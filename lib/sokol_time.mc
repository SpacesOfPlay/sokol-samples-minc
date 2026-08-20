// sokol_time
import sokol_all;

// sokol_time
when os(windows) {
    extern "kernel32.dll" {
        i32 QueryPerformanceFrequency(LARGE_INTEGER* lp);
        i32 QueryPerformanceCounter(LARGE_INTEGER* lp);
    }
}


when os(ios) {
type __arr_u64_2 = u64[2];
struct timespec {
    i64 tv_sec;
    i64 tv_nsec;
}

struct mach_timebase_info_data_t {
    u32 numer;
    u32 denom;
}

/*-- IMPLEMENTATION ----------------------------------------------------------*/
struct _stm_state_t {
    u32 initialized;
    mach_timebase_info_data_t timebase;
    u64 start;
}

/*
    sokol_time.h    -- simple cross-platform time measurement

    Project URL: https://github.com/floooh/sokol

    Do this:
        #define SOKOL_IMPL or
        #define SOKOL_TIME_IMPL
    before you include this file in *one* C or C++ file to create the
    implementation.

    Optionally provide the following defines with your own implementations:
    SOKOL_ASSERT(c)     - your own assert macro (default: assert(c))
    SOKOL_TIME_API_DECL - public function declaration prefix (default: extern)
    SOKOL_API_DECL      - same as SOKOL_TIME_API_DECL
    SOKOL_API_IMPL      - public function implementation prefix (default: -)

    If sokol_time.h is compiled as a DLL, define the following before
    including the declaration or implementation:

    SOKOL_DLL

    On Windows, SOKOL_DLL will define SOKOL_TIME_API_DECL as __declspec(dllexport)
    or __declspec(dllimport) as needed.

    void stm_setup();
        Call once before any other functions to initialize sokol_time
        (this calls for instance QueryPerformanceFrequency on Windows)

    uint64_t stm_now();
        Get current point in time in unspecified 'ticks'. The value that
        is returned has no relation to the 'wall-clock' time and is
        not in a specific time unit, it is only useful to compute
        time differences.

    uint64_t stm_diff(uint64_t new, uint64_t old);
        Computes the time difference between new and old. This will always
        return a positive, non-zero value.

    uint64_t stm_since(uint64_t start);
        Takes the current time, and returns the elapsed time since start
        (this is a shortcut for "stm_diff(stm_now(), start)")

    uint64_t stm_laptime(uint64_t* last_time);
        This is useful for measuring frame time and other recurring
        events. It takes the current time, returns the time difference
        to the value in last_time, and stores the current time in
        last_time for the next call. If the value in last_time is 0,
        the return value will be zero (this usually happens on the
        very first call).

    uint64_t stm_round_to_common_refresh_rate(uint64_t duration)
        This oddly named function takes a measured frame time and
        returns the closest "nearby" common display refresh rate frame duration
        in ticks. If the input duration isn't close to any common display
        refresh rate, the input duration will be returned unchanged as a fallback.
        The main purpose of this function is to remove jitter/inaccuracies from
        measured frame times, and instead use the display refresh rate as
        frame duration.
        NOTE: for more robust frame timing, consider using the
        sokol_app.h function sapp_frame_duration()

    Use the following functions to convert a duration in ticks into
    useful time units:

    double stm_sec(uint64_t ticks);
    double stm_ms(uint64_t ticks);
    double stm_us(uint64_t ticks);
    double stm_ns(uint64_t ticks);
        Converts a tick value into seconds, milliseconds, microseconds
        or nanoseconds. Note that not all platforms will have nanosecond
        or even microsecond precision.

    Uses the following time measurement functions under the hood:

    Windows:        QueryPerformanceFrequency() / QueryPerformanceCounter()
    MacOS/iOS:      mach_absolute_time()
    emscripten:     emscripten_get_now()
    Linux+others:   clock_gettime(CLOCK_MONOTONIC)

    zlib/libpng license

    Copyright (c) 2018 Andre Weissflog

    This software is provided 'as-is', without any express or implied warranty.
    In no event will the authors be held liable for any damages arising from the
    use of this software.

    Permission is granted to anyone to use this software for any purpose,
    including commercial applications, and to alter it and redistribute it
    freely, subject to the following restrictions:

        1. The origin of this software must not be misrepresented; you must not
        claim that you wrote the original software. If you use this software in a
        product, an acknowledgment in the product documentation would be
        appreciated but is not required.

        2. Altered source versions must be plainly marked as such, and must not
        be misrepresented as being the original software.

        3. This notice may not be removed or altered from any source
        distribution.
*/
private {
_stm_state_t _stm;

/* prevent 64-bit overflow when computing relative timestamp
    see https://gist.github.com/jspohr/3dc4f00033d79ec5bdaf67bc46c813e3
*/
i64 _stm_int64_muldiv(i64 value, i64 numer, i64 denom) {
    i64 q = value / denom;
    i64 r = value % denom;
    return q * numer + r * numer / denom;
}
}

void stm_setup() {
    memset(&_stm, 0, cast(u64, sizeof(_stm)));
    _stm.initialized = 0xABCDABCD;
}

u64 stm_now() {
    u64 now;
    return now;
}

u64 stm_diff(u64 new_ticks, u64 old_ticks) {
    if new_ticks > old_ticks {
        return new_ticks - old_ticks;
    } else {
        return 1;
    }
}

u64 stm_since(u64 start_ticks) {
    return stm_diff(stm_now(), start_ticks);
}

u64 stm_laptime(u64* last_time) {
    u64 dt = 0;
    u64 now = stm_now();
    if 0 != *last_time {
        dt = stm_diff(now, *last_time);
    }
    *last_time = now;
    return dt;
}
// first number is frame duration in ns, second number is tolerance in ns,
// the resulting min/max values must not overlap!
private {
__arr_u64_2[10] _stm_refresh_rates = {
    {16666667, 1000000},
    {13888889, 250000},
    {13333333, 250000},
    {11764706, 250000},
    {11111111, 250000},
    {10000000, 500000},
    {8333333, 500000},
    {6944445, 500000},
    {4166667, 1000000},
    {0, 0},
};
}

u64 stm_round_to_common_refresh_rate(u64 ticks) {
    u64 ns;
    i32 i = 0;
    while true {
        ns = _stm_refresh_rates[i][0];
        if 0 != ns == 0 {
            break;
        }
        u64 tol = _stm_refresh_rates[i][1];
        if ticks > ns - tol && ticks < ns + tol {
            return ns;
        }
        i++;
    }
    return ticks;
}

f64 stm_sec(u64 ticks) {
    return cast(f64, ticks) / 1000000000.0;
}

f64 stm_ms(u64 ticks) {
    return cast(f64, ticks) / 1000000.0;
}

f64 stm_us(u64 ticks) {
    return cast(f64, ticks) / 1000.0;
}

f64 stm_ns(u64 ticks) {
    return cast(f64, ticks);
}

}

when os(linux) {
type __arr_u64_2 = u64[2];
struct timespec {
    i64 tv_sec;
    i64 tv_nsec;
}

struct mach_timebase_info_data_t {
    u32 numer;
    u32 denom;
}

struct _stm_state_t {
    u32 initialized;
    u64 start;
}

/*
    sokol_time.h    -- simple cross-platform time measurement

    Project URL: https://github.com/floooh/sokol

    Do this:
        #define SOKOL_IMPL or
        #define SOKOL_TIME_IMPL
    before you include this file in *one* C or C++ file to create the
    implementation.

    Optionally provide the following defines with your own implementations:
    SOKOL_ASSERT(c)     - your own assert macro (default: assert(c))
    SOKOL_TIME_API_DECL - public function declaration prefix (default: extern)
    SOKOL_API_DECL      - same as SOKOL_TIME_API_DECL
    SOKOL_API_IMPL      - public function implementation prefix (default: -)

    If sokol_time.h is compiled as a DLL, define the following before
    including the declaration or implementation:

    SOKOL_DLL

    On Windows, SOKOL_DLL will define SOKOL_TIME_API_DECL as __declspec(dllexport)
    or __declspec(dllimport) as needed.

    void stm_setup();
        Call once before any other functions to initialize sokol_time
        (this calls for instance QueryPerformanceFrequency on Windows)

    uint64_t stm_now();
        Get current point in time in unspecified 'ticks'. The value that
        is returned has no relation to the 'wall-clock' time and is
        not in a specific time unit, it is only useful to compute
        time differences.

    uint64_t stm_diff(uint64_t new, uint64_t old);
        Computes the time difference between new and old. This will always
        return a positive, non-zero value.

    uint64_t stm_since(uint64_t start);
        Takes the current time, and returns the elapsed time since start
        (this is a shortcut for "stm_diff(stm_now(), start)")

    uint64_t stm_laptime(uint64_t* last_time);
        This is useful for measuring frame time and other recurring
        events. It takes the current time, returns the time difference
        to the value in last_time, and stores the current time in
        last_time for the next call. If the value in last_time is 0,
        the return value will be zero (this usually happens on the
        very first call).

    uint64_t stm_round_to_common_refresh_rate(uint64_t duration)
        This oddly named function takes a measured frame time and
        returns the closest "nearby" common display refresh rate frame duration
        in ticks. If the input duration isn't close to any common display
        refresh rate, the input duration will be returned unchanged as a fallback.
        The main purpose of this function is to remove jitter/inaccuracies from
        measured frame times, and instead use the display refresh rate as
        frame duration.
        NOTE: for more robust frame timing, consider using the
        sokol_app.h function sapp_frame_duration()

    Use the following functions to convert a duration in ticks into
    useful time units:

    double stm_sec(uint64_t ticks);
    double stm_ms(uint64_t ticks);
    double stm_us(uint64_t ticks);
    double stm_ns(uint64_t ticks);
        Converts a tick value into seconds, milliseconds, microseconds
        or nanoseconds. Note that not all platforms will have nanosecond
        or even microsecond precision.

    Uses the following time measurement functions under the hood:

    Windows:        QueryPerformanceFrequency() / QueryPerformanceCounter()
    MacOS/iOS:      mach_absolute_time()
    emscripten:     emscripten_get_now()
    Linux+others:   clock_gettime(CLOCK_MONOTONIC)

    zlib/libpng license

    Copyright (c) 2018 Andre Weissflog

    This software is provided 'as-is', without any express or implied warranty.
    In no event will the authors be held liable for any damages arising from the
    use of this software.

    Permission is granted to anyone to use this software for any purpose,
    including commercial applications, and to alter it and redistribute it
    freely, subject to the following restrictions:

        1. The origin of this software must not be misrepresented; you must not
        claim that you wrote the original software. If you use this software in a
        product, an acknowledgment in the product documentation would be
        appreciated but is not required.

        2. Altered source versions must be plainly marked as such, and must not
        be misrepresented as being the original software.

        3. This notice may not be removed or altered from any source
        distribution.
*/
/*-- IMPLEMENTATION ----------------------------------------------------------*/
private { _stm_state_t _stm; }

/* prevent 64-bit overflow when computing relative timestamp
    see https://gist.github.com/jspohr/3dc4f00033d79ec5bdaf67bc46c813e3
*/
void stm_setup() {
    memset(&_stm, 0, cast(u64, sizeof(_stm)));
    _stm.initialized = 0xABCDABCD;
    noinit timespec ts;
    clock_gettime(CLOCK_MONOTONIC, &ts);
    _stm.start = cast(u64, ts.tv_sec) * 1000000000 + cast(u64, ts.tv_nsec);
}

u64 stm_now() {
    u64 now;
    noinit timespec ts;
    clock_gettime(CLOCK_MONOTONIC, &ts);
    now = cast(u64, ts.tv_sec) * 1000000000 + cast(u64, ts.tv_nsec) - _stm.start;
    return now;
}

u64 stm_diff(u64 new_ticks, u64 old_ticks) {
    if new_ticks > old_ticks {
        return new_ticks - old_ticks;
    } else {
        return 1;
    }
}

u64 stm_since(u64 start_ticks) {
    return stm_diff(stm_now(), start_ticks);
}

u64 stm_laptime(u64* last_time) {
    u64 dt = 0;
    u64 now = stm_now();
    if 0 != *last_time {
        dt = stm_diff(now, *last_time);
    }
    *last_time = now;
    return dt;
}
// first number is frame duration in ns, second number is tolerance in ns,
// the resulting min/max values must not overlap!
private {
__arr_u64_2[10] _stm_refresh_rates = {
    {16666667, 1000000},
    {13888889, 250000},
    {13333333, 250000},
    {11764706, 250000},
    {11111111, 250000},
    {10000000, 500000},
    {8333333, 500000},
    {6944445, 500000},
    {4166667, 1000000},
    {0, 0},
};
}

u64 stm_round_to_common_refresh_rate(u64 ticks) {
    u64 ns;
    i32 i = 0;
    while true {
        ns = _stm_refresh_rates[i][0];
        if 0 != ns == 0 {
            break;
        }
        u64 tol = _stm_refresh_rates[i][1];
        if ticks > ns - tol && ticks < ns + tol {
            return ns;
        }
        i++;
    }
    return ticks;
}

f64 stm_sec(u64 ticks) {
    return cast(f64, ticks) / 1000000000.0;
}

f64 stm_ms(u64 ticks) {
    return cast(f64, ticks) / 1000000.0;
}

f64 stm_us(u64 ticks) {
    return cast(f64, ticks) / 1000.0;
}

f64 stm_ns(u64 ticks) {
    return cast(f64, ticks);
}

}

when os(macos) {
type __arr_u64_2 = u64[2];
struct timespec {
    i64 tv_sec;
    i64 tv_nsec;
}

struct mach_timebase_info_data_t {
    u32 numer;
    u32 denom;
}

/*-- IMPLEMENTATION ----------------------------------------------------------*/
struct _stm_state_t {
    u32 initialized;
    mach_timebase_info_data_t timebase;
    u64 start;
}

/*
    sokol_time.h    -- simple cross-platform time measurement

    Project URL: https://github.com/floooh/sokol

    Do this:
        #define SOKOL_IMPL or
        #define SOKOL_TIME_IMPL
    before you include this file in *one* C or C++ file to create the
    implementation.

    Optionally provide the following defines with your own implementations:
    SOKOL_ASSERT(c)     - your own assert macro (default: assert(c))
    SOKOL_TIME_API_DECL - public function declaration prefix (default: extern)
    SOKOL_API_DECL      - same as SOKOL_TIME_API_DECL
    SOKOL_API_IMPL      - public function implementation prefix (default: -)

    If sokol_time.h is compiled as a DLL, define the following before
    including the declaration or implementation:

    SOKOL_DLL

    On Windows, SOKOL_DLL will define SOKOL_TIME_API_DECL as __declspec(dllexport)
    or __declspec(dllimport) as needed.

    void stm_setup();
        Call once before any other functions to initialize sokol_time
        (this calls for instance QueryPerformanceFrequency on Windows)

    uint64_t stm_now();
        Get current point in time in unspecified 'ticks'. The value that
        is returned has no relation to the 'wall-clock' time and is
        not in a specific time unit, it is only useful to compute
        time differences.

    uint64_t stm_diff(uint64_t new, uint64_t old);
        Computes the time difference between new and old. This will always
        return a positive, non-zero value.

    uint64_t stm_since(uint64_t start);
        Takes the current time, and returns the elapsed time since start
        (this is a shortcut for "stm_diff(stm_now(), start)")

    uint64_t stm_laptime(uint64_t* last_time);
        This is useful for measuring frame time and other recurring
        events. It takes the current time, returns the time difference
        to the value in last_time, and stores the current time in
        last_time for the next call. If the value in last_time is 0,
        the return value will be zero (this usually happens on the
        very first call).

    uint64_t stm_round_to_common_refresh_rate(uint64_t duration)
        This oddly named function takes a measured frame time and
        returns the closest "nearby" common display refresh rate frame duration
        in ticks. If the input duration isn't close to any common display
        refresh rate, the input duration will be returned unchanged as a fallback.
        The main purpose of this function is to remove jitter/inaccuracies from
        measured frame times, and instead use the display refresh rate as
        frame duration.
        NOTE: for more robust frame timing, consider using the
        sokol_app.h function sapp_frame_duration()

    Use the following functions to convert a duration in ticks into
    useful time units:

    double stm_sec(uint64_t ticks);
    double stm_ms(uint64_t ticks);
    double stm_us(uint64_t ticks);
    double stm_ns(uint64_t ticks);
        Converts a tick value into seconds, milliseconds, microseconds
        or nanoseconds. Note that not all platforms will have nanosecond
        or even microsecond precision.

    Uses the following time measurement functions under the hood:

    Windows:        QueryPerformanceFrequency() / QueryPerformanceCounter()
    MacOS/iOS:      mach_absolute_time()
    emscripten:     emscripten_get_now()
    Linux+others:   clock_gettime(CLOCK_MONOTONIC)

    zlib/libpng license

    Copyright (c) 2018 Andre Weissflog

    This software is provided 'as-is', without any express or implied warranty.
    In no event will the authors be held liable for any damages arising from the
    use of this software.

    Permission is granted to anyone to use this software for any purpose,
    including commercial applications, and to alter it and redistribute it
    freely, subject to the following restrictions:

        1. The origin of this software must not be misrepresented; you must not
        claim that you wrote the original software. If you use this software in a
        product, an acknowledgment in the product documentation would be
        appreciated but is not required.

        2. Altered source versions must be plainly marked as such, and must not
        be misrepresented as being the original software.

        3. This notice may not be removed or altered from any source
        distribution.
*/
private {
_stm_state_t _stm;

/* prevent 64-bit overflow when computing relative timestamp
    see https://gist.github.com/jspohr/3dc4f00033d79ec5bdaf67bc46c813e3
*/
i64 _stm_int64_muldiv(i64 value, i64 numer, i64 denom) {
    i64 q = value / denom;
    i64 r = value % denom;
    return q * numer + r * numer / denom;
}
}

void stm_setup() {
    memset(&_stm, 0, cast(u64, sizeof(_stm)));
    _stm.initialized = 0xABCDABCD;
}

u64 stm_now() {
    u64 now;
    return now;
}

u64 stm_diff(u64 new_ticks, u64 old_ticks) {
    if new_ticks > old_ticks {
        return new_ticks - old_ticks;
    } else {
        return 1;
    }
}

u64 stm_since(u64 start_ticks) {
    return stm_diff(stm_now(), start_ticks);
}

u64 stm_laptime(u64* last_time) {
    u64 dt = 0;
    u64 now = stm_now();
    if 0 != *last_time {
        dt = stm_diff(now, *last_time);
    }
    *last_time = now;
    return dt;
}
// first number is frame duration in ns, second number is tolerance in ns,
// the resulting min/max values must not overlap!
private {
__arr_u64_2[10] _stm_refresh_rates = {
    {16666667, 1000000},
    {13888889, 250000},
    {13333333, 250000},
    {11764706, 250000},
    {11111111, 250000},
    {10000000, 500000},
    {8333333, 500000},
    {6944445, 500000},
    {4166667, 1000000},
    {0, 0},
};
}

u64 stm_round_to_common_refresh_rate(u64 ticks) {
    u64 ns;
    i32 i = 0;
    while true {
        ns = _stm_refresh_rates[i][0];
        if 0 != ns == 0 {
            break;
        }
        u64 tol = _stm_refresh_rates[i][1];
        if ticks > ns - tol && ticks < ns + tol {
            return ns;
        }
        i++;
    }
    return ticks;
}

f64 stm_sec(u64 ticks) {
    return cast(f64, ticks) / 1000000000.0;
}

f64 stm_ms(u64 ticks) {
    return cast(f64, ticks) / 1000000.0;
}

f64 stm_us(u64 ticks) {
    return cast(f64, ticks) / 1000.0;
}

f64 stm_ns(u64 ticks) {
    return cast(f64, ticks);
}

}

when os(wasm) {
// emscripten_get_now() for sokol_time.h's wasm arm: milliseconds as a
// double. Bridged onto the host's env.clock import (nanoseconds).
private {
    extern "env" i64 clock();
}

f64 emscripten_get_now() {
    return cast(f64, clock()) / 1000000.0;
}

type __arr_u64_2 = u64[2];
/*-- IMPLEMENTATION ----------------------------------------------------------*/
struct _stm_state_t {
    u32 initialized;
    f64 start;
}

/*
    sokol_time.h    -- simple cross-platform time measurement

    Project URL: https://github.com/floooh/sokol

    Do this:
        #define SOKOL_IMPL or
        #define SOKOL_TIME_IMPL
    before you include this file in *one* C or C++ file to create the
    implementation.

    Optionally provide the following defines with your own implementations:
    SOKOL_ASSERT(c)     - your own assert macro (default: assert(c))
    SOKOL_TIME_API_DECL - public function declaration prefix (default: extern)
    SOKOL_API_DECL      - same as SOKOL_TIME_API_DECL
    SOKOL_API_IMPL      - public function implementation prefix (default: -)

    If sokol_time.h is compiled as a DLL, define the following before
    including the declaration or implementation:

    SOKOL_DLL

    On Windows, SOKOL_DLL will define SOKOL_TIME_API_DECL as __declspec(dllexport)
    or __declspec(dllimport) as needed.

    void stm_setup();
        Call once before any other functions to initialize sokol_time
        (this calls for instance QueryPerformanceFrequency on Windows)

    uint64_t stm_now();
        Get current point in time in unspecified 'ticks'. The value that
        is returned has no relation to the 'wall-clock' time and is
        not in a specific time unit, it is only useful to compute
        time differences.

    uint64_t stm_diff(uint64_t new, uint64_t old);
        Computes the time difference between new and old. This will always
        return a positive, non-zero value.

    uint64_t stm_since(uint64_t start);
        Takes the current time, and returns the elapsed time since start
        (this is a shortcut for "stm_diff(stm_now(), start)")

    uint64_t stm_laptime(uint64_t* last_time);
        This is useful for measuring frame time and other recurring
        events. It takes the current time, returns the time difference
        to the value in last_time, and stores the current time in
        last_time for the next call. If the value in last_time is 0,
        the return value will be zero (this usually happens on the
        very first call).

    uint64_t stm_round_to_common_refresh_rate(uint64_t duration)
        This oddly named function takes a measured frame time and
        returns the closest "nearby" common display refresh rate frame duration
        in ticks. If the input duration isn't close to any common display
        refresh rate, the input duration will be returned unchanged as a fallback.
        The main purpose of this function is to remove jitter/inaccuracies from
        measured frame times, and instead use the display refresh rate as
        frame duration.
        NOTE: for more robust frame timing, consider using the
        sokol_app.h function sapp_frame_duration()

    Use the following functions to convert a duration in ticks into
    useful time units:

    double stm_sec(uint64_t ticks);
    double stm_ms(uint64_t ticks);
    double stm_us(uint64_t ticks);
    double stm_ns(uint64_t ticks);
        Converts a tick value into seconds, milliseconds, microseconds
        or nanoseconds. Note that not all platforms will have nanosecond
        or even microsecond precision.

    Uses the following time measurement functions under the hood:

    Windows:        QueryPerformanceFrequency() / QueryPerformanceCounter()
    MacOS/iOS:      mach_absolute_time()
    emscripten:     emscripten_get_now()
    Linux+others:   clock_gettime(CLOCK_MONOTONIC)

    zlib/libpng license

    Copyright (c) 2018 Andre Weissflog

    This software is provided 'as-is', without any express or implied warranty.
    In no event will the authors be held liable for any damages arising from the
    use of this software.

    Permission is granted to anyone to use this software for any purpose,
    including commercial applications, and to alter it and redistribute it
    freely, subject to the following restrictions:

        1. The origin of this software must not be misrepresented; you must not
        claim that you wrote the original software. If you use this software in a
        product, an acknowledgment in the product documentation would be
        appreciated but is not required.

        2. Altered source versions must be plainly marked as such, and must not
        be misrepresented as being the original software.

        3. This notice may not be removed or altered from any source
        distribution.
*/
private { _stm_state_t _stm; }

/* prevent 64-bit overflow when computing relative timestamp
    see https://gist.github.com/jspohr/3dc4f00033d79ec5bdaf67bc46c813e3
*/
void stm_setup() {
    memset(&_stm, 0, cast(u64, sizeof(_stm)));
    _stm.initialized = 0xABCDABCD;
    _stm.start = emscripten_get_now();
}

u64 stm_now() {
    u64 now;
    f64 js_now = cast(f64, emscripten_get_now()) - _stm.start;
    now = cast(u64, js_now * 1000000.0);
    return now;
}

u64 stm_diff(u64 new_ticks, u64 old_ticks) {
    if new_ticks > old_ticks {
        return new_ticks - old_ticks;
    } else {
        return 1;
    }
}

u64 stm_since(u64 start_ticks) {
    return stm_diff(stm_now(), start_ticks);
}

u64 stm_laptime(u64* last_time) {
    u64 dt = 0;
    u64 now = stm_now();
    if 0 != *last_time {
        dt = stm_diff(now, *last_time);
    }
    *last_time = now;
    return dt;
}
// first number is frame duration in ns, second number is tolerance in ns,
// the resulting min/max values must not overlap!
private {
__arr_u64_2[10] _stm_refresh_rates = {
    {16666667, 1000000},
    {13888889, 250000},
    {13333333, 250000},
    {11764706, 250000},
    {11111111, 250000},
    {10000000, 500000},
    {8333333, 500000},
    {6944445, 500000},
    {4166667, 1000000},
    {0, 0},
};
}

u64 stm_round_to_common_refresh_rate(u64 ticks) {
    u64 ns;
    i32 i = 0;
    while true {
        ns = _stm_refresh_rates[i][0];
        if 0 != ns == 0 {
            break;
        }
        u64 tol = _stm_refresh_rates[i][1];
        if ticks > ns - tol && ticks < ns + tol {
            return ns;
        }
        i++;
    }
    return ticks;
}

f64 stm_sec(u64 ticks) {
    return cast(f64, ticks) / 1000000000.0;
}

f64 stm_ms(u64 ticks) {
    return cast(f64, ticks) / 1000000.0;
}

f64 stm_us(u64 ticks) {
    return cast(f64, ticks) / 1000.0;
}

f64 stm_ns(u64 ticks) {
    return cast(f64, ticks);
}

}

when os(windows) {
enum __enum_PROCESS_DPI_UNAWARE {
    PROCESS_DPI_UNAWARE = 0,
    PROCESS_SYSTEM_DPI_AWARE = 1,
    PROCESS_PER_MONITOR_DPI_AWARE = 2,
    MDT_EFFECTIVE_DPI = 0,
    MDT_ANGULAR_DPI = 1,
    MDT_RAW_DPI = 2,
}

type PROCESS_DPI_AWARENESS = i32;
type MONITOR_DPI_TYPE = i32;
type BOOL = i32;
type BYTE = u8;
type WORD = u16;
type DWORD = u32;
type UINT = u32;
type INT = i32;
type LONG = i32;
type ULONG = u32;
type LONGLONG = i64;
type ULONGLONG = u64;
type SHORT = i16;
type USHORT = u16;
type CHAR = u8;
type UCHAR = u8;
type WCHAR = u16;
type FLOAT = f32;
type HRESULT = i32;
type ATOM = u16;
type UINT_PTR = u64;
type INT_PTR = i64;
type ULONG_PTR = u64;
type LONG_PTR = i64;
type DWORD_PTR = u64;
type SIZE_T = u64;
type SSIZE_T = i64;
type WPARAM = u64;
type LPARAM = i64;
type LRESULT = i64;
type HANDLE = void*;
type HWND = void*;
type HDC = void*;
type HGLRC = void*;
type HINSTANCE = void*;
type HMODULE = void*;
type HMENU = void*;
type HICON = void*;
type HCURSOR = void*;
type HBRUSH = void*;
type HMONITOR = void*;
type HDROP = void*;
type HBITMAP = void*;
type HGDIOBJ = void*;
type HKL = void*;
type HRAWINPUT = void*;
type HLOCAL = void*;
type FARPROC = void*;
type PROC = void*;
type PVOID = void*;
type LPVOID = void*;
type LPCVOID = void*;
type LPSTR = u8*;
type LPCSTR = u8*;
type LPWSTR = WCHAR*;
type LPCWSTR = WCHAR*;
type PCWSTR = WCHAR*;
type LPBYTE = BYTE*;
type LPDWORD = DWORD*;
type LPWORD = WORD*;
type LPLONG = LONG*;
type LPINT = i32*;
type LPUINT = UINT*;
type LPUNKNOWN = void*;
type WNDPROC = fn(HWND, UINT, WPARAM, LPARAM): LRESULT;
type LPRECT = RECT*;
type errno_t = i32;
type handle_type = i64;
type DPI_AWARENESS_CONTEXT_T = void*;
type __arr_u64_2 = u64[2];
struct LARGE_INTEGER {
    i64 QuadPart;
}

struct POINT {
    LONG x;
    LONG y;
}

struct POINTL {
    LONG x;
    LONG y;
}

struct RECT {
    LONG left;
    LONG top;
    LONG right;
    LONG bottom;
}

struct SIZE {
    WORD cx;
    WORD cy;
}

struct MSG {
    HWND hwnd;
    UINT message;
    WPARAM wParam;
    LPARAM lParam;
    DWORD time;
    POINT pt;
}

struct WNDCLASSW {
    UINT style;
    WNDPROC lpfnWndProc;
    i32 cbClsExtra;
    i32 cbWndExtra;
    HINSTANCE hInstance;
    HICON hIcon;
    HCURSOR hCursor;
    HBRUSH hbrBackground;
    LPCWSTR lpszMenuName;
    LPCWSTR lpszClassName;
}

struct WNDCLASSEXW {
    UINT cbSize;
    UINT style;
    WNDPROC lpfnWndProc;
    i32 cbClsExtra;
    i32 cbWndExtra;
    HINSTANCE hInstance;
    HICON hIcon;
    HCURSOR hCursor;
    HBRUSH hbrBackground;
    LPCWSTR lpszMenuName;
    LPCWSTR lpszClassName;
    HICON hIconSm;
}

struct PIXELFORMATDESCRIPTOR {
    WORD nSize;
    WORD nVersion;
    DWORD dwFlags;
    BYTE iPixelType;
    BYTE cColorBits;
    BYTE cRedBits;
    BYTE cRedShift;
    BYTE cGreenBits;
    BYTE cGreenShift;
    BYTE cBlueBits;
    BYTE cBlueShift;
    BYTE cAlphaBits;
    BYTE cAlphaShift;
    BYTE cAccumBits;
    BYTE cAccumRedBits;
    BYTE cAccumGreenBits;
    BYTE cAccumBlueBits;
    BYTE cAccumAlphaBits;
    BYTE cDepthBits;
    BYTE cStencilBits;
    BYTE cAuxBuffers;
    BYTE iLayerType;
    BYTE bReserved;
    DWORD dwLayerMask;
    DWORD dwVisibleMask;
    DWORD dwDamageMask;
}

struct TRACKMOUSEEVENT {
    DWORD cbSize;
    DWORD dwFlags;
    HWND hwndTrack;
    DWORD dwHoverTime;
}

struct CURSORINFO {
    DWORD cbSize;
    DWORD flags;
    HCURSOR hCursor;
    POINT ptScreenPos;
}

struct MONITORINFO {
    DWORD cbSize;
    RECT rcMonitor;
    RECT rcWork;
    DWORD dwFlags;
}

struct SIZEL {
    LONG cx;
    LONG cy;
}

struct WINDOWPLACEMENT_STUB {
    DWORD style;
    DWORD dwExtendedStyle;
    DWORD cdxStyle;
    LONG x;
    LONG y;
    LONG cx;
    LONG cy;
}

struct DEVMODEW {
    LONG dmType;
    DWORD dmFields;
    DWORD dmPelsWidth;
    DWORD dmPelsHeight;
    DWORD dmBitsPerPel;
    DWORD dmDisplayFrequency;
}

struct OSVERSIONINFOW {
    DWORD dwOSVersionInfoSize;
    DWORD dwMajorVersion;
    DWORD dwMinorVersion;
    DWORD dwBuildNumber;
    DWORD dwPlatformId;
}

struct RAWINPUTHEADER {
    DWORD dwType;
    DWORD dwSize;
    HANDLE hDevice;
    WPARAM wParam;
}

struct RAWINPUTDEVICE {
    USHORT usUsagePage;
    USHORT usUsage;
    DWORD dwFlags;
    HWND hwndTarget;
}

struct RAWMOUSE {
    USHORT usFlags;
    ULONG _pad_buttons;
    ULONG ulRawButtons;
    LONG lLastX;
    LONG lLastY;
    ULONG ulExtraInformation;
}

struct RAWINPUT {
    RAWINPUTHEADER header;
    struct {
        RAWMOUSE mouse;
    } data;
}

struct SYSTEM_INFO {
    DWORD dwOemId;
    DWORD dwPageSize;
    LPVOID lpMinimumApplicationAddress;
    LPVOID lpMaximumApplicationAddress;
    DWORD_PTR dwActiveProcessorMask;
    DWORD dwNumberOfProcessors;
    DWORD dwProcessorType;
    DWORD dwAllocationGranularity;
    WORD wProcessorLevel;
    WORD wProcessorRevision;
}

struct CRITICAL_SECTION {
    PVOID DebugInfo;
    LONG LockCount;
    LONG RecursionCount;
    HANDLE OwningThread;
    HANDLE LockSemaphore;
    ULONG_PTR SpinCount;
}

struct BITMAPV5HEADER {
    DWORD bV5Size;
    LONG bV5Width;
    LONG bV5Height;
    WORD bV5Planes;
    WORD bV5BitCount;
    DWORD bV5Compression;
    DWORD bV5SizeImage;
    LONG bV5XPelsPerMeter;
    LONG bV5YPelsPerMeter;
    DWORD bV5ClrUsed;
    DWORD bV5ClrImportant;
    DWORD bV5RedMask;
    DWORD bV5GreenMask;
    DWORD bV5BlueMask;
    DWORD bV5AlphaMask;
}

struct BITMAPINFO {
    DWORD _unused;
}

struct ICONINFO {
    BOOL fIcon;
    DWORD xHotspot;
    DWORD yHotspot;
    HBITMAP hbmMask;
    HBITMAP hbmColor;
}

/*-- IMPLEMENTATION ----------------------------------------------------------*/
struct _stm_state_t {
    u32 initialized;
    LARGE_INTEGER freq;
    LARGE_INTEGER start;
}

/*
    sokol_time.h    -- simple cross-platform time measurement

    Project URL: https://github.com/floooh/sokol

    Do this:
        #define SOKOL_IMPL or
        #define SOKOL_TIME_IMPL
    before you include this file in *one* C or C++ file to create the
    implementation.

    Optionally provide the following defines with your own implementations:
    SOKOL_ASSERT(c)     - your own assert macro (default: assert(c))
    SOKOL_TIME_API_DECL - public function declaration prefix (default: extern)
    SOKOL_API_DECL      - same as SOKOL_TIME_API_DECL
    SOKOL_API_IMPL      - public function implementation prefix (default: -)

    If sokol_time.h is compiled as a DLL, define the following before
    including the declaration or implementation:

    SOKOL_DLL

    On Windows, SOKOL_DLL will define SOKOL_TIME_API_DECL as __declspec(dllexport)
    or __declspec(dllimport) as needed.

    void stm_setup();
        Call once before any other functions to initialize sokol_time
        (this calls for instance QueryPerformanceFrequency on Windows)

    uint64_t stm_now();
        Get current point in time in unspecified 'ticks'. The value that
        is returned has no relation to the 'wall-clock' time and is
        not in a specific time unit, it is only useful to compute
        time differences.

    uint64_t stm_diff(uint64_t new, uint64_t old);
        Computes the time difference between new and old. This will always
        return a positive, non-zero value.

    uint64_t stm_since(uint64_t start);
        Takes the current time, and returns the elapsed time since start
        (this is a shortcut for "stm_diff(stm_now(), start)")

    uint64_t stm_laptime(uint64_t* last_time);
        This is useful for measuring frame time and other recurring
        events. It takes the current time, returns the time difference
        to the value in last_time, and stores the current time in
        last_time for the next call. If the value in last_time is 0,
        the return value will be zero (this usually happens on the
        very first call).

    uint64_t stm_round_to_common_refresh_rate(uint64_t duration)
        This oddly named function takes a measured frame time and
        returns the closest "nearby" common display refresh rate frame duration
        in ticks. If the input duration isn't close to any common display
        refresh rate, the input duration will be returned unchanged as a fallback.
        The main purpose of this function is to remove jitter/inaccuracies from
        measured frame times, and instead use the display refresh rate as
        frame duration.
        NOTE: for more robust frame timing, consider using the
        sokol_app.h function sapp_frame_duration()

    Use the following functions to convert a duration in ticks into
    useful time units:

    double stm_sec(uint64_t ticks);
    double stm_ms(uint64_t ticks);
    double stm_us(uint64_t ticks);
    double stm_ns(uint64_t ticks);
        Converts a tick value into seconds, milliseconds, microseconds
        or nanoseconds. Note that not all platforms will have nanosecond
        or even microsecond precision.

    Uses the following time measurement functions under the hood:

    Windows:        QueryPerformanceFrequency() / QueryPerformanceCounter()
    MacOS/iOS:      mach_absolute_time()
    emscripten:     emscripten_get_now()
    Linux+others:   clock_gettime(CLOCK_MONOTONIC)

    zlib/libpng license

    Copyright (c) 2018 Andre Weissflog

    This software is provided 'as-is', without any express or implied warranty.
    In no event will the authors be held liable for any damages arising from the
    use of this software.

    Permission is granted to anyone to use this software for any purpose,
    including commercial applications, and to alter it and redistribute it
    freely, subject to the following restrictions:

        1. The origin of this software must not be misrepresented; you must not
        claim that you wrote the original software. If you use this software in a
        product, an acknowledgment in the product documentation would be
        appreciated but is not required.

        2. Altered source versions must be plainly marked as such, and must not
        be misrepresented as being the original software.

        3. This notice may not be removed or altered from any source
        distribution.
*/
private {
_stm_state_t _stm;

/* prevent 64-bit overflow when computing relative timestamp
    see https://gist.github.com/jspohr/3dc4f00033d79ec5bdaf67bc46c813e3
*/
i64 _stm_int64_muldiv(i64 value, i64 numer, i64 denom) {
    i64 q = value / denom;
    i64 r = value % denom;
    return q * numer + r * numer / denom;
}
}

void stm_setup() {
    memset(&_stm, 0, cast(u64, sizeof(_stm)));
    _stm.initialized = 0xABCDABCD;
    QueryPerformanceFrequency(&_stm.freq);
    QueryPerformanceCounter(&_stm.start);
}

u64 stm_now() {
    u64 now;
    noinit LARGE_INTEGER qpc_t;
    QueryPerformanceCounter(&qpc_t);
    now = cast(u64, _stm_int64_muldiv(cast(i64, qpc_t.QuadPart - _stm.start.QuadPart), 1000000000, cast(i64, _stm.freq.QuadPart)));
    return now;
}

u64 stm_diff(u64 new_ticks, u64 old_ticks) {
    if new_ticks > old_ticks {
        return new_ticks - old_ticks;
    } else {
        return 1;
    }
}

u64 stm_since(u64 start_ticks) {
    return stm_diff(stm_now(), start_ticks);
}

u64 stm_laptime(u64* last_time) {
    u64 dt = 0;
    u64 now = stm_now();
    if 0 != *last_time {
        dt = stm_diff(now, *last_time);
    }
    *last_time = now;
    return dt;
}
// first number is frame duration in ns, second number is tolerance in ns,
// the resulting min/max values must not overlap!
private {
__arr_u64_2[10] _stm_refresh_rates = {
    {16666667, 1000000},
    {13888889, 250000},
    {13333333, 250000},
    {11764706, 250000},
    {11111111, 250000},
    {10000000, 500000},
    {8333333, 500000},
    {6944445, 500000},
    {4166667, 1000000},
    {0, 0},
};
}

u64 stm_round_to_common_refresh_rate(u64 ticks) {
    u64 ns;
    i32 i = 0;
    while true {
        ns = _stm_refresh_rates[i][0];
        if 0 != ns == 0 {
            break;
        }
        u64 tol = _stm_refresh_rates[i][1];
        if ticks > ns - tol && ticks < ns + tol {
            return ns;
        }
        i++;
    }
    return ticks;
}

f64 stm_sec(u64 ticks) {
    return cast(f64, ticks) / 1000000000.0;
}

f64 stm_ms(u64 ticks) {
    return cast(f64, ticks) / 1000000.0;
}

f64 stm_us(u64 ticks) {
    return cast(f64, ticks) / 1000.0;
}

f64 stm_ns(u64 ticks) {
    return cast(f64, ticks);
}

}

