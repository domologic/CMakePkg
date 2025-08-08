#
# Internal
# Load compiler configuration for Windows AMD64 platform
#
set_compiler_defaults(
  # preprocessor definitions
  DEFINE
    _CRT_NONSTDC_NO_WARNINGS
    _CRT_SECURE_NO_WARNINGS
    _WINSOCK_DEPRECATED_NO_WARNINGS
    NOMINMAX
    WIN32
    WIN32_LEAN_AND_MEAN
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
  # debug compiler flags
  FLAGS_DEBUG
    /MTd
    /Ob0
    /Od
    /RTC1
    /Zi
  # release compiler flags
  FLAGS_RELEASE
    /GL
    /Gw
    /MT
    /MP
    /O2
    /Ob3
    /Qpar
  # ASM compiler flags
  FLAGS_ASM_MASM
    /nologo
    /quiet
  # C compiler flags
  FLAGS_C
    /TC
  # C++ compiler flags
  FLAGS_CXX
    /TP
  # debug linker flags
  LINK_DEBUG
    /DEBUG:FULL
    /OPT:NOICF
    /OPT:NOREF
  # release linker flags
  LINK_RELEASE
    /DEBUG:NONE
    /LTCG
    /OPT:ICF
    /OPT:REF
)
