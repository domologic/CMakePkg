#pragma once

namespace @MODULE_NAME@::revision {
    constexpr const char* kVersion   = "@MODULE_VERSION@";
    constexpr const char* kRevision  = "@MODULE_REVISION@";
    constexpr const char* kTag       = "@MODULE_TAG@";
    constexpr const char* kTimestamp = "@MODULE_TIMESTAMP@";
    constexpr const char* kDate      = "@MODULE_DATE@";
    constexpr int         kYear      = @MODULE_YEAR@;
    constexpr const char* kBranch    = "@MODULE_BRANCH@";
}
