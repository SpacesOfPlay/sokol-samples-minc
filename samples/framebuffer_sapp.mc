import dbgui;
import vecmath;
import sokol_framebuffer;

import sokol_all;
import math;

// force high-dpi, sample entry point is __sapp_sample_main()
sapp_desc sokol_main() {
    sapp_desc d = __sapp_sample_main();
    d.high_dpi = true;
    return d;
}

type __arr_u32_320 = u32[320];
private struct state_t {
    sfb_framebuffer fb;
    f32 time;
}

private {
state_t state;
__arr_u32_320[256] pixels;

void init() {
    sg_setup(&sg_desc{.environment = sglue_environment(), .logger = sg_logger{.func = slog_func}});
    __dbgui_setup();
    sfb_setup(&sfb_desc{.logger = sfb_logger{.func = slog_func}});
    state.fb = sfb_make_framebuffer(&sfb_framebuffer_desc{.width = 320, .height = 256});
}

void frame() {
    state.time = fmodf(state.time + cast(f32, sapp_frame_duration()), 3600.0f);
    for i32 y = 0; y < 256; y++ {
        for i32 x = 0; x < 320; x++ {
            f32 t3 = state.time * 0.6f;
            vec2_t coord = vec2(cast(f32, x * 2), cast(f32, y * 2));
            f32 color1 = (sinf(vec2_dot(coord, vec2(sinf(t3), cosf(t3))) * 0.02f + t3) + 1.0f) * 0.5f;
            vec2_t center = vec2_add(vec2(320.0f, 180.0f), vec2(320.0f * sinf(-t3), 180.0f * cosf(-t3)));
            f32 color2 = (cosf(vec2_length(vec2_sub(coord, center)) * 0.03f) + 1.0f) * 0.5f;
            f32 color = color1 + color2;
            f32 rf = (cosf(3.141592654f * color + t3) + 1.0f) * 0.5f;
            f32 gf = (sinf(3.141592654f * color + t3) + 1.0f) * 0.5f;
            f32 bf = (sinf(t3) + 1.0f) * 0.5f;
            var ru8 = cast(u8, rf * 255.0f);
            var gu8 = cast(u8, gf * 255.0f);
            var bu8 = cast(u8, bf * 255.0f);
            pixels[y][x] = cast(u32, 0xFF000000 | cast(i32, bu8) << 16 | cast(i32, gu8) << 8 | ru8);
        }
    }
    sfb_update(state.fb, &sfb_update_desc{.pixels = sg_range{&pixels, sizeof(pixels)}});
    sg_begin_pass(&sg_pass{
        .action = sg_pass_action{.colors[0] = {.load_action = SG_LOADACTION_DONTCARE}},
        .swapchain = sglue_swapchain(),
    });
    sfb_render(state.fb);
    __dbgui_draw();
    sg_end_pass();
    sg_commit();
}

void cleanup() {
    sfb_shutdown();
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
        .width = 800,
        .height = 600,
        .window_title = "framebuffer-sapp.mc",
        .icon = sapp_icon_desc{.sokol_default = true},
        .logger = sapp_logger{.func = slog_func},
    };
}
