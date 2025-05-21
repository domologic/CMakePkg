#
# Internal
# Load compiler configuration for Baremetal Cortex M4F arm platform
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
    -mfloat-abi=softfp
    -pipe
    -c
    -fmessage-length=0
    -mcpu=cortex-m4
    -mfpu=fpv4-sp-d16
    -mthumb
  # debug compiler flags
  FLAGS_DEBUG
    -O0
    -g
    -gdwarf-2
  # release compiler flags
  FLAGS_RELEASE
    -Os
  # C++ compiler flags
  FLAGS_CXX
    -fno-exceptions
    -fno-rtti
    -fno-threadsafe-statics
  # linker flags
  LINK
    -nostartfiles
    -Xlinker --gc-sections
    -specs=nano.specs
    -specs=nosys.specs
    -u _printf_float
    #-u _scanf_float ?? TODO [FB] Warum funktioniert dies nicht
    -mfloat-abi=softfp
    -mfpu=fpv4-sp-d16
    -mcpu=cortex-m4
    -mthumb
  # debug linker flags
  LINK_DEBUG
    -g
    -gdwarf-2
)
