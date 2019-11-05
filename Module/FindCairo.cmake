#
# find_package module for Cairo library
#
# Tries to locate the Cairo library with pkgconfig
#

include(FindPackageHandleStandardArgs)

find_package(PkgConfig QUIET)
pkg_check_modules(PC_CAIRO cairo QUIET)

set(CAIRO_VERSION ${PC_CAIRO_VERSION})

find_path(CAIRO_INCLUDE_DIR
  NAMES
    cairo/cairo.h
  HINTS
    ${PC_CAIRO_INCLUDEDIR}
    ${PC_CAIRO_INCLUDE_DIRS}
  PATH_SUFFIXES
    cairo
)

find_library(CAIRO_LIBRARY
  NAMES
    cairo
  HINTS
    ${PC_CAIRO_LIBDIR}
    ${PC_CAIRO_LIBRARY_DIRS}
)

find_package_handle_standard_args(Cairo
  DEFAULT_MSG
  CAIRO_VERSION
  CAIRO_INCLUDE_DIR
  CAIRO_LIBRARY
)

if (Cairo_FOUND)
  set(CAIRO_INCLUDE_DIRS
    ${CAIRO_INCLUDE_DIR}
    ${CAIRO_INCLUDE_DIR}/cairo
  )

  set(CAIRO_LIBRARIES
    ${CAIRO_LIBRARY}
  )

  mark_as_advanced(
    CAIRO_VERSION
    CAIRO_INCLUDE_DIR
    CAIRO_INCLUDE_DIRS
    CAIRO_LIBRARY
    CAIRO_LIBRARIES
  )
endif()
