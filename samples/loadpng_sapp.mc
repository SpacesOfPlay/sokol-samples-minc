import dbgui;
import sapp_util;
import sokol_fetch;
import vecmath;

import sokol_all;
import math;

// force high-dpi, sample entry point is __sapp_sample_main()
sapp_desc sokol_main() {
    sapp_desc d = __sapp_sample_main();
    d.high_dpi = true;
    return d;
}

// loadpng-sapp.glsl - ported to minc @shader.

struct LoadpngSappVsOut {
    float4 pos;
    float2 uv;
}

@shader vertex
LoadpngSappVsOut loadpng_sapp_vs(
    @attr(0) float4 pos,
    @attr(1) float2 texcoord0,
    @uniform float4x4 mvp
) {
    LoadpngSappVsOut o;
    o.pos = mul(mvp, pos);
    o.uv = texcoord0;
    return o;
}

@shader fragment
float4 loadpng_sapp_fs(
LoadpngSappVsOut input,
    @texture(0) Texture2D tex,
    @sampler(0) Sampler smp
) {
    return sample(tex, smp, input.uv);
}


enum __enum_ATTR_loadpng_pos {
    ATTR_loadpng_pos = 0,
    ATTR_loadpng_texcoord0 = 1,
    UB_vs_params = 0,
    VIEW_tex = 0,
    SMP_smp = 0,
    __shim_end = 255,
}

/* Replaces stb_image.h; the samples only use the
   load-from-memory surface, provided by ext/sokol_samples/
   stbi_shim.mc over lib/png.mc + lib/jpeg.mc (RGBA8). Extern-included:
   declarations register, nothing emits. */
type stbi_uc = u8;
// Replaces the sokol-shdc generated loadpng-sapp.glsl.h.
struct vs_params_t {
    mat44_t mvp;
}

private struct state_t {
    f32 rx;
    f32 ry;
    sg_pass_action pass_action;
    sg_pipeline pip;
    sg_bindings bind;
    u8[262144] file_buffer;
}

struct vertex_t {
    f32 x;
    f32 y;
    f32 z;
    i16 u;
    i16 v;
}

private { state_t state; }

private {
void init() {
    sg_setup(&sg_desc{.environment = sglue_environment(), .logger = sg_logger{.func = slog_func}});
    __dbgui_setup();
    sfetch_setup(&sfetch_desc_t{
        .max_requests = 1,
        .num_channels = 1,
        .num_lanes = 1,
        .logger = sfetch_logger_t{.func = slog_func},
    });
    state.pass_action = sg_pass_action{
        .colors[0] = {
            .load_action = SG_LOADACTION_CLEAR,
            .clear_value = {0.125f, 0.25f, 0.35f, 1.0f},
        },
    };
    state.bind.views[VIEW_tex] = sg_alloc_view();
    state.bind.samplers[SMP_smp] = sg_make_sampler(&sg_sampler_desc{
        .min_filter = SG_FILTER_LINEAR,
        .mag_filter = SG_FILTER_LINEAR,
        .label = "png-sampler",
    });
    vertex_t[24] vertices = {
        vertex_t{-1.0f, -1.0f, -1.0f, 0, 0},
        vertex_t{1.0f, -1.0f, -1.0f, 32767, 0},
        vertex_t{1.0f, 1.0f, -1.0f, 32767, 32767},
        vertex_t{-1.0f, 1.0f, -1.0f, 0, 32767},
        vertex_t{-1.0f, -1.0f, 1.0f, 0, 0},
        vertex_t{1.0f, -1.0f, 1.0f, 32767, 0},
        vertex_t{1.0f, 1.0f, 1.0f, 32767, 32767},
        vertex_t{-1.0f, 1.0f, 1.0f, 0, 32767},
        vertex_t{-1.0f, -1.0f, -1.0f, 0, 0},
        vertex_t{-1.0f, 1.0f, -1.0f, 32767, 0},
        vertex_t{-1.0f, 1.0f, 1.0f, 32767, 32767},
        vertex_t{-1.0f, -1.0f, 1.0f, 0, 32767},
        vertex_t{1.0f, -1.0f, -1.0f, 0, 0},
        vertex_t{1.0f, 1.0f, -1.0f, 32767, 0},
        vertex_t{1.0f, 1.0f, 1.0f, 32767, 32767},
        vertex_t{1.0f, -1.0f, 1.0f, 0, 32767},
        vertex_t{-1.0f, -1.0f, -1.0f, 0, 0},
        vertex_t{-1.0f, -1.0f, 1.0f, 32767, 0},
        vertex_t{1.0f, -1.0f, 1.0f, 32767, 32767},
        vertex_t{1.0f, -1.0f, -1.0f, 0, 32767},
        vertex_t{-1.0f, 1.0f, -1.0f, 0, 0},
        vertex_t{-1.0f, 1.0f, 1.0f, 32767, 0},
        vertex_t{1.0f, 1.0f, 1.0f, 32767, 32767},
        vertex_t{1.0f, 1.0f, -1.0f, 0, 32767},
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
    state.pip = sg_make_pipeline(&sg_pipeline_desc{
        .shader = sokol_make_shader(&loadpng_sapp_vs_shader, &loadpng_sapp_fs_shader),
        .layout = sg_vertex_layout_state{
            .attrs[0] = {.format = SG_VERTEXFORMAT_FLOAT3},
            .attrs[1] = {.format = SG_VERTEXFORMAT_SHORT2N},
        },
        .index_type = SG_INDEXTYPE_UINT16,
        .cull_mode = SG_CULLMODE_BACK,
        .depth = sg_depth_state{.compare = SG_COMPAREFUNC_LESS_EQUAL, .write_enabled = true},
        .label = "cube-pipeline",
    });
    noinit u8[512] path_buf;
    sfetch_send(&sfetch_request_t{
        .path = fileutil_get_path("baboon.png", path_buf, cast(u64, sizeof(path_buf))),
        .callback = fetch_callback,
        .buffer = sfetch_range_t{&state.file_buffer, sizeof(state.file_buffer)},
    });
}

/* The frame-function is fairly boring, note that no special handling is
   needed for the case where the texture isn't loaded yet.
   Also note the sfetch_dowork() function, this is usually called once a
   frame to pump the sokol-fetch message queues.
*/
void frame() {
    sfetch_dowork();
    var t = cast(f32, sapp_frame_duration() * 60.0);
    state.rx += 1.0f * t;
    state.ry += 2.0f * t;
    vs_params_t vs_params = compute_vsparams(state.rx, state.ry);
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
    sfetch_shutdown();
    sg_shutdown();
}

/* The fetch-callback is called by sokol_fetch.h when the data is loaded,
   or when an error has occurred.
*/
void fetch_callback(sfetch_response_t* response) {
    if response.fetched != 0 {
        i32 png_width;
        i32 png_height;
        i32 num_channels;
        i32 desired_channels = 4;
        stbi_uc* pixels = stbi_load_from_memory(response.data.ptr, cast(i32, response.data.size), &png_width, &png_height, &num_channels, desired_channels);
        if pixels != null {
            sg_image img = sg_make_image(&sg_image_desc{
                .width = png_width,
                .height = png_height,
                .pixel_format = SG_PIXELFORMAT_RGBA8,
                .data = sg_image_data{
                    .mip_levels[0] = {.ptr = pixels, .size = cast(u64, png_width * png_height * 4)},
                },
                .label = "png-image",
            });
            stbi_image_free(pixels);
            sg_init_view(state.bind.views[VIEW_tex], &sg_view_desc{
                .texture = sg_texture_view_desc{.image = img},
                .label = "png-texture-view",
            });
        }
    } else if response.failed != 0 {
        state.pass_action = sg_pass_action{
            .colors[0] = {
                .load_action = SG_LOADACTION_CLEAR,
                .clear_value = {1.0f, 0.0f, 0.0f, 1.0f},
            },
        };
    }
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
        .init_cb = init,
        .frame_cb = frame,
        .cleanup_cb = cleanup,
        .event_cb = __dbgui_event,
        .width = 800,
        .height = 600,
        .sample_count = 4,
        .window_title = "loadpng-sapp.mc",
        .icon = sapp_icon_desc{.sokol_default = true},
        .logger = sapp_logger{.func = slog_func},
    };
}
