#!/bin/bash

# 映射表：将类型映射到相应的处理函数
declare -A handlers
handlers["src-git"]="handle_src_git"
handlers["src-git-spares"]="handle_src_git_spares"
config_file="packages.conf"

# 定义克隆函数
function git_clone(){
  git clone --depth 1 $@
  if [ "$?" != 0 ]; then
    echo "error on $1"
    pid="$( ps -q $$ )"
    kill $pid
  fi
}

function mvdir() {
  mkdir -p $2 && rm -rf $2/* $2/.[!.]*
  find $1 -mindepth 1 -maxdepth 1 ! -name ".git" -exec mv -n {} "$2/" \;
  rm -rf $1
}

# 处理 src-git 的函数
function handle_src_git() {
  local line=$1
  # 解析行参数
  local repo_url=$(echo $line | cut -d' ' -f2)
  local src_dir=$(echo $line | cut -d' ' -f3)
  local target_dir=$(echo $line | cut -d' ' -f4)

  local repo_name=$(basename $repo_url .git)  # 仓库名称
  local repo_dir="/tmp/$repo_name"  # 临时克隆目录

  echo "Cloning $repo_url into temporary directory $repo_dir..."
  git_clone $repo_url $repo_dir
  
  echo "Moving contents to $target_dir..."
  mvdir $repo_dir$src_dir $target_dir

}

# 处理 src-git-spares 的函数
function handle_src_git_spares() {
  local line=$1
  # 解析行参数
  local repo_url=$(echo $line | cut -d' ' -f2)
  local branch=$(echo $line | cut -d' ' -f3)
  local src_dir=$(echo $line | cut -d' ' -f4)
  local target_dir=$(echo $line | cut -d' ' -f5)

  local repo_name=$(basename $repo_url .git)  # 仓库名称
  local repo_dir="/tmp/$repo_name"  # 临时克隆目录
  
  echo "Cloning $repo_url (branch: $branch) into temporary directory $repo_dir..."
  git_clone $repo_url $repo_dir -b $branch
  
  echo "Moving contents to $target_dir..."
  mvdir $repo_dir$src_dir $target_dir

}

# 主函数：读取packages.conf并传递整行给处理函数
function sync_packages() {

  while IFS= read -r line ||[ -n "$line" ]; do
    echo "Processing: $line"
    # 忽略空行和注释行
    if [[ -z "$line" || $line == \#* ]]; then
      continue
    fi
    # 提取类型 
    type=$(echo $line | cut -d' ' -f1)
    

    # 调用相应的处理函数，并传递整行内容
    if [[ -n "${handlers[$type]}" ]]; then
      ${handlers[$type]} "$line"
    else
      echo "No handler defined for type: $type"
    fi
  done < "$config_file"
}

# 调用主函数
sync_packages
