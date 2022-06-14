#pragma once

namespace @MODULE_NAME@ {
    constexpr auto kVersion   = "@MODULE_VERSION@";
    constexpr auto kTimestamp = "@MODULE_TIMESTAMP@";
    constexpr auto kDate      = "@MODULE_DATE@";
    constexpr auto kYear      = @MODULE_YEAR@;

    /**
     * DEPRECATED
     */
    namespace revision {
        /**
         * DEPRECATED
         */
        [[deprecated]] constexpr auto kVersion   = "@MODULE_VERSION@";
        /**
         * DEPRECATED
         */
        [[deprecated]] constexpr auto kRevision  = "@MODULE_REVISION@";
        /**
         * DEPRECATED
         */
        [[deprecated]] constexpr auto kTag       = "@MODULE_TAG@";
        /**
         * DEPRECATED
         */
        [[deprecated]] constexpr auto kTimestamp = "@MODULE_TIMESTAMP@";
        /**
         * DEPRECATED
         */
        [[deprecated]] constexpr auto kDate      = "@MODULE_DATE@";
        /**
         * DEPRECATED
         */
        [[deprecated]] constexpr auto kYear      = @MODULE_YEAR@;
        /**
         * DEPRECATED
         */
        [[deprecated]] constexpr auto kBranch    = "@MODULE_BRANCH@";
    }
}
