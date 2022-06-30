#
# Toolchain description file for gcc-arm-none-eabi-msys2
#

list(APPEND CMAKE_FIND_ROOT_PATH "${CMAKEPKG_TOOLCHAIN_PATH}")

if (DEFINED CMAKEPKG_TOOLCHAIN_PATH)
  set(TOOLCHAIN_PATH "${CMAKEPKG_TOOLCHAIN_PATH}/bin")
else()
  find_path(TOOLCHAIN_PATH
    NAMES
      "gcc"
      "gcc.exe"
    HINTS
      "C:/msys64/mingw64/bin"
  )
#  if (TOOLCHAIN_PATH)
#    get_filename_component(TOOLCHAIN_PATH "${TOOLCHAIN_PATH}" DIRECTORY)
#    set(TOOLCHAIN_PATH "${TOOLCHAIN_PATH}/arm-none-eabi")
#  else()
#    if (WIN32)
#      set(TOOLCHAIN_PATH  "C:/Program Files/GCC/gcc-arm-none-eabi-10.3-2021.10/bin/arm-none-eabi")
#    else()
#      set(TOOLCHAIN_PATH  "/opt/gcc-arm-none-eabi-10.3-2021.10/bin/arm-none-eabi")
#    endif()
#  endif()
endif()

# Platform description
#set(CMAKE_SYSTEM_NAME         "Generic"                           CACHE STRING "")
#set(CMAKE_SYSTEM_PROCESSOR    "arm"                               CACHE STRING "")

# Available tools in the toolchain
set(CMAKE_ADDR2LINE           "${TOOLCHAIN_PATH}/addr2line.exe"                                CACHE FILEPATH "" FORCE)
set(CMAKE_AR                  "${TOOLCHAIN_PATH}/ar.exe"                                       CACHE FILEPATH "" FORCE)
set(CMAKE_ASM_COMPILER        "${TOOLCHAIN_PATH}/gcc.exe"                                      CACHE FILEPATH "" FORCE)
set(CMAKE_CXX_FILT            "${TOOLCHAIN_PATH}/c++filt.exe"                                  CACHE FILEPATH "" FORCE)
set(CMAKE_DWP                 "${TOOLCHAIN_PATH}/dwp.exe"                                      CACHE FILEPATH "" FORCE)
set(CMAKE_ELFEDIT             "${TOOLCHAIN_PATH}/elfedit.exe"                                  CACHE FILEPATH "" FORCE)
set(CMAKE_CXX_COMPILER        "${TOOLCHAIN_PATH}/g++.exe"                                      CACHE FILEPATH "" FORCE)
set(CMAKE_C_COMPILER          "${TOOLCHAIN_PATH}/gcc.exe"                                      CACHE FILEPATH "" FORCE)
set(CMAKE_ASM_COMPILER_AR     "${TOOLCHAIN_PATH}/gcc-ar.exe"                                   CACHE FILEPATH "" FORCE)
set(CMAKE_C_COMPILER_AR       "${TOOLCHAIN_PATH}/gcc-ar.exe"                                   CACHE FILEPATH "" FORCE)
set(CMAKE_CXX_COMPILER_AR     "${TOOLCHAIN_PATH}/gcc-ar.exe"                                   CACHE FILEPATH "" FORCE)
set(CMAKE_ASM_COMPILER_NM     "${TOOLCHAIN_PATH}/gcc-nm.exe"                                   CACHE FILEPATH "" FORCE)
set(CMAKE_C_COMPILER_NM       "${TOOLCHAIN_PATH}/gcc-nm.exe"                                   CACHE FILEPATH "" FORCE)
set(CMAKE_CXX_COMPILER_NM     "${TOOLCHAIN_PATH}/gcc-nm.exe"                                   CACHE FILEPATH "" FORCE)
set(CMAKE_ASM_COMPILER_RANLIB "${TOOLCHAIN_PATH}/gcc-ranlib.exe"                               CACHE FILEPATH "" FORCE)
set(CMAKE_C_COMPILER_RANLIB   "${TOOLCHAIN_PATH}/gcc-ranlib.exe"                               CACHE FILEPATH "" FORCE)
set(CMAKE_CXX_COMPILER_RANLIB "${TOOLCHAIN_PATH}/gcc-ranlib.exe"                               CACHE FILEPATH "" FORCE)
set(CMAKE_GCOV                "${TOOLCHAIN_PATH}/gcov.exe"                                     CACHE FILEPATH "" FORCE)
set(CMAKE_GCOV_DUMP           "${TOOLCHAIN_PATH}/gcov-dump.exe"                                CACHE FILEPATH "" FORCE)
set(CMAKE_GCOV_TOOL           "${TOOLCHAIN_PATH}/gcov-tool.exe"                                CACHE FILEPATH "" FORCE)
set(CMAKE_GDB                 "${TOOLCHAIN_PATH}/gdb.exe"                                      CACHE FILEPATH "" FORCE)
set(CMAKE_GDB_ADD_INDEX       "${TOOLCHAIN_PATH}/gdb-add-index.exe"                            CACHE FILEPATH "" FORCE)
set(CMAKE_GPROF               "${TOOLCHAIN_PATH}/gprof.exe"                                    CACHE FILEPATH "" FORCE)
set(CMAKE_LINKER              "${TOOLCHAIN_PATH}/ld.exe"                                       CACHE FILEPATH "" FORCE)
set(CMAKE_NM                  "${TOOLCHAIN_PATH}/nm.exe"                                       CACHE FILEPATH "" FORCE)
set(CMAKE_OBJCOPY             "${TOOLCHAIN_PATH}/objcopy.exe"                                  CACHE FILEPATH "" FORCE)
set(CMAKE_OBJDUMP             "${TOOLCHAIN_PATH}/objdump.exe"                                  CACHE FILEPATH "" FORCE)
set(CMAKE_RANLIB              "${TOOLCHAIN_PATH}/ranlib.exe"                                   CACHE FILEPATH "" FORCE)
set(CMAKE_READELF             "${TOOLCHAIN_PATH}/readelf.exe"                                  CACHE FILEPATH "" FORCE)
set(CMAKE_SIZE                "${TOOLCHAIN_PATH}/size.exe"                                     CACHE FILEPATH "" FORCE)
set(CMAKE_STRINGS             "${TOOLCHAIN_PATH}/strings.exe"                                  CACHE FILEPATH "" FORCE)
set(CMAKE_STRIP               "${TOOLCHAIN_PATH}/strip.exe"                                    CACHE FILEPATH "" FORCE)

# Set CMake C/C++ flags to tollchain flags
set(CMAKE_C_FLAGS             ""                                                               CACHE STRING "" FORCE)
set(CMAKE_CXX_FLAGS           ""                                                               CACHE STRING "" FORCE)
set(CMAKE_ASM_FLAGS           ""                                                               CACHE STRING "" FORCE)
set(CMAKE_EXE_LINKER_FLAGS    "-pthread -Wl,--gc-sections -p -pg --coverage -lstdc++ -static"  CACHE STRING "" FORCE)

#set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
#set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
#set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)
#set(CMAKE_FIND_ROOT_PATH_MODE_PACKAGE ONLY)

set(CMAKE_THREAD_PREFER_PTHREAD   TRUE)

set(CMAKE_TRY_COMPILE_TARGET_TYPE "STATIC_LIBRARY")
set(CMAKE_C_COMPILER_WORKS        1)
set(CMAKE_CXX_COMPILER_WORKS      1)
