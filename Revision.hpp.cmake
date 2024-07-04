#pragma once

namespace @PACKAGE_NAME@ {
    constexpr auto kVersion      = "@PACKAGE_VERSION@";

#cmakedefine PACKAGE_VERSION_MAJOR
#ifdef PACKAGE_VERSION_MAJOR
    constexpr auto kVersionMajor = @PACKAGE_VERSION_MAJOR@;
#else
    constexpr auto kVersionMajor = 0;
#endif
#undef PACKAGE_VERSION_MAJOR

#cmakedefine PACKAGE_VERSION_MINOR
#ifdef PACKAGE_VERSION_MINOR
    constexpr auto kVersionMinor = @PACKAGE_VERSION_MINOR@;
#else
    constexpr auto kVersionMinor = 0;
#endif
#undef PACKAGE_VERSION_MINOR

#cmakedefine PACKAGE_VERSION_PATCH
#ifdef PACKAGE_VERSION_PATCH
    constexpr auto kVersionPatch = @PACKAGE_VERSION_PATCH@;
#else
    constexpr auto kVersionPatch = 0;
#endif
#undef PACKAGE_VERSION_PATCH

#cmakedefine PACKAGE_VERSION_TWEAK
#ifdef PACKAGE_VERSION_TWEAK
    constexpr auto kVersionTweak = @PACKAGE_VERSION_TWEAK@;
#else
    constexpr auto kVersionTweak = 0;
#endif
#undef PACKAGE_VERSION_TWEAK

    constexpr auto kTimestamp = "@PACKAGE_TIMESTAMP@";
    constexpr auto kDate      = "@PACKAGE_DATE@";
    constexpr auto kTime      = "@PACKAGE_TIME@";
    constexpr auto kYear      = @PACKAGE_YEAR@;
}
