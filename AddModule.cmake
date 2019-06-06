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

function(_add_module_load_dependency DEPENDENCY)
  string(REPLACE "::" ";" DEPENDENCY_GROUP_PROJECT ${DEPENDENCY})

  list(GET DEPENDENCY_GROUP_PROJECT 0 GROUP)
  list(GET DEPENDENCY_GROUP_PROJECT 1 PROJECT)

  set(SRC_PATH "${DOMOLOGIC_DEPENDENCY_PATH}/Source/${GROUP}/${PROJECT}")
  set(BIN_PATH "${DOMOLOGIC_DEPENDENCY_PATH}/Binary/${GROUP}/${PROJECT}")

  if (NOT EXISTS ${SRC_PATH})
    file(MAKE_DIRECTORY ${SRC_PATH})

    execute_process(
      COMMAND
        ${GIT_EXECUTABLE} clone "http://${DOMOLOGIC_DEPENDENCY_GIT_DOMAIN}/${GROUP}/${PROJECT}.git" --depth 1 --recursive ${SRC_PATH}
      WORKING_DIRECTORY
        ${CMAKE_CURRENT_BINARY_DIR}
      RESULT_VARIABLE
        RESULT
      OUTPUT_QUIET
      ERROR_QUIET
    )

    if (NOT ${RESULT} EQUAL "0")
      message(FATAL_ERROR "Could not clone ${GROUP}::${PROJECT}!")
    endif()
  endif()

  if (NOT EXISTS ${BIN_PATH})
    file(MAKE_DIRECTORY ${BIN_PATH})

    execute_process(
      COMMAND
        ${CMAKE_COMMAND}
        -S ${SRC_PATH}
        -B ${BIN_PATH}
        -G "${CMAKE_GENERATOR}"
        -DCMAKE_TOOLCHAIN_FILE=${CMAKE_TOOLCHAIN_FILE}
        -DCMAKE_INSTALL_PREFIX=${CMAKE_INSTALL_PREFIX}
        -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE}
        -DDOMOLOGIC_DEPENDENCY_PATH=${DOMOLOGIC_DEPENDENCY_PATH}
      WORKING_DIRECTORY
        ${BIN_PATH}
      OUTPUT_QUIET
    )

    execute_process(
      COMMAND
        ${CMAKE_COMMAND} --build ${BIN_PATH}
      WORKING_DIRECTORY
        ${BIN_PATH}
      OUTPUT_QUIET
    )
  endif()

  file(GLOB DEPENDENCIES ${BIN_PATH}/*.dep.cmake)
  foreach(DEPENDENCY ${DEPENDENCIES})
    file(COPY ${DEPENDENCY} DESTINATION ${CMAKE_CURRENT_BINARY_DIR})
  endforeach()
endfunction()

macro(_add_module_collect_sources)
  if (ARG_SOURCE_DIR)
    cmake_parse_arguments(SOURCE_DIR
      ""
      "PATH"
      "EXCLUDES"
      ${ARG_SOURCE_DIR}
    )

    _add_module_collect_source_files(${SOURCE_DIR_PATH} SOURCES ${SOURCE_DIR_EXCLUDES})
    set(ARG_SOURCES ${ARG_SOURCES} ${SOURCES})
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
    set(DEPS
      ${DEPS}
      ${DEPENDENCY_NAME}
    )
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
  include(${DOMOLOGIC_SCRIPT_PATH}/Compiler/${CMAKE_SYSTEM_NAME}_${CMAKE_SYSTEM_PROCESSOR}.cmake)

  if (NOT "${type}" STREQUAL "INTERFACE")
    message(STATUS "Loading ${CMAKE_SYSTEM_NAME}::${CMAKE_SYSTEM_PROCESSOR} configuration")
    load_compiler_config()

    target_compile_definitions(${module_name}
      PRIVATE
        $<$<BOOL:"${DEFINE}">:${DEFINE}>
        $<$<AND:$<BOOL:"${DEFINE_DEBUG}">,$<CONFIG:Debug>>:${DEFINE_DEBUG}>
        $<$<AND:$<BOOL:"${DEFINE_RELEASE}">,$<CONFIG:Release>>:${DEFINE_RELEASE}>
    )
    target_compile_options(${module_name}
      PRIVATE
        $<$<BOOL:"${FLAGS}">:${FLAGS}>
        $<$<AND:$<BOOL:"${FLAGS_DEBUG}">,$<CONFIG:Debug>>:${FLAGS_DEBUG}>
        $<$<AND:$<BOOL:"${FLAGS_RELEASE}">,$<CONFIG:Release>>:${FLAGS_RELEASE}>
        $<$<AND:$<BOOL:"${FLAGS_C}">,$<COMPILE_LANGUAGE:C>>:${FLAGS_C}>
        $<$<AND:$<BOOL:"${FLAGS_C_DEBUG}">,$<COMPILE_LANGUAGE:C>,$<CONFIG:Debug>>:${FLAGS_C_DEBUG}>
        $<$<AND:$<BOOL:"${FLAGS_C_RELEASE}">,$<COMPILE_LANGUAGE:C>,$<CONFIG:Release>>:${FLAGS_C_RELEASE}>
        $<$<AND:$<BOOL:"${FLAGS_CXX}">,$<COMPILE_LANGUAGE:CXX>>:${FLAGS_CXX}>
        $<$<AND:$<BOOL:"${FLAGS_CXX_DEBUG}">,$<COMPILE_LANGUAGE:CXX>,$<CONFIG:Debug>>:${FLAGS_CXX_DEBUG}>
        $<$<AND:$<BOOL:"${FLAGS_CXX_RELEASE}">,$<COMPILE_LANGUAGE:CXX>,$<CONFIG:Release>>:${FLAGS_CXX_RELEASE}>
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
  endif()

  foreach(DEPENDENCY ${ARG_DEPENDENCIES})
    message(STATUS "Building dependency ${DEPENDENCY}...")
    _add_module_load_dependency(${DEPENDENCY})
    message(STATUS "Dependency ${DEPENDENCY} loaded.")
  endforeach()

  _add_module_link_libraries(${ARG_LINK_LIBRARIES})

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
        add_custom_command(TARGET ${module_name} POST_BUILD COMMAND ${CMAKE_COMMAND} -E copy_directory ${SUBRESOURCE} ${CMAKE_INSTALL_PREFIX})
      else()
        add_custom_command(TARGET ${module_name} POST_BUILD COMMAND ${CMAKE_COMMAND} -E copy ${RESOURCE} ${CMAKE_INSTALL_PREFIX})
      endif()
    endforeach()
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

  export(
    TARGETS
      ${module_name}
    FILE
      ${module_name}.dep.cmake
    EXPORT_LINK_INTERFACE_LIBRARIES
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
    "SOURCE_DIR"
    ""
    ${ARGN}
  )

  set(OUTPUT_DIR "${CMAKE_INSTALL_PREFIX}/docs")
  if (NOT EXISTS ${OUTPUT_DIR})
    file(MAKE_DIRECTORY ${OUTPUT_DIR})
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
        ${OUTPUT_DIR}
      COMMENT
        "Generate doxygen docs for ${project_name}"
      ALL
    )
  endif()
endfunction()
