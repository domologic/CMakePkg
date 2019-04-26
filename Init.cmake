include_guard(GLOBAL)

message(STATUS "Loading DOMOLOGIC build system")

set(CMAKE_MODULE_PATH
  ${CMAKE_MODULE_PATH}
  ${CMAKE_CURRENT_LIST_DIR}/Module
)

set(CMAKE_DISABLE_SOURCE_CHANGES  ON)
set(CMAKE_DISABLE_IN_SOURCE_BUILD ON)

find_package(Cxx17 REQUIRED)

function(load_script name)
  include(${CMAKE_CURRENT_LIST_DIR}/${name}.cmake)
endfunction()

load_script(FunctionGeneral)
load_script(FunctionGit)
load_script(FunctionBuild)

load_script(FindDependency)
load_script(RegisterDependency)

load_script(AddModule)