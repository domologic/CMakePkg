#
# Init script
#

include_guard(GLOBAL)

message(STATUS "Loading CMakePkg...")

option(CMAKEPKG_PIC      "Use position independent code" ON)

if (NOT DEFINED CMAKEPKG_C_STD)
  set(CMAKEPKG_C_STD 11)
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

set(CMAKE_C_STANDARD                  ${CMAKEPKG_C_STD})
set(CMAKE_CXX_STANDARD                ${CMAKEPKG_CXX_STD})
set(CMAKE_POSITION_INDEPENDENT_CODE   ${CMAKEPKG_PIC})

set_property(GLOBAL
  PROPERTY
    USE_FOLDERS ON
)

enable_testing()

include(${CMAKEPKG_SOURCE_DIR}/AddModule.cmake)
include(${CMAKEPKG_SOURCE_DIR}/Extensions.cmake)
include(${CMAKEPKG_SOURCE_DIR}/Util.cmake)

# load tags file if it was specified
load_tags_file()
