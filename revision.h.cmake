#pragma once

/**
 * Version of the @PACKAGE_NAME@ package.
 */
#define @PACKAGE_NAME_UPPER@_VERSION              "@PACKAGE_VERSION@"

#cmakedefine PACKAGE_VERSION_MAJOR
#ifdef PACKAGE_VERSION_MAJOR
   /**
    * Major version of the @PACKAGE_NAME@ package.
    */
#  define @PACKAGE_NAME_UPPER@_VERSION_MAJOR      @PACKAGE_VERSION_MAJOR@
#else
   /**
    * Major version of the @PACKAGE_NAME@ package.
    */
#  define @PACKAGE_NAME_UPPER@_VERSION_MAJOR      0
#endif
#undef PACKAGE_VERSION_MAJOR

#cmakedefine PACKAGE_VERSION_MINOR
#ifdef PACKAGE_VERSION_MINOR
   /**
    * Minor version of the @PACKAGE_NAME@ package.
    */
#  define @PACKAGE_NAME_UPPER@_VERSION_MINOR      @PACKAGE_VERSION_MINOR@
#else
   /**
    * Minor version of the @PACKAGE_NAME@ package.
    */
#  define @PACKAGE_NAME_UPPER@_VERSION_MINOR      0
#endif
#undef PACKAGE_VERSION_MINOR

#cmakedefine PACKAGE_VERSION_PATCH
#ifdef PACKAGE_VERSION_PATCH
   /**
    * Patch version of the @PACKAGE_NAME@ package.
    */
#  define @PACKAGE_NAME_UPPER@_VERSION_PATCH      @PACKAGE_VERSION_PATCH@
#else
   /**
    * Patch version of the @PACKAGE_NAME@ package.
    */
#  define @PACKAGE_NAME_UPPER@_VERSION_PATCH 0
#endif
#undef PACKAGE_VERSION_PATCH

#cmakedefine PACKAGE_VERSION_TWEAK
#ifdef PACKAGE_VERSION_TWEAK
   /**
    * Tweak version of the @PACKAGE_NAME@ package.
    */
#  define @PACKAGE_NAME_UPPER@_VERSION_TWEAK      @PACKAGE_VERSION_TWEAK@
#else
   /**
    * Tweak version of the @PACKAGE_NAME@ package.
    */
#  define @PACKAGE_NAME_UPPER@_VERSION_TWEAK      0
#endif
#undef PACKAGE_VERSION_TWEAK

#cmakedefine PACKAGE_VERSION_COMMIT_ID
#ifdef PACKAGE_VERSION_COMMIT_ID
   /**
    * Commit id of the @PACKAGE_NAME@ package.
    */
#  define @PACKAGE_NAME_UPPER@_VERSION_COMMIT_ID  @PACKAGE_VERSION_COMMIT_ID@
#else
   /**
    * Commit id of the @PACKAGE_NAME@ package.
    */
#  define @PACKAGE_NAME_UPPER@_VERSION_COMMIT_ID  0
#endif
#undef PACKAGE_VERSION_COMMIT_ID

/**
 * Timestamp of the @PACKAGE_NAME@ package.
 */
#define @PACKAGE_NAME_UPPER@_TIMESTAMP            "@PACKAGE_TIMESTAMP@"
/**
 * Build timestamp of the @PACKAGE_NAME@ package.
 */
#define @PACKAGE_NAME_UPPER@_TIMESTAMP_BUILD      "@PACKAGE_TIMESTAMP_BUILD@"
/**
 * Date of the @PACKAGE_NAME@ package.
 */
#define @PACKAGE_NAME_UPPER@_DATE                 "@PACKAGE_DATE@"
/**
 * Time of the @PACKAGE_NAME@ package.
 */
#define @PACKAGE_NAME_UPPER@_TIME                 "@PACKAGE_TIME@"
/**
 * Year of the @PACKAGE_NAME@ package.
 */
#define @PACKAGE_NAME_UPPER@_YEAR                 @PACKAGE_YEAR@
