#!/bin/bash

# Build script for the Cryptomator appimage

VERSION=$1
BUILD_NUMBER=$2

# Create build dir
rm --force --recursive ./build
mkdir build
cd build

# Download buildkit
curl -L https://github.com/cryptomator/cryptomator/releases/download/${VERSION}/buildkit-linux.zip -o buildkit.zip

# Unzip buildkit
unzip buildkit.zip

# Store upstream version in variable
UPSTREAM_VERSION=`cat ./libs/version.txt`

# Create runtime image
${JAVA_HOME}/bin/jlink \
    --verbose \
    --output runtimeImage \
    --module-path "${JAVA_HOME/}/jmods" \
    --add-modules java.base,java.logging,java.xml,java.sql,java.management,java.security.sasl,java.naming,java.datatransfer,java.security.jgss,java.rmi,java.scripting,java.prefs,java.desktop,jdk.security.auth,jdk.unsupported,java.net.http,jdk.crypto.ec \
    --no-header-files \
    --no-man-pages \
    --strip-debug \
    --compress=1

#prepare workaround for [ISSUE]

${JAVA_HOME}/bin/jar xf ./libs/jffi-1.2.23-native.jar /jni/x86_64-Linux/
mv ./jni/x86_64-Linux/* ./libs/libjffi.so

# Build Cryptomator.AppDir
mkdir Cryptomator.AppDir
mv LICENSE.txt Cryptomator.AppDir/LICENSE.txt
mv runtimeImage Cryptomator.AppDir/runtimeImage
mv libs Cryptomator.AppDir/libs
cp -r ../resources/appimage/AppDir/* Cryptomator.AppDir/
ln -s usr/share/icons/hicolor/scalable/apps/org.cryptomator.Cryptomator.svg Cryptomator.AppDir/org.cryptomator.Cryptomator.svg
ln -s usr/share/icons/hicolor/scalable/apps/org.cryptomator.Cryptomator.svg Cryptomator.AppDir/Cryptomator.svg
ln -s usr/share/icons/hicolor/scalable/apps/org.cryptomator.Cryptomator.svg Cryptomator.AppDir/.DirIcon
ln -s usr/share/applications/org.cryptomator.Cryptomator.desktop Cryptomator.AppDir/Cryptomator.desktop
ln -s bin/cryptomator.sh Cryptomator.AppDir/AppRun
echo "$BUILD_NUMBER" > Cryptomator.AppDir/build.number

# Download appImageKit
curl -L https://github.com/AppImage/AppImageKit/releases/download/12/appimagetool-x86_64.AppImage -o appimagetool.AppImage
chmod +x appimagetool.AppImage
./appimagetool.AppImage --appimage-extract

# Build AppImage
./squashfs-root/AppRun Cryptomator.AppDir cryptomator-${VERSION}-x86_64.AppImage -u 'bintray-zsync|cryptomator|cryptomator|cryptomator-linux|cryptomator-${VERSION}-x86_64.AppImage.zsync'