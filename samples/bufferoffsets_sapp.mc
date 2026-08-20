import dbgui;

import sokol_all;
import math;

// force high-dpi, sample entry point is __sapp_sample_main()
sapp_desc sokol_main() {
    sapp_desc d = __sapp_sample_main();
    d.high_dpi = true;
    return d;
}

// bufferoffsets-sapp.glsl - ported to minc @shader.

struct BufferoffsetsSappVsOut {
    float4 pos;
    float4 color;
}

@shader vertex
BufferoffsetsSappVsOut bufferoffsets_sapp_vs(
    @attr(0) float4 position,
    @attr(1) float4 color0
) {
    BufferoffsetsSappVsOut o;
    o.pos = position;
    o.color = color0;
    return o;
}

@shader fragment
float4 bufferoffsets_sapp_fs(
BufferoffsetsSappVsOut input
) {
    return input.color;
}


enum __enum_ATTR_bufferoffsets_position {
    ATTR_bufferoffsets_position = 0,
    ATTR_bufferoffsets_color0 = 1,
    __shim_end = 255,
}

private struct state_t {
    sg_buffer vbuf;
    sg_buffer ibuf;
    sg_pass_action pass_action;
    sg_pipeline pip;
}

struct vertex_t {
    f32 x;
    f32 y;
    f32 r;
    f32 g;
    f32 b;
}

private {
state_t state = state_t{
    .pass_action = sg_pass_action{
        .colors[0] = {.load_action = SG_LOADACTION_CLEAR, .clear_value = {0.5f, 0.5f, 1.0f, 1.0f}},
    },
};

void init() {
    sg_setup(&sg_desc{.environment = sglue_environment(), .logger = sg_logger{.func = slog_func}});
    __dbgui_setup();
    vertex_t[7] vertices = {
        vertex_t{0.0f, 0.55f, 1.0f, 0.0f, 0.0f},
        vertex_t{0.25f, 0.05f, 0.0f, 1.0f, 0.0f},
        vertex_t{-0.25f, 0.05f, 0.0f, 0.0f, 1.0f},
        vertex_t{-0.25f, -0.05f, 0.0f, 0.0f, 1.0f},
        vertex_t{0.25f, -0.05f, 0.0f, 1.0f, 0.0f},
        vertex_t{0.25f, -0.55f, 1.0f, 0.0f, 0.0f},
        vertex_t{-0.25f, -0.55f, 1.0f, 1.0f, 0.0f},
    };
    u16[9] indices = {0, 1, 2, 0, 1, 2, 0, 2, 3};
    state.vbuf = sg_make_buffer(&sg_buffer_desc{
        .data = sg_range{&vertices, sizeof(vertices)},
        .label = "vertex-buffer",
    });
    state.ibuf = sg_make_buffer(&sg_buffer_desc{
        .usage = sg_buffer_usage{.index_buffer = true},
        .data = sg_range{&indices, sizeof(indices)},
        .label = "index-buffer",
    });
    state.pip = sg_make_pipeline(&sg_pipeline_desc{
        .shader = sokol_make_shader(&bufferoffsets_sapp_vs_shader, &bufferoffsets_sapp_fs_shader),
        .index_type = SG_INDEXTYPE_UINT16,
        .layout = sg_vertex_layout_state{
            .attrs[0] = {.format = SG_VERTEXFORMAT_FLOAT2},
            .attrs[1] = {.format = SG_VERTEXFORMAT_FLOAT3},
        },
        .label = "pipeline",
    });
}

void frame() {
    sg_begin_pass(&sg_pass{.action = state.pass_action, .swapchain = sglue_swapchain()});
    sg_apply_pipeline(state.pip);
    sg_apply_bindings(&sg_bindings{.vertex_buffers[0] = state.vbuf, .index_buffer = state.ibuf});
    sg_draw(0, 3, 1);
    sg_apply_bindings(&sg_bindings{
        .vertex_buffers[0] = state.vbuf,
        .vertex_buffer_offsets[0] = cast(i32, 3 * sizeof(vertex_t)),
        .index_buffer = state.ibuf,
        .index_buffer_offset = cast(i32, 3 * sizeof(u16)),
    });
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
        .width = 800,
        .height = 600,
        .depth_format = SAPP_PIXELFORMAT_NONE,
        .window_title = "bufferoffsets-sapp.mc",
        .icon = sapp_icon_desc{.sokol_default = true},
        .logger = sapp_logger{.func = slog_func},
    };
}
