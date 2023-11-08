#
# Copyright (C) 2008-2014 The LuCI Team <luci@lists.subsignal.org>
#
# This is free software, licensed under the Apache License, Version 2.0 .
#

include $(TOPDIR)/rules.mk

PKG_VERSION:=1.0.0
PKG_RELEASE:=1

LUCI_TITLE:=vnt VPN Configuration module
LUCI_DEPENDS:=+kmod-tun +luci-lib-fs
LUCI_PKGARCH:=all

PKG_NAME:=luci-app-vnt

define Package/$(PKG_NAME)/postinst
#!/bin/sh
chmod +x /etc/init.d/vnt
endef


include $(TOPDIR)/feeds/luci/luci.mk

# call BuildPackage - OpenWrt buildroot signature
