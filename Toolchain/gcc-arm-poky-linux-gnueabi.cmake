#
# Toolchain description file for for Yocto SDK
#

if (DEFINED CMAKEPKG_TOOLCHAIN_PATH)
  set(TOOLCHAIN_PATH "${CMAKEPKG_TOOLCHAIN_PATH}/x86_64-pokysdk-linux/usr/bin/arm-poky-linux-gnueabi/arm-poky-linux-gnueabi")
  set(SYSROOT_PATH   "${CMAKEPKG_TOOLCHAIN_PATH}/cortexa7t2hf-neon-poky-linux-gnueabi")
else()
  set(TOOLCHAIN_PATH "/opt/yocto-sdk/sigma/sysroots/x86_64-pokysdk-linux/usr/bin/arm-poky-linux-gnueabi/arm-poky-linux-gnueabi")
  set(SYSROOT_PATH   "/opt/yocto-sdk/sigma/sysroots/cortexa7t2hf-neon-poky-linux-gnueabi")
endif()

# Global toolchain flags specific to this platform
set(TOOLCHAIN_FLAGS   "-marm -mlittle-endian -mtune=cortex-a7 -mcpu=cortex-a7 -mfpu=neon-vfpv4 -mfloat-abi=hard -mtp=auto -mabi=aapcs-linux -mvectorize-with-neon-quad -Wno-psabi")

# Platform description
set(CMAKE_SYSTEM_NAME         "Linux"                         CACHE STRING "" FORCE)
set(CMAKE_SYSTEM_PROCESSOR    "arm"                           CACHE STRING "" FORCE)
set(CMAKE_SYSTEM_TOOLCHAIN    "GCC"                           CACHE STRING "" FORCE)

# Available tools in the toolchain
set(CMAKE_ADDR2LINE           ${TOOLCHAIN_PATH}-addr2line     CACHE STRING "" FORCE)
set(CMAKE_AR                  ${TOOLCHAIN_PATH}-ar            CACHE STRING "" FORCE)
#set(CMAKE_ASM_COMPILER        ${TOOLCHAIN_PATH}-as            CACHE STRING "" FORCE) # wont work with --sysroot option
set(CMAKE_CXX_FILT            ${TOOLCHAIN_PATH}-c++filt       CACHE STRING "" FORCE)
set(CMAKE_DWP                 ${TOOLCHAIN_PATH}-dwp           CACHE STRING "" FORCE)
set(CMAKE_ELFEDIT             ${TOOLCHAIN_PATH}-elfedit       CACHE STRING "" FORCE)
set(CMAKE_CXX_COMPILER        ${TOOLCHAIN_PATH}-g++           CACHE STRING "" FORCE)
set(CMAKE_C_COMPILER          ${TOOLCHAIN_PATH}-gcc           CACHE STRING "" FORCE)
set(CMAKE_ASM_COMPILER_AR     ${TOOLCHAIN_PATH}-gcc-ar        CACHE STRING "" FORCE)
set(CMAKE_C_COMPILER_AR       ${TOOLCHAIN_PATH}-gcc-ar        CACHE STRING "" FORCE)
set(CMAKE_CXX_COMPILER_AR     ${TOOLCHAIN_PATH}-gcc-ar        CACHE STRING "" FORCE)
set(CMAKE_ASM_COMPILER_NM     ${TOOLCHAIN_PATH}-gcc-nm        CACHE STRING "" FORCE)
set(CMAKE_C_COMPILER_NM       ${TOOLCHAIN_PATH}-gcc-nm        CACHE STRING "" FORCE)
set(CMAKE_CXX_COMPILER_NM     ${TOOLCHAIN_PATH}-gcc-nm        CACHE STRING "" FORCE)
set(CMAKE_ASM_COMPILER_RANLIB ${TOOLCHAIN_PATH}-gcc-ranlib    CACHE STRING "" FORCE)
set(CMAKE_C_COMPILER_RANLIB   ${TOOLCHAIN_PATH}-gcc-ranlib    CACHE STRING "" FORCE)
set(CMAKE_CXX_COMPILER_RANLIB ${TOOLCHAIN_PATH}-gcc-ranlib    CACHE STRING "" FORCE)
set(CMAKE_GCOV                ${TOOLCHAIN_PATH}-gcov          CACHE STRING "" FORCE)
set(CMAKE_GCOV_DUMP           ${TOOLCHAIN_PATH}-gcov-dump     CACHE STRING "" FORCE)
set(CMAKE_GCOV_TOOL           ${TOOLCHAIN_PATH}-gcov-tool     CACHE STRING "" FORCE)
set(CMAKE_GDB                 ${TOOLCHAIN_PATH}-gdb           CACHE STRING "" FORCE)
set(CMAKE_GDB_ADD_INDEX       ${TOOLCHAIN_PATH}-gdb-add-index CACHE STRING "" FORCE)
set(CMAKE_GPROF               ${TOOLCHAIN_PATH}-gprof         CACHE STRING "" FORCE)
set(CMAKE_LINKER              ${TOOLCHAIN_PATH}-ld            CACHE STRING "" FORCE)
set(CMAKE_NM                  ${TOOLCHAIN_PATH}-nm            CACHE STRING "" FORCE)
set(CMAKE_OBJCOPY             ${TOOLCHAIN_PATH}-objcopy       CACHE STRING "" FORCE)
set(CMAKE_OBJDUMP             ${TOOLCHAIN_PATH}-objdump       CACHE STRING "" FORCE)
set(CMAKE_RANLIB              ${TOOLCHAIN_PATH}-ranlib        CACHE STRING "" FORCE)
set(CMAKE_READELF             ${TOOLCHAIN_PATH}-readelf       CACHE STRING "" FORCE)
set(CMAKE_SIZE                ${TOOLCHAIN_PATH}-size          CACHE STRING "" FORCE)
set(CMAKE_STRINGS             ${TOOLCHAIN_PATH}-strings       CACHE STRING "" FORCE)
set(CMAKE_STRIP               ${TOOLCHAIN_PATH}-strip         CACHE STRING "" FORCE)

# Set CMake system root path
set(CMAKE_SYSROOT             ${SYSROOT_PATH}                 CACHE STRING "" FORCE)

# Set CMake C/C++ flags to toolchain flags
set(CMAKE_C_FLAGS             ${TOOLCHAIN_FLAGS}              CACHE STRING "" FORCE)
set(CMAKE_CXX_FLAGS           ${TOOLCHAIN_FLAGS}              CACHE STRING "" FORCE)

# Overwrite lookup priority for custom system root
set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM BOTH)
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_PACKAGE ONLY)

# Set pkg-config path environment variable to system root for FindPkgConfig
set(ENV{PKG_CONFIG_PATH} ${CMAKE_SYSROOT}/usr/lib/pkgconfig)
