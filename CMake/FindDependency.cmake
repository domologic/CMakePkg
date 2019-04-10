include_guard(GLOBAL)

if (NOT FIND_DEPENDENCY_PATH)
  set(FIND_DEPENDENCY_PATH        "${CMAKE_BINARY_DIR}/Dependency"  CACHE PATH   "find dependency path")
endif()

find_package(Git REQUIRED)

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

set(FIND_DEPENDENCY_GIT_URL     "${FIND_DEPENDENCY_GIT_URL}"      CACHE STRING "find dependency git remote origin url")

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

set(FIND_DEPENDENCY_GIT_DOMAIN  "${FIND_DEPENDENCY_GIT_DOMAIN}"   CACHE STRING "find dependency git remote origin domain")

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
    message(FATAL_ERROR "find_DEPENDENCY GROUP argument missing!")
  endif()

  if (NOT DEPENDENCY_PROJECT)
    message(FATAL_ERROR "find_DEPENDENCY PROJECT argument missing!")
  endif()

  if (NOT DEPENDENCY_URL)
    if (${DEPENDENCY_USE_SSH})
      set(DEPENDENCY_URL "git@${FIND_DEPENDENCY_GIT_DOMAIN}:${DEPENDENCY_GROUP}/${DEPENDENCY_PROJECT}.git")
    elseif (${DEPENDENCY_USE_HTTPS})
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
      ${GIT_EXECUTABLE} clone ${DEPENDENCY_URL} --branch ${DEPENDENCY_BRANCH} --depth 1 ${DEPENDENCY_SOURCE_PATH}
    WORKING_DIRECTORY
      ${DEPENDENCY_SOURCE_PATH}
    RESULT_VARIABLE
      DEPENDENCY_GIT_CLONE_RESULT
    OUTPUT_STRIP_TRAILING_WHITESPACE
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
      ${CMAKE_COMMAND} ${DEPENDENCY_SOURCE_PATH} -DFIND_DEPENDENCY_PATH=${FIND_DEPENDENCY_PATH} ${DEPENDENCY_BUILD_OPTIONS}
    WORKING_DIRECTORY
      ${DEPENDENCY_BINARY_PATH}
    RESULT_VARIABLE
      DEPENDENCY_CMAKE_RESULT
    OUTPUT_STRIP_TRAILING_WHITESPACE
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
    get_filename_component(DEPENDENCY_TARGET_NAME ${DEPENDENCY_TARGET} NAME_WE)
    set(DEPENDENCY_TARGET_NAMES
      ${DEPENDENCY_TARGET_NAMES}
      ${DEPENDENCY_NAME}
    )
  endforeach()
endmacro()

macro(_find_dependency_add_target)
  set(DEPENDENCY_TARGET_NAME ${DEPENDENCY_GROUP}${DEPENDENCY_PROJECT})
  set(DEPENDENCY_ALIAS_NAME  ${DEPENDENCY_GROUP}::${DEPENDENCY_PROJECT})

  add_library(${DEPENDENCY_TARGET_NAME} INTERFACE)

  target_link_libraries(${DEPENDENCY_TARGET_NAME}
    ${DEPENDENCY_TARGET_NAMES}
  )
  add_library(${DEPENDENCY_ALIAS_NAME}
    ALIAS
      ${DEPENDENCY_TARGET_NAME}
  )
endmacro()

macro(_find_dependency_store_metadata)
  set(DEPENDENCY_METADATA_PATH ${DEPENDENCY_PATH}/${DEPENDENCY_GROUP}.${DEPENDENCY_PROJECT}.md.cmake)
  file(WRITE  ${DEPENDENCY_METADATA_PATH}
    "FIND_DEPENDENCY_PATH=${FIND_DEPENDENCY_PATH}\n"
    "FIND_DEPENDENCY_GIT_URL=${FIND_DEPENDENCY_GIT_URL}\n"
    "FIND_DEPENDENCY_GIT_DOMAIN=${FIND_DEPENDENCY_GIT_DOMAIN}\n"
    "DEPENDENCY_USE_SSH=${DEPENDENCY_USE_SSH}\n"
    "DEPENDENCY_USE_HTTPS=${DEPENDENCY_USE_HTTPS}\n"
    "DEPENDENCY_GROUP=${DEPENDENCY_GROUP}\n"
    "DEPENDENCY_PROJECT=${DEPENDENCY_PROJECT}\n"
    "DEPENDENCY_BRANCH=${DEPENDENCY_BRANCH}\n"
    "DEPENDENCY_URL=${DEPENDENCY_URL}\n"
    "DEPENDENCY_BUILD_OPTIONS=${DEPENDENCY_BUILD_OPTIONS}\n"
    "\n"
    "DEPENDENCY_GIT_COMMIT_ID=${DEPENDENCY_GIT_COMMIT_ID}\n"
    "DEPENDENCY_GIT_TIMESTAMP=${DEPENDENCY_GIT_TIMESTAMP}\n"
    "\n"
    "DEPENDENCY_PATH=${DEPENDENCY_PATH}\n"
    "DEPENDENCY_SOURCE_PATH=${DEPENDENCY_SOURCE_PATH}\n"
    "DEPENDENCY_BINARY_PATH=${DEPENDENCY_BINARY_PATH}\n"
    ""
    "DEPENDENCY_GIT_CLONE_RESULT=${DEPENDENCY_GIT_CLONE_RESULT}\n"
    "DEPENDENCY_CMAKE_RESULT=${DEPENDENCY_CMAKE_RESULT}\n"
    "DEPENDENCY_BUILD_RESULT=${DEPENDENCY_BUILD_RESULT}\n"
    ""
    "DEPENDENCY_TARGETS=${DEPENDENCY_TARGETS}\n"
    "DEPENDENCY_TARGET_NAMES=${DEPENDENCY_TARGET_NAMES}\n"
    ""
    "DEPENDENCY_TARGET_NAME=${DEPENDENCY_TARGET_NAME}\n"
    "DEPENDENCY_ALIAS_NAME=${DEPENDENCY_ALIAS_NAME}\n"
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
    _find_dependency_git_commit_id()

  endif()

  if (NOT EXISTS "${DEPENDENCY_BINARY_PATH}/CMakeCache.txt")
    _find_domo_package_gen_build()
    _find_domo_package_start_build()
    _find_dependency_git_timestamp()
  endif()

  _find_dependency_collect_targets()
  _find_dependency_add_target()
  _find_dependency_store_metadata()
endfunction()

# register_dependency(<dependency name>)
function(register_dependency dependency_name)
  set(DEPENDENCY_NAME ${dependency_name})

  export(TARGETS
      ${DEPENDENCY_NAME}
    FILE
      ${DEPENDENCY_NAME}.dep.cmake
    APPEND
    EXPORT_LINK_INTERFACE_LIBRARIES
  )
endfunction()
