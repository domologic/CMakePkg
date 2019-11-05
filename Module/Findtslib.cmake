#
# find_package module for tslib library
#
# Tries to locate the tslib library with pkgconfig
#

include(FindPackageHandleStandardArgs)

find_package(PkgConfig QUIET)
pkg_check_modules(PC_TSLIB tslib QUIET)

set(TSLIB_VERSION ${PC_TSLIB_VERSION})

find_path(TSLIB_INCLUDE_DIR
  NAMES
    tslib/tslib.h
  HINTS
    ${PC_TSLIB_INCLUDEDIR}
    ${PC_TSLIB_INCLUDE_DIRS}
)

find_library(TSLIB_LIBRARY
  NAMES
    ts
    tslib
  HINTS
    ${PC_TSLIB_LIBDIR}
    ${PC_TSLIB_LIBRARY_DIRS}
)

find_package_handle_standard_args(tslib
  DEFAULT_MSG
  TSLIB_VERSION
  TSLIB_INCLUDE_DIR
  TSLIB_LIBRARY
)

if (tslib_FOUND)
  set(TSLIB_INCLUDE_DIRS
    ${TSLIB_INCLUDE_DIR}
  )

  set(TSLIB_LIBRARIES
    ${TSLIB_LIBRARY}
  )

  mark_as_advanced(
    TSLIB_VERSION
    TSLIB_INCLUDE_DIR
    TSLIB_INCLUDE_DIRS
    TSLIB_LIBRARY
    TSLIB_LIBRARIES
  )
endif()
