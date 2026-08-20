import dbgui;
import sapp_util;
import sokol_debugtext;
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

// cubemap-jpeg-sapp.glsl - ported to minc @shader.

struct CubemapJpegSappVsOut {
    float4 pos;
    float3 uvw;
}

@shader vertex
CubemapJpegSappVsOut cubemap_jpeg_sapp_vs(
    @attr(0) float4 pos,
    @uniform float4x4 mvp
) {
    CubemapJpegSappVsOut o;
    o.pos = mul(mvp, pos);
    o.uvw = normalize(pos.xyz);
    return o;
}

@shader fragment
float4 cubemap_jpeg_sapp_fs(
CubemapJpegSappVsOut input,
    @texture(0) TextureCube tex,
    @sampler(0) Sampler smp
) {
    return sample(tex, smp, input.uvw);
}


enum __enum_ATTR_cubemap_pos {
    ATTR_cubemap_pos = 0,
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
/*
    Quick'n'dirty Maya-style camera. Include after vecmath.h
    and sokol_app.h
*/
struct camera_desc_t {
    f32 min_dist;
    f32 max_dist;
    f32 min_lat;
    f32 max_lat;
    f32 distance;
    f32 latitude;
    f32 longitude;
    f32 fov;
    f32 nearz;
    f32 farz;
    vec3_t center;
}

struct camera_t {
    f32 min_dist;
    f32 max_dist;
    f32 min_lat;
    f32 max_lat;
    f32 distance;
    f32 latitude;
    f32 longitude;
    f32 fov;
    f32 nearz;
    f32 farz;
    vec3_t center;
    vec3_t eye_pos;
    mat44_t view;
    mat44_t proj;
    mat44_t view_proj;
}

// Replaces the sokol-shdc generated cubemap-jpeg-sapp.glsl.h.
struct vs_params_t {
    mat44_t mvp;
}

private struct state_t {
    sg_pass_action pass_action;
    sg_image img;
    sg_pipeline pip;
    sg_bindings bind;
    camera_t camera;
    i32 load_count;
    bool load_failed;
}

private {
f32 _cam_def(f32 val, f32 def) {
    return val == 0.0f ? def : val;
}

/* initialize to default parameters */
void cam_init(camera_t* cam, camera_desc_t* desc) {
    memset(cam, 0, cast(u64, sizeof(camera_t)));
    cam.min_dist = _cam_def(desc.min_dist, 2.0f);
    cam.max_dist = _cam_def(desc.max_dist, 30.0f);
    cam.min_lat = _cam_def(desc.min_lat, -85.0f);
    cam.max_lat = _cam_def(desc.max_lat, 85.0f);
    cam.distance = _cam_def(desc.distance, 5.0f);
    cam.center = desc.center;
    cam.latitude = desc.latitude;
    cam.longitude = desc.longitude;
    cam.fov = _cam_def(desc.fov, 60.0f);
    cam.nearz = _cam_def(desc.nearz, 0.01f);
    cam.farz = _cam_def(desc.farz, 100.0f);
}

/* feed mouse movement */
void cam_orbit(camera_t* cam, f32 dx, f32 dy) {
    cam.longitude -= dx;
    if cam.longitude < 0.0f {
        cam.longitude += 360.0f;
    }
    if cam.longitude > 360.0f {
        cam.longitude -= 360.0f;
    }
    cam.latitude = vecmath_clamp(cam.latitude + dy, cam.min_lat, cam.max_lat);
}

/* feed zoom (mouse wheel) input */
void cam_zoom(camera_t* cam, f32 d) {
    cam.distance = vecmath_clamp(cam.distance + d * cam.distance * 0.1f, cam.min_dist, cam.max_dist);
}

vec3_t _cam_euclidean(f32 latitude, f32 longitude) {
    f32 lat = vecmath_radians(latitude);
    f32 lng = vecmath_radians(longitude);
    return vec3(vecmath_cos(lat) * vecmath_sin(lng), vecmath_sin(lat), vecmath_cos(lat) * vecmath_cos(lng));
}

/* update the view, proj and view_proj matrix */
void cam_update(camera_t* cam, i32 fb_width, i32 fb_height) {
    var w = cast(f32, fb_width);
    var h = cast(f32, fb_height);
    cam.eye_pos = vec3_add(cam.center, vec3_mulf(_cam_euclidean(cam.latitude, cam.longitude), cam.distance));
    cam.view = mat44_look_at_rh(cam.eye_pos, cam.center, vec3(0.0f, 1.0f, 0.0f));
    cam.proj = mat44_perspective_fov_rh(vecmath_radians(cam.fov), w / h, cam.nearz, cam.farz);
    cam.view_proj = mat44_mul_mat44(cam.view, cam.proj);
}

/* handle sokol-app input events */
void cam_handle_event(camera_t* cam, sapp_event* ev) {
    switch ev.type {
        case SAPP_EVENTTYPE_MOUSE_DOWN: {
            if ev.mouse_button == SAPP_MOUSEBUTTON_LEFT {
                sapp_lock_mouse(true);
            }
        }
        case SAPP_EVENTTYPE_MOUSE_UP: {
            if ev.mouse_button == SAPP_MOUSEBUTTON_LEFT {
                sapp_lock_mouse(false);
            }
        }
        case SAPP_EVENTTYPE_MOUSE_SCROLL: {
            cam_zoom(cam, ev.scroll_y * 0.5f);
        }
        case SAPP_EVENTTYPE_MOUSE_MOVE: {
            if sapp_mouse_locked() != 0 {
                cam_orbit(cam, ev.mouse_dx * 0.25f, ev.mouse_dy * 0.25f);
            }
        }
        default: {
        }
    }
}
}
private {
state_t state;
u8[16777216] iobuffer;
}

private {
void init() {
    sg_setup(&sg_desc{.environment = sglue_environment(), .logger = sg_logger{.func = slog_func}});
    __dbgui_setup();
    sdtx_setup(&sdtx_desc_t{
        .fonts[0] = sdtx_font_oric(),
        .logger = sdtx_logger_t{.func = slog_func},
    });
    sfetch_setup(&sfetch_desc_t{
        .max_requests = 6,
        .num_channels = 1,
        .num_lanes = 1,
        .logger = sfetch_logger_t{.func = slog_func},
    });
    cam_init(&state.camera, &camera_desc_t{
        .latitude = 0.0f,
        .longitude = 0.0f,
        .distance = 0.1f,
        .min_dist = 0.1f,
        .max_dist = 0.1f,
    });
    state.pass_action = sg_pass_action{
        .colors[0] = {.load_action = SG_LOADACTION_CLEAR, .clear_value = {0.0f, 0.0f, 0.0f, 1.0f}},
    };
    f32[72] vertices = {
        -1.0f, -1.0f, -1.0f, 1.0f, -1.0f, -1.0f, 1.0f, 1.0f, -1.0f, -1.0f, 1.0f, -1.0f, -1.0f,
        -1.0f, 1.0f, 1.0f, -1.0f, 1.0f, 1.0f, 1.0f, 1.0f, -1.0f, 1.0f, 1.0f, -1.0f, -1.0f, -1.0f,
        -1.0f, 1.0f, -1.0f, -1.0f, 1.0f, 1.0f, -1.0f, -1.0f, 1.0f, 1.0f, -1.0f, -1.0f, 1.0f, 1.0f,
        -1.0f, 1.0f, 1.0f, 1.0f, 1.0f, -1.0f, 1.0f, -1.0f, -1.0f, -1.0f, -1.0f, -1.0f, 1.0f, 1.0f,
        -1.0f, 1.0f, 1.0f, -1.0f, -1.0f, -1.0f, 1.0f, -1.0f, -1.0f, 1.0f, 1.0f, 1.0f, 1.0f, 1.0f,
        1.0f, 1.0f, -1.0f,
    };
    state.bind.vertex_buffers[0] = sg_make_buffer(&sg_buffer_desc{
        .data = sg_range{&vertices, sizeof(vertices)},
        .label = "cubemap-vertices",
    });
    u16[36] indices = {
        0, 1, 2, 0, 2, 3, 6, 5, 4, 7, 6, 4, 8, 9, 10, 8, 10, 11, 14, 13, 12, 15, 14, 12, 16, 17, 18,
        16, 18, 19, 22, 21, 20, 23, 22, 20,
    };
    state.bind.index_buffer = sg_make_buffer(&sg_buffer_desc{
        .usage = sg_buffer_usage{.index_buffer = true},
        .data = sg_range{&indices, sizeof(indices)},
        .label = "cubemap-indices",
    });
    state.img = sg_make_image(&sg_image_desc{
        .usage = sg_image_usage{.write_unsealed = true},
        .type = SG_IMAGETYPE_CUBE,
        .width = 2048,
        .height = 2048,
        .pixel_format = SG_PIXELFORMAT_RGBA8,
        .label = "cubemap-image",
    });
    state.bind.views[VIEW_tex] = sg_make_view(&sg_view_desc{
        .texture = sg_texture_view_desc{.image = state.img},
        .label = "cubemap-view",
    });
    state.bind.samplers[SMP_smp] = sg_make_sampler(&sg_sampler_desc{
        .min_filter = SG_FILTER_LINEAR,
        .mag_filter = SG_FILTER_LINEAR,
        .label = "cubemap-sampler",
    });
    state.pip = sg_make_pipeline(&sg_pipeline_desc{
        .layout = sg_vertex_layout_state{.attrs[0] = {.format = SG_VERTEXFORMAT_FLOAT3}},
        .shader = sokol_make_shader(&cubemap_jpeg_sapp_vs_shader, &cubemap_jpeg_sapp_fs_shader),
        .index_type = SG_INDEXTYPE_UINT16,
        .depth = sg_depth_state{.compare = SG_COMPAREFUNC_LESS_EQUAL, .write_enabled = true},
        .label = "cubemap-pipeline",
    });
    noinit u8[1024] path_buf;
    u8*[6] filenames = {
        "nb2_posx.jpg", "nb2_negx.jpg", "nb2_posy.jpg", "nb2_negy.jpg", "nb2_posz.jpg",
        "nb2_negz.jpg",
    };
    for i32 face_index = 0; face_index < 6; face_index++ {
        sfetch_send(&sfetch_request_t{
            .path = fileutil_get_path(filenames[face_index], path_buf, cast(u64, sizeof(path_buf))),
            .callback = fetch_cb,
            .buffer = sfetch_range_t{&iobuffer, sizeof(iobuffer)},
            .user_data = sfetch_range_t{&face_index, sizeof(face_index)},
        });
    }
}

void fetch_cb(sfetch_response_t* response) {
    if response.fetched != 0 {
        i32 width;
        i32 height;
        i32 channels_in_file;
        i32 desired_channels = 4;
        stbi_uc* decoded_pixels = stbi_load_from_memory(response.data.ptr, cast(i32, response.data.size), &width, &height, &channels_in_file, desired_channels);
        if decoded_pixels != null {
            i32 face_index = *cast(i32*, response.user_data);
            sg_write_image_unsealed(&sg_write_image_desc{
                .src = sg_write_image_source{.data = sg_range{.ptr = decoded_pixels, .size = cast(u64, 2048 * 2048 * 4)}},
                .dst = sg_image_location{.image = state.img, .mip_level = 0, .slice = face_index},
                .size = sg_image_extent{.num_slices = 1},
            });
            stbi_image_free(decoded_pixels);
            if ++state.load_count == 6 {
                sg_seal_image(state.img);
            }
        }
    } else if response.failed != 0 {
        state.load_failed = true;
    }
}

void frame() {
    sfetch_dowork();
    cam_update(&state.camera, sapp_width(), sapp_height());
    var vs_params = vs_params_t{.mvp = state.camera.view_proj};
    sdtx_canvas(sapp_widthf() * 0.5f, sapp_heightf() * 0.5f);
    sdtx_origin(1.0f, 1.0f);
    if state.load_failed != 0 {
        sdtx_puts("LOAD FAILED!");
    } else if state.load_count < 6 {
        sdtx_puts("LOADING ...");
    } else {
        sdtx_puts("LMB + move mouse to look around");
    }
    sg_begin_pass(&sg_pass{.action = state.pass_action, .swapchain = sglue_swapchain()});
    sg_apply_pipeline(state.pip);
    sg_apply_bindings(&state.bind);
    sg_apply_uniforms(UB_vs_params, &sg_range{&vs_params, sizeof(vs_params)});
    sg_draw(0, 36, 1);
    sdtx_draw();
    __dbgui_draw();
    sg_end_pass();
    sg_commit();
}

void cleanup() {
    __dbgui_shutdown();
    sfetch_shutdown();
    sdtx_shutdown();
    sg_shutdown();
}

void input(sapp_event* ev) {
    if __dbgui_event_with_retval(ev) != 0 {
        return;
    }
    cam_handle_event(&state.camera, ev);
}
}

sapp_desc __sapp_sample_main() {
    return sapp_desc{
        .init_cb = init,
        .frame_cb = frame,
        .cleanup_cb = cleanup,
        .event_cb = input,
        .width = 800,
        .height = 600,
        .sample_count = 1,
        .window_title = "cubemap-jpeg-sapp.mc",
        .icon = sapp_icon_desc{.sokol_default = true},
        .logger = sapp_logger{.func = slog_func},
    };
}
