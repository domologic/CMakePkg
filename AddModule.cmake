include_guard(GLOBAL)

if (NOT OUTPUT_DIRECTORY)
  set(OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/bin")
endif()
set(OUTPUT_DIRECTORY ${OUTPUT_DIRECTORY} CACHE PATH "output directory path")

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

macro(_add_module_process_resources)
  cmake_parse_arguments(RESOURCES
   ""
   ""
   "RELEASE;DEBUG"
   ${ARG_RESOURCES}
  )
  if (RESOURCES_DEBUG)
    install(
      FILES
        ${RESOURCES_DEBUG}
      CONFIGURATIONS
        Debug
      DESTINATION
        ${OUTPUT_DIRECTORY}
    )
    file(APPEND ${CMAKE_CURRENT_BINARY_DIR}/resources.dep.cmake
      "install("
      "  FILES"
      "    ${RESOURCES_DEBUG}"
      "  CONFIGURATIONS"
      "    Debug"
      "  DESTINATION"
      "    ${OUTPUT_DIRECTORY}"
      ")"
    )
  endif()
  if (RESOURCES_RELEASE)
    install(
      FILES
        ${RESOURCES_RELEASE}
      CONFIGURATIONS
        Release
      DESTINATION
        ${OUTPUT_DIRECTORY}
    )
    file(APPEND ${CMAKE_CURRENT_BINARY_DIR}/resources.dep.cmake
      "install("
      "  FILES"
      "    ${RESOURCES_RELEASE}"
      "  CONFIGURATIONS"
      "    Release"
      "  DESTINATION"
      "    ${OUTPUT_DIRECTORY}"
      ")"
    )
  endif()
  if (RESOURCES_UNPARSED_ARGUMENTS)
    install(
      FILES
        ${RESOURCES_UNPARSED_ARGUMENTS}
      DESTINATION
        ${OUTPUT_DIRECTORY}
    )
    file(APPEND ${CMAKE_CURRENT_BINARY_DIR}/resources.dep.cmake
      "install("
      "  FILES"
      "    ${RESOURCES_UNPARSED_ARGUMENTS}"
      "  DESTINATION"
      "    ${OUTPUT_DIRECTORY}"
      ")"
    )
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
