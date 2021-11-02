#
# Provides a wrapper facility which enables the usage of external git repositories for dependency resolution.
# Each dependency will be downloaded from git and included in the root project.
#
# Following functions are available to use:
#   add_module_library
#   add_module_executable
#   add_module_test
#   add_module_docs
#

macro(_add_module_parse_args)
  set(_MULTI_OPTIONS
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
  )
  cmake_parse_arguments(ARG
    ""
    ""
    "${_MULTI_OPTIONS}"
    ${ARGN}
  )
endmacro()

function(_add_module_generate_revision module_name)
  # Create C++ compatible name of this module, used by the template Revision.hpp.cmake
  string(REGEX REPLACE "-" "_" MODULE_NAME "${module_name}") 

  set(MODULE_REVISION  "unknown")
  set(MODULE_TAG       "unknown")
  set(MODULE_TIMESTAMP "1970-01-01 00:00:00 +0000")
  set(MODULE_DATE      "19700101")
  set(MODULE_YEAR      "1970")
  set(MODULE_BRANCH    "unknown")

  # MODULE_ORIGIN is the git repository url
  execute_process(
    COMMAND
      ${GIT_EXECUTABLE} remote get-url origin
    WORKING_DIRECTORY
      ${CMAKE_SOURCE_DIR}
    OUTPUT_VARIABLE
      MODULE_ORIGIN
    OUTPUT_STRIP_TRAILING_WHITESPACE
  )

  # MODULE_REVISION is the short hash of the latest commit
  execute_process(
    COMMAND
      ${GIT_EXECUTABLE} rev-parse --short HEAD
    WORKING_DIRECTORY
      ${PROJECT_SOURCE_DIR}
    OUTPUT_VARIABLE
      MODULE_REVISION
    OUTPUT_STRIP_TRAILING_WHITESPACE
    ERROR_QUIET
  )

  # MODULE_TAG is the long hash of the latest commit
  execute_process(
    COMMAND
      ${GIT_EXECUTABLE} rev-parse HEAD
    WORKING_DIRECTORY
      ${PROJECT_SOURCE_DIR}
    OUTPUT_VARIABLE
      MODULE_TAG
    OUTPUT_STRIP_TRAILING_WHITESPACE
    ERROR_QUIET
  )

  # MODULE_TIMESTAMP is the date of the last commit
  execute_process(
    COMMAND
      ${GIT_EXECUTABLE} show -s --format=%ci
    WORKING_DIRECTORY
      ${PROJECT_SOURCE_DIR}
    OUTPUT_VARIABLE
      MODULE_TIMESTAMP
    OUTPUT_STRIP_TRAILING_WHITESPACE
    ERROR_QUIET
  )

  # MODULE_DATE is the date of the last commit
  execute_process(
    COMMAND
      ${GIT_EXECUTABLE} show -s --format=%cd --date=short
    WORKING_DIRECTORY
      ${PROJECT_SOURCE_DIR}
    OUTPUT_VARIABLE
      MODULE_DATE
    OUTPUT_STRIP_TRAILING_WHITESPACE
    ERROR_QUIET
  )

  # MODULE_BRANCH is the name of the current branch
  execute_process(
    COMMAND
      ${GIT_EXECUTABLE} rev-parse --abbrev-ref HEAD
    WORKING_DIRECTORY
      ${PROJECT_SOURCE_DIR}
    OUTPUT_VARIABLE
      MODULE_BRANCH
    OUTPUT_STRIP_TRAILING_WHITESPACE
    ERROR_QUIET
  )

  # fix branch if 
  if ("${MODULE_BRANCH}" STREQUAL "HEAD")
    foreach(PACKAGE ${CMAKEPKG_PACKAGE_LIST})
      set(PACKAGE_TMP_URL ${${PACKAGE}_URL})
      set(PACKAGE_TMP_TAG ${${PACKAGE}_TAG})
      if ("${PACKAGE_TMP_URL}" STREQUAL ${MODULE_ORIGIN})
        if (${PACKAGE_TMP_TAG})
          set(MODULE_BRANCH ${PACKAGE_TMP_TAG})
        else()
          set(MODULE_BRANCH "master")
        endif()
        break()
      endif()
    endforeach()
    if ("${MODULE_BRANCH}" STREQUAL "HEAD")
      set(MODULE_BRANCH "master")
    endif()
  endif()

  # MODULE_YEAR is the year of the last commit
  string(REGEX REPLACE "-" "" MODULE_DATE "${MODULE_DATE}")
  string(SUBSTRING "${MODULE_DATE}" 0 4 MODULE_YEAR)

  # MODULE_VERSION is the project version
  if (EXISTS ${PROJECT_SOURCE_DIR}/version.txt)
    file(READ ${PROJECT_SOURCE_DIR}/version.txt MODULE_VERSION)
    string(REGEX REPLACE "\n$" "" MODULE_VERSION "${MODULE_VERSION}")
  else()
    set(MODULE_VERSION ${PROJECT_VERSION})
  endif()

  configure_file(
    ${CMAKEPKG_SOURCE_DIR}/Revision.hpp.cmake
    ${CMAKE_BINARY_DIR}/Revision/${module_name}/Revision.hpp
    @ONLY
  )
endfunction()

function(_add_module_collect_source_files CURRENT_DIR VARIABLE)
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
        _add_module_collect_source_files(${SUB_DIRECTORY} ${VARIABLE} ${ARGN})
      endif()
    endforeach()
    set(${VARIABLE} ${${VARIABLE}} PARENT_SCOPE)
  endif()
endfunction()

function(_add_module_load_dependency PACKAGE)
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
  set(${PACKAGE_ID}_URL ${PACKAGE_URL} CACHE INTERNAL "${PACKAGE_ID} git repository url")

  # get package tag
  if (DEFINED ${PACKAGE_ID}_TAG)
    set(PACKAGE_TAG "${PACKAGE_ID}_TAG")
  else()
    list(LENGTH PACKAGE_DATA PACKAGE_DATA_LENGTH)
    if (PACKAGE_DATA_LENGTH EQUAL 2)
      list(GET PACKAGE_DATA 1 PACKAGE_TAG)
    else()
      set(PACKAGE_TAG master)
    endif()
    set(${PACKAGE_ID}_TAG ${PACKAGE_TAG} CACHE INTERNAL "${PACKAGE_ID} git repository branch/tag")
  endif()

  FetchContent_Declare(${PACKAGE_ID}
    GIT_REPOSITORY  ${PACKAGE_URL}
    GIT_TAG         ${PACKAGE_TAG}
    GIT_SHALLOW
  )

  if (NOT ${PACKAGE_ID}_LOADED)
    message(STATUS "Loading package ${PACKAGE}...")
    FetchContent_MakeAvailable(${PACKAGE_ID})

    set(CMAKEPKG_PACKAGE_LIST
      ${CMAKEPKG_PACKAGE_LIST}
      ${PACKAGE_ID}
    )
    set(CMAKEPKG_PACKAGE_LIST ${CMAKEPKG_PACKAGE_LIST} CACHE INTERNAL "All dependencies requested with CMakePkg" FORCE)
    set(${PACKAGE_ID}_LOADED  ON                       CACHE INTERNAL "Indicates that the ${PACKAGE_ID} dependency was loaded")
  endif()
endfunction()

function(_add_module_load_dependencies)
  cmake_parse_arguments(DEPENDENCY_LIST
    ""
    ""
    "PUBLIC;PRIVATE;INTERFACE"
    ${ARGN}
  )
  foreach(DEPENDENCY ${DEPENDENCY_LIST_PUBLIC})
    _add_module_load_dependency(${DEPENDENCY})
  endforeach()
  foreach(DEPENDENCY ${DEPENDENCY_LIST_PRIVATE})
    _add_module_load_dependency(${DEPENDENCY})
  endforeach()
  foreach(DEPENDENCY ${DEPENDENCY_LIST_INTERFACE})
    _add_module_load_dependency(${DEPENDENCY})
  endforeach()
  foreach(DEPENDENCY ${DEPENDENCY_LIST_UNPARSED_ARGUMENTS})
    _add_module_load_dependency(${DEPENDENCY})
  endforeach()
endfunction()

function(_add_module_collect_sources)
  if (ARG_SOURCE_DIR)
    cmake_parse_arguments(SOURCE_DIR
      ""
      "PATH"
      "EXCLUDE"
      ${ARG_SOURCE_DIR}
    )

    _add_module_collect_source_files(${SOURCE_DIR_PATH} ${module_name}_SOURCES ${SOURCE_DIR_EXCLUDE})
    set(${module_name}_SOURCES "${${module_name}_SOURCES}" PARENT_SCOPE)
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

macro(_add_module_link_libraries)
  cmake_parse_arguments(LIBRARY_LIST
    ""
    ""
    "PUBLIC;PRIVATE;INTERFACE"
    ${ARG_LINK_LIBRARIES}
  )
  cmake_parse_arguments(DEPENDENCY_LIST
    ""
    ""
    "PUBLIC;PRIVATE;INTERFACE"
    ${ARG_DEPENDENCIES}
  )

  _convert_dependencies_to_libraries("${DEPENDENCY_LIST_PUBLIC}"                  DEPENDENCIES_PUBLIC)
  _convert_dependencies_to_libraries("${DEPENDENCY_LIST_PRIVATE}"                 DEPENDENCIES_PRIVATE)
  _convert_dependencies_to_libraries("${DEPENDENCY_LIST_INTERFACE}"               DEPENDENCIES_INTERFACE)
  _convert_dependencies_to_libraries("${DEPENDENCY_LIST_UNPARSED_ARGUMENTS}"      DEPENDENCIES_PUBLIC)

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

  target_link_libraries(${module_name}
    ${LIBRARIES_PUBLIC}
    ${LIBRARIES_PRIVATE}
    ${LIBRARIES_INTERFACE}
    ${DEPENDENCIES_PUBLIC}
    ${DEPENDENCIES_PRIVATE}
    ${DEPENDENCIES_INTERFACE}
  )
endmacro()

macro(_add_module)
  if (NOT DEFINED CMAKEPKG_COMPILER_CONFIG)
    set(CMAKEPKG_COMPILER_CONFIG ${CMAKE_SYSTEM_NAME}::${CMAKE_SYSTEM_PROCESSOR} CACHE INTERNAL "CMakePkg compiler configuration")
    message(STATUS "Loading ${CMAKEPKG_COMPILER_CONFIG} configuration")
    string(REPLACE "::" "_" CMAKEPKG_COMPILER_CONFIG_FILE ${CMAKEPKG_COMPILER_CONFIG})
    set(COMPILER_CONFIG_FILE ${CMAKEPKG_SOURCE_DIR}/Compiler/${CMAKEPKG_COMPILER_CONFIG_FILE}.cmake)
    if (EXISTS ${COMPILER_CONFIG_FILE})
      include(${COMPILER_CONFIG_FILE})
    endif()
  endif()

  if (NOT "${type}" STREQUAL "INTERFACE")
    if (BUILD_UNIT_TESTS)
      set(DEFINES_BUILD_UNIT_TESTS BUILD_UNIT_TESTS)
    endif()

    target_compile_definitions(${module_name}
      PRIVATE
        $<$<BOOL:"${CMAKEPKG_DEFINE}">:${CMAKEPKG_DEFINE}>
        $<$<AND:$<BOOL:"${CMAKEPKG_DEFINE_DEBUG}">,$<CONFIG:Debug>>:${CMAKEPKG_DEFINE_DEBUG}>
        $<$<AND:$<BOOL:"${CMAKEPKG_DEFINE_RELEASE}">,$<CONFIG:Release>>:${CMAKEPKG_DEFINE_RELEASE}>
        ${DEFINES_BUILD_UNIT_TESTS}
    )
    target_compile_options(${module_name}
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
    target_link_options(${module_name}
      PRIVATE
        $<$<BOOL:"${LINK}">:${LINK}>
        $<$<AND:$<BOOL:"${LINK_DEBUG}">,$<CONFIG:Debug>>:${LINK_DEBUG}>
        $<$<AND:$<BOOL:"${LINK_RELEASE}">,$<CONFIG:Release>>:${LINK_RELEASE}>
    )
    set_target_properties(${module_name}
      PROPERTIES
        LIBRARY_OUTPUT_DIRECTORY ${CMAKE_INSTALL_PREFIX}
        RUNTIME_OUTPUT_DIRECTORY ${CMAKE_INSTALL_PREFIX}
    )
    target_include_directories(${module_name}
      PUBLIC
        ${CMAKE_BINARY_DIR}/Revision
    )
  else()
    target_include_directories(${module_name}
      INTERFACE
        ${CMAKE_BINARY_DIR}/Revision
    )
  endif()

  _add_module_load_dependencies(${ARG_DEPENDENCIES})
  _add_module_link_libraries(${ARG_LINK_LIBRARIES} ${ARG_DEPENDENCIES})

  if (ARG_COMPILE_DEFINITIONS)
    target_compile_definitions(${module_name}
      ${ARG_COMPILE_DEFINITIONS}
    )
  endif()

  if (ARG_COMPILE_OPTIONS)
    target_compile_options(${module_name}
      ${ARG_COMPILE_OPTIONS}
    )
  endif()

  if (ARG_LINK_OPTIONS)
    target_link_options(${module_name}
      ${ARG_LINK_OPTIONS}
    )
  endif()

  if (ARG_COMPILE_FEATURES)
    target_compile_features(${module_name}
      ${ARG_COMPILE_FEATURES}
    )
  endif()

  if (ARG_INCLUDE_DIRECTORIES)
    target_include_directories(${module_name}
      ${ARG_INCLUDE_DIRECTORIES}
    )
  endif()

  if (ARG_LINK_DIRECTORIES)
    target_link_directories(${module_name}
      ${ARG_LINK_DIRECTORIES}
    )
  endif()

  if (ARG_PROPERTIES)
    set_target_properties(${module_name}
      PROPERTIES
        ${ARG_PROPERTIES}
    )
  endif()

  if (ARG_RESOURCES)
    foreach (RESOURCE ${ARG_RESOURCES})
      if (IS_DIRECTORY ${RESOURCE})
        add_custom_command(TARGET ${module_name} POST_BUILD COMMAND ${CMAKE_COMMAND} -E copy_directory ${RESOURCE} ${CMAKE_INSTALL_PREFIX})
      else()
        add_custom_command(TARGET ${module_name} POST_BUILD COMMAND ${CMAKE_COMMAND} -E copy ${RESOURCE} ${CMAKE_INSTALL_PREFIX})
      endif()
    endforeach()
  endif()

  _add_module_generate_revision(${module_name})
endmacro()

#
# Add a library module to the project using the specified source files.
#
# add_module_library(<name> [STATIC | SHARED | MODULE]
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
#
function(add_module_library module_name type)
  _add_module_parse_args(${ARGN})

  if ("${type}" STREQUAL "INTERFACE")
    add_library(${module_name} INTERFACE)
  else()
    _add_module_collect_sources()
    add_library(${module_name} ${type}
      ${ARG_SOURCES}
      ${${module_name}_SOURCES}
    )
  endif()

  _add_module()
endfunction()

#
# Add a executable module to the project using the specified source files.
#
# add_module_executable(<name>
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
#
function(add_module_executable module_name)
  _add_module_parse_args(${ARGN})
  _add_module_collect_sources()

  add_executable(${module_name}
    ${ARG_SOURCES}
    ${${module_name}_SOURCES}
  )

  _add_module()
endfunction()

#
# Add a test to the project to be run by ctest.
#
# add_module_test(<name>
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
#
function(add_module_test module_name)
  _add_module_parse_args(${ARGN})
  _add_module_collect_sources()

  add_executable(${module_name}
    ${ARG_SOURCES}
    ${${module_name}_SOURCES}
  )

  _add_module()

  add_test(
    NAME
      ${module_name}
    COMMAND
      ${module_name}
    WORKING_DIRECTORY
      ${CMAKE_INSTALL_PREFIX}
  )
endfunction()

#
# Add a apidocs target for the given module.
#
# add_module_docs(<name>
#   [DOXYGEN <config>]
# )
#
# <name> needs to be a valid module created with add_module_library or add_module_executable
#
# DOXYGEN
#   Use Doxygen as generator. Currently this is the only option supported.
#
#   <config>
#     List of doxygen parameters used for creating Doxyfile
#
function(add_module_docs project_name)
  cmake_parse_arguments(ARG
    ""
    ""
    "DOXYGEN"
    ${ARGN}
  )

  if (ARG_DOXYGEN)
    foreach (CONFIG ${ARG_DOXYGEN})
      string(REPLACE "=" ";" CONFIG ${CONFIG})
      list(GET CONFIG 0 KEY)
      list(GET CONFIG 1 VALUE)

      set(DOXYGEN_${KEY} ${VALUE})
    endforeach()

    set(DOXYGEN_OUTPUT_DIRECTORY    "${CMAKE_INSTALL_PREFIX}/docs")
    set(DOXYGEN_CREATE_SUBDIRS      YES)
    set(DOXYGEN_BUILTIN_STL_SUPPORT YES)
    set(DOXYGEN_EXTRACT_ALL         YES)
    set(DOXYGEN_GENERATE_TREEVIEW   YES)

    find_package(Doxygen REQUIRED
      OPTIONAL_COMPONENTS
        dot
        mscgen
        dia
    )

    get_target_property(SOURCE_LIST ${project_name} SOURCES)

    doxygen_add_docs(${project_name}-docs
        ${SOURCE_LIST}
      WORKING_DIRECTORY
        ${CMAKE_CURRENT_SOURCE_DIR}
      COMMENT
        "Generate doxygen docs for ${project_name}"
      ALL
    )
  endif()
endfunction()
