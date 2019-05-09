include(FindPackageHandleStandardArgs)

find_package(PkgConfig QUIET)
pkg_check_modules(PKG_CONFIG_CAIRO cairo QUIET)

set(CAIRO_VERSION ${PKG_CONFIG_CAIRO_VERSION})

find_path(CAIRO_INCLUDE_DIR
  NAMES
    cairo.h
  HINTS
    ${PKG_CONFIG_CAIRO_INCLUDEDIR}
    ${PKG_CONFIG_CAIRO_INCLUDE_DIRS}
  PATH_SUFFIXES
    cairo
)

find_library(CAIRO_LIBRARY
  NAMES
    cairo
  HINTS
    ${PKG_CONFIG_CAIRO_LIBDIR}
    ${PKG_CONFIG_CAIRO_LIBRARY_DIRS}
)

find_package_handle_standard_args(Cairo
  DEFAULT_MSG
  CAIRO_VERSION
  CAIRO_INCLUDE_DIR
  CAIRO_LIBRARY
)

if (Cairo_FOUND)
  mark_as_advanced(
    CAIRO_VERSION
    CAIRO_INCLUDE_DIR
    CAIRO_LIBRARY
  )
endif()