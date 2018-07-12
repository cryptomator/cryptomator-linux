#!/bin/bash
BUILD_VERSION=$1

# build application directory
ant \
  -Dantbuild.logback.configurationFile=logback.xml \
  -Dantbuild.cryptomator.settingsPath=~/.Cryptomator/settings.json \
  -Dantbuild.cryptomator.ipcPortPath=~/.Cryptomator/ipcPort.bin \
  -Dantbuild.cryptomator.keychainPath= \
  -Dantbuild.dropinResourcesRoot= \
  image

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
  --add-modules java.base,java.logging,java.xml,java.sql,java.management,java.security.sasl,java.naming,java.datatransfer,java.security.jgss,java.rmi,java.scripting,java.prefs,java.desktop,javafx.fxml,javafx.controls \
  --verbose

# build AppDir
mkdir -p Cryptomator.AppDir/usr/share/icons/hicolor/512x512/apps/
mkdir -p Cryptomator.AppDir/usr/share/icons/hicolor/scalable/apps/
mkdir -p Cryptomator.AppDir/usr/share/applications/
cp -r antbuild/Cryptomator/* Cryptomator.AppDir/
cp resources/appimage/logback.xml Cryptomator.AppDir/app/
cp resources/appimage/cryptomator.svg Cryptomator.AppDir/usr/share/icons/hicolor/scalable/apps/
cp resources/appimage/cryptomator.png Cryptomator.AppDir/usr/share/icons/hicolor/512x512/apps/
cp resources/appimage/cryptomator.desktop Cryptomator.AppDir/usr/share/applications/
ln -s usr/share/icons/hicolor/scalable/apps/cryptomator.svg Cryptomator.AppDir/cryptomator.svg
ln -s usr/share/applications/cryptomator.desktop Cryptomator.AppDir/cryptomator.desktop
ln -s Cryptomator Cryptomator.AppDir/AppRun

# print resulting AppDir to stdout
echo "Resulting AppDir:"
find Cryptomator.AppDir
echo "--------"

# get and extract appimagetool (extraction needed, as FUSE isn't present on build server)
curl -L https://github.com/AppImage/AppImageKit/releases/download/10/appimagetool-x86_64.AppImage -o appimagetool.AppImage
chmod +x appimagetool.AppImage
./appimagetool.AppImage --appimage-extract

# build AppImage
export ARCH=x86_64
export PATH=./squashfs-root/usr/bin:${PATH}
if [[ ${BUILD_VERSION} == "continuous" ]]; then
  appimagetool Cryptomator.AppDir cryptomator-continuous-x86_64.AppImage -u 'bintray-zsync|cryptomator|cryptomator|cryptomator-linux|cryptomator-continuous-x86_64.AppImage.zsync'
else
  appimagetool Cryptomator.AppDir cryptomator-${BUILD_VERSION}-x86_64.AppImage -u 'bintray-zsync|cryptomator|cryptomator|cryptomator-linux|cryptomator-_latestVersion-x86_64.AppImage.zsync'
fi
