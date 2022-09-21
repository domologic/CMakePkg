#
# Provides a wrapper facility which enables the usage of external git repositories for dependency resolution.
# Each dependency will be downloaded from git and included in the root project.
#
# Following functions are available to use:
#   add_package_library
#   add_package_executable
#   add_package_test
#   add_package_docs
#

set(COMMITID_FILE_MARKER_BEGIN "---COMMITID BEGIN---" CACHE INTERNAL "Begin marker for commit id file.")
set(COMMITID_FILE_MARKER_END   "---COMMITID END---"   CACHE INTERNAL "End marker for commit id file.")

macro(_add_package_parse_args)
  set(_MULTI_VALUE_ARGS
    SOURCE_DIR
    SOURCES
    COMPILE_DEFINITIONS
    COMPILE_FEATURES
    COMPILE_OPTIONS
    INCLUDE_DIRECTORIES
    LINK_DIRECTORIES
    LINK_LIBRARIES
    LINK_OPTIONS
    PROPERTIES
    DEPENDENCIES
    RESOURCES
    OBJCOPY
    DOT
  )
  cmake_parse_arguments(ARG
    ""
    ""
    "${_MULTI_VALUE_ARGS}"
    ${ARGN}
  )
endmacro()

function(_add_package_set_root)
  # set root package in cache if not already set and load commit id file
  if (NOT DEFINED CACHE{CMAKEPKG_ROOT_PACKAGE})
    set(CMAKEPKG_ROOT_PACKAGE ${PACKAGE_NAME} CACHE INTERNAL "Name of the CMakePkg root package.")
    _add_package_load_commitid_file()
  endif()
endfunction()

function(_add_package_load_commitid_file)
  # do nothing if no commit id file was specified
  if (NOT DEFINED CMAKEPKG_COMMITID_FILE)
    return()
  endif()

  # check if specified commit id file exists
  if (NOT EXISTS ${CMAKEPKG_COMMITID_FILE})
    message(WARNING "Commit id file '${CMAKEPKG_COMMITID_FILE}' does not exist!")
    return()
  endif()

  # split commit id file to lines
  message(STATUS "Loading commit id File '${CMAKEPKG_COMMITID_FILE}'")
  file(STRINGS ${CMAKEPKG_COMMITID_FILE} CMAKEPKG_COMMITIDS REGEX "^[ ]*[^#].*")

  # iterate over each line in the commit id file
  set(COMMITID_BEGIN OFF)
  foreach (LINE IN LISTS CMAKEPKG_COMMITIDS)
    # check if commit id segment was detected
    if (NOT COMMITID_BEGIN)
      # if the segment was not detected check if the line contains the begin marker
      if ("${LINE}" STREQUAL "${COMMITID_FILE_MARKER_BEGIN}")
        set(COMMITID_BEGIN ON)
      endif()
      continue()
    else()
      # if the segment was detected check if line contains the end marker
      if ("${LINE}" STREQUAL "${COMMITID_FILE_MARKER_END}")
        return()
      endif()
    endif()

    # remove any whitespaces
    string(REPLACE " " "" EXPR "${LINE}")

    # split the line on colon symbol
    string(REPLACE ":" ";" EXPR "${EXPR}")
    list(GET EXPR 0 PACKAGE_ID)
    list(GET EXPR 1 PACKAGE_COMMITID)

    # get package id usable in cmake
    string(REPLACE "/" ";" PACKAGE_ID "${PACKAGE_ID}")
    list(GET PACKAGE_ID -1 PACKAGE_ID)

    # set package commit id to cache
	message(STATUS "  Package ${PACKAGE_ID}: ${PACKAGE_COMMITID}")
    set("${PACKAGE_ID}_COMMITID" "${PACKAGE_COMMITID}" CACHE INTERNAL "Revision of the ${PACKAGE_ID} package")
  endforeach()
endfunction()

function(_add_package_generate_commitid_file)
  # do nothing if the current package is not root
  if (NOT ${CMAKEPKG_ROOT_PACKAGE} STREQUAL ${PACKAGE_NAME})
    return()
  endif()

  # set the commit id file path if its missing
  if (NOT DEFINED CMAKEPKG_COMMITID_OUT_FILE)
    set(CMAKEPKG_COMMITID_OUT_FILE ${CMAKE_BINARY_DIR}/CMakePkgCommitIds)
  endif()

  # delete the commit id file if it already exists
  if (EXISTS ${CMAKEPKG_COMMITID_OUT_FILE})
    file(REMOVE ${CMAKEPKG_COMMITID_OUT_FILE})
  endif()

  # write the begin marker
  file(APPEND ${CMAKEPKG_COMMITID_OUT_FILE} "${COMMITID_FILE_MARKER_BEGIN}\n")

  # iterate over all known packages
  foreach(PACKAGE ${CMAKEPKG_PACKAGE_LIST})
    string(REPLACE "/" ";" PACKAGE_ID "${PACKAGE}")
    list(GET PACKAGE_ID -1 PACKAGE_ID)

    execute_process(
      COMMAND
        "${GIT_EXECUTABLE}" rev-parse HEAD
      WORKING_DIRECTORY
        "${${PACKAGE_ID}_SOURCE_DIR}"
      OUTPUT_VARIABLE
        PACKAGE_COMMITID
      OUTPUT_STRIP_TRAILING_WHITESPACE
      ERROR_QUIET
    )

    # append the package to the commit id file
    file(APPEND ${CMAKEPKG_COMMITID_OUT_FILE} "${PACKAGE}: ${PACKAGE_COMMITID}\n")
  endforeach()

  # write the end marker
  file(APPEND ${CMAKEPKG_COMMITID_OUT_FILE} "${COMMITID_FILE_MARKER_END}")
endfunction()

macro(_add_package_enable_tests)
  set(DEFINES_BUILD_UNIT_TESTS BUILD_UNIT_TESTS)
endmacro()

function(_add_package_generate_revision PACKAGE_NAME_ORIG)
  # Create C++ compatible name of this package, used by the template Revision.hpp.cmake
  string(REGEX REPLACE "-" "_" PACKAGE_NAME "${PACKAGE_NAME_ORIG}") 

  set(PACKAGE_VERSION   "unknown")
  set(PACKAGE_REVISION  "unknown")
  set(PACKAGE_TIMESTAMP "1970-01-01 00:00:00 +0000")
  set(PACKAGE_DATE      "19700101")
  set(PACKAGE_YEAR      "1970")

  # PACKAGE_VERSION is the version tag
  execute_process(
    COMMAND
      ${GIT_EXECUTABLE} tag --points-at HEAD
    WORKING_DIRECTORY
      ${CMAKE_SOURCE_DIR}
    OUTPUT_VARIABLE
      PACKAGE_VERSION
    OUTPUT_STRIP_TRAILING_WHITESPACE
  )

  # PACKAGE_REVISION is the short hash of the latest commit
  execute_process(
    COMMAND
      ${GIT_EXECUTABLE} rev-parse --short HEAD
    WORKING_DIRECTORY
      ${PROJECT_SOURCE_DIR}
    OUTPUT_VARIABLE
      PACKAGE_REVISION
    OUTPUT_STRIP_TRAILING_WHITESPACE
    ERROR_QUIET
  )

  # PACKAGE_TIMESTAMP is the date of the last commit
  execute_process(
    COMMAND
      ${GIT_EXECUTABLE} show -s --format=%ci
    WORKING_DIRECTORY
      ${PROJECT_SOURCE_DIR}
    OUTPUT_VARIABLE
      PACKAGE_TIMESTAMP
    OUTPUT_STRIP_TRAILING_WHITESPACE
    ERROR_QUIET
  )

  # PACKAGE_DATE is the date of the last commit
  execute_process(
    COMMAND
      ${GIT_EXECUTABLE} show -s --format=%cd --date=short
    WORKING_DIRECTORY
      ${PROJECT_SOURCE_DIR}
    OUTPUT_VARIABLE
      PACKAGE_DATE
    OUTPUT_STRIP_TRAILING_WHITESPACE
    ERROR_QUIET
  )

  # PACKAGE_YEAR is the year of the last commit
  string(REGEX REPLACE "-" "" PACKAGE_DATE "${PACKAGE_DATE}")
  string(SUBSTRING "${PACKAGE_DATE}" 0 4 PACKAGE_YEAR)

  # fix package version if not version is available from git history
  if ("${PACKAGE_VERSION}" STREQUAL "unknown" OR "${PACKAGE_VERSION}" STREQUAL "")
    set(PACKAGE_VERSION ${PACKAGE_REVISION})
  endif()

  # generate version info file
  if (${CMAKEPKG_ROOT_PACKAGE} STREQUAL ${PACKAGE_NAME_ORIG})
    file(WRITE ${CMAKE_BINARY_DIR}/Version ${PACKAGE_VERSION})
  endif()

  # generate revision file
  configure_file(
    ${CMAKEPKG_SOURCE_DIR}/Revision.hpp.cmake
    ${CMAKE_BINARY_DIR}/Revision/${PACKAGE_NAME_ORIG}/Revision.hpp
    @ONLY
  )

  message(STATUS "Loaded package ${PACKAGE_NAME_ORIG} ${PACKAGE_VERSION} ${PACKAGE_TIMESTAMP}")
endfunction()

function(_add_package_collect_source_files CURRENT_DIR VARIABLE)
  list(FIND ARGN "${CURRENT_DIR}" IS_EXCLUDED)
  if (IS_EXCLUDED EQUAL -1)
    file(GLOB COLLECTED_SOURCES
      ${CURRENT_DIR}/*.c
      ${CURRENT_DIR}/*.cpp
      ${CURRENT_DIR}/*.cxx
      ${CURRENT_DIR}/*.c++
      ${CURRENT_DIR}/*.cc
      ${CURRENT_DIR}/*.h
      ${CURRENT_DIR}/*.hpp
      ${CURRENT_DIR}/*.hxx
      ${CURRENT_DIR}/*.h++
      ${CURRENT_DIR}/*.hh
      ${CURRENT_DIR}/*.inl
      ${CURRENT_DIR}/*.inc
      ${CURRENT_DIR}/*.inl.hpp
      ${CURRENT_DIR}/*.inc.hpp
    )
    list(APPEND ${VARIABLE} ${COLLECTED_SOURCES})

    file(GLOB SUB_DIRECTORIES ${CURRENT_DIR}/*)
    foreach(SUB_DIRECTORY ${SUB_DIRECTORIES})
      if (IS_DIRECTORY ${SUB_DIRECTORY})
        _add_package_collect_source_files(${SUB_DIRECTORY} ${VARIABLE} ${ARGN})
      endif()
    endforeach()
    set(${VARIABLE} ${${VARIABLE}} PARENT_SCOPE)
  endif()
endfunction()

function(_add_package_load_dependency PACKAGE)
  # split PACKAGE into path and tag
  string(REPLACE "@" ";" PACKAGE_DATA "${PACKAGE}")

  # get package path
  list(GET PACKAGE_DATA 0 PACKAGE_PATH)
  string(REGEX REPLACE "::|\/" "\/" PACKAGE_PATH "${PACKAGE_PATH}")

  # get package id
  list(GET PACKAGE_DATA 0 PACKAGE_ID)
  string(REGEX REPLACE "::|\/" ";" PACKAGE_ID "${PACKAGE_ID}")
  list(GET PACKAGE_ID -1 PACKAGE_ID)

  # set package git url
  set(PACKAGE_URL ${CMAKEPKG_GIT_ROOT}/${PACKAGE_PATH}.git)

  # get package tag
  if (DEFINED ${PACKAGE_ID}_COMMITID)
    set(PACKAGE_COMMITID "${${PACKAGE_ID}_COMMITID}")
  else()
    list(LENGTH PACKAGE_DATA PACKAGE_DATA_LENGTH)
    if (PACKAGE_DATA_LENGTH EQUAL 2)
      list(GET PACKAGE_DATA 1 PACKAGE_COMMITID)
    else()
      set(PACKAGE_COMMITID master)
    endif()
  endif()

  # get md5 of the package path
  string(MD5 PACKAGE_PATH_HASH "${PACKAGE_PATH}")

  # set package path if not already specified
  if (NOT DEFINED ${PACKAGE_ID}_PATH)
    set(${PACKAGE_ID}_PATH ${CMAKE_BINARY_DIR}/deps/${PACKAGE_PATH_HASH})
  endif()

  # download the package if the path does not exist
  if (NOT EXISTS ${${PACKAGE_ID}_PATH})
    message(STATUS "Loading package ${PACKAGE} using commit id ${PACKAGE_COMMITID}...")

    # try shallow clone on given package tag
    execute_process(
      COMMAND
        ${GIT_EXECUTABLE} clone -b ${PACKAGE_COMMITID} --depth 1 ${PACKAGE_URL} --quiet ${${PACKAGE_ID}_PATH}
      RESULT_VARIABLE
        RESULT
      OUTPUT_QUIET
      ERROR_QUIET
    )

    # clone the complete repository to checkout the requested tag if shallow clone fails because the requested tag does not point to a git branch or git tag
    if (NOT ${RESULT} EQUAL "0")
      execute_process(
        COMMAND
          ${GIT_EXECUTABLE} clone ${PACKAGE_URL} --quiet ${${PACKAGE_ID}_PATH}
        RESULT_VARIABLE
          RESULT
        OUTPUT_QUIET
        ERROR_QUIET
      )

      if (NOT ${RESULT} EQUAL "0")
        message(FATAL_ERROR "Could not clone '${PACKAGE}' from '${PACKAGE_URL}'.")
      else()
        execute_process(
          COMMAND
            ${GIT_EXECUTABLE} checkout -b ${PACKAGE_COMMITID} ${PACKAGE_COMMITID}
          WORKING_DIRECTORY
            ${${PACKAGE_ID}_PATH}
          RESULT_VARIABLE
            RESULT
          OUTPUT_QUIET
          ERROR_QUIET
        )

        if (NOT ${RESULT} EQUAL "0")
          message(FATAL_ERROR "Could not checkout '${PACKAGE_COMMITID}' for package '${PACKAGE}' from '${PACKAGE_URL}'")
        endif()
      endif()
    endif()
  endif()

  # load the package if not already loaded
  if (NOT TARGET ${PACKAGE_ID})
    add_subdirectory(${${PACKAGE_ID}_PATH} ${CMAKE_BINARY_DIR}/depsb/${PACKAGE_PATH_HASH})

    # append the package to the package list
    set(PACKAGE_LIST
      ${CMAKEPKG_PACKAGE_LIST}
      ${PACKAGE_PATH}
    )
    list(SORT PACKAGE_LIST COMPARE STRING)
    list(REMOVE_DUPLICATES PACKAGE_LIST)
    set(CMAKEPKG_PACKAGE_LIST ${PACKAGE_LIST} CACHE INTERNAL "All dependencies requested with CMakePkg" FORCE)
  endif()
endfunction()

function(_add_package_load_dependencies)
  # parse args
  cmake_parse_arguments(DEPENDENCY_LIST
    ""
    ""
    "PUBLIC;PRIVATE;INTERFACE"
    ${ARGN}
  )

  # load public dependencies
  foreach(DEPENDENCY ${DEPENDENCY_LIST_PUBLIC})
    _add_package_load_dependency(${DEPENDENCY})
  endforeach()

  # load private dependencies
  foreach(DEPENDENCY ${DEPENDENCY_LIST_PRIVATE})
    _add_package_load_dependency(${DEPENDENCY})
  endforeach()

  # load interface dependencies
  foreach(DEPENDENCY ${DEPENDENCY_LIST_INTERFACE})
    _add_package_load_dependency(${DEPENDENCY})
  endforeach()

  # load dependencies with unspecified visibility
  foreach(DEPENDENCY ${DEPENDENCY_LIST_UNPARSED_ARGUMENTS})
    _add_package_load_dependency(${DEPENDENCY})
  endforeach()
endfunction()

function(_add_package_collect_sources)
  if (ARG_SOURCE_DIR)
    cmake_parse_arguments(SOURCE_DIR
      ""
      "PATH"
      "EXCLUDE"
      ${ARG_SOURCE_DIR}
    )

    _add_package_collect_source_files(${SOURCE_DIR_PATH} ${PACKAGE_NAME}_SOURCES ${SOURCE_DIR_EXCLUDE})
    set(${PACKAGE_NAME}_SOURCES "${${PACKAGE_NAME}_SOURCES}" PARENT_SCOPE)
  endif()
endfunction()

function(_convert_dependencies_to_libraries DEPENDENCIES VARIABLE)
  set(RESULT "")
  foreach (DEPENDENCY ${DEPENDENCIES})
    # remove @branch
    string(REPLACE "@" ";" DEPENDENCY ${DEPENDENCY})
    list(LENGTH DEPENDENCY DEPENDENCY_LEN)
    if (DEPENDENCY_LEN GREATER 1)
      list(GET DEPENDENCY 0 DEPENDENCY)
    endif()

    # both separators "::" and "/" are supported
    string(REGEX REPLACE "::|\/" ";" DEPENDENCY ${DEPENDENCY})
    list(LENGTH DEPENDENCY DEPENDENCY_LEN)
    if (DEPENDENCY_LEN GREATER 1)
      list(GET DEPENDENCY -1 DEPENDENCY)
    endif()

    # add dependency to result
    list(APPEND RESULT ${DEPENDENCY})
  endforeach()

  # return result
  if (RESULT)
    if (${VARIABLE})
      set(${VARIABLE} "${VARIABLE};${RESULT}" PARENT_SCOPE)
    else()
      set(${VARIABLE} ${RESULT} PARENT_SCOPE)
    endif()
  endif()
endfunction()

macro(_add_package_link_libraries)
  # parse arguments
  cmake_parse_arguments(LIBRARY_LIST
    ""
    ""
    "PUBLIC;PRIVATE;INTERFACE"
    ${ARG_LINK_LIBRARIES}
  )

  # parse sub arguments
  cmake_parse_arguments(DEPENDENCY_LIST
    ""
    ""
    "PUBLIC;PRIVATE;INTERFACE"
    ${ARG_DEPENDENCIES}
  )

  # convert dependencies to libraries
  _convert_dependencies_to_libraries("${DEPENDENCY_LIST_PUBLIC}"              DEPENDENCIES_PUBLIC)
  _convert_dependencies_to_libraries("${DEPENDENCY_LIST_PRIVATE}"             DEPENDENCIES_PRIVATE)
  _convert_dependencies_to_libraries("${DEPENDENCY_LIST_INTERFACE}"           DEPENDENCIES_INTERFACE)
  _convert_dependencies_to_libraries("${DEPENDENCY_LIST_UNPARSED_ARGUMENTS}"  DEPENDENCIES_PUBLIC)

  # adjust parameters
  if (LIBRARY_LIST_PUBLIC)
    set(LIBRARIES_PUBLIC "PUBLIC;${LIBRARY_LIST_PUBLIC}")
  endif()
  if (LIBRARY_LIST_PRIVATE)
    set(LIBRARIES_PRIVATE "PRIVATE;${LIBRARY_LIST_PRIVATE}")
  endif()
  if (LIBRARY_LIST_INTERFACE)
    set(LIBRARIES_INTERFACE "INTERFACE;${LIBRARY_LIST_INTERFACE}")
  endif()
  if (DEPENDENCIES_PUBLIC)
    set(DEPENDENCIES_PUBLIC "PUBLIC;${DEPENDENCIES_PUBLIC}")
  endif()
  if (DEPENDENCIES_PRIVATE)
    set(DEPENDENCIES_PRIVATE "PRIVATE;${DEPENDENCIES_PRIVATE}")
  endif()
  if (DEPENDENCIES_INTERFACE)
    set(DEPENDENCIES_INTERFACE "INTERFACE;${DEPENDENCIES_INTERFACE}")
  endif()

  # link libraries
  target_link_libraries(${PACKAGE_NAME}
    ${LIBRARIES_PUBLIC}
    ${LIBRARIES_PRIVATE}
    ${LIBRARIES_INTERFACE}
    ${DEPENDENCIES_PUBLIC}
    ${DEPENDENCIES_PRIVATE}
    ${DEPENDENCIES_INTERFACE}
  )
endmacro()

macro(_add_package_load_compiler_config)
  # set the config if not already set
  if (NOT DEFINED CMAKEPKG_COMPILER_CONFIG)
    set(CMAKEPKG_COMPILER_CONFIG ${CMAKE_SYSTEM_NAME}::${CMAKE_SYSTEM_PROCESSOR} CACHE INTERNAL "CMakePkg compiler configuration.")
  endif()

  # check if the config was already loaded
  if (NOT DEFINED CMAKEPKG_COMPILER_CONFIG_LOADED)
    # normalize config name to file path
    string(REPLACE "::" "_" CMAKEPKG_COMPILER_CONFIG_FILE ${CMAKEPKG_COMPILER_CONFIG})
    set(COMPILER_CONFIG_FILE ${CMAKEPKG_SOURCE_DIR}/Compiler/${CMAKEPKG_COMPILER_CONFIG_FILE}.cmake)

    # load the config file if it exists
    if (EXISTS ${COMPILER_CONFIG_FILE})
      message(STATUS "Loading ${CMAKEPKG_COMPILER_CONFIG} configuration")
      include(${COMPILER_CONFIG_FILE})
    endif()

    # set config loaded flag
    set(CMAKEPKG_COMPILER_CONFIG_LOADED ON CACHE INTERNAL "CMakePkg compiler configuration loaded.")
  endif()
endmacro()

macro(_add_package)
  _add_package_set_root()

  if (NOT "${PACKAGE_TYPE}" STREQUAL "INTERFACE")
    target_compile_definitions(${PACKAGE_NAME}
      PRIVATE
        $<$<BOOL:"${CMAKEPKG_DEFINE}">:${CMAKEPKG_DEFINE}>
        $<$<AND:$<BOOL:"${CMAKEPKG_DEFINE_DEBUG}">,$<CONFIG:Debug>>:${CMAKEPKG_DEFINE_DEBUG}>
        $<$<AND:$<BOOL:"${CMAKEPKG_DEFINE_RELEASE}">,$<CONFIG:Release>>:${CMAKEPKG_DEFINE_RELEASE}>
        ${DEFINES_BUILD_UNIT_TESTS}
    )
    target_compile_options(${PACKAGE_NAME}
      PRIVATE
        $<$<AND:$<BOOL:"${CMAKEPKG_FLAGS}">,$<OR:$<COMPILE_LANGUAGE:C>,$<COMPILE_LANGUAGE:CXX>>>:${CMAKEPKG_FLAGS}>
        $<$<AND:$<BOOL:"${CMAKEPKG_FLAGS_DEBUG}">,$<OR:$<COMPILE_LANGUAGE:C>,$<COMPILE_LANGUAGE:CXX>>,$<CONFIG:Debug>>:${CMAKEPKG_FLAGS_DEBUG}>
        $<$<AND:$<BOOL:"${CMAKEPKG_FLAGS_RELEASE}">,$<OR:$<COMPILE_LANGUAGE:C>,$<COMPILE_LANGUAGE:CXX>>,$<CONFIG:Release>>:${CMAKEPKG_FLAGS_RELEASE}>
        $<$<AND:$<BOOL:"${CMAKEPKG_FLAGS_C}">,$<COMPILE_LANGUAGE:C>>:${CMAKEPKG_FLAGS_C}>
        $<$<AND:$<BOOL:"${CMAKEPKG_FLAGS_C_DEBUG}">,$<COMPILE_LANGUAGE:C>,$<CONFIG:Debug>>:${CMAKEPKG_FLAGS_C_DEBUG}>
        $<$<AND:$<BOOL:"${CMAKEPKG_FLAGS_C_RELEASE}">,$<COMPILE_LANGUAGE:C>,$<CONFIG:Release>>:${CMAKEPKG_FLAGS_C_RELEASE}>
        $<$<AND:$<BOOL:"${CMAKEPKG_FLAGS_CXX}">,$<COMPILE_LANGUAGE:CXX>>:${CMAKEPKG_FLAGS_CXX}>
        $<$<AND:$<BOOL:"${CMAKEPKG_FLAGS_CXX_DEBUG}">,$<COMPILE_LANGUAGE:CXX>,$<CONFIG:Debug>>:${CMAKEPKG_FLAGS_CXX_DEBUG}>
        $<$<AND:$<BOOL:"${CMAKEPKG_FLAGS_CXX_RELEASE}">,$<COMPILE_LANGUAGE:CXX>,$<CONFIG:Release>>:${CMAKEPKG_FLAGS_CXX_RELEASE}>
    )
    target_link_options(${PACKAGE_NAME}
      PRIVATE
        $<$<BOOL:"${CMAKEPKG_LINK}">:${CMAKEPKG_LINK}>
        $<$<AND:$<BOOL:"${CMAKEPKG_LINK_DEBUG}">,$<CONFIG:Debug>>:${CMAKEPKG_LINK_DEBUG}>
        $<$<AND:$<BOOL:"${CMAKEPKG_LINK_RELEASE}">,$<CONFIG:Release>>:${CMAKEPKG_LINK_RELEASE}>
    )
    set_target_properties(${PACKAGE_NAME}
      PROPERTIES
        LIBRARY_OUTPUT_DIRECTORY ${CMAKE_INSTALL_PREFIX}
        RUNTIME_OUTPUT_DIRECTORY ${CMAKE_INSTALL_PREFIX}
    )
    target_include_directories(${PACKAGE_NAME}
      PUBLIC
        ${CMAKE_BINARY_DIR}/Revision
    )
  else()
    target_include_directories(${PACKAGE_NAME}
      INTERFACE
        ${CMAKE_BINARY_DIR}/Revision
    )
  endif()

  _add_package_load_dependencies(${ARG_DEPENDENCIES})
  _add_package_link_libraries(${ARG_LINK_LIBRARIES} ${ARG_DEPENDENCIES})

  if (ARG_COMPILE_DEFINITIONS)
    target_compile_definitions(${PACKAGE_NAME}
      ${ARG_COMPILE_DEFINITIONS}
    )
  endif()

  if (ARG_COMPILE_OPTIONS)
    target_compile_options(${PACKAGE_NAME}
      ${ARG_COMPILE_OPTIONS}
    )
  endif()

  if (ARG_LINK_OPTIONS)
    target_link_options(${PACKAGE_NAME}
      ${ARG_LINK_OPTIONS}
    )
  endif()

  if (ARG_COMPILE_FEATURES)
    target_compile_features(${PACKAGE_NAME}
      ${ARG_COMPILE_FEATURES}
    )
  endif()

  if (ARG_INCLUDE_DIRECTORIES)
    target_include_directories(${PACKAGE_NAME}
      ${ARG_INCLUDE_DIRECTORIES}
    )
  endif()

  if (ARG_LINK_DIRECTORIES)
    target_link_directories(${PACKAGE_NAME}
      ${ARG_LINK_DIRECTORIES}
    )
  endif()

  if (ARG_PROPERTIES)
    set_target_properties(${PACKAGE_NAME}
      PROPERTIES
        ${ARG_PROPERTIES}
    )
  endif()

  if (ARG_RESOURCES)
    foreach (RESOURCE ${ARG_RESOURCES})
      if (IS_DIRECTORY ${RESOURCE})
        add_custom_command(TARGET ${PACKAGE_NAME} POST_BUILD COMMAND ${CMAKE_COMMAND} -E copy_directory ${RESOURCE} ${CMAKE_INSTALL_PREFIX})
      else()
        add_custom_command(TARGET ${PACKAGE_NAME} POST_BUILD COMMAND ${CMAKE_COMMAND} -E copy           ${RESOURCE} ${CMAKE_INSTALL_PREFIX})
      endif()
    endforeach()
  endif()

  if (ARG_OBJCOPY)
    target_objcopy(${PACKAGE_NAME}
      ${ARG_OBJCOPY}
    )
  endif()

  if (ARG_DOT)
    target_dot(${PACKAGE_NAME}
      ${ARG_DOT}
    )
  endif()

  # generate revision file
  _add_package_generate_revision(${PACKAGE_NAME})

  # generate commit id files
  _add_package_generate_commitid_file()
endmacro()

#
# Add a library package to the project using the specified source files.
#
# add_package_library(<name> [STATIC | SHARED | MODULE]
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
#   [RESOURCES]
#   [OBJCOPY]
#   [DOT]
# )
#
# Creates <name> library target with the add_library function.
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
# RESOURCES
#  List of files or directories which will be copied to the binary folder.
# OBJCOPY
#  Generates specified file output types from the target.
# DOT
#  Generates specified dot file from the target.
#
function(add_package_library PACKAGE_NAME PACKAGE_TYPE)
  # parse arguments
  _add_package_parse_args(${ARGN})

  # collect sources
  _add_package_load_compiler_config()

  # check if the library is an interface
  if (${PACKAGE_TYPE} STREQUAL INTERFACE)
    # add interface library
    add_library(${PACKAGE_NAME} INTERFACE)
  else()
    # collect sources
    _add_package_collect_sources()

    # add library
    add_library(${PACKAGE_NAME} ${PACKAGE_TYPE}
      ${ARG_SOURCES}
      ${${PACKAGE_NAME}_SOURCES}
    )
  endif()

  # add generic package
  _add_package()
endfunction()

#
# Add a executable package to the project using the specified source files.
#
# add_package_executable(<name>
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
#   [RESOURCES]
#   [OBJCOPY]
#   [DOT]
# )
#
# Creates <name> executable target with the add_executable function.
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
# RESOURCES
#  List of files or directories which will be copied to the binary folder.
# OBJCOPY
#  Generates specified file output types from the target.
# DOT
#  Generates specified dot file from the target.
#
function(add_package_executable PACKAGE_NAME)
  # parse arguments
  _add_package_parse_args(${ARGN})

  # collect sources
  _add_package_collect_sources()

  # load compiler config
  _add_package_load_compiler_config()

  # add executable
  add_executable(${PACKAGE_NAME}
    ${ARG_SOURCES}
    ${${PACKAGE_NAME}_SOURCES}
  )

  # add generic package
  _add_package()
endfunction()

#
# Add a test to the project to be run by ctest.
#
# add_package_test(<name>
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
#   [RESOURCES]
#   [OBJCOPY]
#   [DOT]
# )
#
# Creates <name> executable target with the add_executable function and includes it as a test with the add_test function.
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
# RESOURCES
#  List of files or directories which will be copied to the binary folder.
# OBJCOPY
#  Generates specified file output types from the target.
# DOT
#  Generates specified dot file from the target.
#
function(add_package_test PACKAGE_NAME)
  # parse arguments
  _add_package_parse_args(${ARGN})

  # enable tests
  _add_package_enable_tests()

  # collect sources
  _add_package_collect_sources()

  # load compiler config
  _add_package_load_compiler_config()

  # add test package executable
  add_executable(${PACKAGE_NAME}
    ${ARG_SOURCES}
    ${${PACKAGE_NAME}_SOURCES}
  )

  # add generic package
  _add_package()

  # add test target
  add_test(
    NAME
      ${PACKAGE_NAME}
    COMMAND
      ${PACKAGE_NAME}
    WORKING_DIRECTORY
      ${CMAKE_INSTALL_PREFIX}
  )
endfunction()

#
# Add a apidocs target for the given package.
#
# add_package_docs(<name>
#   [EXTRA_SOURCES <filesOrDirs...>]
#   [DOXYGEN <config>]
# )
#
# <name> needs to be a valid package created with add_package_library or add_package_executable.
#
# EXTRA_SOURCES
#   List of extra files and directories that should be included.
#
# DOXYGEN
#   Use Doxygen as generator. Currently this is the only option supported.
#
#   <config>
#     List of doxygen parameters used for creating Doxyfile.
#
function(add_package_docs PACKAGE_NAME)
  # load compiler config
  _add_package_load_compiler_config()

  # parse args
  cmake_parse_arguments(ARG
    ""
    ""
    "DOXYGEN;EXTRA_SOURCES"
    ${ARGN}
  )

  # generate Doxygen docs
  if (ARG_DOXYGEN)
    if (NOT DEFINED CACHE{DOXYGEN_EXECUTABLE})
      message(FATAL_ERROR "Failed to generate doxygen project: doxygen was not found!")
    endif()

    # redirect Doxygen options 
    foreach (CONFIG ${ARG_DOXYGEN})
      string(REPLACE "=" ";" CONFIG ${CONFIG})
      list(GET CONFIG 0 KEY)
      list(GET CONFIG 1 VALUE)

      set(DOXYGEN_${KEY} ${VALUE})
    endforeach()

    # set some Doxygen rules
    set(DOXYGEN_OUTPUT_DIRECTORY    "${CMAKE_INSTALL_PREFIX}/docs")
    set(DOXYGEN_CREATE_SUBDIRS      YES)
    set(DOXYGEN_BUILTIN_STL_SUPPORT YES)
    set(DOXYGEN_EXTRACT_ALL         YES)
    set(DOXYGEN_GENERATE_TREEVIEW   YES)

    # get list of source files
    get_target_property(SOURCE_LIST ${PACKAGE_NAME} SOURCES)

    # add Doxygen target
    doxygen_add_docs(${PACKAGE_NAME}-docs
        ${SOURCE_LIST}
        ${ARG_EXTRA_SOURCES}
      WORKING_DIRECTORY
        ${CMAKE_CURRENT_SOURCE_DIR}
      COMMENT
        "Generate doxygen docs for ${PACKAGE_NAME}"
      ALL
    )
  endif()
endfunction()
