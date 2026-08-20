// Pins the GL 3.3 core backend. Must come before anything that imports
// sokol_all, directly or through another module, so it is emitted ahead
// of the sample's module imports.
//
// Used by samples that need a GL-only feature natively; sgl-points'
// point size is hardwired to 1px on D3D11 (upstream sokol_gl.h
// limitation).
//
// Windows only: the pin exists to override D3D11, which is the default
// there and nowhere else. Linux already defaults to GLCORE, and forcing
// it on wasm selects desktop-GL code paths that GLES3 cannot link
// (_sg_gl_texture_target's GL_TEXTURE_2D_MULTISAMPLE).
when os(windows) {
    @define "SOKOL_GLCORE"
}

import dbgui;
import sokol_gl;

import sokol_all;
import math;

// force high-dpi, sample entry point is __sapp_sample_main()
sapp_desc sokol_main() {
    sapp_desc d = __sapp_sample_main();
    d.high_dpi = true;
    return d;
}

struct rgb_t {
    f32 r;
    f32 g;
    f32 b;
}

private {
rgb_t[16] palette = {
    rgb_t{0.957f, 0.263f, 0.212f},
    rgb_t{0.914f, 0.118f, 0.388f},
    rgb_t{0.612f, 0.153f, 0.69f},
    rgb_t{0.404f, 0.227f, 0.718f},
    rgb_t{0.247f, 0.318f, 0.71f},
    rgb_t{0.129f, 0.588f, 0.953f},
    rgb_t{0.012f, 0.663f, 0.957f},
    rgb_t{0.0f, 0.737f, 0.831f},
    rgb_t{0.0f, 0.588f, 0.533f},
    rgb_t{0.298f, 0.686f, 0.314f},
    rgb_t{0.545f, 0.765f, 0.29f},
    rgb_t{0.804f, 0.863f, 0.224f},
    rgb_t{1.0f, 0.922f, 0.231f},
    rgb_t{1.0f, 0.757f, 0.027f},
    rgb_t{1.0f, 0.596f, 0.0f},
    rgb_t{1.0f, 0.341f, 0.133f},
};

void init() {
    sg_setup(&sg_desc{.environment = sglue_environment(), .logger = sg_logger{.func = slog_func}});
    __dbgui_setup();
    sgl_setup(&sgl_desc_t{.logger = sgl_logger_t{.func = slog_func}});
}

rgb_t compute_color(f32 t) {
    var i0 = cast(u8, cast(u8, t * 16.0f) % 16);
    var i1 = cast(u8, (i0 + 1) % 16);
    f32 l = fmodf(t * 16.0f, 1.0f);
    rgb_t c0 = palette[i0];
    rgb_t c1 = palette[i1];
    return rgb_t{
        c0.r * (1.0f - l) + c1.r * l, c0.g * (1.0f - l) + c1.g * l, c0.b * (1.0f - l) + c1.b * l,
    };
}

void frame() {
    var frame_count = cast(i32, sapp_frame_count());
    f32 angle = fmodf(cast(f32, frame_count), 360.0f);
    sgl_defaults();
    sgl_begin_points();
    f32 psize = 5.0f;
    for i32 i = 0; i < 300; i++ {
        f32 a = sgl_rad(angle + cast(f32, i));
        rgb_t color = compute_color(fmodf(cast(f32, frame_count + i), 300.0f) / 300.0f);
        f32 r = sinf(a * 4.0f);
        f32 s = sinf(a);
        f32 c = cosf(a);
        f32 x = s * r;
        f32 y = c * r;
        sgl_c3f(color.r, color.g, color.b);
        sgl_point_size(psize);
        sgl_v2f(x, y);
        psize *= 1.005f;
    }
    sgl_end();
    var pass_action = sg_pass_action{
        .colors[0] = {.load_action = SG_LOADACTION_CLEAR, .clear_value = {0.0f, 0.0f, 0.0f, 1.0f}},
    };
    sg_begin_pass(&sg_pass{.action = pass_action, .swapchain = sglue_swapchain()});
    sgl_draw();
    sg_end_pass();
    sg_commit();
}

void cleanup() {
    __dbgui_shutdown();
    sgl_shutdown();
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
        .window_title = "sgl-points-sapp.mc",
        .icon = sapp_icon_desc{.sokol_default = true},
        .logger = sapp_logger{.func = slog_func},
    };
}
