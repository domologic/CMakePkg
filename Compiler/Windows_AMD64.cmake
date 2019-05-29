macro(load_compiler_config)
  # preprocessor definitions
  set(DEFINE
    WIN32
    _WIN32
    WIN64
    _WIN64
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
  #set(DEFINE_RELWITHDEBINFO)
  set(DEFINE_RELEASE
    NODEBUG
    _NODEBUG
    NDEBUG
  )

  # global flags
  set(FLAGS
    /JMC
    /Oi
    /Ot
    /GT
    /GF
    /arch:AVX2
    /favor:INTEL64
    /permissive-
    /Zc:inline
    /Zc:rvalueCast
    /Zc:__cplusplus
    /Zc:referenceBinding
    /Zc:throwingNew
    /volatile:iso
    /GR
    /GA
    /std:c++17
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
  set(FLAGS_RELWITHDEBINFO
    /Zi
    /MP
    /GL
    /O2
    /guard:cf
    /Gy
    /Qpar
    /Qfast_transcendentals
  )
  set(FLAGS_RELEASE
    /MP
    /GL
    /O2
    /guard:cf
    /Gy
    /Qpar
    /Qfast_transcendentals
  )

  # c flags
  set(FLAGS_C
    /TC
  )
  #set(FLAGS_C_DEBUG            "")
  #set(FLAGS_C_RELWITHDEBINFO   "")
  #set(FLAGS_C_RELEASE          "")

  # c++ flags
  set(FLAGS_CXX
    /TP
  )
  #set(FLAGS_CXX_DEBUG          "")
  #set(FLAGS_CXX_RELWITHDEBINFO "")
  #set(FLAGS_CXX_RELEASE        "")

  #set(LINK                     "")
  set(LINK_DEBUG
    /OPT:NOREF
    /OPT:NOICF
    /DEBUG:FULL
  )
  set(LINK_RELWITHDEBINFO
    /OPT:REF
    /OPT:ICF
    /DEBUG
    /LTCG
  )
  set(LINK_RELEASE
    /OPT:REF
    /OPT:ICF
    /LTCG
  )
endmacro()
