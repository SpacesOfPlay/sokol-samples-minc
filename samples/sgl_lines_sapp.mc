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

type __arr_f32_6 = f32[6];
private struct state_t {
    sg_pass_action pass_action;
    sgl_pipeline depth_test_pip;
}

private {
state_t state;

void init() {
    sg_setup(&sg_desc{.environment = sglue_environment(), .logger = sg_logger{.func = slog_func}});
    __dbgui_setup();
    sgl_setup(&sgl_desc_t{.logger = sgl_logger_t{.func = slog_func}});
    state.depth_test_pip = sgl_make_pipeline(&sg_pipeline_desc{
        .depth = sg_depth_state{.write_enabled = true, .compare = SG_COMPAREFUNC_LESS_EQUAL},
    });
    state.pass_action = sg_pass_action{
        .colors[0] = {.load_action = SG_LOADACTION_CLEAR, .clear_value = {0.0f, 0.0f, 0.0f, 1.0f}},
    };
}

void grid(f32 y, u32 frame_count) {
    i32 num = 64;
    f32 dist = 4.0f;
    f32 z_offset = dist / 8.0f * cast(f32, frame_count & 7);
    sgl_begin_lines();
    for i32 i = 0; i < num; i++ {
        f32 x = cast(f32, i) * dist - cast(f32, num) * dist * 0.5f;
        sgl_v3f(x, y, cast(f32, -num) * dist);
        sgl_v3f(x, y, 0.0f);
    }
    for i32 i = 0; i < num; i++ {
        f32 z = z_offset + cast(f32, i) * dist - cast(f32, num) * dist;
        sgl_v3f(cast(f32, -num) * dist * 0.5f, y, z);
        sgl_v3f(cast(f32, num) * dist * 0.5f, y, z);
    }
    sgl_end();
}

void floaty_thingy(u32 frame_count) {
    u32 num_segs = 32;
    u32 start = frame_count % (num_segs * 2);
    if start < num_segs {
        start = 0;
    } else {
        start -= num_segs;
    }
    u32 end = frame_count % (num_segs * 2);
    if end > num_segs {
        end = num_segs;
    }
    f32 dx = 0.25f;
    f32 dy = 0.25f;
    f32 x0 = -(cast(f32, num_segs) * dx * 0.5f);
    f32 x1 = -x0;
    f32 y0 = -(cast(f32, num_segs) * dy * 0.5f);
    f32 y1 = -y0;
    sgl_begin_lines();
    for u32 i = start; i < end; i++ {
        f32 x = cast(f32, i) * dx;
        f32 y = cast(f32, i) * dy;
        sgl_v2f(x0 + x, y0);
        sgl_v2f(x1, y0 + y);
        sgl_v2f(x1 - x, y1);
        sgl_v2f(x0, y1 - y);
        sgl_v2f(x0 + x, y1);
        sgl_v2f(x1, y1 - y);
        sgl_v2f(x1 - x, y0);
        sgl_v2f(x0, y0 + y);
    }
    sgl_end();
}

u32 xorshift32() {
    xorshift32__x ^= xorshift32__x << 13;
    xorshift32__x ^= xorshift32__x >> 17;
    xorshift32__x ^= xorshift32__x << 5;
    return xorshift32__x;
}

f32 rnd() {
    return cast(f32, xorshift32() & 0xFFFF) / 65536.0f * 2.0f - 1.0f;
}

void hairball() {
    f32 vx = rnd();
    f32 vy = rnd();
    f32 vz = rnd();
    f32 r = (rnd() + 1.0f) * 0.5f;
    f32 g = (rnd() + 1.0f) * 0.5f;
    f32 b = (rnd() + 1.0f) * 0.5f;
    f32 x = hairball__ring[hairball__head][0];
    f32 y = hairball__ring[hairball__head][1];
    f32 z = hairball__ring[hairball__head][2];
    hairball__head = hairball__head + 1 & cast(u32, 1024 - 1);
    hairball__ring[hairball__head][0] = x * 0.9f + vx;
    hairball__ring[hairball__head][1] = y * 0.9f + vy;
    hairball__ring[hairball__head][2] = z * 0.9f + vz;
    hairball__ring[hairball__head][3] = r;
    hairball__ring[hairball__head][4] = g;
    hairball__ring[hairball__head][5] = b;
    sgl_begin_line_strip();
    for u32 i = hairball__head + 1 & cast(u32, 1024 - 1); i != hairball__head; i = i + 1 & cast(u32, 1024 - 1) {
        sgl_c3f(hairball__ring[i][3], hairball__ring[i][4], hairball__ring[i][5]);
        sgl_v3f(hairball__ring[i][0], hairball__ring[i][1], hairball__ring[i][2]);
    }
    sgl_end();
}

void frame() {
    f32 aspect = sapp_widthf() / sapp_heightf();
    frame__frame_count++;
    sgl_defaults();
    sgl_push_pipeline();
    sgl_load_pipeline(state.depth_test_pip);
    sgl_matrix_mode_projection();
    sgl_perspective(sgl_rad(45.0f), aspect, 0.1f, 1000.0f);
    sgl_matrix_mode_modelview();
    sgl_translate(sinf(cast(f32, frame__frame_count) * 0.02f) * 16.0f, sinf(cast(f32, frame__frame_count) * 0.01f) * 4.0f, 0.0f);
    sgl_c3f(1.0f, 0.0f, 1.0f);
    grid(-7.0f, frame__frame_count);
    grid(7.0f, frame__frame_count);
    sgl_push_matrix();
    sgl_translate(0.0f, 0.0f, -30.0f);
    sgl_rotate(cast(f32, frame__frame_count) * 0.05f, 0.0f, 1.0f, 1.0f);
    sgl_c3f(1.0f, 1.0f, 0.0f);
    floaty_thingy(frame__frame_count);
    sgl_pop_matrix();
    sgl_push_matrix();
    sgl_translate(-sinf(cast(f32, frame__frame_count) * 0.02f) * 32.0f, 0.0f, -70.0f + cosf(cast(f32, frame__frame_count) * 0.01f) * 50.0f);
    sgl_rotate(cast(f32, frame__frame_count) * 0.05f, 0.0f, -1.0f, 1.0f);
    sgl_c3f(0.0f, 1.0f, 0.0f);
    floaty_thingy(frame__frame_count + 32);
    sgl_pop_matrix();
    sgl_push_matrix();
    sgl_translate(-sinf(cast(f32, frame__frame_count) * 0.02f) * 16.0f, 0.0f, -30.0f);
    sgl_rotate(cast(f32, frame__frame_count) * 0.01f, sinf(cast(f32, frame__frame_count) * 0.005f), 0.0f, 1.0f);
    sgl_c3f(0.5f, 1.0f, 0.0f);
    hairball();
    sgl_pop_matrix();
    sgl_pop_pipeline();
    sg_begin_pass(&sg_pass{.action = state.pass_action, .swapchain = sglue_swapchain()});
    sgl_draw();
    __dbgui_draw();
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
        .sample_count = 4,
        .window_title = "sgl-lines-sapp.mc",
        .icon = sapp_icon_desc{.sokol_default = true},
        .logger = sapp_logger{.func = slog_func},
    };
}
private {
u32 xorshift32__x = 0x12345678;
__arr_f32_6[1024] hairball__ring;
u32 hairball__head = 0;
u32 frame__frame_count = 0;
}
