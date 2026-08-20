import dbgui;
import vecmath;

import sokol_all;
import math;

// force high-dpi, sample entry point is __sapp_sample_main()
sapp_desc sokol_main() {
    sapp_desc d = __sapp_sample_main();
    d.high_dpi = true;
    return d;
}

// compositemode-sapp.glsl - ported to minc @shader.

struct CompositemodeSappVsOut {
    float4 pos;
    float4 color;
}

@shader vertex
CompositemodeSappVsOut compositemode_sapp_vs(
    @attr(0) float4 position,
    @attr(1) float4 color0,
    @uniform float4x4 mvp
) {
    CompositemodeSappVsOut o;
    o.pos = mul(mvp, position);
    o.color = color0;
    return o;
}

@shader fragment
float4 compositemode_sapp_fs(
CompositemodeSappVsOut input
) {
    return float4{input.color.rgb, 1};
}


enum __enum_ATTR_shd_position {
    ATTR_shd_position = 0,
    ATTR_shd_color0 = 1,
    UB_vs_params = 0,
    __shim_end = 255,
}

// Replaces the sokol-shdc generated compositemode-sapp.glsl.h.
struct vs_params_t {
    mat44_t mvp;
}

private struct state_t {
    f32 rx;
    f32 ry;
    sg_pipeline pip;
    sg_bindings bind;
}

private { state_t state; }

private {
void init() {
    sg_setup(&sg_desc{.environment = sglue_environment(), .logger = sg_logger{.func = slog_func}});
    __dbgui_setup();
    f32[168] vertices = {
        -1.0f, -1.0f, -1.0f, 1.0f, 0.0f, 0.0f, 1.0f, 1.0f, -1.0f, -1.0f, 1.0f, 0.0f, 0.0f, 1.0f,
        1.0f, 1.0f, -1.0f, 1.0f, 0.0f, 0.0f, 1.0f, -1.0f, 1.0f, -1.0f, 1.0f, 0.0f, 0.0f, 1.0f,
        -1.0f, -1.0f, 1.0f, 0.0f, 1.0f, 0.0f, 1.0f, 1.0f, -1.0f, 1.0f, 0.0f, 1.0f, 0.0f, 1.0f, 1.0f,
        1.0f, 1.0f, 0.0f, 1.0f, 0.0f, 1.0f, -1.0f, 1.0f, 1.0f, 0.0f, 1.0f, 0.0f, 1.0f, -1.0f, -1.0f,
        -1.0f, 0.0f, 0.0f, 1.0f, 1.0f, -1.0f, 1.0f, -1.0f, 0.0f, 0.0f, 1.0f, 1.0f, -1.0f, 1.0f,
        1.0f, 0.0f, 0.0f, 1.0f, 1.0f, -1.0f, -1.0f, 1.0f, 0.0f, 0.0f, 1.0f, 1.0f, 1.0f, -1.0f,
        -1.0f, 1.0f, 0.5f, 0.0f, 1.0f, 1.0f, 1.0f, -1.0f, 1.0f, 0.5f, 0.0f, 1.0f, 1.0f, 1.0f, 1.0f,
        1.0f, 0.5f, 0.0f, 1.0f, 1.0f, -1.0f, 1.0f, 1.0f, 0.5f, 0.0f, 1.0f, -1.0f, -1.0f, -1.0f,
        0.0f, 0.5f, 1.0f, 1.0f, -1.0f, -1.0f, 1.0f, 0.0f, 0.5f, 1.0f, 1.0f, 1.0f, -1.0f, 1.0f, 0.0f,
        0.5f, 1.0f, 1.0f, 1.0f, -1.0f, -1.0f, 0.0f, 0.5f, 1.0f, 1.0f, -1.0f, 1.0f, -1.0f, 1.0f,
        0.0f, 0.5f, 1.0f, -1.0f, 1.0f, 1.0f, 1.0f, 0.0f, 0.5f, 1.0f, 1.0f, 1.0f, 1.0f, 1.0f, 0.0f,
        0.5f, 1.0f, 1.0f, 1.0f, -1.0f, 1.0f, 0.0f, 0.5f, 1.0f,
    };
    sg_buffer vbuf = sg_make_buffer(&sg_buffer_desc{
        .data = sg_range{&vertices, sizeof(vertices)},
        .label = "cube-vertices",
    });
    u16[36] indices = {
        0, 1, 2, 0, 2, 3, 6, 5, 4, 7, 6, 4, 8, 9, 10, 8, 10, 11, 14, 13, 12, 15, 14, 12, 16, 17, 18,
        16, 18, 19, 22, 21, 20, 23, 22, 20,
    };
    sg_buffer ibuf = sg_make_buffer(&sg_buffer_desc{
        .usage = sg_buffer_usage{.index_buffer = true},
        .data = sg_range{&indices, sizeof(indices)},
        .label = "cube-indices",
    });
    sg_shader shd = sokol_make_shader(&compositemode_sapp_vs_shader, &compositemode_sapp_fs_shader);
    state.pip = sg_make_pipeline(&sg_pipeline_desc{
        .layout = sg_vertex_layout_state{
            .buffers[0] = {.stride = 28},
            .attrs[0] = {.format = SG_VERTEXFORMAT_FLOAT3},
            .attrs[1] = {.format = SG_VERTEXFORMAT_FLOAT4},
        },
        .shader = shd,
        .index_type = SG_INDEXTYPE_UINT16,
        .cull_mode = SG_CULLMODE_BACK,
        .alpha_to_coverage_enabled = true,
        .depth = sg_depth_state{.write_enabled = true, .compare = SG_COMPAREFUNC_LESS_EQUAL},
        .label = "cube-pipeline",
    });
    state.bind = sg_bindings{.vertex_buffers[0] = vbuf, .index_buffer = ibuf};
}

void frame() {
    var t = cast(f32, sapp_frame_duration() * 60.0);
    state.rx += 1.0f * t;
    state.ry += 2.0f * t;
    vs_params_t vs_params = compute_vsparams(state.rx, state.ry);
    sg_begin_pass(&sg_pass{
        .action = sg_pass_action{
            .colors[0] = {
                .load_action = SG_LOADACTION_CLEAR,
                .clear_value = {0.0f, 0.0f, 0.0f, 0.0f},
            },
        },
        .swapchain = sglue_swapchain(),
    });
    sg_apply_pipeline(state.pip);
    sg_apply_bindings(&state.bind);
    sg_apply_uniforms(UB_vs_params, &sg_range{&vs_params, sizeof(vs_params)});
    sg_draw(0, 36, 1);
    __dbgui_draw();
    sg_end_pass();
    sg_commit();
}

void cleanup() {
    __dbgui_shutdown();
    sg_shutdown();
}

vs_params_t compute_vsparams(f32 rx, f32 ry) {
    f32 w = sapp_widthf();
    f32 h = sapp_heightf();
    mat44_t proj = mat44_perspective_fov_rh(vecmath_radians(60.0f), w / h, 0.01f, 10.0f);
    mat44_t view = mat44_look_at_rh(vec3(0.0f, 1.5f, 4.0f), vec3(0.0f, 0.0f, 0.0f), vec3(0.0f, 1.0f, 0.0f));
    mat44_t view_proj = mat44_mul_mat44(view, proj);
    mat44_t rxm = mat44_rotation_x(vecmath_radians(rx));
    mat44_t rym = mat44_rotation_y(vecmath_radians(ry));
    mat44_t model = mat44_mul_mat44(rym, rxm);
    return vs_params_t{.mvp = mat44_mul_mat44(model, view_proj)};
}
}

sapp_desc __sapp_sample_main() {
    return sapp_desc{
        .composite_mode = SAPP_COMPOSITEMODE_PREMULTIPLIED,
        .init_cb = init,
        .frame_cb = frame,
        .cleanup_cb = cleanup,
        .event_cb = __dbgui_event,
        .width = 800,
        .height = 600,
        .sample_count = 4,
        .window_title = "cube-sapp.mc",
        .icon = sapp_icon_desc{.sokol_default = true},
        .logger = sapp_logger{.func = slog_func},
    };
}
