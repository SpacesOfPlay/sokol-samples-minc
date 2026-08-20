// box3d_ext.mc — runtime support for box3d-minc: libc-shaped helpers,
// a portable FILE* layer, the atomic/bit intrinsics, and the platform
// layer (timing, threads, mutexes) over minc's builtins. Imported by
// box3d.mc; user code imports box3d.
import box3d;
import math;
import ext_libc;

// extra libc-shaped helpers box3d needs: aligned allocation, the MSVC
// bit-scan intrinsic, and isnan/isinf.
//

// --- target-neutral -------------------------------------------------

// Aligned allocation over the runtime allocator: over-allocate and
// stash the raw pointer just below the aligned block. Alignment is a
// power of two.
void* _aligned_malloc(u64 size, u64 alignment) {
    u64 total = size + alignment + 8;
    u8* raw = cast(u8*, alloc(cast(i64, total)));
    if raw == null { return null; }
    u64 addr = cast(u64, raw) + 8;
    u64 aligned = ((addr + alignment - 1) / alignment) * alignment;
    *cast(u64*, aligned - 8) = cast(u64, raw);
    return cast(void*, aligned);
}
void _aligned_free(void* p) {
    if p == null { return; }
    free(cast(void*, *cast(u64*, cast(u64, p) - 8)));
}

// C11 aligned_alloc, paired with _aligned_free.
void* aligned_alloc(u64 alignment, u64 size) {
    return _aligned_malloc(size, alignment);
}

// MSVC bit-scan intrinsic over the clz builtin.
u8 _BitScanReverse(u32* index, u32 mask) {
    if mask == 0 { return 0; }
    *index = cast(u32, 31 - clz(cast(i32, mask)));
    return 1;
}

bool isnan(f32 x) { return x != x; }
bool isinf(f32 x) { return x == x && (x - x) != 0.0f; }

// runtime support for box3d: a portable FILE* layer, MSVC atomic 
// intrinsics, and math/string helpers.

import atomic;

// --- FILE* layer over the open/read/write/close builtins ------------
//
// Read mode reads the whole file into a buffer up front, so fseek and
// ftell resolve in memory. Write mode streams through write(); a file
// being written is never seeked.
struct B3File {
    i64 fd;        // write mode: the open fd; read mode: -1
    u8* buf;       // read mode: whole-file contents
    i64 size;      // read: buffer length; write: bytes written
    i64 pos;       // current offset
    i32 writing;
}

void* __b3_fopen(u8* name, u8* mode) {
    // mode[0]: 'r' (114) reads; 'w'/'a'/anything else writes+truncates.
    bool writing = *mode != 114;
    i64 fd = open(name, writing ? 1 : 0);
    if fd < 0 { return null; }
    B3File* fp = cast(B3File*, alloc(cast(i64, sizeof(B3File))));
    fp.pos = 0;
    if writing {
        fp.fd = fd;
        fp.buf = null;
        fp.size = 0;
        fp.writing = 1;
        return cast(void*, fp);
    }
    // read: pull the whole file into a growing buffer, then drop the fd
    fp.fd = 0 - 1;
    fp.writing = 0;
    i64 cap = 4096;
    u8* buf = cast(u8*, alloc(cap));
    i64 len = 0;
    while true {
        if len + 1024 > cap {
            i64 ncap = cap * 2;
            u8* nb = cast(u8*, alloc(ncap));
            memcpy(nb, buf, len);
            free(buf);
            buf = nb;
            cap = ncap;
        }
        i64 got = read(fd, buf + len, 1024);
        if got <= 0 { break; }
        len += got;
    }
    close(fd);
    fp.buf = buf;
    fp.size = len;
    return cast(void*, fp);
}

i32 __b3_fclose(void* f) {
    B3File* fp = cast(B3File*, f);
    if fp == null { return 0; }
    if fp.writing != 0 { close(fp.fd); }
    if fp.buf != null { free(fp.buf); }
    free(cast(void*, fp));
    return 0;
}

u64 __b3_fwrite(void* p, u64 size, u64 n, void* f) {
    B3File* fp = cast(B3File*, f);
    if fp == null || fp.writing == 0 || size == 0 { return 0; }
    i64 wrote = write(fp.fd, p, cast(i32, size * n));
    if wrote < 0 { return 0; }
    fp.pos += wrote;
    fp.size += wrote;
    return cast(u64, wrote) / size;
}

u64 __b3_fread(void* p, u64 size, u64 n, void* f) {
    B3File* fp = cast(B3File*, f);
    if fp == null || fp.writing != 0 || size == 0 { return 0; }
    i64 want = cast(i64, size * n);
    i64 avail = fp.size - fp.pos;
    if want > avail { want = avail; }
    if want <= 0 { return 0; }
    memcpy(cast(u8*, p), fp.buf + fp.pos, want);
    fp.pos += want;
    return cast(u64, want) / size;
}

// SEEK_SET=0, SEEK_CUR=1, SEEK_END=2. Read-mode only (buffer-backed);
// a write-mode seek returns error, which box3d never triggers.
i32 __b3_fseek(void* f, i64 offset, i32 origin) {
    B3File* fp = cast(B3File*, f);
    if fp == null || fp.writing != 0 { return 0 - 1; }
    i64 base = 0;
    if origin == 1 { base = fp.pos; }
    else if origin == 2 { base = fp.size; }
    i64 np = base + offset;
    if np < 0 || np > fp.size { return 0 - 1; }
    fp.pos = np;
    return 0;
}

i32 __b3_ftell(void* f) {
    B3File* fp = cast(B3File*, f);
    if fp == null { return 0 - 1; }
    return cast(i32, fp.pos);
}

// (`rewind` is -D mapped to __b3_rewind in every config, but no box3d
// code path calls it; the shim is omitted until one does.)

// char IO used by __b3_fprintf / __b3_vfscanf below.
i32 __b3_fgetc(void* f) {
    B3File* fp = cast(B3File*, f);
    if fp == null || fp.pos >= fp.size { return 0 - 1; }
    u8 c = *(fp.buf + fp.pos);
    fp.pos++;
    return cast(i32, c);
}

i32 __b3_ungetc(i32 c, void* f) {
    B3File* fp = cast(B3File*, f);
    if fp == null || fp.pos <= 0 { return 0 - 1; }
    fp.pos--;
    return c;
}

void __b3_fputc(i32 c, void* f) {
    B3File* fp = cast(B3File*, f);
    if fp == null || fp.writing == 0 { return; }
    u8 b = cast(u8, c);
    i64 wrote = write(fp.fd, &b, 1);
    if wrote > 0 { fp.pos += wrote; fp.size += wrote; }
}

// Secure-CRT fopen_s: 0 on success, nonzero on failure.
i32 fopen_s(void** f, u8* name, u8* mode) {
    *f = __b3_fopen(name, mode);
    if *f == null { return 1; }
    return 0;
}

// --- math helpers ---------------------------------------------------
// One entry point the math module does not carry, over roundf.
f32 remainderf(f32 x, f32 y) { return x - y * roundf(x / y); }

// strncpy_s over a -D rename (`strncpy_s=__b3_strncpy_s`), so one
// unconditional definition serves every target: native minc already
// carries a strncpy_s, and defining ours conditionally just to dodge
// that collision cost the dist a platform arm.
i32 __b3_strncpy_s(u8* dst, u64 dstSize, u8* src, u64 count) {
    if dst == null || dstSize == 0 { return 22; }
    u64 i = 0;
    while i < count && i + 1 < dstSize && *(src + i) != 0 {
        *(dst + i) = *(src + i);
        i++;
    }
    *(dst + i) = 0;
    return 0;
}

// Buffered-formatting fprintf over the builtin-backed __b3_fputc.
i32 __b3_fprintf(void* f, u8* fmt, ...) {
    u8[1024] line;
    i32 n = __minc_vfmt(cast(u8*, &line), 1024, fmt, &...);
    for i32 i = 0; i < n; i++ {
        __b3_fputc(cast(i32, line[i]), f);
    }
    return n;
}

// fscanf_s subset — %d and %f over whitespace-delimited text, which is
// the whole surface box3d's height-field format uses.
private {

bool __b3_scan_ws(i32 c) {
    return c == 32 || c == 9 || c == 10 || c == 13 || c == 11 || c == 12;
}

// Reads past leading whitespace; returns first non-ws char or -1.
i32 __b3_scan_skip_ws(void* f) {
    i32 c = __b3_fgetc(f);
    while c >= 0 && __b3_scan_ws(c) { c = __b3_fgetc(f); }
    return c;
}

}

i32 fscanf_s(void* f, u8* fmt, ...) { return __b3_vfscanf(f, fmt, &...); }
// Non-MSVC arm of B3_FILE_SCAN (the _MSC_VER gate maps to os(windows)
// at transpile time, so macOS/linux amalgams call plain fscanf).
i32 fscanf(void* f, u8* fmt, ...)   { return __b3_vfscanf(f, fmt, &...); }

i32 __b3_vfscanf(void* f, u8* fmt, &... ap) {
    i32 count = 0;
    i32 fi = 0;
    while *(fmt + fi) != 0 {
        u8 fc = *(fmt + fi);
        if fc != 37 {           // whitespace / literal: %-handlers skip ws
            fi++;
            continue;
        }
        fi++;
        u8 conv = *(fmt + fi);
        fi++;
        if conv == 100 {        // %d
            i32 c = __b3_scan_skip_ws(f);
            i64 sign = 1;
            if c == 45 { sign = -1; c = __b3_fgetc(f); }
            else if c == 43 { c = __b3_fgetc(f); }
            bool any = false;
            i64 v = 0;
            while c >= 48 && c <= 57 {
                v = v * 10 + cast(i64, c - 48);
                any = true;
                c = __b3_fgetc(f);
            }
            if c >= 0 { ignore __b3_ungetc(c, f); }
            if !any { return count; }
            i32* out = cast(i32*, arg_read_ptr(ap));
            *out = cast(i32, v * sign);
            count++;
        } else if conv == 102 { // %f — token to buffer, atof to parse
            i32 c = __b3_scan_skip_ws(f);
            noinit u8[64] tok;
            i32 n = 0;
            while c >= 0 && !__b3_scan_ws(c) && n < 63 {
                tok[n] = cast(u8, c);
                n++;
                c = __b3_fgetc(f);
            }
            if c >= 0 { ignore __b3_ungetc(c, f); }
            if n == 0 { return count; }
            tok[n] = 0;
            f32* out = cast(f32*, arg_read_ptr(ap));
            *out = cast(f32, atof(&tok[0]));
            count++;
        } else {
            return count;       // unsupported conversion
        }
    }
    return count;
}

// printf that formats and writes straight to the stdout handle.
i32 __b3_printf(u8* fmt, ...) {
    u8[1024] line;
    i32 n = __minc_vfmt(cast(u8*, &line), 1024, fmt, &...);
    ignore write(stdout(), cast(u8*, &line), n);
    return n;
}

// MOV on x64, LDAR on arm64.
i32 __b3_atomic_load32(i32* p) { return atomic_load(p); }

i32 _InterlockedExchange(i32* p, i32 v) { return atomic_xchg(p, v); }
u32 _InterlockedExchange(u32* p, u32 v) { return atomic_xchg(p, v); }

i32 _InterlockedExchangeAdd(i32* p, i32 d) { return atomic_add(p, d); }

// box3d uses `_InterlockedOr(p, 0)` as its atomic-load idiom; the
// general case is a CAS loop.
i32 _InterlockedOr(i32* p, i32 v) {
    if v == 0 { return atomic_load(p); }
    while true {
        i32 old = atomic_load(p);
        if atomic_cas(p, old, old | v) { return old; }
    }
}
u32 _InterlockedOr(u32* p, u32 v) {
    if v == 0 { return atomic_load(p); }
    while true {
        u32 old = atomic_load(p);
        if atomic_cas(p, old, old | v) { return old; }
    }
}

// Returns the original value, like the intrinsic. Argument order is
// the MSVC: (target, desired, expected).
i32 _InterlockedCompareExchange(i32* p, i32 desired, i32 expected) {
    while true {
        i32 old = atomic_load(p);
        if old != expected { return old; }
        if atomic_cas(p, expected, desired) { return expected; }
    }
}

// Cache prefetch hints over the prefetch builtin.
void _mm_prefetch(u8* addr, i32 hint) {
    prefetch(addr);
}

i64 __popcnt64(u64 v) {
    i32 lo = popcount(cast(i32, v & 0xFFFFFFFF));
    i32 hi = popcount(cast(i32, v >> 32));
    return cast(i64, lo + hi);
}

// MSVC bit-scan intrinsics over the ctz/clz builtins. Return nonzero
// when a set bit was found (mask != 0), matching the intrinsics.
u8 _BitScanForward(u32* index, u32 mask) {
    if mask == 0 { return 0; }
    *index = cast(u32, ctz(cast(i32, mask)));
    return 1;
}

u8 _BitScanForward64(u32* index, u64 mask) {
    if mask == 0 { return 0; }
    u32 lo = cast(u32, mask & 0xFFFFFFFF);
    if lo != 0 {
        *index = cast(u32, ctz(cast(i32, lo)));
    } else {
        u32 hi = cast(u32, mask >> 32);
        *index = cast(u32, 32 + ctz(cast(i32, hi)));
    }
    return 1;
}

// SSE2 helpers used by box3d's SIMD paths. __m128i maps to int4;
// cast(float4, int4) / cast(int4, float4) are bitcasts.
//
float4 _mm_loadu_ps(f32* p) { return *cast(float4*, p); }
void _mm_storeu_ps(f32* p, float4 v) { *cast(float4*, p) = v; }
float4 _mm_castsi128_ps(int4 a) { return cast(float4, a); }
int4 _mm_castps_si128(float4 a) { return cast(int4, a); }
int4 _mm_set1_epi32(i32 a) { return int4{a, a, a, a}; }
int4 _mm_setr_epi32(i32 a, i32 b, i32 c, i32 d) { return int4{a, b, c, d}; }
int4 _mm_add_epi32(int4 a, int4 b) { return a + b; }
i32 _mm_cvtsi128_si32(int4 a) { return a.x; }

// box3d's platform layer (timing, sleep/yield, mutexes, semaphores, 
// threads) over minc's builtins. wasm is single-threaded.

import thread;

// The opaque handles box3d passes around.
struct b3Mutex {
    Mutex m;
}

struct b3Semaphore {
    Semaphore s;
}

struct b3Thread {
    Thread t;
    b3ThreadFunction function;
    void* context;
}

// --- timing ---------------------------------------------------------
// qpc/qpf give a monotonic clock (nanosecond ticks + frequency).
//
f64 b3_invFrequency;

private f64 b3_inv_freq() {
    // cache the timer frequency
    if b3_invFrequency == 0.0 {
        i64 freq = qpf();
        if freq == 0 { return 0.0; }
        b3_invFrequency = 1000.0 / cast(f64, freq);
    }
    return b3_invFrequency;
}

u64 b3GetTicks() {
    return cast(u64, qpc());
}

f32 b3GetMilliseconds(u64 ticks) {
    f64 inv = b3_inv_freq();
    u64 now = cast(u64, qpc());
    return cast(f32, inv * cast(f64, now - ticks));
}

f32 b3GetMillisecondsAndReset(u64* ticks) {
    f64 inv = b3_inv_freq();
    u64 now = cast(u64, qpc());
    f32 ms = cast(f32, inv * cast(f64, now - *ticks));
    *ticks = now;
    return ms;
}

// --- mutex ----------------------------------------------------------
// Supported on every target.

b3Mutex* b3CreateMutex() {
    b3Mutex* m = cast(b3Mutex*, b3Alloc(cast(u64, sizeof(b3Mutex))));
    mutex_init(&m.m);
    return m;
}

void b3DestroyMutex(b3Mutex* m) {
    mutex_destroy(&m.m);
    b3Free(m, cast(u64, sizeof(b3Mutex)));
}

void b3LockMutex(b3Mutex* m) {
    mutex_lock(&m.m);
}

void b3UnlockMutex(b3Mutex* m) {
    mutex_unlock(&m.m);
}

when os(wasm) {

when defined(MINC_THREADS) {

// --- wasm --threads: real thread/semaphore builtins -----------------
// thread_sleep has no wasm lowering (the browser main thread cannot
// block), so yield/sleep stay no-ops; the scheduler only uses them as
// spin hints.

void b3Yield() { }

void b3Sleep(i32 milliseconds) { }

b3Semaphore* b3CreateSemaphore(i32 initCount) {
    b3Semaphore* s = cast(b3Semaphore*, b3Alloc(cast(u64, sizeof(b3Semaphore))));
    sem_init(&s.s, initCount);
    return s;
}

void b3DestroySemaphore(b3Semaphore* s) {
    sem_destroy(&s.s);
    b3Free(s, cast(u64, sizeof(b3Semaphore)));
}

void b3WaitSemaphore(b3Semaphore* s) {
    // Adaptive spin before parking. Parking is expensive.
    for i32 i = 0; i < 20000; i++ {
        if atomic_load(&s.s.count) > 0 { break; }
    }
    sem_wait(&s.s);
}

void b3SignalSemaphore(b3Semaphore* s) {
    sem_signal(&s.s);
}

b3Thread* b3CreateThread(b3ThreadFunction function, void* context, u8* name) {
    b3Thread* t = cast(b3Thread*, b3Alloc(cast(u64, sizeof(b3Thread))));
    t.function = function;
    t.context = context;
    thread_create(&t.t, function, context);
    return t;
}

void b3JoinThread(b3Thread* t) {
    thread_join(&t.t);
    b3Free(t, cast(u64, sizeof(b3Thread)));
}

} else {

// --- wasm: single-threaded, thread/semaphore ops are no-ops ---------

void b3Yield() { }

void b3Sleep(i32 milliseconds) { }

b3Semaphore* b3CreateSemaphore(i32 initCount) {
    return cast(b3Semaphore*, b3Alloc(cast(u64, sizeof(b3Semaphore))));
}

void b3DestroySemaphore(b3Semaphore* s) {
    b3Free(s, cast(u64, sizeof(b3Semaphore)));
}

void b3WaitSemaphore(b3Semaphore* s) { }

void b3SignalSemaphore(b3Semaphore* s) { }

b3Thread* b3CreateThread(b3ThreadFunction function, void* context, u8* name) {
    return null;
}

void b3JoinThread(b3Thread* t) { }

}

} else {

// --- native: real threads -------------------------------------------

void b3Yield() {
    thread_sleep(0);
}

void b3Sleep(i32 milliseconds) {
    thread_sleep(milliseconds);
}

b3Semaphore* b3CreateSemaphore(i32 initCount) {
    b3Semaphore* s = cast(b3Semaphore*, b3Alloc(cast(u64, sizeof(b3Semaphore))));
    sem_init(&s.s, initCount);
    return s;
}

void b3DestroySemaphore(b3Semaphore* s) {
    sem_destroy(&s.s);
    b3Free(s, cast(u64, sizeof(b3Semaphore)));
}

void b3WaitSemaphore(b3Semaphore* s) {
    sem_wait(&s.s);
}

void b3SignalSemaphore(b3Semaphore* s) {
    sem_signal(&s.s);
}

// The optional thread name is unused.
b3Thread* b3CreateThread(b3ThreadFunction function, void* context, u8* name) {
    b3Thread* t = cast(b3Thread*, b3Alloc(cast(u64, sizeof(b3Thread))));
    t.function = function;
    t.context = context;
    thread_create(&t.t, function, context);
    return t;
}

void b3JoinThread(b3Thread* t) {
    thread_join(&t.t);
    b3Free(t, cast(u64, sizeof(b3Thread)));
}

}
