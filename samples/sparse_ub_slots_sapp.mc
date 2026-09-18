import sokol_debugtext;

import sokol_all;
import math;

// force high-dpi, sample entry point is __sapp_sample_main()
sapp_desc sokol_main() {
    sapp_desc d = __sapp_sample_main();
    d.high_dpi = true;
    return d;
}

// sparse-ub-slots-sapp.glsl - ported to minc @shader.
// Fragment blocks take program slot 1: the vertex block holds slot 0,
// and WebGPU needs distinct @group(0) bindings within one program.

struct SparseUbSlotsSappVsOut {
    float4 pos;
}

@shader vertex
SparseUbSlotsSappVsOut sparse_ub_slots_sapp_vs(
    @attr(0) float2 position,
    @uniform float2 offset
) {
    SparseUbSlotsSappVsOut o;
    o.pos = float4{position + offset * 0.5f, 0.0f, 1.0f};
    return o;
}

@shader fragment
float4 sparse_ub_slots_sapp_dense_fs(
SparseUbSlotsSappVsOut input,
    @uniform(1) float4 color
) {
    return color;
}

@shader fragment
float4 sparse_ub_slots_sapp_sparse_fs(
SparseUbSlotsSappVsOut input,
    @uniform(1) float4 color
) {
    return color;
}


enum __enum_ATTR_dense_position {
    ATTR_dense_position = 0,
    ATTR_sparse_position = 0,
    UB_vs_params = 0,
    UB_dense_fs_params = 1,
    UB_sparse_fs_params = 1,
    __shim_end = 255,
}

// Replaces the sokol-shdc generated sparse-ub-slots-sapp.glsl.h.
struct vs_params_t {
    f32[2] offset;
    u8[8] _pad_tail;
}

struct dense_fs_params_t {
    f32[4] color;
}

struct sparse_fs_params_t {
    f32[4] color;
}

private struct state_t {
    sg_bindings bind;
    sg_pipeline pip_dense;
    sg_pipeline pip_sparse;
    sg_pass_action pass_action;
}

/*
    The typical debug UI overlay useful for most sokol-app samples
*/
private {
void __dbgui_setup() {
}

void __dbgui_shutdown() {
}

void __dbgui_draw() {
}

void __dbgui_event(sapp_event* e) {
    ignore e;
}

bool __dbgui_event_with_retval(sapp_event* e) {
    ignore e;
    return false;
}
state_t state = state_t{
    .pass_action = sg_pass_action{
        .colors[0] = {
            .load_action = SG_LOADACTION_CLEAR,
            .clear_value = {0.15f, 0.15f, 0.18f, 1.0f},
        },
    },
};

void init() {
    sg_setup(&sg_desc{.environment = sglue_environment(), .logger = sg_logger{.func = slog_func}});
    __dbgui_setup();
    sdtx_setup(&sdtx_desc_t{
        .fonts[0] = sdtx_font_oric(),
        .logger = sdtx_logger_t{.func = slog_func},
    });
    state.bind.vertex_buffers[0] = sg_make_buffer(&sg_buffer_desc{
        .data = sg_range{&init__vertices, sizeof(init__vertices)},
        .label = "triangle-vertices",
    });
    state.pip_dense = sg_make_pipeline(&sg_pipeline_desc{
        .shader = sokol_make_shader(&sparse_ub_slots_sapp_vs_shader, &sparse_ub_slots_sapp_dense_fs_shader),
        .layout = sg_vertex_layout_state{.attrs[0] = {.format = SG_VERTEXFORMAT_FLOAT2}},
        .label = "pip-dense",
    });
    state.pip_sparse = sg_make_pipeline(&sg_pipeline_desc{
        .shader = sokol_make_shader(&sparse_ub_slots_sapp_vs_shader, &sparse_ub_slots_sapp_sparse_fs_shader),
        .layout = sg_vertex_layout_state{.attrs[0] = {.format = SG_VERTEXFORMAT_FLOAT2}},
        .label = "pip-sparse",
    });
}

void frame() {
    sdtx_canvas(cast(f32, sapp_width()) * 0.5f, cast(f32, sapp_height()) * 0.5f);
    sdtx_origin(2.0f, 2.0f);
    sdtx_home();
    sdtx_color3f(0.0f, 1.0f, 0.0f);
    sdtx_puts("Left triangle should be green\n\n");
    sdtx_color3f(1.0f, 0.0f, 1.0f);
    sdtx_puts("Right triangle should be magenta\n");
    var left_vs_params = vs_params_t{.offset = {-1.0f, 0.0f}};
    var right_vs_params = vs_params_t{.offset = {1.0f, 0.0f}};
    var dense_fs_params = dense_fs_params_t{.color = {0.0f, 1.0f, 0.0f, 1.0f}};
    var sparse_fs_params = sparse_fs_params_t{.color = {1.0f, 0.0f, 1.0f, 1.0f}};
    sg_begin_pass(&sg_pass{.action = state.pass_action, .swapchain = sglue_swapchain()});
    sg_apply_pipeline(state.pip_dense);
    sg_apply_bindings(&state.bind);
    sg_apply_uniforms(UB_vs_params, &sg_range{&left_vs_params, sizeof(left_vs_params)});
    sg_apply_uniforms(UB_dense_fs_params, &sg_range{&dense_fs_params, sizeof(dense_fs_params)});
    sg_draw(0, 3, 1);
    sg_apply_pipeline(state.pip_sparse);
    sg_apply_bindings(&state.bind);
    sg_apply_uniforms(UB_vs_params, &sg_range{&right_vs_params, sizeof(right_vs_params)});
    sg_apply_uniforms(UB_sparse_fs_params, &sg_range{&sparse_fs_params, sizeof(sparse_fs_params)});
    sg_draw(0, 3, 1);
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
        .width = 800,
        .height = 450,
        .depth_format = SAPP_PIXELFORMAT_NONE,
        .icon = sapp_icon_desc{.sokol_default = true},
        .window_title = "sparse-ub-slot-sapp.mc",
        .logger = sapp_logger{.func = slog_func},
    };
}
private { f32[6] init__vertices = {0.0f, 0.65f, 0.45f, -0.65f, -0.45f, -0.65f}; }
