#
# Internal
# Load compiler configuration for Windows AMD64 platform
#

# cleanup cmake default flags
set(CMAKE_CXX_FLAGS                "" CACHE STRING "" FORCE)
set(CMAKE_CXX_FLAGS_DEBUG          "" CACHE STRING "" FORCE)
set(CMAKE_CXX_FLAGS_DEBUG          "" CACHE STRING "" FORCE)

set(CMAKE_C_FLAGS                  "" CACHE STRING "" FORCE)
set(CMAKE_C_FLAGS_DEBUG            "" CACHE STRING "" FORCE)
set(CMAKE_C_FLAGS_RELEASE          "" CACHE STRING "" FORCE)

# Preprocessor definitions
set(DEFINE
  WIN32
  _WINDOWS
  WIN32_LEAN_AND_MEAN
  VC_EXTRALEAN
  OEMRESOURCE
  NOMINMAX
  UNICODE
  _UNICODE
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
  /W3
  /Oi
  /Ot
  /GT
  /GF
  /permissive-
  /Zc:inline
  /Zc:rvalueCast
  /Zc:__cplusplus
  /Zc:referenceBinding
  /Zc:throwingNew
  /volatile:iso
  /GR
  /GA
  /EHsc
  /d2FH4
  /bigobj
  /diagnostics:caret
)
set(FLAGS_DEBUG
  /ZI
  /Od
  /Ob0
  /RTC1
  /MDd
)
set(FLAGS_RELEASE
  /Zi
  /MP
  /GL
  /O2
  /guard:cf
  /Gy
  /Qpar
  /MD
  /GL
  /Qfast_transcendentals
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
set(LINK
  /DEBUG:FULL
)
set(LINK_DEBUG
  /OPT:NOREF
  /OPT:NOICF
)
set(LINK_RELEASE
  /OPT:REF
  /OPT:ICF
  /LTCG
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
set(CMAKEPKG_LINK              ${LINK}              CACHE INTERNAL "CMakePkg linker flags")
set(CMAKEPKG_LINK_DEBUG        ${LINK_DEBUG}        CACHE INTERNAL "CMakePkg linker debug flags")
set(CMAKEPKG_LINK_RELEASE      ${LINK_RELEASE}      CACHE INTERNAL "CMakePkg linker release flags")
