import dbgui;
import imgui_compat;
import sokol_gl;
import sokol_letterbox;

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

struct __anon_letterbox_sapp_struct_1 {
    slbx_anchor anchor;
    u8* label;
}

private struct state_t {
    sg_pass_action pass_action;
    slbx_letterbox_desc lbox;
    bool link_lr_border;
    bool link_tb_border;
    i32 cur_anchor_idx;
    __anon_letterbox_sapp_struct_1[5] anchors;
}

private {
state_t state = state_t{
    .pass_action = sg_pass_action{
        .colors[0] = {.load_action = SG_LOADACTION_CLEAR, .clear_value = {0.0f, 0.0f, 0.0f, 1.0f}},
    },
    .link_lr_border = true,
    .link_tb_border = true,
    .lbox = slbx_letterbox_desc{.content_aspect_ratio = 4.0f / 3.0f},
    .anchors = {
        __anon_letterbox_sapp_struct_1{.anchor = SLBX_ANCHOR_CENTER, .label = "Center"},
        __anon_letterbox_sapp_struct_1{.anchor = SLBX_ANCHOR_TOP, .label = "Top"},
        __anon_letterbox_sapp_struct_1{.anchor = SLBX_ANCHOR_BOTTOM, .label = "Bottom"},
        __anon_letterbox_sapp_struct_1{.anchor = SLBX_ANCHOR_LEFT, .label = "Left"},
        __anon_letterbox_sapp_struct_1{.anchor = SLBX_ANCHOR_RIGHT, .label = "Right"},
    },
};
}

private {
void init() {
    sg_setup(&sg_desc{.environment = sglue_environment(), .logger = sg_logger{.func = slog_func}});
    sgl_setup(&sgl_desc_t{.logger = sgl_logger_t{.func = slog_func}});
    simgui_setup(&simgui_desc_t{.logger = simgui_logger_t{.func = slog_func}});
}

void frame() {
    draw_ui();
    i32 width = sapp_width();
    i32 height = sapp_height();
    sgl_defaults();
    slbx_viewport vp = slbx_letterbox(width, height, &state.lbox);
    sgl_viewport(vp.x, vp.y, vp.width, vp.height, true);
    sgl_begin_quads();
    main_quad();
    corner_quad(-0.9f, 0.9f);
    corner_quad(0.9f, 0.9f);
    corner_quad(0.9f, -0.9f);
    corner_quad(-0.9f, -0.9f);
    sgl_end();
    sgl_viewport(0, 0, width, height, true);
    sg_begin_pass(&sg_pass{.action = state.pass_action, .swapchain = sglue_swapchain()});
    sgl_draw();
    simgui_render();
    sg_end_pass();
    sg_commit();
}

void main_quad() {
    sgl_v2f_c3b(-1.0f, 1.0f, 255, 0, 0);
    sgl_v2f_c3b(1.0f, 1.0f, 255, 255, 0);
    sgl_v2f_c3b(1.0f, -1.0f, 0, 255, 0);
    sgl_v2f_c3b(-1.0f, -1.0f, 0, 255, 255);
}

void corner_quad(f32 x, f32 y) {
    f32 s = 0.05f;
    u8 r = 255;
    u8 g = 128;
    u8 b = 255;
    sgl_v2f_c3b(x - s, y + s, r, g, b);
    sgl_v2f_c3b(x + s, y + s, r, g, b);
    sgl_v2f_c3b(x + s, y - s, r, g, b);
    sgl_v2f_c3b(x - s, y - s, r, g, b);
}

void cleanup() {
    simgui_shutdown();
    sgl_shutdown();
    sg_shutdown();
}

void input(sapp_event* ev) {
    simgui_handle_event(ev);
}

u8* anchor_getter(void* userdata, i32 index) {
    ignore userdata;
    return state.anchors[index].label;
}

void draw_ui() {
    simgui_new_frame(&simgui_frame_desc_t{
        .width = sapp_width(),
        .height = sapp_height(),
        .delta_time = sapp_frame_duration(),
        .dpi_scale = sapp_dpi_scale(),
    });
    ImGui_SetNextWindowPos(ImVec2{30.0f, 50.0f}, ImGuiCond_Once);
    ImGui_SetNextWindowBgAlpha(0.75f);
    if ImGui_Begin("Controls", null, ImGuiWindowFlags_NoDecoration | ImGuiWindowFlags_AlwaysAutoResize) != 0 {
        ImGui_Text("Resize app window!\n");
        ImGui_SliderFloat("Content Aspect Ratio", &state.lbox.content_aspect_ratio, 0.5f, 2.0f);
        if ImGui_Combo("Anchor", &state.cur_anchor_idx, cast(fn(void*, i32): u8*, anchor_getter), null, 5) != 0 {
            state.lbox.anchor = state.anchors[state.cur_anchor_idx].anchor;
        }
        ImGui_SeparatorText("Border");
        ImGui_Checkbox("Link Left/Right", &state.link_lr_border);
        if ImGui_SliderInt("Left", &state.lbox.border.left, -50, 50) && state.link_lr_border {
            state.lbox.border.right = state.lbox.border.left;
        }
        if ImGui_SliderInt("Right", &state.lbox.border.right, -50, 50) && state.link_lr_border {
            state.lbox.border.left = state.lbox.border.right;
        }
        ImGui_Checkbox("Link Top/Bottom", &state.link_tb_border);
        if ImGui_SliderInt("Top", &state.lbox.border.top, -50, 50) && state.link_tb_border {
            state.lbox.border.bottom = state.lbox.border.top;
        }
        if ImGui_SliderInt("Bottom", &state.lbox.border.bottom, -50, 50) && state.link_tb_border {
            state.lbox.border.top = state.lbox.border.bottom;
        }
    }
    ImGui_End();
}
}

sapp_desc __sapp_sample_main() {
    return sapp_desc{
        .init_cb = init,
        .frame_cb = frame,
        .cleanup_cb = cleanup,
        .event_cb = input,
        .width = 800,
        .height = 600,
        .window_title = "letterbox-sapp.mc",
        .icon = sapp_icon_desc{.sokol_default = true},
        .logger = sapp_logger{.func = slog_func},
    };
}
