#!/bin/sh -e

OGG_OUTPUT=$PWD/Ogg.xcframework
OGG_VERSION=1.3.4

VORBIS_OUTPUT=$PWD/Vorbis.xcframework
VORBIS_VERSION=1.3.7

SIMULATOR_SDK=iphonesimulator
CATALYST_SDK=macosx

IOS_ARCH=arm64
IOS_TARGET=aarch64-apple-ios
IOS_HOST=arm-apple-darwin
IOS_SDK=iphoneos
IOS_CFLAGS="-miphoneos-version-min=7.0"

X86_SIMULATOR_ARCH=x86_64
X86_SIMULATOR_TARGET=x86_64-apple-ios-simulator
X86_SIMULATOR_HOST=x86_64-apple-darwin
X86_SIMULATOR_SDK=${SIMULATOR_SDK}
X86_SIMULATOR_CFLAGS="-mios-simulator-version-min=7.0"

ARM_SIMULATOR_ARCH=arm64
ARM_SIMULATOR_TARGET=aarch64-apple-ios-simulator
ARM_SIMULATOR_HOST=arm-apple-darwin
ARM_SIMULATOR_SDK=${SIMULATOR_SDK}
ARM_SIMULATOR_CFLAGS="-mios-simulator-version-min=7.0"

X86_CATALYST_ARCH=x86_64
X86_CATALYST_TARGET=x86_64-apple-ios13.0-macabi
X86_CATALYST_HOST=x86_64-apple-darwin
X86_CATALYST_SDK=${CATALYST_SDK}
X86_CATALYST_CFLAGS="-miphoneos-version-min=13.0"

ARM_CATALYST_ARCH=arm64
ARM_CATALYST_TARGET=arm64-apple-ios14.0-macabi
ARM_CATALYST_HOST=arm-apple-darwin
ARM_CATALYST_SDK=${CATALYST_SDK}
ARM_CATALYST_CFLAGS="-miphoneos-version-min=13.0"

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

	message Creating libvorbisall.a for ${BUILD_FOR}
	OBJECTS_DIR=${BUILD_ROOT}/${BUILD_PATH}/usr/local/lib/objects
	rm -rf ${OBJECTS_DIR}
	mkdir ${OBJECTS_DIR}
	pushd ${BUILD_ROOT}/${BUILD_PATH}/usr/local/lib/objects
	for lib in ../libvorbis*.a; do ar -x $lib; done
	ar -rs ../libvorbisall.a *.o
	popd
}

build_framework()
{
	BUILD_FRAMEWORK=$1
	BUILD_VERSION=$2
	BUILD_SDK=$3
	BUILD_HEADERS_DIR=$4
	BUILD_ARCHIVE_NAME=$5
	shift 5

	BUILD_HEADERS_ARCH=$1
	BUILD_LIPO_ARGS=""
	while (( $# )); do
		BUILD_ARCH=$1
		shift 1

		BUILD_LIPO_ARGS+=" -arch ${BUILD_ARCH} out-${BUILD_SDK}-${BUILD_ARCH}/usr/local/lib/${BUILD_ARCHIVE_NAME}"
	done

	BUILD_PATH=out-${BUILD_SDK}
	BUILD_FRAMEWORK_DIR=${BUILD_PATH}/${BUILD_FRAMEWORK}.framework
	BUILD_VERSION_DIR=${BUILD_FRAMEWORK_DIR}/Versions/${BUILD_VERSION}

	message Creating ${BUILD_FRAMEWORK}.framework for ${BUILD_SDK}
	rm -rf ${BUILD_FRAMEWORK_DIR}
	mkdir -p ${BUILD_VERSION_DIR}
	cp -a out-${BUILD_SDK}-${BUILD_HEADERS_ARCH}/usr/local/include/${BUILD_HEADERS_DIR} ${BUILD_VERSION_DIR}/Headers
	lipo -create -output ${BUILD_VERSION_DIR}/${BUILD_FRAMEWORK} ${BUILD_LIPO_ARGS}

	ln -sfh ${BUILD_VERSION} ${BUILD_FRAMEWORK_DIR}/Versions/Current
	ln -sfh Versions/Current/Headers ${BUILD_FRAMEWORK_DIR}/Headers
	ln -sfh Versions/Current/${BUILD_FRAMEWORK} ${BUILD_FRAMEWORK_DIR}/${BUILD_FRAMEWORK}
}

build_xcframework()
{
	BUILD_FRAMEWORK=$1
	shift 1

	BUILD_OUTPUT=${BUILD_FRAMEWORK}.xcframework

	BUILD_FRAMEWORK_ARGS=""
	while (( $# )); do
		BUILD_SDK=$1
		shift 1

		BUILD_FRAMEWORK_ARGS+=" -framework out-${BUILD_SDK}/${BUILD_FRAMEWORK}.framework"
	done

	message Creating ${BUILD_FRAMEWORK}.xcframework

	rm -rf ${BUILD_OUTPUT}
	xcodebuild -create-xcframework ${BUILD_FRAMEWORK_ARGS} -output ${BUILD_OUTPUT}
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
build_libogg "Simulator (x86-64)" ${X86_SIMULATOR_ARCH} ${X86_SIMULATOR_TARGET} ${X86_SIMULATOR_HOST} ${X86_SIMULATOR_SDK} "${X86_SIMULATOR_CFLAGS}"
build_libogg "Simulator (arm64)" ${ARM_SIMULATOR_ARCH} ${ARM_SIMULATOR_TARGET} ${ARM_SIMULATOR_HOST} ${ARM_SIMULATOR_SDK} "${ARM_SIMULATOR_CFLAGS}"
build_libogg "Catalyst (x86-64)" ${X86_CATALYST_ARCH} ${X86_CATALYST_TARGET} ${X86_CATALYST_HOST} ${X86_CATALYST_SDK} "${X86_CATALYST_CFLAGS}"
build_libogg "Catalyst (arm64)" ${ARM_CATALYST_ARCH} ${ARM_CATALYST_TARGET} ${ARM_CATALYST_HOST} ${ARM_CATALYST_SDK} "${ARM_CATALYST_CFLAGS}"

build_framework Ogg ${OGG_VERSION} ${IOS_SDK} ogg libogg.a ${IOS_ARCH}
build_framework Ogg ${OGG_VERSION} ${SIMULATOR_SDK} ogg libogg.a ${X86_SIMULATOR_ARCH} ${ARM_SIMULATOR_ARCH}
build_framework Ogg ${OGG_VERSION} ${CATALYST_SDK} ogg libogg.a ${X86_CATALYST_ARCH} ${ARM_CATALYST_ARCH}

build_xcframework Ogg ${IOS_SDK} ${SIMULATOR_SDK} ${CATALYST_SDK}

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
build_libvorbis "Simulator (x86-64)" ${X86_SIMULATOR_ARCH} ${X86_SIMULATOR_TARGET} ${X86_SIMULATOR_HOST} ${X86_SIMULATOR_SDK} "${X86_SIMULATOR_CFLAGS}"
build_libvorbis "Simulator (arm64)" ${ARM_SIMULATOR_ARCH} ${ARM_SIMULATOR_TARGET} ${ARM_SIMULATOR_HOST} ${ARM_SIMULATOR_SDK} "${ARM_SIMULATOR_CFLAGS}"
build_libvorbis "Catalyst (x86-64)" ${X86_CATALYST_ARCH} ${X86_CATALYST_TARGET} ${X86_CATALYST_HOST} ${X86_CATALYST_SDK} "${X86_CATALYST_CFLAGS}"
build_libvorbis "Catalyst (arm64)" ${ARM_CATALYST_ARCH} ${ARM_CATALYST_TARGET} ${ARM_CATALYST_HOST} ${ARM_CATALYST_SDK} "${ARM_CATALYST_CFLAGS}"

build_framework Vorbis ${VORBIS_VERSION} ${IOS_SDK} vorbis libvorbisall.a ${IOS_ARCH}
build_framework Vorbis ${VORBIS_VERSION} ${SIMULATOR_SDK} vorbis libvorbisall.a ${X86_SIMULATOR_ARCH} ${ARM_SIMULATOR_ARCH}
build_framework Vorbis ${VORBIS_VERSION} ${CATALYST_SDK} vorbis libvorbisall.a ${X86_CATALYST_ARCH} ${ARM_CATALYST_ARCH}

build_xcframework Vorbis ${IOS_SDK} ${SIMULATOR_SDK} ${CATALYST_SDK}

rm -rf ${OGG_OUTPUT} ${VORBIS_OUTPUT}
mv Ogg.xcframework ${OGG_OUTPUT}
mv Vorbis.xcframework ${VORBIS_OUTPUT}
