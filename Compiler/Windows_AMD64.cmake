macro(load_compiler_config)
  # preprocessor definitions
  set(DEFINE
    WIN32_LEAN_AND_MEAN
    VC_EXTRALEAN
    OEMRESOURCE
    NOMINMAX
    UNICODE
    _UNICODE
  )
  set(DEFINE_DEBUG
    DEBUG
  )
  set(DEFINE_RELEASE
    NDEBUG
    _NDEBUG
  )

  # global flags
  set(FLAGS
    /Oi
    /Ot
    /GT
    /GF
    /arch:AVX2
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
  #set(FLAGS_C_RELEASE          "")

  # c++ flags
  set(FLAGS_CXX
    /TP
  )
  #set(FLAGS_CXX_DEBUG          "")
  #set(FLAGS_CXX_RELEASE        "")

  #set(LINK                     "")
  set(LINK_DEBUG
    /OPT:NOREF
    /OPT:NOICF
    /DEBUG:FULL
  )
  set(LINK_RELEASE
    /OPT:REF
    /OPT:ICF
    /LTCG
  )
endmacro()
