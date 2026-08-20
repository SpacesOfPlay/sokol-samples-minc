import dbgui;
import sokol_debugtext;
import sokol_gl;

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
    sgl_pipeline sgl_pip;
}

private {
state_t state;

void init() {
    sg_setup(&sg_desc{.environment = sglue_environment(), .logger = sg_logger{.func = slog_func}});
    __dbgui_setup();
    sdtx_setup(&sdtx_desc_t{.fonts[0] = sdtx_font_cpc(), .logger = sdtx_logger_t{.func = slog_func}});
    sgl_setup(&sgl_desc_t{.logger = sgl_logger_t{.func = slog_func}});
    state.pass_action = sg_pass_action{
        .colors[0] = {.load_action = SG_LOADACTION_CLEAR, .clear_value = {0.0f, 0.0f, 0.0f, 1.0f}},
    };
    state.sgl_pip = sgl_make_pipeline(&sg_pipeline_desc{
        .depth = sg_depth_state{.write_enabled = false},
        .colors[0] = {
            .blend = {
                .enabled = true,
                .src_factor_rgb = SG_BLENDFACTOR_SRC_ALPHA,
                .dst_factor_rgb = SG_BLENDFACTOR_ONE_MINUS_SRC_ALPHA,
            },
        },
    });
}

void frame() {
    sdtx_canvas(64.0f, 48.0f);
    sdtx_font(0);
    sdtx_color3b(255, 255, 255);
    sdtx_home();
    for i32 i = 0; i < 3; i++ {
        sdtx_layer(i);
        sdtx_pos(0.5f, 0.5f + 2.0f * cast(f32, i));
        sdtx_printf("Layer %d", i);
    }
    f32 h = 2.0f / cast(f32, 3);
    sgl_defaults();
    sgl_load_pipeline(state.sgl_pip);
    for i32 i = 0; i <= 3; i++ {
        f32 y0 = 1.0f - cast(f32, i) * h + h * 0.5f;
        f32 y1 = y0 - h;
        sgl_layer(i);
        switch i {
            case 0: {
                sgl_c4b(255, 0, 0, 160);
            }
            case 1: {
                sgl_c4b(0, 255, 0, 160);
            }
            case 2: {
                sgl_c4b(0, 0, 255, 160);
            }
            default: {
                sgl_c4b(255, 0, 0, 160);
            }
        }
        sgl_begin_quads();
        sgl_v2f(-1.0f, y0);
        sgl_v2f(1.0f, y0);
        sgl_v2f(1.0f, y1);
        sgl_v2f(-1.0f, y1);
        sgl_end();
    }
    sg_begin_pass(&sg_pass{.action = state.pass_action, .swapchain = sglue_swapchain()});
    for i32 i = 0; i < 3; i++ {
        sgl_draw_layer(i);
        sdtx_draw_layer(i);
    }
    sgl_draw_layer(3);
    __dbgui_draw();
    sg_end_pass();
    sg_commit();
}

void cleanup() {
    sgl_shutdown();
    sdtx_shutdown();
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
        .window_title = "debugtext-layers-sapp.mc",
        .icon = sapp_icon_desc{.sokol_default = true},
        .logger = sapp_logger{.func = slog_func},
    };
}
