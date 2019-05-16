include_guard(GLOBAL)

if (WIN32)
  set(CMAKE_DEPENDENCY_PATH "$ENV{USERPROFILE}/.cmake" CACHE INTERNAL "path to the downloaded dependencies")
else()
  set(CMAKE_DEPENDENCY_PATH "$ENV{HOME}/.cmake"        CACHE INTERNAL "path to the downloaded dependencies")
endif()

set(CMAKE_SCRIPT_PATH "${CMAKE_DEPENDENCY_PATH}/Scripts" CACHE INTERNAL "path to cmake scripts")

find_package(Git QUIET)

execute_process(
  COMMAND
    ${GIT_EXECUTABLE} remote get-url origin
  WORKING_DIRECTORY
    ${CMAKE_SOURCE_DIR}
  OUTPUT_VARIABLE
  URL
  OUTPUT_STRIP_TRAILING_WHITESPACE
  ERROR_QUIET
)

if (NOT URL)
  message(FATAL_ERROR "Could not get current git remote origin url!")
endif()

string(REGEX REPLACE "git@|https://|http://" "" CMAKE_DEPENDENCY_GIT_DOMAIN ${URL})
string(REGEX REPLACE "[:/].*"                "" CMAKE_DEPENDENCY_GIT_DOMAIN ${CMAKE_DEPENDENCY_GIT_DOMAIN})

set(CMAKE_DEPENDENCY_GIT_DOMAIN ${CMAKE_DEPENDENCY_GIT_DOMAIN} CACHE STRING "git domain")

if (NOT EXISTS ${CMAKE_SCRIPT_PATH})
  file(MAKE_DIRECTORY ${CMAKE_SCRIPT_PATH})

  execute_process(
    COMMAND
      ${GIT_EXECUTABLE} clone "http://${CMAKE_DEPENDENCY_GIT_DOMAIN}/domologic/CMakeModule.git" --depth 1 ${CMAKE_SCRIPT_PATH}
    WORKING_DIRECTORY
      ${CMAKE_SCRIPT_PATH}
    RESULT_VARIABLE
      RESULT
    OUTPUT_QUIET
    ERROR_QUIET
  )

  if (NOT ${RESULT} EQUAL "0")
    message(FATAL_ERROR "Could not download cmake scripts!")
  endif()
else()
  execute_process(
    COMMAND
      ${GIT_EXECUTABLE} pull
    WORKING_DIRECTORY
      ${CMAKE_SCRIPT_PATH}
    RESULT_VARIABLE
      RESULT
    OUTPUT_QUIET
    ERROR_QUIET
  )

  if (NOT ${RESULT} EQUAL "0")
    message(WARNING "Could not update cmake scripts!")
  endif()
endif()

include(${CMAKE_SCRIPT_PATH}/Init.cmake)
