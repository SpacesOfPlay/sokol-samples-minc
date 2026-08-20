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

// shared-bindings-sapp.glsl - ported to minc @shader.

struct SharedBindingsSappVsOut {
    float4 pos;
    float4 color;
    float2 uv;
}

@shader vertex
SharedBindingsSappVsOut shared_bindings_sapp_vs(
    @attr(0) float4 pos,
    @attr(1) float4 color0,
    @attr(2) float2 texcoord0,
    @uniform float4x4 mvp
) {
    SharedBindingsSappVsOut o;
    o.pos = mul(mvp, pos);
    o.color = color0;
    o.uv = texcoord0 * 5.0f;
    return o;
}

@shader fragment
float4 shared_bindings_sapp_fs_red(
SharedBindingsSappVsOut input,
    @texture(0) Texture2D tex_red,
    @sampler(8) Sampler smp_red
) {
    return sample(tex_red, smp_red, input.uv) * input.color;
}

@shader fragment
float4 shared_bindings_sapp_fs_green(
SharedBindingsSappVsOut input,
    @texture(2) Texture2D tex_green,
    @sampler(4) Sampler smp_green
) {
    return sample(tex_green, smp_green, input.uv) * input.color;
}

@shader fragment
float4 shared_bindings_sapp_fs_blue(
SharedBindingsSappVsOut input,
    @texture(4) Texture2D tex_blue,
    @sampler(2) Sampler smp_blue
) {
    return sample(tex_blue, smp_blue, input.uv) * input.color;
}


enum __enum_ATTR_red_pos {
    ATTR_red_pos = 0,
    ATTR_red_color0 = 1,
    ATTR_red_texcoord0 = 2,
    ATTR_green_pos = 0,
    ATTR_green_color0 = 1,
    ATTR_green_texcoord0 = 2,
    ATTR_blue_pos = 0,
    ATTR_blue_color0 = 1,
    ATTR_blue_texcoord0 = 2,
    UB_vs_params = 0,
    VIEW_tex_red = 0,
    SMP_smp_red = 8,
    VIEW_tex_green = 2,
    SMP_smp_green = 4,
    VIEW_tex_blue = 4,
    SMP_smp_blue = 2,
    __shim_end = 255,
}

type __arr_u32_4 = u32[4];
// Replaces the sokol-shdc generated shared-bindings-sapp.glsl.h.
struct vs_params_t {
    mat44_t mvp;
}

private struct state_t {
    f32 rx;
    f32 ry;
    sg_bindings bind;
    sg_pipeline[3] pip;
    sg_pass_action pass_action;
}

struct vertex_t {
    f32 x;
    f32 y;
    f32 z;
    u32 color;
    i16 u;
    i16 v;
}

private { state_t state; }

private {
void init() {
    sg_setup(&sg_desc{.environment = sglue_environment(), .logger = sg_logger{.func = slog_func}});
    __dbgui_setup();
    state.pass_action = sg_pass_action{
        .colors[0] = {.load_action = SG_LOADACTION_CLEAR, .clear_value = {0.0f, 0.0f, 0.0f, 1.0f}},
    };
    vertex_t[24] vertices = {
        vertex_t{-1.0f, -1.0f, -1.0f, 0xFFFFFFFF, 0, 0},
        vertex_t{1.0f, -1.0f, -1.0f, 0xFFFFFFFF, 32767, 0},
        vertex_t{1.0f, 1.0f, -1.0f, 0xFFFFFFFF, 32767, 32767},
        vertex_t{-1.0f, 1.0f, -1.0f, 0xFFFFFFFF, 0, 32767},
        vertex_t{-1.0f, -1.0f, 1.0f, 0xFFDDDDDD, 0, 0},
        vertex_t{1.0f, -1.0f, 1.0f, 0xFFDDDDDD, 32767, 0},
        vertex_t{1.0f, 1.0f, 1.0f, 0xFFDDDDDD, 32767, 32767},
        vertex_t{-1.0f, 1.0f, 1.0f, 0xFFDDDDDD, 0, 32767},
        vertex_t{-1.0f, -1.0f, -1.0f, 0xFFBBBBBB, 0, 0},
        vertex_t{-1.0f, 1.0f, -1.0f, 0xFFBBBBBB, 32767, 0},
        vertex_t{-1.0f, 1.0f, 1.0f, 0xFFBBBBBB, 32767, 32767},
        vertex_t{-1.0f, -1.0f, 1.0f, 0xFFBBBBBB, 0, 32767},
        vertex_t{1.0f, -1.0f, -1.0f, 0xFF999999, 0, 0},
        vertex_t{1.0f, 1.0f, -1.0f, 0xFF999999, 32767, 0},
        vertex_t{1.0f, 1.0f, 1.0f, 0xFF999999, 32767, 32767},
        vertex_t{1.0f, -1.0f, 1.0f, 0xFF999999, 0, 32767},
        vertex_t{-1.0f, -1.0f, -1.0f, 0xFF777777, 0, 0},
        vertex_t{-1.0f, -1.0f, 1.0f, 0xFF777777, 32767, 0},
        vertex_t{1.0f, -1.0f, 1.0f, 0xFF777777, 32767, 32767},
        vertex_t{1.0f, -1.0f, -1.0f, 0xFF777777, 0, 32767},
        vertex_t{-1.0f, 1.0f, -1.0f, 0xFF555555, 0, 0},
        vertex_t{-1.0f, 1.0f, 1.0f, 0xFF555555, 32767, 0},
        vertex_t{1.0f, 1.0f, 1.0f, 0xFF555555, 32767, 32767},
        vertex_t{1.0f, 1.0f, -1.0f, 0xFF555555, 0, 32767},
    };
    state.bind.vertex_buffers[0] = sg_make_buffer(&sg_buffer_desc{
        .data = sg_range{&vertices, sizeof(vertices)},
        .label = "cube-vertices",
    });
    u16[36] indices = {
        0, 1, 2, 0, 2, 3, 6, 5, 4, 7, 6, 4, 8, 9, 10, 8, 10, 11, 14, 13, 12, 15, 14, 12, 16, 17, 18,
        16, 18, 19, 22, 21, 20, 23, 22, 20,
    };
    state.bind.index_buffer = sg_make_buffer(&sg_buffer_desc{
        .usage = sg_buffer_usage{.index_buffer = true},
        .data = sg_range{&indices, sizeof(indices)},
        .label = "cube-indices",
    });
    for i32 i = 0; i < 3; i++ {
        i32 view_slot;
        i32 smp_slot;
        u32 color;
        u8* image_label;
        u8* view_label;
        u8* smp_label;
        u8* pip_label;
        noinit sg_shader shd;
        switch i {
            case 0: {
                view_slot = VIEW_tex_red;
                smp_slot = SMP_smp_red;
                color = 0xFF0000FF;
                image_label = "red-image";
                view_label = "red-texture-view";
                smp_label = "red-sampler";
                pip_label = "red-pipeline";
                shd = sokol_make_shader(&shared_bindings_sapp_vs_shader, &shared_bindings_sapp_fs_red_shader);
            }
            case 1: {
                view_slot = VIEW_tex_green;
                smp_slot = SMP_smp_green;
                color = 0xFF00FF00;
                image_label = "green-image";
                view_label = "green-texture-view";
                smp_label = "green-sampler";
                pip_label = "green-pipeline";
                shd = sokol_make_shader(&shared_bindings_sapp_vs_shader, &shared_bindings_sapp_fs_green_shader);
            }
            default: {
                view_slot = VIEW_tex_blue;
                smp_slot = SMP_smp_blue;
                color = 0xFFFF0000;
                image_label = "blue-image";
                view_label = "blue-texture-view";
                smp_label = "blue-sampler";
                pip_label = "blue-pipeline";
                shd = sokol_make_shader(&shared_bindings_sapp_vs_shader, &shared_bindings_sapp_fs_blue_shader);
            }
        }
        noinit __arr_u32_4[4] pixels;
        for i32 y = 0; y < 4; y++ {
            for i32 x = 0; x < 4; x++ {
                pixels[y][x] = ((x ^ y) & 1) != 0 ? color : 0xFF000000;
            }
        }
        state.bind.views[view_slot] = sg_make_view(&sg_view_desc{
            .texture = sg_texture_view_desc{
                .image = sg_make_image(&sg_image_desc{
                    .width = 4,
                    .height = 4,
                    .data = sg_image_data{.mip_levels[0] = sg_range{&pixels, sizeof(pixels)}},
                    .label = image_label,
                }),
            },
            .label = view_label,
        });
        state.bind.samplers[smp_slot] = sg_make_sampler(&sg_sampler_desc{.label = smp_label});
        state.pip[i] = sg_make_pipeline(&sg_pipeline_desc{
            .shader = shd,
            .layout = sg_vertex_layout_state{
                .attrs[0] = {.format = SG_VERTEXFORMAT_FLOAT3},
                .attrs[1] = {.format = SG_VERTEXFORMAT_UBYTE4N},
                .attrs[2] = {.format = SG_VERTEXFORMAT_SHORT2N},
            },
            .index_type = SG_INDEXTYPE_UINT16,
            .cull_mode = SG_CULLMODE_BACK,
            .depth = sg_depth_state{.compare = SG_COMPAREFUNC_LESS_EQUAL, .write_enabled = true},
            .label = pip_label,
        });
    }
}

void frame() {
    var dt = cast(f32, sapp_frame_duration() * 60.0);
    f32 dw = sapp_widthf();
    f32 dh = sapp_heightf();
    state.rx += 1.0f * dt;
    state.ry += 2.0f * dt;
    var vs_params = vs_params_t{.mvp = compute_mvp()};
    f32 vpw = dw * 0.333f;
    f32 vph = vpw;
    f32 vpy = dh * 0.5f - vph * 0.5f;
    sg_begin_pass(&sg_pass{.action = state.pass_action, .swapchain = sglue_swapchain()});
    for i32 i = 0; i < 3; i++ {
        f32 vpx = dw * 0.5f - 1.5f * vpw + cast(f32, i) * vpw;
        sg_apply_viewportf(vpx, vpy, vpw, vph, true);
        sg_apply_pipeline(state.pip[i]);
        sg_apply_bindings(&state.bind);
        sg_apply_uniforms(UB_vs_params, &sg_range{&vs_params, sizeof(vs_params)});
        sg_draw(0, 36, 1);
    }
    __dbgui_draw();
    sg_end_pass();
    sg_commit();
}

void cleanup() {
    __dbgui_shutdown();
    sg_shutdown();
}

mat44_t compute_mvp() {
    mat44_t proj = mat44_perspective_fov_rh(vecmath_radians(60.0f), 1.0f, 0.01f, 10.0f);
    mat44_t view = mat44_look_at_rh(vec3(0.0f, 0.0f, 4.0f), vec3(0.0f, 0.0f, 0.0f), vec3(0.0f, 1.0f, 0.0f));
    mat44_t rxm = mat44_rotation_x(vecmath_radians(state.rx));
    mat44_t rym = mat44_rotation_y(vecmath_radians(state.ry));
    mat44_t model = mat44_mul_mat44(rym, rxm);
    return mat44_mul_mat44(model, mat44_mul_mat44(view, proj));
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
        .window_title = "shared-bindings-sapp.mc",
        .icon = sapp_icon_desc{.sokol_default = true},
        .logger = sapp_logger{.func = slog_func},
    };
}
