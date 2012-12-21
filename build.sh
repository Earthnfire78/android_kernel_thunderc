#!/bin/sh
copy_kernel () {
	if [ -e $kernel ]; then
		sed -i s/CONFIG_LOCALVERSION=\".*\"/CONFIG_LOCALVERSION=\"\"/ .config
		cp -f .config arch/arm/configs/chaos_defconfig
		cp -f $kerenl \
			drivers/net/tun.ko \
			drivers/net/wireless/*/*.ko ../../$kernel_type
		echo
		echo "  Copying kernel and module drivers"
	else
		echo "  ERROR: Compiling kernel"
		exit 0
	fi
}
do_compile () {
	echo
	kerenl=arch/arm/boot/zImage
	echo "Compiling Kernel: 2.6.32.9-$version-Mike@Mandylion-`date +%H%M%S`))"
	echo
	sed -i s/CONFIG_LOCALVERSION=\".*\"/CONFIG_LOCALVERSION=\"$version-${1}\"/ .config; make -j3
        echo
	echo "  Ziping package"

	mkdir -p zip/system/lib/modules
	cp -f $kerenl zip/kernel
	cp -f drivers/net/tun.ko \
		drivers/net/wireless/*/*.ko zip/system/lib/modules
	cp -f Documentation/install/update-binary zip/META-INF/com/google/android
	

	if [ ! $4 ]; then
		cd zip/
		rm -f *.zip
		zip -q -r update.zip *
		rm -f /tmp/*.zip
		cp *.zip /tmp
		echo "  Signing Pakcage."
                echo
		java -Xmx512m -jar ../../../out/host/linux-x86/framework/signapk.jar -w \
			../../../build/target/product/security/testkey.x509.pem ../../../build/target/product/security/testkey.pk8 \
			../zip/update.zip ../zip/$zipfile
		rm -f update.zip
                md5sum $zipfile > $zipfile.md5sum
                cat $zipfile.md5sum
                echo
                cd ..
	fi
}

compile_vm () {
        rm -f zip/system/build.prop
	version=-VM670-OM-`date +%Y%m%d`
	kernel_type=device/lge/thunderc_VM670/files/kernel
	zipfile="VM670-OM-Kernel.zip"; cp -f arch/arm/configs/vm670_config .config
	cp -f Documentation/install/updater-script.vm670 zip/META-INF/com/google/android/updater-script
	do_compile; cp -f .config arch/arm/configs/vm670_config
}

compile_ls () {
	version=-LS670-OM-`date +%Y%m%d`
	kernel_type=device/lge/thunderc_LS670/files/kernel
	zipfile="LS670-OM-Kernel.zip"; cp -f arch/arm/configs/ls670_config .config
	cp -f Documentation/install/updater-script.ls670 zip/META-INF/com/google/android/updater-script 
	do_compile; cp -f .config arch/arm/configs/ls670_config
}
restart () {
	# Start sciprt here for easier editing
	echo
	echo "Pick one of the options below as to what you would like to do."
	echo
	echo "version you would like to compile." 
	echo
	echo "   Compile VM670 kernel   - 1"
	echo
	echo "   Compile LS670 kernel   - 2"
	echo
	echo "   Compile VM kernel test - 3"
	echo
	echo "   Compile LS kernel test - 4"
	echo
	echo "   Push to Git            - 5"
	echo
	echo "   Clean out build        - 6"
	echo
	echo -n "Enter Option: "
	read compile_kernel
	case $compile_kernel in
		1)	compile_vm; copy_kernel; echo ;;
		2)	compile_ls; copy_kernel; echo ;;
		3)	compile_vm; echo ;;
		4)	compile_ls; echo ;;
		5)	git_push; echo ;;
		6)	echo; make clean; clear; restart ;;
		x)  	echo; leave;;
		*)
			echo; echo "    Please chose one of the above options"; sleep 3
		;;
	esac
}

git_push () {
	git init
        echo
        git add .
        echo
        echo
        echo -e "  Enter commit message: "
	read commit_message 
        git commit -m "$commit_message"
        echo
        git push
}
restart

