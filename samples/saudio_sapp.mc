import dbgui;

import sokol_all;
import math;

// force high-dpi, sample entry point is __sapp_sample_main()
sapp_desc sokol_main() {
    sapp_desc d = __sapp_sample_main();
    d.high_dpi = true;
    return d;
}

// Extra prelude for samples using sokol_audio.h.
import sokol_audio;

private struct state_t {
    sg_pass_action pass_action;
    u32 even_odd;
    i32 sample_pos;
    f32[32] samples;
}

private { state_t state; }

void init() {
    sg_setup(&sg_desc{.environment = sglue_environment(), .logger = sg_logger{.func = slog_func}});
    saudio_setup(&saudio_desc{.logger = saudio_logger{.func = slog_func}});
    state.pass_action = sg_pass_action{
        .colors[0] = {.load_action = SG_LOADACTION_CLEAR, .clear_value = {1.0f, 0.5f, 0.0f, 1.0f}},
    };
}

void frame() {
    sg_begin_pass(&sg_pass{.action = state.pass_action, .swapchain = sglue_swapchain()});
    i32 num_frames = saudio_expect();
    f32 s;
    for i32 i = 0; i < num_frames; i++ {
        if (state.even_odd++ & cast(u32, 1 << 5)) != 0 {
            s = 0.05f;
        } else {
            s = -0.05f;
        }
        state.samples[state.sample_pos++] = s;
        if state.sample_pos == 32 {
            state.sample_pos = 0;
            saudio_push(state.samples, 32);
        }
    }
    sg_end_pass();
    sg_commit();
}

void cleanup() {
    saudio_shutdown();
    sg_shutdown();
}

sapp_desc __sapp_sample_main() {
    return sapp_desc{
        .init_cb = init,
        .frame_cb = frame,
        .cleanup_cb = cleanup,
        .width = 400,
        .height = 300,
        .depth_format = SAPP_PIXELFORMAT_NONE,
        .window_title = "saudio-sapp.mc",
        .icon = sapp_icon_desc{.sokol_default = true},
        .logger = sapp_logger{.func = slog_func},
    };
}
