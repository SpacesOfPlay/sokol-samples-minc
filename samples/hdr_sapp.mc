import dbgui;

import sokol_all;
import math;

// force high-dpi, sample entry point is __sapp_sample_main()
sapp_desc sokol_main() {
    sapp_desc d = __sapp_sample_main();
    d.high_dpi = true;
    return d;
}

// hdr-sapp.glsl - ported to minc @shader.

struct HdrSappVsOut {
    float4 pos;
    float4 color;
}

@shader vertex
HdrSappVsOut hdr_sapp_vs() {
    HdrSappVsOut o;
    float4[3] colors = {
        float4{1.0f, 0.0f, 0.0f, 1.0f},
        float4{0.0f, 1.0f, 0.0f, 1.0f},
        float4{0.0f, 0.0f, 1.0f, 1.0f},
    };
    float2[3] positions = {
        float2{0.0f, 0.5f},
        float2{0.4f, -0.5f},
        float2{-0.4f, -0.5f},
    };
    float2 pos;
    float4 c;
    if vertex_id() < 3 {
        pos = positions[vertex_id()];
        c = colors[vertex_id()];
        pos.x -= 0.5f;
    } else {
        pos = positions[vertex_id() - 3];
        c = colors[vertex_id() - 3];
        c = float4{c.x * 4.0f, c.y * 4.0f, c.z * 4.0f, c.w};
        pos.x += 0.5f;
    }
    o.pos = float4{pos.x, pos.y, 0.0f, 1.0f};
    o.color = c;
    return o;
}

@shader fragment
float4 hdr_sapp_fs(
HdrSappVsOut input
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

private {
state_t state;

void init() {
    sg_setup(&sg_desc{.environment = sglue_environment(), .logger = sg_logger{.func = slog_func}});
    __dbgui_setup();
    sg_shader shd = sokol_make_shader(&hdr_sapp_vs_shader, &hdr_sapp_fs_shader);
    state.pip = sg_make_pipeline(&sg_pipeline_desc{.shader = shd});
    state.pass_action = sg_pass_action{
        .colors[0] = {.load_action = SG_LOADACTION_CLEAR, .clear_value = {0.0f, 0.0f, 0.0f, 1.0f}},
    };
}

void frame() {
    sg_begin_pass(&sg_pass{.action = state.pass_action, .swapchain = sglue_swapchain()});
    sg_apply_pipeline(state.pip);
    sg_draw(0, 6, 1);
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
        .width = 640,
        .height = 480,
        .hdr = true,
        .depth_format = SAPP_PIXELFORMAT_NONE,
        .window_title = "triangle-bufferless-sapp.mc",
        .icon = sapp_icon_desc{.sokol_default = true},
        .logger = sapp_logger{.func = slog_func},
    };
}
