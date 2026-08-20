import dbgui;
import imgui_compat;
import sokol_fetch;

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

enum loadstate_t {
    LOADSTATE_UNKNOWN = 0,
    LOADSTATE_SUCCESS = 1,
    LOADSTATE_FAILED = 2,
    LOADSTATE_FILE_TOO_BIG = 3,
}

private struct state_t {
    loadstate_t load_state;
    i32 size;
    u8[1048576] buffer;
}

private {
state_t state;

void init() {
    sg_setup(&sg_desc{.environment = sglue_environment(), .logger = sg_logger{.func = slog_func}});
    simgui_setup(&simgui_desc_t{.logger = simgui_logger_t{.func = slog_func}});
    sfetch_setup(&sfetch_desc_t{
        .num_channels = 1,
        .num_lanes = 1,
        .logger = sfetch_logger_t{.func = slog_func},
    });
}

// render the loaded file content as hex view
void render_file_content() {
    i32 bytes_per_line = 16;
    i32 num_lines = (state.size + (bytes_per_line - 1)) / bytes_per_line;
    f32 cw = ImGui_CalcTextSize(" ").x;
    ImGui_BeginChild("##scrolling", ImVec2{0.0f, 0.0f}, ImGuiChildFlags_None, ImGuiWindowFlags_NoMove | ImGuiWindowFlags_NoNav);
    ImGuiListClipper clipper;
    ImGuiListClipper_Begin(&clipper, num_lines, ImGui_GetTextLineHeight());
    ImGuiListClipper_Step(&clipper);
    for i32 line_i = clipper.DisplayStart; line_i < clipper.DisplayEnd; line_i++ {
        i32 start_offset = line_i * bytes_per_line;
        i32 end_offset = start_offset + bytes_per_line;
        if end_offset >= state.size {
            end_offset = state.size;
        }
        ImGui_Text("%04X: ", start_offset);
        for i32 i = start_offset; i < end_offset; i++ {
            ImGui_SameLine(0.0f, 0.0f);
            ImGui_Text("%02X ", state.buffer[i]);
        }
        ImGui_SameLine(6.0f * cw + cast(f32, bytes_per_line * 3) * cw + 2.0f * cw, 0.0f);
        for i32 i = start_offset; i < end_offset; i++ {
            if i != start_offset {
                ImGui_SameLine(0.0f, 0.0f);
            }
            u8 c = state.buffer[i];
            if c < 32 || c > 127 {
                c = 46;
            }
            ImGui_Text("%c", c);
        }
    }
    ImGui_Text("EOF\n");
    ImGuiListClipper_End(&clipper);
    ImGui_EndChild();
}

void frame() {
    sfetch_dowork();
    i32 width = sapp_width();
    i32 height = sapp_height();
    simgui_new_frame(&simgui_frame_desc_t{
        .width = width,
        .height = height,
        .delta_time = sapp_frame_duration(),
        .dpi_scale = sapp_dpi_scale(),
    });
    ImGui_SetNextWindowPos(ImVec2{10.0f, 10.0f}, ImGuiCond_Once);
    ImGui_SetNextWindowSize(ImVec2{600.0f, 500.0f}, ImGuiCond_Once);
    ImGui_Begin("Drop a file!", null, 0);
    if state.load_state != LOADSTATE_UNKNOWN {
        ImGui_Text("%s:", sapp_get_dropped_file_path(0));
    }
    switch state.load_state {
        case LOADSTATE_FAILED: {
            ImGui_Text("LOAD FAILED!");
        }
        case LOADSTATE_FILE_TOO_BIG: {
            ImGui_Text("FILE TOO BIG!");
        }
        case LOADSTATE_SUCCESS: {
            ImGui_Separator();
            render_file_content();
        }
        default: {
        }
    }
    ImGui_End();
    sg_begin_pass(&sg_pass{.swapchain = sglue_swapchain()});
    simgui_render();
    sg_end_pass();
    sg_commit();
}

void cleanup() {
    sfetch_shutdown();
    simgui_shutdown();
    sg_shutdown();
}

// the async-loading callback for native platforms
void native_load_callback(sfetch_response_t* response) {
    if response.fetched != 0 {
        state.load_state = LOADSTATE_SUCCESS;
        state.size = cast(i32, response.data.size);
    } else if response.error_code == SFETCH_ERROR_BUFFER_TOO_SMALL {
        state.load_state = LOADSTATE_FILE_TOO_BIG;
    } else {
        state.load_state = LOADSTATE_FAILED;
    }
}

void input(sapp_event* ev) {
    simgui_handle_event(ev);
    if ev.type == SAPP_EVENTTYPE_FILES_DROPPED {
        sfetch_send(&sfetch_request_t{
            .path = sapp_get_dropped_file_path(0),
            .callback = native_load_callback,
            .buffer = sfetch_range_t{&state.buffer, sizeof(state.buffer)},
        });
    }
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
        .window_title = "droptest-sapp.mc",
        .depth_format = SAPP_PIXELFORMAT_NONE,
        .enable_dragndrop = true,
        .max_dropped_files = 1,
        .icon = sapp_icon_desc{.sokol_default = true},
        .logger = sapp_logger{.func = slog_func},
    };
}
