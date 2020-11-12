#!/bin/sh
cd $(dirname $0)

BUILD_NUMBER=$(cat ./build.number)

# determine GTK version
GTK2_CMD_OUT="echo" #just a dummy
GTK3_CMD_OUT="echo" #just a dummy
if [ -n $(which dpkg) ]
    then #do stuff for debian based things
    GTK2_CMD_OUT=`dpkg -l libgtk* | grep -e '\^ii' | grep -e 'libgtk2-*'`
    GTK3_CMD_OUT=`dpkg -l libgtk* | grep -e '\^ii' | grep -e 'libgtk3-*'`
elif [ -n $(which rpm) ]
    then # do stuff for rpm based things
    GTK2_CMD_OUT=`rpm -qa | grep -e '\^gtk2-[0-9][0-9]*'`
    GTK3_CMD_OUT=`rpm -qa | grep -e '\^gtk3-[0-9][0-9]*'`
elif [ -n $(which pacman)]
    then #don't forget arch
    GTK2_CMD_OUT=`pacman -Qi gtk2`
    GTK3_CMD_OUT=`pacman -Qi gtk3`
fi

GTK2_PRESENT=$( test $? -eq 0 )  &&  $( test -z $GTK2_CMD_OUT)
GTK3_PRESENT=$( test $? -eq 0 ) && $( test -z $GTK3_CMD_OUT )

if $GTK2_PRESENT && (! $GTK3_PRESENT )
    then
    GTK_FLAG="-Djdk.gtk.version=2"
    else
    GTK_FLAG="-Djdk.gtk.version=3"
fi

# workaround for ISSUE
export LD_PRELOAD=libs/libjffi.so

# start Cryptomator
./runtimeImage/bin/java \
	-cp "./libs/*" \
	-Dcryptomator.logDir="~/.local/share/Cryptomator/logs" \
	-Dcryptomator.mountPointsDir="~/.local/share/Cryptomator/mnt" \
    -Dcryptomator.settingsPath="~/.config/Cryptomator/settings.json:~/.Cryptomator/settings.json" \
    -Dcryptomator.ipcPortPath="~/.config/Cryptomator/ipcPort.bin:~/.Cryptomator/ipcPort.bin" \
    -Dcryptomator.buildNumber="appimage-${BUILD_NUMBER}" \
    $GTK_FLAG \
    -Xss2m \
    -Xmx512m \
	org.cryptomator.launcher.Cryptomator