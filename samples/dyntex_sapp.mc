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

// Tiny libc surface some samples touch. rand() matches C's contract
// (0..RAND_MAX, deterministic per seed) via a 32-bit xorshift.

private { u32 __sapp_rand_state = 0x12345678; }

const i32 RAND_MAX_C = 0x7fffffff;

i32 rand() {
    u32 x = __sapp_rand_state;
    x = x ^ (x << 13);
    x = x ^ (x >> 17);
    x = x ^ (x << 5);
    __sapp_rand_state = x;
    return cast(i32, x & 0x7fffffff);
}

void srand(u32 seed) {
    if seed == 0 { seed = 1; }
    __sapp_rand_state = seed;
}

// dyntex-sapp.glsl - ported to minc @shader.

struct DyntexSappVsOut {
    float4 pos;
    float4 color;
    float2 uv;
}

@shader vertex
DyntexSappVsOut dyntex_sapp_vs(
    @attr(0) float4 position,
    @attr(1) float4 color0,
    @attr(2) float2 texcoord0,
    @uniform float4x4 mvp
) {
    DyntexSappVsOut o;
    o.pos = mul(mvp, position);
    o.uv = texcoord0;
    o.color = color0;
    return o;
}

@shader fragment
float4 dyntex_sapp_fs(
DyntexSappVsOut input,
    @texture(0) Texture2D tex,
    @sampler(0) Sampler smp
) {
    return sample(tex, smp, input.uv) * input.color;
}


enum __enum_ATTR_dyntex_position {
    ATTR_dyntex_position = 0,
    ATTR_dyntex_color0 = 1,
    ATTR_dyntex_texcoord0 = 2,
    UB_vs_params = 0,
    VIEW_tex = 0,
    SMP_smp = 0,
    __shim_end = 255,
}

type __arr_u32_64 = u32[64];
// Replaces the sokol-shdc generated dyntex-sapp.glsl.h.
struct vs_params_t {
    mat44_t mvp;
}

private struct state_t {
    sg_pass_action pass_action;
    sg_pipeline pip;
    sg_image img;
    sg_bindings bind;
    f32 rx;
    f32 ry;
    i32 update_count;
    __arr_u32_64[64] pixels;
}

private { state_t state; }

private {
void init() {
    sg_setup(&sg_desc{.environment = sglue_environment(), .logger = sg_logger{.func = slog_func}});
    __dbgui_setup();
    state.img = sg_make_image(&sg_image_desc{
        .width = 64,
        .height = 64,
        .pixel_format = SG_PIXELFORMAT_RGBA8,
        .usage = sg_image_usage{.stream_update = true},
        .label = "dynamic-texture",
    });
    sg_view tex_view = sg_make_view(&sg_view_desc{
        .texture = sg_texture_view_desc{.image = state.img},
        .label = "dynamic-texture-view",
    });
    sg_sampler smp = sg_make_sampler(&sg_sampler_desc{
        .min_filter = SG_FILTER_LINEAR,
        .mag_filter = SG_FILTER_LINEAR,
        .wrap_u = SG_WRAP_CLAMP_TO_EDGE,
        .wrap_v = SG_WRAP_CLAMP_TO_EDGE,
        .label = "sampler",
    });
    f32[216] vertices = {
        -1.0f, -1.0f, -1.0f, 1.0f, 0.0f, 0.0f, 1.0f, 0.0f, 0.0f, 1.0f, -1.0f, -1.0f, 1.0f, 0.0f,
        0.0f, 1.0f, 1.0f, 0.0f, 1.0f, 1.0f, -1.0f, 1.0f, 0.0f, 0.0f, 1.0f, 1.0f, 1.0f, -1.0f, 1.0f,
        -1.0f, 1.0f, 0.0f, 0.0f, 1.0f, 0.0f, 1.0f, -1.0f, -1.0f, 1.0f, 0.0f, 1.0f, 0.0f, 1.0f, 0.0f,
        0.0f, 1.0f, -1.0f, 1.0f, 0.0f, 1.0f, 0.0f, 1.0f, 1.0f, 0.0f, 1.0f, 1.0f, 1.0f, 0.0f, 1.0f,
        0.0f, 1.0f, 1.0f, 1.0f, -1.0f, 1.0f, 1.0f, 0.0f, 1.0f, 0.0f, 1.0f, 0.0f, 1.0f, -1.0f, -1.0f,
        -1.0f, 0.0f, 0.0f, 1.0f, 1.0f, 0.0f, 0.0f, -1.0f, 1.0f, -1.0f, 0.0f, 0.0f, 1.0f, 1.0f, 1.0f,
        0.0f, -1.0f, 1.0f, 1.0f, 0.0f, 0.0f, 1.0f, 1.0f, 1.0f, 1.0f, -1.0f, -1.0f, 1.0f, 0.0f, 0.0f,
        1.0f, 1.0f, 0.0f, 1.0f, 1.0f, -1.0f, -1.0f, 1.0f, 0.5f, 0.0f, 1.0f, 0.0f, 0.0f, 1.0f, 1.0f,
        -1.0f, 1.0f, 0.5f, 0.0f, 1.0f, 1.0f, 0.0f, 1.0f, 1.0f, 1.0f, 1.0f, 0.5f, 0.0f, 1.0f, 1.0f,
        1.0f, 1.0f, -1.0f, 1.0f, 1.0f, 0.5f, 0.0f, 1.0f, 0.0f, 1.0f, -1.0f, -1.0f, -1.0f, 0.0f,
        0.5f, 1.0f, 1.0f, 0.0f, 0.0f, -1.0f, -1.0f, 1.0f, 0.0f, 0.5f, 1.0f, 1.0f, 1.0f, 0.0f, 1.0f,
        -1.0f, 1.0f, 0.0f, 0.5f, 1.0f, 1.0f, 1.0f, 1.0f, 1.0f, -1.0f, -1.0f, 0.0f, 0.5f, 1.0f, 1.0f,
        0.0f, 1.0f, -1.0f, 1.0f, -1.0f, 1.0f, 0.0f, 0.5f, 1.0f, 0.0f, 0.0f, -1.0f, 1.0f, 1.0f, 1.0f,
        0.0f, 0.5f, 1.0f, 1.0f, 0.0f, 1.0f, 1.0f, 1.0f, 1.0f, 0.0f, 0.5f, 1.0f, 1.0f, 1.0f, 1.0f,
        1.0f, -1.0f, 1.0f, 0.0f, 0.5f, 1.0f, 0.0f, 1.0f,
    };
    u16[36] indices = {
        0, 1, 2, 0, 2, 3, 6, 5, 4, 7, 6, 4, 8, 9, 10, 8, 10, 11, 14, 13, 12, 15, 14, 12, 16, 17, 18,
        16, 18, 19, 22, 21, 20, 23, 22, 20,
    };
    sg_buffer vbuf = sg_make_buffer(&sg_buffer_desc{
        .data = sg_range{&vertices, sizeof(vertices)},
        .label = "cube-vertices",
    });
    sg_buffer ibuf = sg_make_buffer(&sg_buffer_desc{
        .usage = sg_buffer_usage{.index_buffer = true},
        .data = sg_range{&indices, sizeof(indices)},
        .label = "cube-indices",
    });
    sg_shader shd = sokol_make_shader(&dyntex_sapp_vs_shader, &dyntex_sapp_fs_shader);
    state.pip = sg_make_pipeline(&sg_pipeline_desc{
        .layout = sg_vertex_layout_state{
            .attrs[0] = {.format = SG_VERTEXFORMAT_FLOAT3},
            .attrs[1] = {.format = SG_VERTEXFORMAT_FLOAT4},
            .attrs[2] = {.format = SG_VERTEXFORMAT_FLOAT2},
        },
        .shader = shd,
        .index_type = SG_INDEXTYPE_UINT16,
        .cull_mode = SG_CULLMODE_BACK,
        .depth = sg_depth_state{.compare = SG_COMPAREFUNC_LESS_EQUAL, .write_enabled = true},
        .label = "cube-pipelin",
    });
    state.bind = sg_bindings{
        .vertex_buffers[0] = vbuf,
        .index_buffer = ibuf,
        .views[0] = tex_view,
        .samplers[0] = smp,
    };
    game_of_life_init();
}

void frame() {
    var t = cast(f32, sapp_frame_duration() * 60.0);
    state.rx += 1.0f * t;
    state.ry += 2.0f * t;
    vs_params_t vs_params = compute_vsparams(state.rx, state.ry);
    game_of_life_update();
    sg_update_image(state.img, &sg_image_data{.mip_levels[0] = sg_range{&state.pixels, sizeof(state.pixels)}});
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

void game_of_life_init() {
    for i32 y = 0; y < 64; y++ {
        for i32 x = 0; x < 64; x++ {
            if (rand() & 255) > 230 {
                state.pixels[y][x] = 0xFFFFFFFF;
            } else {
                state.pixels[y][x] = 0xFF000000;
            }
        }
    }
}

void game_of_life_update() {
    for i32 y = 0; y < 64; y++ {
        for i32 x = 0; x < 64; x++ {
            i32 num_living_neighbours = 0;
            for i32 ny = -1; ny < 2; ny++ {
                for i32 nx = -1; nx < 2; nx++ {
                    if nx == 0 && ny == 0 {
                        continue;
                    }
                    if state.pixels[y + ny & 64 - 1][x + nx & 64 - 1] == 0xFFFFFFFF {
                        num_living_neighbours++;
                    }
                }
            }
            if state.pixels[y][x] == 0xFFFFFFFF {
                if num_living_neighbours < 2 {
                    state.pixels[y][x] = 0xFF000000;
                } else if num_living_neighbours > 3 {
                    state.pixels[y][x] = 0xFF000000;
                }
            } else if num_living_neighbours == 3 {
                state.pixels[y][x] = 0xFFFFFFFF;
            }
        }
    }
    if state.update_count++ > 240 {
        game_of_life_init();
        state.update_count = 0;
    }
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
        .window_title = "dyntex-sapp.mc",
        .icon = sapp_icon_desc{.sokol_default = true},
        .logger = sapp_logger{.func = slog_func},
    };
}
