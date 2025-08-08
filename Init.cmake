#
# Init script
#

include_guard(GLOBAL)

message(STATUS "Loading CMakePkg...")

option(CMAKEPKG_PIC                  "Use position independent code."                             ON)
option(CMAKEPKG_LTO                  "Enable link time optimization."                             OFF)
option(CMAKEPKG_BUILD_DATA_PRESERVE  "Preserve the required build data for reproducible builds."  OFF)

if (NOT DEFINED CMAKEPKG_C_STD)
  set(CMAKEPKG_C_STD   17)
endif()
if (NOT DEFINED CMAKEPKG_CXX_STD)
  set(CMAKEPKG_CXX_STD 20)
endif()

set(CMAKE_MODULE_PATH                   ${CMAKEPKG_SOURCE_DIR}/Module)
set(CMAKE_MSVC_RUNTIME_LIBRARY          "")

set(CMAKE_SKIP_BUILD_RPATH              ON)
set(CMAKE_BUILD_WITH_INSTALL_RPATH      OFF)
set(CMAKE_INSTALL_RPATH_USE_LINK_PATH   OFF)

set(CMAKE_EXPORT_COMPILE_COMMANDS       ON)

set(CMAKE_C_STANDARD                    ${CMAKEPKG_C_STD})
set(CMAKE_CXX_STANDARD                  ${CMAKEPKG_CXX_STD})
set(CMAKE_POSITION_INDEPENDENT_CODE     ${CMAKEPKG_PIC})
set(CMAKE_INTERPROCEDURAL_OPTIMIZATION  ${CMAKEPKG_LTO})

# cleanup cmake default asm flags
set(CMAKE_ASM_FLAGS                     "" CACHE STRING "" FORCE)
set(CMAKE_ASM_FLAGS_DEBUG               "" CACHE STRING "" FORCE)
set(CMAKE_ASM_FLAGS_RELEASE             "" CACHE STRING "" FORCE)
set(CMAKE_ASM_FLAGS_RELWITHDEBINFO      "" CACHE STRING "" FORCE)
set(CMAKE_ASM_FLAGS_MINSIZEREL          "" CACHE STRING "" FORCE)

# cleanup cmake default asm flags
set(CMAKE_ASM_MASM_FLAGS                "" CACHE STRING "" FORCE)
set(CMAKE_ASM_MASM_FLAGS_DEBUG          "" CACHE STRING "" FORCE)
set(CMAKE_ASM_MASM_FLAGS_RELEASE        "" CACHE STRING "" FORCE)
set(CMAKE_ASM_MASM_FLAGS_RELWITHDEBINFO "" CACHE STRING "" FORCE)
set(CMAKE_ASM_MASM_FLAGS_MINSIZEREL     "" CACHE STRING "" FORCE)

# cleanup cmake default c flags
set(CMAKE_C_FLAGS                       "" CACHE STRING "" FORCE)
set(CMAKE_C_FLAGS_DEBUG                 "" CACHE STRING "" FORCE)
set(CMAKE_C_FLAGS_RELEASE               "" CACHE STRING "" FORCE)
set(CMAKE_C_FLAGS_RELWITHDEBINFO        "" CACHE STRING "" FORCE)
set(CMAKE_C_FLAGS_MINSIZEREL            "" CACHE STRING "" FORCE)

# cleanup cmake default c++ flags
set(CMAKE_CXX_FLAGS                     "" CACHE STRING "" FORCE)
set(CMAKE_CXX_FLAGS_DEBUG               "" CACHE STRING "" FORCE)
set(CMAKE_CXX_FLAGS_RELEASE             "" CACHE STRING "" FORCE)
set(CMAKE_CXX_FLAGS_RELWITHDEBINFO      "" CACHE STRING "" FORCE)
set(CMAKE_CXX_FLAGS_MINSIZEREL          "" CACHE STRING "" FORCE)

set(ENV{GIT_CLONE_PROTECTION_ACTIVE}    false)

if (WIN32)
  set(CMAKEPKG_ASM  ASM_MASM  CACHE STRING "Alias to system local assembler language.")
else()
  set(CMAKEPKG_ASM  ASM       CACHE STRING "Alias to system local assembler language.")
endif()

set_property(GLOBAL
  PROPERTY
    USE_FOLDERS ON
)

find_package(Doxygen
  OPTIONAL_COMPONENTS
    dot
    mscgen
    dia
  QUIET
)

enable_testing()

include(${CMAKEPKG_SOURCE_DIR}/AddPackage.cmake)
include(${CMAKEPKG_SOURCE_DIR}/Config.cmake)
include(${CMAKEPKG_SOURCE_DIR}/Extensions.cmake)
include(${CMAKEPKG_SOURCE_DIR}/Zephyr.cmake)
