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

private struct state_t {
    sg_pass_action pass_action;
}

private {
state_t state = state_t{
    .pass_action = sg_pass_action{
        .colors[0] = {
            .load_action = SG_LOADACTION_CLEAR,
            .clear_value = {0.0f, 0.125f, 0.25f, 1.0f},
        },
    },
};

void init() {
    sg_setup(&sg_desc{.environment = sglue_environment(), .logger = sg_logger{.func = slog_func}});
    __dbgui_setup();
    sdtx_setup(&sdtx_desc_t{
        .fonts = {
            sdtx_font_kc853(),
            sdtx_font_kc854(),
            sdtx_font_z1013(),
            sdtx_font_cpc(),
            sdtx_font_c64(),
            sdtx_font_oric(),
            sdtx_font_desc_t{},
            sdtx_font_desc_t{},
        },
        .logger = sdtx_logger_t{.func = slog_func},
    });
}

void print_font(i32 font_index, u8* title, u8 r, u8 g, u8 b) {
    sdtx_font(font_index);
    sdtx_color3b(r, g, b);
    sdtx_puts(title);
    for i32 c = 32; c < 256; c++ {
        sdtx_putc(cast(u8, c));
        if (c + 1 & 63) == 0 {
            sdtx_crlf();
        }
    }
    sdtx_crlf();
}

void frame() {
    sdtx_canvas(cast(f32, sapp_width()) * 0.5f, cast(f32, sapp_height()) * 0.5f);
    sdtx_origin(0.0f, 2.0f);
    sdtx_home();
    print_font(0, "KC85/3:\n", 0xf4, 0x43, 0x36);
    print_font(1, "KC85/4:\n", 0x21, 0x96, 0xf3);
    print_font(2, "Z1013:\n", 0x4c, 0xaf, 0x50);
    print_font(3, "Amstrad CPC:\n", 0xff, 0xeb, 0x3b);
    print_font(4, "C64:\n", 0x79, 0x86, 0xcb);
    print_font(5, "Oric Atmos:\n", 0xff, 0x98, 0x00);
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
        .width = 1024,
        .height = 600,
        .depth_format = SAPP_PIXELFORMAT_NONE,
        .window_title = "debugtext-sapp.mc",
        .icon = sapp_icon_desc{.sokol_default = true},
        .logger = sapp_logger{.func = slog_func},
    };
}
