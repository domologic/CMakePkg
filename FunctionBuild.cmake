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
    "SOURCE_PATH;BINARY_PATH"
    "OPTIONS"
    ${ARGN}
  )

  if (NOT ARG_SOURCE_PATH)
    message(FATAL_ERROR "build_generate SOURCE_PATH argument missing!")
  endif()

  if (NOT ARG_BINARY_PATH)
    message(FATAL_ERROR "build_generate BINARY_PATH argument missing!")
  endif()

  if (UNIX)
    set(PLATFORM_FLAGS "-DCMAKE_BUILD_TYPE=${BUILD_TYPE}")
  endif()

  execute_process(
    COMMAND
      ${CMAKE_COMMAND} -S ${ARG_SOURCE_PATH} -B${ARG_BINARY_PATH} -T "${CMAKE_TOOLCHAIN_FILE}" -G "${CMAKE_GENERATOR}" ${PLATFORM_FLAGS} -DOUTPUT_DIRECTORY=${OUTPUT_DIRECTORY} ${ARG_OPTIONS}
    WORKING_DIRECTORY
      ${ARG_BINARY_PATH}
    OUTPUT_QUIET
  )

  if (WIN32)
    set(PLATFORM_FLAGS --config ${BUILD_TYPE})
  endif()

  execute_process(
    COMMAND
      ${CMAKE_COMMAND} --build ${ARG_PATH} ${PLATFORM_FLAGS}
    WORKING_DIRECTORY
      ${ARG_PATH}
    OUTPUT_QUIET
  )
endfunction()
