include_guard(GLOBAL)

macro(_find_dependency_set_folder target)
  set_target_properties(${target}
    PROPERTIES
      FOLDER
        "Dependency/${ARG_GROUP}/${ARG_PROJECT}"
  )
endmacro()

# find_dependency(
#   GROUP
#     <group>
#   PROJECT
#     <project>
#   BRANCH
#     <branch>
#   URL
#     <url>
#   OPTIONS
#     <build>
#     <options>
# )
function(find_dependency)
  cmake_parse_arguments(ARG
    ""
    "GROUP;PROJECT;BRANCH;URL"
    "OPTIONS"
    ${ARGN}
  )

  if (NOT ARG_GROUP)
    message(FATAL_ERROR "find_dependency GROUP argument missing!")
  endif()

  if (NOT ARG_PROJECT)
    message(FATAL_ERROR "find_dependency PROJECT argument missing!")
  endif()

  if (NOT ARG_URL)
    git_create_url(
      DOMAIN
        ${CMAKE_DEPENDENCY_GIT_DOMAIN}
      GROUP
        ${ARG_GROUP}
      PROJECT
        ${ARG_PROJECT}
      RESULT
        ARG_URL
    )
  endif()

  if (NOT ARG_BRANCH)
    set(ARG_BRANCH "master")
  endif()

  set(PATH "${CMAKE_DEPENDENCY_PATH}/${CMAKE_SYSTEM_NAME}/${CMAKE_SYSTEM_PROCESSOR}/${ARG_GROUP}/${ARG_PROJECT}")

  if (NOT EXISTS ${PATH})
    file(MAKE_DIRECTORY ${PATH})
  endif()

  set(SRC_PATH "${PATH}/src")
  set(BIN_PATH "${PATH}/bin")

  file(TO_CMAKE_PATH "${SRC_PATH}" SRC_PATH)
  file(TO_CMAKE_PATH "${BIN_PATH}" BIN_PATH)

  if (NOT EXISTS ${SRC_PATH})
    file(MAKE_DIRECTORY ${SRC_PATH})

    git_clone(
      URL
        ${ARG_URL}
      PATH
        ${SRC_PATH}
      BRANCH
        ${ARG_BRANCH}
      RESULT
        GIT_CLONE_RESULT
    )

    if (NOT ${GIT_CLONE_RESULT})
      message(FATAL_ERROR "Cloning ${ARG_GROUP}::${ARG_PROJECT} repository failed!")
    endif()
  endif()

  if (NOT EXISTS ${BIN_PATH})
    file(MAKE_DIRECTORY ${BIN_PATH})

    build_generate(
      SOURCE_PATH
        ${SRC_PATH}
      BINARY_PATH
        ${BIN_PATH}
      OPTIONS
        ${ARG_OPTIONS}
    )
  endif()

  file(GLOB_RECURSE
    DEPENDENCIES
      ${BIN_PATH}/*.dep.cmake
  )

  add_custom_target(${ARG_PROJECT}-pull
    COMMAND
      ${GIT_EXECUTABLE} pull
    WORKING_DIRECTORY
      ${SRC_PATH}
    COMMENT
      "Run git pull for ${ARG_PROJECT}"
  )

  add_custom_target(${ARG_PROJECT}-generate
    COMMAND
      ${CMAKE_COMMAND} ${SRC_PATH} ${BUILD_OPTIONS}
    WORKING_DIRECTORY
      ${BIN_PATH}
    COMMENT
      "Generate cmake build for ${ARG_PROJECT}"
  )

  add_custom_target(${ARG_PROJECT}-build
    COMMAND
      ${CMAKE_COMMAND} --build ${SRC_PATH}
    WORKING_DIRECTORY
      ${BIN_PATH}
    COMMENT
      "Build ${ARG_PROJECT}"
  )

  add_custom_target(${ARG_PROJECT}-rebuild
    COMMAND
      ${CMAKE_COMMAND} --build ${SRC_PATH} --clean-first
    WORKING_DIRECTORY
      ${BIN_PATH}
    COMMENT
      "Build ${ARG_PROJECT}"
  )

  _find_dependency_set_folder(${ARG_PROJECT}-pull)
  _find_dependency_set_folder(${ARG_PROJECT}-generate)
  _find_dependency_set_folder(${ARG_PROJECT}-build)
  _find_dependency_set_folder(${ARG_PROJECT}-rebuild)

  foreach (DEPENDENCY ${DEPENDENCIES})
    if (NOT EXISTS "${CMAKE_CURRENT_BINARY_DIR}/${DEPENDENCY}.dep.cmake")
      file(COPY ${DEPENDENCY} DESTINATION ${CMAKE_CURRENT_BINARY_DIR})
    endif()
  endforeach()
endfunction()

# register_dependency(<dependency name> [<dependencies>])
function(register_dependency dependency_name)
  export(TARGETS
      ${dependency_name}
    FILE
      ${dependency_name}.dep.cmake
    EXPORT_LINK_INTERFACE_LIBRARIES
  )
endfunction()
