#!/bin/sh

VM670_Kernel=device/lge/thunderc_VM670/files/kernel
kerenl=arch/arm/boot/zImage
version=-OM-v4.1.3.1
sed -i s/CONFIG_LOCALVERSION=\".*\"/CONFIG_LOCALVERSION=\"$version-${1}\"/ .config; make -j2

if [ -e $kernel ]; then
	sed -i s/CONFIG_LOCALVERSION=\".*\"/CONFIG_LOCALVERSION=\"\"/ .config
	cp .config arch/arm/configs/chaos_defconfig
	cp -f $kerenl \
		drivers/net/tun.ko zip/system/lib/modules \
		drivers/net/wireless/*/*.ko zip/system/lib/modules ../../$VM670_Kernel
	echo "  Copying kernel and module drivers"
fi

echo "  Now making flash install zip"

mkdir -p zip/system/lib/modules
cp -f $kerenl zip/kernel
cp -f drivers/net/tun.ko zip/system/lib/modules
cp -f drivers/net/wireless/*/*.ko zip/system/lib/modules

zipfile="OM-Mandylion-Kernel.zip"
if [ ! $4 ]; then
	cd zip/
	rm -f *.zip
	zip -q -r $zipfile *
	rm -f /tmp/*.zip
	cp *.zip /tmp
fi
