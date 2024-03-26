#
# Copyright (C) 2008-2014 The LuCI Team <luci@lists.subsignal.org>
#
# This is free software, licensed under the Apache License, Version 2.0 .
#

include $(TOPDIR)/rules.mk

PKG_VERSION:=1.3.0
PKG_RELEASE:=1

LUCI_TITLE:=LuCI support for vnt
LUCI_DEPENDS:=
LUCI_PKGARCH:=all

PKG_NAME:=luci-app-vnt

define Package/$(PKG_NAME)/prerm
#!/bin/sh
if [ -f /etc/config/vnt ] ; then
  echo "备份vnt配置文件/etc/config/vnt到/tmp/vnt_backup"
  echo "再次安装luci-app-vnt 配置不丢失,不用重新配置，如果重启机器此配置文件将会丢失"
  mv -f /etc/config/vnt /tmp/vnt_backup
fi
vntsbin="$(uci -q get vnt.@vnts[0].vntsbin)"
path=$(dirname "$vntsbin")
web_path="${path}/static"
[ -d "$web_path" ] && rm -rf $web_path
endef

define Package/$(PKG_NAME)/postinst
#!/bin/sh
chmod +x /etc/init.d/vnt
if [ -f /tmp/vnt_backup ] ; then
  echo "发现vnt备份配置文件/tmp/vnt_backup，开始恢复到/etc/config/vnt"
  mv -f /tmp/vnt_backup /etc/config/vnt
  if [ "$(uci -q get vnt.@vnt-cli[0].enabled)" = "1" ] || [ "$(uci -q get vnt.@vnts[0].enabled)" = "1" ] ; then
     echo "开始启动vnt..."
     /etc/init.d/vnt restart &
  fi
fi
endef

include $(TOPDIR)/feeds/luci/luci.mk

# call BuildPackage - OpenWrt buildroot signature
