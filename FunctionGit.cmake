include_guard(GLOBAL)

find_package(Git REQUIRED)

set(GIT_DEFAULT_REVISION_DATA_TEMPLATE ${CMAKE_CURRENT_LIST_DIR}/RevisionData.hpp.cmake)

# git_pull(
#   PATH
#     <path>
#   RESULT
#     <result_variable>
# )
function(git_pull)
  cmake_parse_arguments(ARG
    ""
    "PATH;RESULT"
    ""
    ${ARGN}
  )

  if (NOT ARG_PATH)
    message(FATAL_ERROR "git_clone PATH argument missing!")
  endif()

  if (NOT ARG_RESULT)
    message(FATAL_ERROR "git_clone RESULT argument missing!")
  endif()

  execute_process(
    COMMAND
      ${GIT_EXECUTABLE} pull
    WORKING_DIRECTORY
      ${ARG_PATH}
    RESULT_VARIABLE
      RESULT
    ERROR_QUIET
    OUTPUT_QUIET
  )

  if (${RESULT} EQUAL "0")
    set(${ARG_RESULT} TRUE PARENT_SCOPE)
  else()
    set(${ARG_RESULT} FALSE PARENT_SCOPE)
  endif()
endfunction()

# git_clone(
#   URL
#     <url>
#   PATH
#     <path>
#   [BRANCH]
#     <branch>
#   RESULT
#     <result_variable>
#   [PULL]
# )
function(git_clone)
  cmake_parse_arguments(ARG
    "PULL"
    "URL;PATH;BRANCH;RESULT"
    ""
    ${ARGN}
  )

  if (NOT ARG_URL)
    message(FATAL_ERROR "git_clone URL argument missing!")
  endif()

  if (NOT ARG_PATH)
    message(FATAL_ERROR "git_clone PATH argument missing!")
  endif()

  if (NOT ARG_RESULT)
    message(FATAL_ERROR "git_clone RESULT argument missing!")
  endif()

  if (NOT ARG_BRANCH)
    set(ARG_BRANCH "master")
  endif()

  if (EXISTS ${ARG_PATH}/.git)
    if (ARG_PULL)
      git_pull(
        PATH
          ${ARG_PATH}
        RESULT
          ${ARG_RESULT}
      )
    endif()
    return()
  endif()

  execute_process(
    COMMAND
      ${GIT_EXECUTABLE} clone ${ARG_URL} --branch ${ARG_BRANCH} --depth 1 --recursive ${ARG_PATH}
    WORKING_DIRECTORY
      ${CMAKE_CURRENT_BINARY_DIR}
    RESULT_VARIABLE
      RESULT
    OUTPUT_QUIET
    ERROR_QUIET
  )

  if (${RESULT} EQUAL "0")
    set(${ARG_RESULT} TRUE PARENT_SCOPE)
  else()
    set(${ARG_RESULT} FALSE PARENT_SCOPE)
  endif()
endfunction()

# git_timestamp(
#   PATH
#     <path>
#   RESULT
#     <result_variable>
# )
function(git_timestamp)
  cmake_parse_arguments(ARG
    ""
    "PATH;RESULT"
    ""
    ${ARGN}
  )

  if (NOT ARG_PATH)
    message(FATAL_ERROR "git_timestamp PATH argument missing!")
  endif()

  if (NOT ARG_RESULT)
    message(FATAL_ERROR "git_timestamp RESULT argument missing!")
  endif()

  execute_process(
    COMMAND
      ${GIT_EXECUTABLE} show -s --format=%ci
    WORKING_DIRECTORY
      ${ARG_PATH}
    OUTPUT_VARIABLE
      RESULT
    ERROR_QUIET
    OUTPUT_STRIP_TRAILING_WHITESPACE
  )

  if (NOT RESULT)
    set(RESULT "1970-01-01 00:00:00 +0000")
    message("Could not get git timestamp. Result set to ${RESULT}")
  endif()

  set(${ARG_RESULT} ${RESULT} PARENT_SCOPE)
endfunction()

# git_commit_id(
#   PATH
#     <path>
#   RESULT
#     <result_variable>
# )
function(git_commit_id)
  cmake_parse_arguments(ARG
    ""
    "PATH;RESULT"
    ""
    ${ARGN}
  )

  if (NOT ARG_PATH)
    message(FATAL_ERROR "git_commit_id PATH argument missing!")
  endif()

  if (NOT ARG_RESULT)
    message(FATAL_ERROR "git_commit_id RESULT argument missing!")
  endif()

  execute_process(
    COMMAND
      ${GIT_EXECUTABLE} describe --long --match init --dirty=+ --abbrev=12 --always
    WORKING_DIRECTORY
      ${ARG_PATH}
    OUTPUT_VARIABLE
      RESULT
    ERROR_QUIET
    OUTPUT_STRIP_TRAILING_WHITESPACE
  )

  if (NOT RESULT)
    set(RESULT "unknown")
    message("Could not get git commit id. Result set to ${RESULT}")
  endif()

  set(${ARG_RESULT} ${RESULT} PARENT_SCOPE)
endfunction()

# git_branch(
#   PATH
#     <path>
#   RESULT
#     <result_variable>
# )
function(git_branch)
  cmake_parse_arguments(ARG
    ""
    "PATH;RESULT"
    ""
    ${ARGN}
  )

  if (NOT ARG_PATH)
    message(FATAL_ERROR "git_branch PATH argument missing!")
  endif()

  if (NOT ARG_RESULT)
    message(FATAL_ERROR "git_branch RESULT argument missing!")
  endif()

  execute_process(
    COMMAND
      ${GIT_EXECUTABLE} rev-parse --abbrev-ref HEAD
    WORKING_DIRECTORY
      ${ARG_PATH}
    OUTPUT_VARIABLE
      RESULT
    ERROR_QUIET
    OUTPUT_STRIP_TRAILING_WHITESPACE
  )

  if (NOT RESULT)
    set(RESULT "archived")
    message("Could not get git branch. Result set to ${RESULT}")
  endif()

  set(${ARG_RESULT} ${RESULT} PARENT_SCOPE)
endfunction()

# git_generate_revision_data(
#   [PROJECT]
#     <project>
#   [PATH]
#     <path>
#   [TEMPLATE]
#     <template>
# )
function(git_generate_revision_data)
  cmake_parse_arguments(GIT
    ""
    "PROJECT;PATH;TEMPLATE"
    ""
    ${ARGN}
  )

  if (NOT GIT_PROJECT)
    set(GIT_PROJECT ${CMAKE_PROJECT_NAME})
  endif()

  if (NOT GIT_PATH)
    set(GIT_PATH ${CMAKE_CURRENT_SOURCE_DIR})
  endif()

  if (NOT GIT_TEMPLATE)
    set(GIT_TEMPLATE ${GIT_DEFAULT_REVISION_DATA_TEMPLATE})
  endif()

  git_timestamp(
    PATH
      ${GIT_PATH}
    RESULT
      GIT_TIMESTAMP
  )

  git_commit_id(
    PATH
      ${GIT_PATH}
    RESULT
      GIT_COMMIT_ID
  )

  git_branch(
    PATH
      ${GIT_PATH}
    RESULT
      GIT_BRANCH
  )

  set(GIT_OUTPUT_FILE ${CMAKE_CURRENT_BINARY_DIR}/RevisionData/${GIT_PROJECT}/RevisionData.hpp)

  camelcase_to_underscore(
    VALUE
      ${GIT_PROJECT}
    RESULT
      GIT_PROJECT
    TOUPPER
  )

  configure_file(
    ${GIT_TEMPLATE}
    ${GIT_OUTPUT_FILE}
    @ONLY
  )

  add_library(${GIT_PROJECT}::RevisionData INTERFACE IMPORTED)
  set_target_properties(${GIT_PROJECT}::RevisionData
    PROPERTIES
      INTERFACE_INCLUDE_DIRECTORIES
        ${CMAKE_CURRENT_BINARY_DIR}/RevisionData
  )
endfunction()

# git_create_url(
#   DOMAIN
#     domain
#   GROUP
#     <group>
#   PROJECT
#     <project>
#   RESULT
#     <result>
#   [USE_HTTP]
#   [USE_HTTPS]
#   [USE_SSH]
# )
function(git_create_url)
  cmake_parse_arguments(ARG
    "USE_HTTP;USE_HTTPS;USE_SSH"
    "DOMAIN;GROUP;PROJECT;RESULT"
    ""
    ${ARGN}
  )

  if (NOT ARG_DOMAIN)
    message(FATAL_ERROR "git_create_url DOMAIN argument missing!")
  endif()

  if (NOT ARG_GROUP)
    message(FATAL_ERROR "git_create_url GROUP argument missing!")
  endif()

  if (NOT ARG_PROJECT)
    message(FATAL_ERROR "git_create_url PROJECT argument missing!")
  endif()

  if (NOT ARG_RESULT)
    message(FATAL_ERROR "git_create_url RESULT argument missing!")
  endif()

  if (${ARG_USE_SSH})
    set(${ARG_RESULT} "git@${ARG_DOMAIN}:${ARG_GROUP}/${ARG_PROJECT}.git"     PARENT_SCOPE)
  elseif (${ARG_USE_HTTPS})
    set(${ARG_RESULT} "https://${ARG_DOMAIN}/${ARG_GROUP}/${ARG_PROJECT}.git" PARENT_SCOPE)
  else()
    set(${ARG_RESULT} "http://${ARG_DOMAIN}/${ARG_GROUP}/${ARG_PROJECT}.git"  PARENT_SCOPE)
  endif()
endfunction()
