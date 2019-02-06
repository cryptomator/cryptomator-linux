#!/bin/bash
BUILD_VERSION=${1:-continuous}

# check preconditions
if [ -z "${JAVA_HOME}" ]; then echo "JAVA_HOME not set. Run using JAVA_HOME=/path/to/java/ ./build.sh"; exit 1; fi
if [ ! -x ./tools/packager/jpackager ]; then echo "../tools/packager/jpackager not executable."; exit 1; fi
if [ ! -x ./tools/appimagekit/appimagetool-x86_64.AppImage ]; then echo "./tools/appimagekit/appimagetool-x86_64.AppImage not executable."; exit 1; fi

# create .app
./tools/packager/jpackager create-image \
    --verbose \
    --echo-mode \
    --input libs \
    --main-jar launcher-${BUILD_VERSION}.jar  \
    --class org.cryptomator.launcher.Cryptomator \
    --jvm-args "-Dlogback.configurationFile=\"logback.xml\"" \
    --jvm-args "-Dcryptomator.settingsPath=\"~/.Cryptomator/settings.json\"" \
    --jvm-args "-Dcryptomator.ipcPortPath=\"~/.Cryptomator/ipcPort.bin\"" \
    --jvm-args "-Xss2m" \
    --jvm-args "-Xmx512m" \
    --output app \
    --force \
    --identifier org.cryptomator \
    --name Cryptomator \
    --version ${BUILD_VERSION} \
    --module-path ${JAVA_HOME}/jmods\
    --add-modules java.base,java.logging,java.xml,java.sql,java.management,java.security.sasl,java.naming,java.datatransfer,java.security.jgss,java.rmi,java.scripting,java.prefs,java.desktop,jdk.unsupported \
    --strip-native-commands

# build AppDir
mkdir -p Cryptomator.AppDir/usr/share/icons/hicolor/512x512/apps/
mkdir -p Cryptomator.AppDir/usr/share/icons/hicolor/scalable/apps/
mkdir -p Cryptomator.AppDir/usr/share/applications/
cp -r app/Cryptomator/* Cryptomator.AppDir/
cp resources/appimage/logback.xml Cryptomator.AppDir/app/
cp resources/appimage/cryptomator.svg Cryptomator.AppDir/usr/share/icons/hicolor/scalable/apps/
cp resources/appimage/cryptomator.png Cryptomator.AppDir/usr/share/icons/hicolor/512x512/apps/
cp resources/appimage/cryptomator.desktop Cryptomator.AppDir/usr/share/applications/
cp resources/appimage/cryptomator.appdata.xml Cryptomator.AppDir/usr/share/metainfo/
ln -s usr/share/icons/hicolor/scalable/apps/cryptomator.svg Cryptomator.AppDir/cryptomator.svg
ln -s usr/share/applications/cryptomator.desktop Cryptomator.AppDir/cryptomator.desktop
ln -s Cryptomator Cryptomator.AppDir/AppRun

# extract appimagetool (extraction needed, as FUSE isn't present/allowed on build server)
(cd ./tools/appimagekit && ./appimagetool-x86_64.AppImage --appimage-extract)

# build AppImage
export ARCH=x86_64
if [[ ${BUILD_VERSION} == "continuous" ]]; then
  ./tools/appimagekit/squashfs-root/AppRun Cryptomator.AppDir cryptomator-continuous-x86_64.AppImage -u 'bintray-zsync|cryptomator|cryptomator|cryptomator-linux|cryptomator-continuous-x86_64.AppImage.zsync'
else
  ./tools/appimagekit/squashfs-root/AppRun Cryptomator.AppDir cryptomator-${BUILD_VERSION}-x86_64.AppImage -u 'bintray-zsync|cryptomator|cryptomator|cryptomator-linux|cryptomator-_latestVersion-x86_64.AppImage.zsync'
fi
