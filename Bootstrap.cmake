include_guard(GLOBAL)

if (NOT DOMOLOGIC_DEPENDENCY_PATH)
  set(DOMOLOGIC_DEPENDENCY_PATH "${CMAKE_CURRENT_BINARY_DIR}/Domologic"     CACHE INTERNAL "path to the downloaded dependencies")
endif()

set(DOMOLOGIC_SCRIPT_PATH     "${DOMOLOGIC_DEPENDENCY_PATH}/Scripts"  CACHE INTERNAL "path to cmake scripts")

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

string(REGEX REPLACE "git@|https://|http://" "" DOMOLOGIC_DEPENDENCY_GIT_DOMAIN ${URL})
string(REGEX REPLACE "[:/].*"                "" DOMOLOGIC_DEPENDENCY_GIT_DOMAIN ${DOMOLOGIC_DEPENDENCY_GIT_DOMAIN})

set(DOMOLOGIC_DEPENDENCY_GIT_DOMAIN ${DOMOLOGIC_DEPENDENCY_GIT_DOMAIN} CACHE STRING "git domain")

if (NOT EXISTS ${DOMOLOGIC_SCRIPT_PATH})
  file(MAKE_DIRECTORY ${DOMOLOGIC_SCRIPT_PATH})

  execute_process(
    COMMAND
      ${GIT_EXECUTABLE} clone "http://${DOMOLOGIC_DEPENDENCY_GIT_DOMAIN}/domologic/CMakeModule.git" --depth 1 ${DOMOLOGIC_SCRIPT_PATH}
    WORKING_DIRECTORY
      ${DOMOLOGIC_SCRIPT_PATH}
    RESULT_VARIABLE
      RESULT
    OUTPUT_QUIET
    ERROR_QUIET
  )

  if (NOT ${RESULT} EQUAL "0")
    message(FATAL_ERROR "Could not download cmake scripts!")
  endif()
endif()

include(${DOMOLOGIC_SCRIPT_PATH}/Init.cmake)
