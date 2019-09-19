#!/bin/bash

# check preconditions
if [ -z "${JAVA_HOME}" ]; then echo "JAVA_HOME not set. Run using JAVA_HOME=/path/to/java/ ./build.sh"; exit 1; fi
if [ ! -x ./tools/packager/jpackager ]; then echo "./tools/packager/jpackager not executable."; exit 1; fi
if [ ! -f ./libs/version.txt ]; then echo "./libs/version.txt does not exist."; exit 1; fi
BUILD_VERSION=`cat libs/version.txt`

# create app dir
./tools/packager/jpackager create-image \
    --verbose \
    --echo-mode \
    --input libs \
    --main-jar launcher-${BUILD_VERSION}.jar  \
    --class org.cryptomator.launcher.Cryptomator \
    --jvm-args "-Dcryptomator.logDir=\"~/.local/share/Cryptomator/logs\"" \
    --jvm-args "-Dcryptomator.settingsPath=\"~/.config/Cryptomator/settings.json:~/.Cryptomator/settings.json\"" \
    --jvm-args "-Dcryptomator.ipcPortPath=\"~/.config/Cryptomator/ipcPort.bin:~/.Cryptomator/ipcPort.bin\"" \
    --jvm-args "-Dcryptomator.mountPointsDir=\"~/.local/share/Cryptomator/mnt\"" \
    --jvm-args "-Xss2m" \
    --jvm-args "-Xmx512m" \
    --jvm-args "-Djdk.gtk.version=2" \
    --output app \
    --force \
    --identifier org.cryptomator \
    --name Cryptomator \
    --version ${BUILD_VERSION} \
    --module-path ${JAVA_HOME}/jmods \
    --add-modules java.base,java.logging,java.xml,java.sql,java.management,java.security.sasl,java.naming,java.datatransfer,java.security.jgss,java.rmi,java.scripting,java.prefs,java.desktop,jdk.security.auth,jdk.unsupported,java.net.http,jdk.crypto.ec \
    --strip-native-commands

# archive app dir
tar -C app -czf appdir.tar.gz Cryptomator
