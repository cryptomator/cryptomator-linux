#!/bin/sh
cd $(dirname $0)

BUILD_NUMBER=$(cat ./build.number)

# determine GTK version
DETERMINE_CMD_GTK2="echo" #just a dummy
DETERMINE_CMD_GTK3="echo" #just a dummy
if [ -n $(which dpkg) ]
    then #do stuff for debian based things
    DETERMINE_CMD_GTK2="dpkg -l libgtk* | grep -e '\^ii' | grep -e 'libgtk2-*'"
    DETERMINE_CMD_GTK3="dpkg -l libgtk* | grep -e '\^ii' | grep -e 'libgtk3-*'"
elif [ -n $(which rpm) ]
    then # do stuff for rpm based things
    DETERMINE_CMD_GTK2="rpm -qa | grep -e '^gtk2-[0-9][0-9]*'"
    DETERMINE_CMD_GTK3="rpm -qa | grep -e '^gtk3-[0-9][0-9]*'"
elif [ -n $(which pacman)]
    then #don't forget arch
    DETERMINE_CMD_GTK2="pacman -Qi gtk2"
    DETERMINE_CMD_GTK3="pacman -Qi gtk3"
fi

CMD_OUT_NOT_EMPTY=$( test -z $(eval $DETERMINE_CMD_GTK2) )
GTK2_PRESENT=$( test $? -eq 0 )  &&  $CMD_OUT_NOT_EMPTY

CMD_OUT_NOT_EMPTY=$( [ -z $(eval $DETERMINE_CMD_GTK3) ] )
GTK3_PRESENT=$( test $? -eq 0 ) && $CMD_OUT_NOT_EMPTY

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