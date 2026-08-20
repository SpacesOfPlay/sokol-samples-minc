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

// transminc: C stdlib constants referenced by source
const f64 M_PI = 3.141592653589793;

private struct state_t {
    sg_pass_action pass_action;
    f32 ball_x;
    f32 ball_y;
    f32 ball_vx;
    f32 ball_vy;
    f32 ball_radius;
    f32 ball_rotz;
    f32 ball_rotx;
}

private { state_t state; }
sg_color bg_color = sg_color{0.2f, 0.2f, 0.4f, 1.0f};

private {
void init() {
    sg_setup(&sg_desc{.environment = sglue_environment(), .logger = sg_logger{.func = slog_func}});
    __dbgui_setup();
    sgl_setup(&sgl_desc_t{.logger = sgl_logger_t{.func = slog_func}});
    state.pass_action = sg_pass_action{
        .colors[0] = {.load_action = SG_LOADACTION_CLEAR, .clear_value = bg_color},
    };
    state.ball_radius = 70.0f;
    state.ball_x = state.ball_radius + 20.0f;
    state.ball_y = sapp_heightf() - state.ball_radius - 20.0f;
    state.ball_vx = 300.0f;
    state.ball_vy = -sapp_heightf();
}

void frame() {
    var dt = cast(f32, sapp_frame_duration());
    f32 gravity = 800.0f;
    state.ball_vy += gravity * dt;
    state.ball_x += state.ball_vx * dt;
    state.ball_y += state.ball_vy * dt;
    f32 floor_y = sapp_heightf() - state.ball_radius;
    if state.ball_y > floor_y {
        state.ball_y = floor_y;
        state.ball_vy = -sapp_heightf();
    }
    if state.ball_x < state.ball_radius {
        state.ball_x = state.ball_radius;
        state.ball_vx = -state.ball_vx;
    }
    if state.ball_x > sapp_widthf() - state.ball_radius {
        state.ball_x = sapp_widthf() - state.ball_radius;
        state.ball_vx = -state.ball_vx;
    }
    state.ball_rotz += state.ball_vx * dt * 0.3f;
    state.ball_rotx += state.ball_vy * dt * 0.2f;
    var red = sg_color{.r = 0.9f, .g = 0.1f, .b = 0.1f};
    var white = sg_color{.r = 1.0f, .g = 1.0f, .b = 1.0f};
    var shadow = sg_color{bg_color.r * 0.5f, bg_color.g * 0.5f, bg_color.b * 0.5f, 1.0f};
    sgl_defaults();
    sgl_matrix_mode_projection();
    sgl_ortho(0.0f, sapp_widthf(), sapp_heightf(), 0.0f, -100.0f, 100.0f);
    sgl_matrix_mode_modelview();
    draw_ball(state.ball_x + 20.0f, state.ball_y + 30.0f, state.ball_radius * 1.05f, state.ball_rotz, state.ball_rotx, shadow, shadow);
    draw_ball(state.ball_x, state.ball_y, state.ball_radius, state.ball_rotz, state.ball_rotx, red, white);
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

void draw_ball(f32 x, f32 y, f32 r, f32 rotz, f32 rotx, sg_color c0, sg_color c1) {
    i32 bands = 12;
    i32 segs = 12;
    sgl_push_matrix();
    sgl_translate(x, y, 0.0f);
    sgl_rotate(sgl_rad(rotz), 0.0f, 0.0f, 1.0f);
    sgl_rotate(sgl_rad(rotx), 1.0f, 0.0f, 0.0f);
    sgl_begin_quads();
    for i32 lat = 0; lat < bands; lat++ {
        var latf = cast(f32, lat);
        f32 t1 = cast(f32, M_PI) * (latf / cast(f32, bands)) - cast(f32, M_PI) * 0.5f;
        f32 t2 = cast(f32, M_PI) * ((latf + 1.0f) / cast(f32, bands)) - cast(f32, M_PI) * 0.5f;
        f32 sint1 = sinf(t1);
        f32 cost1 = cosf(t1);
        f32 sint2 = sinf(t2);
        f32 cost2 = cosf(t2);
        for i32 lon = 0; lon < segs; lon++ {
            var lonf = cast(f32, lon);
            f32 p1 = 2.0f * cast(f32, M_PI) * (lonf / cast(f32, segs));
            f32 p2 = 2.0f * cast(f32, M_PI) * ((lonf + 1.0f) / cast(f32, segs));
            bool is_red = 0 != (lat + lon & 1);
            f32 sinp1 = sinf(p1);
            f32 cosp1 = cosf(p1);
            f32 sinp2 = sinf(p2);
            f32 cosp2 = cosf(p2);
            if is_red != 0 {
                sgl_c3f(c0.r, c0.g, c0.b);
            } else {
                sgl_c3f(c1.r, c1.g, c1.b);
            }
            sgl_v3f(r * cost1 * cosp1, r * sint1, r * cost1 * sinp1);
            sgl_v3f(r * cost1 * cosp2, r * sint1, r * cost1 * sinp2);
            sgl_v3f(r * cost2 * cosp2, r * sint2, r * cost2 * sinp2);
            sgl_v3f(r * cost2 * cosp1, r * sint2, r * cost2 * sinp1);
        }
    }
    sgl_end();
    sgl_pop_matrix();
}
}

sapp_desc __sapp_sample_main() {
    return sapp_desc{
        .init_cb = init,
        .frame_cb = frame,
        .cleanup_cb = cleanup,
        .event_cb = __dbgui_event,
        .width = 800,
        .height = 600,
        .window_title = "sgl-boing-sapp.mc",
        .icon = sapp_icon_desc{.sokol_default = true},
    };
}
