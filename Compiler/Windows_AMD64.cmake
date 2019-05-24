macro(load_compiler_config)
  # global flags
  set(FLAGS                    "/JMC /Oi /Ot /GT /GF /arch:AVX2 /flavor:INTEL /permissive- /Zc:rvalueCast /GR /openmp /std:c++17 /EHsc")
  set(FLAGS_DEBUG              "/ZI /Od /Ob0 /RTC1 /MDd")
  set(FLAGS_RELWITHDEBINFO     "/Zi")
  set(FLAGS_RELEASE            "/MP /GL /Ox /Ob2 /guard:cf /Gy /Qpar")

  # preprocessor definitions
  set(DEFINE                    "/DPLATFORM_X86 /DWIN32_LEAN_AND_MEAN /DVC_EXTRALEAN /DWIN32 /D_WIN32 /DWIN64 /D_WIN64 /DNOMINMAX /D_UNICODE /D_WINDOWS")
  set(DEFINE_DEBUG              "/DDEBUG /D_DEBUG /DRP_DEBUG")
  #set(DEFINE_RELWITHDEBINFO     "")
  set(DEFINE_RELEASE            "/DNODEBUG /D_NODEBUG /DNDEBUG")

  # c flags
  set(FLAGS_C                  "/TC")
  #set(FLAGS_C_DEBUG            "")
  #set(FLAGS_C_RELWITHDEBINFO   "")
  #set(FLAGS_C_RELEASE          "")

  # c++ flags
  set(FLAGS_CXX                "/TP")
  #set(FLAGS_CXX_DEBUG          "")
  #set(FLAGS_CXX_RELWITHDEBINFO "")
  #set(FLAGS_CXX_RELEASE        "")
endmacro()