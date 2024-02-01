#
# Copyright (C) 2008-2014 The LuCI Team <luci@lists.subsignal.org>
#
# This is free software, licensed under the Apache License, Version 2.0 .
#

include $(TOPDIR)/rules.mk

PKG_VERSION:=1.2.0
PKG_RELEASE:=1

LUCI_TITLE:=LuCI support for vnt
LUCI_DEPENDS:=
LUCI_PKGARCH:=all

PKG_NAME:=luci-app-vnt

define Package/$(PKG_NAME)/preinst
#!/bin/sh
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
if [ -f /etc/config/vnt ] ; then
  echo "发现vnt配置文件/etc/config/vnt，备份到/tmp/vnt_backup"
  mv -f /etc/config/vnt /tmp/vnt_backup
fi
endef

define Package/$(PKG_NAME)/postinst
#!/bin/sh
chmod +x /etc/init.d/vnt
if [ -f /tmp/vnt_backup ] ; then
  echo "将备份的配置文件/tmp/vnt_backup还原到/etc/config/vnt"
  mv -f /tmp/vnt_backup /etc/config/vnt
fi
endef

include $(TOPDIR)/feeds/luci/luci.mk

# call BuildPackage - OpenWrt buildroot signature
