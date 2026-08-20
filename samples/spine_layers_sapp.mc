import dbgui;
import sapp_util;
import sokol_fetch;
import sokol_gl;
import spine_c;
import sokol_spine;

import sokol_all;
import math;

// force high-dpi, sample entry point is __sapp_sample_main()
sapp_desc sokol_main() {
    sapp_desc d = __sapp_sample_main();
    d.high_dpi = true;
    return d;
}

/* Replaces stb_image.h; the samples only use the
   load-from-memory surface, provided by ext/sokol_samples/
   stbi_shim.mc over lib/png.mc + lib/jpeg.mc (RGBA8). Extern-included:
   declarations register, nothing emits. */
type stbi_uc = u8;
struct load_status_t {
    bool loaded;
    sspine_range data;
}

private struct state_t {
    sspine_atlas atlas;
    sspine_skeleton skeleton;
    sspine_instance[3] instances;
    sg_pass_action pass_action;
    struct {
        load_status_t atlas;
        load_status_t skeleton;
        bool failed;
    } load_status;
    struct {
        u8[16384] atlas;
        u8[524288] skeleton;
        u8[524288] image;
    } buffers;
}

private { state_t state; }

private {
void init() {
    sg_setup(&sg_desc{.environment = sglue_environment(), .logger = sg_logger{.func = slog_func}});
    sspine_setup(&sspine_desc{.logger = sspine_logger{.func = slog_func}});
    sgl_setup(&sgl_desc_t{.logger = sgl_logger_t{.func = slog_func}});
    sfetch_setup(&sfetch_desc_t{
        .max_requests = 3,
        .num_channels = 2,
        .num_lanes = 1,
        .logger = sfetch_logger_t{.func = slog_func},
    });
    __dbgui_setup();
    state.pass_action = sg_pass_action{
        .colors[0] = {.load_action = SG_LOADACTION_CLEAR, .clear_value = {0.0f, 0.0f, 0.0f, 1.0f}},
    };
    noinit u8[512] path;
    sfetch_send(&sfetch_request_t{
        .path = fileutil_get_path("speedy-pma.atlas", path, cast(u64, sizeof(path))),
        .channel = 0,
        .buffer = sfetch_range_t{&state.buffers.atlas, sizeof(state.buffers.atlas)},
        .callback = atlas_data_loaded,
    });
    sfetch_send(&sfetch_request_t{
        .path = fileutil_get_path("speedy-ess.skel", path, cast(u64, sizeof(path))),
        .channel = 1,
        .buffer = sfetch_range_t{&state.buffers.skeleton, sizeof(state.buffers.skeleton)},
        .callback = skeleton_data_loaded,
    });
}

void frame() {
    var delta_time = cast(f32, sapp_frame_duration());
    sfetch_dowork();
    var layer_transform = sspine_layer_transform{
        .size = sspine_vec2{.x = 1024.0f, .y = 768.0f},
        .origin = sspine_vec2{.x = 512.0f, .y = 384.0f},
    };
    sgl_defaults();
    for i32 layer_index = 0; layer_index < 3; layer_index++ {
        sgl_layer(layer_index);
        switch layer_index {
            case 0: {
                sgl_c3f(0.0f, 0.0f, 1.0f);
            }
            case 1: {
                sgl_c3f(0.0f, 1.0f, 0.0f);
            }
            case 2: {
                sgl_c3f(1.0f, 0.0f, 0.0f);
            }
        }
        sgl_begin_quads();
        i32 num_bars = 30;
        f32 bar_width_half = 0.0075f;
        f32 bar_offset_x = cast(f32, layer_index) * 0.02f;
        for i32 i = 0; i <= num_bars; i++ {
            f32 x = bar_offset_x + (cast(f32, i) * (1.0f / cast(f32, num_bars)) * 2.0f - 1.0f);
            f32 x0 = x - bar_width_half;
            f32 x1 = x + bar_width_half;
            sgl_v2f(x0, -1.0f);
            sgl_v2f(x1, -1.0f);
            sgl_v2f(x1, 1.0f);
            sgl_v2f(x0, 1.0f);
        }
        sgl_end();
    }
    sspine_set_position(state.instances[0], sspine_vec2{-225.0f, 128.0f});
    sspine_update_instance(state.instances[0], delta_time);
    sspine_draw_instance_in_layer(state.instances[0], 0);
    sspine_set_position(state.instances[1], sspine_vec2{0.0f, 128.0f});
    sspine_update_instance(state.instances[1], delta_time);
    sspine_draw_instance_in_layer(state.instances[1], 1);
    sspine_set_position(state.instances[2], sspine_vec2{225.0f, 128.0f});
    sspine_update_instance(state.instances[2], delta_time);
    sspine_draw_instance_in_layer(state.instances[2], 2);
    sg_begin_pass(&sg_pass{.action = state.pass_action, .swapchain = sglue_swapchain()});
    for i32 layer_index = 0; layer_index < 3; layer_index++ {
        sspine_draw_layer(layer_index, &layer_transform);
        sgl_draw_layer(layer_index);
    }
    __dbgui_draw();
    sg_end_pass();
    sg_commit();
}

void cleanup() {
    __dbgui_shutdown();
    sfetch_shutdown();
    sgl_shutdown();
    sspine_shutdown();
    sg_shutdown();
}

// fetch callback for atlas data
void atlas_data_loaded(sfetch_response_t* response) {
    if response.fetched != 0 {
        state.load_status.atlas = load_status_t{
            .loaded = true,
            .data = sspine_range{.ptr = response.data.ptr, .size = response.data.size},
        };
        if state.load_status.atlas.loaded && state.load_status.skeleton.loaded {
            create_spine_objects();
        }
    } else if response.failed != 0 {
        state.load_status.failed = true;
    }
}

// fetch callback for skeleton data
void skeleton_data_loaded(sfetch_response_t* response) {
    if response.fetched != 0 {
        state.load_status.skeleton = load_status_t{
            .loaded = true,
            .data = sspine_range{.ptr = response.data.ptr, .size = response.data.size},
        };
        if state.load_status.atlas.loaded && state.load_status.skeleton.loaded {
            create_spine_objects();
        }
    } else if response.failed != 0 {
        state.load_status.failed = true;
    }
}

// called when both the atlas and skeleton files have been loaded,
// creates spine atlas, skeleton and instance, and starts loading
// the atlas image(s)
void create_spine_objects() {
    state.atlas = sspine_make_atlas(&sspine_atlas_desc{.data = state.load_status.atlas.data});
    state.skeleton = sspine_make_skeleton(&sspine_skeleton_desc{
        .atlas = state.atlas,
        .anim_default_mix = 0.2f,
        .binary_data = state.load_status.skeleton.data,
    });
    for i32 i = 0; i < 3; i++ {
        state.instances[i] = sspine_make_instance(&sspine_instance_desc{.skeleton = state.skeleton});
        sspine_set_animation(state.instances[i], sspine_anim_by_name(state.skeleton, "run-linear"), 0, true);
    }
    i32 num_images = sspine_num_images(state.atlas);
    for i32 img_index = 0; img_index < num_images; img_index++ {
        sspine_image img = sspine_image_by_index(state.atlas, img_index);
        sspine_image_info img_info = sspine_get_image_info(img);
        noinit u8[512] path_buf;
        sfetch_send(&sfetch_request_t{
            .channel = 0,
            .path = fileutil_get_path(img_info.filename.cstr, path_buf, cast(u64, sizeof(path_buf))),
            .buffer = sfetch_range_t{&state.buffers.image, sizeof(state.buffers.image)},
            .callback = image_data_loaded,
            .user_data = sfetch_range_t{&img, sizeof(img)},
        });
    }
}

// load spine atlas image data and create a sokol-gfx image object
void image_data_loaded(sfetch_response_t* response) {
    sspine_image img = *cast(sspine_image*, response.user_data);
    sspine_image_info img_info = sspine_get_image_info(img);
    if response.fetched != 0 {
        i32 desired_channels = 4;
        i32 img_width;
        i32 img_height;
        i32 num_channels;
        stbi_uc* pixels = stbi_load_from_memory(response.data.ptr, cast(i32, response.data.size), &img_width, &img_height, &num_channels, desired_channels);
        if pixels != null {
            sg_init_image(img_info.sgimage, &sg_image_desc{
                .width = img_width,
                .height = img_height,
                .pixel_format = SG_PIXELFORMAT_RGBA8,
                .label = img_info.filename.cstr,
                .data = sg_image_data{
                    .mip_levels[0] = {.ptr = pixels, .size = cast(u64, img_width * img_height * 4)},
                },
            });
            sg_init_view(img_info.sgview, &sg_view_desc{.texture = sg_texture_view_desc{.image = img_info.sgimage}});
            sg_init_sampler(img_info.sgsampler, &sg_sampler_desc{
                .min_filter = img_info.min_filter,
                .mag_filter = img_info.mag_filter,
                .mipmap_filter = img_info.mipmap_filter,
                .wrap_u = img_info.wrap_u,
                .wrap_v = img_info.wrap_v,
                .label = img_info.filename.cstr,
            });
            stbi_image_free(pixels);
        } else {
            state.load_status.failed = true;
            sg_fail_image(img_info.sgimage);
        }
    } else if response.failed != 0 {
        state.load_status.failed = true;
        sg_fail_image(img_info.sgimage);
    }
}
}

sapp_desc __sapp_sample_main() {
    return sapp_desc{
        .init_cb = init,
        .frame_cb = frame,
        .cleanup_cb = cleanup,
        .event_cb = __dbgui_event,
        .width = 1024,
        .height = 768,
        .window_title = "spine-layers-sapp.mc",
        .icon = sapp_icon_desc{.sokol_default = true},
        .logger = sapp_logger{.func = slog_func},
    };
}
