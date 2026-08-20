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

private struct state_t {
    f64 angle_deg;
    struct {
        sg_view tex_view;
        sg_pass pass;
        sgl_context sgl_ctx;
    } offscreen;
    struct {
        sg_pass_action pass_action;
        sg_sampler smp;
        sgl_pipeline sgl_pip;
    } display;
}

private { state_t state; }

private {
void init() {
    sg_setup(&sg_desc{.environment = sglue_environment(), .logger = sg_logger{.func = slog_func}});
    __dbgui_setup();
    sgl_setup(&sgl_desc_t{
        .max_vertices = 64,
        .max_commands = 16,
        .logger = sgl_logger_t{.func = slog_func},
    });
    state.display.pass_action = sg_pass_action{
        .colors[0] = {.load_action = SG_LOADACTION_CLEAR, .clear_value = {0.5f, 0.7f, 1.0f, 1.0f}},
    };
    state.display.sgl_pip = sgl_context_make_pipeline(sgl_default_context(), &sg_pipeline_desc{
        .cull_mode = SG_CULLMODE_BACK,
        .depth = sg_depth_state{.write_enabled = true, .compare = SG_COMPAREFUNC_LESS_EQUAL},
    });
    state.offscreen.sgl_ctx = sgl_make_context(&sgl_context_desc_t{
        .max_vertices = 8,
        .max_commands = 4,
        .color_format = SG_PIXELFORMAT_RGBA8,
        .depth_format = SG_PIXELFORMAT_NONE,
        .sample_count = 1,
    });
    sg_image img = sg_make_image(&sg_image_desc{
        .usage = sg_image_usage{.color_attachment = true},
        .width = 32,
        .height = 32,
        .pixel_format = SG_PIXELFORMAT_RGBA8,
        .sample_count = 1,
    });
    state.offscreen.tex_view = sg_make_view(&sg_view_desc{.texture = sg_texture_view_desc{.image = img}});
    state.offscreen.pass = sg_pass{
        .action = sg_pass_action{
            .colors[0] = {
                .load_action = SG_LOADACTION_CLEAR,
                .clear_value = {0.0f, 0.0f, 0.0f, 1.0f},
            },
        },
        .attachments = sg_attachments{.colors[0] = sg_make_view(&sg_view_desc{.color_attachment = sg_image_view_desc{.image = img}})},
    };
    state.display.smp = sg_make_sampler(&sg_sampler_desc{
        .wrap_u = SG_WRAP_CLAMP_TO_EDGE,
        .wrap_v = SG_WRAP_CLAMP_TO_EDGE,
        .min_filter = SG_FILTER_NEAREST,
        .mag_filter = SG_FILTER_NEAREST,
    });
}

void frame() {
    state.angle_deg += sapp_frame_duration() * 60.0;
    f32 a = sgl_rad(cast(f32, state.angle_deg));
    sgl_set_context(state.offscreen.sgl_ctx);
    sgl_defaults();
    sgl_matrix_mode_modelview();
    sgl_rotate(a, 0.0f, 0.0f, 1.0f);
    draw_quad();
    sgl_set_context(SGL_DEFAULT_CONTEXT);
    sgl_defaults();
    sgl_enable_texture();
    sgl_texture(state.offscreen.tex_view, state.display.smp);
    sgl_load_pipeline(state.display.sgl_pip);
    sgl_matrix_mode_projection();
    sgl_perspective(sgl_rad(45.0f), sapp_widthf() / sapp_heightf(), 0.1f, 100.0f);
    f32[3] eye = {sinf(a) * 6.0f, sinf(a) * 3.0f, cosf(a) * 6.0f};
    sgl_matrix_mode_modelview();
    sgl_lookat(eye[0], eye[1], eye[2], 0.0f, 0.0f, 0.0f, 0.0f, 1.0f, 0.0f);
    draw_cube();
    sg_begin_pass(&state.offscreen.pass);
    sgl_context_draw(state.offscreen.sgl_ctx);
    sg_end_pass();
    sg_begin_pass(&sg_pass{.action = state.display.pass_action, .swapchain = sglue_swapchain()});
    sgl_context_draw(SGL_DEFAULT_CONTEXT);
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
        .width = 800,
        .height = 600,
        .sample_count = 4,
        .window_title = "sgl-context-sapp.mc",
        .icon = sapp_icon_desc{.sokol_default = true},
        .logger = sapp_logger{.func = slog_func},
    };
}

// helper function to draw a colored quad with sokol-gl
private {
void draw_quad() {
    sgl_begin_quads();
    sgl_v2f_c3b(0.0f, -1.0f, 255, 0, 0);
    sgl_v2f_c3b(1.0f, 0.0f, 0, 0, 255);
    sgl_v2f_c3b(0.0f, 1.0f, 0, 255, 255);
    sgl_v2f_c3b(-1.0f, 0.0f, 0, 255, 0);
    sgl_end();
}

// helper function to draw a textured cube with sokol-gl
void draw_cube() {
    sgl_begin_quads();
    sgl_v3f_t2f(-1.0f, 1.0f, -1.0f, 0.0f, 1.0f);
    sgl_v3f_t2f(1.0f, 1.0f, -1.0f, 1.0f, 1.0f);
    sgl_v3f_t2f(1.0f, -1.0f, -1.0f, 1.0f, 0.0f);
    sgl_v3f_t2f(-1.0f, -1.0f, -1.0f, 0.0f, 0.0f);
    sgl_v3f_t2f(-1.0f, -1.0f, 1.0f, 0.0f, 1.0f);
    sgl_v3f_t2f(1.0f, -1.0f, 1.0f, 1.0f, 1.0f);
    sgl_v3f_t2f(1.0f, 1.0f, 1.0f, 1.0f, 0.0f);
    sgl_v3f_t2f(-1.0f, 1.0f, 1.0f, 0.0f, 0.0f);
    sgl_v3f_t2f(-1.0f, -1.0f, 1.0f, 0.0f, 1.0f);
    sgl_v3f_t2f(-1.0f, 1.0f, 1.0f, 1.0f, 1.0f);
    sgl_v3f_t2f(-1.0f, 1.0f, -1.0f, 1.0f, 0.0f);
    sgl_v3f_t2f(-1.0f, -1.0f, -1.0f, 0.0f, 0.0f);
    sgl_v3f_t2f(1.0f, -1.0f, 1.0f, 0.0f, 1.0f);
    sgl_v3f_t2f(1.0f, -1.0f, -1.0f, 1.0f, 1.0f);
    sgl_v3f_t2f(1.0f, 1.0f, -1.0f, 1.0f, 0.0f);
    sgl_v3f_t2f(1.0f, 1.0f, 1.0f, 0.0f, 0.0f);
    sgl_v3f_t2f(1.0f, -1.0f, -1.0f, 0.0f, 1.0f);
    sgl_v3f_t2f(1.0f, -1.0f, 1.0f, 1.0f, 1.0f);
    sgl_v3f_t2f(-1.0f, -1.0f, 1.0f, 1.0f, 0.0f);
    sgl_v3f_t2f(-1.0f, -1.0f, -1.0f, 0.0f, 0.0f);
    sgl_v3f_t2f(-1.0f, 1.0f, -1.0f, 0.0f, 1.0f);
    sgl_v3f_t2f(-1.0f, 1.0f, 1.0f, 1.0f, 1.0f);
    sgl_v3f_t2f(1.0f, 1.0f, 1.0f, 1.0f, 0.0f);
    sgl_v3f_t2f(1.0f, 1.0f, -1.0f, 0.0f, 0.0f);
    sgl_end();
}
}
