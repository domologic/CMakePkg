#
# Internal
# Load compiler configuration for Linux x86_64 platform
#

# Preprocessor definitions
#set(DEFINE
#)
set(DEFINE_DEBUG
  DEBUG
  _DEBUG
)
set(DEFINE_RELEASE
  NDEBUG
  _NDEBUG
)

# Global flags
set(FLAGS
  -rdynamic
  -shared-libgcc
  -march=native
)
set(FLAGS_DEBUG
  -ggdb
  -Og
)
set(FLAGS_RELEASE
  -O3
  -flto
  -fno-fat-lto-objects
  -fmerge-all-constants
  -faggressive-loop-optimizations
  -fgcse-sm
  -fgcse-las
  -fgcse-after-reload
  -fdevirtualize-speculatively
  -fdevirtualize-at-ltrans
)

# C flags
#set(FLAGS_C
#)
#set(FLAGS_C_DEBUG
#)
#set(FLAGS_C_RELEASE
#)

# C++ flags
#set(FLAGS_CXX
#)
#set(FLAGS_CXX_DEBUG
#)
#set(FLAGS_CXX_RELEASE
#)

# Linker flags
#set(LINK
#)
#set(LINK_DEBUG
#)
#set(LINK_RELEASE
#)

# store configuration in cmake cache
#set(CMAKEPKG_DEFINE            ${DEFINE}            CACHE INTERNAL "CMakePkg definitions")
set(CMAKEPKG_DEFINE_DEBUG      ${DEFINE_DEBUG}      CACHE INTERNAL "CMakePkg debug definitions")
set(CMAKEPKG_DEFINE_RELEASE    ${DEFINE_RELEASE}    CACHE INTERNAL "CMakePkg release definitions")
set(CMAKEPKG_FLAGS             ${FLAGS}             CACHE INTERNAL "CMakePkg compiler flags")
set(CMAKEPKG_FLAGS_DEBUG       ${FLAGS_DEBUG}       CACHE INTERNAL "CMakePkg compiler debug flags")
set(CMAKEPKG_FLAGS_RELEASE     ${FLAGS_RELEASE}     CACHE INTERNAL "CMakePkg compiler release flags")
#set(CMAKEPKG_FLAGS_C           ${FLAGS_C}           CACHE INTERNAL "CMakePkg c flags")
#set(CMAKEPKG_FLAGS_C_DEBUG     ${FLAGS_C_DEBUG}     CACHE INTERNAL "CMakePkg c debug flags")
#set(CMAKEPKG_FLAGS_C_RELEASE   ${FLAGS_C_RELEASE}   CACHE INTERNAL "CMakePkg c release flags")
#set(CMAKEPKG_FLAGS_CXX         ${FLAGS_CXX}         CACHE INTERNAL "CMakePkg c++ flags")
#set(CMAKEPKG_FLAGS_CXX_DEBUG   ${FLAGS_CXX_DEBUG}   CACHE INTERNAL "CMakePkg c++ debug flags")
#set(CMAKEPKG_FLAGS_CXX_RELEASE ${FLAGS_CXX_RELEASE} CACHE INTERNAL "CMakePkg c++ release flags")
#set(CMAKEPKG_LINK              ${LINK}              CACHE INTERNAL "CMakePkg linker flags")
#set(CMAKEPKG_LINK_DEBUG        ${LINK_DEBUG}        CACHE INTERNAL "CMakePkg linker debug flags")
#set(CMAKEPKG_LINK_RELEASE      ${LINK_RELEASE}      CACHE INTERNAL "CMakePkg linker release flags")
