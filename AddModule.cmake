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
    "MFC"
    ""
    "${_MULTI_OPTIONS}"
    ${ARGN}
  )
endmacro()

macro(_add_module_collect_sources)
  if (ARG_SOURCE_DIR)
    cmake_parse_arguments(SOURCE_DIR
      ""
      "PATH"
      "EXCLUDES"
      ${ARG_SOURCE_DIR}
    )

    collect_source_files(
      ${SOURCE_DIR_PATH}
      SOURCES
      ${SOURCE_DIR_EXCLUDES}
    )
    set(ARG_SOURCES
      ${ARG_SOURCES}
      ${SOURCES}
    )
    group_sources(${SOURCE_DIR_PATH})
  endif()
endmacro()

macro(_add_module_link_libraries)
  cmake_parse_arguments(LIBRARY_LIST
    ""
    ""
    "PUBLIC;PRIVATE;INTERFACE"
    ${ARGN}
  )

  file(GLOB_RECURSE
    DEPENDENCIES
      ${CMAKE_CURRENT_BINARY_DIR}/*.dep.cmake
  )

  foreach (DEPENDENCY ${DEPENDENCIES})
    include(${DEPENDENCY})
    get_filename_component(DEPENDENCY_NAME ${DEPENDENCY} NAME_WE)
    if (NOT ${DEPENDENCY} MATCHES ".*-res")
      set (DEPS
        ${DEPS}
        ${DEPENDENCY_NAME}
      )
    endif()
  endforeach()

  if ("${type}" STREQUAL "INTERFACE")
    target_link_libraries(${module_name}
      INTERFACE
        ${LIBRARY_LIST_PUBLIC}
        ${LIBRARY_LIST_PRIVATE}
        ${LIBRARY_LIST_INTERFACE}
        ${DEPS}
    )
  else()
    if (LIBRARY_LIST_PRIVATE)
      set(LIBRARIES_PRIVATE "PRIVATE;${LIBRARY_LIST_PRIVATE}")
    endif()
    if (LIBRARY_LIST_INTERFACE)
      set(LIBRARIES_INTERFACE "INTERFACE;${LIBRARY_LIST_INTERFACE}")
    endif()

    target_link_libraries(${module_name}
      PUBLIC
        ${LIBRARY_LIST_PUBLIC}
        ${DEPS}
      ${LIBRARIES_PRIVATE}
      ${LIBRARIES_INTERFACE}
    )
  endif()
endmacro()

macro(_add_module)
  if (NOT EXISTS ${OUTPUT_DIRECTORY})
    file(MAKE_DIRECTORY ${OUTPUT_DIRECTORY})
  endif()

  if (ARG_DEPENDENCIES)
    foreach(DEPENDENCY ${ARG_DEPENDENCIES})
      string(REPLACE "::" ";" DEPENDENCY_GROUP_PROJECT ${DEPENDENCY})

      list(GET DEPENDENCY_GROUP_PROJECT 0 DEPENDENCY_GROUP)
      list(GET DEPENDENCY_GROUP_PROJECT 1 DEPENDENCY_PROJECT)

      message(STATUS "Building dependency ${DEPENDENCY}...")
      find_dependency(
        GROUP
          ${DEPENDENCY_GROUP}
        PROJECT
          ${DEPENDENCY_PROJECT}
      )
      message(STATUS "Dependency ${DEPENDENCY} loaded.")
    endforeach()
  endif()

  _add_module_link_libraries(${ARG_LINK_LIBRARIES})

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

  if (ARG_LINK_OPTIONS)
    target_link_options(${module_name}
      ${ARG_LINK_OPTIONS}
    )
  endif()

  if (ARG_RESOURCES)
    foreach (RESOURCE ${ARG_RESOURCES})
      if (IS_DIRECTORY ${RESOURCE})
        file(GLOB
          SUBRESOURCES
            ${RESOURCE}/*
        )
        
        foreach (SUBRESOURCE ${SUBRESOURCES})
          file(COPY ${SUBRESOURCE} DESTINATION ${OUTPUT_DIRECTORY})
        endforeach()
      else()
        file(COPY ${SUBRESOURCE} DESTINATION ${OUTPUT_DIRECTORY})
      endif()
    endforeach()
  endif()

  if (NOT "${type}" STREQUAL "INTERFACE")
    set_target_properties(${module_name}
      PROPERTIES
        ARCHIVE_OUTPUT_DIRECTORY
          ${OUTPUT_DIRECTORY}
        LIBRARY_OUTPUT_DIRECTORY
          ${OUTPUT_DIRECTORY}
        PDB_OUTPUT_DIRECTORY
          ${OUTPUT_DIRECTORY}
        RUNTIME_OUTPUT_DIRECTORY
          ${OUTPUT_DIRECTORY}
    )
  endif()
endmacro()

function(add_module_library module_name type)
  _add_module_parse_args(${ARGN})

  if ("${type}" STREQUAL "INTERFACE")
    add_library(${module_name} INTERFACE)
  else()
    _add_module_collect_sources()
    add_library(${module_name} ${type}
      ${ARG_SOURCES}
    )
  endif()

  _add_module()

  register_dependency(${module_name})
endfunction()

function(add_module_executable module_name)
  _add_module_parse_args(${ARGN})
  _add_module_collect_sources()

  if (ARG_MFC)
    set(CMAKE_MFC_FLAG 2)
    set(EXE_TYPE WIN32)
  endif()

  add_executable(${module_name} ${EXE_TYPE}
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
