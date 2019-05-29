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
      set(DEPS
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

macro(_add_module_compile_definitions)
  if (ARG_COMPILE_DEFINITIONS)
    target_compile_definitions(${module_name}
      ${ARG_COMPILE_DEFINITIONS}
    )
  endif()

  if (NOT "${type}" STREQUAL "INTERFACE")
    target_compile_definitions(${module_name}
      PRIVATE
        $<$<BOOL:"${DEFINE}">:${DEFINE}>
        $<$<AND:$<BOOL:"${DEFINE_DEBUG}">,$<CONFIG:Debug>>:${DEFINE_DEBUG}>
        $<$<AND:$<BOOL:"${DEFINE_RELWITHDEBINFO}">,$<CONFIG:RelWithDebInfo>>:${DEFINE_RELWITHDEBINFO}>
        $<$<AND:$<BOOL:"${DEFINE_RELEASE}">,$<CONFIG:Release>>:${DEFINE_RELEASE}>
    )
  endif()
endmacro()

macro(_add_module_compile_options)
  if (ARG_COMPILE_OPTIONS)
    target_compile_options(${module_name}
      ${ARG_COMPILE_OPTIONS}
    )
  endif()

  if (NOT "${type}" STREQUAL "INTERFACE")
    target_compile_options(${module_name}
      PRIVATE
        $<$<BOOL:"${FLAGS}">:${FLAGS}>
        $<$<AND:$<BOOL:"${FLAGS_DEBUG}">,$<CONFIG:Debug>>:${FLAGS_DEBUG}>
        $<$<AND:$<BOOL:"${FLAGS_RELWITHDEBINFO}">,$<CONFIG:RelWithDebInfo>>:${FLAGS_RELWITHDEBINFO}>
        $<$<AND:$<BOOL:"${FLAGS_RELEASE}">,$<CONFIG:Release>>:${FLAGS_RELEASE}>
        $<$<AND:$<BOOL:"${FLAGS_C}">,$<COMPILE_LANGUAGE:C>>:${FLAGS_C}>
        $<$<AND:$<BOOL:"${FLAGS_C_DEBUG}">,$<COMPILE_LANGUAGE:C>,$<CONFIG:Debug>>:${FLAGS_C_DEBUG}>
        $<$<AND:$<BOOL:"${FLAGS_C_RELWITHDEBINFO}">,$<COMPILE_LANGUAGE:C>,$<CONFIG:RelWithDebInfo>>:${FLAGS_C_RELWITHDEBINFO}>
        $<$<AND:$<BOOL:"${FLAGS_C_RELEASE}">,$<COMPILE_LANGUAGE:C>,$<CONFIG:Release>>:${FLAGS_C_RELEASE}>
        $<$<AND:$<BOOL:"${FLAGS_CXX}">,$<COMPILE_LANGUAGE:CXX>>:${FLAGS_CXX}>
        $<$<AND:$<BOOL:"${FLAGS_CXX_DEBUG}">,$<COMPILE_LANGUAGE:CXX>,$<CONFIG:Debug>>:${FLAGS_CXX_DEBUG}>
        $<$<AND:$<BOOL:"${FLAGS_CXX_RELWITHDEBINFO}">,$<COMPILE_LANGUAGE:CXX>,$<CONFIG:RelWithDebInfo>>:${FLAGS_CXX_RELWITHDEBINFO}>
        $<$<AND:$<BOOL:"${FLAGS_CXX_RELEASE}">,$<COMPILE_LANGUAGE:CXX>,$<CONFIG:Release>>:${FLAGS_CXX_RELEASE}>
    )
  endif()
endmacro()

macro(_add_module_link_options)
  if (ARG_LINK_OPTIONS)
    target_link_options(${module_name}
      ${ARG_LINK_OPTIONS}
    )
  endif()

  if (NOT "${type}" STREQUAL "INTERFACE")
    target_link_options(${module_name}
      PRIVATE
        $<$<BOOL:"${LINK}">:${LINK}>
        $<$<AND:$<BOOL:"${LINK_DEBUG}">,$<CONFIG:Debug>>:${LINK_DEBUG}>
        $<$<AND:$<BOOL:"${LINK_RELWITHDEBINFO}">,$<CONFIG:RelWithDebInfo>>:${LINK_RELWITHDEBINFO}>
        $<$<AND:$<BOOL:"${LINK_RELEASE}">,$<CONFIG:Release>>:${LINK_RELEASE}>
    )
  endif()
endmacro()

macro(_add_module)
  if (NOT EXISTS ${OUTPUT_DIRECTORY})
    file(MAKE_DIRECTORY ${OUTPUT_DIRECTORY})
  endif()

  include(${CMAKE_SCRIPT_PATH}/Compiler/${CMAKE_SYSTEM_NAME}_${CMAKE_SYSTEM_PROCESSOR}.cmake
    OPTIONAL
    RESULT_VARIABLE
      CONFIG_AVAILABLE
  )

  if (NOT "${CONFIG_AVAILABLE}" STREQUAL "NOTFOUND")
    message(STATUS "Loading ${CMAKE_SYSTEM_NAME}::${CMAKE_SYSTEM_PROCESSOR} configuration")
    load_compiler_config()
  endif()

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

  _add_module_link_libraries(${ARG_LINK_LIBRARIES})
  _add_module_compile_definitions()
  _add_module_compile_options()
  _add_module_link_options()

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
    foreach(OUTPUT_TYPE ARCHIVE LIBRARY PDB RUNTIME)
      foreach(CONFIG Y Y_DEBUG Y_RELWITHDEBINFO Y_RELEASE)
        set(OUTPUT_DIRECTORY_PROPERTY
          ${OUTPUT_DIRECTORY_PROPERTY}
          ${OUTPUT_TYPE}_OUTPUT_DIRECTOR${CONFIG}
            ${OUTPUT_DIRECTORY}
        )
      endforeach()
    endforeach()

    set_target_properties(${module_name}
      PROPERTIES
        ${OUTPUT_DIRECTORY_PROPERTY}
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

  if (WIN32)
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
