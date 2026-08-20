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

enum iconmode_t {
    ICONMODE_NONE = 0,
    ICONMODE_DEFAULT = 1,
    ICONMODE_USER = 2,
    NUM_ICONMODES = 3,
}

private struct state_t {
    bool icon_mode_changed;
    iconmode_t icon_mode;
    sg_pass_action pass_action;
}

private {
u8*[3] help_text = {"<NONE>", "1: default icon\n\n", "2: user icon\n\n"};
state_t state = state_t{
    .icon_mode_changed = false,
    .icon_mode = ICONMODE_NONE,
    .pass_action = sg_pass_action{
        .colors[0] = {.load_action = SG_LOADACTION_CLEAR, .clear_value = {0.0f, 0.25f, 0.5f, 1.0f}},
    },
};

void init() {
    sg_setup(&sg_desc{.environment = sglue_environment(), .logger = sg_logger{.func = slog_func}});
    sdtx_setup(&sdtx_desc_t{
        .fonts[0] = sdtx_font_oric(),
        .logger = sdtx_logger_t{.func = slog_func},
    });
}
}

private {
void frame() {
    if state.icon_mode_changed != 0 {
        state.icon_mode_changed = false;
        switch state.icon_mode {
            case ICONMODE_DEFAULT: {
                sapp_set_icon(&sapp_icon_desc{.sokol_default = true});
            }
            case ICONMODE_USER: {
                set_user_icon();
            }
            default: {
            }
        }
    }
    sdtx_canvas(sapp_widthf() * 0.5f, sapp_heightf() * 0.5f);
    sdtx_origin(1.0f, 2.0f);
    sdtx_home();
    sdtx_puts("Press key to switch icon:\n\n\n");
    for i32 i = 0; i < NUM_ICONMODES; i++ {
        if i != ICONMODE_NONE {
            sdtx_puts(i == cast(i32, state.icon_mode) ? "==> " : "    ");
            sdtx_puts(help_text[i]);
        }
    }
    sg_begin_pass(&sg_pass{.action = state.pass_action, .swapchain = sglue_swapchain()});
    sdtx_draw();
    sg_end_pass();
    sg_commit();
}

void input(sapp_event* ev) {
    if ev.type == SAPP_EVENTTYPE_CHAR {
        switch ev.char_code {
            case 49: {
                state.icon_mode_changed = true;
                state.icon_mode = ICONMODE_DEFAULT;
            }
            case 50: {
                state.icon_mode_changed = true;
                state.icon_mode = ICONMODE_USER;
            }
            default: {
            }
        }
    }
}

void cleanup() {
    sdtx_shutdown();
    sg_shutdown();
}

// helper functions for setting up user image icons
void fill_arrow_pixels(u32* pixels, u32 w, u32 h) {
    for u32 y = 0; y < h; y++ {
        for u32 x = 0; x < w; x++ {
            u32 color = fill_arrow_pixels__colors[(x ^ y) >> 1 & 3];
            if y < h / 2 {
                if x < h / 2 - y || x > h / 2 + y {
                    color = 0;
                }
            } else {
                if x < w / 4 || x > w / 4 * 3 {
                    color = 0;
                }
            }
            pixels[y * h + x] = color;
        }
    }
}

void set_user_icon() {
    noinit u32[256] small;
    noinit u32[1024] medium;
    noinit u32[4096] big;
    fill_arrow_pixels(small, 16, 16);
    fill_arrow_pixels(medium, 32, 32);
    fill_arrow_pixels(big, 64, 64);
    sapp_set_icon(&sapp_icon_desc{
        .images = {
            sapp_image_desc{.width = 16, .height = 16, .pixels = sapp_range{&small, sizeof(small)}},
            sapp_image_desc{
                .width = 32,
                .height = 32,
                .pixels = sapp_range{&medium, sizeof(medium)},
            },
            sapp_image_desc{.width = 64, .height = 64, .pixels = sapp_range{&big, sizeof(big)}},
            sapp_image_desc{},
            sapp_image_desc{},
            sapp_image_desc{},
            sapp_image_desc{},
            sapp_image_desc{},
        },
    });
}
}

sapp_desc __sapp_sample_main() {
    return sapp_desc{
        .init_cb = init,
        .frame_cb = frame,
        .event_cb = input,
        .cleanup_cb = cleanup,
        .width = 800,
        .height = 600,
        .depth_format = SAPP_PIXELFORMAT_NONE,
        .window_title = "icon-sapp.mc",
        .logger = sapp_logger{.func = slog_func},
    };
}
private { u32[4] fill_arrow_pixels__colors = {0xFF0000FF, 0xFF00FF00, 0xFFFF0000, 0xFF00FFFF}; }
