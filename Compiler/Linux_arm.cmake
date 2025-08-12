#
# Internal
# Load compiler configuration for Linux arm platform
#

set_compiler_defaults(
  # preprocessor definitions
  DEFINE
    _FILE_OFFSET_BITS=64
    _TIME_BITS=64
  # debug preprocessor definitions
  DEFINE_DEBUG
    DEBUG
    _DEBUG
  # release preprocessor definitions
  DEFINE_RELEASE
    NDEBUG
    _NDEBUG
  # compiler flags
  FLAGS
    -fno-gnu-tm
    -fuse-ld=gold
    -ftrivial-auto-var-init=zero
    -mno-unaligned-access
  # debug compiler flags
  FLAGS_DEBUG
    -ggdb3
    -O0
  # release compiler flags
  FLAGS_RELEASE
    -g3
    -O2
    -fdata-sections
    -ffunction-sections
    -flto=auto
    -fmerge-all-constants
    -funroll-loops
    -fwhole-program
  # linker flags
  LINK
    LINKER:--gc-sections
    LINKER:--disable-linker-version
    LINKER:-z noexecstack
)
