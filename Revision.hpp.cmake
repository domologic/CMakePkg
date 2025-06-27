#pragma once

namespace @PACKAGE_NAME@ {
    /**
     * Version of the @PACKAGE_NAME@ package.
     */
    constexpr auto kVersion         = "@PACKAGE_VERSION@";

#cmakedefine PACKAGE_VERSION_MAJOR
#ifdef PACKAGE_VERSION_MAJOR
    /**
     * Major version of the @PACKAGE_NAME@ package.
     */
    constexpr auto kVersionMajor    = @PACKAGE_VERSION_MAJOR@;
#else
    /**
     * Major version of the @PACKAGE_NAME@ package.
     */
    constexpr auto kVersionMajor    = 0;
#endif
#undef PACKAGE_VERSION_MAJOR

#cmakedefine PACKAGE_VERSION_MINOR
#ifdef PACKAGE_VERSION_MINOR
    /**
     * Minor version of the @PACKAGE_NAME@ package.
     */
    constexpr auto kVersionMinor    = @PACKAGE_VERSION_MINOR@;
#else
    /**
     * Minor version of the @PACKAGE_NAME@ package.
     */
    constexpr auto kVersionMinor    = 0;
#endif
#undef PACKAGE_VERSION_MINOR

#cmakedefine PACKAGE_VERSION_PATCH
#ifdef PACKAGE_VERSION_PATCH
    /**
     * Patch version of the @PACKAGE_NAME@ package.
     */
    constexpr auto kVersionPatch    = @PACKAGE_VERSION_PATCH@;
#else
    /**
     * Patch version of the @PACKAGE_NAME@ package.
     */
    constexpr auto kVersionPatch    = 0;
#endif
#undef PACKAGE_VERSION_PATCH

#cmakedefine PACKAGE_VERSION_TWEAK
#ifdef PACKAGE_VERSION_TWEAK
    /**
     * Tweak version of the @PACKAGE_NAME@ package.
     */
    constexpr auto kVersionTweak    = @PACKAGE_VERSION_TWEAK@;
#else
    /**
     * Tweak version of the @PACKAGE_NAME@ package.
     */
    constexpr auto kVersionTweak    = 0;
#endif
#undef PACKAGE_VERSION_TWEAK

    /**
     * Commit id of the @PACKAGE_NAME@ package.
     */
    constexpr auto kVersionCommitId = "@PACKAGE_VERSION_COMMIT_ID@";

    /**
     * Timestamp of the @PACKAGE_NAME@ package.
     */
    constexpr auto kTimestamp       = "@PACKAGE_TIMESTAMP@";
    /**
     * Build timestamp of the @PACKAGE_NAME@ package.
     */
    constexpr auto kTimestampBuild  = @PACKAGE_TIMESTAMP_BUILD@;
    /**
     * Date of the @PACKAGE_NAME@ package.
     */
    constexpr auto kDate            = "@PACKAGE_DATE@";
    /**
     * Time of the @PACKAGE_NAME@ package.
     */
    constexpr auto kTime            = "@PACKAGE_TIME@";
    /**
     * Year of the @PACKAGE_NAME@ package.
     */
    constexpr auto kYear            = @PACKAGE_YEAR@;
}
