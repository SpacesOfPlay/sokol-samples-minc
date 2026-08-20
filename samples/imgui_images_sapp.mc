import dbgui;
import imgui_compat;
import sokol_gl;

// sapp samples that use Dear ImGui
import sokol_all;
import imgui;
import sokol_imgui;
import math;

// upstream samples leave high_dpi off and blur on scaled displays.
// Forced enabled here.
sapp_desc sokol_main() {
    sapp_desc d = __sapp_sample_main();
    d.high_dpi = true;
    return d;
}

private struct state_t {
    f64 angle_deg;
    struct {
        sgl_context sgl_ctx;
        sgl_pipeline sgl_pip;
        sg_view tex_view;
        sg_pass pass;
    } offscreen;
    struct {
        sg_pass_action pass_action;
    } display;
    struct {
        sg_sampler nearest_clamp;
        sg_sampler linear_clamp;
        sg_sampler nearest_repeat;
        sg_sampler linear_mirror;
    } smp;
}

private { state_t state; }

// helper function to construct ImTextureRef from ImTextureID
// FIXME: remove when Dear Bindings offers such helper
private {
ImTextureRef imtexref(ImTextureID tex_id) {
    return ImTextureRef{._TexID = tex_id};
}

void init() {
    sg_setup(&sg_desc{.environment = sglue_environment(), .logger = sg_logger{.func = slog_func}});
    simgui_setup(&simgui_desc_t{.logger = simgui_logger_t{.func = slog_func}});
    sgl_setup(&sgl_desc_t{.logger = sgl_logger_t{.func = slog_func}});
    state.offscreen.sgl_ctx = sgl_make_context(&sgl_context_desc_t{
        .color_format = SG_PIXELFORMAT_RGBA8,
        .depth_format = SG_PIXELFORMAT_DEPTH,
        .sample_count = 1,
    });
    state.offscreen.sgl_pip = sgl_context_make_pipeline(state.offscreen.sgl_ctx, &sg_pipeline_desc{
        .cull_mode = SG_CULLMODE_BACK,
        .depth = sg_depth_state{
            .write_enabled = true,
            .pixel_format = SG_PIXELFORMAT_DEPTH,
            .compare = SG_COMPAREFUNC_LESS_EQUAL,
        },
        .colors[0] = {.pixel_format = SG_PIXELFORMAT_RGBA8},
        .sample_count = 1,
    });
    sg_image color_img = sg_make_image(&sg_image_desc{
        .usage = sg_image_usage{.color_attachment = true},
        .width = 32,
        .height = 32,
        .pixel_format = SG_PIXELFORMAT_RGBA8,
        .sample_count = 1,
    });
    sg_image depth_img = sg_make_image(&sg_image_desc{
        .usage = sg_image_usage{.depth_stencil_attachment = true},
        .width = 32,
        .height = 32,
        .pixel_format = SG_PIXELFORMAT_DEPTH,
        .sample_count = 1,
    });
    state.offscreen.tex_view = sg_make_view(&sg_view_desc{.texture = sg_texture_view_desc{.image = color_img}});
    sg_view color_view = sg_make_view(&sg_view_desc{.color_attachment = sg_image_view_desc{.image = color_img}});
    sg_view depth_view = sg_make_view(&sg_view_desc{.depth_stencil_attachment = sg_image_view_desc{.image = depth_img}});
    state.offscreen.pass = sg_pass{
        .action = sg_pass_action{
            .colors[0] = {
                .load_action = SG_LOADACTION_CLEAR,
                .clear_value = {0.0f, 0.0f, 0.0f, 1.0f},
            },
        },
        .attachments = sg_attachments{.colors[0] = color_view, .depth_stencil = depth_view},
    };
    state.display.pass_action = sg_pass_action{
        .colors[0] = {.load_action = SG_LOADACTION_CLEAR, .clear_value = {0.5f, 0.5f, 1.0f, 1.0f}},
    };
    state.smp.nearest_clamp = sg_make_sampler(&sg_sampler_desc{
        .min_filter = SG_FILTER_NEAREST,
        .mag_filter = SG_FILTER_NEAREST,
        .wrap_u = SG_WRAP_CLAMP_TO_EDGE,
        .wrap_v = SG_WRAP_CLAMP_TO_EDGE,
    });
    state.smp.linear_clamp = sg_make_sampler(&sg_sampler_desc{
        .min_filter = SG_FILTER_LINEAR,
        .mag_filter = SG_FILTER_LINEAR,
        .wrap_u = SG_WRAP_CLAMP_TO_EDGE,
        .wrap_v = SG_WRAP_CLAMP_TO_EDGE,
    });
    state.smp.nearest_repeat = sg_make_sampler(&sg_sampler_desc{
        .min_filter = SG_FILTER_NEAREST,
        .mag_filter = SG_FILTER_NEAREST,
        .wrap_u = SG_WRAP_REPEAT,
        .wrap_v = SG_WRAP_REPEAT,
    });
    state.smp.linear_mirror = sg_make_sampler(&sg_sampler_desc{
        .min_filter = SG_FILTER_LINEAR,
        .mag_filter = SG_FILTER_LINEAR,
        .wrap_u = SG_WRAP_MIRRORED_REPEAT,
        .wrap_v = SG_WRAP_MIRRORED_REPEAT,
    });
}

void frame() {
    state.angle_deg += sapp_frame_duration() * 60.0;
    f32 a = sgl_rad(cast(f32, state.angle_deg));
    sgl_set_context(state.offscreen.sgl_ctx);
    sgl_defaults();
    sgl_load_pipeline(state.offscreen.sgl_pip);
    sgl_matrix_mode_projection();
    sgl_perspective(sgl_rad(45.0f), 1.0f, 0.1f, 100.0f);
    f32[3] eye = {sinf(a) * 4.0f, sinf(a) * 2.0f, cosf(a) * 4.0f};
    sgl_matrix_mode_modelview();
    sgl_lookat(eye[0], eye[1], eye[2], 0.0f, 0.0f, 0.0f, 0.0f, 1.0f, 0.0f);
    draw_cube();
    simgui_new_frame(&simgui_frame_desc_t{
        .width = sapp_width(),
        .height = sapp_height(),
        .delta_time = sapp_frame_duration(),
        .dpi_scale = sapp_dpi_scale(),
    });
    ImGui_SetNextWindowPos(ImVec2{20.0f, 20.0f}, ImGuiCond_Once);
    ImGui_SetNextWindowSize(ImVec2{540.0f, 560.0f}, ImGuiCond_Once);
    if ImGui_Begin("Sokol + Dear ImGui Image Test", null, 0) != 0 {
        var size = ImVec2{256.0f, 256.0f};
        var uv0 = ImVec2{0.0f, 0.0f};
        var uv1 = ImVec2{1.0f, 1.0f};
        var uv2 = ImVec2{4.0f, 4.0f};
        sg_view view = state.offscreen.tex_view;
        ImTextureID texid0 = simgui_imtextureid_with_sampler(view, state.smp.nearest_clamp);
        ImTextureID texid1 = simgui_imtextureid_with_sampler(view, state.smp.linear_clamp);
        ImTextureID texid2 = simgui_imtextureid_with_sampler(view, state.smp.nearest_repeat);
        ImTextureID texid3 = simgui_imtextureid_with_sampler(view, state.smp.linear_mirror);
        ImGui_Image(imtexref(texid0), size, uv0, uv1);
        ImGui_SameLine(0.0f, 4.0f);
        ImGui_Image(imtexref(texid1), size, uv0, uv1);
        ImGui_Image(imtexref(texid2), size, uv0, uv2);
        ImGui_SameLine(0.0f, 4.0f);
        ImGui_Image(imtexref(texid3), size, uv0, uv2);
    }
    ImGui_End();
    sg_begin_pass(&state.offscreen.pass);
    sgl_context_draw(state.offscreen.sgl_ctx);
    sg_end_pass();
    sg_begin_pass(&sg_pass{.action = state.display.pass_action, .swapchain = sglue_swapchain()});
    simgui_render();
    sg_end_pass();
    sg_commit();
}

void cleanup() {
    sgl_shutdown();
    simgui_shutdown();
    sg_shutdown();
}

void input(sapp_event* ev) {
    simgui_handle_event(ev);
}
}

sapp_desc __sapp_sample_main() {
    return sapp_desc{
        .width = 580,
        .height = 600,
        .init_cb = init,
        .frame_cb = frame,
        .event_cb = input,
        .cleanup_cb = cleanup,
        .window_title = "imgui-images-sapp.mc",
        .icon = sapp_icon_desc{.sokol_default = true},
        .logger = sapp_logger{.func = slog_func},
    };
}

// vertex specification for a cube with colored sides and texture coords
private {
void draw_cube() {
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
}
