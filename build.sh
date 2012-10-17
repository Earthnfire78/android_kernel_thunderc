#!/bin/sh

do_compile () {
	make clean
	kerenl=arch/arm/boot/zImage
	clear
	echo "  Compiling Kernel: 2.6.32.9-$version-Mike@Mandylion-`date +%H%M%S`))"
	echo
	sed -i s/CONFIG_LOCALVERSION=\".*\"/CONFIG_LOCALVERSION=\"$version-${1}\"/ .config; make -j2

	if [ -e $kernel ]; then
		sed -i s/CONFIG_LOCALVERSION=\".*\"/CONFIG_LOCALVERSION=\"\"/ .config
		cp -f .config arch/arm/configs/chaos_defconfig
		cp -f $kerenl \
			drivers/net/tun.ko \
			drivers/net/wireless/*/*.ko ../../$kernel_type
		echo
		echo "  Copying kernel and module drivers"
	fi

	echo "  Now making flash install zip"

	mkdir -p zip/system/lib/modules
	cp -f $kerenl zip/kernel
	cp -f drivers/net/tun.ko zip/system/lib/modules
	cp -f drivers/net/wireless/*/*.ko zip/system/lib/modules

	if [ ! $4 ]; then
		cd zip/
		rm -f *.zip
		zip -q -r update.zip *
		rm -f /tmp/*.zip
		cp *.zip /tmp
		echo "  Signing Kernel zip package."
		java -Xmx512m -jar ../Documentation/framework/signapk.jar -w \
			../Documentation/framework/testkey.x509.pem ../Documentation/framework/testkey.pk8 \
			../zip/update.zip ../zip/$zipfile
		rm -f update.zip
		cd ..
	fi
}

choose_kernel () {
	VM670_Kernel=device/lge/thunderc_VM670/files/kernel
	clear
	echo " Compile VM670 kernel - 1"
	echo " Compile LS670 kernel - 2"
	echo
	echo -n " Enter Option: "
	read compile_kernel
	if [ "$compile_kernel" = "1" ]; then
		version=-VM670-OM-`date +%Y%m%d`
		kernel_type=device/lge/thunderc_VM670/files/kernel
		zipfile="VM670-OM-Kernel.zip"; cp -f arch/arm/configs/vm670_config .config
		do_compile; cp -f .config arch/arm/configs/vm670_config
	elif [ "$compile_kernel" = "2" ]; then
		version=-LS670-OM-`date +%Y%m%d`
		kernel_type=device/lge/thunderc_LS670/files/kernel
		zipfile="LS670-OM-Kernel.zip"; cp -f arch/arm/configs/ls670_config .config
		do_compile; cp -f .config arch/arm/configs/ls670_config
	fi		
}

# Start sciprt here for easier editing
kerenl=arch/arm/boot/zImage
if [ -e $kernel ]; then
	make clean; choose_kernel
else
	choose_kernel
fi

