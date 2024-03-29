#
# find_package module for libubi library
#
# Tries to locate the libubi library with pkgconfig
#

include(FindPackageHandleStandardArgs)

find_package(PkgConfig QUIET)
pkg_check_modules(PC_LIBUBI libubi QUIET)

if (libubi_FOUND)
  set(LIBUBI_VERSION ${PC_LIBUBI_VERSION})
else()
  set(LIBUBI_VERSION "2.1.2-2")
endif()

find_path(LIBUBI_INCLUDE_DIR
  NAMES
    libubi.h
  HINTS
    ${PC_LIBUBI_INCLUDEDIR}
    ${PC_LIBUBI_INCLUDE_DIRS}
)

find_library(LIBUBI_LIBRARY
  NAMES
    ubi
    libubi
  HINTS
    ${PC_LIBUBI_LIBDIR}
    ${PC_LIBUBI_LIBRARY_DIRS}
)

if (NOT DEFINED LIBUBI_INCLUDE_DIR_NOTFOUND AND NOT DEFINED LIBUBI_LIBRARY_FOUND)
  set(libubi_FOUND ON)
endif()

find_package_handle_standard_args(libubi
  DEFAULT_MSG
  LIBUBI_VERSION
  LIBUBI_INCLUDE_DIR
  LIBUBI_LIBRARY
)

if (libubi_FOUND)
  set(LIBUBI_INCLUDE_DIRS
    ${LIBUBI_INCLUDE_DIR}
  )

  set(LIBUBI_LIBRARIES
    ${LIBUBI_LIBRARY}
  )

  mark_as_advanced(
    LIBUBI_VERSION
    LIBUBI_INCLUDE_DIR
    LIBUBI_INCLUDE_DIRS
    LIBUBI_LIBRARY
    LIBUBI_LIBRARIES
  )
endif()
