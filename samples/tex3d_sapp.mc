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

// tex3d-sapp.glsl - ported to minc @shader.

struct Tex3DSappVsOut {
    float4 pos;
    float3 uvw;
}

@gpu_layout
struct Ub_vs_params {
    float4x4 mvp;
    f32 scale;
}

@shader vertex
Tex3DSappVsOut tex3d_sapp_vs(
    @attr(0) float4 position,
    @uniform(0) Ub_vs_params vs_params
) {
    Tex3DSappVsOut o;
    o.pos = mul(vs_params.mvp, position);
    o.uvw = ((position.xyz * vs_params.scale) + 1.0f) * 0.5f;
    return o;
}

@shader fragment
float4 tex3d_sapp_fs(
Tex3DSappVsOut input,
    @texture(0) Texture3D tex,
    @sampler(0) Sampler smp
) {
    return sample(tex, smp, input.uvw);
}


enum __enum_ATTR_cube_position {
    ATTR_cube_position = 0,
    UB_vs_params = 0,
    VIEW_tex = 0,
    SMP_smp = 0,
    __shim_end = 255,
}

type __arr_u32_32 = u32[32];
type __arr___arr_u32_32_32 = __arr_u32_32[32];
// Replaces the sokol-shdc generated tex3d-sapp.glsl.h.
struct vs_params_t {
    mat44_t mvp;
    f32 scale;
    u8[12] _pad_tail;
}

private struct state_t {
    sg_pass_action pass_action;
    sg_pipeline pip;
    sg_bindings bind;
    f32 rx;
    f32 ry;
    f32 t;
}

private {
state_t state;

u32 xorshift32() {
    xorshift32__x ^= xorshift32__x << 13;
    xorshift32__x ^= xorshift32__x >> 17;
    xorshift32__x ^= xorshift32__x << 5;
    return xorshift32__x;
}

void init() {
    sg_setup(&sg_desc{.environment = sglue_environment(), .logger = sg_logger{.func = slog_func}});
    __dbgui_setup();
    state.pass_action = sg_pass_action{
        .colors[0] = {.load_action = SG_LOADACTION_CLEAR, .clear_value = {0.25f, 0.5f, 0.75f, 1.0f}},
    };
    f32[72] vertices = {
        -1.0f, -1.0f, -1.0f, 1.0f, -1.0f, -1.0f, 1.0f, 1.0f, -1.0f, -1.0f, 1.0f, -1.0f, -1.0f,
        -1.0f, 1.0f, 1.0f, -1.0f, 1.0f, 1.0f, 1.0f, 1.0f, -1.0f, 1.0f, 1.0f, -1.0f, -1.0f, -1.0f,
        -1.0f, 1.0f, -1.0f, -1.0f, 1.0f, 1.0f, -1.0f, -1.0f, 1.0f, 1.0f, -1.0f, -1.0f, 1.0f, 1.0f,
        -1.0f, 1.0f, 1.0f, 1.0f, 1.0f, -1.0f, 1.0f, -1.0f, -1.0f, -1.0f, -1.0f, -1.0f, 1.0f, 1.0f,
        -1.0f, 1.0f, 1.0f, -1.0f, -1.0f, -1.0f, 1.0f, -1.0f, -1.0f, 1.0f, 1.0f, 1.0f, 1.0f, 1.0f,
        1.0f, 1.0f, -1.0f,
    };
    u16[36] indices = {
        0, 1, 2, 0, 2, 3, 6, 5, 4, 7, 6, 4, 8, 9, 10, 8, 10, 11, 14, 13, 12, 15, 14, 12, 16, 17, 18,
        16, 18, 19, 22, 21, 20, 23, 22, 20,
    };
    state.bind.vertex_buffers[0] = sg_make_buffer(&sg_buffer_desc{
        .usage = sg_buffer_usage{.vertex_buffer = true},
        .data = sg_range{&vertices, sizeof(vertices)},
        .label = "cube-vertices",
    });
    state.bind.index_buffer = sg_make_buffer(&sg_buffer_desc{
        .usage = sg_buffer_usage{.index_buffer = true},
        .data = sg_range{&indices, sizeof(indices)},
        .label = "cube-indices",
    });
    state.pip = sg_make_pipeline(&sg_pipeline_desc{
        .layout = sg_vertex_layout_state{.attrs[0] = {.format = SG_VERTEXFORMAT_FLOAT3}},
        .shader = sokol_make_shader(&tex3d_sapp_vs_shader, &tex3d_sapp_fs_shader),
        .index_type = SG_INDEXTYPE_UINT16,
        .cull_mode = SG_CULLMODE_BACK,
        .depth = sg_depth_state{.compare = SG_COMPAREFUNC_LESS_EQUAL, .write_enabled = true},
        .label = "cube-pipeline",
    });
    for i32 x = 0; x < 32; x++ {
        for i32 y = 0; y < 32; y++ {
            for i32 z = 0; z < 32; z++ {
                init__pixels[x][y][z] = xorshift32();
            }
        }
    }
    state.bind.views[VIEW_tex] = sg_make_view(&sg_view_desc{
        .texture = sg_texture_view_desc{
            .image = sg_make_image(&sg_image_desc{
                .type = SG_IMAGETYPE_3D,
                .width = 32,
                .height = 32,
                .num_slices = 32,
                .num_mipmaps = 1,
                .pixel_format = SG_PIXELFORMAT_RGBA8,
                .label = "3d-texture",
                .data = sg_image_data{.mip_levels[0] = sg_range{&init__pixels, sizeof(init__pixels)}},
            }),
        },
        .label = "3d-texture-view",
    });
    state.bind.samplers[SMP_smp] = sg_make_sampler(&sg_sampler_desc{
        .min_filter = SG_FILTER_LINEAR,
        .mag_filter = SG_FILTER_LINEAR,
        .label = "sampler",
    });
}

void frame() {
    var t = cast(f32, sapp_frame_duration() * 60.0);
    state.rx += 1.0f * t;
    state.ry += 2.0f * t;
    state.t += 0.03f * t;
    mat44_t proj = mat44_perspective_fov_rh(vecmath_radians(60.0f), sapp_widthf() / sapp_heightf(), 0.01f, 10.0f);
    mat44_t view = mat44_look_at_rh(vec3(0.0f, 1.5f, 4.0f), vec3(0.0f, 0.0f, 0.0f), vec3(0.0f, 1.0f, 0.0f));
    mat44_t view_proj = mat44_mul_mat44(view, proj);
    mat44_t rxm = mat44_rotation_x(vecmath_radians(state.rx));
    mat44_t rym = mat44_rotation_y(vecmath_radians(state.ry));
    mat44_t model = mat44_mul_mat44(rym, rxm);
    var vs_params = vs_params_t{
        .mvp = mat44_mul_mat44(model, view_proj),
        .scale = (vecmath_sin(state.t) + 1.0f) * 0.5f,
    };
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
        .window_title = "tex3d-sapp.mc",
        .icon = sapp_icon_desc{.sokol_default = true},
        .logger = sapp_logger{.func = slog_func},
    };
}
private {
u32 xorshift32__x = 0x12345678;
__arr___arr_u32_32_32[32] init__pixels;
}
