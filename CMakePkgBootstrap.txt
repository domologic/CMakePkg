#
# Bootstrap script loading the CMake Modules Library
# Hosted on GitHub: https://gist.github.com/domologic/8e21149b956276a848d7fb3be2a4c71a
#
# Include following code before the project keyword to make the library available for use:
#
#    file(DOWNLOAD https://gist.github.com/domologic/8e21149b956276a848d7fb3be2a4c71a/raw/CMakePkgBootstrap.txt ${CMAKE_BINARY_DIR}/CMakePkgBootstrap.txt)
#    include(${CMAKE_BINARY_DIR}/CMakePkgBootstrap.txt)
#

include_guard(GLOBAL)

# Global dependency path
if (NOT DOMOLOGIC_DEPENDENCY_PATH)
  set(DOMOLOGIC_DEPENDENCY_PATH "${CMAKE_CURRENT_BINARY_DIR}/Domologic" CACHE INTERNAL "Path to the downloaded dependencies")
endif()

# Global script location
set(DOMOLOGIC_SCRIPT_PATH "${DOMOLOGIC_DEPENDENCY_PATH}/Scripts" CACHE INTERNAL "Path to CMake scripts")

find_package(Git QUIET)

if (GITLAB_PIPELINE)
  set(DOMOLOGIC_DEPENDENCY_GIT_DOMAIN "gitlab.domologic")
else()
  # query git remote url which will be used to locate dependencies
  execute_process(
    COMMAND
      ${GIT_EXECUTABLE} remote get-url origin
    WORKING_DIRECTORY
      ${CMAKE_SOURCE_DIR}
    OUTPUT_VARIABLE
      URL
    OUTPUT_STRIP_TRAILING_WHITESPACE
  )

  if (NOT URL)
    message(FATAL_ERROR "Could not get current git remote origin url!")
  endif()

  # extract git domain for dependency fetching
  string(REGEX REPLACE "git@|https://|http://"           "" DOMOLOGIC_DEPENDENCY_GIT_DOMAIN ${URL})
  string(REGEX REPLACE "(\/[a-zA-Z-]+\/[a-zA-Z-]+\.git)" "" DOMOLOGIC_DEPENDENCY_GIT_DOMAIN ${DOMOLOGIC_DEPENDENCY_GIT_DOMAIN})
endif()

# global git domain
set(DOMOLOGIC_DEPENDENCY_GIT_DOMAIN ${DOMOLOGIC_DEPENDENCY_GIT_DOMAIN} CACHE STRING "git domain")
message(STATUS "Using ${DOMOLOGIC_DEPENDENCY_GIT_DOMAIN}' as git root for dependency resolution")

# clone the cmake module library
if (NOT EXISTS ${DOMOLOGIC_SCRIPT_PATH})
  file(MAKE_DIRECTORY ${DOMOLOGIC_SCRIPT_PATH})

  execute_process(
    COMMAND
      ${GIT_EXECUTABLE} clone "http://${DOMOLOGIC_DEPENDENCY_GIT_DOMAIN}/domologic/CMakePkg.git" --depth 1 ${DOMOLOGIC_SCRIPT_PATH}
    WORKING_DIRECTORY
      ${DOMOLOGIC_SCRIPT_PATH}
    RESULT_VARIABLE
      RESULT
    OUTPUT_QUIET
  )

  if (NOT ${RESULT} EQUAL "0")
    message(FATAL_ERROR "Could not download CMake scripts!")
  endif()
endif()

# load the library
include(${DOMOLOGIC_SCRIPT_PATH}/Init.cmake)
