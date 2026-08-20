import dbgui;

import sokol_all;
import math;

// force high-dpi, sample entry point is __sapp_sample_main()
sapp_desc sokol_main() {
    sapp_desc d = __sapp_sample_main();
    d.high_dpi = true;
    return d;
}

// triangle-sapp.glsl, hand-ported to minc @shader.
// Interface mirrors the sokol-shdc program `triangle`:
//   attrs: position(0), color0(1); no uniform blocks.

struct TriangleVsOut {
    float4 pos;
    float4 color;
}

@shader vertex
TriangleVsOut triangle_sapp_vs(@attr(0) float4 position, @attr(1) float4 color0) {
    TriangleVsOut o;
    o.pos = position;
    o.color = color0;
    return o;
}

@shader fragment
float4 triangle_sapp_fs(TriangleVsOut input) {
    return input.color;
}

enum __enum_ATTR_triangle_position {
    ATTR_triangle_position = 0,
    ATTR_triangle_color0 = 1,
    __shim_end = 255,
}

private struct state_t {
    sg_pipeline pip;
    sg_bindings bind;
    sg_pass_action pass_action;
}

// application state
private {
state_t state;

void init() {
    sg_setup(&sg_desc{.environment = sglue_environment(), .logger = sg_logger{.func = slog_func}});
    __dbgui_setup();
    f32[21] vertices = {
        0.0f, 0.5f, 0.5f, 1.0f, 0.0f, 0.0f, 1.0f, 0.5f, -0.5f, 0.5f, 0.0f, 1.0f, 0.0f, 1.0f, -0.5f,
        -0.5f, 0.5f, 0.0f, 0.0f, 1.0f, 1.0f,
    };
    state.bind.vertex_buffers[0] = sg_make_buffer(&sg_buffer_desc{
        .data = sg_range{&vertices, sizeof(vertices)},
        .label = "vertex-buffer",
    });
    sg_shader shd = sokol_make_shader(&triangle_sapp_vs_shader, &triangle_sapp_fs_shader);
    state.pip = sg_make_pipeline(&sg_pipeline_desc{
        .shader = shd,
        .layout = sg_vertex_layout_state{
            .attrs[0] = {.format = SG_VERTEXFORMAT_FLOAT3},
            .attrs[1] = {.format = SG_VERTEXFORMAT_FLOAT4},
        },
        .label = "triangle-pipeline",
    });
    state.pass_action = sg_pass_action{
        .colors[0] = {.load_action = SG_LOADACTION_CLEAR, .clear_value = {0.0f, 0.0f, 0.0f, 1.0f}},
    };
}
}

void frame() {
    sg_begin_pass(&sg_pass{.action = state.pass_action, .swapchain = sglue_swapchain()});
    sg_apply_pipeline(state.pip);
    sg_apply_bindings(&state.bind);
    sg_draw(0, 3, 1);
    __dbgui_draw();
    sg_end_pass();
    sg_commit();
}

void cleanup() {
    __dbgui_shutdown();
    sg_shutdown();
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
        .window_title = "triangle-sapp.mc",
        .icon = sapp_icon_desc{.sokol_default = true},
        .logger = sapp_logger{.func = slog_func},
    };
}
