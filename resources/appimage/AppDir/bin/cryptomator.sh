#!/bin/sh
cd $(dirname $0)

# determine GTK version
GTK2_PRESENT=$(test -z "x") #always false
GTK3_PRESENT=$(test -z "") #always true
if command -v dpkg &> /dev/null; then #do stuff for debian based things
	GTK2_PRESENT=$( test -z `dpkg -l libgtk* | grep -e '\^ii' | grep -e 'libgtk2-*'` )
	GTK3_PRESENT=$( test -z `dpkg -l libgtk* | grep -e '\^ii' | grep -e 'libgtk3-*'` )
elif command -v rpm &> /dev/null; then # do stuff for rpm based things
	GTK2_PRESENT=$( test -z `rpm -qa | grep -e '\^gtk2-[0-9][0-9]*'` )
	GTK3_PRESENT=$( test -z `rpm -qa | grep -e '\^gtk3-[0-9][0-9]*'` )
elif command -v pacman &> /dev/null; then #don't forget arch
	pacman -Qi gtk2
	GTK2_PRESENT=$( test $? -eq 0 )
	pacman -Qi gtk3
	GTK3_PRESENT=$( test $? -eq 0 )
fi


if $GTK2_PRESENT && (! $GTK3_PRESENT ); then
	GTK_FLAG="-Djdk.gtk.version=2"
fi

# workaround for issue #27
export LD_PRELOAD=libs/libjffi.so

# start Cryptomator
./runtime/bin/java \
	-cp "./libs/*" \
	-Dcryptomator.logDir="~/.local/share/Cryptomator/logs" \
	-Dcryptomator.mountPointsDir="~/.local/share/Cryptomator/mnt" \
	-Dcryptomator.settingsPath="~/.config/Cryptomator/settings.json:~/.Cryptomator/settings.json" \
	-Dcryptomator.ipcPortPath="~/.config/Cryptomator/ipcPort.bin:~/.Cryptomator/ipcPort.bin" \
	-Dcryptomator.buildNumber="appimage-${REVISION_NO}" \
	$GTK_FLAG \
	-Xss2m \
	-Xmx512m \
	org.cryptomator.launcher.Cryptomator
