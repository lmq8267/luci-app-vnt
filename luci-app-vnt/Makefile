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

define Package/$(PKG_NAME)/preinst
#!/bin/sh
echo "开始检测是否安装一些必需的模块组件..."
echo "更新自带的软件仓库列表..."
opkg update
if [ -z "`opkg list-installed|grep kmod-tun`" ] ; then
  echo "未安装tun模块，开始安装kmod-tun模块..."
  opkg update
  opkg install kmod-tun
fi
if [ -z "`opkg list-installed|grep luci-lib-fs`" ] ; then
  echo "未安装fs模块，开始安装luci-lib-fs模块..."
  opkg update
  opkg install luci-lib-fs
fi
if [ -z "`opkg list-installed|grep luci-base`" ] ; then
  echo "未安装base模块，开始安装luci-base模块..."
  opkg update
  opkg install luci-base
fi
if [ -z "`opkg list-installed|grep luci-compat`" ] ; then
  echo "未安装luci-compat，开始安装luci-compat..."
  opkg update
  opkg install luci-compat
fi
endef

define Package/$(PKG_NAME)/prerm
#!/bin/sh
if [ -f /etc/config/vnt ] ; then
  echo "备份vnt配置文件/etc/config/vnt到/tmp/vnt_backup"
  echo "再次安装luci-app-vnt 配置不丢失，如果重启机器此配置文件将会丢失"
  mv -f /etc/config/vnt /tmp/vnt_backup
fi
endef

define Package/$(PKG_NAME)/postinst
#!/bin/sh
chmod +x /etc/init.d/vnt
if [ -f /tmp/vnt_backup ] ; then
  echo "备份vnt配置文件/etc/config/vnt到/tmp/vnt_backup"
  mv -f /tmp/vnt_backup /etc/config/vnt
  if [ "$(uci -q set vnt.@vnt-cli[0].enabled)" = "1" ] || [ "$(uci -q set vnt.@vnts[0].enabled)" = "1" ] ; then
     echo "开始启动vnt..."
     /etc/init.d/vnt restart &
  fi
fi
endef

include $(TOPDIR)/feeds/luci/luci.mk

# call BuildPackage - OpenWrt buildroot signature
