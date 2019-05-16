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

function(collect_source_files current_dir variable)
  list(FIND ARGN "${current_dir}" IS_EXCLUDED)
  if (IS_EXCLUDED EQUAL -1)
    file(GLOB COLLECTED_SOURCES
      ${current_dir}/*.c
      ${current_dir}/*.cpp
      ${current_dir}/*.cxx
      ${current_dir}/*.c++
      ${current_dir}/*.cc
      ${current_dir}/*.h
      ${current_dir}/*.hpp
      ${current_dir}/*.hxx
      ${current_dir}/*.h++
      ${current_dir}/*.hh
      ${current_dir}/*.inl
      ${current_dir}/*.inc
      ${current_dir}/*.inl.hpp
      ${current_dir}/*.inc.hpp
    )
    list(APPEND ${variable} ${COLLECTED_SOURCES})

    file(GLOB SUB_DIRECTORIES ${current_dir}/*)
    foreach(SUB_DIRECTORY ${SUB_DIRECTORIES})
      if (IS_DIRECTORY ${SUB_DIRECTORY})
        collect_source_files("${SUB_DIRECTORY}" "${variable}" "${ARGN}")
      endif()
    endforeach()
    set(${variable} ${${variable}} PARENT_SCOPE)
  endif()
endfunction()

macro(group_sources dir)
  file(GLOB_RECURSE ELEMENTS RELATIVE ${dir}
    *.c *.cpp *.cxx *.c++ *.cc
    *.h *.hpp *.hxx *.h++ *.hh
  )

  foreach(ELEMENT ${ELEMENTS})
    get_filename_component(ELEMENT_NAME ${ELEMENT} NAME)
    get_filename_component(ELEMENT_DIR ${ELEMENT} DIRECTORY)

    if (NOT ${ELEMENT_DIR} STREQUAL "")
      string(REPLACE "/" "\\" GROUP_NAME ${ELEMENT_DIR})
      source_group("${GROUP_NAME}" FILES ${dir}/${ELEMENT})
    else()
      source_group("\\" FILES ${dir}/${ELEMENT})
    endif()
  endforeach()
endmacro()

function(select_compiler_config)
  cmake_parse_arguments(ARG
    ""
    "${CMAKE_SYSTEM_NAME}::${CMAKE_SYSTEM_PROCESSOR}"
    ""
    ${ARGN}
  )

  if (ARG_${CMAKE_SYSTEM_NAME}-${CMAKE_SYSTEM_PROCESSOR})
    include(${ARG_${CMAKE_SYSTEM_NAME}::${CMAKE_SYSTEM_PROCESSOR}}
      OPTIONAL
      RESULT_VARIABLE
        CONFIG_AVAILABLE
    )
  endif()

  if ("${CONFIG_AVAILABLE}" STREQUAL "NOTFOUND")
    message(STATUS "Configuring ${CMAKE_SYSTEM_NAME}::${CMAKE_SYSTEM_PROCESSOR}")
  else()
    message(WARNING "Configuration file ${CMAKE_SYSTEM_NAME}::${CMAKE_SYSTEM_PROCESSOR} missing!")
  endif()

  if (FLAGS_C)
    set(CMAKE_C_FLAGS                ${FLAGS_C})
  endif()
  if (FLAGS_C_DEBUG)
    set(CMAKE_C_FLAGS_DEBUG          ${FLAGS_C_DEBUG})
  endif()
  if (FLAGS_C_RELWITHDEBINFO)
    set(CMAKE_C_FLAGS_RELWITHDEBINFO ${FLAGS_C_RELWITHDEBINFO})
  endif()
  if (FLAGS_C_RELEASE)
    set(CMAKE_C_FLAGS_RELEASE        ${FLAGS_C_RELEASE})
  endif()

  if (FLAGS_CXX)
    set(CMAKE_CXX_FLAGS                ${FLAGS_CXX})
  endif()
  if (FLAGS_CXX_DEBUG)
    set(CMAKE_CXX_FLAGS_DEBUG          ${FLAGS_CXX_DEBUG})
  endif()
  if (FLAGS_CXX_RELWITHDEBINFO)
    set(CMAKE_CXX_FLAGS_RELWITHDEBINFO ${FLAGS_CXX_RELWITHDEBINFO})
  endif()
  if (FLAGS_CXX_RELEASE)
    set(CMAKE_CXX_FLAGS_RELEASE        ${FLAGS_CXX_RELEASE})
  endif()
endfunction()
