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

// arraytex-sapp.glsl - ported to minc @shader.

struct ArraytexSappVsOut {
    float4 pos;
    float3 uv0;
    float3 uv1;
    float3 uv2;
}

@gpu_layout
struct Ub_vs_params {
    float4x4 mvp;
    float2 offset0;
    float2 offset1;
    float2 offset2;
}

@shader vertex
ArraytexSappVsOut arraytex_sapp_vs(
    @attr(0) float4 position,
    @attr(1) float2 texcoord0,
    @uniform(0) Ub_vs_params vs_params
) {
    ArraytexSappVsOut o;
    o.pos = mul(vs_params.mvp, position);
    o.uv0 = float3{texcoord0 + vs_params.offset0, 0.0f};
    o.uv1 = float3{texcoord0 + vs_params.offset1, 1.0f};
    o.uv2 = float3{texcoord0 + vs_params.offset2, 2.0f};
    return o;
}

@shader fragment
float4 arraytex_sapp_fs(
ArraytexSappVsOut input,
    @texture(0) Texture2DArray tex,
    @sampler(0) Sampler smp
) {
    float4 c0 = sample(tex, smp, input.uv0);
    float4 c1 = sample(tex, smp, input.uv1);
    float4 c2 = sample(tex, smp, input.uv2);
    return float4{c0.xyz + c1.xyz + c2.xyz, 1.0f};
}


enum __enum_ATTR_arraytex_position {
    ATTR_arraytex_position = 0,
    ATTR_arraytex_texcoord0 = 1,
    UB_vs_params = 0,
    VIEW_tex = 0,
    SMP_smp = 0,
    __shim_end = 255,
}

type __arr_u32_16 = u32[16];
type __arr___arr_u32_16_16 = __arr_u32_16[16];
// Replaces the sokol-shdc generated arraytex-sapp.glsl.h.
struct vs_params_t {
    mat44_t mvp;
    vec2_t offset0;
    vec2_t offset1;
    vec2_t offset2;
    u8[8] _pad_tail;
}

private struct state_t {
    sg_pass_action pass_action;
    sg_pipeline pip;
    sg_bindings bind;
    f32 rx;
    f32 ry;
}

private { state_t state; }

private {
void init() {
    sg_setup(&sg_desc{.environment = sglue_environment(), .logger = sg_logger{.func = slog_func}});
    __dbgui_setup();
    state.pass_action = sg_pass_action{
        .colors[0] = {.load_action = SG_LOADACTION_CLEAR, .clear_value = {0.0f, 0.0f, 0.0f, 1.0f}},
    };
    {
        i32 layer = 0;
        i32 even_odd = 0;
        for ; layer < 3; layer++ {
            for i32 y = 0; y < 16; y++ {
                for i32 x = 0; x < 16; x++ {
                    if (even_odd & 1) != 0 {
                        switch layer {
                            case 0: {
                                init__pixels[layer][y][x] = 0x000000FF;
                            }
                            case 1: {
                                init__pixels[layer][y][x] = 0x0000FF00;
                            }
                            case 2: {
                                init__pixels[layer][y][x] = 0x00FF0000;
                            }
                        }
                    } else {
                        init__pixels[layer][y][x] = 0;
                    }
                    even_odd++;
                }
                even_odd++;
            }
        }
    }
    sg_image img = sg_make_image(&sg_image_desc{
        .type = SG_IMAGETYPE_ARRAY,
        .width = 16,
        .height = 16,
        .num_slices = 3,
        .pixel_format = SG_PIXELFORMAT_RGBA8,
        .data = sg_image_data{.mip_levels[0] = sg_range{&init__pixels, sizeof(init__pixels)}},
        .label = "array-texture",
    });
    sg_view tex_view = sg_make_view(&sg_view_desc{
        .texture = sg_texture_view_desc{.image = img},
        .label = "array-texture-view",
    });
    sg_sampler smp = sg_make_sampler(&sg_sampler_desc{
        .min_filter = SG_FILTER_LINEAR,
        .mag_filter = SG_FILTER_LINEAR,
        .label = "sampler",
    });
    f32[120] vertices = {
        -1.0f, -1.0f, -1.0f, 0.0f, 0.0f, 1.0f, -1.0f, -1.0f, 1.0f, 0.0f, 1.0f, 1.0f, -1.0f, 1.0f,
        1.0f, -1.0f, 1.0f, -1.0f, 0.0f, 1.0f, -1.0f, -1.0f, 1.0f, 0.0f, 0.0f, 1.0f, -1.0f, 1.0f,
        1.0f, 0.0f, 1.0f, 1.0f, 1.0f, 1.0f, 1.0f, -1.0f, 1.0f, 1.0f, 0.0f, 1.0f, -1.0f, -1.0f,
        -1.0f, 0.0f, 0.0f, -1.0f, 1.0f, -1.0f, 1.0f, 0.0f, -1.0f, 1.0f, 1.0f, 1.0f, 1.0f, -1.0f,
        -1.0f, 1.0f, 0.0f, 1.0f, 1.0f, -1.0f, -1.0f, 0.0f, 0.0f, 1.0f, 1.0f, -1.0f, 1.0f, 0.0f,
        1.0f, 1.0f, 1.0f, 1.0f, 1.0f, 1.0f, -1.0f, 1.0f, 0.0f, 1.0f, -1.0f, -1.0f, -1.0f, 0.0f,
        0.0f, -1.0f, -1.0f, 1.0f, 1.0f, 0.0f, 1.0f, -1.0f, 1.0f, 1.0f, 1.0f, 1.0f, -1.0f, -1.0f,
        0.0f, 1.0f, -1.0f, 1.0f, -1.0f, 0.0f, 0.0f, -1.0f, 1.0f, 1.0f, 1.0f, 0.0f, 1.0f, 1.0f, 1.0f,
        1.0f, 1.0f, 1.0f, 1.0f, -1.0f, 0.0f, 1.0f,
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
    state.pip = sg_make_pipeline(&sg_pipeline_desc{
        .layout = sg_vertex_layout_state{
            .attrs[0] = {.format = SG_VERTEXFORMAT_FLOAT3},
            .attrs[1] = {.format = SG_VERTEXFORMAT_FLOAT2},
        },
        .shader = sokol_make_shader(&arraytex_sapp_vs_shader, &arraytex_sapp_fs_shader),
        .index_type = SG_INDEXTYPE_UINT16,
        .cull_mode = SG_CULLMODE_NONE,
        .depth = sg_depth_state{.compare = SG_COMPAREFUNC_LESS_EQUAL, .write_enabled = true},
        .label = "cube-pipeline",
    });
    state.bind = sg_bindings{
        .vertex_buffers[0] = vbuf,
        .index_buffer = ibuf,
        .views[0] = tex_view,
        .samplers[0] = smp,
    };
}

void frame() {
    var t = cast(f32, sapp_frame_duration() * 60.0);
    f32 offset = cast(f32, sapp_frame_count()) * 0.0001f * t;
    state.rx += 1.0f * t;
    state.ry += 2.0f * t;
    vs_params_t vs_params = compute_vsparams(state.rx, state.ry, offset);
    sg_begin_pass(&sg_pass{.action = state.pass_action, .swapchain = sglue_swapchain()});
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

vs_params_t compute_vsparams(f32 rx, f32 ry, f32 offset) {
    f32 w = sapp_widthf();
    f32 h = sapp_heightf();
    mat44_t proj = mat44_perspective_fov_rh(vecmath_radians(60.0f), w / h, 0.01f, 10.0f);
    mat44_t view = mat44_look_at_rh(vec3(0.0f, 1.5f, 4.0f), vec3(0.0f, 0.0f, 0.0f), vec3(0.0f, 1.0f, 0.0f));
    mat44_t view_proj = mat44_mul_mat44(view, proj);
    mat44_t rxm = mat44_rotation_x(vecmath_radians(rx));
    mat44_t rym = mat44_rotation_y(vecmath_radians(ry));
    mat44_t model = mat44_mul_mat44(rym, rxm);
    return vs_params_t{
        .mvp = mat44_mul_mat44(model, view_proj),
        .offset0 = vec2(-offset, offset),
        .offset1 = vec2(offset, -offset),
        .offset2 = vec2(0.0f, 0.0f),
    };
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
        .window_title = "arraytex-sapp.mc",
        .icon = sapp_icon_desc{.sokol_default = true},
        .logger = sapp_logger{.func = slog_func},
    };
}
private { __arr___arr_u32_16_16[3] init__pixels; }
