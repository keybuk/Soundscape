#!/bin/sh -e

OGG_OUTPUT=$PWD/Ogg.xcframework
OGG_VERSION=1.3.4

VORBIS_OUTPUT=$PWD/Vorbis.xcframework
VORBIS_VERSION=1.3.6

IOS_ARCH=arm64
IOS_TARGET=aarch64-apple-ios
IOS_HOST=arm-apple-darwin
IOS_SDK=iphoneos
IOS_SDK_VERSION=`xcrun --sdk ${IOS_SDK} --show-sdk-version`
IOS_SDK_PATH=`xcrun --sdk ${IOS_SDK} --show-sdk-path`
IOS_CFLAGS="-miphoneos-version-min=7.0"

SIMULATOR_ARCH=x86_64
SIMULATOR_TARGET=x86_64-apple-ios
SIMULATOR_HOST=x86_64-apple-darwin
SIMULATOR_SDK=iphonesimulator
SIMULATOR_SDK_VERSION=`xcrun --sdk ${SIMULATOR_SDK} --show-sdk-version`
SIMULATOR_SDK_PATH=`xcrun --sdk ${SIMULATOR_SDK} --show-sdk-path`
SIMULATOR_CFLAGS="-mios-simulator-version-min=7.0"

CATALYST_ARCH=x86_64
CATALYST_TARGET=x86_64-apple-ios13.0-macabi
CATALYST_HOST=x86_64-apple-darwin
CATALYST_SDK=macosx
CATALYST_SDK_VERSION=`xcrun --sdk ${CATALYST_SDK} --show-sdk-version`
CATALYST_SDK_PATH=`xcrun --sdk ${CATALYST_SDK} --show-sdk-path`
CATALYST_CFLAGS="-miphoneos-version-min=13.0"

message()
{
	printf "\e[1m$*\e[0m\n"
}

build_libogg()
{
	BUILD_FOR=$1
	BUILD_ARCH=$2
	BUILD_TARGET=$3
	BUILD_HOST=$4
	BUILD_SDK=$5
	BUILD_CFLAGS=$6

	BUILD_PATH=out-${BUILD_SDK}-${BUILD_ARCH}
	BUILD_SDK_VERSION=`xcrun --sdk ${BUILD_SDK} --show-sdk-version`
	BUILD_SDK_PATH=`xcrun --sdk ${BUILD_SDK} --show-sdk-path`

	message Building libogg for ${BUILD_FOR} ${BUILD_SDK_VERSION}
	pushd libogg-${OGG_VERSION}
	CC=$(xcrun -sdk ${BUILD_SDK}${BUILD_SDK_VERSION} -find clang || xcrun -sdk ${BUILD_SDK} -find clang) \
	CFLAGS="-isysroot ${BUILD_SDK_PATH} -arch ${BUILD_ARCH} ${BUILD_CFLAGS} -fembed-bitcode -target ${BUILD_TARGET}" \
	./configure --host=${BUILD_HOST} --disable-shared
	make
	make DESTDIR=${BUILD_ROOT}/${BUILD_PATH} install
	make distclean
	popd

	message Building Ogg.framework for ${BUILD_FOR}
	OGG_DIR=${BUILD_PATH}/Ogg.framework
	OGG_VERSION_DIR=${OGG_DIR}/Versions/${OGG_VERSION}
	mkdir -p ${OGG_VERSION_DIR}
	cp -a ${BUILD_PATH}/usr/local/include/ogg ${OGG_VERSION_DIR}/Headers
	#lipo -create -output ${OGG_VERSION_DIR}/Ogg \
	#	-arch ${BUILD_ARCH} ${BUILD_PATH}/usr/local/lib/libogg.a
	cp ${BUILD_PATH}/usr/local/lib/libogg.a ${OGG_VERSION_DIR}/Ogg

	ln -sfh ${OGG_VERSION} ${OGG_DIR}/Versions/Current
	ln -sfh Versions/Current/Headers ${OGG_DIR}/Headers
	ln -sfh Versions/Current/Ogg ${OGG_DIR}/Ogg
}

build_libvorbis()
{
	BUILD_FOR=$1
	BUILD_ARCH=$2
	BUILD_TARGET=$3
	BUILD_HOST=$4
	BUILD_SDK=$5
	BUILD_CFLAGS=$6

	BUILD_PATH=out-${BUILD_SDK}-${BUILD_ARCH}
	BUILD_SDK_VERSION=`xcrun --sdk ${BUILD_SDK} --show-sdk-version`
	BUILD_SDK_PATH=`xcrun --sdk ${BUILD_SDK} --show-sdk-path`

	message Building libvorbis for ${BUILD_FOR} ${BUILD_SDK_VERSION}
	pushd libvorbis-${VORBIS_VERSION}
	CC=$(xcrun -sdk ${BUILD_SDK}${BUILD_SDK_VERSION} -find clang) \
	CFLAGS="-isysroot ${BUILD_SDK_PATH} -arch ${BUILD_ARCH} ${BUILD_CFLAGS} -fembed-bitcode -I${BUILD_ROOT}/${BUILD_PATH}/usr/local/include -target ${BUILD_TARGET}" \
	OGG_LIBS="-L${BUILD_ROOT}/${BUILD_PATH}/usr/local/lib" \
	./configure --host=${BUILD_HOST} --disable-shared --disable-oggtest
	make
	make DESTDIR=${BUILD_ROOT}/${BUILD_PATH} install
	make distclean
	popd

	message Creating libvorbisall.a for iOS
	OBJECTS_DIR=${BUILD_ROOT}/${BUILD_PATH}/usr/local/lib/objects
	rm -rf ${OBJECTS_DIR}
	mkdir ${OBJECTS_DIR}
	pushd ${BUILD_ROOT}/${BUILD_PATH}/usr/local/lib/objects
	for lib in ../libvorbis*.a; do ar -x $lib; done
	ar -rs ../libvorbisall.a *.o
	popd

	message Building Vorbis.framework for ${BUILD_FOR}
	VORBIS_DIR=${BUILD_PATH}/Vorbis.framework
	VORBIS_VERSION_DIR=${VORBIS_DIR}/Versions/${VORBIS_VERSION}
	mkdir -p ${VORBIS_VERSION_DIR}
	cp -a ${BUILD_PATH}/usr/local/include/vorbis ${VORBIS_VERSION_DIR}/Headers
	#lipo -create -output ${VORBIS_VERSION_DIR}/Vorbis \
	#	-arch ${BUILD_ARCH} ${BUILD_PATH}/usr/local/lib/libvorbisall.a
	cp ${BUILD_PATH}/usr/local/lib/libvorbisall.a ${VORBIS_VERSION_DIR}/Vorbis

	ln -sfh ${VORBIS_VERSION} ${VORBIS_DIR}/Versions/Current
	ln -sfh Versions/Current/Headers ${VORBIS_DIR}/Headers
	ln -sfh Versions/Current/Vorbis ${VORBIS_DIR}/Vorbis
}


mkdir -p build_frameworks
cd build_frameworks
BUILD_ROOT=$PWD

message Downloading libogg-${OGG_VERSION}
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

build_libogg iOS ${IOS_ARCH} ${IOS_TARGET} ${IOS_HOST} ${IOS_SDK} "${IOS_CFLAGS}"
build_libogg Simulator ${SIMULATOR_ARCH} ${SIMULATOR_TARGET} ${SIMULATOR_HOST} ${SIMULATOR_SDK} "${SIMULATOR_CFLAGS}"
build_libogg Catalyst ${CATALYST_ARCH} ${CATALYST_TARGET} ${CATALYST_HOST} ${CATALYST_SDK} "${CATALYST_CFLAGS}"

message Building Ogg.xcframework
xcodebuild -create-xcframework \
	-framework out-${IOS_SDK}-${IOS_ARCH}/Ogg.framework \
	-framework out-${SIMULATOR_SDK}-${SIMULATOR_ARCH}/Ogg.framework \
	-framework out-${CATALYST_SDK}-${CATALYST_ARCH}/Ogg.framework \
	-output ${OGG_OUTPUT}

message Downloading libvorbis-${VORBIS_VERSION}
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

build_libvorbis iOS ${IOS_ARCH} ${IOS_TARGET} ${IOS_HOST} ${IOS_SDK} "${IOS_CFLAGS}"
build_libvorbis Simulator ${SIMULATOR_ARCH} ${SIMULATOR_TARGET} ${SIMULATOR_HOST} ${SIMULATOR_SDK} "${SIMULATOR_CFLAGS}"
build_libvorbis Catalyst ${CATALYST_ARCH} ${CATALYST_TARGET} ${CATALYST_HOST} ${CATALYST_SDK} "${CATALYST_CFLAGS}"

message Building Vorbis.xcframework
xcodebuild -create-xcframework \
	-framework out-${IOS_SDK}-${IOS_ARCH}/Vorbis.framework \
	-framework out-${SIMULATOR_SDK}-${SIMULATOR_ARCH}/Vorbis.framework \
	-framework out-${CATALYST_SDK}-${CATALYST_ARCH}/Vorbis.framework \
	-output ${VORBIS_OUTPUT}
