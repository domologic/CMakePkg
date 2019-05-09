include(FindPackageHandleStandardArgs)

enable_language(C)
enable_language(CXX)

set(CMAKE_CXX_STANDARD 17)

find_package(Threads REQUIRED)

set(CXX17_THREAD_LIBRARY     "${CMAKE_THREAD_LIBS_INIT}")
set(CXX17_FILESYSTEM_LIBRARY "-lstdc++fs")
set(CXX17_FOUND              TRUE)

find_package_handle_standard_args(Cxx17
  DEFAULT_MSG
  CXX17_FOUND
)

if (Cxx17_FOUND)
  add_library(std::c++17 INTERFACE IMPORTED)

  set_property(
    TARGET
      std::c++17
    PROPERTY
      INTERFACE_COMPILE_OPTIONS
        $<$<BOOL:${UNIX}>:${CXX17_THREAD_LIBRARY}>
        $<$<BOOL:${UNIX}>:${CXX17_FILESYSTEM_LIBRARY}>
  )
  set_property(
    TARGET
      std::c++17
    PROPERTY
      INTERFACE_LINK_LIBRARIES
        $<$<BOOL:${UNIX}>:${CXX17_THREAD_LIBRARY}>
        $<$<BOOL:${UNIX}>:${CXX17_FILESYSTEM_LIBRARY}>
  )

  mark_as_advanced(
    CXX17_THREAD_LIBRARY
    CXX17_FILESYSTEM_LIBRARY
    CXX17_LIBRARIES
  )
endif()
