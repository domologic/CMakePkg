#
# Internal
# Load compiler configuration for MinGW AMD64 arm platform
#

#Don't use position independent code
set(CMAKE_POSITION_INDEPENDENT_CODE  OFF  CACHE INTERNAL "" FORCE)

set_compiler_defaults(
  # preprocessor definitions
  DEFINE
    TOOLCHAIN=GCC
    TOOLCHAIN_GCC_
  # debug preprocessor definitions
  DEFINE_DEBUG
    DEBUG_
  # release preprocessor definitions
  DEFINE_RELEASE
    RELEASE
    RELEASE_
    NDEBUG
    NDEBUG_
  # compiler flags
  FLAGS
    -ffunction-sections
    -fdata-sections
    -mno-unaligned-access
    -Wall
    -Wpedantic
    -Wno-unknown-pragmas
    -pipe
    -c
    -fmessage-length=0
  # debug flags
  FLAGS_DEBUG
    -O0
    -g
    -gdwarf-2
  # release flags
  FLAGS_RELEASE
    -Os
  # C++ flags
  FLAGS_CXX
    -fexceptions
    -frtti
  # linker flags
  LINK
    -Xlinker --gc-sections
  # debug linker flags
  LINK_DEBUG
    -g
    -gdwarf-2
)
