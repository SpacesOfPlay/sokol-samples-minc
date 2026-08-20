import dbgui;
import imgui_compat;
import sokol_time;

// sapp samples that use Dear ImGui
import sokol_all;
import imgui;
import sokol_imgui;
import math;

// Keeps upstream's high_dpi default (off, so sapp_dpi_scale() is 1 and
// framebuffer pixels equal ImGui points). For samples that feed
// sapp_width()/sapp_height() straight into ImGui coordinates; with
// high-dpi on, io.DisplaySize is width / dpi_scale and those windows
// land off-screen toward the bottom right.
sapp_desc sokol_main() {
    return __sapp_sample_main();
}

private struct state_t {
    u64 last_time;
    i32 num_windows;
    f64 min_raw_frame_time;
    f64 max_raw_frame_time;
    f64 min_rounded_frame_time;
    f64 max_rounded_frame_time;
    f32 counter;
    sg_pass_action pass_action;
}

private {
i32 max_windows = 128;
state_t state = state_t{
    .num_windows = 16,
    .pass_action = sg_pass_action{
        .colors[0] = {.load_action = SG_LOADACTION_CLEAR, .clear_value = {0.0f, 0.5f, 0.7f, 1.0f}},
    },
};

void reset_minmax_frametimes() {
    state.max_raw_frame_time = 0.0;
    state.min_raw_frame_time = 1000.0;
    state.max_rounded_frame_time = 0.0;
    state.min_rounded_frame_time = 1000.0;
}

void init() {
    sg_setup(&sg_desc{.environment = sglue_environment(), .logger = sg_logger{.func = slog_func}});
    stm_setup();
    simgui_setup(&simgui_desc_t{.logger = simgui_logger_t{.func = slog_func}});
    reset_minmax_frametimes();
}

void frame() {
    i32 width = sapp_width();
    i32 height = sapp_height();
    var fwidth = cast(f32, width);
    var fheight = cast(f32, height);
    f64 raw_frame_time = stm_sec(stm_laptime(&state.last_time));
    f64 rounded_frame_time = sapp_frame_duration();
    if raw_frame_time > 0.0 {
        if raw_frame_time < state.min_raw_frame_time {
            state.min_raw_frame_time = raw_frame_time;
        }
        if raw_frame_time > state.max_raw_frame_time {
            state.max_raw_frame_time = raw_frame_time;
        }
    }
    if rounded_frame_time > 0.0 {
        if rounded_frame_time < state.min_rounded_frame_time {
            state.min_rounded_frame_time = rounded_frame_time;
        }
        if rounded_frame_time > state.max_rounded_frame_time {
            state.max_rounded_frame_time = rounded_frame_time;
        }
    }
    simgui_new_frame(&simgui_frame_desc_t{
        .width = width,
        .height = height,
        .delta_time = rounded_frame_time,
        .dpi_scale = sapp_dpi_scale(),
    });
    ImGui_SetNextWindowPos(ImVec2{10.0f, 10.0f}, ImGuiCond_Once);
    ImGui_SetNextWindowSize(ImVec2{500.0f, 0.0f}, ImGuiCond_Once);
    ImGui_Begin("Controls", null, ImGuiWindowFlags_NoResize | ImGuiWindowFlags_NoScrollbar);
    ImGui_SliderInt("Num Windows", &state.num_windows, 1, max_windows);
    ImGui_Text("raw frame time:     %.3fms (min: %.3f, max: %.3f)", raw_frame_time * 1000.0, state.min_raw_frame_time * 1000.0, state.max_raw_frame_time * 1000.0);
    ImGui_Text("rounded frame time: %.3fms (min: %.3f, max: %.3f)", rounded_frame_time * 1000.0, state.min_rounded_frame_time * 1000.0, state.max_rounded_frame_time * 1000.0);
    if ImGui_Button("Reset min/max times") != 0 {
        reset_minmax_frametimes();
    }
    ImGui_End();
    state.counter += 1.0f;
    for i32 i = 0; i < state.num_windows; i++ {
        f32 t = state.counter + cast(f32, i) * 2.0f;
        f32 r = cast(f32, i) / cast(f32, max_windows);
        f32 x = fwidth * (0.5f + r * 0.5f * 0.75f * sinf(t * 0.05f));
        f32 y = fheight * (0.5f + r * 0.5f * 0.75f * cosf(t * 0.05f));
        noinit u8[64] name;
        snprintf(name, sizeof(name), "Hello ImGui %d", i);
        ImGui_SetNextWindowPos(ImVec2{x, y}, ImGuiCond_Always);
        ImGui_SetNextWindowSize(ImVec2{100.0f, 10.0f}, ImGuiCond_Always);
        ImGui_Begin(name, null, ImGuiWindowFlags_NoResize | ImGuiWindowFlags_NoScrollbar | ImGuiWindowFlags_NoFocusOnAppearing);
        ImGui_End();
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

void input(sapp_event* ev) {
    simgui_handle_event(ev);
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
        .depth_format = SAPP_PIXELFORMAT_NONE,
        .window_title = "imgui-perf-sapp.mc",
        .icon = sapp_icon_desc{.sokol_default = true},
        .logger = sapp_logger{.func = slog_func},
    };
}
