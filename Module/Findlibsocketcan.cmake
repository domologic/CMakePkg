#
# find_package module for libsocketcan library
#
# Tries to locate the libsocketcan library with pkgconfig
#

include(FindPackageHandleStandardArgs)

find_package(PkgConfig QUIET)
pkg_check_modules(PC_LIBSOCKETCAN libsocketcan QUIET)

set(LIBSOCKETCAN_VERSION ${PC_LIBSOCKETCAN_VERSION})

find_path(LIBSOCKETCAN_INCLUDE_DIR
  NAMES
    libsocketcan.h
  HINTS
    ${PC_LIBSOCKETCAN_INCLUDEDIR}
    ${PC_LIBSOCKETCAN_INCLUDE_DIRS}
)

find_library(LIBSOCKETCAN_LIBRARY
  NAMES
    socketcan
    libsocketcan
  HINTS
    ${PC_LIBSOCKETCAN_LIBDIR}
    ${PC_LIBSOCKETCAN_LIBRARY_DIRS}
)

find_package_handle_standard_args(libsocketcan
  DEFAULT_MSG
  LIBSOCKETCAN_VERSION
  LIBSOCKETCAN_INCLUDE_DIR
  LIBSOCKETCAN_LIBRARY
)

if (libsocketcan_FOUND)
  set(LIBSOCKETCAN_INCLUDE_DIRS
    ${LIBSOCKETCAN_INCLUDE_DIR}
  )

  set(LIBSOCKETCAN_LIBRARIES
    ${LIBSOCKETCAN_LIBRARY}
  )

  mark_as_advanced(
    LIBSOCKETCAN_VERSION
    LIBSOCKETCAN_INCLUDE_DIR
    LIBSOCKETCAN_INCLUDE_DIRS
    LIBSOCKETCAN_LIBRARY
    LIBSOCKETCAN_LIBRARIES
  )
endif()
