#
# Internal
# Load compiler configuration for Linux x86_64 platform
#

set_compiler_defaults(
  # global preprocessor definitions
  DEFINE
    _FILE_OFFSET_BITS=64
    _TIME_BITS=64
  # debug preprocessor definitions
  DEFINE_DEBUG
    DEBUG
    _DEBUG
  # relwithdebinfo preprocessor definitions
  DEFINE_RELWITHDEBINFO
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
    -Og
    -fno-omit-frame-pointer
    -ggdb3
  # relwithdebinfo compiler flags
  FLAGS_RELWITHDEBINFO
    -O2
    -fdata-sections
    -ffunction-sections
    -flto=auto
    -fmerge-all-constants
    -fno-omit-frame-pointer
    -funroll-loops
    -fwhole-program
    -gdescribe-dies
    -ggdb3
    -ginline-points
    -ginternal-reset-location-views
    -gstatement-frontiers
    -gvariable-location-views
    -gz=zstd
  # release compiler flags
  FLAGS_RELEASE
    -O2
    -fdata-sections
    -ffunction-sections
    -flto=auto
    -fmerge-all-constants
    -funroll-loops
    -fwhole-program
  # linker flags
  LINK
    LINKER:--disable-linker-version
    LINKER:--gc-sections
)
