include(FindPackageHandleStandardArgs)

find_package(PkgConfig QUIET)
pkg_check_modules(PC_DBUS dbus-1 QUIET)

set(DBUS_VERSION ${PC_DBUS_VERSION})

find_path(DBUS_INCLUDE_DIR
  NAMES
    dbus/dbus.h
  HINTS
    ${PC_DBUS_INCLUDEDIR}
    ${PC_DBUS_INCLUDE_DIRS}
  PATH_SUFFIXES
    dbus-1.0
)

find_path(DBUS_CONFIG_INCLUDE_DIR
  NAMES
    dbus/dbus-arch-deps.h
  HINTS
    ${PC_DBUS_LIBDIR}
    ${PC_DBUS_LIBRARY_DIRS}
  PATH_SUFFIXES
    dbus-1.0/include
)

find_library(DBUS_LIBRARY
  NAMES
    dbus-1
  HINTS
    ${PC_DBUS_LIBDIR}
    ${PC_DBUS_LIBRARY_DIRS}
)

find_package_handle_standard_args(DBus
  DEFAULT_MSG
  DBUS_VERSION
  DBUS_INCLUDE_DIR
  DBUS_CONFIG_INCLUDE_DIR
  DBUS_LIBRARY
)

if (DBus_FOUND)
  set(DBUS_INCLUDE_DIRS
    ${DBUS_INCLUDE_DIR}
    ${DBUS_INCLUDE_DIR}/dbus
    ${DBUS_CONFIG_INCLUDE_DIR}
    ${DBUS_CONFIG_INCLUDE_DIR}/dbus
  )

  set(DBUS_LIBRARIES
    ${DBUS_LIBRARY}
  )

  mark_as_advanced(
    DBUS_VERSION
    DBUS_INCLUDE_DIR
    DBUS_CONFIG_INCLUDE_DIR
    DBUS_INCLUDE_DIRS
    DBUS_LIBRARY
    DBUS_LIBRARIES
  )
endif()
