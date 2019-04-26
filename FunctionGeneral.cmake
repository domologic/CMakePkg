include_guard(GLOBAL)

# camelcase_to_underscore(
#   VALUE
#     <value>
#   RESULT
#     <result>
#   [TOUPPER]
#   [TOLOWER]
# )
function(camelcase_to_underscore)
  cmake_parse_arguments(ARG
    "TOUPPER;TOLOWER"
    "VALUE;RESULT"
    ""
    ${ARGN}
  )

  if (NOT ARG_VALUE)
    message(FATAL_ERROR "camelcase_to_underscore VALUE argument missing!")
  endif()

  if (NOT ARG_RESULT)
    message(FATAL_ERROR "camelcase_to_underscore RESULT argument missing!")
  endif()

  string(REGEX REPLACE "(.)([A-Z][a-z]+)"  "\\1_\\2" VALUE ${ARG_VALUE})
  string(REGEX REPLACE "([a-z0-9])([A-Z])" "\\1_\\2" VALUE ${VALUE})

  if (ARG_TOUPPER)
    string(TOUPPER ${VALUE} VALUE)
  elseif(ARG_TOLOWER)
    string(TOLOWER ${VALUE} VALUE)
  endif()

  set(${ARG_RESULT} ${VALUE} PARENT_SCOPE)
endfunction()
