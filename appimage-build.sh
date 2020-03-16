#!/bin/bash
BUILD_VERSION=${1:-SNAPSHOT}

# check preconditions
if [ ! -d ./Cryptomator ]; then echo "./Cryptomator does not exist."; exit 1; fi
if [ ! -x $(readlink -e ./tools/appimagekit/squashfs-root/AppRun) ]; then echo "./tools/appimagekit/squashfs-root/AppRun not executable."; exit 1; fi

# render appdata.xml
./render-appdata-template.sh resources/appdata.template.xml $BUILD_VERSION > resources/appimage/org.cryptomator.Cryptomator.appdata.xml

# prepare AppDir
mv Cryptomator Cryptomator.AppDir
cp -r resources/appimage/AppDir/* Cryptomator.AppDir/
ln -s usr/share/icons/hicolor/scalable/apps/org.cryptomator.Cryptomator.svg Cryptomator.AppDir/org.cryptomator.Cryptomator.svg
ln -s usr/share/icons/hicolor/scalable/apps/org.cryptomator.Cryptomator.svg Cryptomator.AppDir/Cryptomator.svg
ln -s usr/share/icons/hicolor/scalable/apps/org.cryptomator.Cryptomator.svg Cryptomator.AppDir/.DirIcon
ln -s usr/share/applications/org.cryptomator.Cryptomator.desktop Cryptomator.AppDir/Cryptomator.desktop
ln -s Cryptomator Cryptomator.AppDir/AppRun

tree Cryptomator.AppDir

# build AppImage
export ARCH=x86_64
if [[ ${BUILD_VERSION} == "SNAPSHOT" ]]; then
  ./tools/appimagekit/squashfs-root/AppRun Cryptomator.AppDir cryptomator-SNAPSHOT-x86_64.AppImage -u 'bintray-zsync|cryptomator|cryptomator|cryptomator-linux|cryptomator-SNAPSHOT-x86_64.AppImage.zsync'
else
  ./tools/appimagekit/squashfs-root/AppRun Cryptomator.AppDir cryptomator-${BUILD_VERSION}-x86_64.AppImage -u 'bintray-zsync|cryptomator|cryptomator|cryptomator-linux|cryptomator-_latestVersion-x86_64.AppImage.zsync'
fi
