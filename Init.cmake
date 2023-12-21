#
# Init script
#

include_guard(GLOBAL)

message(STATUS "Loading CMakePkg...")

option(CMAKEPKG_PIC      "Use position independent code"  ON)
option(CMAKEPKG_LTO      "Enable link time optimization"  OFF)

if (NOT DEFINED CMAKEPKG_C_STD)
  set(CMAKEPKG_C_STD   11)
endif()
if (NOT DEFINED CMAKEPKG_CXX_STD)
  set(CMAKEPKG_CXX_STD 17)
endif()

set(CMAKE_MODULE_PATH                 ${CMAKEPKG_SOURCE_DIR}/Module)
set(CMAKE_CONFIGURATION_TYPES         "Debug;Release" CACHE STRING "" FORCE)

set(CMAKE_SKIP_BUILD_RPATH            ON)
set(CMAKE_BUILD_WITH_INSTALL_RPATH    OFF)
set(CMAKE_INSTALL_RPATH_USE_LINK_PATH OFF)

set(CMAKE_EXPORT_COMPILE_COMMANDS     ON)

set(CMAKE_C_STANDARD                    ${CMAKEPKG_C_STD})
set(CMAKE_CXX_STANDARD                  ${CMAKEPKG_CXX_STD})
set(CMAKE_POSITION_INDEPENDENT_CODE     ${CMAKEPKG_PIC})
set(CMAKE_INTERPROCEDURAL_OPTIMIZATION  ${CMAKEPKG_LTO})

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

include(${CMAKEPKG_SOURCE_DIR}/AddModule.cmake)
include(${CMAKEPKG_SOURCE_DIR}/AddPackage.cmake)
include(${CMAKEPKG_SOURCE_DIR}/Config.cmake)
include(${CMAKEPKG_SOURCE_DIR}/Extensions.cmake)
include(${CMAKEPKG_SOURCE_DIR}/Zephyr.cmake)
