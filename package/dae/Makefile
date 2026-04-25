# SPDX-License-Identifier: GPL-2.0-only
#
# Copyright (C) 2023 ImmortalWrt.org

include $(TOPDIR)/rules.mk

PKG_NAME:=dae
PKG_VERSION:=$(shell date "+%Y.%m.%d")
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
#PKG_SOURCE_URL:=https://github.com/daeuniverse/dae.git
PKG_SOURCE_URL:=https://github.com/olicesx/dae.git
GIT_BRANCH:=kdae
PKG_SOURCE_PROTO:=git
PKG_SOURCE_VERSION:=$(shell git ls-remote $(PKG_SOURCE_URL) $(GIT_BRANCH) | cut -c1-7)
PKG_MIRROR_HASH:=

PKG_LICENSE:=AGPL-3.0-only
PKG_LICENSE_FILE:=LICENSE
PKG_MAINTAINER:=Tianling Shen <cnsztl@immortalwrt.org>

PKG_BUILD_DEPENDS:=golang/host bpf-headers
PKG_BUILD_PARALLEL:=1
PKG_BUILD_FLAGS:=no-mips16

GO_PKG:=github.com/daeuniverse/dae
GO_PKG_EXCLUDES:=control/kern/tests
GO_PKG_LDFLAGS:= \
	-s -w -buildid= \
	-linkmode external -extldflags '-static -Wl,-s'
GO_PKG_LDFLAGS_X:= \
	$(GO_PKG)/cmd.Version=$(PKG_SOURCE_VERSION) \
	$(GO_PKG)/common/consts.MaxMatchSetLen_=1024
GO_PKG_TAGS:=embedallowed,trace

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/bpf.mk
include $(TOPDIR)/feeds/packages/lang/golang/golang-package.mk

GO_PKG_BUILD_VARS+= \
	GOFLAGS="-trimpath -buildvcs=false -pgo=auto"

GO_PKG_TARGET_VARS+= \
	CGO_LDFLAGS="$(TARGET_LDFLAGS) -static -Wl,-s" \
	CGO_ENABLED=1 \
	GOEXPERIMENT=newinliner,simd

TAR_CMD=$(HOST_TAR) -C $(BUILD_DIR)/ $(TAR_OPTIONS)

define Package/dae/Default
  SECTION:=net
  CATEGORY:=Network
  SUBMENU:=Web Servers/Proxies
  URL:=https://github.com/daeuniverse/dae
endef

define Package/dae
  $(call Package/dae/Default)
  TITLE:=A lightweight and high-performance transparent proxy solution
  # You need enable KERNEL_DEBUG_INFO_BTF and KERNEL_BPF_EVENTS
  DEPENDS:=$(GO_ARCH_DEPENDS) $(BPF_DEPENDS)  \
    +ca-bundle +kmod-sched-core +kmod-sched-bpf +kmod-xdp-sockets-diag \
    +kmod-veth +v2ray-geoip +v2ray-geosite
endef

define Package/dae/description
  dae, means goose, is a lightweight and high-performance transparent
  proxy solution.

  In order to improve the traffic diversion performance as much as possible,
  dae runs the transparent proxy and traffic diversion suite in the linux
  kernel by eBPF. Therefore, we have the opportunity to make the direct
  traffic bypass the forwarding by proxy application and achieve true direct
  traffic through. Under such a magic trick, there is almost no performance
  loss and additional resource consumption for direct traffic.
endef



define Package/dae/conffiles
/etc/dae/config.dae
/etc/config/dae
endef

define Build/Prepare
	( \
		rm -rf $(PKG_BUILD_DIR) && git clone -b $(GIT_BRANCH) $(PKG_SOURCE_URL) $(PKG_BUILD_DIR) ; \
		rm -rf $(PKG_BUILD_DIR)/../outbound && git clone --depth=1 -b perf/complete-optimizations https://github.com/olicesx/outbound.git $(PKG_BUILD_DIR)/../outbound ; \
		rm -rf $(PKG_BUILD_DIR)/../quic-go && git clone --depth=1 -b main https://github.com/olicesx/quic-go.git $(PKG_BUILD_DIR)/../quic-go ; \
		pushd $(PKG_BUILD_DIR) ; \
		go mod edit -replace github.com/daeuniverse/outbound=../outbound ; \
		go mod edit -replace github.com/daeuniverse/quic-go=../quic-go ; \
		go get -u=patch ; \
		git submodule update --init ; \
		go mod tidy ; \
		popd ; \
	)
endef

DAE_CFLAGS:= \
	-O2 -Wall -Werror \
	-DMAX_MATCH_SET_LEN=1024 \
	-D__UNROLL_ROUTE_LOOP \
	-I$(BPF_HEADERS_DIR)/tools/lib \
	-I$(BPF_HEADERS_DIR)/arch/$(BPF_KARCH)/include/asm/mach-generic

ifneq ($(CONFIG_USE_MUSL),)
  TARGET_CFLAGS += -D_LARGEFILE64_SOURCE
endif

define Build/Compile
	( \
		export \
		$(GO_GENERAL_BUILD_CONFIG_VARS) \
		$(GO_PKG_BUILD_CONFIG_VARS) \
		$(GO_PKG_BUILD_VARS) \
		BPF_CLANG="$(CLANG)" \
		BPF_STRIP_FLAG="-strip=$(LLVM_STRIP)" \
		BPF_CFLAGS="$(DAE_CFLAGS)" \
		BPF_TARGET="bpfel,bpfeb" \
		BPF_TRACE_TARGET="$(GO_ARCH)" ; \
		go generate $(PKG_BUILD_DIR)/control/control.go ; \
		go generate $(PKG_BUILD_DIR)/trace/trace.go ; \
		$(call GoPackage/Build/Compile) ; \
	)
endef

define Package/dae/install
	$(call GoPackage/Package/Install/Bin,$(1))

	$(INSTALL_DIR) $(1)/etc/dae/
	$(INSTALL_CONF) $(PKG_BUILD_DIR)/example.dae $(1)/etc/dae/

	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_CONF) $(CURDIR)/files/dae.config $(1)/etc/config/dae

	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) $(CURDIR)/files/dae.init $(1)/etc/init.d/dae

	$(INSTALL_DIR) $(1)/usr/share/dae
	$(LN) ../v2ray/geoip.dat $(1)/usr/share/dae/geoip.dat

	$(INSTALL_DIR) $(1)/usr/share/dae
	$(LN) ../v2ray/geosite.dat $(1)/usr/share/dae/geosite.dat
endef


$(eval $(call GoBinPackage,dae))
$(eval $(call BuildPackage,dae))

