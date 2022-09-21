#pragma once

namespace @PACKAGE_NAME@ {
    constexpr auto kVersion   = "@PACKAGE_VERSION@";
    constexpr auto kTimestamp = "@PACKAGE_TIMESTAMP@";
    constexpr auto kDate      = "@PACKAGE_DATE@";
    constexpr auto kYear      = @PACKAGE_YEAR@;

    /**
     * DEPRECATED
     */
    namespace revision {
        /**
         * DEPRECATED
         */
        [[deprecated]] constexpr auto kVersion   = "@PACKAGE_VERSION@";
        /**
         * DEPRECATED
         */
        [[deprecated]] constexpr auto kRevision  = "@PACKAGE_REVISION@";
        /**
         * DEPRECATED
         */
        [[deprecated]] constexpr auto kTag       = "@PACKAGE_TAG@";
        /**
         * DEPRECATED
         */
        [[deprecated]] constexpr auto kTimestamp = "@PACKAGE_TIMESTAMP@";
        /**
         * DEPRECATED
         */
        [[deprecated]] constexpr auto kDate      = "@PACKAGE_DATE@";
        /**
         * DEPRECATED
         */
        [[deprecated]] constexpr auto kYear      = @PACKAGE_YEAR@;
        /**
         * DEPRECATED
         */
        [[deprecated]] constexpr auto kBranch    = "@PACKAGE_BRANCH@";
    }
}
