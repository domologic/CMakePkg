set(Cxx17_FOUND FALSE)

set(CMAKE_CXX_STANDARD 17)

find_package(Threads REQUIRED)

add_library(std::c++17 INTERFACE IMPORTED)

if (UNIX)
  set_property(
    TARGET
      std::c++17
    PROPERTY
      INTERFACE_COMPILE_OPTIONS
        "-lstdc++fs"
  )
  set_property(
    TARGET
      std::c++17
    PROPERTY
      INTERFACE_LINK_LIBRARIES
        "-lstdc++fs"
  )
endif()

target_link_libraries(std::c++17
  INTERFACE
    Threads::Threads
)

set(Cxx17_FOUND TRUE)
