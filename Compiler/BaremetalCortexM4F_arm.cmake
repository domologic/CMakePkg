#
# Internal
# Load compiler configuration for Baremetal Cortex M4F arm platform
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
  TOOLCHAIN=GCC
  TOOLCHAIN_GCC_
)
set(DEFINE_DEBUG
  DEBUG_
)
set(DEFINE_RELEASE
  RELEASE
  RELEASE_
  NDEBUG
  NDEBUG_
)

# Global compiler flags
set(FLAGS
  -ffunction-sections
  -fdata-sections
  -mno-unaligned-access
  -Wall
  -Wpedantic
  -Wno-unknown-pragmas
  -mfloat-abi=softfp
  -pipe
  -c
  -fmessage-length=0
  -mcpu=cortex-m4
  -mfpu=fpv4-sp-d16
  -mthumb
)
set(FLAGS_DEBUG
  -O0
  -g
  -gdwarf-2
)

set(FLAGS_RELEASE
  -Os
)

# C flags
#set(FLAGS_C
#
#)
#set(FLAGS_C_DEBUG
#
#)

#set(FLAGS_C_RELEASE
#
#)

# C++ flags
set(FLAGS_CXX
  -fno-exceptions
  -fno-rtti
  -fno-threadsafe-statics
)

#set(FLAGS_CXX_DEBUG
#
#)

#set(FLAGS_CXX_RELEASE
#
#)

# Linker flags
set(LINK
  -nostartfiles
  -Xlinker --gc-sections
  -specs=nano.specs
  -specs=nosys.specs
  -u _printf_float
  #-u _scanf_float ?? TODO [FB] Warum funktioniert dies nicht
  -mfloat-abi=softfp
  -mfpu=fpv4-sp-d16
  -mcpu=cortex-m4
  -mthumb
)
set(LINK_DEBUG
   -g
   -gdwarf-2
)
#set(LINK_RELEASE
#
#)

# store configuration in cmake cache
set(CMAKEPKG_DEFINE            ${DEFINE}            CACHE STRING "CMakePkg definitions")
set(CMAKEPKG_DEFINE_DEBUG      ${DEFINE_DEBUG}      CACHE STRING "CMakePkg debug definitions")
set(CMAKEPKG_DEFINE_RELEASE    ${DEFINE_RELEASE}    CACHE STRING "CMakePkg release definitions")
set(CMAKEPKG_FLAGS             ${FLAGS}             CACHE STRING "CMakePkg compiler flags")
set(CMAKEPKG_FLAGS_DEBUG       ${FLAGS_DEBUG}       CACHE STRING "CMakePkg compiler debug flags")
set(CMAKEPKG_FLAGS_RELEASE     ${FLAGS_RELEASE}     CACHE STRING "CMakePkg compiler release flags")
#set(CMAKEPKG_FLAGS_C           ${FLAGS_C}           CACHE STRING "CMakePkg c flags")
#set(CMAKEPKG_FLAGS_C_DEBUG     ${FLAGS_C_DEBUG}     CACHE STRING "CMakePkg c debug flags")
#set(CMAKEPKG_FLAGS_C_RELEASE   ${FLAGS_C_RELEASE}   CACHE STRING "CMakePkg c release flags")
set(CMAKEPKG_FLAGS_CXX         ${FLAGS_CXX}         CACHE STRING "CMakePkg c++ flags")
#set(CMAKEPKG_FLAGS_CXX_DEBUG   ${FLAGS_CXX_DEBUG}   CACHE STRING "CMakePkg c++ debug flags")
#set(CMAKEPKG_FLAGS_CXX_RELEASE ${FLAGS_CXX_RELEASE} CACHE STRING "CMakePkg c++ release flags")
set(CMAKEPKG_LINK              ${LINK}              CACHE STRING "CMakePkg linker flags")
set(CMAKEPKG_LINK_DEBUG        ${LINK_DEBUG}        CACHE STRING "CMakePkg linker debug flags")
#set(CMAKEPKG_LINK_RELEASE      ${LINK_RELEASE}      CACHE STRING "CMakePkg linker release flags")

#Don't use position independent code
set(CMAKE_POSITION_INDEPENDENT_CODE  OFF  CACHE INTERNAL "" FORCE)
