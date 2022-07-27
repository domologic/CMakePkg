#
# Bootstrap script loading the CMakePkg Library
#
# To make it available, include the following lines into your CMakeLists.txt before the project keyword:
#   //---
#   if (NOT DEFINED CMAKEPKG_BOOTSTRAP_FILE)
#     set(CMAKEPKG_BOOTSTRAP_FILE "${CMAKE_BINARY_DIR}/Bootstrap.cmake")
#     file(DOWNLOAD https://raw.githubusercontent.com/domologic/CMakePkg/master/Bootstrap.cmake ${CMAKEPKG_BOOTSTRAP_FILE})
#   endif()
#   include(${CMAKEPKG_BOOTSTRAP_FILE})
#   //---
#
# Important Variables:
#
#   CMAKEPKG_BOOTSTRAP_FILE
#     Path to the local copy of this bootstrap file. If this variable is not specified the file will be downloaded from the
#     default GitHub location.
#
#   CMAKEPKG_USERINIT_FILE
#     Path to the file containing user specific init information.
#
#   CMAKEPKG_PRIVATE_KEY_FILE
#     Path to file holding the ssh private key, used by git to check out. This makes only sense in case of a git@... URL
#
#   CMAKEPKG_GIT_ROOT
#     Base URL used for all git repositories. Will be determined from the project base repository if not set.
#
#   CMAKEPKG_REMOTE_ORIGIN
#     URL to the CMakePkg git repository. Will be determined from the project base repository if not set.
#
#   CMAKEPKG_SOURCE_DIR
#     Path to the local copy of the CMakePkg. Default is ${CMAKE_CURRENT_BINARY_DIR}/CMakePkgFiles.
#
#   CMAKEPKG_COMMITID_FILE
#     Text-based file defining commit ids of each package to used for the checkout. Each line defines a commit id of a single
#     package. The package name is separated by a ':' from the commit id.
#     The tag file has to start with a "---COMMITID BEGIN---" line and may end with a "---COMMITID END---" line. Example:
#       ---COMMITID BEGIN--- 
#       Domologic/DatabaseSystem: 9ad56776abb5c7061e6ad14a058c8b393ec3b3dd
#       Domologic/LMDBxx: cc64d31469693aad74b68c664afbc6cc4c5c039f
#       Extern/zstd: 745243abdd133142161da0071b4357f20bf91b1f
#       ---COMMITID END---
#     During each build, CMakePkg will generate a tag file containing all packages and their current commit ids as 'Build/CMakePkgCommitIds'.
#     Example to annotate a commit id file to a version tag (v0.13.4) in the master repository:
#        git tag -a v0.13.4 --file=Build/CMakePkgCommitIds <commit-id>
#     Example to retrieve a commit id file from an annotaged tag in the master repository:
#        git tag -l --format="%(contents)" v0.13.4 > CMakePkgCommitIds
#
#   CMAKEPKG_BRANCH
#     Specifies the CMakePkg branch that should be checked out. Default is master
#

include_guard(GLOBAL)

find_package(Git QUIET REQUIRED)

if (DEFINED CMAKEPKG_USERINIT_FILE)
  if (EXISTS ${CMAKEPKG_USERINIT_FILE})
    include(${CMAKEPKG_USERINIT_FILE})
  endif()
else()
  if (EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/UserInit.cmake)
    include(${CMAKE_CURRENT_SOURCE_DIR}/UserInit.cmake)
  endif()
endif()

if (DEFINED CMAKEPKG_PRIVATE_KEY_FILE)
  set(ENV{GIT_SSH_COMMAND} "ssh -F /dev/null -i ${CMAKEPKG_PRIVATE_KEY_FILE} -o 'StrictHostKeyChecking=no' -o 'UserKnownHostsFile=${CMAKE_BINARY_DIR}/known_hosts'")
endif()

if (NOT DEFINED CMAKEPKG_BRANCH)
  set(CMAKEPKG_BRANCH "master" CACHE INTERNAL "CMakePkg repository branch")
endif()

# Global directory used to checkout the CMakePkg project repository
if (NOT DEFINED CMAKEPKG_SOURCE_DIR)
  set(CMAKEPKG_SOURCE_DIR "${CMAKE_CURRENT_BINARY_DIR}/CMakePkg" CACHE INTERNAL "Path to cloned files from the CMakePkg repository")
endif()

if (NOT DEFINED CMAKEPKG_GIT_ROOT AND NOT DEFINED CMAKEPKG_REMOTE_ORIGIN)
  # query git remote url which will be used to locate dependencies
  execute_process(
    COMMAND
      ${GIT_EXECUTABLE} remote get-url origin
    WORKING_DIRECTORY
      ${CMAKE_SOURCE_DIR}
    OUTPUT_VARIABLE
      CMAKEPKG_GIT_ROOT
    OUTPUT_STRIP_TRAILING_WHITESPACE
  )

  if (NOT CMAKEPKG_GIT_ROOT)
    message(FATAL_ERROR "Could not get current git remote origin url!")
  endif()

  if (CMAKEPKG_GIT_ROOT MATCHES "^git@.*")
    # ensure that ":" is always followed by "/"
    string(REGEX REPLACE ":" ":/" CMAKEPKG_GIT_ROOT ${CMAKEPKG_GIT_ROOT})
    string(REGEX REPLACE "/+" "/" CMAKEPKG_GIT_ROOT ${CMAKEPKG_GIT_ROOT})
  endif()
  # remove last two subfolders in URL (project name)
  string(REGEX REPLACE "/+$"     "" CMAKEPKG_GIT_ROOT ${CMAKEPKG_GIT_ROOT})
  string(REGEX REPLACE "/[^/]*$" "" CMAKEPKG_GIT_ROOT ${CMAKEPKG_GIT_ROOT})
  string(REGEX REPLACE "/[^/]*$" "" CMAKEPKG_GIT_ROOT ${CMAKEPKG_GIT_ROOT})

  # global git domain
  set(CMAKEPKG_GIT_ROOT ${CMAKEPKG_GIT_ROOT} CACHE STRING "git domain")
  message(STATUS "Using '${CMAKEPKG_GIT_ROOT}' as git root for dependency resolution")

  # set CMakePkg git repository origin url
  set(CMAKEPKG_REMOTE_ORIGIN ${CMAKEPKG_GIT_ROOT}/domologic/CMakePkg.git CACHE STRING "CMakePkg git repository origin url")
endif()

# clone the cmake module library
if (NOT EXISTS ${CMAKEPKG_SOURCE_DIR})
  execute_process(
    COMMAND
      ${GIT_EXECUTABLE} clone -b ${CMAKEPKG_BRANCH} --depth 1 ${CMAKEPKG_REMOTE_ORIGIN} ${CMAKEPKG_SOURCE_DIR}
    RESULT_VARIABLE
      RESULT
    OUTPUT_QUIET
  )

  if (NOT ${RESULT} EQUAL "0")
    message(FATAL_ERROR "Could not clone CMakePkg sources from ${CMAKEPKG_REMOTE_ORIGIN}")
  endif()
endif()

# load the library
include(${CMAKEPKG_SOURCE_DIR}/Init.cmake)
