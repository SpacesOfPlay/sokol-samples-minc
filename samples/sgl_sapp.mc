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

type __arr_u32_8 = u32[8];
private struct state_t {
    sg_pass_action pass_action;
    sg_view tex_view;
    sg_sampler smp;
    sgl_pipeline pip_3d;
}

private {
state_t state;

void init() {
    sg_setup(&sg_desc{.environment = sglue_environment(), .logger = sg_logger{.func = slog_func}});
    __dbgui_setup();
    sgl_setup(&sgl_desc_t{.logger = sgl_logger_t{.func = slog_func}});
    noinit __arr_u32_8[8] pixels;
    for i32 y = 0; y < 8; y++ {
        for i32 x = 0; x < 8; x++ {
            pixels[y][x] = cast(u32, ((y ^ x) & 1) != 0 ? 0xFFFFFFFF : 0xFF000000);
        }
    }
    state.tex_view = sg_make_view(&sg_view_desc{
        .texture = sg_texture_view_desc{
            .image = sg_make_image(&sg_image_desc{
                .width = 8,
                .height = 8,
                .data = sg_image_data{.mip_levels[0] = sg_range{&pixels, sizeof(pixels)}},
            }),
        },
    });
    state.smp = sg_make_sampler(&sg_sampler_desc{
        .min_filter = SG_FILTER_NEAREST,
        .mag_filter = SG_FILTER_NEAREST,
    });
    state.pip_3d = sgl_make_pipeline(&sg_pipeline_desc{
        .cull_mode = SG_CULLMODE_BACK,
        .depth = sg_depth_state{.write_enabled = true, .compare = SG_COMPAREFUNC_LESS_EQUAL},
    });
    state.pass_action = sg_pass_action{
        .colors[0] = {.load_action = SG_LOADACTION_CLEAR, .clear_value = {0.0f, 0.0f, 0.0f, 1.0f}},
    };
}

void draw_triangle() {
    sgl_defaults();
    sgl_begin_triangles();
    sgl_v2f_c3b(0.0f, 0.5f, 255, 0, 0);
    sgl_v2f_c3b(-0.5f, -0.5f, 0, 0, 255);
    sgl_v2f_c3b(0.5f, -0.5f, 0, 255, 0);
    sgl_end();
}

void draw_quad(f32 t) {
    f32 scale = 1.0f + sinf(sgl_rad(draw_quad__angle_deg)) * 0.5f;
    draw_quad__angle_deg += 1.0f * t;
    sgl_defaults();
    sgl_rotate(sgl_rad(draw_quad__angle_deg), 0.0f, 0.0f, 1.0f);
    sgl_scale(scale, scale, 1.0f);
    sgl_begin_quads();
    sgl_v2f_c3b(-0.5f, -0.5f, 255, 255, 0);
    sgl_v2f_c3b(0.5f, -0.5f, 0, 255, 0);
    sgl_v2f_c3b(0.5f, 0.5f, 0, 0, 255);
    sgl_v2f_c3b(-0.5f, 0.5f, 255, 0, 0);
    sgl_end();
}

// vertex specification for a cube with colored sides and texture coords
void cube() {
    sgl_begin_quads();
    sgl_c3f(1.0f, 0.0f, 0.0f);
    sgl_v3f_t2f(-1.0f, 1.0f, -1.0f, -1.0f, 1.0f);
    sgl_v3f_t2f(1.0f, 1.0f, -1.0f, 1.0f, 1.0f);
    sgl_v3f_t2f(1.0f, -1.0f, -1.0f, 1.0f, -1.0f);
    sgl_v3f_t2f(-1.0f, -1.0f, -1.0f, -1.0f, -1.0f);
    sgl_c3f(0.0f, 1.0f, 0.0f);
    sgl_v3f_t2f(-1.0f, -1.0f, 1.0f, -1.0f, 1.0f);
    sgl_v3f_t2f(1.0f, -1.0f, 1.0f, 1.0f, 1.0f);
    sgl_v3f_t2f(1.0f, 1.0f, 1.0f, 1.0f, -1.0f);
    sgl_v3f_t2f(-1.0f, 1.0f, 1.0f, -1.0f, -1.0f);
    sgl_c3f(0.0f, 0.0f, 1.0f);
    sgl_v3f_t2f(-1.0f, -1.0f, 1.0f, -1.0f, 1.0f);
    sgl_v3f_t2f(-1.0f, 1.0f, 1.0f, 1.0f, 1.0f);
    sgl_v3f_t2f(-1.0f, 1.0f, -1.0f, 1.0f, -1.0f);
    sgl_v3f_t2f(-1.0f, -1.0f, -1.0f, -1.0f, -1.0f);
    sgl_c3f(1.0f, 0.5f, 0.0f);
    sgl_v3f_t2f(1.0f, -1.0f, 1.0f, -1.0f, 1.0f);
    sgl_v3f_t2f(1.0f, -1.0f, -1.0f, 1.0f, 1.0f);
    sgl_v3f_t2f(1.0f, 1.0f, -1.0f, 1.0f, -1.0f);
    sgl_v3f_t2f(1.0f, 1.0f, 1.0f, -1.0f, -1.0f);
    sgl_c3f(0.0f, 0.5f, 1.0f);
    sgl_v3f_t2f(1.0f, -1.0f, -1.0f, -1.0f, 1.0f);
    sgl_v3f_t2f(1.0f, -1.0f, 1.0f, 1.0f, 1.0f);
    sgl_v3f_t2f(-1.0f, -1.0f, 1.0f, 1.0f, -1.0f);
    sgl_v3f_t2f(-1.0f, -1.0f, -1.0f, -1.0f, -1.0f);
    sgl_c3f(1.0f, 0.0f, 0.5f);
    sgl_v3f_t2f(-1.0f, 1.0f, -1.0f, -1.0f, 1.0f);
    sgl_v3f_t2f(-1.0f, 1.0f, 1.0f, 1.0f, 1.0f);
    sgl_v3f_t2f(1.0f, 1.0f, 1.0f, 1.0f, -1.0f);
    sgl_v3f_t2f(1.0f, 1.0f, -1.0f, -1.0f, -1.0f);
    sgl_end();
}

void draw_cubes(f32 t) {
    draw_cubes__rot[0] += 1.0f * t;
    draw_cubes__rot[1] += 2.0f * t;
    sgl_defaults();
    sgl_load_pipeline(state.pip_3d);
    sgl_matrix_mode_projection();
    sgl_perspective(sgl_rad(45.0f), 1.0f, 0.1f, 100.0f);
    sgl_matrix_mode_modelview();
    sgl_translate(0.0f, 0.0f, -12.0f);
    sgl_rotate(sgl_rad(draw_cubes__rot[0]), 1.0f, 0.0f, 0.0f);
    sgl_rotate(sgl_rad(draw_cubes__rot[1]), 0.0f, 1.0f, 0.0f);
    cube();
    sgl_push_matrix();
    sgl_translate(0.0f, 0.0f, 3.0f);
    sgl_scale(0.5f, 0.5f, 0.5f);
    sgl_rotate(-2.0f * sgl_rad(draw_cubes__rot[0]), 1.0f, 0.0f, 0.0f);
    sgl_rotate(-2.0f * sgl_rad(draw_cubes__rot[1]), 0.0f, 1.0f, 0.0f);
    cube();
    sgl_push_matrix();
    sgl_translate(0.0f, 0.0f, 3.0f);
    sgl_scale(0.5f, 0.5f, 0.5f);
    sgl_rotate(-3.0f * sgl_rad(2.0f * draw_cubes__rot[0]), 1.0f, 0.0f, 0.0f);
    sgl_rotate(3.0f * sgl_rad(2.0f * draw_cubes__rot[1]), 0.0f, 0.0f, 1.0f);
    cube();
    sgl_pop_matrix();
    sgl_pop_matrix();
}

void draw_tex_cube(f32 t) {
    draw_tex_cube__frame_count += 1.0f * t;
    f32 a = sgl_rad(draw_tex_cube__frame_count);
    f32 tex_rot = 0.5f * a;
    f32 tex_scale = 1.0f + sinf(a) * 0.5f;
    f32 eye_x = sinf(a) * 6.0f;
    f32 eye_z = cosf(a) * 6.0f;
    f32 eye_y = sinf(a) * 3.0f;
    sgl_defaults();
    sgl_load_pipeline(state.pip_3d);
    sgl_enable_texture();
    sgl_texture(state.tex_view, state.smp);
    sgl_matrix_mode_projection();
    sgl_perspective(sgl_rad(45.0f), 1.0f, 0.1f, 100.0f);
    sgl_matrix_mode_modelview();
    sgl_lookat(eye_x, eye_y, eye_z, 0.0f, 0.0f, 0.0f, 0.0f, 1.0f, 0.0f);
    sgl_matrix_mode_texture();
    sgl_rotate(tex_rot, 0.0f, 0.0f, 1.0f);
    sgl_scale(tex_scale, tex_scale, 1.0f);
    cube();
}

void frame() {
    var t = cast(f32, sapp_frame_duration() * 60.0);
    i32 dw = sapp_width();
    i32 dh = sapp_height();
    i32 ww = dh / 2;
    i32 hh = dh / 2;
    i32 x0 = dw / 2 - hh;
    i32 x1 = dw / 2;
    i32 y0 = 0;
    i32 y1 = dh / 2;
    sgl_viewport(x0, y0, ww, hh, true);
    draw_triangle();
    sgl_viewport(x1, y0, ww, hh, true);
    draw_quad(t);
    sgl_viewport(x0, y1, ww, hh, true);
    draw_cubes(t);
    sgl_viewport(x1, y1, ww, hh, true);
    draw_tex_cube(t);
    sgl_viewport(0, 0, dw, dh, true);
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
        .window_title = "sgl-sapp.mc",
        .icon = sapp_icon_desc{.sokol_default = true},
        .logger = sapp_logger{.func = slog_func},
    };
}
private {
f32 draw_quad__angle_deg = 0.0f;
f32[2] draw_cubes__rot = {0.0f, 0.0f};
f32 draw_tex_cube__frame_count = 0.0f;
}
