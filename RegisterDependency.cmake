include_guard(GLOBAL)

# register_dependency(<dependency name> [<dependencies>])
function(register_dependency dependency_name)
  export(TARGETS
      ${dependency_name}
      ${ARGN}
    FILE
      ${dependency_name}.dep.cmake
    EXPORT_LINK_INTERFACE_LIBRARIES
  )
endfunction()
