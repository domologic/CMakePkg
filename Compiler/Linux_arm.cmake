macro(load_compiler_config)
  # preprocessor definitions
  #set(DEFINE)
  set(DEFINE_DEBUG
    DEBUG
  )
  set(DEFINE_RELEASE
    NDEBUG
    _NDEBUG
  )

  # global flags
  set(FLAGS
    -rdynamic
    -shared-libgcc
    -lpthread
    -lstdc++fs
  )
  set(FLAGS_DEBUG
    -ggdb
    -Og
  )
  set(FLAGS_RELEASE
    -O3
    -fmerge-all-constants
    -faggressive-loop-optimizations
    -s
  )

  # c flags
  #set(FLAGS_C)
  #set(FLAGS_C_DEBUG)
  #set(FLAGS_C_RELEASE)

  # c++ flags
  #set(FLAGS_CXX)
  #set(FLAGS_CXX_DEBUG)
  #set(FLAGS_CXX_RELEASE)

  set(LINK
    -lpthread
    -lstdc++fs
  )
  #set(LINK_DEBUG)
  #set(LINK_RELEASE)
endmacro()
