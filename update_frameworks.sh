#!/bin/sh -e

OGG_DIR=$PWD/Ogg.framework
OGG_VERSION=1.3.4

VORBIS_DIR=$PWD/Vorbis.framework
VORBIS_VERSION=1.3.6

IOS_ARCH=arm64
IOS_TARGET=aarch64-apple-ios
IOS_HOST=arm-apple-darwin
IOS_SDK=iphoneos
IOS_SDK_VERSION=`xcrun --sdk ${IOS_SDK} --show-sdk-version`
IOS_SDK_PATH=`xcrun --sdk ${IOS_SDK} --show-sdk-path`

SIMULATOR_ARCH=x86_64
SIMULATOR_TARGET=x86_64-apple-ios
SIMULATOR_HOST=x86_64-apple-darwin
SIMULATOR_SDK=iphonesimulator
SIMULATOR_SDK_VERSION=`xcrun --sdk ${SIMULATOR_SDK} --show-sdk-version`
SIMULATOR_SDK_PATH=`xcrun --sdk ${SIMULATOR_SDK} --show-sdk-path`

CATALYST_ARCH=x86_64
CATALYST_TARGET=x86_64-apple-ios13.0-macabi
CATALYST_HOST=x86_64-apple-darwin
CATALYST_SDK=macosx
CATALYST_SDK_VERSION=`xcrun --sdk ${CATALYST_SDK} --show-sdk-version`
CATALYST_SDK_PATH=`xcrun --sdk ${CATALYST_SDK} --show-sdk-path`

mkdir -p build_frameworks
cd build_frameworks
BUILD_ROOT=$PWD

echo Downloading libogg-${OGG_VERSION}
rm -rf libogg-${OGG_VERSION}
curl -LO http://downloads.xiph.org/releases/ogg/libogg-${OGG_VERSION}.tar.gz
tar xf libogg-${OGG_VERSION}.tar.gz

pushd libogg-${OGG_VERSION}
patch -p0 << EOF
--- include/ogg/os_types.h.orig	2019-09-05 11:30:48.000000000 -0700
+++ include/ogg/os_types.h	2019-09-05 11:30:59.000000000 -0700
@@ -71,6 +71,7 @@
 #elif (defined(__APPLE__) && defined(__MACH__)) /* MacOS X Framework build */
 
 #  include <sys/types.h>
+#  include <stdint.h>
    typedef int16_t ogg_int16_t;
    typedef uint16_t ogg_uint16_t;
    typedef int32_t ogg_int32_t;
EOF
popd

echo Downloading libvorbis-${VORBIS_VERSION}
rm -rf libvorbis-${VORBIS_VERSION}
curl -LO http://downloads.xiph.org/releases/vorbis/libvorbis-${VORBIS_VERSION}.tar.gz
tar xf libvorbis-${VORBIS_VERSION}.tar.gz

pushd libvorbis-${VORBIS_VERSION}
#cp configure configure.orig
#sed 's/-force_cpusubtype_ALL//' < configure.orig > configure
patch -p0 << EOF
--- configure.orig	2019-09-05 11:23:22.000000000 -0700
+++ configure	2019-09-05 11:23:22.000000000 -0700
@@ -12856,9 +12856,9 @@
 		CFLAGS="-O3 -Wall -Wextra -ffast-math -D__NO_MATH_INLINES -fsigned-char $sparc_cpu"
 		PROFILE="-pg -g -O3 -D__NO_MATH_INLINES -fsigned-char $sparc_cpu" ;;
 	*-*-darwin*)
-		DEBUG="-DDARWIN -fno-common -force_cpusubtype_ALL -Wall -g -O0 -fsigned-char"
-		CFLAGS="-DDARWIN -fno-common -force_cpusubtype_ALL -Wall -g -O3 -ffast-math -fsigned-char"
-		PROFILE="-DDARWIN -fno-common -force_cpusubtype_ALL -Wall -g -pg -O3 -ffast-math -fsigned-char";;
+		DEBUG="-DDARWIN -fno-common  -Wall -g -O0 -fsigned-char"
+		CFLAGS="-DDARWIN -fno-common  -Wall -g -O3 -ffast-math -fsigned-char"
+		PROFILE="-DDARWIN -fno-common  -Wall -g -pg -O3 -ffast-math -fsigned-char";;
 	*-*-os2*)
 		# Use -W instead of -Wextra because gcc on OS/2 is an old version.
 		DEBUG="-g -Wall -W -D_REENTRANT -D__NO_MATH_INLINES -fsigned-char"
EOF
popd

###

echo Building libogg for iOS ${SDK_VERSION}
pushd libogg-${OGG_VERSION}
CC=$(xcrun -sdk ${IOS_SDK}${IOS_SDK_VERSION} -find clang) \
CFLAGS="-isysroot ${IOS_SDK_PATH} -arch ${IOS_ARCH} -miphoneos-version-min=7.0 -fembed-bitcode -target ${IOS_TARGET}" \
./configure --host=${IOS_HOST} --disable-shared
make
make DESTDIR=${BUILD_ROOT}/ogg-arm64 install
make distclean
popd

# echo Building libogg for Simulator
# pushd libogg-${OGG_VERSION}
# CC=$(xcrun -sdk ${SIMULATOR_SDK}${SIMULATOR_SDK_VERSION} -find clang) \
# CFLAGS="-isysroot ${SIMULATOR_SDK_PATH} -arch ${SIMULATOR_ARCH} -mios-simulator-version-min=7.0 -fembed-bitcode -target ${SIMULATOR_TARGET}" \
# ./configure --host=${SIMULATOR_HOST} --disable-shared
# make
# make DESTDIR=${BUILD_ROOT}/ogg-x86_64 install
# make distclean
# popd

echo Building libogg for Catalyst
pushd libogg-${OGG_VERSION}
CC=$(xcrun -sdk ${CATALYST_SDK}${CATALYST_SDK_VERSION} -find clang) \
CFLAGS="-isysroot ${CATALYST_SDK_PATH} -arch ${CATALYST_ARCH} -mios-simulator-version-min=7.0 -fembed-bitcode -target ${CATALYST_TARGET}" \
./configure --host=${CATALYST_HOST} --disable-shared
make
make DESTDIR=${BUILD_ROOT}/ogg-x86_64 install
make distclean
popd


echo Building Ogg.framework
OGG_VERSION_DIR=${OGG_DIR}/Versions/${OGG_VERSION}
rm -rf ${OGG_VERSION_DIR}
mkdir -p ${OGG_VERSION_DIR}
cp -a ogg-x86_64/usr/local/include/ogg ${OGG_VERSION_DIR}/Headers
lipo -create -output ${OGG_VERSION_DIR}/Ogg \
	-arch x86_64 ogg-x86_64/usr/local/lib/libogg.a \
	-arch arm64 ogg-arm64/usr/local/lib/libogg.a

ln -sfh ${OGG_VERSION} ${OGG_DIR}/Versions/Current
ln -sfh Versions/Current/Headers ${OGG_DIR}/Headers
ln -sfh Versions/Current/Ogg ${OGG_DIR}/Ogg

###

echo Building libvorbis for iOS ${SDK_VERSION}
pushd libvorbis-${VORBIS_VERSION}
CC=$(xcrun -sdk ${IOS_SDK}${IOS_SDK_VERSION} -find clang) \
CFLAGS="-isysroot ${IOS_SDK_PATH} -arch ${IOS_ARCH} -miphoneos-version-min=7.0 -fembed-bitcode -I${BUILD_ROOT}/ogg-arm64/usr/local/include -target ${IOS_TARGET}" \
OGG_LIBS="-L${BUILD_ROOT}/ogg-arm64/usr/local/lib" \
./configure --host=${IOS_HOST} --disable-shared --disable-oggtest
make
make DESTDIR=${BUILD_ROOT}/vorbis-arm64 install
make distclean
popd

echo Creating libvorbisall.a for iOS
OBJECTS_DIR=${BUILD_ROOT}/vorbis-arm64/usr/local/lib/objects
rm -rf ${OBJECTS_DIR}
mkdir ${OBJECTS_DIR}
pushd ${BUILD_ROOT}/vorbis-arm64/usr/local/lib/objects
for lib in ../*.a; do ar -x $lib; done
ar -rs ../libvorbisall.a *.o
popd

# echo Building libvorbis for Simulator
# pushd libvorbis-${VORBIS_VERSION}
# CC=$(xcrun -sdk ${SIMULATOR_SDK}${SIMULATOR_SDK_VERSION} -find clang) \
# CFLAGS="-isysroot ${SIMULATOR_SDK_PATH} -arch ${SIMULATOR_ARCH} -mios-simulator-version-min=7.0 -fembed-bitcode -I${BUILD_ROOT}/ogg-x86_64/usr/local/include -target ${SIMULATOR_TARGET}" \
# OGG_LIBS="-L${BUILD_ROOT}/ogg-x86_64/usr/local/lib" \
# ./configure --host=${SIMULATOR_HOST} --disable-shared --disable-oggtest
# make
# make DESTDIR=${BUILD_ROOT}/vorbis-x86_64 install
# make distclean
# popd

# echo Creating libvorbisall.a for Simulator
# OBJECTS_DIR=${BUILD_ROOT}/vorbis-x86_64/usr/local/lib/objects
# rm -rf ${OBJECTS_DIR}
# mkdir ${OBJECTS_DIR}
# pushd ${BUILD_ROOT}/vorbis-x86_64/usr/local/lib/objects
# for lib in ../*.a; do ar -x $lib; done
# ar -rs ../libvorbisall.a *.o
# popd

echo Building libvorbis for Catalyst
pushd libvorbis-${VORBIS_VERSION}
CC=$(xcrun -sdk ${CATALYST_SDK}${CATALYST_SDK_VERSION} -find clang) \
CFLAGS="-isysroot ${CATALYST_SDK_PATH} -arch ${CATALYST_ARCH} -mios-simulator-version-min=7.0 -fembed-bitcode -I${BUILD_ROOT}/ogg-x86_64/usr/local/include -target ${CATALYST_TARGET}" \
OGG_LIBS="-L${BUILD_ROOT}/ogg-x86_64/usr/local/lib" \
./configure --host=${CATALYST_HOST} --disable-shared --disable-oggtest
make
make DESTDIR=${BUILD_ROOT}/vorbis-x86_64 install
make distclean
popd

echo Creating libvorbisall.a for Catalyst
OBJECTS_DIR=${BUILD_ROOT}/vorbis-x86_64/usr/local/lib/objects
rm -rf ${OBJECTS_DIR}
mkdir ${OBJECTS_DIR}
pushd ${BUILD_ROOT}/vorbis-x86_64/usr/local/lib/objects
for lib in ../*.a; do ar -x $lib; done
ar -rs ../libvorbisall.a *.o
popd

echo Building Vorbis.framework
VORBIS_VERSION_DIR=${VORBIS_DIR}/Versions/${VORBIS_VERSION}
rm -rf ${VORBIS_VERSION_DIR}
mkdir -p ${VORBIS_VERSION_DIR}
cp -a vorbis-x86_64/usr/local/include/vorbis ${VORBIS_VERSION_DIR}/Headers
lipo -create -output ${VORBIS_VERSION_DIR}/Vorbis \
	-arch x86_64 vorbis-x86_64/usr/local/lib/libvorbisall.a \
	-arch arm64 vorbis-arm64/usr/local/lib/libvorbisall.a

ln -sfh ${VORBIS_VERSION} ${VORBIS_DIR}/Versions/Current
ln -sfh Versions/Current/Headers ${VORBIS_DIR}/Headers
ln -sfh Versions/Current/Vorbis ${VORBIS_DIR}/Vorbis
