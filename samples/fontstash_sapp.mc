import dbgui;
import sapp_util;
import sokol_fetch;
import sokol_gl;
import fontstash;
import sokol_fontstash;

import sokol_all;
import math;

// force high-dpi, sample entry point is __sapp_sample_main()
sapp_desc sokol_main() {
    sapp_desc d = __sapp_sample_main();
    d.high_dpi = true;
    return d;
}

// transminc: C #define constants read as values
const i32 FONS_INVALID = -1;

struct state_t {
    FONScontext* fons;
    f32 dpi_scale;
    i32 font_normal;
    i32 font_italic;
    i32 font_bold;
    i32 font_japanese;
    u8[256 * 1024] font_normal_data;
    u8[256 * 1024] font_italic_data;
    u8[256 * 1024] font_bold_data;
    u8[2 * 1024 * 1024] font_japanese_data;
}

private {
state_t state;

// optional memory allocation function overrides (see sfons_create())
void* my_alloc(u64 size, void* user_data) {
    ignore user_data;
    return alloc(cast(i64, size));
}

void my_free(void* ptr, void* user_data) {
    ignore user_data;
    free(ptr);
}

// sokol-fetch load callbacks
void font_normal_loaded(sfetch_response_t* response) {
    if response.fetched != 0 {
        state.font_normal = fonsAddFontMem(state.fons, "sans", response.data.ptr, cast(i32, response.data.size), false);
    }
}

void font_italic_loaded(sfetch_response_t* response) {
    if response.fetched != 0 {
        state.font_italic = fonsAddFontMem(state.fons, "sans-italic", response.data.ptr, cast(i32, response.data.size), false);
    }
}

void font_bold_loaded(sfetch_response_t* response) {
    if response.fetched != 0 {
        state.font_bold = fonsAddFontMem(state.fons, "sans-bold", response.data.ptr, cast(i32, response.data.size), false);
    }
}

void font_japanese_loaded(sfetch_response_t* response) {
    if response.fetched != 0 {
        state.font_japanese = fonsAddFontMem(state.fons, "sans-japanese", response.data.ptr, cast(i32, response.data.size), false);
    }
}

// round to next power of 2 (see bit-twiddling-hacks)
i32 round_pow2(f32 v) {
    u32 vi = cast(u32, v) - 1;
    for u32 i = 0; i < 5; i++ {
        vi |= vi >> (1 << i);
    }
    return cast(i32, vi + 1);
}

void init() {
    state.dpi_scale = sapp_dpi_scale();
    sg_setup(&sg_desc{.environment = sglue_environment(), .logger = sg_logger{.func = slog_func}});
    __dbgui_setup();
    sgl_setup(&sgl_desc_t{.logger = sgl_logger_t{.func = slog_func}});
    i32 atlas_dim = round_pow2(512.0f * state.dpi_scale);
    FONScontext* fons_context = sfons_create(&sfons_desc_t{
        .width = atlas_dim,
        .height = atlas_dim,
        .allocator = sfons_allocator_t{.alloc_fn = my_alloc, .free_fn = my_free},
    });
    state.fons = fons_context;
    state.font_normal = FONS_INVALID;
    state.font_italic = FONS_INVALID;
    state.font_bold = FONS_INVALID;
    state.font_japanese = FONS_INVALID;
    sfetch_setup(&sfetch_desc_t{
        .num_channels = 1,
        .num_lanes = 4,
        .logger = sfetch_logger_t{.func = slog_func},
    });
    noinit u8[512] path_buf;
    sfetch_send(&sfetch_request_t{
        .path = fileutil_get_path("DroidSerif-Regular.ttf", path_buf, cast(u64, sizeof(path_buf))),
        .callback = font_normal_loaded,
        .buffer = sfetch_range_t{&state.font_normal_data, sizeof(state.font_normal_data)},
    });
    sfetch_send(&sfetch_request_t{
        .path = fileutil_get_path("DroidSerif-Italic.ttf", path_buf, cast(u64, sizeof(path_buf))),
        .callback = font_italic_loaded,
        .buffer = sfetch_range_t{&state.font_italic_data, sizeof(state.font_italic_data)},
    });
    sfetch_send(&sfetch_request_t{
        .path = fileutil_get_path("DroidSerif-Bold.ttf", path_buf, cast(u64, sizeof(path_buf))),
        .callback = font_bold_loaded,
        .buffer = sfetch_range_t{&state.font_bold_data, sizeof(state.font_bold_data)},
    });
    sfetch_send(&sfetch_request_t{
        .path = fileutil_get_path("DroidSansJapanese.ttf", path_buf, cast(u64, sizeof(path_buf))),
        .callback = font_japanese_loaded,
        .buffer = sfetch_range_t{&state.font_japanese_data, sizeof(state.font_japanese_data)},
    });
}

void line(f32 sx, f32 sy, f32 ex, f32 ey) {
    sgl_begin_lines();
    sgl_c4b(255, 255, 0, 128);
    sgl_v2f(sx, sy);
    sgl_v2f(ex, ey);
    sgl_end();
}

void frame() {
    f32 dpis = state.dpi_scale;
    sfetch_dowork();
    f32 sx;
    f32 sy;
    f32 dx;
    f32 dy;
    f32 lh = 0.0f;
    u32 white = sfons_rgba(255, 255, 255, 255);
    u32 black = sfons_rgba(0, 0, 0, 255);
    u32 brown = sfons_rgba(192, 128, 0, 128);
    u32 blue = sfons_rgba(0, 192, 255, 255);
    fonsClearState(state.fons);
    sgl_defaults();
    sgl_matrix_mode_projection();
    sgl_ortho(0.0f, sapp_widthf(), sapp_heightf(), 0.0f, -1.0f, 1.0f);
    sx = 50.0f * dpis;
    sy = 50.0f * dpis;
    dx = sx;
    dy = sy;
    FONScontext* fs = state.fons;
    if state.font_normal != FONS_INVALID {
        fonsSetFont(fs, state.font_normal);
        fonsSetSize(fs, 124.0f * dpis);
        fonsVertMetrics(fs, null, null, &lh);
        dx = sx;
        dy += lh;
        fonsSetColor(fs, white);
        dx = fonsDrawText(fs, dx, dy, "The quick ", null);
    }
    if state.font_italic != FONS_INVALID {
        fonsSetFont(fs, state.font_italic);
        fonsSetSize(fs, 48.0f * dpis);
        fonsSetColor(fs, brown);
        dx = fonsDrawText(fs, dx, dy, "brown ", null);
    }
    if state.font_normal != FONS_INVALID {
        fonsSetFont(fs, state.font_normal);
        fonsSetSize(fs, 24.0f * dpis);
        fonsSetColor(fs, white);
        dx = fonsDrawText(fs, dx, dy, "fox ", null);
    }
    if state.font_normal != FONS_INVALID && state.font_italic != FONS_INVALID && state.font_bold != FONS_INVALID {
        fonsVertMetrics(fs, null, null, &lh);
        dx = sx;
        dy += lh * 1.2f;
        fonsSetFont(fs, state.font_italic);
        dx = fonsDrawText(fs, dx, dy, "jumps over ", null);
        fonsSetFont(fs, state.font_bold);
        dx = fonsDrawText(fs, dx, dy, "the lazy ", null);
        fonsSetFont(fs, state.font_normal);
        dx = fonsDrawText(fs, dx, dy, "dog.", null);
    }
    if state.font_normal != FONS_INVALID {
        dx = sx;
        dy += lh * 1.2f;
        fonsSetSize(fs, 12.0f * dpis);
        fonsSetFont(fs, state.font_normal);
        fonsSetColor(fs, blue);
        fonsDrawText(fs, dx, dy, "Now is the time for all good men to come to the aid of the party.", null);
    }
    if state.font_italic != FONS_INVALID {
        fonsVertMetrics(fs, null, null, &lh);
        dx = sx;
        dy += lh * 1.2f * 2.0f;
        fonsSetSize(fs, 18.0f * dpis);
        fonsSetFont(fs, state.font_italic);
        fonsSetColor(fs, white);
        fonsDrawText(fs, dx, dy, "Ég get etið gler án þess að meiða mig.", null);
    }
    if state.font_japanese != FONS_INVALID {
        fonsVertMetrics(fs, null, null, &lh);
        dx = sx;
        dy += lh * 1.2f;
        fonsSetFont(fs, state.font_japanese);
        fonsDrawText(fs, dx, dy, "私はガラスを食べられます。それは私を傷つけません。", null);
    }
    if state.font_normal != FONS_INVALID {
        fonsSetSize(fs, 18.0f * dpis);
        fonsSetFont(fs, state.font_normal);
        fonsSetColor(fs, white);
        dx = 50.0f * dpis;
        dy = 350.0f * dpis;
        line(dx - 10.0f * dpis, dy, dx + 250.0f * dpis, dy);
        fonsSetAlign(fs, FONS_ALIGN_LEFT | FONS_ALIGN_TOP);
        dx = fonsDrawText(fs, dx, dy, "Top", null);
        dx += 10.0f * dpis;
        fonsSetAlign(fs, FONS_ALIGN_LEFT | FONS_ALIGN_MIDDLE);
        dx = fonsDrawText(fs, dx, dy, "Middle", null);
        dx += 10.0f * dpis;
        fonsSetAlign(fs, FONS_ALIGN_LEFT | FONS_ALIGN_BASELINE);
        dx = fonsDrawText(fs, dx, dy, "Baseline", null);
        dx += 10.0f * dpis;
        fonsSetAlign(fs, FONS_ALIGN_LEFT | FONS_ALIGN_BOTTOM);
        fonsDrawText(fs, dx, dy, "Bottom", null);
        dx = 150.0f * dpis;
        dy = 400.0f * dpis;
        line(dx, dy - 30.0f * dpis, dx, dy + 80.0f * dpis);
        fonsSetAlign(fs, FONS_ALIGN_LEFT | FONS_ALIGN_BASELINE);
        fonsDrawText(fs, dx, dy, "Left", null);
        dy += 30.0f * dpis;
        fonsSetAlign(fs, FONS_ALIGN_CENTER | FONS_ALIGN_BASELINE);
        fonsDrawText(fs, dx, dy, "Center", null);
        dy += 30.0f * dpis;
        fonsSetAlign(fs, FONS_ALIGN_RIGHT | FONS_ALIGN_BASELINE);
        fonsDrawText(fs, dx, dy, "Right", null);
    }
    if state.font_italic != FONS_INVALID {
        dx = 500.0f * dpis;
        dy = 350.0f * dpis;
        fonsSetAlign(fs, FONS_ALIGN_LEFT | FONS_ALIGN_BASELINE);
        fonsSetSize(fs, 60.0f * dpis);
        fonsSetFont(fs, state.font_italic);
        fonsSetColor(fs, white);
        fonsSetSpacing(fs, 5.0f * dpis);
        fonsSetBlur(fs, 10.0f);
        fonsDrawText(fs, dx, dy, "Blurry...", null);
    }
    if state.font_bold != FONS_INVALID {
        dy += 50.0f * dpis;
        fonsSetSize(fs, 18.0f * dpis);
        fonsSetFont(fs, state.font_bold);
        fonsSetColor(fs, black);
        fonsSetSpacing(fs, 0.0f);
        fonsSetBlur(fs, 3.0f);
        fonsDrawText(fs, dx, dy + 2.0f, "DROP THAT SHADOW", null);
        fonsSetColor(fs, white);
        fonsSetBlur(fs, 0.0f);
        fonsDrawText(fs, dx, dy, "DROP THAT SHADOW", null);
    }
    sfons_flush(fs);
    sg_begin_pass(&sg_pass{
        .action = sg_pass_action{
            .colors[0] = {
                .load_action = SG_LOADACTION_CLEAR,
                .clear_value = {0.3f, 0.3f, 0.32f, 1.0f},
            },
        },
        .swapchain = sglue_swapchain(),
    });
    sgl_draw();
    __dbgui_draw();
    sg_end_pass();
    sg_commit();
}

void cleanup() {
    __dbgui_shutdown();
    sfetch_shutdown();
    sfons_destroy(state.fons);
    sgl_shutdown();
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
        .high_dpi = true,
        .window_title = "fontstash-sapp.mc",
        .icon = sapp_icon_desc{.sokol_default = true},
        .logger = sapp_logger{.func = slog_func},
    };
}
