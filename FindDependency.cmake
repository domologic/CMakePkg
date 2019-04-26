include_guard(GLOBAL)

function(_find_dependency_collect_targets targets)
  file(GLOB_RECURSE
    TARGETS
      ${BINARY_PATH}/*.dep.cmake
  )

  if ("${TARGETS}" STREQUAL "")
    message(FATAL_ERROR "Dependency ${ARG_GROUP}::${ARG_PROJECT} does not register any targets!")
  endif()

  foreach (TARGET ${TARGETS})
    include(${TARGET})
    get_filename_component(TARGET_NAME ${TARGET} NAME_WE)
    set(TARGET_NAMES
      ${TARGET_NAMES}
      ${TARGET_NAME}
    )

    file(COPY ${TARGET} DESTINATION ${CMAKE_CURRENT_BINARY_DIR})
  endforeach()
  set(${targets} ${TARGET_NAMES} PARENT_SCOPE)
endfunction()

function(_find_dependency_set_folder target)
  set_target_properties(${target}
    PROPERTIES
      FOLDER
        "Dependency/${ARG_TARGET_NAME}"
  )
endfunction()

function(_find_dependency_add_target targets)
  add_library(${TARGET_NAME} INTERFACE)

  target_link_libraries(${TARGET_NAME}
    INTERFACE
      ${targets}
  )
  add_library(${ALIAS_NAME}
    ALIAS
      ${TARGET_NAME}
  )

  add_custom_target(${TARGET_NAME}-pull
    COMMAND
      ${GIT_EXECUTABLE} pull
    WORKING_DIRECTORY
      ${SOURCE_PATH}
    COMMENT
      "Run git pull for ${TARGET_NAME}"
  )

  add_custom_target(${TARGET_NAME}-generate
    COMMAND
      ${CMAKE_COMMAND} ${SOURCE_PATH} ${BUILD_OPTIONS}
    WORKING_DIRECTORY
      ${BINARY_PATH}
    COMMENT
      "Generate cmake build for ${TARGET_NAME}"
  )

  add_custom_target(${TARGET_NAME}-build
    COMMAND
      ${CMAKE_COMMAND} ${SOURCE_PATH} ${BUILD_OPTIONS}
    WORKING_DIRECTORY
      ${BINARY_PATH}
    COMMENT
      "Build ${TARGET_NAME}"
  )

  add_custom_target(${TARGET_NAME}-clean
    COMMAND
      make clean
    WORKING_DIRECTORY
      ${BINARY_PATH}
    COMMENT
      "Build ${TARGET_NAME}"
  )

  _find_dependency_set_folder(${TARGET_NAME}-pull)
  _find_dependency_set_folder(${TARGET_NAME}-generate)
  _find_dependency_set_folder(${TARGET_NAME}-build)
  _find_dependency_set_folder(${TARGET_NAME}-clean)
endfunction()

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

  set(TARGET_NAME ${ARG_GROUP}-${ARG_PROJECT})
  set(ALIAS_NAME  ${ARG_GROUP}::${ARG_PROJECT})

  string(SHA1 PATH "${CMAKE_VERSION}${CMAKE_SYSTEM}${CMAKE_TOOLCHAIN_FILE}${ARG_GROUP}${ARG_PROJECT}")
  set(PATH "${CMAKE_DEPENDENCY_PATH}/${PATH}")

  if (NOT EXISTS ${PATH})
    file(MAKE_DIRECTORY ${PATH})
  endif()

  set(SOURCE_PATH ${PATH}/Source)
  set(BINARY_PATH ${PATH}/Binary)

  if (NOT EXISTS ${SOURCE_PATH})
    file(MAKE_DIRECTORY ${SOURCE_PATH})
  endif()

  if (NOT EXISTS ${BINARY_PATH})
    file(MAKE_DIRECTORY ${BINARY_PATH})
  endif()

  git_clone(
    URL
      ${ARG_URL}
    PATH
      ${SOURCE_PATH}
    BRANCH
      ${ARG_BRANCH}
    RESULT
      GIT_CLONE_RESULT
  )

  if (NOT ${GIT_CLONE_RESULT})
    message(FATAL_ERROR "Cloning repository failed!")
  endif()

  build_generate(
    SOURCE_PATH
      ${SOURCE_PATH}
    BINARY_PATH
      ${BINARY_PATH}
    RESULT
      BUILD_GENERATE_RESULT
    OPTIONS
      ${ARG_OPTIONS}
  )

  if (NOT ${BUILD_GENERATE_RESULT})
    message(FATAL_ERROR "Generating build failed!")
  endif()

  build_start(
    PATH
      ${BINARY_PATH}
    RESULT
      BUILD_RESULT
  )

  if (NOT ${BUILD_RESULT})
    message(FATAL_ERROR "Build for ${ARG_ALIAS_NAME} failed!")
  endif()

  _find_dependency_collect_targets(TARGETS)
  _find_dependency_add_target(${TARGETS})
endfunction()
