
all: git-init mmcblk0p1.img mmcblk0p2.img

git-init:
	git submodule init
	git submodule update

openwrt/feeds.conf:
	cp -a $< $@

openwrt/feeds/packages/README.md: openwrt/feeds.conf
	openwrt/scripts/feeds update -a

openwrt/feeds/packages.tmp/.packageinfo: openwrt/feeds/packages/README.md
	openwrt/scripts/feeds install -a

openwrt/.config: openwrt-cfg/.config
	cp -a $< $@

openwrt/build_dir/target-arm_arm926ej-s_musl_eabi/linux-mxs_generic/zImage-initramfs: openwrt/feeds/packages.tmp/.packageinfo openwrt/.config
	ln -snf ../openwrt-cfg/files openwrt/files
	$(MAKE) -C openwrt

linux/arch/arm/boot/dts/nxp/mxs/imx28-evacharge-se.dtb:
	$(MAKE) -C linux ARCH=arm CROSS_COMPILE="arm-linux-gnueabi-" mxs_defconfig
	$(MAKE) -C linux ARCH=arm CROSS_COMPILE="arm-linux-gnueabi-" dtbs

imx-bootlets/zImage: openwrt/build_dir/target-arm_arm926ej-s_musl_eabi/linux-mxs_generic/zImage-initramfs linux/arch/arm/boot/dts/nxp/mxs/imx28-evacharge-se.dtb
	cat openwrt/build_dir/target-arm_arm926ej-s_musl_eabi/linux-mxs_generic/zImage-initramfs linux/arch/arm/boot/dts/nxp/mxs/imx28-evacharge-se.dtb > imx-bootlets/zImage

imx-bootlets/imx28_ivt_linux.sb: imx-bootlets/zImage
	$(MAKE) -C imx-bootlets -j1 CROSS_COMPILE="arm-linux-gnueabi-" MEM_TYPE=MEM_DDR1 BOARD="evachargese"

imx-uuc/sdimage:
	$(MAKE) -C imx-uuc sdimage

SBSIZE = $(shell stat -c "%s" imx-bootlets/imx28_ivt_linux.sb)
DDSIZE = $(shell expr $(SBSIZE) + 2048)

mmcblk0p1.img: imx-uuc/sdimage partition-container.sh imx-bootlets/imx28_ivt_linux.sb
	rm -f mmcblk0.img mmcblk0p1.img
	dd if=/dev/zero of=mmcblk0.img bs=1M count=10
	sh partition-container.sh mmcblk0.img 1
	imx-uuc/sdimage -d mmcblk0.img -f imx-bootlets/imx28_ivt_linux.sb
	dd if=mmcblk0.img of=mmcblk0p1.img bs=1M count=8 skip=1
	rm -f mmcblk0.img
	truncate -s $(DDSIZE) mmcblk0p1.img

mmcblk0p2.img: imx-uuc/sdimage partition-container.sh imx-bootlets/imx28_ivt_linux.sb
	rm -f mmcblk0.img mmcblk0p2.img
	dd if=/dev/zero of=mmcblk0.img bs=1M count=72
	sh partition-container.sh mmcblk0.img 2
	imx-uuc/sdimage -d mmcblk0.img -f imx-bootlets/imx28_ivt_linux.sb
	dd if=mmcblk0.img of=mmcblk0p2.img bs=1 count=8388608 skip=37757440
	rm -f mmcblk0.img
	truncate -s $(DDSIZE) mmcblk0p2.img
