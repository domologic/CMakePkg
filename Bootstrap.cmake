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

# Sources of CMakePkg project. Has to be located on the same Git server than the project itself
set(CMAKEPKG_REPOSITORY "domologic/CMakePkg.git")

# Global directory used for CMakePkg
if (NOT CMAKEPKG_FILES)
  set(CMAKEPKG_FILES "${CMAKE_CURRENT_BINARY_DIR}/CMakePkgFiles" CACHE INTERNAL "Path to cloned files from the CMakePkg repository")
endif()

# Global directory used to clone all packages
if (NOT CMAKEPKG_PACKAGES_DIR)
  set(CMAKEPKG_PACKAGES_DIR "${CMAKE_CURRENT_BINARY_DIR}/Packages" CACHE INTERNAL "Path to the downloaded dependencies")
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
if (NOT EXISTS ${CMAKEPKG_FILES})
  execute_process(
    COMMAND
      ${GIT_EXECUTABLE} clone "${CMAKEPKG_PROJECT_ROOT_URL}/${CMAKEPKG_REPOSITORY}" --depth 1 ${CMAKEPKG_FILES}
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
include(${CMAKEPKG_FILES}/Init.cmake)
