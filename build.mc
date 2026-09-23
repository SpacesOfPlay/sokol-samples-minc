// build.mc: build and run the sokol-samples-minc examples.
//
// Usage, from this folder:
//   minc run <sample>        build + run one sample (e.g. `minc run cube_sapp`)
//   minc run <file.mc>       same, by path
//   minc run all             build + run every sample, a few at a time
//   minc run all --jobs 2    ... how many share the screen (default 4)
//   minc run all --seconds 3 ... close each one automatically
//   minc run <sample> --gl   build against OpenGL instead of the
//                            platform default (Windows: D3D11,
//                            macOS: Metal)
//   minc run <s> --no-trace  drop sokol's trace hooks (on by default;
//                            they feed the sokol-gfx debug windows)
//   minc build <sample>      compile only
//   minc build all           compile every sample in samples/LIST.txt,
//                            several compilers at once
//   minc build all --jobs 4  ... how many (default: the machine's cores,
//                            bounded)
//   minc wasm <sample>       build for the browser + serve it (WebGL2)
//   minc wasm <s> --wgpu     ... against WebGPU instead (needs a
//                            WebGPU-capable browser)
//   minc wasm <s> --no-run   build + serve without opening the browser
//   minc wasm                list the wasm-capable samples (LIST_WASM.txt)
//   minc wasm --wgpu         list the WebGPU-capable ones (LIST_WASM_WGPU.txt)
//   minc run                 list the samples
//   minc clean
//
// A sample is ONE compilation unit in samples/; `import sokol_all;`
// resolves against the minc install when building from this directory.
// Samples fetch their assets from data/ relative to this folder, so
// run them from here.
//
// The compiler is taken from MINC, then PATH, then this folder
// (install: https://minc.dev).

@minc_min_version "0.9.15"

// Older minc ignores the tag above; this forces an error instead.
when !defined(MINC_VERSION) || MINC_VERSION < 9015 {
    minc_0_9_15_or_newer_required please_update_minc;
}

import process;
import file;
import str;
import thread;

when os(windows) { str EXE_SUFFIX = ".exe"; }
when os(linux) || os(macos) { str EXE_SUFFIX = ""; }

string join_named(str dir, str name, str ext) {
    string base = str_concat(name, ext);
    defer free(base);
    return path_join(dir, base);
}

// The dev server serves the .wasm's own directory, so mirror data/
// into build/web/ for the same relative paths to resolve there.
void stage_web_data() {
    if !path_is_dir("data") { return; }
    ignore dir_create("build/web/data");
    DirList files = dir_list("data", "", false);
    defer dir_list_free(&files);
    for i32 i = 0; i < files.count; i++ {
        string src = path_join("data", files.items[i]);
        defer free(src);
        string dst = path_join("build/web/data", files.items[i]);
        defer free(dst);
        ignore file_copy(src, dst);
    }
    return;
}

void die(str s) {
    eprint("{}\n", s);
    exit(1);
    return;
}

// MINC (install dir or binary), then PATH, then this folder.
string find_minc() {
    string env = env_get("MINC");
    if env.len > 0 {
        if path_is_dir(env) {
            string cand = join_named(env, "minc", EXE_SUFFIX);
            free(env);
            return cand;
        }
        return env;
    }
    free(env);

    string onpath = path_which("minc");
    if onpath.len > 0 { return onpath; }
    free(onpath);

    string local = str_concat("./minc", EXE_SUFFIX);
    if path_exists(local) { return local; }
    free(local);

    string none = { .data = null, .len = 0 };
    return none;
}

// "cube_sapp" -> "samples/cube_sapp.mc"; a path ending in .mc is
// taken as given.
string resolve_source(str arg) {
    if str_ends_with(arg, ".mc") { return string(arg); }
    string base = str_concat(arg, ".mc");
    defer free(base);
    return path_join("samples", base);
}

// --gl: build against GL 3.3 core instead of the platform default.
// -D SOKOL_GLCORE selects the backend, and sokol_all maps that to
// `@gpu "opengl"` so the @shader functions emit GLSL to match. A
// no-op on Linux, where GL is already the default.
bool g_gl;

// Trace hooks are ON by default.
bool g_no_trace;

// build/<name><EXE_SUFFIX>, or build/<name>_gl<EXE_SUFFIX> under --gl so
// the two backends' binaries do not overwrite each other.
string exe_named(str name) {
    if !g_gl { return join_named("build", name, EXE_SUFFIX); }
    string gl = str_concat(name, "_gl");
    defer free(gl);
    return join_named("build", gl, EXE_SUFFIX);
}

// Compile samples/<stem>.mc -> build/<stem><EXE_SUFFIX>. Returns the
// compiler's exit code.
i32 build_one(str cc, str stem) {
    string src = resolve_source(stem);
    defer free(src);
    str srcp = src;
    if !path_exists(srcp) {
        eprint("no such sample: {}\n", srcp);
        return 1;
    }
    str name = path_stem(srcp);
    string exe = exe_named(name);
    defer free(exe);
    print("building {}\n", name);
    ProcCmd c = { .args = { cc, srcp, "-o", exe } };
    if g_gl { proc_arg(&c, "-DSOKOL_GLCORE"); }
    if !g_no_trace { proc_arg(&c, "-DSOKOL_TRACE_HOOKS"); }
    ProcResult r = proc_run(&c);
    i32 rc = r.exit_code;
    proc_result_free(&r);
    return rc;
}

// build_one without the printing: the callers print their own [i/N]
// line per sample. Diagnostics are handed back so a parallel caller
// can print them under its own lock. *log is empty on success;
// caller frees.
i32 build_one_capture(str cc, str stem, string* log) {
    log.data = null;
    log.len = 0;
    string src = resolve_source(stem);
    defer free(src);
    str srcp = src;
    if !path_exists(srcp) { return 1; }
    str name = path_stem(srcp);
    string exe = exe_named(name);
    defer free(exe);
    ProcCmd c = { .args = { cc, srcp, "-o", exe } };
    if g_gl { proc_arg(&c, "-DSOKOL_GLCORE"); }
    if !g_no_trace { proc_arg(&c, "-DSOKOL_TRACE_HOOKS"); }
    c.capture = true;
    ProcResult r = proc_run(&c);
    i32 rc = r.exit_code;
    if rc != 0 && r.out.len > 0 { *log = string(r.out); }
    proc_result_free(&r);
    return rc;
}

// build_one_capture, printing the diagnostics itself.
i32 build_one_quiet(str cc, str stem) {
    string log = { .data = null, .len = 0 };
    i32 rc = build_one_capture(cc, stem, &log);
    if log.len > 0 { print("{}", log); }
    free(log);
    return rc;
}

// The sample list, one stem per line.
string read_list() {
    return file_read_str("samples/LIST.txt");
}

const i32 MAX_SAMPLES = 256;

// Split the list into stems, one per non-empty line. The stems point
// into `lst`, so it has to outlive them. Returns the count, or -1 if
// the list is longer than `max`.
i32 parse_stem_list(str lst, str* stems, i32 max) {
    i32 n = 0;
    str rest = lst;
    while rest.len > 0 {
        str line = rest;
        i32 nl = str_find_byte(rest, 10);
        if nl >= 0 {
            line = str_from(rest.data, nl);
            rest = str_from(rest.data + nl + 1, rest.len - nl - 1);
        } else {
            rest = str_from(rest.data, 0);
        }
        line = str_trim(line);
        if line.len == 0 { continue; }
        if n >= max { return -1; }
        *(stems + n) = line;
        n++;
    }
    return n;
}

void list_samples() {
    string lst = read_list();
    defer free(lst);
    if lst.len == 0 {
        print("samples/LIST.txt missing; dist is incomplete\n");
        return;
    }
    print("samples (run one with `minc run <name>`):\n{}", lst);
    return;
}

void list_wasm_samples() {
    string lst = file_read_str("samples/LIST_WASM.txt");
    if lst.data == null {
        print("samples/LIST_WASM.txt missing; dist is incomplete\n");
        return;
    }
    defer free(lst);
    print("wasm-capable samples (run one with `minc wasm <name>`):\n{}", lst);
    return;
}

void list_wgpu_samples() {
    string lst = file_read_str("samples/LIST_WASM_WGPU.txt");
    if lst.data == null {
        print("samples/LIST_WASM_WGPU.txt missing; dist is incomplete\n");
        return;
    }
    defer free(lst);
    print("WebGPU-capable samples (run one with `minc wasm <name> --wgpu`):\n{}", lst);
    return;
}

// Non-negative integer, or -1 if the argument is not one.
i32 str_to_i32(str s) {
    if s.len == 0 { return -1; }
    i32 v = 0;
    for i32 i = 0; i < s.len; i++ {
        u8 c = *(s.data + i);
        if c < '0' || c > '9' { return -1; }
        v = v * 10 + cast(i32, c - '0');
    }
    return v;
}

// --- `run all`: every sample, a few windows at a time -----------------
//
// proc_run blocks until the child exits, so the pool is threads: each
// worker takes the next stem and blocks until you close that window.
// Four on screen at once by default.
//

struct RunAll {
    str[MAX_SAMPLES] stems;
    i32 count;
    i32 next;        // atomic cursor into stems
    i32 failed;      // atomic
    i32 seconds;     // 0: wait for the window to be closed
    str cc;
    Mutex say_lock;  // one line of output at a time
}

private { RunAll _run_all; }

void run_all_worker(void* arg) {
    ignore arg;
    while true {
        i32 i = atomic_add(&_run_all.next, 1);
        if i >= _run_all.count { break; }
        str stem = _run_all.stems[i];

        // compile
        if build_one_quiet(_run_all.cc, stem) != 0 {
            ignore atomic_add(&_run_all.failed, 1);
            mutex_lock(&_run_all.say_lock);
            print("  [{}/{}] FAILED TO BUILD: {}\n", i + 1, _run_all.count, stem);
            mutex_unlock(&_run_all.say_lock);
            continue;
        }

        string exe = exe_named(stem);
        defer free(exe);

        mutex_lock(&_run_all.say_lock);
        print("  [{}/{}] {}\n", i + 1, _run_all.count, stem);
        mutex_unlock(&_run_all.say_lock);

        ProcCmd c = { .args = { exe } };
        if _run_all.seconds > 0 { c.timeout_ms = _run_all.seconds * 1000; }
        ProcResult r = proc_run(&c);
        // timeout is from --seconds
        if !r.spawned || (r.exit_code != 0 && !r.timed_out) {
            ignore atomic_add(&_run_all.failed, 1);
            mutex_lock(&_run_all.say_lock);
            print("      FAILED: {}\n", stem);
            mutex_unlock(&_run_all.say_lock);
        }
        proc_result_free(&r);
    }
    return;
}

// --- `build all`: every sample, several compilers at once -------------
//
// The jobs share nothing: each writes its own build/<stem>, and the
// compiler only reads samples/ and lib/. Same thread pool as
// `run all`, one worker per job.
//
// The default is one job per core, bounded: a single minc can hold
// most of a gigabyte on the largest sample. `--jobs N` overrides.
//

const i32 BUILD_ALL_MAX_JOBS = 12;

struct BuildAll {
    str[MAX_SAMPLES] stems;
    i32 count;
    i32 next;        // atomic cursor into stems
    i32 done;        // atomic; numbers the lines in completion order
    i32 failed;      // atomic
    str cc;
    Mutex say_lock;  // one line of output at a time
}

private { BuildAll _build_all; }

void build_all_worker(void* arg) {
    ignore arg;
    while true {
        i32 i = atomic_add(&_build_all.next, 1);
        if i >= _build_all.count { break; }
        str stem = _build_all.stems[i];

        string log = { .data = null, .len = 0 };
        i32 rc = build_one_capture(_build_all.cc, stem, &log);
        // Numbered as they finish, not as they were queued: the order
        // is whatever the pool produces.
        i32 n = atomic_add(&_build_all.done, 1) + 1;

        mutex_lock(&_build_all.say_lock);
        if rc == 0 {
            print("  [{}/{}] {}\n", n, _build_all.count, stem);
        } else {
            ignore atomic_add(&_build_all.failed, 1);
            print("  [{}/{}] FAILED: {}\n", n, _build_all.count, stem);
            if log.len > 0 { print("{}", log); }
        }
        mutex_unlock(&_build_all.say_lock);
        free(log);
    }
    return;
}

i32 main() {
    i32 argc = get_argc();
    str verb = "run";
    str target = "";
    bool no_run = false;
    bool use_wgpu = false;
    i32 jobs = 0;   // 0: unset - `run all` and `build all` differ
    i32 seconds = 0;

    for i32 i = 1; i < argc; i++ {
        str a = str_from_cstr(get_arg(i));
        if str_equal(a, "--no-run") { no_run = true; }
        else if str_equal(a, "--wgpu") { use_wgpu = true; }
        else if str_equal(a, "--gl") { g_gl = true; }
        else if str_equal(a, "--no-trace") { g_no_trace = true; }
        else if str_equal(a, "--jobs") && i + 1 < argc {
            i++;
            i32 v = str_to_i32(str_from_cstr(get_arg(i)));
            if v < 1 { die("--jobs wants a positive number"); }
            jobs = v;
        }
        else if str_equal(a, "--seconds") && i + 1 < argc {
            i++;
            i32 v = str_to_i32(str_from_cstr(get_arg(i)));
            if v < 0 { die("--seconds wants a number"); }
            seconds = v;
        }
        else if i == 1 {
            // A .mc path in the verb slot means "run this".
            if str_ends_with(a, ".mc") { target = a; }
            else { verb = a; }
        } else if target.len == 0 { target = a; }
    }

    if str_equal(verb, "clean") {
        ignore dir_remove("build");
        print("clean.\n");
        return 0;
    }

    string minc = find_minc();
    defer free(minc);
    if minc.len == 0 {
        print("\nminc compiler not found.\n"
              "Install it:  powershell -c \"irm minc.dev/install.ps1 | iex\"\n"
              "or set MINC (see install_minc.md).\n");
        die("See README.md (Quickstart) and LICENSE.md.");
    }

    if !path_exists("samples/LIST.txt") {
        die("missing samples/LIST.txt; dist is incomplete");
    }

    if target.len == 0 {
        if str_equal(verb, "wasm") {
            if use_wgpu { list_wgpu_samples(); }
            else { list_wasm_samples(); }
        }
        else { list_samples(); }
        return 0;
    }

    ignore dir_create("build");

    if str_equal(verb, "wasm") {
        ignore dir_create("build/web");
        stage_web_data();
        string src = resolve_source(target);
        defer free(src);
        str srcp = src;
        if !path_exists(srcp) {
            eprint("no such sample: {}\n", srcp);
            exit(1);
        }
        str name = path_stem(target);
        // --wgpu: -D SOKOL_WGPU selects the WebGPU backend, and
        // sokol_all maps it to `@gpu "webgpu"` so the shaders come
        // out as WGSL. The artifact gets a _wgpu suffix.
        string out_stem = string(name);
        if use_wgpu { free(out_stem); out_stem = str_concat(name, "_wgpu"); }
        defer free(out_stem);
        string wasm_out = join_named("build/web", out_stem, ".wasm");
        defer free(wasm_out);
        print("building + serving {}", name);
        if use_wgpu { print(" for the web (WebGPU)...\n"); }
        else { print(" for the web (wasm)...\n"); }
        ProcCmd c = { .args = {
            minc, "run", "--target", "wasm", srcp,
            "-o", wasm_out
        } };
        if use_wgpu { proc_arg(&c, "-DSOKOL_WGPU"); }
        if no_run { proc_arg(&c, "--no-browser"); }
        ProcResult r = proc_run(&c);
        i32 wrc = r.exit_code;
        proc_result_free(&r);
        return wrc;
    }

    if str_equal(verb, "run") && str_equal(target, "all") {
        string lst = read_list();
        // held for the whole run: the stems point into it
        defer free(lst);
        i32 rn = parse_stem_list(lst, &_run_all.stems[0], MAX_SAMPLES);
        if rn < 0 { die("samples/LIST.txt is longer than this driver can hold"); }
        _run_all.count = rn;
        if _run_all.count == 0 { die("nothing to run"); }

        _run_all.seconds = seconds;
        _run_all.cc = minc;
        mutex_init(&_run_all.say_lock);
        if jobs == 0 { jobs = 4; }   // how many windows share the screen
        if jobs > _run_all.count { jobs = _run_all.count; }
        if seconds > 0 {
            print("running {} sample(s), {} at a time, {}s each\n",
                  _run_all.count, jobs, seconds);
        } else {
            print("running {} sample(s), {} at a time; close a window for the next\n",
                  _run_all.count, jobs);
        }

        Thread[16] pool;
        if jobs > 16 { jobs = 16; }
        for i32 t = 0; t < jobs; t++ { thread_create(&pool[t], run_all_worker, null); }
        for i32 t = 0; t < jobs; t++ { thread_join(&pool[t]); }
        mutex_destroy(&_run_all.say_lock);

        i32 bad = _run_all.failed;
        if bad > 0 {
            print("{} of {} sample(s) failed\n", bad, _run_all.count);
            return 1;
        }
        print("all {} sample(s) ran.\n", _run_all.count);
        return 0;
    }

    if str_equal(verb, "build") && str_equal(target, "all") {
        string lst = read_list();
        // held for the whole build: the stems point into it
        defer free(lst);
        i32 bn = parse_stem_list(lst, &_build_all.stems[0], MAX_SAMPLES);
        if bn < 0 { die("samples/LIST.txt is longer than this driver can hold"); }
        _build_all.count = bn;
        if _build_all.count == 0 { die("nothing to build"); }

        if jobs == 0 { jobs = cpu_count(); }
        if jobs > BUILD_ALL_MAX_JOBS { jobs = BUILD_ALL_MAX_JOBS; }
        if jobs > _build_all.count { jobs = _build_all.count; }
        if jobs < 1 { jobs = 1; }

        _build_all.cc = minc;
        mutex_init(&_build_all.say_lock);
        print("building {} sample(s), {} at a time\n", _build_all.count, jobs);

        Thread[BUILD_ALL_MAX_JOBS] pool;
        for i32 t = 0; t < jobs; t++ { thread_create(&pool[t], build_all_worker, null); }
        for i32 t = 0; t < jobs; t++ { thread_join(&pool[t]); }
        mutex_destroy(&_build_all.say_lock);

        if _build_all.failed > 0 {
            print("FAILED: {} of {} sample(s) did not build\n",
                  _build_all.failed, _build_all.count);
            return 1;
        }
        print("all samples built.\n");
        return 0;
    }

    i32 rc = build_one(minc, target);
    if rc != 0 { die("minc compile failed"); }

    if str_equal(verb, "run") {
        str name = path_stem(target);
        string exe = exe_named(name);
        defer free(exe);
        ProcCmd runc = { .args = { exe } };
        ProcResult rr = proc_run(&runc);
        rc = rr.exit_code;
        proc_result_free(&rr);
    }
    return rc;
}
