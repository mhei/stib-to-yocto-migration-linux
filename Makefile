
all:
	git submodule init
	git submodule update
	openwrt/scripts/feeds update -a
	openwrt/scripts/feeds install -a
	$(MAKE) -C openwrt oldconfig
	$(MAKE) -C openwrt
