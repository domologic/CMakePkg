#
# find_package module for cairomm library
#
# Tries to locate the cairomm library with pkgconfig
#

include(FindPackageHandleStandardArgs)

find_package(PkgConfig QUIET)

pkg_check_modules(PC_CAIROMM cairomm-1.16 QUIET)

set(CAIROMM_VERSION ${PC_CAIROMM_VERSION})

find_path(CAIROMM_INCLUDE_DIR
  NAMES
    cairomm/cairomm.h
  HINTS
    ${PC_CAIROMM_INCLUDEDIR}
    ${PC_CAIROMM_INCLUDE_DIRS}
  PATH_SUFFIXES
    cairomm-1.16
)

find_path(CAIROMM_CONFIG_INCLUDE_DIR
  NAMES
    cairommconfig.h
  HINTS
    ${PC_CAIROMM_LIBDIR}
    ${PC_CAIROMM_LIBRARY_DIRS}
  PATH_SUFFIXES
    cairomm-1.16/include
)

find_library(CAIROMM_LIBRARY
  NAMES
    cairomm-1.16
  HINTS
    ${PKG_CONFIG_CAIROMM_LIBDIR}
    ${PKG_CONFIG_CAIROMM_LIBRARY_DIRS}
)

find_package_handle_standard_args(cairomm
  DEFAULT_MSG
  CAIROMM_VERSION
  CAIROMM_INCLUDE_DIR
  CAIROMM_CONFIG_INCLUDE_DIR
  CAIROMM_LIBRARY
)

if (cairomm_FOUND)
  set(CAIROMM_INCLUDE_DIRS
    ${CAIROMM_INCLUDE_DIR}
    ${CAIROMM_CONFIG_INCLUDE_DIR}
  )

  set(CAIROMM_LIBRARIES
    ${CAIROMM_LIBRARY}
  )

  mark_as_advanced(
    CAIROMM_VERSION
    CAIROMM_INCLUDE_DIR
    CAIROMM_CONFIG_INCLUDE_DIR
    CAIROMM_INCLUDE_DIRS
    CAIROMM_LIBRARY
    CAIROMM_LIBRARIES
  )
endif()
