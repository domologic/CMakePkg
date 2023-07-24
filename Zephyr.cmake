include_guard(GLOBAL)

macro(_zephyr_init_parse_args)
  cmake_parse_arguments(ARG
    ""
    "CONDITION"
    "CONFIG;BOARD_ROOT;DEVICETREE_ROOT;DEVICETREE_OVERLAY;COMPILE_DEFINITIONS"
    ${ARGN}
  )
endmacro()

macro(_zephyr_init_condition)
  # split on equal comparison operator
  string(REPLACE "==" ";" CONDITION ${ARGN})

  # get left and right operands
  list(GET CONDITION 0 LHS)
  list(GET CONDITION 1 RHS)

  # exit from scope if both operands are not equal
  if (NOT ${LHS} STREQUAL ${RHS})
    return()
  endif()
endmacro()

function(_zephyr_init_config)
  foreach (CONFIG IN LISTS ARGN)
    # split config on equal sign
    string(REPLACE "=" ";" CONFIG ${CONFIG})

    # extract key and value
    list(GET CONFIG 0 CONFIG_KEY)
    list(GET CONFIG 1 CONFIG_VAL)

    # normalize bool values for Kconfig
    if (${CONFIG_VAL} STREQUAL "ON")
      set(CONFIG_VAL y)
    elseif(${CONFIG_VAL} STREQUAL "OFF")
      set(CONFIG_VAL n)
    endif()

    # set config to cmake cache
    set(${CONFIG_KEY} ${CONFIG_VAL} CACHE INTERNAL "" FORCE)
    set(CONFIG_${CONFIG_KEY} ${CONFIG_VAL} CACHE INTERNAL "" FORCE)
  endforeach()
endfunction()

macro(_zephyr_init_board_root)
  set(BOARD_ROOT ${ARGN})
endmacro()

macro(_zephyr_init_devicetree_root)
  set(DTS_ROOT ${ARGN})
endmacro()

macro(_zephyr_init_devicetree_overlay)
  set(DTC_OVERLAY_FILE ${ARGN})
endmacro()

#
# Initializes the Zephyr SDK.
#
# zephyr_init(<board>
#   [CONFIG <KEY=value...>]
# )
#
# <board> Configures the Zephyr SDK for the specified board.
#
# CONFIG
#   One or more key value pairs used to configure the Zephyr SDK.
#   Each entry should not contain any spaces and should separate the key from value with an equal sign.
#
function(zephyr_init BOARD)
  # parse args
  _zephyr_init_parse_args(${ARGN})

  # check if condition is specified and true
  if (ARG_CONDITION)
    _zephyr_init_condition(${ARG_CONDITION})
  endif()

  # init Zephyr configuration
  if (ARG_CONFIG)
    _zephyr_init_config(${ARG_CONFIG})
  endif()

  # set board root
  if (ARG_BOARD_ROOT)
    _zephyr_init_board_root(${ARG_BOARD_ROOT})
  endif()

  # set device tree root
  if (ARG_DEVICETREE_ROOT)
    _zephyr_init_devicetree_root(${ARG_DEVICETREE_ROOT})
  endif()

  # add device tree overlay files
  if (ARG_DEVICETREE_OVERLAY)
    _zephyr_init_devicetree_overlay(${ARG_DEVICETREE_OVERLAY})
  endif()

  # enable Zephyr build
  set(ZEPHYR ON CACHE BOOL "True when the target system is Zephyr")

  # set options for Zephyr
  set(NO_BUILD_TYPE_WARNING     ON)
  set(ZEPHYR_TOOLCHAIN_VARIANT  zephyr)

  # load Zephyr
  find_package(Zephyr REQUIRED)

  # add compile definitions
  if (ARG_COMPILE_DEFINITIONS)
    zephyr_compile_definitions(${ARG_COMPILE_DEFINITIONS})
  endif()
endfunction()

#
# Defines a Zephyr application target.
#
# zephyr_app(<name>
#   [SOURCE_DIR]
#   [SOURCES]
#   [COMPILE_DEFINITIONS]
#   [COMPILE_FEATURES]
#   [COMPILE_OPTIONS]
#   [INCLUDE_DIRECTORIES]
#   [LINK_DIRECTORIES]
#   [LINK_LIBRARIES]
#   [LINK_OPTIONS]
#   [PROPERTIES]
#   [DEPENDENCIES]
# )
#
# <name>
#   Name of the executable target if the application should not be built with Zephyr.
#
# SOURCE_DIR
#   Path to the directory to collect source files from.
# SOURCES
#   List of source files to include.
# COMPILE_DEFINITIONS
#   See target_compile_definitions function.
# COMPILE_FEATURES
#   See target_compile_features function.
# COMPILE_OPTIONS
#   See target_compile_options function.
# INCLUDE_DIRECTORIES
#   See target_include_directories function.
# LINK_DIRECTORIES
#   See target_link_directories function.
# LINK_LIBRARIES
#   See target_link_libraries function.
# PROPERTIES
#   See set_target_properties function.
# DEPENDENCIES
#   List of dependencies described as <group>::<project> which will be downloaded from git and included in the build process.
#
function(zephyr_app PACKAGE_NAME)
  # check if Zephyr build is enabled
  if (ZEPHYR)
    # set package name
    set(PACKAGE_NAME app)

    # parse arguments
    _add_package_parse_args(${ARGN})

    # collect sources
    _add_package_collect_sources()

    # add sources
    target_sources(${PACKAGE_NAME}
      PRIVATE
        ${ARG_SOURCES}
        ${${PACKAGE_NAME}_SOURCES}
    )

    # add generic module
    _add_package()
  else()
    # build as regular executable
    add_package_executable(${PACKAGE_NAME} ${ARGN})
  endif()
endfunction()

#
# Defines a post build python task.
#
# zephyr_post_build(<script>
#   [ARGS]
#   [COMMENT]
# )
#
# <script>
#   Name of the script file.
#
# ARGS
#   Arguments that should be passed to the script.
# COMMENT
#  Optional comment that describes the post build task.
#
function(zephyr_post_build SCRIPT)
  cmake_parse_arguments(ARG
    ""
    "COMMENT"
    "ARGS"
    ${ARGN}
  )

  if (ZEPHYR)
    add_custom_target(zephyr_post_build_${SCRIPT} ALL
      DEPENDS
        zephyr_final
      COMMAND
        python ${CMAKE_CURRENT_SOURCE_DIR}/scripts/${SCRIPT}.py ${ARG_ARGS}
      COMMENT
        ${ARG_COMMENT}
    )
  endif()
endfunction()
