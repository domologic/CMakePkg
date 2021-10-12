#
# Bootstrap script loading the CMakePkg Library
# Hosted on GitHub: https://gist.github.com/domologic/8e21149b956276a848d7fb3be2a4c71a
#
# To make it available, include the following lines into your CMakeLists.txt before the project keyword:
#   //---
#   if (NOT DEFINED CMAKEPKG_BOOTSTRAP_FILE)
#     set(CMAKEPKG_BOOTSTRAP_FILE "${CMAKE_BINARY_DIR}/Bootstrap.cmake")
#     file(DOWNLOAD https://gist.github.com/domologic/8e21149b956276a848d7fb3be2a4c71a/raw/Bootstrap.cmake ${CMAKEPKG_BOOTSTRAP_FILE})
#   endif()
#   include(${CMAKEPKG_BOOTSTRAP_FILE})
#   //---
#
# Important Variables:
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
#   CMAKEPKG_SOURCE_DIR
#     Cloned sources of the CMakePkg project. Set to ${CMAKE_CURRENT_BINARY_DIR}/CMakePkgFiles by default.
#
#   CMAKEPKG_TAG_FILE
#     File with git tags of the packages used to checkout.
#     Each package is separated by a ':' from the tag name.
#
#   CMAKEPKG_BRANCH
#     Specifies the CMakePkg branch that should be checked out.
#     Default is master
#

include_guard(GLOBAL)

find_package(Git QUIET REQUIRED)

if (DEFINED CMAKEPKG_PRIVATE_KEY_FILE)
  set(ENV{GIT_SSH_COMMAND} "ssh -F /dev/null -i ${CMAKEPKG_PRIVATE_KEY_FILE} -o 'StrictHostKeyChecking=no' -o 'UserKnownHostsFile=/dev/null'")
endif()

if (NOT DEFINED CMAKEPKG_BRANCH)
  set(CMAKEPKG_BRANCH "master" CACHE INTERNAL "CMakePkg repository branch")
endif()

# Global directory used to checkout the CMakePkg project repository
if (NOT DEFINED CMAKEPKG_SOURCE_DIR)
  set(CMAKEPKG_SOURCE_DIR "${CMAKE_CURRENT_BINARY_DIR}/CMakePkg" CACHE INTERNAL "Path to cloned files from the CMakePkg repository")
endif()

if (NOT DEFINED CMAKEPKG_PROJECT_ROOT_URL)
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

  if (CMAKEPKG_PROJECT_ROOT_URL MATCHES "^git@.*")
    # ensure that ":" is always followed by "/"
    string(REGEX REPLACE ":" ":/" CMAKEPKG_PROJECT_ROOT_URL ${CMAKEPKG_PROJECT_ROOT_URL})
    string(REGEX REPLACE "/+" "/" CMAKEPKG_PROJECT_ROOT_URL ${CMAKEPKG_PROJECT_ROOT_URL})
  endif()
  # remove last two subfolders in URL (project name)
  string(REGEX REPLACE "/+$"     "" CMAKEPKG_PROJECT_ROOT_URL ${CMAKEPKG_PROJECT_ROOT_URL})
  string(REGEX REPLACE "/[^/]*$" "" CMAKEPKG_PROJECT_ROOT_URL ${CMAKEPKG_PROJECT_ROOT_URL})
  string(REGEX REPLACE "/[^/]*$" "" CMAKEPKG_PROJECT_ROOT_URL ${CMAKEPKG_PROJECT_ROOT_URL})

  # global git domain
  set(CMAKEPKG_PROJECT_ROOT_URL ${CMAKEPKG_PROJECT_ROOT_URL} CACHE STRING "git domain")
  message(STATUS "Using '${CMAKEPKG_PROJECT_ROOT_URL}' as git root for dependency resolution")
endif()

# clone the cmake module library
if (NOT EXISTS ${CMAKEPKG_SOURCE_DIR})
  execute_process(
    COMMAND
      ${GIT_EXECUTABLE} clone -b ${CMAKEPKG_BRANCH} --depth 1 "${CMAKEPKG_PROJECT_ROOT_URL}/domologic/CMakePkg.git" ${CMAKEPKG_SOURCE_DIR}
    WORKING_DIRECTORY
      ${CMAKE_CURRENT_BINARY_DIR}
    RESULT_VARIABLE
      RESULT
    OUTPUT_QUIET
  )

  if (NOT ${RESULT} EQUAL "0")
    message(FATAL_ERROR "Could not clone CMakePkg sources from ${CMAKEPKG_PROJECT_ROOT_URL}")
  endif()
endif()

# load the library
include(${CMAKEPKG_SOURCE_DIR}/Init.cmake)
