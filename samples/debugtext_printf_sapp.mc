import dbgui;
import sokol_debugtext;

import sokol_all;
import math;

// force high-dpi, sample entry point is __sapp_sample_main()
sapp_desc sokol_main() {
    sapp_desc d = __sapp_sample_main();
    d.high_dpi = true;
    return d;
}

struct color_t {
    u8 r;
    u8 g;
    u8 b;
}

private struct state_t {
    sg_pass_action pass_action;
    color_t[3] palette;
}

private {
state_t state = state_t{
    .pass_action = sg_pass_action{
        .colors[0] = {
            .load_action = SG_LOADACTION_CLEAR,
            .clear_value = {0.0f, 0.125f, 0.25f, 1.0f},
        },
    },
    .palette = {color_t{0xf4, 0x43, 0x36}, color_t{0x21, 0x96, 0xf3}, color_t{0x4c, 0xaf, 0x50}},
};

void init() {
    sg_setup(&sg_desc{.environment = sglue_environment(), .logger = sg_logger{.func = slog_func}});
    __dbgui_setup();
    sdtx_setup(&sdtx_desc_t{
        .fonts = {
            sdtx_font_kc854(),
            sdtx_font_c64(),
            sdtx_font_oric(),
            sdtx_font_desc_t{},
            sdtx_font_desc_t{},
            sdtx_font_desc_t{},
            sdtx_font_desc_t{},
            sdtx_font_desc_t{},
        },
        .logger = sdtx_logger_t{.func = slog_func},
    });
}

void my_printf_wrapper(u8* fmt, ...) {
    sdtx_vprintf(fmt, cast(void*, &...));
}

void frame() {
    var frame_count = cast(u32, sapp_frame_count());
    f64 frame_time = sapp_frame_duration() * 1000.0;
    sdtx_canvas(cast(f32, sapp_width()) * 0.5f, cast(f32, sapp_height()) * 0.5f);
    sdtx_origin(3.0f, 3.0f);
    for i32 i = 0; i < 3; i++ {
        color_t color = state.palette[i];
        sdtx_font(i);
        sdtx_color3b(color.r, color.g, color.b);
        sdtx_printf("Hello '%s'!\n", (frame_count & cast(u32, 1 << 7)) != 0 ? "Welt" : "World");
        sdtx_printf("\tFrame Time:\t\t%.3f\n", frame_time);
        my_printf_wrapper("\tFrame Count:\t%d\t0x%04X\n", frame_count, frame_count);
        sdtx_putr("Range Test 1(xyzbla)", 12);
        sdtx_putr("\nRange Test 2\n", 32);
        sdtx_move_y(2.0f);
    }
    sg_begin_pass(&sg_pass{.action = state.pass_action, .swapchain = sglue_swapchain()});
    sdtx_draw();
    __dbgui_draw();
    sg_end_pass();
    sg_commit();
}

void cleanup() {
    sdtx_shutdown();
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
        .width = 640,
        .height = 480,
        .depth_format = SAPP_PIXELFORMAT_NONE,
        .window_title = "debugtext-printf-sapp.mc",
        .icon = sapp_icon_desc{.sokol_default = true},
        .logger = sapp_logger{.func = slog_func},
    };
}
