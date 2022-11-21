#
# find_package module for libudev library
#
# Tries to locate the libudev library with pkgconfig
#

include(FindPackageHandleStandardArgs)

find_package(PkgConfig QUIET)
pkg_check_modules(PC_LIBUDEV libudev QUIET)

set(LIBUDEV_VERSION ${PC_LIBUDEV_VERSION})

find_path(LIBUDEV_INCLUDE_DIR
  NAMES
    libudev.h
  HINTS
    ${PC_LIBUDEV_INCLUDEDIR}
    ${PC_LIBUDEV_INCLUDE_DIRS}
)

find_library(LIBUDEV_LIBRARY
  NAMES
    udev
    libudev
  HINTS
    ${PC_LIBUDEV_LIBDIR}
    ${PC_LIBUDEV_LIBRARY_DIRS}
)

find_package_handle_standard_args(libudev
  DEFAULT_MSG
  LIBUDEV_VERSION
  LIBUDEV_INCLUDE_DIR
  LIBUDEV_LIBRARY
)

if (libudev_FOUND)
  set(LIBUDEV_INCLUDE_DIRS
    ${LIBUDEV_INCLUDE_DIR}
  )

  set(LIBUDEV_LIBRARIES
    ${LIBUDEV_LIBRARY}
  )

  mark_as_advanced(
    LIBUDEV_VERSION
    LIBUDEV_INCLUDE_DIR
    LIBUDEV_INCLUDE_DIRS
    LIBUDEV_LIBRARY
    LIBUDEV_LIBRARIES
  )
endif()
