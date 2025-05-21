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
    -mfpu=neon
    -mfloat-abi=hard
  # debug compiler flags
  FLAGS_DEBUG
    -ggdb3
    -O0
  # release compiler flags
  FLAGS_RELEASE
    -ggdb3
    -O3
    -fmerge-all-constants
    -ffast-math
    -s
)
