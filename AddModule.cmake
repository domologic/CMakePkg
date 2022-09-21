macro(_add_module_warning)
  if (NOT CMAKEPKG_DISABLE_ADDMODULE_WARNINGS)
    string(REPLACE "module" "package" _ADDMODULE_NEW_FUNC_NAME ${CMAKE_CURRENT_FUNCTION})
    #message(WARNING "CMakePkg function '${CMAKE_CURRENT_FUNCTION}' is deprecated! Use '${_ADDMODULE_NEW_FUNC_NAME}' instead. Set 'CMAKEPKG_DISABLE_ADDMODULE_WARNINGS' to disable this warning.")
  endif()
endmacro()

#
# DEPRECATED: Use add_package_library
#
function(add_module_library PACKAGE_NAME PACKAGE_TYPE)
  _add_module_warning()
  add_package_library(${PACKAGE_NAME} ${PACKAGE_TYPE} ${ARGN})
endfunction()

#
# DEPRECATED: Use add_package_executable
#
function(add_module_executable PACKAGE_NAME)
  _add_module_warning()
  add_package_executable(${PACKAGE_NAME} ${ARGN})
endfunction()

#
# DEPRECATED: Use add_package_test
#
function(add_module_test PACKAGE_NAME)
  _add_module_warning()
  add_package_test(${PACKAGE_NAME} ${ARGN})
endfunction()

#
# DEPRECATED: Use add_package_docs
#
function(add_package_docs PACKAGE_NAME)
  _add_module_warning()
  add_package_docs(${PACKAGE_NAME} ${ARGN})
endfunction()
