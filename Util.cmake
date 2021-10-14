include_guard(GLOBAL)

function(generate_tags_file TAGS_FILE_PATH)
  find_package(Git QUIET REQUIRED)

  if (EXISTS ${TAGS_FILE_PATH})
    file(REMOVE ${TAGS_FILE_PATH})
  endif()

  foreach(PACKAGE CMAKEPKG_PACKAGE_LIST)
    execute_process(
      COMMAND "${GIT_EXECUTABLE}" rev-parse HEAD
      WORKING_DIRECTORY "${${PACKAGE}_SOURCE_DIR}"
      OUTPUT_VARIABLE MODULE_TAG
      OUTPUT_STRIP_TRAILING_WHITESPACE
      ERROR_QUIET
    )

    file(APPEND ${TAGS_FILE_PATH} "${PACKAGE}: {MODULE_TAG}\n")
  endforeach()
endfunction()

function(load_tags_file)
  if (NOT DEFINED CMAKEPKG_TAG_FILE)
    return()
  endif()

  if (NOT EXISTS ${CMAKEPKG_TAG_FILE})
    message(WARNING "Tags file '${CMAKEPKG_TAG_FILE}' does not exist!")
    return()
  endif()

  message(STATUS "Loading Tags File '${CMAKEPKG_TAG_FILE}'")
  file(STRINGS ${CMAKEPKG_TAG_FILE} CMAKEPKG_TAGS REGEX "^[ ]*[^#].*")
  foreach (LINE IN LISTS CMAKEPKG_TAGS)
    string(REPLACE " " "" EXPR "${LINE}")
    if (EXPR MATCHES ".*:.*")
      string(REPLACE ":" ";" EXPR "${EXPR}")
      list(GET EXPR 0 PACKAGE_ID)
      list(GET EXPR 1 TAG)
      if (NOT "${PACKAGE_ID}" STREQUAL "")
        string(REPLACE "/" "_" PACKAGE_ID "${PACKAGE_ID}")
        string(TOLOWER "${PACKAGE_ID}" PACKAGE_ID)
        set("${PACKAGE_ID}_TAG" "${TAG}" CACHE INTERNAL "Revision of the ${PACKAGE_ID} package")
      endif()
    else()
      message(WARNING "Ignoring expression in line '${LINE}' of CMAKEPKG_TAG_FILE '${CMAKEPKG_TAG_FILE}'")
    endif()
  endforeach()
endfunction()
