include_guard(GLOBAL)

#
# Adds a post build objcopy event to the given target.
#
# target_objcopy(<target>
#   [<OUTPUT_FORMAT>]
#     [SUFFIX]
#       "suffix"
#     [ARGS]
#       <args...>
# )
#
# Generates a custom output file from the given target using objcopy command. Multiple output formats may be providen.
# The command does nothing if the toolchain does not provide any objcopy command.
# Actual supported output formats may differ from recognized output formats depending on the objcopy command.
#
# Recognized output formats are:
#   elf32-big
#   elf32-bigarm
#   elf32-bigarm-fdpic
#   elf32-bigmips
#   elf32-i386
#   elf32-iamcu
#   elf32-little
#   elf32-littlearm
#   elf32-littlearm-fdpic
#   elf32-littleriscv
#   elf32-ntradbigmips
#   elf32-ntradlittlemips
#   elf32-powerpc
#   elf32-powerpcle
#   elf32-sparc
#   elf32-sparcel
#   elf32-tradbigmips
#   elf32-tradlittlemips
#   elf32-x86-64
#   elf64-aarch64
#   elf64-littleaarch64
#   elf64-littleriscv
#   elf64-powerpc
#   elf64-powerpcle
#   elf64-tradbigmips
#   elf64-tradlittlemips
#   elf64-x86-64
#   plugin
#   srec
#   symbolsrec
#   verilog
#   tekhex
#   binary
#   ihex
#
# Every output format can be further customized:
#
# [PROJECT_AS_OUTPUT_NAME]
#  The project name should be used as the output filename.
# [PREFIX]
#   Specifies optional custom prefix of the output file.
# [SUFFIX]
#   Specifies optional custom suffix of the output file.
# [OUTPUT_NAME]
#   Specifies optional custom output filename.
# [OUTPUT_DIRECTORY]
#   Specifies optional output directory.
# [ARGS]
#   Specifies optional arguments that should be passed to objcopy. See objcopy documentation for more details.
#
function(target_objcopy TARGET)
  if (NOT DEFINED CMAKE_OBJCOPY)
    return()
  endif()

  set(KNOWN_OUTPUT_FORMATS
    ELF32_BIG
    ELF32_BIGARM
    ELF32_BIGARM_FDPIC
    ELF32_BIGMIPS
    ELF32_I386
    ELF32_IAMCU
    ELF32_LITTLE
    ELF32_LITTLEARM
    ELF32_LITTLEARM_FDPIC
    ELF32_LITTLERISCV
    ELF32_NTRADBIGMIPS
    ELF32_NTRADLITTLEMIPS
    ELF32_POWERPC
    ELF32_POWERPCLE
    ELF32_SPARC
    ELF32_SPARCEL
    ELF32_TRADBIGMIPS
    ELF32_TRADLITTLEMIPS
    ELF32_X86_64
    ELF64_AARCH64
    ELF64_LITTLEAARCH64
    ELF64_LITTLERISCV
    ELF64_POWERPC
    ELF64_POWERPCle
    ELF64_TRADMIGMIPS
    ELF64_TRADLITTLEMIS
    ELF64_X86_64
    PLUGIN
    SREC
    SYMBOLSREC
    VERILOG
    TEKHEX
    BINARY
    IHEX
  )

  cmake_parse_arguments(OUTPUT_FORMAT
    ""
    ""
    "${KNOWN_OUTPUT_FORMATS}"
    ${ARGN}
  )

  cmake_parse_arguments(OUTPUT_FORMAT_NOARGS
    "${KNOWN_OUTPUT_FORMATS}"
    ""
    ""
    ${OUTPUT_FORMAT_KEYWORDS_MISSING_VALUES}
  )

  foreach(KNOWN_OUTPUT_FORMAT ${KNOWN_OUTPUT_FORMATS})
    if (OUTPUT_FORMAT_${KNOWN_OUTPUT_FORMAT} OR OUTPUT_FORMAT_NOARGS_${KNOWN_OUTPUT_FORMAT})
      string(TOLOWER "${KNOWN_OUTPUT_FORMAT}" OUTPUT_FORMAT)
      string(REPLACE "_" "-" "${OUTPUT_FORMAT}" OUTPUT_FORMAT)

      cmake_parse_arguments(PARAM
        "PROJECT_AS_OUTPUT_NAME"
        "PREFIX;SUFFIX;OUTPUT_NAME;OUTPUT_DIRECTORY"
        "ARGS"
        ${OUTPUT_FORMAT_${KNOWN_OUTPUT_FORMAT}}
      )

      if (NOT DEFINED PARAM_SUFFIX)
        set(PARAM_SUFFIX ".${OUTPUT_FORMAT}")
      endif()

      if (PARAM_PROJECT_AS_OUTPUT_NAME)
        set(PARAM_OUTPUT_NAME ${PROJECT_NAME_FULL})
      endif()

      add_custom_command(TARGET ${TARGET} POST_BUILD
        COMMAND
          ${CMAKE_OBJCOPY} -O ${OUTPUT_FORMAT} ${PARAM_ARGS} $<TARGET_FILE:${TARGET}> $<IF:$<BOOL:${PARAM_OUTPUT_DIRECTORY}>,${PARAM_OUTPUT_DIRECTORY},$<TARGET_FILE_DIR:${TARGET}>>/$<IF:$<BOOL:${PARAM_PREFIX}>,${PARAM_PREFIX},$<TARGET_FILE_PREFIX:${TARGET}>>$<IF:$<BOOL:${PARAM_OUTPUT_NAME}>,${PARAM_OUTPUT_NAME},$<TARGET_FILE_BASE_NAME:${TARGET}>>${PARAM_SUFFIX}
        COMMENT
          "Generating ${OUTPUT_FORMAT} for ${TARGET}."
      )
    endif()
  endforeach()
endfunction()

#
# Adds a post build dot event to the given target.
#
# target_dot(<target>
#   FORMAT
#     <format>
# )
#
# <format>
#   Specifies the format the dot event should generate
#
function(target_dot TARGET)
  if (NOT DEFINED CACHE{DOXYGEN_DOT_EXECUTABLE})
    message(WARNING "Cannot create dot target: doxygen was not found. Skipping.")
    return()
  endif()

  cmake_parse_arguments(ARG_DOT
    ""
    "FORMAT"
    ""
    ${ARGN}
  )

  add_custom_command(TARGET ${TARGET} POST_BUILD
    COMMAND
      dot -T${ARG_DOT_FORMAT} ${CMAKE_BINARY_DIR}/${TARGET}.dot -o ${CMAKE_INSTALL_PREFIX}/${TARGET}.${ARG_DOT_FORMAT} || (exit 0)
    COMMENT
      "Generating Graphviz ${ARG_DOT_FORMAT} for ${TARGET}."
  )
endfunction()

function(python_execute)
  set(_ONE_VALUE_ARGS
    SCRIPT
    WORKING_DIRECTORY
  )
  cmake_parse_arguments(ARG
    ""
    "${_ONE_VALUE_ARGS}"
    "ARGS"
    ${ARGN}
  )

  if (NOT DEFINED CMAKEPKG_PYTHON)
    find_package(Python 3.12 REQUIRED)
    set(CMAKEPKG_PYTHON "${Python_EXECUTABLE}" CACHE INTERNAL "CmakePkg found python executable" FORCE)
  endif()

  execute_process(
    COMMAND
      ${CMAKEPKG_PYTHON} ${ARG_SCRIPT} ${ARG_ARGS}
    WORKING_DIRECTORY
      ${ARG_WORKING_DIRECTORY}
    ENCODING
      UTF8
    COMMAND_ERROR_IS_FATAL
      ANY
  )
endfunction()

function(cmakepkg_generate GENERATOR)
  set(_ONE_VALUE_ARGS
    NAMESPACE
    PATH
    OUTPUT
  )
  cmake_parse_arguments(ARG
    ""
    "${_ONE_VALUE_ARGS}"
    ""
    ${ARGN}
  )

  python_execute(
    SCRIPT
      ${CMAKE_CURRENT_SOURCE_DIR}/scripts/generate_${GENERATOR}.py
    WORKING_DIRECTORY
      ${CMAKE_CURRENT_BINARY_DIR}
    ARGS
      --namespace=${ARG_NAMESPACE}
      --path=${ARG_PATH}
      --output=${ARG_OUTPUT}
  )
endfunction()

function(cmakepkg_configure_file FILE_PATH)
  cmake_parse_arguments(ARG
    ""
    "LIST_FILES_INDENT;LIST_FILES_BASE_DIR"
    "LIST_FILES;LIST_FILES_IGNORE"
    ${ARGN}
  )

  if (ARG_LIST_FILES_INDENT)
    set(CMAKEPKG_CONFIG_LIST_FILES_INDENT "")
    foreach(IDX RANGE 1 ${ARG_LIST_FILES_INDENT})
      string(APPEND CMAKEPKG_CONFIG_LIST_FILES_INDENT "    ")
    endforeach()
  endif()

  if (ARG_LIST_FILES)
    set(CMAKEPKG_CONFIG_LISTED_FILES "")
    foreach(ENTRY ${ARG_LIST_FILES})
      file(GLOB_RECURSE ENTRY_FILES
        LIST_DIRECTORIES false
        ${ARG_LIST_FILES_BASE_DIR}/${ENTRY}/*
      )

      foreach(ENTRY_FILE ${ENTRY_FILES})
        string(REPLACE "${ARG_LIST_FILES_BASE_DIR}/" "" ENTRY_FILE "${ENTRY_FILE}")
        if (NOT ${ENTRY_FILE} IN_LIST ARG_LIST_FILES_IGNORE)
          string(APPEND CMAKEPKG_CONFIG_LISTED_FILES "\n${CMAKEPKG_CONFIG_LIST_FILES_INDENT}\"${ENTRY_FILE}\",")
        endif()
      endforeach()
    endforeach()
  endif()

  configure_file(
    ${CMAKE_CURRENT_SOURCE_DIR}/${FILE_PATH}.cmake
    ${CMAKE_CURRENT_BINARY_DIR}/${FILE_PATH}
    @ONLY
  )
endfunction()
