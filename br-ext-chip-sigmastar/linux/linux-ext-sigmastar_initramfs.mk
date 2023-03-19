################################################################################
#
# linux-ext-sigmastar_initramfs
#
################################################################################

ifeq ($(BR2_LINUX_KERNEL_EXT_SIGMASTAR_INITRAMFS),y)
LINUX_EXTENSIONS += sigmastar-initramfs
endif

SIGMASTAR_INITRAMFS_BUSYBOX_VERSION = 1.36.0
SIGMASTAR_INITRAMFS_BUSYBOX_SOURCE = busybox-$(SIGMASTAR_INITRAMFS_BUSYBOX_VERSION).tar.bz2
SIGMASTAR_INITRAMFS_BUSYBOX_SITE = https://www.busybox.net/downloads

SIGMASTAR_INITRAMFS_DOSFSTOOLS_VERSION = 4.2
SIGMASTAR_INITRAMFS_DOSFSTOOLS_SOURCE = dosfstools-$(SIGMASTAR_INITRAMFS_DOSFSTOOLS_VERSION).tar.gz
SIGMASTAR_INITRAMFS_DOSFSTOOLS_SITE = https://github.com/dosfstools/dosfstools/releases/download/v$(SIGMASTAR_INITRAMFS_DOSFSTOOLS_VERSION)

SIGMASTAR_INITRAMFS_TOOLCHAIN_SOURCE = cortex_a7_thumb2_hf-gcc8.4.0-musl-4_9-1e913a17.tgz
SIGMASTAR_INITRAMFS_TOOLCHAIN_SITE = https://github.com/openipc/firmware/releases/download/latest

SIGMASTAR_INITRAMFS_BUSYBOX_PATH = $(HOST_DIR)/source/busybox-$(SIGMASTAR_INITRAMFS_BUSYBOX_VERSION)
SIGMASTAR_INITRAMFS_DOSFSTOOLS_PATH = $(HOST_DIR)/source/dosfstools-$(SIGMASTAR_INITRAMFS_DOSFSTOOLS_VERSION)
SIGMASTAR_INITRAMFS_TOOLCHAIN_PATH = $(HOST_DIR)/source/arm-openipc-linux-musleabihf_sdk-buildroot/bin

define SIGMASTAR_INITRAMFS_PREPARE_KERNEL
	mkdir -p $(LINUX_DIR)/initramfs
	cp -f $(SIGMASTAR_INITRAMFS_PKGDIR)/files/* $(LINUX_DIR)/initramfs

	wget $(SIGMASTAR_INITRAMFS_BUSYBOX_SITE)/$(SIGMASTAR_INITRAMFS_BUSYBOX_SOURCE) -P $(HOST_DIR)/source -c
	tar -xf $(HOST_DIR)/source/$(SIGMASTAR_INITRAMFS_BUSYBOX_SOURCE) -C $(HOST_DIR)/source

	wget $(SIGMASTAR_INITRAMFS_DOSFSTOOLS_SITE)/$(SIGMASTAR_INITRAMFS_DOSFSTOOLS_SOURCE) -P $(HOST_DIR)/source -c
	tar -xf $(HOST_DIR)/source/$(SIGMASTAR_INITRAMFS_DOSFSTOOLS_SOURCE) -C $(HOST_DIR)/source

	wget $(SIGMASTAR_INITRAMFS_TOOLCHAIN_SITE)/$(SIGMASTAR_INITRAMFS_TOOLCHAIN_SOURCE) -P $(HOST_DIR)/source -c
	tar -xf $(HOST_DIR)/source/$(SIGMASTAR_INITRAMFS_TOOLCHAIN_SOURCE) -C $(HOST_DIR)/source

	cp -f $(SIGMASTAR_INITRAMFS_PKGDIR)/files/initramfs_defconfig $(SIGMASTAR_INITRAMFS_BUSYBOX_PATH)/.config
	$(MAKE) CROSS_COMPILE=$(SIGMASTAR_INITRAMFS_TOOLCHAIN_PATH)/arm-linux- -C $(SIGMASTAR_INITRAMFS_BUSYBOX_PATH)
	cp -f $(SIGMASTAR_INITRAMFS_BUSYBOX_PATH)/busybox $(LINUX_DIR)/initramfs

	cd $(SIGMASTAR_INITRAMFS_DOSFSTOOLS_PATH) && ./autogen.sh && ./configure
	$(MAKE) CC=$(SIGMASTAR_INITRAMFS_TOOLCHAIN_PATH)/arm-linux-gcc CFLAGS="-static -s" -C $(SIGMASTAR_INITRAMFS_DOSFSTOOLS_PATH)
	cp -f $(SIGMASTAR_INITRAMFS_DOSFSTOOLS_PATH)/src/fsck.fat $(LINUX_DIR)/initramfs
endef