#
# Defines a usable variable that can be ovewritten from extern location.
#
# define_variable(<variable_name>
#   <value>...
# )
#
# <variable_name>
#   Specifies the name of the variable.
# <value>
#   Specifies one or more values associated with the variable.
#
macro(define_variable variable default_value)
  if (NOT DEFINED ${variable})
    set(${variable} ${default_value})
    message(WARNING "Variable '${variable}' was not specified. Setting to default value '${default_value}'.")
  endif()
endmacro()

#
# Defines a usable cache variable that can be ovewritten from extern location.
#
# define_variable_cache(<variable_name>
#   <value>...
#   <type>
#   <docstring>
#   [FORCE]
# )
#
# <variable_name>
#   Specifies the name of the variable.
# <value>
#   Specifies one or more values associated with the variable.
# <type>
#   Specifies the type of the variable. Allowed types are:
#     BOOL
#       Boolean ON/OFF value.
#     FILEPATH
#       Path to a file on disk.
#     PATH
#       Path to a directory on disk.
#     STRING
#       A line of text.
#     INTERNAL
#       Any type. Does not show in cmake-gui.
#  [FORCE]
#    
function(define_variable_cache variable default_value type docstring)
  cmake_parse_arguments(DEFINE_VARIABLE_CACHE_ARGS
    "FORCE"
    ""
    ""
    ${ARGN}
  )

  if (DEFINE_VARIABLE_CACHE_ARGS_FORCE)
    set(DEFINE_VARIABLE_CACHE_FORCE FORCE)
  endif()

  if (NOT DEFINED CACHE{variable})
    set(${variable} ${default_value} CACHE ${type} ${docstring} ${DEFINE_VARIABLE_CACHE_FORCE})
    message(WARNING "Variable '${variable}' was not specified. Setting to default value '${default_value}'.")
  endif()
endfunction()

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
function(target_objcopy target)
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
        ""
        "PREFIX;SUFFIX;OUTPUT_NAME;OUTPUT_DIRECTORY"
        "ARGS"
        ${OUTPUT_FORMAT_${KNOWN_OUTPUT_FORMAT}}
      )

      if (NOT DEFINED PARAM_SUFFIX)
        set(PARAM_SUFFIX ".${OUTPUT_FORMAT}")
      endif()

      add_custom_command(TARGET ${target} POST_BUILD
        COMMAND
          ${CMAKE_OBJCOPY} -O ${OUTPUT_FORMAT} ${PARAM_ARGS} $<TARGET_FILE:${target}> $<IF:$<BOOL:${PARAM_OUTPUT_DIRECTORY}>,${PARAM_OUTPUT_DIRECTORY},$<TARGET_FILE_DIR:${target}>>/$<IF:$<BOOL:${PARAM_PREFIX}>,${PARAM_PREFIX},$<TARGET_FILE_PREFIX:${target}>>$<IF:$<BOOL:${PARAM_OUTPUT_NAME}>,${PARAM_OUTPUT_NAME},$<TARGET_FILE_BASE_NAME:${target}>>${PARAM_SUFFIX}
        COMMENT
          "Generating ${OUTPUT_FORMAT} for ${target}."
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
function(target_dot ${module_name})
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

  add_custom_command(TARGET ${module_name} POST_BUILD
    COMMAND
      dot -T${ARG_DOT_FORMAT} ${CMAKE_BINARY_DIR}/${module_name}.dot -o ${CMAKE_INSTALL_PREFIX}/${module_name}.${ARG_DOT_FORMAT} || (exit 0)
    COMMENT
      "Generating Graphviz ${ARG_DOT_FORMAT} for ${module_name}."
  )
endfunction()
