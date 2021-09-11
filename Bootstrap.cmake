#
# Bootstrap script loading the CMakePkg Library
# Hosted on GitHub: https://gist.github.com/domologic/8e21149b956276a848d7fb3be2a4c71a
#
# To make it available, include the following lines into your CMakeLists.txt before the project keyword:
#   //---
#   if(NOT DEFINED CMAKEPKG_BOOTSTRAP_FILE)
#     set(CMAKEPKG_BOOTSTRAP_FILE "${CMAKE_BINARY_DIR}/Bootstrap.cmake")
#     file(DOWNLOAD https://gist.github.com/domologic/8e21149b956276a848d7fb3be2a4c71a/raw/Bootstrap.cmake ${CMAKEPKG_BOOTSTRAP_FILE})
#   endif()
#   include(${CMAKEPKG_BOOTSTRAP_FILE})
#   //---
#
# Important Variables:
#
#   CMAKEPKG_MODE
#     JOINED (Default): Dependencies will be checked-out before configuration step, and built at build time
#     PREBUILD: Dependencies will be checked-out and built immediately at configuration time
#
#   CMAKEPKG_BOOTSTRAP_FILE
#     Name of the CMakePkg Bootstrap File. It not set, a default version will be fetched from GitHub.
#
#   CMAKEPKG_PRIVATE_KEY_FILE
#     Path to file holding the ssh private key, used by git to check out. This makes only sense in case
#     of a git@... URL
#
#   CMAKEPKG_PROJECT_ROOT_URL
#     Base URL used for all Git Repositories. Will be determined from the project base repository.
#
#   CMAKEPKG_SELF_DIR
#     Cloned sources of the CMakePkg project. Set to ${CMAKE_CURRENT_BINARY_DIR}/CMakePkgFiles by default.
#
#   CMAKEPKG_DEPENDENCIES_DIR
#     Used to store the dependencies when CMAKEPKG_MODE=PREBUILD.
#     Set to ${CMAKE_CURRENT_BINARY_DIR}/_deps by default.
#
#   CMAKEPKG_TAG_FILE
#     File with git tags of the packages used to checkout.
#     Each package is separated by a ':' from the tag name.
#

include_guard(GLOBAL)

if (DEFINED CMAKEPKG_PRIVATE_KEY_FILE)
  set(ENV{GIT_SSH_COMMAND} "ssh -F /dev/null -i ${CMAKEPKG_PRIVATE_KEY_FILE} -o 'StrictHostKeyChecking=no' -o 'UserKnownHostsFile=/dev/null'")
endif()

# Sources of CMakePkg project repository (Group/Project). Has to be located on the same Git server than the project itself
set(CMAKEPKG_SELF_REPO "domologic/CMakePkg.git")

# Global directory used to checkout the CMakePkg project repository
if (NOT DEFINED CMAKEPKG_SELF_DIR)
  set(CMAKEPKG_SELF_DIR "${CMAKE_CURRENT_BINARY_DIR}/CMakePkgFiles" CACHE INTERNAL "Path to cloned files from the CMakePkg repository")
endif()

# Global directory used to checkout all dependencies
if (NOT DEFINED CMAKEPKG_DEPENDENCIES_DIR)
  set(CMAKEPKG_DEPENDENCIES_DIR "${CMAKE_CURRENT_BINARY_DIR}/_deps" CACHE INTERNAL "Path to the downloaded dependencies")
endif()

find_package(Git QUIET)

# query git remote url which will be used to locate dependencies
execute_process(
  COMMAND
    ${GIT_EXECUTABLE} remote get-url origin
  WORKING_DIRECTORY
     ${CMAKE_SOURCE_DIR}
   OUTPUT_VARIABLE
     CMAKEPKG_PROJECT_ROOT_URL
   OUTPUT_STRIP_TRAILING_WHITESPACE
)

if (NOT CMAKEPKG_PROJECT_ROOT_URL)
  message(FATAL_ERROR "Could not get current git remote origin url!")
endif()

if(CMAKEPKG_PROJECT_ROOT_URL MATCHES "^git@.*")
  # ensure that ":" is always followed by "/"
  string(REGEX REPLACE ":" ":/" CMAKEPKG_PROJECT_ROOT_URL ${CMAKEPKG_PROJECT_ROOT_URL})
  string(REGEX REPLACE "/+" "/" CMAKEPKG_PROJECT_ROOT_URL ${CMAKEPKG_PROJECT_ROOT_URL})
endif()
# remove last two subfolders in URL (project name)
string(REGEX REPLACE "/+$" "" CMAKEPKG_PROJECT_ROOT_URL ${CMAKEPKG_PROJECT_ROOT_URL})
string(REGEX REPLACE "/[^/]*$" "" CMAKEPKG_PROJECT_ROOT_URL ${CMAKEPKG_PROJECT_ROOT_URL})
string(REGEX REPLACE "/[^/]*$" "" CMAKEPKG_PROJECT_ROOT_URL ${CMAKEPKG_PROJECT_ROOT_URL})

# global git domain
set(CMAKEPKG_PROJECT_ROOT_URL ${CMAKEPKG_PROJECT_ROOT_URL} CACHE STRING "git domain")
message(STATUS "Using '${CMAKEPKG_PROJECT_ROOT_URL}' as git root for dependency resolution")

# read CMakePkgTags.txt file from CMAKE_SOURCE_DIR
if (DEFINED CMAKEPKG_TAG_FILE)
  if (NOT EXISTS ${CMAKEPKG_TAG_FILE})
    message(FATAL_ERROR "CMAKEPKG_TAG_FILE '${CMAKEPKG_TAG_FILE}' does not exist!")
  else()
    message(STATUS "Loading Tags File '${CMAKEPKG_TAG_FILE}'")
    file(STRINGS ${CMAKEPKG_TAG_FILE} CMAKEPKG_TAGS REGEX "^[ ]*[^#].*")
    foreach(LINE IN LISTS CMAKEPKG_TAGS)
      string(REPLACE " " "" EXPR "${LINE}")
      if (EXPR MATCHES ".*:.*")
        string(REPLACE ":" ";" EXPR "${EXPR}")
        list(POP_FRONT EXPR PACKAGE)
        if (NOT "${PACKAGE}" STREQUAL "")
          string(REPLACE "/" "_" PACKAGE "${PACKAGE}")
          string(TOLOWER "${PACKAGE}" PACKAGE)
          set("${PACKAGE}_TAG" "${EXPR}")
        endif()
      else()
        message(WARNING "Ignoring expression in line '${LINE}' of CMAKEPKG_TAG_FILE '${CMAKEPKG_TAG_FILE}'")
      endif()
    endforeach()
  endif()
endif()

# clone the cmake module library
if (NOT EXISTS ${CMAKEPKG_SELF_DIR})
  execute_process(
    COMMAND
      ${GIT_EXECUTABLE} clone "${CMAKEPKG_PROJECT_ROOT_URL}/${CMAKEPKG_SELF_REPO}" --depth 1 ${CMAKEPKG_SELF_DIR}
    WORKING_DIRECTORY
      ${CMAKE_CURRENT_BINARY_DIR}
    RESULT_VARIABLE
      RESULT
    OUTPUT_QUIET
  )

  if (NOT ${RESULT} EQUAL "0")
    message(FATAL_ERROR "Could not clone CMakePkg sources from ${CMAKEPKG_PROJECT_ROOT_URL}/${CMAKEPKG_SELF_REPO}")
  endif()
endif()

# load the library
include(${CMAKEPKG_SELF_DIR}/Init.cmake)
