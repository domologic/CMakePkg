#
# Toolchain description file for zig
#

if (NOT DEFINED ZIG_ARCH)
  set(ZIG_ARCH        "armv7")
endif()
if (NOT DEFINED ZIG_TARGET_ABI)
  set(ZIG_TARGET_ABI  "arm-linux-gnueabihf.2.28")
endif()
if (NOT DEFINED ZIG_SOURCE_ABI)
  set(ZIG_SOURCE_ABI  "alpine-linux-musleabihf")
endif()

set(TOOLCHAIN_COMPILE_FLAGS  "-target ${ZIG_TARGET_ABI}")
set(TOOLCHAIN_PATH           ${ZIG_ARCH}-${ZIG_SOURCE_ABI})

# Platform description
set(CMAKE_SYSTEM_NAME         "Linux"                      CACHE STRING "")
set(CMAKE_SYSTEM_PROCESSOR    "armv7hf_neon_clang"         CACHE STRING "")

# Available tools in the toolchain

set(CMAKE_ADDR2LINE           ${TOOLCHAIN_PATH}-addr2line  CACHE STRING "" FORCE)
set(CMAKE_AR                  ${TOOLCHAIN_PATH}-ar         CACHE STRING "" FORCE)
set(CMAKE_ASM_COMPILER        ${TOOLCHAIN_PATH}-as         CACHE STRING "" FORCE)
set(CMAKE_ASM_COMPILER_AR     ${TOOLCHAIN_PATH}-ar         CACHE STRING "" FORCE)
set(CMAKE_ASM_COMPILER_NM     ${TOOLCHAIN_PATH}-nm         CACHE STRING "" FORCE)
set(CMAKE_ASM_COMPILER_RANLIB ${TOOLCHAIN_PATH}-ranlib     CACHE STRING "" FORCE)
set(CMAKE_CXX_COMPILER        zig c++                      CACHE STRING "" FORCE)
set(CMAKE_CXX_COMPILER_AR     ${TOOLCHAIN_PATH}-ar         CACHE STRING "" FORCE)
set(CMAKE_CXX_COMPILER_NM     ${TOOLCHAIN_PATH}-nm         CACHE STRING "" FORCE)
set(CMAKE_CXX_COMPILER_RANLIB ${TOOLCHAIN_PATH}-ranlib     CACHE STRING "" FORCE)
set(CMAKE_CXX_FILT            ${TOOLCHAIN_PATH}-c++filt    CACHE STRING "" FORCE)
set(CMAKE_C_COMPILER          zig cc                       CACHE STRING "" FORCE)
set(CMAKE_C_COMPILER_AR       ${TOOLCHAIN_PATH}-ar         CACHE STRING "" FORCE)
set(CMAKE_C_COMPILER_NM       ${TOOLCHAIN_PATH}-nm         CACHE STRING "" FORCE)
set(CMAKE_C_COMPILER_RANLIB   ${TOOLCHAIN_PATH}-ranlib     CACHE STRING "" FORCE)
set(CMAKE_ELFEDIT             ${TOOLCHAIN_PATH}-elfedit    CACHE STRING "" FORCE)
set(CMAKE_GPROF               ${TOOLCHAIN_PATH}-gprof      CACHE STRING "" FORCE)
set(CMAKE_LINKER              ld.lld                       CACHE STRING "" FORCE)
set(CMAKE_NM                  ${TOOLCHAIN_PATH}-nm         CACHE STRING "" FORCE)
set(CMAKE_OBJCOPY             ${TOOLCHAIN_PATH}-objcopy    CACHE STRING "" FORCE)
set(CMAKE_OBJDUMP             ${TOOLCHAIN_PATH}-objdump    CACHE STRING "" FORCE)
set(CMAKE_RANLIB              ${TOOLCHAIN_PATH}-ranlib     CACHE STRING "" FORCE)
set(CMAKE_READELF             ${TOOLCHAIN_PATH}-readelf    CACHE STRING "" FORCE)
set(CMAKE_SIZE                ${TOOLCHAIN_PATH}-size       CACHE STRING "" FORCE)
set(CMAKE_STRINGS             ${TOOLCHAIN_PATH}-strings    CACHE STRING "" FORCE)
set(CMAKE_STRIP               ${TOOLCHAIN_PATH}-strip      CACHE STRING "" FORCE)

# Set CMake C/C++ flags to tollchain flags
set(CMAKE_C_FLAGS             "-target ${ZIG_TARGET_ABI}"  CACHE STRING "" FORCE)
set(CMAKE_CXX_FLAGS           "-target ${ZIG_TARGET_ABI}"  CACHE STRING "" FORCE)
