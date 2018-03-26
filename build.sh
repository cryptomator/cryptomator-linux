#!/bin/bash

# build application directory
ant image

# replace jvm
rm -rf antbuild/Cryptomator/runtime
${JAVA_HOME}/bin/jlink \
  --module-path ${JAVA_HOME}/jmods \
  --compress 1 \
  --no-header-files \
  --strip-debug \
  --no-man-pages \
  --strip-native-commands \
  --output antbuild/Cryptomator/runtime \
  --add-modules java.base,java.logging,java.xml,java.sql,java.management,java.security.sasl,java.naming,java.datatransfer,java.security.jgss,java.rmi,java.scripting,java.prefs,java.desktop,jdk.incubator.httpclient,javafx.fxml,javafx.controls,jdk.incubator.httpclient \
  --verbose

# build AppDir
mkdir -p Cryptomator.AppDir/usr/bin/
mkdir -p Cryptomator.AppDir/opt/
cp resources/appimage/cryptomator.png Cryptomator.AppDir
cp resources/appimage/cryptomator.desktop Cryptomator.AppDir
cp resources/appimage/cryptomator.sh Cryptomator.AppDir/usr/bin/
cp -r antbuild/Cryptomator Cryptomator.AppDir/opt
curl -L https://github.com/AppImage/AppImageKit/releases/download/10/AppRun-x86_64 -o Cryptomator.AppDir/AppRun
chmod +x Cryptomator.AppDir/AppRun
chmod +x Cryptomator.AppDir/usr/bin/cryptomator.sh

# build AppImage
export ARCH=x86_64
curl -L https://github.com/AppImage/AppImageKit/releases/download/10/appimagetool-x86_64.AppImage -o appimagetool.AppImage
chmod +x appimagetool.AppImage
./appimagetool.AppImage --appimage-extract
export PATH=./squashfs-root/usr/bin:${PATH}
appimagetool Cryptomator.AppDir Cryptomator.AppImage
