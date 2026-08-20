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

// blend-op-sapp.glsl - ported to minc @shader.

struct BlendOpSappVs_BgOut {
    float4 pos;
}

@shader vertex
BlendOpSappVs_BgOut blend_op_sapp_vs_bg(
    @attr(0) float2 position
) {
    BlendOpSappVs_BgOut o;
    o.pos = float4{position, 0.5f, 1.0f};
    return o;
}

@shader fragment
float4 blend_op_sapp_fs_bg(
BlendOpSappVs_BgOut input,
    @uniform f32 tick
) {
    float2 xy = fract((frag_coord().xy - float2{tick}) / 50.0f);
    return float4{float3{xy.x * xy.y}, 1.0f};
}

struct BlendOpSappVs_QuadOut {
    float4 pos;
    float4 color;
}

@shader vertex
BlendOpSappVs_QuadOut blend_op_sapp_vs_quad(
    @attr(0) float4 position,
    @attr(1) float4 color0,
    @uniform float4x4 mvp
) {
    BlendOpSappVs_QuadOut o;
    o.pos = mul(mvp, position);
    o.color = color0;
    return o;
}

@shader fragment
float4 blend_op_sapp_fs_quad(
BlendOpSappVs_QuadOut input
) {
    return input.color;
}


enum __enum_ATTR_bg_position {
    ATTR_bg_position = 0,
    ATTR_quad_position = 0,
    ATTR_quad_color0 = 1,
    UB_bg_fs_params = 0,
    UB_quad_vs_params = 0,
    __shim_end = 255,
}

type __arr_sg_pipeline_5 = sg_pipeline[5];
// Replaces the sokol-shdc generated blend-op-sapp.glsl.h.
struct bg_fs_params_t {
    f32 tick;
    u8[12] _pad_tail;
}

struct quad_vs_params_t {
    mat44_t mvp;
}

private struct state_t {
    sg_pass_action pass_action;
    sg_bindings bind;
    __arr_sg_pipeline_5[5] pips;
    sg_pipeline bg_pip;
    f32 r;
    quad_vs_params_t quad_vs_params;
    bg_fs_params_t bg_fs_params;
}

private {
state_t state;

void init() {
    sg_setup(&sg_desc{
        .pipeline_pool_size = 5 * 5 + 16,
        .environment = sglue_environment(),
        .logger = sg_logger{.func = slog_func},
    });
    __dbgui_setup();
    state.pass_action = sg_pass_action{
        .colors[0] = {.load_action = SG_LOADACTION_DONTCARE},
        .depth = sg_depth_attachment_action{.load_action = SG_LOADACTION_DONTCARE},
        .stencil = sg_stencil_attachment_action{.load_action = SG_LOADACTION_DONTCARE},
    };
    f32[28] vertices = {
        -1.0f, -1.0f, 0.0f, 1.0f, 0.0f, 0.0f, 0.5f, 1.0f, -1.0f, 0.0f, 0.0f, 1.0f, 0.0f, 0.5f,
        -1.0f, 1.0f, 0.0f, 0.0f, 0.0f, 1.0f, 0.5f, 1.0f, 1.0f, 0.0f, 1.0f, 1.0f, 0.0f, 0.5f,
    };
    state.bind.vertex_buffers[0] = sg_make_buffer(&sg_buffer_desc{.data = sg_range{&vertices, sizeof(vertices)}});
    sg_shader bg_shd = sokol_make_shader(&blend_op_sapp_vs_bg_shader, &blend_op_sapp_fs_bg_shader);
    state.bg_pip = sg_make_pipeline(&sg_pipeline_desc{
        .layout = sg_vertex_layout_state{
            .buffers[0] = {.stride = 28},
            .attrs[0] = {.format = SG_VERTEXFORMAT_FLOAT2},
        },
        .shader = bg_shd,
        .primitive_type = SG_PRIMITIVETYPE_TRIANGLE_STRIP,
    });
    sg_shader quad_shd = sokol_make_shader(&blend_op_sapp_vs_quad_shader, &blend_op_sapp_fs_quad_shader);
    var pip_desc = sg_pipeline_desc{
        .layout = sg_vertex_layout_state{
            .attrs[0] = {.format = SG_VERTEXFORMAT_FLOAT3},
            .attrs[1] = {.format = SG_VERTEXFORMAT_FLOAT4},
        },
        .shader = quad_shd,
        .primitive_type = SG_PRIMITIVETYPE_TRIANGLE_STRIP,
        .blend_color = sg_color{1.0f, 0.0f, 0.0f, 1.0f},
    };
    for i32 rgb = 0; rgb < 5; rgb++ {
        for i32 alpha = 0; alpha < 5; alpha++ {
            var rgb_op = cast(sg_blend_op, rgb + 1);
            var alpha_op = cast(sg_blend_op, alpha + 1);
            pip_desc.colors[0].blend = sg_blend_state{
                .enabled = true,
                .src_factor_rgb = SG_BLENDFACTOR_SRC_ALPHA,
                .src_factor_alpha = SG_BLENDFACTOR_SRC_ALPHA,
                .dst_factor_rgb = SG_BLENDFACTOR_ONE_MINUS_SRC_ALPHA,
                .dst_factor_alpha = SG_BLENDFACTOR_ONE_MINUS_SRC_ALPHA,
                .op_rgb = rgb_op,
                .op_alpha = alpha_op,
            };
            if rgb_op == SG_BLENDOP_MIN || rgb_op == SG_BLENDOP_MAX {
                pip_desc.colors[0].blend.src_factor_rgb = SG_BLENDFACTOR_ONE;
                pip_desc.colors[0].blend.dst_factor_rgb = SG_BLENDFACTOR_ONE;
            }
            if alpha_op == SG_BLENDOP_MIN || alpha_op == SG_BLENDOP_MAX {
                pip_desc.colors[0].blend.src_factor_alpha = SG_BLENDFACTOR_ONE;
                pip_desc.colors[0].blend.dst_factor_alpha = SG_BLENDFACTOR_ONE;
            }
            state.pips[rgb][alpha] = sg_make_pipeline(&pip_desc);
        }
    }
}

void frame() {
    mat44_t proj = mat44_perspective_fov_rh(vecmath_radians(90.0f), sapp_widthf() / sapp_heightf(), 0.01f, 100.0f);
    mat44_t view = mat44_look_at_rh(vec3(0.0f, 0.0f, 7.0f), vec3(0.0f, 0.0f, 0.0f), vec3(0.0f, 1.0f, 0.0f));
    mat44_t view_proj = mat44_mul_mat44(view, proj);
    sg_begin_pass(&sg_pass{.action = state.pass_action, .swapchain = sglue_swapchain()});
    sg_apply_pipeline(state.bg_pip);
    sg_apply_bindings(&state.bind);
    sg_apply_uniforms(UB_bg_fs_params, &sg_range{&state.bg_fs_params, sizeof(state.bg_fs_params)});
    sg_draw(0, 4, 1);
    f32 r0 = state.r;
    for i32 src = 0; src < 5; src++ {
        for i32 dst = 0; dst < 5; dst++ {
            mat44_t rm = mat44_rotation_y(vecmath_radians(r0));
            f32 x = cast(f32, dst - 5 / 2) * 3.0f;
            f32 y = cast(f32, src - 5 / 2) * 2.2f;
            mat44_t model = mat44_mul_mat44(rm, mat44_translation(x, y, 0.0f));
            state.quad_vs_params.mvp = mat44_mul_mat44(model, view_proj);
            sg_apply_pipeline(state.pips[src][dst]);
            sg_apply_bindings(&state.bind);
            sg_apply_uniforms(UB_quad_vs_params, &sg_range{&state.quad_vs_params, sizeof(state.quad_vs_params)});
            sg_draw(0, 4, 1);
            r0 += 0.6f;
        }
    }
    __dbgui_draw();
    sg_end_pass();
    sg_commit();
    var t = cast(f32, sapp_frame_duration() * 60.0);
    state.r += 0.6f * t;
    state.bg_fs_params.tick += 1.0f * t;
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
        .sample_count = 4,
        .window_title = "blend-op-sapp.mc",
        .icon = sapp_icon_desc{.sokol_default = true},
        .logger = sapp_logger{.func = slog_func},
    };
}
