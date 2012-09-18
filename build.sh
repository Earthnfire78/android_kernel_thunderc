#!/bin/sh


VM670_Kernel=device/lge/thunderc_VM670/files/kernel
kerenl=arch/arm/boot/zImage
sed -i s/CONFIG_LOCALVERSION=\".*\"/CONFIG_LOCALVERSION=\"-OM-v4.1.0.1-${1}\"/ .config; make -j2

if [ -e $kernel ]; then
	sed -i s/CONFIG_LOCALVERSION=\".*\"/CONFIG_LOCALVERSION=\"\"/ .config
	cp .config arch/arm/configs/chaos_defconfig
	cp -f arch/arm/boot/zImage \
	      drivers/*/tun.ko \
	      drivers/*/wireless/bcm4325/wireless.ko \
	      fs/*/cifs.ko ../../$VM670_Kernel
	echo "Copying kernel and module drivers"
fi
