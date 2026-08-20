import dbgui;
import imgui_compat;

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

struct state_t {
    u64 last_time;
    bool show_test_window;
    bool show_another_window;
    sg_pass_action pass_action;
}

private {
state_t state;

void init() {
    sg_setup(&sg_desc{.environment = sglue_environment(), .logger = sg_logger{.func = slog_func}});
    simgui_setup(&simgui_desc_t{.logger = simgui_logger_t{.func = slog_func}});
    state = state_t{
        .show_test_window = true,
        .pass_action = sg_pass_action{
            .colors[0] = {
                .load_action = SG_LOADACTION_CLEAR,
                .clear_value = {0.7f, 0.5f, 0.0f, 1.0f},
            },
        },
    };
}

void frame() {
    i32 width = sapp_width();
    i32 height = sapp_height();
    simgui_new_frame(&simgui_frame_desc_t{
        .width = width,
        .height = height,
        .delta_time = sapp_frame_duration(),
        .dpi_scale = sapp_dpi_scale(),
    });
    ImGui_Text("Hello, world!");
    ImGui_SliderFloat("float", &frame__f, 0.0f, 1.0f, "%.3f", ImGuiSliderFlags_None);
    ImGui_ColorEdit3("clear color", cast(f32*, &state.pass_action.colors[0].clear_value), 0);
    if ImGui_Button("Test Window") != 0 {
        state.show_test_window = (cast(i32, state.show_test_window) ^ 1) != 0;
    }
    if ImGui_Button("Another Window") != 0 {
        state.show_another_window = (cast(i32, state.show_another_window) ^ 1) != 0;
    }
    ImGui_Text("Application average %.3f ms/frame (%.1f FPS)", 1000.0f / ImGui_GetIO().Framerate, ImGui_GetIO().Framerate);
    if state.show_another_window != 0 {
        ImGui_SetNextWindowSize(ImVec2{200.0f, 100.0f}, ImGuiCond_FirstUseEver);
        ImGui_Begin("Another Window", &state.show_another_window, 0);
        ImGui_Text("Hello");
        ImGui_End();
    }
    if state.show_test_window != 0 {
        ImGui_SetNextWindowPos(ImVec2{460.0f, 20.0f}, ImGuiCond_FirstUseEver);
        ImGui_ShowDemoWindow(null);
    }
    sg_begin_pass(&sg_pass{.action = state.pass_action, .swapchain = sglue_swapchain()});
    simgui_render();
    sg_end_pass();
    sg_commit();
}

void cleanup() {
    simgui_shutdown();
    sg_shutdown();
}

void input(sapp_event* event) {
    simgui_handle_event(event);
}
}

sapp_desc __sapp_sample_main() {
    return sapp_desc{
        .init_cb = init,
        .frame_cb = frame,
        .cleanup_cb = cleanup,
        .event_cb = input,
        .width = 1024,
        .height = 768,
        .depth_format = SAPP_PIXELFORMAT_NONE,
        .window_title = "cimgui-sapp.mc",
        .ios = sapp_ios_desc{.keyboard_resizes_canvas = false},
        .icon = sapp_icon_desc{.sokol_default = true},
        .enable_clipboard = true,
        .logger = sapp_logger{.func = slog_func},
    };
}
private { f32 frame__f = 0.0f; }
