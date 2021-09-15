#
# Toolchain description file for for Yocto SDK
#

set(TOOLCHAIN         "/opt/yocto-sdk/sigma/sysroots/x86_64-pokysdk-linux/usr/bin/arm-poky-linux-gnueabi/arm-poky-linux-gnueabi")
set(TOOLCHAIN_SYSROOT "/opt/yocto-sdk/sigma/sysroots/cortexa7t2hf-neon-poky-linux-gnueabi")
set(TOOLCHAIN_FLAGS   "-marm -mlittle-endian -mtune=cortex-a7 -mcpu=cortex-a7 -mfpu=neon-vfpv4 -mfloat-abi=hard -mtp=auto -mabi=aapcs-linux -mvectorize-with-neon-quad -Wno-psabi")

set(CMAKE_SYSTEM_NAME      Linux                 CACHE STRING "" FORCE)
set(CMAKE_SYSTEM_PROCESSOR arm                   CACHE STRING "" FORCE)

set(CMAKE_AR           ${TOOLCHAIN}-ar           CACHE STRING "" FORCE)
set(CMAKE_C_COMPILER   ${TOOLCHAIN}-gcc          CACHE STRING "" FORCE)
set(CMAKE_CXX_COMPILER ${TOOLCHAIN}-g++          CACHE STRING "" FORCE)
set(CMAKE_LINKER       ${TOOLCHAIN}-ld           CACHE STRING "" FORCE)
set(CMAKE_NM           ${TOOLCHAIN}-nm           CACHE STRING "" FORCE)
set(CMAKE_OBJCOPY      ${TOOLCHAIN}-objcopy      CACHE STRING "" FORCE)
set(CMAKE_OBJDUMP      ${TOOLCHAIN}-objdump      CACHE STRING "" FORCE)
set(CMAKE_RANLIB       ${TOOLCHAIN}-ranlib       CACHE STRING "" FORCE)
set(CMAKE_STRIP        ${TOOLCHAIN}-strip        CACHE STRING "" FORCE)
set(CMAKE_SYSROOT      ${TOOLCHAIN_SYSROOT}      CACHE STRING "" FORCE)

set(CMAKE_C_FLAGS      ${TOOLCHAIN_FLAGS}        CACHE STRING "" FORCE)
set(CMAKE_CXX_FLAGS    ${TOOLCHAIN_FLAGS}        CACHE STRING "" FORCE)

set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM BOTH)
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_PACKAGE ONLY)

set(ENV{PKG_CONFIG_PATH} ${CMAKE_SYSROOT}/usr/lib/pkgconfig)
