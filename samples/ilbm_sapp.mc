import dbgui;
import imgui_compat;
import sapp_util;
import sokol_fetch;
import sokol_gfx_imgui;
import sokol_app_imgui;
import sokol_framebuffer;
import sokol_letterbox;
import ilbm;

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
    sfb_framebuffer fb;
    ilbm_t ilbm;
    struct {
        bool pending;
        bool success;
        bool failed;
    } load;
    struct {
        i32 selected;
        bool allow_color_cycling;
    } ui;
}

private {
u8*[10] files = {
    "celtic_woman.iff", "venus.iff", "eye.iff", "eiffel_tower.iff", "kingtut.iff", "gorilla.iff",
    "paintcan.iff", "space.iff", "waterfall.iff", "yacht.iff",
};
u8*[10] artists = {
    "Avril Harrison (1985)", "Avril Harrison (1988)", "Avril Harrison (1986)",
    "Avril Harrison (1986)", "Avril Harrison (1985)", "Greg Johnson (1985)", "Greg Johnson (1985)",
    "Unknown (1989)", "Unknown (1989)", "Unknown (1989)",
};
// some of the images have active CRNG chunks even though
// no color cycling is intended for these images
bool[10] allow_color_cyling = {false, false, false, false, false, false, false, true, true, true};
state_t state;
u8[131072] file_buffer;
}

private {
void init() {
    sg_setup(&sg_desc{.environment = sglue_environment(), .logger = sg_logger{.func = slog_func}});
    sfetch_setup(&sfetch_desc_t{
        .num_channels = 1,
        .num_lanes = 1,
        .max_requests = 1,
        .logger = sfetch_logger_t{.func = slog_func},
    });
    sgimgui_setup(&sgimgui_desc_t{});
    sappimgui_setup();
    simgui_setup(&simgui_desc_t{.logger = simgui_logger_t{.func = slog_func}});
    sfb_setup(&sfb_desc{.logger = sfb_logger{.func = slog_func}});
    fetch_async(files[0]);
}

void frame() {
    sfetch_dowork();
    draw_ui();
    if state.load.success && state.ui.allow_color_cycling && ilbm_color_cycle(&state.ilbm, sapp_frame_duration()) {
        sfb_update(state.fb, &sfb_update_desc{.palette = sg_range{&state.ilbm.colors, sizeof(state.ilbm.colors)}});
    }
    sg_begin_pass(&sg_pass{
        .action = sg_pass_action{
            .colors[0] = {.load_action = SG_LOADACTION_CLEAR, .clear_value = {.a = 1.0f}},
        },
        .swapchain = sglue_swapchain(),
    });
    if state.load.success != 0 {
        slbx_viewport vp = slbx_letterbox(sapp_width(), sapp_height(), &slbx_letterbox_desc{
            .content_aspect_ratio = state.ilbm.aspect_ratio,
            .border = slbx_border{.top = 26, .left = 10, .right = 10, .bottom = 10},
        });
        sg_apply_viewport(vp.x, vp.y, vp.width, vp.height, true);
        sfb_render(state.fb);
        sg_apply_viewport(0, 0, sapp_width(), sapp_height(), true);
    }
    simgui_render();
    sg_end_pass();
    sg_commit();
}

void cleanup() {
    ilbm_free(&state.ilbm);
    sfb_shutdown();
    sappimgui_shutdown();
    sgimgui_shutdown();
    simgui_shutdown();
    sfetch_shutdown();
    sg_shutdown();
}

void input(sapp_event* ev) {
    sappimgui_track_event(ev);
    simgui_handle_event(ev);
}

void draw_ui() {
    sappimgui_track_frame();
    simgui_new_frame(&simgui_frame_desc_t{
        .width = sapp_width(),
        .height = sapp_height(),
        .delta_time = sapp_frame_duration(),
        .dpi_scale = sapp_dpi_scale(),
    });
    if ImGui_BeginMainMenuBar() != 0 {
        sgimgui_draw_menu("sokol-gfx");
        sappimgui_draw_menu("sokol-app");
        ImGui_EndMainMenuBar();
    }
    sgimgui_draw();
    sappimgui_draw();
    ImGui_SetNextWindowPos(ImVec2{30.0f, 50.0f}, ImGuiCond_Once);
    ImGui_SetNextWindowBgAlpha(0.75f);
    if ImGui_Begin("Controls", null, ImGuiWindowFlags_NoDecoration | ImGuiWindowFlags_AlwaysAutoResize) != 0 {
        if state.load.pending != 0 {
            ImGui_Text("Loading...");
        } else {
            if state.load.failed != 0 {
                ImGui_Text("Loading failed!");
            }
            if ImGui_Combo("Image", &state.ui.selected, files, cast(i32, sizeof(files) / sizeof(*files))) != 0 {
                state.ui.allow_color_cycling = allow_color_cyling[state.ui.selected];
                fetch_async(files[state.ui.selected]);
            }
            ImGui_Text("Artist: %s", artists[state.ui.selected]);
            ImGui_Text("Width: %d", state.ilbm.width);
            ImGui_Text("Height: %d", state.ilbm.height);
            ImGui_Text("Colors: %d", state.ilbm.num_colors);
            ImGui_Checkbox("Allow Color Cycling", &state.ui.allow_color_cycling);
        }
    }
    ImGui_End();
}

void fetch_async(u8* filename) {
    state.load.pending = true;
    state.load.success = false;
    state.load.failed = false;
    noinit u8[512] path_buf;
    sfetch_send(&sfetch_request_t{
        .path = fileutil_get_path(filename, path_buf, cast(u64, sizeof(path_buf))),
        .callback = fetch_callback,
        .buffer = sfetch_range_t{&file_buffer, sizeof(file_buffer)},
    });
}

void fetch_callback(sfetch_response_t* response) {
    if response.fetched != 0 {
        state.load.pending = false;
        sfb_destroy_framebuffer(state.fb);
        ilbm_free(&state.ilbm);
        state.load.success = ilbm_load(&state.ilbm, ilbm_range_t{.ptr = response.data.ptr, .size = response.data.size});
        if state.load.success != 0 {
            state.fb = sfb_make_framebuffer(&sfb_framebuffer_desc{
                .width = state.ilbm.width,
                .height = state.ilbm.height,
                .format = SFB_FORMAT_PALETTE8,
                .prescale = 2,
            });
            sfb_update(state.fb, &sfb_update_desc{
                .pixels = sg_range{.ptr = state.ilbm.pixels.ptr, .size = state.ilbm.pixels.size},
                .palette = sg_range{&state.ilbm.colors, sizeof(state.ilbm.colors)},
            });
        } else {
            state.load.failed = true;
        }
    } else if response.failed != 0 {
        state.load.pending = false;
        state.load.failed = true;
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
        .depth_format = SAPP_PIXELFORMAT_NONE,
        .window_title = "ilbm-sapp.mc",
        .icon = sapp_icon_desc{.sokol_default = true},
        .logger = sapp_logger{.func = slog_func},
    };
}
