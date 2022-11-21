#
# find_package module for libsystemd library
#
# Tries to locate the libsystemd library with pkgconfig
#

include(FindPackageHandleStandardArgs)

find_package(PkgConfig QUIET)
pkg_check_modules(PC_LIBSYSTEMD libsystemd QUIET)

set(LIBSYSTEMD_VERSION ${PC_LIBSYSTEMD_VERSION})

find_path(LIBSYSTEMD_INCLUDE_DIR
  NAMES
    systemd/sd-daemon.h
  HINTS
    ${PC_LIBSYSTEMD_INCLUDEDIR}
    ${PC_LIBSYSTEMD_INCLUDE_DIRS}
)

find_library(LIBSYSTEMD_LIBRARY
  NAMES
    systemd
  HINTS
    ${PC_LIBSYSTEMD_LIBDIR}
    ${PC_LIBSYSTEMD_LIBRARY_DIRS}
)

find_package_handle_standard_args(libsystemd
  DEFAULT_MSG
  LIBSYSTEMD_VERSION
  LIBSYSTEMD_INCLUDE_DIR
  LIBSYSTEMD_LIBRARY
)

if (libsystemd_FOUND)
  set(LIBSYSTEMD_INCLUDE_DIRS
    ${LIBSYSTEMD_INCLUDE_DIR}
  )

  set(LIBSYSTEMD_LIBRARIES
    ${LIBSYSTEMD_LIBRARY}
  )

  mark_as_advanced(
    LIBSYSTEMD_VERSION
    LIBSYSTEMD_INCLUDE_DIR
    LIBSYSTEMD_INCLUDE_DIRS
    LIBSYSTEMD_LIBRARY
    LIBSYSTEMD_LIBRARIES
  )
endif()
