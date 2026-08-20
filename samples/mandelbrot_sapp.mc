import dbgui;

import sokol_all;
import math;

// force high-dpi, sample entry point is __sapp_sample_main()
sapp_desc sokol_main() {
    sapp_desc d = __sapp_sample_main();
    d.high_dpi = true;
    return d;
}

// mandelbrot-sapp.glsl - ported to minc @shader.

struct MandelbrotSappVsOut {
    float4 pos;
    float2 uv;
}

@shader vertex
MandelbrotSappVsOut mandelbrot_sapp_vs() {
    MandelbrotSappVsOut o;
    f32 x = cast(f32, (vertex_id() << 1) & 2);
    f32 y = cast(f32, vertex_id() & 2);
    o.pos = float4{x * 2.0f - 1.0f, y * 2.0f - 1.0f, 0.0f, 1.0f};
    o.uv = float2{x, 1.0f - y};
    return o;
}

@gpu_layout
struct Ub_fs_params {
    f32 time;
    f32 width;
    float2 aspect;
    i32 iter_max;
}

@shader fragment
float4 mandelbrot_sapp_fs(
MandelbrotSappVsOut input,
    @uniform(0) Ub_fs_params fs_params
) {
    float2 target = float2{-0.7756838f, 0.1364674f};
    float2 c = target + ((input.uv - 0.5f) * fs_params.width * fs_params.aspect);
    float2 z = float2{0.0f, 0.0f};
    f32 n = 0.0f;
    for i32 i = 0; i < fs_params.iter_max; i++ {
        z = float2{z.x * z.x - z.y * z.y + c.x, 2.0f * z.x * z.y + c.y};
        if dot(z, z) > 4.0f {
            break;
        }
        n += 1.0f;
    }
    f32 t = n / cast(f32, fs_params.iter_max);
    f32 phase = fs_params.time * 0.33f;
    f32 r = 0.0f;
    f32 g = 0.0f;
    f32 b = 0.0f;
    if n < cast(f32, fs_params.iter_max) {
        r = 0.5f + 0.5f * cos(6.28f * (t * 2.0f + phase));
        g = 0.5f + 0.5f * cos(6.28f * (t * 2.0f + phase + 0.33f));
        b = 0.5f + 0.5f * cos(6.28f * (t * 2.0f + phase + 0.67f));
    }
    return float4{r, g, b, 1.0f};
}


enum __enum_UB_fs_params {
    UB_fs_params = 0,
    __shim_end = 255,
}

// Replaces the sokol-shdc generated mandelbrot-sapp.glsl.h.
struct fs_params_t {
    f32 time;
    f32 width;
    f32[2] aspect;
    i32 iter_max;
    u8[12] _pad_tail;
}

private struct state_t {
    sg_pipeline pip;
    f32 time;
}

private {
state_t state;

void init() {
    sg_setup(&sg_desc{.environment = sglue_environment(), .logger = sg_logger{.func = slog_func}});
    __dbgui_setup();
    state.pip = sg_make_pipeline(&sg_pipeline_desc{.shader = sokol_make_shader(&mandelbrot_sapp_vs_shader, &mandelbrot_sapp_fs_shader)});
}

void frame() {
    state.time = fmodf(state.time + cast(f32, sapp_frame_duration()), 20.0f);
    f32 aspect = sapp_widthf() / sapp_heightf();
    f32 width = 4.0f * powf(0.6f, state.time);
    i32 iter_max = 64 + cast(i32, log2f(4.0f / width) * 32.0f);
    if iter_max > 256 {
        iter_max = 256;
    }
    var fs_params = fs_params_t{
        .time = state.time,
        .width = width,
        .iter_max = iter_max,
        .aspect = {aspect >= 1.0f ? aspect : 1.0f, aspect >= 1.0f ? 1.0f : 1.0f / aspect},
    };
    sg_begin_pass(&sg_pass{
        .action = sg_pass_action{.colors[0] = {.load_action = SG_LOADACTION_DONTCARE}},
        .swapchain = sglue_swapchain(),
    });
    sg_apply_pipeline(state.pip);
    sg_apply_uniforms(UB_fs_params, &sg_range{&fs_params, sizeof(fs_params)});
    sg_draw(0, 3, 1);
    __dbgui_draw();
    sg_end_pass();
    sg_commit();
}

void cleanup() {
    __dbgui_shutdown();
    sg_shutdown();
}
}

sapp_desc __sapp_sample_main() {
    return sapp_desc{
        .init_cb = init,
        .frame_cb = frame,
        .cleanup_cb = cleanup,
        .event_cb = __dbgui_event,
        .width = 512,
        .height = 512,
        .depth_format = SAPP_PIXELFORMAT_NONE,
        .window_title = "mandelbrot-sapp.mc",
        .icon = sapp_icon_desc{.sokol_default = true},
        .logger = sapp_logger{.func = slog_func},
    };
}
