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

// blend-sapp.glsl - ported to minc @shader.

struct BlendSappVs_BgOut {
    float4 pos;
}

@shader vertex
BlendSappVs_BgOut blend_sapp_vs_bg(
    @attr(0) float2 position
) {
    BlendSappVs_BgOut o;
    o.pos = float4{position, 0.5f, 1.0f};
    return o;
}

@shader fragment
float4 blend_sapp_fs_bg(
BlendSappVs_BgOut input,
    @uniform f32 tick
) {
    float2 xy = fract((frag_coord().xy - float2{tick}) / 50.0f);
    return float4{float3{xy.x * xy.y}, 1.0f};
}

struct BlendSappVs_QuadOut {
    float4 pos;
    float4 color;
}

@shader vertex
BlendSappVs_QuadOut blend_sapp_vs_quad(
    @attr(0) float4 position,
    @attr(1) float4 color0,
    @uniform float4x4 mvp
) {
    BlendSappVs_QuadOut o;
    o.pos = mul(mvp, position);
    o.color = color0;
    return o;
}

@shader fragment
float4 blend_sapp_fs_quad(
BlendSappVs_QuadOut input
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

type __arr_sg_pipeline_15 = sg_pipeline[15];
// Replaces the sokol-shdc generated blend-sapp.glsl.h.
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
    __arr_sg_pipeline_15[15] pips;
    sg_pipeline bg_pip;
    f32 r;
    quad_vs_params_t quad_vs_params;
    bg_fs_params_t bg_fs_params;
}

private {
state_t state;

void init() {
    sg_setup(&sg_desc{
        .pipeline_pool_size = 15 * 15 + 16,
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
    sg_shader bg_shd = sokol_make_shader(&blend_sapp_vs_bg_shader, &blend_sapp_fs_bg_shader);
    state.bg_pip = sg_make_pipeline(&sg_pipeline_desc{
        .layout = sg_vertex_layout_state{
            .buffers[0] = {.stride = 28},
            .attrs[0] = {.format = SG_VERTEXFORMAT_FLOAT2},
        },
        .shader = bg_shd,
        .primitive_type = SG_PRIMITIVETYPE_TRIANGLE_STRIP,
    });
    sg_shader quad_shd = sokol_make_shader(&blend_sapp_vs_quad_shader, &blend_sapp_fs_quad_shader);
    var pip_desc = sg_pipeline_desc{
        .layout = sg_vertex_layout_state{
            .attrs[0] = {.format = SG_VERTEXFORMAT_FLOAT3},
            .attrs[1] = {.format = SG_VERTEXFORMAT_FLOAT4},
        },
        .shader = quad_shd,
        .primitive_type = SG_PRIMITIVETYPE_TRIANGLE_STRIP,
        .blend_color = sg_color{1.0f, 0.0f, 0.0f, 1.0f},
    };
    for i32 src = 0; src < 15; src++ {
        for i32 dst = 0; dst < 15; dst++ {
            var src_blend = cast(sg_blend_factor, src + 1);
            var dst_blend = cast(sg_blend_factor, dst + 1);
            if src_blend == SG_BLENDFACTOR_BLEND_COLOR || src_blend == SG_BLENDFACTOR_ONE_MINUS_BLEND_COLOR {
                if dst_blend == SG_BLENDFACTOR_BLEND_ALPHA || dst_blend == SG_BLENDFACTOR_ONE_MINUS_BLEND_ALPHA {
                    continue;
                }
            } else if src_blend == SG_BLENDFACTOR_BLEND_ALPHA || src_blend == SG_BLENDFACTOR_ONE_MINUS_BLEND_ALPHA {
                if dst_blend == SG_BLENDFACTOR_BLEND_COLOR || dst_blend == SG_BLENDFACTOR_ONE_MINUS_BLEND_COLOR {
                    continue;
                }
            }
            pip_desc.colors[0].blend = sg_blend_state{
                .enabled = true,
                .src_factor_rgb = src_blend,
                .dst_factor_rgb = dst_blend,
                .src_factor_alpha = SG_BLENDFACTOR_ONE,
                .dst_factor_alpha = SG_BLENDFACTOR_ZERO,
            };
            state.pips[src][dst] = sg_make_pipeline(&pip_desc);
        }
    }
}

void frame() {
    mat44_t proj = mat44_perspective_fov_rh(vecmath_radians(90.0f), sapp_widthf() / sapp_heightf(), 0.01f, 100.0f);
    mat44_t view = mat44_look_at_rh(vec3(0.0f, 0.0f, 20.0f), vec3(0.0f, 0.0f, 0.0f), vec3(0.0f, 1.0f, 0.0f));
    mat44_t view_proj = mat44_mul_mat44(view, proj);
    sg_begin_pass(&sg_pass{.action = state.pass_action, .swapchain = sglue_swapchain()});
    sg_apply_pipeline(state.bg_pip);
    sg_apply_bindings(&state.bind);
    sg_apply_uniforms(UB_bg_fs_params, &sg_range{&state.bg_fs_params, sizeof(state.bg_fs_params)});
    sg_draw(0, 4, 1);
    f32 r0 = state.r;
    for i32 src = 0; src < 15; src++ {
        for i32 dst = 0; dst < 15; dst++ {
            if state.pips[src][dst].id == cast(u32, SG_INVALID_ID) {
                {
                    r0 += 0.6f;
                    continue;
                }
            }
            mat44_t rm = mat44_rotation_y(vecmath_radians(r0));
            f32 x = cast(f32, dst - 15 / 2) * 3.0f;
            f32 y = cast(f32, src - 15 / 2) * 2.2f;
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
        .window_title = "blend-sapp.mc",
        .icon = sapp_icon_desc{.sokol_default = true},
        .logger = sapp_logger{.func = slog_func},
    };
}
