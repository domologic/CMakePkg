include_guard(GLOBAL)

#
# Provides an option that the user can optionally select.
#
# cmakepkg_option(<variable> <type> <value> <description>)
#
# <variable>
#   Name of the variable.
# <type>
#   Type of the variable
# <value>
#   Default value used when the option is not defined by user.
# <description>
#   Description of the option.
#
function(cmakepkg_option VARIABLE TYPE VALUE DESCRIPTION)
  if (${TYPE} STREQUAL BOOL)
    option(${VARIABLE} "${DESCRIPTION}" ${VALUE})
  else()
    set(${VARIABLE} "${VALUE}" CACHE ${TYPE} "${DESCRIPTION}")
  endif()
endfunction()

#
# Sets configuration options for dependencies.
#
# cmakepkg_config(
#   <options>...
# )
#
# <options>
#   One or more key value pairs.
#   Each entry should not contain any spaces and should separate the key from value with an equal sign.
#
function(cmakepkg_config)
  foreach (CONFIG IN LISTS ARGN)
    # split config on equal sign
    string(REPLACE "=" ";" CONFIG ${CONFIG})

    # extract key and value
    list(GET CONFIG 0 CONFIG_KEY)
    list(GET CONFIG 1 CONFIG_VAL)

    # set config to cmake cache
    set(${CONFIG_KEY} ${CONFIG_VAL} CACHE INTERNAL "")
  endforeach()
endfunction()
