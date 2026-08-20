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
//   minc build all           compile every sample in samples/LIST.txt
//   minc wasm <sample>       build for the browser + serve it (WebGL2)
//   minc wasm <s> --wgpu     ... against WebGPU instead (needs a
//                            WebGPU-capable browser; the flag pairs
//                            @gpu "webgpu" with -D SOKOL_WGPU)
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
// The minc compiler is taken from MINC, then PATH, then this folder.
// Install minc from https://minc.dev.

@minc_min_version "0.9.11"

// minc 0.9.9 ignores the above tag, this will force an error.
// remove at some point in future.
when !defined(MINC_VERSION) || MINC_VERSION < 9011 {
    minc_0_9_10_or_newer_required please_update_minc;
}

import process;
import file;
import str;
import thread;

when os(windows) { str EXE_SUFFIX = ".exe"; }
when os(linux) || os(macos) { str EXE_SUFFIX = ""; }

void out(str s) {
    write(stdout(), s.data, s.len);
    return;
}

void say(str s) {
    out(s);
    write(stdout(), "\n", 1);
    return;
}

// "<dir>/<name><ext>", without leaking the joined name.
string join_named(str dir, str name, str ext) {
    string base = str_concat(name, ext);
    defer free(base);
    return path_join(dir, str_from(base.data, base.len));
}

// Native runs read data/ relative to the cwd; the browser fetches it
// over HTTP from the dev server, which serves the .wasm's own directory.
// Mirror data/ into build/web/ so the same relative paths resolve there.
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
        ignore file_copy(str_from(src.data, src.len), str_from(dst.data, dst.len));
    }
    return;
}

void die(str s) {
    write(stderr(), s.data, s.len);
    write(stderr(), "\n", 1);
    exit(1);
    return;
}

// MINC first (an install dir or the binary itself), then PATH, then a
// binary sitting next to this script.
string find_minc() {
    string env = env_get("MINC");
    if env.len > 0 {
        str e = str_from(env.data, env.len);
        if path_is_dir(e) {
            string cand = join_named(e, "minc", EXE_SUFFIX);
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
    if path_exists(str_from(local.data, local.len)) { return local; }
    free(local);

    string none = { .data = null, .len = 0 };
    return none;
}

// "cube_sapp" -> "samples/cube_sapp.mc"; a path ending in .mc is
// taken as given.
string resolve_source(str arg) {
    if str_ends_with(arg, ".mc") { return str_concat(arg, ""); }
    string base = str_concat(arg, ".mc");
    defer free(base);
    return path_join("samples", str_from(base.data, base.len));
}

// --gl: build the sample against GL 3.3 core instead of the platform
// default. Two things are needed: -D SOKOL_GLCORE selects backend, and
// `@gpu "opengl"` makes the @shader functions emit GLSL to match.
// The pragma has to be in the source, so the sample is copied with that
// line prepended.
//
// Useful on Windows (default D3D11) and macOS (default Metal, and Apple
// caps GL at 4.1 core); on Linux GL is already the default, so --gl is
// a no-op there.
bool g_gl;

// Trace hooks are ON by default.
bool g_no_trace;

// build/<name><EXE_SUFFIX>, or build/<name>_gl<EXE_SUFFIX> under --gl so
// the two backends' binaries do not overwrite each other.
string exe_named(str name) {
    if !g_gl { return join_named("build", name, EXE_SUFFIX); }
    string gl = str_concat(name, "_gl");
    defer free(gl);
    return join_named("build", str_from(gl.data, gl.len), EXE_SUFFIX);
}

// Write build/<name>_gl.mc = `@gpu "opengl"` + the sample, and return
// its path. Caller frees.
string gl_source(str srcp, str name) {
    string dst = join_named("build", name, "_gl.mc");
    FileData fd = file_read(srcp);
    if fd.data == null { return dst; }
    defer free(fd.data);
    string body = str_concat("@gpu \"opengl\"\n", str_from(fd.data, cast(i32, fd.len)));
    defer free(body);
    ignore file_write_str(str_from(dst.data, dst.len), str_from(body.data, body.len));
    return dst;
}

// Compile samples/<stem>.mc -> build/<stem><EXE_SUFFIX>. Returns the
// compiler's exit code.
i32 build_one(str cc, str stem) {
    string src = resolve_source(stem);
    defer free(src);
    str srcp = str_from(src.data, src.len);
    if !path_exists(srcp) {
        out("no such sample: ");
        say(srcp);
        return 1;
    }
    str name = path_stem(srcp);
    string glsrc = { .data = null, .len = 0 };
    if g_gl {
        glsrc = gl_source(srcp, name);
        srcp = str_from(glsrc.data, glsrc.len);
    }
    defer free(glsrc);
    string exe = exe_named(name);
    defer free(exe);
    out("building ");
    say(name);
    ProcCmd c = { .args = { cc, srcp, "-o", str_from(exe.data, exe.len) } };
    if g_gl { proc_arg(&c, "-DSOKOL_GLCORE"); }
    if !g_no_trace { proc_arg(&c, "-DSOKOL_TRACE_HOOKS"); }
    ProcResult r = proc_run(&c);
    i32 rc = r.exit_code;
    proc_result_free(&r);
    return rc;
}

// build_one, without the running commentary; `run all` wants its own
// [i/N] line per sample, not the compiler's. Output is captured and
// printed only if the build fails.
i32 build_one_quiet(str cc, str stem) {
    string src = resolve_source(stem);
    defer free(src);
    str srcp = str_from(src.data, src.len);
    if !path_exists(srcp) { return 1; }
    str name = path_stem(srcp);
    string glsrc = { .data = null, .len = 0 };
    if g_gl {
        glsrc = gl_source(srcp, name);
        srcp = str_from(glsrc.data, glsrc.len);
    }
    defer free(glsrc);
    string exe = exe_named(name);
    defer free(exe);
    ProcCmd c = { .args = { cc, srcp, "-o", str_from(exe.data, exe.len) } };
    if g_gl { proc_arg(&c, "-DSOKOL_GLCORE"); }
    if !g_no_trace { proc_arg(&c, "-DSOKOL_TRACE_HOOKS"); }
    c.capture = true;
    ProcResult r = proc_run(&c);
    i32 rc = r.exit_code;
    if rc != 0 && r.out.len > 0 { out(str_from(r.out.data, r.out.len)); }
    proc_result_free(&r);
    return rc;
}

// The published sample census, one stem per line.
string read_list() {
    FileData fd = file_read("samples/LIST.txt");
    string s = { .data = fd.data, .len = fd.len };
    return s;
}

void list_samples() {
    string lst = read_list();
    defer free(lst);
    if lst.len == 0 {
        say("samples/LIST.txt missing; dist is incomplete");
        return;
    }
    say("samples (run one with `minc run <name>`):");
    out(str_from(lst.data, lst.len));
    return;
}

void list_wasm_samples() {
    FileData fd = file_read("samples/LIST_WASM.txt");
    if fd.data == null {
        say("samples/LIST_WASM.txt missing; dist is incomplete");
        return;
    }
    string lst = { .data = fd.data, .len = fd.len };
    defer free(lst);
    say("wasm-capable samples (run one with `minc wasm <name>`):");
    out(str_from(lst.data, lst.len));
    return;
}

void list_wgpu_samples() {
    FileData fd = file_read("samples/LIST_WASM_WGPU.txt");
    if fd.data == null {
        say("samples/LIST_WASM_WGPU.txt missing; dist is incomplete");
        return;
    }
    string lst = { .data = fd.data, .len = fd.len };
    defer free(lst);
    say("WebGPU-capable samples (run one with `minc wasm <name> --wgpu`):");
    out(str_from(lst.data, lst.len));
    return;
}

// Non-negative integer from a CLI argument; -1 if it is not one.
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
// proc_run blocks until the child exits, and the process module has no
// spawn/poll pair, so the pool is threads: each worker takes the next
// stem and blocks in proc_run until you close that window, then takes
// another. Four on screen at once by default.
//

const i32 RUN_ALL_MAX = 256;

struct RunAll {
    str[RUN_ALL_MAX] stems;
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
            print("  [{}/{}] ", i + 1, _run_all.count);
            out("FAILED TO BUILD: ");
            say(stem);
            mutex_unlock(&_run_all.say_lock);
            continue;
        }

        string exe = exe_named(stem);
        defer free(exe);
        str exep = str_from(exe.data, exe.len);

        mutex_lock(&_run_all.say_lock);
        print("  [{}/{}] ", i + 1, _run_all.count);
        say(stem);
        mutex_unlock(&_run_all.say_lock);

        ProcCmd c = { .args = { exep } };
        if _run_all.seconds > 0 { c.timeout_ms = _run_all.seconds * 1000; }
        ProcResult r = proc_run(&c);
        // timeout is from --seconds
        if !r.spawned || (r.exit_code != 0 && !r.timed_out) {
            ignore atomic_add(&_run_all.failed, 1);
            mutex_lock(&_run_all.say_lock);
            out("      FAILED: ");
            say(stem);
            mutex_unlock(&_run_all.say_lock);
        }
        proc_result_free(&r);
    }
    return;
}

i32 main() {
    i32 argc = get_argc();
    str verb = "run";
    str target = "";
    bool no_run = false;
    bool use_wgpu = false;
    i32 jobs = 4;
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
        say("clean.");
        return 0;
    }

    string minc = find_minc();
    defer free(minc);
    if minc.len == 0 {
        say("");
        say("minc compiler not found.");
        say("Install it:  powershell -c \"irm minc.dev/install.ps1 | iex\"");
        say("or set MINC (see install_minc.md).");
        die("See README.md (Quickstart) and LICENSE.md.");
    }
    str cc = str_from(minc.data, minc.len);

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
        str srcp = str_from(src.data, src.len);
        if !path_exists(srcp) {
            out("no such sample: ");
            die(srcp);
        }
        str name = path_stem(target);
        // --wgpu: prepend @gpu "webgpu" + SOKOL_WGPU, build a
        // _wgpu-suffixed artifact. The temp source sits in samples/ so
        // sibling imports resolve.
        string wgpu_src = { .data = null, .len = 0 };
        if use_wgpu {
            FileData sfd = file_read(srcp);
            if sfd.data == null { die("cannot read sample source"); }
            string body = { .data = sfd.data, .len = sfd.len };
            defer free(body);
            string tmp_name = str_concat("samples/__wgpu_", name);
            defer free(tmp_name);
            wgpu_src = str_concat(str_from(tmp_name.data, tmp_name.len), ".mc");
            string paired = str_concat("@gpu \"webgpu\"
@define \"SOKOL_WGPU\"
",
                                       str_from(body.data, body.len));
            defer free(paired);
            if !file_write_str(str_from(wgpu_src.data, wgpu_src.len),
                               str_from(paired.data, paired.len)) {
                die("cannot write wgpu temp source");
            }
            srcp = str_from(wgpu_src.data, wgpu_src.len);
        }
        string out_stem = str_concat(name, "");
        if use_wgpu { free(out_stem); out_stem = str_concat(name, "_wgpu"); }
        defer free(out_stem);
        string wasm_out = join_named("build/web", str_from(out_stem.data, out_stem.len), ".wasm");
        defer free(wasm_out);
        out("building + serving ");
        out(name);
        if use_wgpu { say(" for the web (WebGPU)..."); }
        else { say(" for the web (wasm)..."); }
        ProcCmd c = { .args = {
            cc, "run", "--target", "wasm", srcp,
            "-o", str_from(wasm_out.data, wasm_out.len)
        } };
        if no_run { proc_arg(&c, "--no-browser"); }
        ProcResult r = proc_run(&c);
        i32 wrc = r.exit_code;
        proc_result_free(&r);
        if use_wgpu {
            ignore file_remove(str_from(wgpu_src.data, wgpu_src.len));
            free(wgpu_src);
        }
        return wrc;
    }

    if str_equal(verb, "run") && str_equal(target, "all") {
        string lst = read_list();
        // held for the whole run: the stems point into it
        defer free(lst);
        str rest = str_from(lst.data, lst.len);
        while rest.len > 0 && _run_all.count < RUN_ALL_MAX {
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
            _run_all.stems[_run_all.count] = line;
            _run_all.count++;
        }
        if _run_all.count == 0 { die("nothing to run"); }

        _run_all.seconds = seconds;
        _run_all.cc = cc;
        mutex_init(&_run_all.say_lock);
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
        defer free(lst);
        i32 fails = 0;
        i32 total = 0;
        str rest = str_from(lst.data, lst.len);
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
            total++;
            if build_one(cc, line) != 0 { fails++; }
        }
        if fails > 0 {
            out("FAILED: ");
            say("some samples did not build");
            return 1;
        }
        say("all samples built.");
        return 0;
    }

    i32 rc = build_one(cc, target);
    if rc != 0 { die("minc compile failed"); }

    if str_equal(verb, "run") {
        str name = path_stem(target);
        string exe = exe_named(name);
        defer free(exe);
        str exep = str_from(exe.data, exe.len);
        ProcCmd runc = { .args = { exep } };
        ProcResult rr = proc_run(&runc);
        rc = rr.exit_code;
        proc_result_free(&rr);
    }
    return rc;
}
