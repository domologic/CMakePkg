include_guard(GLOBAL)

message(STATUS "Loading DOMOLOGIC build system")

set(CMAKE_MODULE_PATH
  ${CMAKE_MODULE_PATH}
  ${CMAKE_CURRENT_LIST_DIR}/Module
)

set(CMAKE_DISABLE_SOURCE_CHANGES  ON)
set(CMAKE_DISABLE_IN_SOURCE_BUILD ON)
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)
set(CMAKE_POSITION_INDEPENDENT_CODE ON)

find_package(Cxx17 REQUIRED)

set_property(GLOBAL
  PROPERTY
    USE_FOLDERS ON
)

function(load_script name)
  include(${CMAKE_CURRENT_LIST_DIR}/${name}.cmake)
endfunction()

if (NOT OUTPUT_DIRECTORY)
  set(OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/bin")
endif()
set(OUTPUT_DIRECTORY ${OUTPUT_DIRECTORY} CACHE PATH "output directory path")

load_script(FunctionGeneral)
load_script(FunctionGit)
load_script(FunctionBuild)

load_script(FindDependency)
load_script(RegisterDependency)

load_script(AddModule)