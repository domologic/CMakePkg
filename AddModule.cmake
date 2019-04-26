include_guard(GLOBAL)

macro(_add_module_parse_args)
  cmake_parse_arguments(ARG
    ""
    ""
    "SOURCES;COMPILE_DEFINITIONS;COMPILE_FEATURES;COMPILE_OPTIONS;INCLUDE_DIRECTORIES;LINK_DIRECTORIES;LINK_LIBRARIES;LINK_OPTIONS;DEPENDENCIES"
    ${ARGN}
  )
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

  if (ARG_DEPENDENCIES)
    string(REPLACE "::" "-" ARG_DEPENDENCIES ${ARG_DEPENDENCIES})
  endif()
  register_dependency(${module_name}
    ${ARG_DEPENDENCIES}
  )
endmacro()

function(add_module_library module_name type)
  _add_module_parse_args(${ARGN})

  if ("${type}" STREQUAL "INTERFACE")
    add_library(${module_name} ${type})
  else()
    add_library(${module_name} ${type}
      ${ARG_SOURCES}
    )
  endif()

  _add_module()
endfunction()

function(add_module_executable module_name)
  _add_module_parse_args(${ARGN})

  add_executable(${module_name}
    ${ARG_SOURCES}
  )

  _add_module()
endfunction()
