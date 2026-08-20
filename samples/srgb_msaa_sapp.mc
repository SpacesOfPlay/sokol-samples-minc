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

// srgb-msaa-sapp.glsl - ported to minc @shader.

struct SrgbMsaaSappVsOut {
    float4 pos;
    float4 color;
}

const float4[3] colors = {
    float4{1.0f, 0.0f, 0.0f, 1.0f},
    float4{0.0f, 1.0f, 0.0f, 1.0f},
    float4{0.0f, 0.0f, 1.0f, 1.0f},
};
const float2[3] positions = {
    float2{0.0f, 0.5f},
    float2{0.5f, -0.5f},
    float2{-0.5f, -0.5f},
};

@shader vertex
SrgbMsaaSappVsOut srgb_msaa_sapp_vs(

) {
    SrgbMsaaSappVsOut o;
    o.pos = float4{positions[vertex_id()], 0.0f, 1.0f};
    o.color = colors[vertex_id()];
    return o;
}

@shader fragment
float4 srgb_msaa_sapp_fs(
SrgbMsaaSappVsOut input
) {
    return input.color;
}


enum __enum___shim_end {
    __shim_end = 255,
}

private struct state_t {
    sg_pipeline pip;
    sg_pass_action pass_action;
}

private { state_t state; }

private {
void init() {
    sg_setup(&sg_desc{.environment = sglue_environment(), .logger = sg_logger{.func = slog_func}});
    __dbgui_setup();
    sdtx_setup(&sdtx_desc_t{
        .fonts[0] = sdtx_font_oric(),
        .logger = sdtx_logger_t{.func = slog_func},
    });
    sg_shader shd = sokol_make_shader(&srgb_msaa_sapp_vs_shader, &srgb_msaa_sapp_fs_shader);
    state.pip = sg_make_pipeline(&sg_pipeline_desc{.shader = shd});
    state.pass_action = sg_pass_action{
        .colors[0] = {
            .load_action = SG_LOADACTION_CLEAR,
            .clear_value = {0.0f, 0.025f, 0.05f, 1.0f},
        },
    };
}

void frame() {
    print_webgl2_note();
    sg_begin_pass(&sg_pass{.action = state.pass_action, .swapchain = sglue_swapchain()});
    sg_apply_pipeline(state.pip);
    sg_draw(0, 3, 1);
    sdtx_draw();
    __dbgui_draw();
    sg_end_pass();
    sg_commit();
}

void cleanup() {
    __dbgui_shutdown();
    sdtx_shutdown();
    sg_shutdown();
}

void print_webgl2_note() {
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
        .srgb = true,
        .sample_count = 4,
        .depth_format = SAPP_PIXELFORMAT_NONE,
        .window_title = "srgb-msaa-sapp.mc",
        .icon = sapp_icon_desc{.sokol_default = true},
        .logger = sapp_logger{.func = slog_func},
    };
}
