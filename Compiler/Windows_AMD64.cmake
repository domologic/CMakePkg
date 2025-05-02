#
# Internal
# Load compiler configuration for Windows AMD64 platform
#

# cleanup cmake default flags
set(CMAKE_CXX_FLAGS                "" CACHE STRING "" FORCE)
set(CMAKE_CXX_FLAGS_DEBUG          "" CACHE STRING "" FORCE)
set(CMAKE_CXX_FLAGS_RELEASE        "" CACHE STRING "" FORCE)

set(CMAKE_C_FLAGS                  "" CACHE STRING "" FORCE)
set(CMAKE_C_FLAGS_DEBUG            "" CACHE STRING "" FORCE)
set(CMAKE_C_FLAGS_RELEASE          "" CACHE STRING "" FORCE)

# Preprocessor definitions
set(DEFINE
  _CRT_NONSTDC_NO_WARNINGS
  _CRT_SECURE_NO_WARNINGS
  _WINSOCK_DEPRECATED_NO_WARNINGS
  NOMINMAX
  WIN32
  WIN32_LEAN_AND_MEAN
)
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
  /EHsc
  /GA
  /GR
  /Oi
  /Ot
  /QIntel-jcc-erratum
  /Qfast_transcendentals
  /W3
  /Zc:__cplusplus
  /Zc:checkGwOdr
  /Zc:enumTypes
  /Zc:inline
  /Zc:preprocessor
  /Zc:referenceBinding
  /Zc:templateScope
  /Zc:throwingNew
  /Zc:trigraphs
  /arch:AVX2
  /bigobj
  /d2FH4
  /diagnostics:caret
  /jumptablerdata
  /permissive-
  /sdl-
  /utf-8
  /volatile:iso
)
set(FLAGS_DEBUG
  /MTd
  /Ob0
  /Od
  /RTC1
  /ZI
)
set(FLAGS_RELEASE
  /GL
  /Gw
  /MT
  /MP
  /O2
  /Ob3
  /Qpar
)

# C flags
set(FLAGS_C
  /TC
)
#set(FLAGS_C_DEBUG
#)
#set(FLAGS_C_RELEASE
#)

# C++ flags
set(FLAGS_CXX
  /TP
)
#set(FLAGS_CXX_DEBUG
#)
#set(FLAGS_CXX_RELEASE
#)

# Linker flags
#set(LINK
#)
set(LINK_DEBUG
  /DEBUG:FULL
  /OPT:NOICF
  /OPT:NOREF
)
set(LINK_RELEASE
  /DEBUG:NONE
  /LTCG
  /OPT:ICF
  /OPT:REF
)

# store configuration in cmake cache
set(CMAKEPKG_DEFINE            ${DEFINE}            CACHE INTERNAL "CMakePkg definitions")
set(CMAKEPKG_DEFINE_DEBUG      ${DEFINE_DEBUG}      CACHE INTERNAL "CMakePkg debug definitions")
set(CMAKEPKG_DEFINE_RELEASE    ${DEFINE_RELEASE}    CACHE INTERNAL "CMakePkg release definitions")
set(CMAKEPKG_FLAGS             ${FLAGS}             CACHE INTERNAL "CMakePkg compiler flags")
set(CMAKEPKG_FLAGS_DEBUG       ${FLAGS_DEBUG}       CACHE INTERNAL "CMakePkg compiler debug flags")
set(CMAKEPKG_FLAGS_RELEASE     ${FLAGS_RELEASE}     CACHE INTERNAL "CMakePkg compiler release flags")
set(CMAKEPKG_FLAGS_C           ${FLAGS_C}           CACHE INTERNAL "CMakePkg c flags")
#set(CMAKEPKG_FLAGS_C_DEBUG     ${FLAGS_C_DEBUG}     CACHE INTERNAL "CMakePkg c debug flags")
#set(CMAKEPKG_FLAGS_C_RELEASE   ${FLAGS_C_RELEASE}   CACHE INTERNAL "CMakePkg c release flags")
set(CMAKEPKG_FLAGS_CXX         ${FLAGS_CXX}         CACHE INTERNAL "CMakePkg c++ flags")
#set(CMAKEPKG_FLAGS_CXX_DEBUG   ${FLAGS_CXX_DEBUG}   CACHE INTERNAL "CMakePkg c++ debug flags")
#set(CMAKEPKG_FLAGS_CXX_RELEASE ${FLAGS_CXX_RELEASE} CACHE INTERNAL "CMakePkg c++ release flags")
#set(CMAKEPKG_LINK              ${LINK}              CACHE INTERNAL "CMakePkg linker flags")
set(CMAKEPKG_LINK_DEBUG        ${LINK_DEBUG}        CACHE INTERNAL "CMakePkg linker debug flags")
set(CMAKEPKG_LINK_RELEASE      ${LINK_RELEASE}      CACHE INTERNAL "CMakePkg linker release flags")
