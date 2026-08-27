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

// fontstash-layers-sapp.glsl, ported to minc @shader.
// Interface mirrors the sokol-shdc program `triangle`:
//   attrs: position(0), color0(1); no uniforms, no textures.
// The triangle is drawn between two sokol-gl text layers, so it needs
// nothing but a colour passed through.

struct FontstashLayersSappVsOut {
    float4 pos;
    float4 color;
}

@shader vertex
FontstashLayersSappVsOut fontstash_layers_sapp_vs(
    @attr(0) float4 position,
    @attr(1) float4 color0
) {
    FontstashLayersSappVsOut o;
    o.pos = position;
    o.color = color0;
    return o;
}

@shader fragment
float4 fontstash_layers_sapp_fs(FontstashLayersSappVsOut input) {
    return input.color;
}

// transminc: C #define constants read as values
const i32 FONS_INVALID = -1;

enum __enum_ATTR_triangle_position {
    ATTR_triangle_position = 0,
    ATTR_triangle_color0 = 1,
    __shim_end = 255,
}

private struct state_t {
    sg_pass_action pass_action;
    sg_pipeline pip;
    sg_bindings bind;
    FONScontext* fons;
    i32 font;
    u8[256 * 1024] font_data;
}

private {
state_t state;

// round to next power of 2 (see bit-twiddling-hacks)
i32 round_pow2(f32 v) {
    u32 vi = cast(u32, v) - 1;
    for u32 i = 0; i < 5; i++ {
        vi |= vi >> (1 << i);
    }
    return cast(i32, vi + 1);
}

// sokol-fetch callback for TTF font data
void font_loaded(sfetch_response_t* response) {
    if response.fetched != 0 {
        state.font = fonsAddFontMem(state.fons, "sans", response.data.ptr, cast(i32, response.data.size), false);
    }
}

void init() {
    sg_setup(&sg_desc{.environment = sglue_environment(), .logger = sg_logger{.func = slog_func}});
    __dbgui_setup();
    sgl_setup(&sgl_desc_t{.logger = sgl_logger_t{.func = slog_func}});
    sfetch_setup(&sfetch_desc_t{
        .num_channels = 1,
        .num_lanes = 1,
        .logger = sfetch_logger_t{.func = slog_func},
    });
    i32 atlas_dim = round_pow2(512.0f * sapp_dpi_scale());
    state.fons = sfons_create(&sfons_desc_t{.width = atlas_dim, .height = atlas_dim});
    state.font = FONS_INVALID;
    noinit u8[512] path_buf;
    sfetch_send(&sfetch_request_t{
        .path = fileutil_get_path("DroidSerif-Regular.ttf", path_buf, cast(u64, sizeof(path_buf))),
        .callback = font_loaded,
        .buffer = sfetch_range_t{&state.font_data, sizeof(state.font_data)},
    });
    state.pass_action = sg_pass_action{
        .colors[0] = {.load_action = SG_LOADACTION_CLEAR, .clear_value = {0.0f, 0.0f, 0.0f, 1.0f}},
    };
    f32[21] vertices = {
        0.0f, 0.5f, 0.5f, 1.0f, 0.0f, 0.0f, 0.9f, 0.5f, -0.5f, 0.5f, 0.0f, 1.0f, 0.0f, 0.9f, -0.5f,
        -0.5f, 0.5f, 0.0f, 0.0f, 1.0f, 0.9f,
    };
    state.bind.vertex_buffers[0] = sg_make_buffer(&sg_buffer_desc{.data = sg_range{&vertices, sizeof(vertices)}});
    state.pip = sg_make_pipeline(&sg_pipeline_desc{
        .shader = sokol_make_shader(&fontstash_layers_sapp_vs_shader, &fontstash_layers_sapp_fs_shader),
        .layout = sg_vertex_layout_state{
            .attrs[0] = {.format = SG_VERTEXFORMAT_FLOAT3},
            .attrs[1] = {.format = SG_VERTEXFORMAT_FLOAT4},
        },
        .colors[0] = {
            .blend = {
                .enabled = true,
                .src_factor_rgb = SG_BLENDFACTOR_SRC_ALPHA,
                .dst_factor_rgb = SG_BLENDFACTOR_ONE_MINUS_SRC_ALPHA,
            },
        },
    });
}

void frame() {
    sfetch_dowork();
    f32 dpis = sapp_dpi_scale();
    f32 disp_w = sapp_widthf();
    f32 disp_h = sapp_heightf();
    sgl_defaults();
    sgl_matrix_mode_projection();
    sgl_ortho(0.0f, disp_w, disp_h, 0.0f, -1.0f, 1.0f);
    FONScontext* fs = state.fons;
    fonsClearState(fs);
    if state.font != FONS_INVALID {
        fonsSetFont(fs, state.font);
        fonsSetSize(fs, 124.0f * dpis);
        fonsSetColor(fs, 0xFFFFFFFF);
        f32 lh;
        fonsVertMetrics(fs, null, null, &lh);
        {
            u8* text = "Background";
            sgl_layer(0);
            f32 w = fonsTextBounds(fs, 0.0f, 0.0f, text, null, null);
            f32 x = (disp_w - w) * 0.5f;
            f32 y = disp_h * 0.5f - lh * 0.25f;
            fonsDrawText(fs, x, y, text, null);
        }
        {
            u8* text = "Foreground";
            sgl_layer(1);
            f32 w = fonsTextBounds(fs, 0.0f, 0.0f, text, null, null);
            f32 x = (disp_w - w) * 0.5f;
            f32 y = disp_h * 0.5f + lh * 1.0f;
            fonsDrawText(fs, x, y, text, null);
        }
    }
    sfons_flush(fs);
    sg_begin_pass(&sg_pass{.action = state.pass_action, .swapchain = sglue_swapchain()});
    sgl_draw_layer(0);
    sg_apply_pipeline(state.pip);
    sg_apply_bindings(&state.bind);
    sg_draw(0, 3, 1);
    sgl_draw_layer(1);
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
        .window_title = "fontstash-layers-sapp.mc",
        .icon = sapp_icon_desc{.sokol_default = true},
        .logger = sapp_logger{.func = slog_func},
    };
}
