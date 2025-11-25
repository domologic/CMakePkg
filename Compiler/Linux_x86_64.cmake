#
# Internal
# Load compiler configuration for Linux x86_64 platform
#

set_compiler_defaults(
  # debug preprocessor definitions
  DEFINE
    _FILE_OFFSET_BITS=64
    _TIME_BITS=64
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
    -ftrivial-auto-var-init=zero
    -fuse-ld=gold
    -march=native
  # debug compiler flags
  FLAGS_DEBUG
    -ggdb3
    -Og
  # release compiler flags
  FLAGS_RELWITHDEBINFO
    -O2
    -fdata-sections
    -ffunction-sections
    -flto=auto
    -fmerge-all-constants
    -funroll-loops
    -fwhole-program
    -ggdb3
  FLAGS_RELEASE
    -O2
    -fdata-sections
    -ffunction-sections
    -flto=auto
    -fmerge-all-constants
    -funroll-loops
    -fwhole-program
  LINK
    LINKER:--gc-sections
    LINKER:--disable-linker-version
)
