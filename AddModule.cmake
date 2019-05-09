include_guard(GLOBAL)

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

macro(_add_module_collect_sources)
  if (ARG_SOURCE_DIR)
    list(GET ARG_SOURCE_DIR 0 SOURCE_DIR)
    list(GET ARG_SOURCE_DIR 1 EXCLUDES)

    collect_source_files(
      ${SOURCE_DIR}
      COLLECTED_SOURCES
      ${EXCLUDES}
    )
    set(ARG_SOURCES
      ${ARG_SOURCES}
      ${COLLECTED_SOURCES}
    )
  endif()
endmacro()

macro(_add_module_process_resource_group)
  cmake_parse_arguments(ARG_RESG
    "UNIX;WIN32;RESOURCE_DIRS"
    ""
    "DEBUG;RELEASE"
    ${ARGN}
  )

  if (ARG_RESG_RESOURCE_DIRS)
    if (ARG_RESG_UNIX)
      set(RESOURCE_DIRS_UNIX_DEBUG    ${ARG_RESG_DEBUG})
      set(RESOURCE_DIRS_UNIX_RELEASE  ${ARG_RESG_RELEASE})
      set(RESOURCE_DIRS_UNIX_ALL      ${ARG_RESG_UNPARSED_ARGUMENTS})
    elseif(ARG_RESG_WIN32)
      set(RESOURCE_DIRS_DEBUG         ${ARG_RESG_DEBUG})
      set(RESOURCE_DIRS_RELEASE       ${ARG_RESG_RELEASE})
      set(RESOURCE_DIRS_ALL           ${ARG_RESG_UNPARSED_ARGUMENTS})
    else()
      set(RESOURCE_DIRS_WIN32_DEBUG   ${ARG_RESG_DEBUG})
      set(RESOURCE_DIRS_WIN32_RELEASE ${ARG_RESG_RELEASE})
      set(RESOURCE_DIRS_WIN32_ALL     ${ARG_RESG_UNPARSED_ARGUMENTS})
    endif()
  else()
    if (ARG_RESG_UNIX)
      set(RESOURCES_UNIX_DEBUG        ${ARG_RESG_DEBUG})
      set(RESOURCES_UNIX_RELEASE      ${ARG_RESG_RELEASE})
      set(RESOURCES_UNIX_ALL          ${ARG_RESG_UNPARSED_ARGUMENTS})
    elseif(ARG_RESG_WIN32)
      set(RESOURCES_WIN32_DEBUG       ${ARG_RESG_DEBUG})
      set(RESOURCES_WIN32_RELEASE     ${ARG_RESG_RELEASE})
      set(RESOURCES_WIN32_ALL         ${ARG_RESG_UNPARSED_ARGUMENTS})
    else()
      set(RESOURCES_DEBUG             ${ARG_RESG_DEBUG})
      set(RESOURCES_RELEASE           ${ARG_RESG_RELEASE})
      set(RESOURCES_ALL               ${ARG_RESG_UNPARSED_ARGUMENTS})
    endif()
  endif()
endmacro()

macro(_add_module_process_resources)
  cmake_parse_arguments(ARG_RES
    "RESOURCE_DIRS"
    ""
    "UNIX;WIN32"
    ${ARG_RESOURCES}
  )
  if (ARG_RES_RESOURCE_DIRS)
    set(TYPE RESOURCE_DIRS)
  endif()

  if (ARG_RES_UNIX)
    _add_module_process_resource_group(${TYPE} UNIX  ${ARG_RES_UNIX})
  endif()
  if (ARG_RES_WIN32)
    _add_module_process_resource_group(${TYPE} WIN32 ${ARG_RES_UNIX})
  endif()
  if (ARG_RES_UNPARSED_ARGUMENTS)
    _add_module_process_resource_group(${TYPE} ${ARG_RES_UNPARSED_ARGUMENTS})
  endif()
endmacro()

macro(_add_module)
  if (ARG_DEPENDENCIES)
    foreach(DEPENDENCY ${ARG_DEPENDENCIES})
      string(REPLACE "::" ";" DEPENDENCY_GROUP_PROJECT ${DEPENDENCY})

      list(GET DEPENDENCY_GROUP_PROJECT 0 DEPENDENCY_GROUP)
      list(GET DEPENDENCY_GROUP_PROJECT 1 DEPENDENCY_PROJECT)

      find_dependency(
        GROUP
          ${DEPENDENCY_GROUP}
        PROJECT
          ${DEPENDENCY_PROJECT}
      )
    endforeach()

    target_link_libraries(${module_name}
      ${ARG_DEPENDENCIES}
    )
  endif()

  if (ARG_COMPILE_DEFINITIONS)
    target_compile_definitions(${module_name}
      ${ARG_COMPILE_DEFINITIONS}
    )
  endif()

  if (ARG_COMPILE_FEATURES)
    target_compile_features(${module_name}
      ${ARG_COMPILE_FEATURES}
    )
  endif()

  if (ARG_COMPILE_OPTIONS)
    target_compile_options(${module_name}
      ${ARG_COMPILE_OPTIONS}
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

  if (ARG_LINK_LIBRARIES)
    target_link_libraries(${module_name}
      ${ARG_LINK_LIBRARIES}
    )
  endif()

  if (ARG_LINK_OPTIONS)
    target_link_options(${module_name}
      ${ARG_LINK_OPTIONS}
    )
  endif()

  if (ARG_RESOURCES)
    _add_module_process_resources()
  endif()

  if (ARG_RESOURCE_DIRS)
    _add_module_process_resources(RESOURCE_DIRS)
  endif()

  if (ARG_RESOURCES OR ARG_RESOURCE_DIRS)
    configure_file(
      ${CMAKE_SCRIPT_PATH}/Resources.in.dep.cmake
      ${CMAKE_CURRENT_BINARY_DIR}/Resources.dep.cmake
      @ONLY
    )
    include(${CMAKE_CURRENT_BINARY_DIR}/Resources.dep.cmake)
  endif()

  if (NOT "${type}" STREQUAL "INTERFACE")
    set_target_properties(${module_name}
      PROPERTIES
        RUNTIME_OUTPUT_DIRECTORY
          ${OUTPUT_DIRECTORY}
    )
  endif()
endmacro()

function(add_module_library module_name type)
  _add_module_parse_args(${ARGN})

  if ("${type}" STREQUAL "INTERFACE")
    add_library(${module_name} ${type})
  else()
    _add_module_collect_sources()
    add_library(${module_name} ${type}
      ${ARG_SOURCES}
    )
  endif()

  _add_module()

  if (ARG_DEPENDENCIES)
    string(REPLACE "::" "-" ARG_DEPENDENCIES "${ARG_DEPENDENCIES}")
  endif()

  register_dependency(${module_name}
    ${ARG_DEPENDENCIES}
  )
endfunction()

function(add_module_executable module_name)
  _add_module_parse_args(${ARGN})
  _add_module_collect_sources()

  add_executable(${module_name}
    ${ARG_SOURCES}
  )

  _add_module()
endfunction()

function(add_module_docs project_name)
  cmake_parse_arguments(ARG
    "DOXYGEN"
    "SOURCE_DIR;OUTPUT_DIR"
    ""
    ${ARGN}
  )

  if (NOT EXISTS ${ARG_OUTPUT_DIR})
    file(MAKE_DIRECTORY ${ARG_OUTPUT_DIR})
  endif()

  if (ARG_DOXYGEN)
    find_package(Doxygen REQUIRED
      OPTIONAL_COMPONENTS
        dot
        mscgen
        dia
    )

    cmake_parse_arguments(DOXYGEN
      ""
      ""
      "CONFIG"
      ${ARGN}
    )

    doxygen_add_docs(${project_name}-docs
        ${ARG_SOURCE_DIR}/*
      WORKING_DIRECTORY
        ${ARG_OUTPUT_DIR}
      COMMENT
        "Generate doxygen docs for ${project_name}"
    )
  endif()
endfunction()
