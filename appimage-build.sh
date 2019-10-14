#!/bin/bash
BUILD_VERSION=${1:-SNAPSHOT}

# check preconditions
if [ ! -d ./Cryptomator ]; then echo "./Cryptomator does not exist."; exit 1; fi
if [ ! -x $(readlink -e ./tools/appimagekit/squashfs-root/AppRun) ]; then echo "./tools/appimagekit/squashfs-root/AppRun not executable."; exit 1; fi

# prepare AppDir
mv Cryptomator Cryptomator.AppDir
mkdir -p Cryptomator.AppDir/usr/share/icons/hicolor/512x512/apps/
mkdir -p Cryptomator.AppDir/usr/share/icons/hicolor/scalable/apps/
mkdir -p Cryptomator.AppDir/usr/share/applications/
mkdir -p Cryptomator.AppDir/usr/share/metainfo/
cp resources/appimage/cryptomator.svg Cryptomator.AppDir/usr/share/icons/hicolor/scalable/apps/
cp resources/appimage/cryptomator.png Cryptomator.AppDir/usr/share/icons/hicolor/512x512/apps/
cp resources/appimage/org.cryptomator.cryptomator.desktop Cryptomator.AppDir/usr/share/applications/
cp resources/appimage/cryptomator.appdata.xml Cryptomator.AppDir/usr/share/metainfo/
ln -s usr/share/icons/hicolor/scalable/apps/cryptomator.svg Cryptomator.AppDir/cryptomator.svg
ln -s usr/share/icons/hicolor/scalable/apps/cryptomator.svg Cryptomator.AppDir/.DirIcon
ln -s usr/share/applications/cryptomator.desktop Cryptomator.AppDir/org.cryptomator.cryptomator.desktop
ln -s Cryptomator Cryptomator.AppDir/AppRun

# build AppImage
export ARCH=x86_64
if [[ ${BUILD_VERSION} == "SNAPSHOT" ]]; then
  ./tools/appimagekit/squashfs-root/AppRun Cryptomator.AppDir cryptomator-SNAPSHOT-x86_64.AppImage -u 'bintray-zsync|cryptomator|cryptomator|cryptomator-linux|cryptomator-SNAPSHOT-x86_64.AppImage.zsync'
else
  ./tools/appimagekit/squashfs-root/AppRun Cryptomator.AppDir cryptomator-${BUILD_VERSION}-x86_64.AppImage -u 'bintray-zsync|cryptomator|cryptomator|cryptomator-linux|cryptomator-_latestVersion-x86_64.AppImage.zsync'
fi
