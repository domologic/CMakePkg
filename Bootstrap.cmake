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
#   CMAKEPKG_PROJECT_ROOT_URL
#     Base URL used for all Git Repositories. Will be determined from the project base repository.
#
#   CMAKEPKG_FILES_DIR
#     Cloned sources of the CMakePkg project. Is set to ${CMAKE_CURRENT_BINARY_DIR}/CMakePkgFiles by default.
#
#   CMAKEPKG_DEPENDENCIES_DIR
#     Used to store the dependencies when CMAKEPKG_MODE=PREBUILD.
#     Is set by default to ${CMAKE_CURRENT_BINARY_DIR}/_deps
#

include_guard(GLOBAL)

# Sources of CMakePkg project (Group/Project). Has to be located on the same Git server than the project itself
set(CMAKEPKG_REPOSITORY "domologic/CMakePkg.git")

# Global directory used for CMakePkg
if (NOT CMAKEPKG_FILES_DIR)
  set(CMAKEPKG_FILES_DIR "${CMAKE_CURRENT_BINARY_DIR}/CMakePkgFiles" CACHE INTERNAL "Path to cloned files from the CMakePkg repository")
endif()

# Global directory used to clone all dependencies
if (NOT CMAKEPKG_DEPENDENCIES_DIR)
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
  # remove everything following separator ":" and add ":" again
  string(REGEX REPLACE ":.*$" "" CMAKEPKG_PROJECT_ROOT_URL ${CMAKEPKG_PROJECT_ROOT_URL})
  string(CONCAT CMAKEPKG_PROJECT_ROOT_URL ${CMAKEPKG_PROJECT_ROOT_URL} ":")
else()
  # remove last 2 subfolders in URL (project name)
  string(REGEX REPLACE "\/[^\/]*$" "" CMAKEPKG_PROJECT_ROOT_URL ${CMAKEPKG_PROJECT_ROOT_URL})
  string(REGEX REPLACE "\/[^\/]*$" "" CMAKEPKG_PROJECT_ROOT_URL ${CMAKEPKG_PROJECT_ROOT_URL})
endif()

# global git domain
set(CMAKEPKG_PROJECT_ROOT_URL ${CMAKEPKG_PROJECT_ROOT_URL} CACHE STRING "git domain")
message(STATUS "Using ${CMAKEPKG_PROJECT_ROOT_URL}' as git root for dependency resolution")

# clone the cmake module library
if (NOT EXISTS ${CMAKEPKG_FILES_DIR})
  execute_process(
    COMMAND
      ${GIT_EXECUTABLE} clone "${CMAKEPKG_PROJECT_ROOT_URL}/${CMAKEPKG_REPOSITORY}" --depth 1 ${CMAKEPKG_FILES_DIR}
    WORKING_DIRECTORY
      ${CMAKE_CURRENT_BINARY_DIR}
    RESULT_VARIABLE
      RESULT
    OUTPUT_QUIET
  )

  if (NOT ${RESULT} EQUAL "0")
    message(FATAL_ERROR "Could not clone CMakePkg sources from ${CMAKEPKG_PROJECT_ROOT_URL}/${CMAKEPKG_REPOSITORY}")
  endif()
endif()

# load the library
include(${CMAKEPKG_FILES_DIR}/Init.cmake)
