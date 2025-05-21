#
# Internal
# Load compiler configuration for Linux x86_64 platform
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
    -march=native
    -ftrivial-auto-var-init=zero
  # debug compiler flags
  FLAGS_DEBUG
    -ggdb
    -Og
  # release compiler flags
  FLAGS_RELEASE
    -ggdb3
    -O2
    -fmerge-all-constants
    -flto=auto
    -fwhole-program
    -fdata-sections
    -ffunction-sections
)
