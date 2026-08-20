import dbgui;
import sapp_util;
import sokol_fetch;
import sokol_debugtext;
import sokol_time;
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
type vec2 = sspine_vec2;
struct load_status_t {
    bool loaded;
    sspine_range data;
}

struct grid_cell_t {
    vec2 pos;
    vec2 vec;
}

private struct state_t {
    sspine_atlas atlas;
    sspine_skeleton skeleton;
    sspine_instance[128] instances;
    sg_pass_action pass_action;
    f32 t;
    u32 t_count;
    grid_cell_t[128] grid;
    struct {
        load_status_t atlas;
        load_status_t skeleton;
        bool failed;
    } load_status;
    struct {
        u8[16384] atlas;
        u8[307200] skeleton;
        u8[524288] image;
    } buffers;
}

/*
    sokol_time.h    -- simple cross-platform time measurement

    Project URL: https://github.com/floooh/sokol

    Do this:
        #define SOKOL_IMPL or
        #define SOKOL_TIME_IMPL
    before you include this file in *one* C or C++ file to create the
    implementation.

    Optionally provide the following defines with your own implementations:
    SOKOL_ASSERT(c)     - your own assert macro (default: assert(c))
    SOKOL_TIME_API_DECL - public function declaration prefix (default: extern)
    SOKOL_API_DECL      - same as SOKOL_TIME_API_DECL
    SOKOL_API_IMPL      - public function implementation prefix (default: -)

    If sokol_time.h is compiled as a DLL, define the following before
    including the declaration or implementation:

    SOKOL_DLL

    On Windows, SOKOL_DLL will define SOKOL_TIME_API_DECL as __declspec(dllexport)
    or __declspec(dllimport) as needed.

    void stm_setup();
        Call once before any other functions to initialize sokol_time
        (this calls for instance QueryPerformanceFrequency on Windows)

    uint64_t stm_now();
        Get current point in time in unspecified 'ticks'. The value that
        is returned has no relation to the 'wall-clock' time and is
        not in a specific time unit, it is only useful to compute
        time differences.

    uint64_t stm_diff(uint64_t new, uint64_t old);
        Computes the time difference between new and old. This will always
        return a positive, non-zero value.

    uint64_t stm_since(uint64_t start);
        Takes the current time, and returns the elapsed time since start
        (this is a shortcut for "stm_diff(stm_now(), start)")

    uint64_t stm_laptime(uint64_t* last_time);
        This is useful for measuring frame time and other recurring
        events. It takes the current time, returns the time difference
        to the value in last_time, and stores the current time in
        last_time for the next call. If the value in last_time is 0,
        the return value will be zero (this usually happens on the
        very first call).

    uint64_t stm_round_to_common_refresh_rate(uint64_t duration)
        This oddly named function takes a measured frame time and
        returns the closest "nearby" common display refresh rate frame duration
        in ticks. If the input duration isn't close to any common display
        refresh rate, the input duration will be returned unchanged as a fallback.
        The main purpose of this function is to remove jitter/inaccuracies from
        measured frame times, and instead use the display refresh rate as
        frame duration.
        NOTE: for more robust frame timing, consider using the
        sokol_app.h function sapp_frame_duration()

    Use the following functions to convert a duration in ticks into
    useful time units:

    double stm_sec(uint64_t ticks);
    double stm_ms(uint64_t ticks);
    double stm_us(uint64_t ticks);
    double stm_ns(uint64_t ticks);
        Converts a tick value into seconds, milliseconds, microseconds
        or nanoseconds. Note that not all platforms will have nanosecond
        or even microsecond precision.

    Uses the following time measurement functions under the hood:

    Windows:        QueryPerformanceFrequency() / QueryPerformanceCounter()
    MacOS/iOS:      mach_absolute_time()
    emscripten:     emscripten_get_now()
    Linux+others:   clock_gettime(CLOCK_MONOTONIC)

    zlib/libpng license

    Copyright (c) 2018 Andre Weissflog

    This software is provided 'as-is', without any express or implied warranty.
    In no event will the authors be held liable for any damages arising from the
    use of this software.

    Permission is granted to anyone to use this software for any purpose,
    including commercial applications, and to alter it and redistribute it
    freely, subject to the following restrictions:

        1. The origin of this software must not be misrepresented; you must not
        claim that you wrote the original software. If you use this software in a
        product, an acknowledgment in the product documentation would be
        appreciated but is not required.

        2. Altered source versions must be plainly marked as such, and must not
        be misrepresented as being the original software.

        3. This notice may not be removed or altered from any source
        distribution.
*/
private { state_t state; }
// unique skins to be combined into skin sets
u8*[8] accessories = {
    "accessories/backpack", "accessories/bag", "accessories/cape-blue", "accessories/cape-red",
    "accessories/hat-pointy-blue-yellow", "accessories/hat-red-yellow", "accessories/scarf",
    "accessories/backpack",
};
u8*[8] clothes = {
    "clothes/dress-blue", "clothes/dress-green", "clothes/hoodie-blue-and-scarf",
    "clothes/hoodie-orange", "clothes/dress-blue", "clothes/dress-green",
    "clothes/hoodie-blue-and-scarf", "clothes/hoodie-orange",
};
u8*[8] eyelids = {
    "eyelids/girly", "eyelids/semiclosed", "eyelids/girly", "eyelids/semiclosed", "eyelids/girly",
    "eyelids/semiclosed", "eyelids/girly", "eyelids/semiclosed",
};
u8*[8] eyes = {
    "eyes/eyes-blue", "eyes/green", "eyes/violet", "eyes/yellow", "eyes/eyes-blue", "eyes/green",
    "eyes/violet", "eyes/yellow",
};
u8*[8] hair = {
    "hair/blue", "hair/brown", "hair/long-blue-with-scarf", "hair/pink", "hair/short-red",
    "hair/blue", "hair/brown", "hair/long-blue-with-scarf",
};
u8*[8] legs = {
    "legs/boots-pink", "legs/boots-red", "legs/pants-green", "legs/pants-jeans", "legs/boots-pink",
    "legs/boots-red", "legs/pants-green", "legs/pants-jeans",
};
u8*[8] nose = {
    "nose/long", "nose/short", "nose/long", "nose/short", "nose/long", "nose/short", "nose/long",
    "nose/short",
};

private {
void init() {
    stm_setup();
    sg_setup(&sg_desc{.environment = sglue_environment(), .logger = sg_logger{.func = slog_func}});
    sdtx_setup(&sdtx_desc_t{
        .fonts[0] = sdtx_font_oric(),
        .logger = sdtx_logger_t{.func = slog_func},
    });
    sspine_setup(&sspine_desc{
        .skinset_pool_size = 16 * 8,
        .instance_pool_size = 16 * 8,
        .max_vertices = 256 * 1024,
        .logger = sspine_logger{.func = slog_func},
    });
    sfetch_setup(&sfetch_desc_t{
        .max_requests = 3,
        .num_channels = 2,
        .num_lanes = 1,
        .logger = sfetch_logger_t{.func = slog_func},
    });
    __dbgui_setup();
    state.pass_action = sg_pass_action{
        .colors[0] = {.load_action = SG_LOADACTION_CLEAR, .clear_value = {0.0f, 0.5f, 0.7f, 1.0f}},
    };
    noinit u8[512] path_buf;
    sfetch_send(&sfetch_request_t{
        .path = fileutil_get_path("mix-and-match-pma.atlas", path_buf, cast(u64, sizeof(path_buf))),
        .channel = 0,
        .buffer = sfetch_range_t{&state.buffers.atlas, sizeof(state.buffers.atlas)},
        .callback = atlas_data_loaded,
    });
    sfetch_send(&sfetch_request_t{
        .path = fileutil_get_path("mix-and-match-pro.skel", path_buf, cast(u64, sizeof(path_buf))),
        .channel = 1,
        .buffer = sfetch_range_t{&state.buffers.skeleton, sizeof(state.buffers.skeleton)},
        .callback = skeleton_data_loaded,
    });
    f32 dx = 64.0f;
    f32 dy = 96.0f;
    f32 y = -dy * cast(f32, 8 / 2) + dy;
    for i32 iy = 0; iy < 8; iy++ {
        f32 x = -dx * cast(f32, 16 / 2) + dx * 0.5f;
        for i32 ix = 0; ix < 16; ix++ {
            grid_cell_t* cell = &state.grid[iy * 16 + ix];
            if (iy & 1) == 0 {
                cell.pos = vec2{x + cast(f32, ix) * dx, y + cast(f32, iy) * dy};
                if ix == 16 - 1 {
                    cell.vec = vec2{0.0f, 1.0f};
                } else {
                    cell.vec = vec2{1.0f, 0.0f};
                }
            } else {
                cell.pos = vec2{x + cast(f32, 16 - 1 - ix) * dx, y + cast(f32, iy) * dy};
                if ix == 16 - 1 {
                    cell.vec = vec2{0.0f, 1.0f};
                } else {
                    cell.vec = vec2{-1.0f, 0.0f};
                }
            }
        }
    }
}

void frame() {
    f64 delta_time = sapp_frame_duration();
    f32 width = sapp_widthf();
    f32 height = sapp_heightf();
    f32 aspect = width / height;
    state.t += cast(f32, delta_time);
    if state.t > 1.0f {
        state.t_count++;
        state.t -= 1.0f;
    }
    sfetch_dowork();
    var virt_size = vec2{1024.0f * aspect, 1024.0f};
    var layer_transform = sspine_layer_transform{
        .size = virt_size,
        .origin = sspine_vec2{.x = virt_size.x * 0.5f, .y = virt_size.y * 0.5f},
    };
    u64 start_time = stm_now();
    for u32 i = 0; i < cast(u32, 16 * 8); i++ {
        u32 grid_index = (i + state.t_count) % cast(u32, 16 * 8);
        vec2 pos = state.grid[grid_index].pos;
        vec2 vec = state.grid[grid_index].vec;
        var p = vec2{.x = pos.x + vec.x * 64.0f * state.t, .y = pos.y + vec.y * 96.0f * state.t};
        sspine_set_position(state.instances[i], p);
        sspine_update_instance(state.instances[i], cast(f32, delta_time));
        sspine_draw_instance_in_layer(state.instances[i], 0);
    }
    f64 eval_time = stm_ms(stm_since(start_time));
    sspine_context_info ctx_info = sspine_get_context_info(sspine_default_context());
    sdtx_canvas(sapp_widthf() * 0.25f, cast(f32, sapp_height()) * 0.25f);
    sdtx_origin(2.0f, 2.0f);
    sdtx_home();
    sdtx_color3b(0, 0, 0);
    sdtx_printf("spine eval time:%.3fms\n", eval_time);
    sdtx_move_y(0.5f);
    sdtx_printf("vertices:%d indices:%d draws:%d", ctx_info.num_vertices, ctx_info.num_indices, ctx_info.num_commands);
    sg_begin_pass(&sg_pass{.action = state.pass_action, .swapchain = sglue_swapchain()});
    sspine_draw_layer(0, &layer_transform);
    sdtx_draw();
    __dbgui_draw();
    sg_end_pass();
    sg_commit();
}

void cleanup() {
    sfetch_shutdown();
    sspine_shutdown();
    __dbgui_shutdown();
    sdtx_shutdown();
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

// returns a xorshift32 random number between 0..<NUM_SKINS
u32 random_skin_index() {
    random_skin_index__x ^= random_skin_index__x << 13;
    random_skin_index__x ^= random_skin_index__x >> 17;
    random_skin_index__x ^= random_skin_index__x << 5;
    return random_skin_index__x & cast(u32, 8 - 1);
}

// called when both the atlas and skeleton files have been loaded,
// creates an sspine_atlas and sspine_skeleton object, starts loading
// the atlas texture(s) and finally creates and sets up spine instances
void create_spine_objects() {
    state.atlas = sspine_make_atlas(&sspine_atlas_desc{.data = state.load_status.atlas.data});
    state.skeleton = sspine_make_skeleton(&sspine_skeleton_desc{
        .atlas = state.atlas,
        .prescale = 0.15f,
        .anim_default_mix = 0.2f,
        .binary_data = state.load_status.skeleton.data,
    });
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
    f32 initial_time = 0.0f;
    for i32 i = 0; i < 16 * 8; i++ {
        state.instances[i] = sspine_make_instance(&sspine_instance_desc{.skeleton = state.skeleton});
        u8* anim_name = (i & 1) != 0 ? "walk" : "dance";
        sspine_set_animation(state.instances[i], sspine_anim_by_name(state.skeleton, anim_name), 0, true);
        sspine_skinset skinset = sspine_make_skinset(&sspine_skinset_desc{
            .skeleton = state.skeleton,
            .skins = {
                sspine_skin_by_name(state.skeleton, "skin-base"),
                sspine_skin_by_name(state.skeleton, accessories[random_skin_index()]),
                sspine_skin_by_name(state.skeleton, clothes[random_skin_index()]),
                sspine_skin_by_name(state.skeleton, eyelids[random_skin_index()]),
                sspine_skin_by_name(state.skeleton, eyes[random_skin_index()]),
                sspine_skin_by_name(state.skeleton, hair[random_skin_index()]),
                sspine_skin_by_name(state.skeleton, legs[random_skin_index()]),
                sspine_skin_by_name(state.skeleton, nose[random_skin_index()]),
                sspine_skin{},
                sspine_skin{},
                sspine_skin{},
                sspine_skin{},
                sspine_skin{},
                sspine_skin{},
                sspine_skin{},
                sspine_skin{},
                sspine_skin{},
                sspine_skin{},
                sspine_skin{},
                sspine_skin{},
                sspine_skin{},
                sspine_skin{},
                sspine_skin{},
                sspine_skin{},
                sspine_skin{},
                sspine_skin{},
                sspine_skin{},
                sspine_skin{},
                sspine_skin{},
                sspine_skin{},
                sspine_skin{},
                sspine_skin{},
            },
        });
        sspine_set_skinset(state.instances[i], skinset);
        sspine_update_instance(state.instances[i], initial_time);
        initial_time += 0.1f;
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
        .depth_format = SAPP_PIXELFORMAT_NONE,
        .high_dpi = true,
        .window_title = "spine-skinsets-sapp.mc",
        .icon = sapp_icon_desc{.sokol_default = true},
        .logger = sapp_logger{.func = slog_func},
    };
}
private { u32 random_skin_index__x = 0x87654321; }
