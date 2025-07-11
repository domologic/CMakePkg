#
# Internal
# Load compiler configuration for Linux arm platform
#

set_compiler_defaults(
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
    -gz=zlib
    -O0
  # release compiler flags
  FLAGS_RELEASE
    -g1
    -gz=zlib
    -O2
    -fmerge-all-constants
    -flto=auto
    -fwhole-program
    -fdata-sections
    -ffunction-sections
  # linker flags
  LINK
    LINKER:--gc-sections
    LINKER:--compress-debug-sections=zlib
    LINKER:--disable-linker-version
    LINKER:-z noexecstack
)
