include_guard(GLOBAL)

message(STATUS "Loading DOMOLOGIC build system")

set(CMAKE_MODULE_PATH               ${CMAKE_CURRENT_LIST_DIR}/Module)
set(CMAKE_CONFIGURATION_TYPES       "Debug;Release" CACHE STRING "" FORCE)
set(CMAKE_DISABLE_SOURCE_CHANGES    ON)
set(CMAKE_DISABLE_IN_SOURCE_BUILD   ON)
set(CMAKE_EXPORT_COMPILE_COMMANDS   ON)
set(CMAKE_POSITION_INDEPENDENT_CODE ON)
set(CMAKE_C_STANDARD                11)
set(CMAKE_CXX_STANDARD              17)

find_package(Cxx17 REQUIRED)

set_property(GLOBAL
  PROPERTY
    USE_FOLDERS ON
)

include(ProcessorCount)
ProcessorCount(N)
if (NOT N EQUAL 0)
  set(CMAKE_BUILD_PARALLEL_LEVEL ${N})
endif()

include(${CMAKE_CURRENT_LIST_DIR}/AddModule.cmake)
