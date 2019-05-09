include_guard(GLOBAL)

# build_generate(
#   SOURCE_PATH
#     <source_path>
#   BINARY_PATH
#     <binary_path>
#   RESULT
#     <result>
#   [OPTIONS]
#     <some>
#     <options>
# )
function(build_generate)
  cmake_parse_arguments(ARG
    ""
    "SOURCE_PATH;BINARY_PATH;RESULT"
    "OPTIONS"
    ${ARGN}
  )

  if (NOT ARG_SOURCE_PATH)
    message(FATAL_ERROR "build_generate SOURCE_PATH argument missing!")
  endif()

  if (NOT ARG_BINARY_PATH)
    message(FATAL_ERROR "build_generate BINARY_PATH argument missing!")
  endif()

  if (NOT ARG_RESULT)
    message(FATAL_ERROR "build_generate RESULT argument missing!")
  endif()

  execute_process(
    COMMAND
      ${CMAKE_COMMAND} -S ${ARG_SOURCE_PATH} -B${ARG_BINARY_PATH} -T "${CMAKE_TOOLCHAIN_FILE}" -G "${CMAKE_GENERATOR}" ${OUTPUT_DIRECTORY} ${ARG_OPTIONS}
    WORKING_DIRECTORY
      ${ARG_BINARY_PATH}
    RESULT_VARIABLE
      RESULT
    OUTPUT_QUIET
  )

  if (RESULT EQUAL "0")
    set(${ARG_RESULT} TRUE PARENT_SCOPE)
  else()
    set(${ARG_RESULT} FALSE PARENT_SCOPE)
  endif()
endfunction()

# build_start(
#   PATH
#     <path>
#   RESULT
#     <result>
# )
macro(build_start)
  cmake_parse_arguments(ARG
    ""
    "PATH;RESULT"
    ""
    ${ARGN}
  )

  if (NOT ARG_PATH)
    message(FATAL_ERROR "build_generate PATH argument missing!")
  endif()

  if (NOT ARG_RESULT)
    message(FATAL_ERROR "build_generate RESULT argument missing!")
  endif()

  execute_process(
    COMMAND
      ${CMAKE_COMMAND} --build ${ARG_PATH}
    WORKING_DIRECTORY
      ${ARG_PATH}
    RESULT_VARIABLE
      RESULT
    OUTPUT_QUIET
  )

  if (RESULT EQUAL "0")
    set(${ARG_RESULT} TRUE PARENT_SCOPE)
  else()
    set(${ARG_RESULT} FALSE PARENT_SCOPE)
  endif()
endmacro()
