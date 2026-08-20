import dbgui;

import sokol_all;
import math;

// force high-dpi, sample entry point is __sapp_sample_main()
sapp_desc sokol_main() {
    sapp_desc d = __sapp_sample_main();
    d.high_dpi = true;
    return d;
}

sg_pass_action pass_action;

private {
void init() {
    sg_setup(&sg_desc{.environment = sglue_environment(), .logger = sg_logger{.func = slog_func}});
    pass_action = sg_pass_action{
        .colors[0] = {.load_action = SG_LOADACTION_CLEAR, .clear_value = {1.0f, 0.0f, 0.0f, 1.0f}},
    };
    __dbgui_setup();
}

void frame() {
    f32 g = pass_action.colors[0].clear_value.g + 0.01f;
    pass_action.colors[0].clear_value.g = g > 1.0f ? 0.0f : g;
    sg_begin_pass(&sg_pass{.action = pass_action, .swapchain = sglue_swapchain()});
    __dbgui_draw();
    sg_end_pass();
    sg_commit();
}

void cleanup() {
    __dbgui_shutdown();
    sg_shutdown();
}
}

sapp_desc __sapp_sample_main() {
    return sapp_desc{
        .init_cb = init,
        .frame_cb = frame,
        .cleanup_cb = cleanup,
        .event_cb = __dbgui_event,
        .width = 400,
        .height = 300,
        .window_title = "clear-sapp.mc",
        .depth_format = SAPP_PIXELFORMAT_NONE,
        .icon = sapp_icon_desc{.sokol_default = true},
        .logger = sapp_logger{.func = slog_func},
    };
}
