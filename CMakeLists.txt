cmake_minimum_required(VERSION 3.12.1 FATAL_ERROR)

set(CMAKE_DISABLE_SOURCE_CHANGES ON)
set(CMAKE_DISABLE_IN_SOURCE_BUILD ON)

project(HunterTest)

include(CMake/FindDependency.cmake)

set(DOMO_PW "hello world")

find_dependency(
  GROUP
    sigma
  PROJECT
    UpdateSystem
  BUILD_OPTIONS
    -DDOMO_UPDATE_PASSWORD=${DOMO_PW}
)

add_executable(foo foo.cpp)
register_dependency(foo)

target_link_libraries(foo
  sigma::UpdateSystem  
)

