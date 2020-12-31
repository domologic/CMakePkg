#
# Init script
#

include_guard(GLOBAL)

if (NOT DEFINED CMAKEPKG_MODE)
  set(CMAKEPKG_MODE "JOINED")
endif()
if (NOT (CMAKEPKG_MODE STREQUAL "JOINED") AND NOT(CMAKEPKG_MODE STREQUAL "PREBUILD"))
  message(FATAL_ERROR "Unsupported CMAKEPKG_MODE: ${CMAKEPKG_MODE}")
endif()
message(STATUS "Loading CMakePkg (CMAKEPKG_MODE=${CMAKEPKG_MODE})...")

if (DEFINED CMAKEPKG_PRIVATE_KEY_FILE)
  set(ENV{GIT_SSH_COMMAND} "ssh -F /dev/null -i ${CMAKEPKG_PRIVATE_KEY_FILE} -o 'StrictHostKeyChecking=no' -o 'UserKnownHostsFile=/dev/null'")
endif()

set(CMAKE_MODULE_PATH                 ${CMAKE_CURRENT_LIST_DIR}/Module)
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

if (UNIX)
  include(ProcessorCount)
  ProcessorCount(N)
  if (NOT N EQUAL 0)
    #set(CMAKE_MAKE_PROGRAM "${CMAKE_MAKE_PROGRAM} -j${N}")
  endif()
endif()

include(${CMAKE_CURRENT_LIST_DIR}/AddModule.cmake)

enable_testing()
