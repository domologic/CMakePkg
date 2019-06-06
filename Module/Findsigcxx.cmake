include(FindPackageHandleStandardArgs)

find_package(PkgConfig QUIET)
pkg_check_modules(PC_SIGCXX sigc++-2.0 QUIET)

set(SIGCXX_VERSION ${PC_SIGCXX_VERSION})

find_path(SIGCXX_INCLUDE_DIR
  NAMES
    sigc++/sigc++.h
  HINTS
    ${PC_SIGCXX_INCLUDEDIR}
    ${PC_SIGCXX_INCLUDE_DIRS}
  PATH_SUFFIXES
    sigc++
)

find_library(SIGCXX_LIBRARY
  NAMES
    sigc-2.0
  HINTS
    ${PC_SIGCXX_LIBDIR}
    ${PC_SIGCXX_LIBRARY_DIRS}
)

find_package_handle_standard_args(sigcxx
  DEFAULT_MSG
  SIGCXX_VERSION
  SIGCXX_INCLUDE_DIR
  SIGCXX_LIBRARY
)

message("SIGCXX_INCLUDE_DIR ${SIGCXX_INCLUDE_DIR}")
message("SIGCXX_LIBRARY     ${SIGCXX_LIBRARY}")

if (sigcxx_FOUND)
  set(SIGCXX_INCLUDE_DIRS
    ${SIGCXX_INCLUDE_DIR}
  )

  set(SIGCXX_LIBRARY
    ${SIGCXX_LIBRARIES}
  )

  mark_as_advanced(
    SIGCXX_VERSION
    SIGCXX_INCLUDE_DIR
    SIGCXX_LIBRARY
  )
endif()
