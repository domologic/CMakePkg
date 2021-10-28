#
# Toolchain description file for
#

if (DEFINED CMAKEPKG_TOOLCHAIN_PATH)
  set(TOOLCHAIN_PATH "${CMAKEPKG_TOOLCHAIN_PATH}/bin/arm-none-eabi-")
else()
  find_program(TOOLCHAIN_PATH
    NAMES
      "arm-none-eabi-gcc"
      "arm-none-eabi-gcc.exe"
    HINTS
      "C:/Program Files"
      "C:/Program Files/GCC"
      "C:/Program Files/GCC/gcc-arm-none-eabi-win32-4.9-DAVE4"
      "C:/Program Files/GCC/gcc-arm-none-eabi-win32-4.9-DAVE4/bin"
      "/opt"
      "/opt/gcc-arm-none-eabi-win32-4.9-DAVE4"
  )
  if (TOOLCHAIN_PATH)
    get_filename_component(TOOLCHAIN_PATH "${TOOLCHAIN_PATH}" DIRECTORY)
    set(TOOLCHAIN_PATH "${TOOLCHAIN_PATH}/arm-none-eabi")
  else()
    if (WIN32)
      set(TOOLCHAIN_PATH  "C:/Program Files/GCC/gcc-arm-none-eabi-win32-4.9-DAVE4/bin/arm-none-eabi")
    else()
      set(TOOLCHAIN_PATH  "/opt/gcc-arm-none-eabi-win32-4.9-DAVE4/bin/arm-none-eabi")
    endif()
  endif()
endif()

set(TOOLCHAIN_COMPILE_FLAGS "-mcpu=cortex-m4 -mthumb -mfpu=fpv4-sp-d16 -mfloat-abi=softfp -nostartfiles -specs=nano.specs -specs=nosys.specs")
set(TOOLCHAIN_ASM_FLAGS     "-xassembler-with-cpp")

# Platform description
set(CMAKE_SYSTEM_NAME         "Generic"                           CACHE STRING "" FORCE)
set(CMAKE_SYSTEM_PROCESSOR    "arm"                               CACHE STRING "" FORCE)

# Available tools in the toolchain
set(CMAKE_ADDR2LINE           ${TOOLCHAIN_PATH}-addr2line.exe     CACHE STRING "" FORCE)
set(CMAKE_AR                  ${TOOLCHAIN_PATH}-ar.exe            CACHE STRING "" FORCE)
set(CMAKE_ASM_COMPILER        ${TOOLCHAIN_PATH}-gcc.exe           CACHE STRING "" FORCE)
set(CMAKE_CXX_FILT            ${TOOLCHAIN_PATH}-c++filt.exe       CACHE STRING "" FORCE)
set(CMAKE_DWP                 ${TOOLCHAIN_PATH}-dwp.exe           CACHE STRING "" FORCE)
set(CMAKE_ELFEDIT             ${TOOLCHAIN_PATH}-elfedit.exe       CACHE STRING "" FORCE)
set(CMAKE_CXX_COMPILER        ${TOOLCHAIN_PATH}-g++.exe           CACHE STRING "" FORCE)
set(CMAKE_C_COMPILER          ${TOOLCHAIN_PATH}-gcc.exe           CACHE STRING "" FORCE)
set(CMAKE_ASM_COMPILER_AR     ${TOOLCHAIN_PATH}-gcc-ar.exe        CACHE STRING "" FORCE)
set(CMAKE_C_COMPILER_AR       ${TOOLCHAIN_PATH}-gcc-ar.exe        CACHE STRING "" FORCE)
set(CMAKE_CXX_COMPILER_AR     ${TOOLCHAIN_PATH}-gcc-ar.exe        CACHE STRING "" FORCE)
set(CMAKE_ASM_COMPILER_NM     ${TOOLCHAIN_PATH}-gcc-nm.exe        CACHE STRING "" FORCE)
set(CMAKE_C_COMPILER_NM       ${TOOLCHAIN_PATH}-gcc-nm.exe        CACHE STRING "" FORCE)
set(CMAKE_CXX_COMPILER_NM     ${TOOLCHAIN_PATH}-gcc-nm.exe        CACHE STRING "" FORCE)
set(CMAKE_ASM_COMPILER_RANLIB ${TOOLCHAIN_PATH}-gcc-ranlib.exe    CACHE STRING "" FORCE)
set(CMAKE_C_COMPILER_RANLIB   ${TOOLCHAIN_PATH}-gcc-ranlib.exe    CACHE STRING "" FORCE)
set(CMAKE_CXX_COMPILER_RANLIB ${TOOLCHAIN_PATH}-gcc-ranlib.exe    CACHE STRING "" FORCE)
set(CMAKE_GCOV                ${TOOLCHAIN_PATH}-gcov.exe          CACHE STRING "" FORCE)
set(CMAKE_GCOV_DUMP           ${TOOLCHAIN_PATH}-gcov-dump.exe     CACHE STRING "" FORCE)
set(CMAKE_GCOV_TOOL           ${TOOLCHAIN_PATH}-gcov-tool.exe     CACHE STRING "" FORCE)
set(CMAKE_GDB                 ${TOOLCHAIN_PATH}-gdb.exe           CACHE STRING "" FORCE)
set(CMAKE_GDB_ADD_INDEX       ${TOOLCHAIN_PATH}-gdb-add-index.exe CACHE STRING "" FORCE)
set(CMAKE_GPROF               ${TOOLCHAIN_PATH}-gprof.exe         CACHE STRING "" FORCE)
set(CMAKE_LINKER              ${TOOLCHAIN_PATH}-ld.exe            CACHE STRING "" FORCE)
set(CMAKE_NM                  ${TOOLCHAIN_PATH}-nm.exe            CACHE STRING "" FORCE)
set(CMAKE_OBJCOPY             ${TOOLCHAIN_PATH}-objcopy.exe       CACHE STRING "" FORCE)
set(CMAKE_OBJDUMP             ${TOOLCHAIN_PATH}-objdump.exe       CACHE STRING "" FORCE)
set(CMAKE_RANLIB              ${TOOLCHAIN_PATH}-ranlib.exe        CACHE STRING "" FORCE)
set(CMAKE_READELF             ${TOOLCHAIN_PATH}-readelf.exe       CACHE STRING "" FORCE)
set(CMAKE_SIZE                ${TOOLCHAIN_PATH}-size.exe          CACHE STRING "" FORCE)
set(CMAKE_STRINGS             ${TOOLCHAIN_PATH}-strings.exe       CACHE STRING "" FORCE)
set(CMAKE_STRIP               ${TOOLCHAIN_PATH}-strip.exe         CACHE STRING "" FORCE)

# Set CMake C/C++ flags to tollchain flags
set(CMAKE_C_FLAGS             ${TOOLCHAIN_COMPILE_FLAGS}          CACHE STRING "" FORCE)
set(CMAKE_CXX_FLAGS           ${TOOLCHAIN_COMPILE_FLAGS}          CACHE STRING "" FORCE)
set(CMAKE_ASM_FLAGS           ${TOOLCHAIN_ASM_FLAGS}              CACHE STRING "" FORCE)

set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_PACKAGE ONLY)
