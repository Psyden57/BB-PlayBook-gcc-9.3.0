#!/bin/sh

export GCC_VER="9.3.0"

# Get the absolute path of the directory containing this script
BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Define where the output toolchain should be installed
export APP_ROOT="${BASE_DIR}/out/playbook-gcc9"

# The path to your extracted BlackBerry NDK sysroot.
# You MUST set this environment variable before building, or edit this path directly.
export BBNDK_ROOT="${BBNDK_ROOT:-/opt/bbndk-2.1.0}"
export BBNDK_TARGET="${BBNDK_ROOT}/target/qnx6"
export BBNDK_HOST="${BBNDK_ROOT}/host/linux/x86"
export BBNDK_ABI="arm-unknown-nto-qnx6.5.0eabi"

BBNDK_HOST_OS="linux"

HOST_OS=`uname -s | tr '[:upper:]' '[:lower:]'`
HOST_ARCH=`uname -m`
export HOST_SYSTEM="${HOST_ARCH}-${HOST_OS}"
export HOST_CPU_COUNT="4"

HOST_LIBNAME=
case ${HOST_ARCH} in
x86)
	HOST_LIBNAME="lib"
	;;
x86_64)
	HOST_LIBNAME="lib" # Haiku is single-arch, no need for lib64
	;;
esac
export ${HOST_LIBNAME}
# try to keep things similar to BlackBerry's config ${ABSE}/target/qnx6
export QNX_VERSION="qnx650" # matches builtin gcc/config/nto.h
export QNX_TARGET="${APP_ROOT}/${QNX_VERSION}"
export QNX_HOST="${QNX_TARGET}/${HOST_SYSTEM}"
export QNX_INC="${QNX_TARGET}/include"
export QNX_ARCH="armle-v7"
export QNX_ABI="arm-blackberry-qnx8eabi"

export QNX_BIN="${QNX_TARGET}/bin"
export QNX_PREBUILT="${QNX_TARGET}/${QNX_ABI}"
export QNX_PREBUILT_BIN="${QNX_HOST}/${QNX_ABI}/bin"
export QNX_PREBUILT_LIBEXEC="${QNX_HOST}/${QNX_ABI}/${HOST_LIBNAME}"
export QNX_PREBUILT_GCCLIB="${QNX_PREBUILT_LIBEXEC}/gcc/${QNX_ABI}/${GCC_VER}"

#-------------------------------------------------------------------------------

export PATH="${QNX_TARGET}/bin:${QNX_CONFIGURATION}/bin:${PATH}"
export PATH="${QNX_TARGET}/features/${LATEST_LINUX_JRE}/jre/bin:${PATH}"
export PATH="${QNX_HOST}/usr/python32/bin:${QNX_BIN}:${QNX_PREBUILT_BIN}:${PATH}"

# ?? from BB's env - unused
unset PYTHONPATH


