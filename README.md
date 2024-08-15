# 自用OpenWrt软件包仓库

<img src="https://v2.jinrishici.com/one.svg?font-size=24&spacing=2&color=Black">

## 说明

* 常用OpenWrt软件包源码合集，同步上游更新！
* 软件不定期同步大神库更新，适合一键下载用于openwrt编译

## 使用

一键命令
```yaml
sed -i '$a src-git genIoco https://github.com/genIoco/openwrt-packages' feeds.conf.default
git pull
./scripts/feeds update -a
./scripts/feeds install -a
make menuconfig
```
