KERNEL_MODULE_VERSION = e9d88ebad195561a0b788d36f59bc67a7bcc697b
KERNEL_MODULE_SITE = https://github.com/Seeed-Studio/seeed-linux-dtoverlays.git
KERNEL_MODULE_SITE_METHOD = git
KERNEL_MODULE_INSTALL_STAGING = NO
KERNEL_MODULE_INSTALL_TARGET = YES
KERNEL_MODULE_DEPENDENCIES += dtc linux

define KERNEL_MODULE_BUILD_CMDS
	rm -rf $(@D)/*
	git clone -b master https://github.com/Seeed-Studio/seeed-linux-dtoverlays.git $(@D)/tmp/
	cp -r $(@D)/tmp/* $(@D)/
	rm -rf $(@D)/tmp/
	sed -i '/* install_arch/d' $(@D)/Makefile
	sed -i 's/@which\ depmod\ >\/dev\/null 2>\&1\ \&\&\ depmod\ -a\ ||\ true//g' $(@D)/Makefile
	$(MAKE) ARCH="$(KERNEL_ARCH)" \
		CC="$(TARGET_CC)" \
		DTC="$(HOST_DIR)/bin/dtc" \
		KBUILD="$(LINUX_DIR)" \
		CROSS_COMPILE="$(TARGET_CROSS)" \
		-C $(@D) all_rpi
endef

define KERNEL_MODULE_INSTALL_TARGET_CMDS
	$(INSTALL) -D -m 0644 $(@D)/overlays/rpi/$(BR2_DEV_NAME)-overlay.dtbo $(BINARIES_DIR)/rpi-firmware/overlays/$(BR2_DEV_NAME).dtbo
	$(if $(filter "reComputer-R2x",$(BR2_DEV_NAME)), \
        $(INSTALL) -D -m 0644 $(@D)/overlays/rpi/reComputer-R21-overlay.dtbo $(BINARIES_DIR)/rpi-firmware/overlays/reComputer-R21.dtbo, \
    )
	mkdir -p $(TARGET_DIR)/lib/modules/$(LINUX_VERSION_PROBED)/extra/
	$(MAKE) ARCH="$(KERNEL_ARCH)" CROSS_COMPILE="$(TARGET_CROSS)" KBUILD="$(LINUX_DIR)" KO_DIR="$(TARGET_DIR)/lib/modules/$(LINUX_VERSION_PROBED)/extra/" -C $(@D) install_rpi
	$(HOST_DIR)/sbin/depmod -a -b $(TARGET_DIR) $(LINUX_VERSION_PROBED)
endef

$(eval $(generic-package))
