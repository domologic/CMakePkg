#
# Internal
# Load compiler configuration for Linux arm platform
#
macro(load_compiler_config)
  # Preprocessor definitions
  #set(DEFINE)
  set(DEFINE_DEBUG
    DEBUG
  )
  set(DEFINE_RELEASE
    NDEBUG
    _NDEBUG
  )

  # Global flags
  set(FLAGS
    -rdynamic
    -shared-libgcc
  )
  set(FLAGS_DEBUG
    -ggdb3
    -Og
  )
  set(FLAGS_RELEASE
    -ggdb3
    -O3
    -fmerge-all-constants
    -faggressive-loop-optimizations
  )

  # C flags
  #set(FLAGS_C)
  #set(FLAGS_C_DEBUG)
  #set(FLAGS_C_RELEASE)

  # C++ flags
  #set(FLAGS_CXX)
  #set(FLAGS_CXX_DEBUG)
  #set(FLAGS_CXX_RELEASE)

  # Linker flags
  #set(LINK)
  #set(LINK_DEBUG)
  #set(LINK_RELEASE)
endmacro()
