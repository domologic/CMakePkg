include_guard(GLOBAL)

if (NOT FIND_DEPENDENCY_PATH)
  set(FIND_DEPENDENCY_PATH        "$ENV{HOME}/.cmake_deps")
endif()
set(FIND_DEPENDENCY_PATH ${FIND_DEPENDENCY_PATH} CACHE INTERNAL "path to the downloaded dependencies")

find_package(Git REQUIRED)

function(_get_git_url_origin)
  execute_process(
    COMMAND
      ${GIT_EXECUTABLE} remote get-url origin
    WORKING_DIRECTORY
      ${CMAKE_SOURCE_DIR}
    OUTPUT_VARIABLE
      FIND_DEPENDENCY_GIT_URL
    OUTPUT_STRIP_TRAILING_WHITESPACE
    ERROR_QUIET
  )

  if (NOT FIND_DEPENDENCY_GIT_URL)
    message(FATAL_ERROR "Could not get current git remote origin url!")
  endif()

  set(FIND_DEPENDENCY_GIT_URL     ${FIND_DEPENDENCY_GIT_URL}      CACHE STRING "find_dependency git remote origin url")
endfunction()

function(_get_git_url_domain)
  execute_process(
    COMMAND
      bash -c "echo ${FIND_DEPENDENCY_GIT_URL} | awk -F[/:] '{print $4}'"
    WORKING_DIRECTORY
      ${CMAKE_SOURCE_DIR}
    OUTPUT_VARIABLE
      FIND_DEPENDENCY_GIT_DOMAIN
    OUTPUT_STRIP_TRAILING_WHITESPACE
    ERROR_QUIET
  )

  if (NOT FIND_DEPENDENCY_GIT_DOMAIN)
    message(FATAL_ERROR "Could not get git remote origin url!")
  endif()

  set(FIND_DEPENDENCY_GIT_DOMAIN  ${FIND_DEPENDENCY_GIT_DOMAIN}   CACHE STRING "find_dependency git remote origin domain")
endfunction()

if (NOT FIND_DEPENDENCY_GIT_URL)
  _get_git_url_origin()
endif()

if (NOT FIND_DEPENDENCY_GIT_DOMAIN)
  _get_git_url_domain()
endif()

macro(_find_dependency_parse_args)
  set(_options              USE_SSH USE_HTTPS)
  set(_ove_value_keywords   GROUP PROJECT BRANCH URL)
  set(_multi_value_keywords BUILD_OPTIONS)

  cmake_parse_arguments(DEPENDENCY
    "${_options}"
    "${_ove_value_keywords}"
    "${_multi_value_keywords}"
    ${ARGN}
  )

  if (NOT DEPENDENCY_GROUP)
    message(FATAL_ERROR "find_dependency GROUP argument missing!")
  endif()

  if (NOT DEPENDENCY_PROJECT)
    message(FATAL_ERROR "find_dependency PROJECT argument missing!")
  endif()

  set(DEPENDENCY_TARGET_NAME ${DEPENDENCY_GROUP}-${DEPENDENCY_PROJECT})
  set(DEPENDENCY_ALIAS_NAME  ${DEPENDENCY_GROUP}::${DEPENDENCY_PROJECT})

  if (NOT DEPENDENCY_URL)
    if (${ARG_USE_SSH})
      set(DEPENDENCY_URL "git@${FIND_DEPENDENCY_GIT_DOMAIN}:${DEPENDENCY_GROUP}/${DEPENDENCY_PROJECT}.git")
    elseif (${ARG_USE_HTTPS})
      set(DEPENDENCY_URL "https://${FIND_DEPENDENCY_GIT_DOMAIN}/${DEPENDENCY_GROUP}/${DEPENDENCY_PROJECT}.git")
    else()
      set(DEPENDENCY_URL "http://${FIND_DEPENDENCY_GIT_DOMAIN}/${DEPENDENCY_GROUP}/${DEPENDENCY_PROJECT}.git")
    endif()
  endif()

  if (NOT DEPENDENCY_BRANCH)
    set(DEPENDENCY_BRANCH "master")
  endif()
endmacro()

macro(_find_dependency_get_path)
  string(SHA1 DEPENDENCY_PATH "${CMAKE_VERSION}${CMAKE_SYSTEM}${CMAKE_TOOLCHAIN_FILE}")

  set(DEPENDENCY_PATH "${FIND_DEPENDENCY_PATH}/${DEPENDENCY_PATH}")

  if (NOT EXISTS ${DEPENDENCY_PATH})
    file(MAKE_DIRECTORY ${DEPENDENCY_PATH})
  endif()
endmacro()

macro(_find_dependency_git_commit_id)
  execute_process(
    COMMAND
      ${GIT_EXECUTABLE} describe --long --match init --dirty=+ --abbrev=12 --always
    WORKING_DIRECTORY
      ${DEPENDENCY_SOURCE_PATH}
    OUTPUT_VARIABLE
      DEPENDENCY_GIT_COMMIT_ID
    OUTPUT_STRIP_TRAILING_WHITESPACE
  )

  if (NOT DEPENDENCY_GIT_COMMIT_ID)
    set(DEPENDENCY_GIT_COMMIT_ID "unknown")
  endif()
endmacro()

macro(_find_dependency_git_timestamp)
  execute_process(
    COMMAND
      ${GIT_EXECUTABLE} show -s --format=%ci
    WORKING_DIRECTORY
      ${DEPENDENCY_SOURCE_PATH}
    OUTPUT_VARIABLE
      DEPENDENCY_GIT_TIMESTAMP
    OUTPUT_STRIP_TRAILING_WHITESPACE
  )

  if (NOT DEPENDENCY_GIT_TIMESTAMP)
    set(DEPENDENCY_GIT_TIMESTAMP "1970-01-01 00:00:00 +0000")
  endif()
endmacro()

macro(_find_dependency_set_helper_vars)
  set(DEPENDENCY_SOURCE_PATH ${DEPENDENCY_PATH}/Source)
  set(DEPENDENCY_BINARY_PATH ${DEPENDENCY_PATH}/Binary)

  if (NOT EXISTS ${DEPENDENCY_SOURCE_PATH})
    file(MAKE_DIRECTORY ${DEPENDENCY_SOURCE_PATH})
  endif()

  if (NOT EXISTS ${DEPENDENCY_BINARY_PATH})
    file(MAKE_DIRECTORY ${DEPENDENCY_BINARY_PATH})
  endif()
endmacro()

macro(_find_domo_package_git_clone)
  message("Cloning Dependency ${DEPENDENCY_GROUP}::${DEPENDENCY_PROJECT}...")
  execute_process(
    COMMAND
      ${GIT_EXECUTABLE} clone ${DEPENDENCY_URL} --branch ${DEPENDENCY_BRANCH} --depth 1 --recursive ${DEPENDENCY_SOURCE_PATH}
    WORKING_DIRECTORY
      ${DEPENDENCY_SOURCE_PATH}
    RESULT_VARIABLE
      DEPENDENCY_GIT_CLONE_RESULT
  )

  if (NOT ${DEPENDENCY_GIT_CLONE_RESULT} EQUAL "0")
    message(FATAL_ERROR "Cloning dependency ${DEPENDENCY_GROUP}::${DEPENDENCY_PROJECT} failed!")
  else()
    message("Cloning dependency ${DEPENDENCY_GROUP}::${DEPENDENCY_PROJECT} done.")
  endif()
endmacro()

macro(_find_domo_package_gen_build)
  message("Generating build files for dependency ${DEPENDENCY_GROUP}::${DEPENDENCY_PROJECT}...")
  execute_process(
    COMMAND
      ${CMAKE_COMMAND} ${DEPENDENCY_SOURCE_PATH} ${DEPENDENCY_BUILD_OPTIONS}
    WORKING_DIRECTORY
      ${DEPENDENCY_BINARY_PATH}
    RESULT_VARIABLE
      DEPENDENCY_CMAKE_RESULT
  )

  if (NOT ${DEPENDENCY_CMAKE_RESULT} EQUAL "0")
    message(FATAL_ERROR "Generating build files for dependency ${DEPENDENCY_GROUP}::${DEPENDENCY_PROJECT} failed!")
  else()
    message("Generating build files for dependency ${DEPENDENCY_GROUP}::${DEPENDENCY_PROJECT} done.")
  endif()
endmacro()

macro(_find_domo_package_start_build)
  message("Building dependency ${DEPENDENCY_GROUP}::${DEPENDENCY_PROJECT}...")
  execute_process(
    COMMAND
      ${CMAKE_COMMAND} --build ${DEPENDENCY_BINARY_PATH}
    WORKING_DIRECTORY
      ${DEPENDENCY_BINARY_PATH}
    RESULT_VARIABLE
      DEPENDENCY_BUILD_RESULT
    OUTPUT_STRIP_TRAILING_WHITESPACE
  )

  if (NOT ${DEPENDENCY_BUILD_RESULT} EQUAL "0")
    message(FATAL_ERROR "Building dependency ${DEPENDENCY_GROUP}::${DEPENDENCY_PROJECT} failed!")
  else()
    message("Building dependency ${DEPENDENCY_GROUP}::${DEPENDENCY_PROJECT} done.")
  endif()
endmacro()

macro(_find_dependency_collect_targets)
  file(GLOB_RECURSE
    DEPENDENCY_TARGETS
      ${DEPENDENCY_BINARY_PATH}/*.dep.cmake
  )

  if ("${DEPENDENCY_TARGETS}" STREQUAL "")
    message(FATAL_ERROR "Dependency ${DEPENDENCY_GROUP}::${DEPENDENCY_PROJECT} does not register any targets!")
  endif()

  foreach (DEPENDENCY_TARGET ${DEPENDENCY_TARGETS})
    include(${DEPENDENCY_TARGET})
    get_filename_component(DEPENDENCY_NAME ${DEPENDENCY_TARGET} NAME_WE)
    set(DEPENDENCY_TARGET_NAMES
      ${DEPENDENCY_TARGET_NAMES}
      ${DEPENDENCY_NAME}
    )
  endforeach()
endmacro()

macro(_find_dependency_add_target)
  add_library(${DEPENDENCY_TARGET_NAME} INTERFACE)

  target_link_libraries(${DEPENDENCY_TARGET_NAME}
    INTERFACE
      ${DEPENDENCY_TARGET_NAMES}
  )
  add_library(${DEPENDENCY_ALIAS_NAME}
    ALIAS
      ${DEPENDENCY_TARGET_NAME}
  )

  add_custom_target(${DEPENDENCY_TARGET_NAME}-pull
    COMMAND
      ${GIT_EXECUTABLE} pull
    WORKING_DIRECTORY
      ${DEPENDENCY_SOURCE_PATH}
    COMMENT
      "Run git pull for ${DEPENDENCY_TARGET_NAME}"
  )

  add_custom_target(${DEPENDENCY_TARGET_NAME}-generate
    COMMAND
      ${CMAKE_COMMAND} ${DEPENDENCY_SOURCE_PATH} -DFIND_DEPENDENCY_PATH=${FIND_DEPENDENCY_PATH} ${DEPENDENCY_BUILD_OPTIONS}
    WORKING_DIRECTORY
      ${DEPENDENCY_BINARY_PATH}
    COMMENT
      "Generate cmake build for ${DEPENDENCY_TARGET_NAME}"
  )

  add_custom_target(${DEPENDENCY_TARGET_NAME}-build
    COMMAND
      ${CMAKE_COMMAND} ${DEPENDENCY_SOURCE_PATH} -DFIND_DEPENDENCY_PATH=${FIND_DEPENDENCY_PATH} ${DEPENDENCY_BUILD_OPTIONS}
    WORKING_DIRECTORY
      ${DEPENDENCY_BINARY_PATH}
    COMMENT
      "Build ${DEPENDENCY_TARGET_NAME}"
  )

  add_custom_target(${DEPENDENCY_TARGET_NAME}-clean
    COMMAND
      make clean
    WORKING_DIRECTORY
      ${DEPENDENCY_BINARY_PATH}
    COMMENT
      "Build ${DEPENDENCY_TARGET_NAME}"
  )
endmacro()

macro(_find_dependency_store_metadata)
  set(${DEPENDENCY_ALIAS_NAME}_USE_SSH          ${DEPENDENCY_USE_SSH}         CACHE BOOL      "${DEPENDENCY_TARGET_NAME} use ssh")
  set(${DEPENDENCY_ALIAS_NAME}_USE_HTTPS        ${DEPENDENCY_USE_HTTPS}       CACHE BOOL      "${DEPENDENCY_TARGET_NAME} use https")
  set(${DEPENDENCY_ALIAS_NAME}_GROUP            ${DEPENDENCY_GROUP}           CACHE STRING    "${DEPENDENCY_TARGET_NAME} group")
  set(${DEPENDENCY_ALIAS_NAME}_PROJECT          ${DEPENDENCY_PROJECT}         CACHE STRING    "${DEPENDENCY_TARGET_NAME} project")
  set(${DEPENDENCY_ALIAS_NAME}_BRANCH           ${DEPENDENCY_BRANCH}          CACHE STRING    "${DEPENDENCY_TARGET_NAME} branch")
  set(${DEPENDENCY_ALIAS_NAME}_URL              ${DEPENDENCY_URL}             CACHE STRING    "${DEPENDENCY_TARGET_NAME} url")
  set(${DEPENDENCY_ALIAS_NAME}_BUILD_OPTIONS    ${DEPENDENCY_BUILD_OPTIONS}   CACHE STRING    "${DEPENDENCY_TARGET_NAME} build options")

  set(${DEPENDENCY_ALIAS_NAME}_GIT_COMMIT_ID    ${DEPENDENCY_GIT_COMMIT_ID}    CACHE STRING   "${DEPENDENCY_TARGET_NAME} git commit id")
  set(${DEPENDENCY_ALIAS_NAME}_GIT_TIMESTAMP    ${DEPENDENCY_GIT_TIMESTAMP}    CACHE STRING   "${DEPENDENCY_TARGET_NAME} git timestamp ")

  set(${DEPENDENCY_ALIAS_NAME}_PATH             ${DEPENDENCY_PATH}             CACHE INTERNAL "${DEPENDENCY_TARGET_NAME} path")
  set(${DEPENDENCY_ALIAS_NAME}_SOURCE_PATH      ${DEPENDENCY_SOURCE_PATH}      CACHE INTERNAL "${DEPENDENCY_TARGET_NAME} source path")
  set(${DEPENDENCY_ALIAS_NAME}_BINARY_PATH      ${DEPENDENCY_BINARY_PATH}      CACHE INTERNAL "${DEPENDENCY_TARGET_NAME} binary path")

  set(${DEPENDENCY_ALIAS_NAME}_GIT_CLONE_RESULT ${DEPENDENCY_GIT_CLONE_RESULT} CACHE INTERNAL "")
  set(${DEPENDENCY_ALIAS_NAME}_CMAKE_RESULT     ${DEPENDENCY_CMAKE_RESULT}     CACHE INTERNAL "")
  set(${DEPENDENCY_ALIAS_NAME}_BUILD_RESULT     ${DEPENDENCY_BUILD_RESULT}     CACHE INTERNAL "")

  set(${DEPENDENCY_ALIAS_NAME}_TARGETS          ${DEPENDENCY_TARGETS}          CACHE INTERNAL "${DEPENDENCY_TARGET_NAME} targets")
  set(${DEPENDENCY_ALIAS_NAME}_TARGET_NAMES     ${DEPENDENCY_TARGET_NAMES}     CACHE STRING   "${DEPENDENCY_TARGET_NAME} target names")

  set(${DEPENDENCY_ALIAS_NAME}_TARGET_NAME      ${DEPENDENCY_TARGET_NAME}      CACHE STRING   "${DEPENDENCY_TARGET_NAME} target name")
  set(${DEPENDENCY_ALIAS_NAME}_ALIAS_NAME       ${DEPENDENCY_ALIAS_NAME}       CACHE STRING   "${DEPENDENCY_TARGET_NAME} alias name")
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
#   BUILD_OPTIONS
#     <build>
#     <options>
#   USE_SSH
#   USE_HTTPS
# )
function(find_dependency)
  _find_dependency_parse_args(${ARGN})
  _find_dependency_get_path()
  _find_dependency_set_helper_vars()

  if (NOT EXISTS "${DEPENDENCY_SOURCE_PATH}/.git")
    _find_domo_package_git_clone()
  endif()

  _find_dependency_git_commit_id()
  _find_dependency_git_timestamp()

  if (NOT EXISTS "${DEPENDENCY_BINARY_PATH}/CMakeCache.txt")
    _find_domo_package_gen_build()
    _find_domo_package_start_build()
  endif()

  _find_dependency_collect_targets()
  _find_dependency_add_target()
  _find_dependency_store_metadata()
endfunction()

# register_dependency(<dependency name>)
function(register_dependency dependency_name)
  export(TARGETS
      ${dependency_name}
    FILE
      ${dependency_name}.dep.cmake
    APPEND
    EXPORT_LINK_INTERFACE_LIBRARIES
  )
endfunction()
