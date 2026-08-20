import dbgui;
import sapp_util;
import sokol_fetch;
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
    sspine_instance instance;
    sg_pass_action pass_action;
    struct {
        load_status_t atlas;
        load_status_t skeleton;
        bool failed;
    } load_status;
    struct {
        u8[4096] atlas;
        u8[131072] skeleton;
        u8[524288] image;
    } buffers;
}

private { state_t state; }

private {
void init() {
    sg_setup(&sg_desc{.environment = sglue_environment(), .logger = sg_logger{.func = slog_func}});
    __dbgui_setup();
    sspine_setup(&sspine_desc{
        .max_vertices = 6 * 1024,
        .max_commands = 16,
        .atlas_pool_size = 1,
        .skeleton_pool_size = 1,
        .skinset_pool_size = 1,
        .instance_pool_size = 1,
        .logger = sspine_logger{.func = slog_func},
    });
    sfetch_setup(&sfetch_desc_t{
        .max_requests = 3,
        .num_channels = 2,
        .num_lanes = 1,
        .logger = sfetch_logger_t{.func = slog_func},
    });
    state.pass_action = sg_pass_action{
        .colors[0] = {.load_action = SG_LOADACTION_CLEAR, .clear_value = {0.0f, 0.0f, 0.0f, 1.0f}},
    };
    noinit u8[512] path_buf;
    sfetch_send(&sfetch_request_t{
        .path = fileutil_get_path("raptor-pma.atlas", path_buf, cast(u64, sizeof(path_buf))),
        .channel = 0,
        .buffer = sfetch_range_t{&state.buffers.atlas, sizeof(state.buffers.atlas)},
        .callback = atlas_data_loaded,
    });
    sfetch_send(&sfetch_request_t{
        .path = fileutil_get_path("raptor-pro.skel", path_buf, cast(u64, sizeof(path_buf))),
        .channel = 1,
        .buffer = sfetch_range_t{&state.buffers.skeleton, sizeof(state.buffers.skeleton)},
        .callback = skeleton_data_loaded,
    });
}

// sokol-fetch callback functions for loading the atlas and skeleton data.
// These are called in undefined order, but the spine atlas must be created
// before the skeleton (because the skeleton creation functions needs an
// atlas handle), this ordering problem is solved by both functions checking
// whether the other function has already finished, and if yes a common
// function 'create_spine_objects()' is called
void atlas_data_loaded(sfetch_response_t* response) {
    if response.fetched != 0 {
        state.load_status.atlas = load_status_t{
            .loaded = true,
            .data = sspine_range{response.data.ptr, response.data.size},
        };
        if state.load_status.atlas.loaded && state.load_status.skeleton.loaded {
            create_spine_objects();
        }
    } else if response.failed != 0 {
        state.load_status.failed = true;
    }
}

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

// this function is called when both the spine atlas and skeleton file has been loaded,
// first an atlas object is created from the loaded atlas data, and then a skeleton
// object (which requires an atlas object as dependency), then a spine instance object.
// Finally any images required by the atlas object are loaded
void create_spine_objects() {
    state.atlas = sspine_make_atlas(&sspine_atlas_desc{.data = state.load_status.atlas.data});
    state.skeleton = sspine_make_skeleton(&sspine_skeleton_desc{
        .atlas = state.atlas,
        .binary_data = state.load_status.skeleton.data,
        .prescale = 0.5f,
        .anim_default_mix = 0.2f,
    });
    state.instance = sspine_make_instance(&sspine_instance_desc{.skeleton = state.skeleton});
    sspine_set_position(state.instance, sspine_vec2{.x = -100.0f, .y = 200.0f});
    sspine_set_animation(state.instance, sspine_anim_by_name(state.skeleton, "jump"), 0, false);
    sspine_add_animation(state.instance, sspine_anim_by_name(state.skeleton, "roar"), 0, false, 0.0f);
    sspine_add_animation(state.instance, sspine_anim_by_name(state.skeleton, "walk"), 0, true, 0.0f);
    i32 num_images = sspine_num_images(state.atlas);
    for i32 img_index = 0; img_index < num_images; img_index++ {
        sspine_image img = sspine_image_by_index(state.atlas, img_index);
        sspine_image_info img_info = sspine_get_image_info(img);
        noinit u8[512] path_buf;
        sfetch_send(&sfetch_request_t{
            .path = fileutil_get_path(img_info.filename.cstr, path_buf, cast(u64, sizeof(path_buf))),
            .channel = 0,
            .buffer = sfetch_range_t{&state.buffers.image, sizeof(state.buffers.image)},
            .callback = image_data_loaded,
            .user_data = sfetch_range_t{&img, sizeof(img)},
        });
    }
}

// This is the image-data fetch callback. The loaded image data will be decoded
// via stb_image.h and a sokol-gfx image object will be created.
//
// What's interesting here is that we're using sokol-gfx's multi-step
// image setup. sokol-spine has already allocated an image handle
// for each atlas image in sspine_make_atlas() via sg_alloc_image().
//
// The fetch callback just needs to finish the image setup by
// calling sg_init_image(), or if loading has failed, put the
// image object into the 'failed' resource state.
//
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
    } else {
        state.load_status.failed = true;
        sg_fail_image(img_info.sgimage);
    }
}

// frame callback, whoop whoop!
void frame() {
    sfetch_dowork();
    var delta_time = cast(f32, sapp_frame_duration());
    f32 w = sapp_widthf();
    f32 h = sapp_heightf();
    var layer_transform = sspine_layer_transform{
        .size = sspine_vec2{.x = w, .y = h},
        .origin = sspine_vec2{.x = w * 0.5f, .y = h * 0.5f},
    };
    sspine_update_instance(state.instance, delta_time);
    sspine_draw_instance_in_layer(state.instance, 0);
    sg_begin_pass(&sg_pass{.action = state.pass_action, .swapchain = sglue_swapchain()});
    sspine_draw_layer(0, &layer_transform);
    __dbgui_draw();
    sg_end_pass();
    sg_commit();
}

void cleanup() {
    sfetch_shutdown();
    sspine_shutdown();
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
        .width = 1024,
        .height = 768,
        .depth_format = SAPP_PIXELFORMAT_NONE,
        .window_title = "spine-simple-sapp.mc",
        .icon = sapp_icon_desc{.sokol_default = true},
        .logger = sapp_logger{.func = slog_func},
    };
}
