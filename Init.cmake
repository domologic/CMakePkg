#
# Init script
#

include_guard(GLOBAL)

message(STATUS "Loading CMakePkg...")

set(CMAKE_MODULE_PATH                 ${CMAKEPKG_SOURCE_DIR}/Module)
set(CMAKE_CONFIGURATION_TYPES         "Debug;Release" CACHE STRING "" FORCE)

set(CMAKE_POSITION_INDEPENDENT_CODE   ON)

set(CMAKE_C_STANDARD                  11)
set(CMAKE_CXX_STANDARD                17)

set(CMAKE_SKIP_BUILD_RPATH            ON)
set(CMAKE_BUILD_WITH_INSTALL_RPATH    OFF)
set(CMAKE_INSTALL_RPATH_USE_LINK_PATH OFF)

set(CMAKE_EXPORT_COMPILE_COMMANDS     ON)

set_property(GLOBAL
  PROPERTY
    USE_FOLDERS ON
)

enable_testing()

include(FetchContent)
include(${CMAKEPKG_SOURCE_DIR}/AddModule.cmake)
include(${CMAKEPKG_SOURCE_DIR}/Util.cmake)

# load tags file if it was specified
load_tags_file()
