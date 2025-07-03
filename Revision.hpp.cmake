#pragma once

namespace @PACKAGE_NAME@ {
    /**
     * Version of the @PACKAGE_NAME@ package.
     */
    static inline constexpr auto kVersion         = "@PACKAGE_VERSION@";

    /**
     * Major version of the @PACKAGE_NAME@ package.
     */
    static inline constexpr auto kVersionMajor    = @PACKAGE_VERSION_MAJOR@;

    /**
     * Minor version of the @PACKAGE_NAME@ package.
     */
    static inline constexpr auto kVersionMinor    = @PACKAGE_VERSION_MINOR@;

    /**
     * Patch version of the @PACKAGE_NAME@ package.
     */
    static inline constexpr auto kVersionPatch    = @PACKAGE_VERSION_PATCH@;

    /**
     * Tweak version of the @PACKAGE_NAME@ package.
     */
    static inline constexpr auto kVersionTweak    = @PACKAGE_VERSION_TWEAK@;

    /**
     * Commit id of the @PACKAGE_NAME@ package.
     */
    static inline constexpr auto kVersionCommitId = "@PACKAGE_VERSION_COMMIT_ID@";

    /**
     * Timestamp of the @PACKAGE_NAME@ package.
     */
    static inline constexpr auto kTimestamp       = "@PACKAGE_TIMESTAMP@";

    /**
     * Build timestamp of the @PACKAGE_NAME@ package.
     */
    static inline constexpr auto kTimestampBuild  = @PACKAGE_TIMESTAMP_BUILD@;

    /**
     * Date of the @PACKAGE_NAME@ package.
     */
    static inline constexpr auto kDate            = "@PACKAGE_DATE@";

    /**
     * Time of the @PACKAGE_NAME@ package.
     */
    static inline constexpr auto kTime            = "@PACKAGE_TIME@";

    /**
     * Year of the @PACKAGE_NAME@ package.
     */
    static inline constexpr auto kYear            = @PACKAGE_YEAR@;
}
