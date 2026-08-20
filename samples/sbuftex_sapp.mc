import dbgui;
import sokol_debugtext;
import vecmath;

import sokol_all;
import math;

// force high-dpi, sample entry point is __sapp_sample_main()
sapp_desc sokol_main() {
    sapp_desc d = __sapp_sample_main();
    d.high_dpi = true;
    return d;
}

// sbuftex-sapp.glsl, hand-ported. A cube pulled from a storage buffer
// in the vertex stage, textured, and tinted per face by a second
// storage buffer indexed in the fragment stage.
//
// sb_vertex needs @gpu_layout: packed it is 24 bytes, while the GPU
// aligns the struct to its widest member (float3 -> 16) and reads a
// 32-byte stride. sb_color is a lone float4 and already conforms.

@gpu_layout
struct sb_vertex {
    float3 pos;
    u32 idx;
    float2 uv;
}

struct sb_color {
    float4 color;
}

struct SbuftexSappVsOut {
    float4 pos;
    float3 uv_idx;
}

@shader vertex
SbuftexSappVsOut sbuftex_sapp_vs(
    @buffer(0) []sb_vertex vtx,
    @uniform(0) float4x4 mvp
) {
    sb_vertex v = vtx[vertex_id()];
    SbuftexSappVsOut o;
    o.pos = mul(mvp, float4{v.pos.x, v.pos.y, v.pos.z, 1.0f});
    // the 0.5 is upstream's wiggle room against an NVIDIA precision
    // problem when the index is recovered in the fragment stage
    o.uv_idx = float3{v.uv.x, v.uv.y, cast(f32, v.idx) + 0.5f};
    return o;
}

@shader fragment
float4 sbuftex_sapp_fs(
SbuftexSappVsOut input,
    @texture(1) Texture2D tex,
    @sampler(0) Sampler smp,
    @buffer(2) []sb_color clr
) {
    u32 idx = cast(u32, input.uv_idx.z);
    float2 uv = float2{input.uv_idx.x, input.uv_idx.y};
    f32 s = sample(tex, smp, uv).x;
    float4 c = clr[idx].color;
    return float4{s * c.x, s * c.y, s * c.z, c.w};
}

enum __enum_UB_vs_params {
    UB_vs_params = 0,
    VIEW_vertices = 0,
    VIEW_tex = 1,
    VIEW_colors = 2,
    SMP_smp = 0,
    __shim_end = 255,
}

type __arr_u8_4 = u8[4];
// Replaces the sokol-shdc generated sbuftex-sapp.glsl.h.
struct vs_params_t {
    mat44_t mvp;
}

/* Storage-buffer elements, matching the @gpu_layout minc structs: the
   GPU aligns the struct to its widest member, so sb_vertex is 32 bytes
   with uv at 16. sb_color is a lone float4 and needs no padding. */
struct sb_vertex_t {
    f32[3] pos;
    u32 idx;
    f32[2] uv;
    f32[2] _pad_tail;
}

struct sb_color_t {
    f32[4] color;
}

private struct state_t {
    f32 rx;
    f32 ry;
    sg_pass_action pass_action;
    sg_pipeline pip;
    sg_bindings bind;
}

private { state_t state; }

private {
void init() {
    sg_setup(&sg_desc{.environment = sglue_environment(), .logger = sg_logger{.func = slog_func}});
    __dbgui_setup();
    if sg_query_features().compute == 0 {
        sdtx_setup(&sdtx_desc_t{.fonts[0] = sdtx_font_cpc()});
        return;
    }
    state.pass_action = sg_pass_action{
        .colors[0] = {.load_action = SG_LOADACTION_CLEAR, .clear_value = {0.5f, 0.75f, 0.25f, 0.0f}},
    };
    sb_vertex_t[24] vertices = {
        sb_vertex_t{.pos = {-1.0f, -1.0f, -1.0f}, .idx = 0, .uv = {0.0f, 0.0f}},
        sb_vertex_t{.pos = {1.0f, -1.0f, -1.0f}, .idx = 0, .uv = {1.0f, 0.0f}},
        sb_vertex_t{.pos = {1.0f, 1.0f, -1.0f}, .idx = 0, .uv = {1.0f, 1.0f}},
        sb_vertex_t{.pos = {-1.0f, 1.0f, -1.0f}, .idx = 0, .uv = {0.0f, 1.0f}},
        sb_vertex_t{.pos = {-1.0f, -1.0f, 1.0f}, .idx = 1, .uv = {0.0f, 0.0f}},
        sb_vertex_t{.pos = {1.0f, -1.0f, 1.0f}, .idx = 1, .uv = {1.0f, 0.0f}},
        sb_vertex_t{.pos = {1.0f, 1.0f, 1.0f}, .idx = 1, .uv = {1.0f, 1.0f}},
        sb_vertex_t{.pos = {-1.0f, 1.0f, 1.0f}, .idx = 1, .uv = {0.0f, 1.0f}},
        sb_vertex_t{.pos = {-1.0f, -1.0f, -1.0f}, .idx = 2, .uv = {0.0f, 0.0f}},
        sb_vertex_t{.pos = {-1.0f, 1.0f, -1.0f}, .idx = 2, .uv = {1.0f, 0.0f}},
        sb_vertex_t{.pos = {-1.0f, 1.0f, 1.0f}, .idx = 2, .uv = {1.0f, 1.0f}},
        sb_vertex_t{.pos = {-1.0f, -1.0f, 1.0f}, .idx = 2, .uv = {0.0f, 1.0f}},
        sb_vertex_t{.pos = {1.0f, -1.0f, -1.0f}, .idx = 3, .uv = {0.0f, 0.0f}},
        sb_vertex_t{.pos = {1.0f, 1.0f, -1.0f}, .idx = 3, .uv = {1.0f, 0.0f}},
        sb_vertex_t{.pos = {1.0f, 1.0f, 1.0f}, .idx = 3, .uv = {1.0f, 1.0f}},
        sb_vertex_t{.pos = {1.0f, -1.0f, 1.0f}, .idx = 3, .uv = {0.0f, 1.0f}},
        sb_vertex_t{.pos = {-1.0f, -1.0f, -1.0f}, .idx = 4, .uv = {0.0f, 0.0f}},
        sb_vertex_t{.pos = {-1.0f, -1.0f, 1.0f}, .idx = 4, .uv = {1.0f, 0.0f}},
        sb_vertex_t{.pos = {1.0f, -1.0f, 1.0f}, .idx = 4, .uv = {1.0f, 1.0f}},
        sb_vertex_t{.pos = {1.0f, -1.0f, -1.0f}, .idx = 4, .uv = {0.0f, 1.0f}},
        sb_vertex_t{.pos = {-1.0f, 1.0f, -1.0f}, .idx = 5, .uv = {0.0f, 0.0f}},
        sb_vertex_t{.pos = {-1.0f, 1.0f, 1.0f}, .idx = 5, .uv = {1.0f, 0.0f}},
        sb_vertex_t{.pos = {1.0f, 1.0f, 1.0f}, .idx = 5, .uv = {1.0f, 1.0f}},
        sb_vertex_t{.pos = {1.0f, 1.0f, -1.0f}, .idx = 5, .uv = {0.0f, 1.0f}},
    };
    sg_buffer vbuf = sg_make_buffer(&sg_buffer_desc{
        .usage = sg_buffer_usage{.storage_buffer = true},
        .data = sg_range{&vertices, sizeof(vertices)},
        .label = "cube-vertex-buffer",
    });
    state.bind.views[VIEW_vertices] = sg_make_view(&sg_view_desc{
        .storage_buffer = sg_buffer_view_desc{.buffer = vbuf},
        .label = "cube-vertex-view",
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
    sb_color_t[6] colors = {
        sb_color_t{.color = {1.0f, 0.0f, 0.0f, 1.0f}},
        sb_color_t{.color = {0.0f, 1.0f, 0.0f, 1.0f}},
        sb_color_t{.color = {0.0f, 0.0f, 1.0f, 1.0f}},
        sb_color_t{.color = {0.5f, 0.0f, 1.0f, 1.0f}},
        sb_color_t{.color = {0.0f, 0.5f, 1.0f, 1.0f}},
        sb_color_t{.color = {1.0f, 0.5f, 0.0f, 1.0f}},
    };
    sg_buffer cbuf = sg_make_buffer(&sg_buffer_desc{
        .usage = sg_buffer_usage{.storage_buffer = true},
        .data = sg_range{&colors, sizeof(colors)},
        .label = "color-palette-buffer",
    });
    state.bind.views[VIEW_colors] = sg_make_view(&sg_view_desc{
        .storage_buffer = sg_buffer_view_desc{.buffer = cbuf},
        .label = "color-palette-view",
    });
    __arr_u8_4[4] pixels = {
        {0xFF, 0xCC, 0x88, 0x44},
        {0xCC, 0x88, 0x44, 0xFF},
        {0x88, 0x44, 0xFF, 0xCC},
        {0x44, 0xFF, 0xCC, 0x88},
    };
    sg_image img = sg_make_image(&sg_image_desc{
        .width = 4,
        .height = 4,
        .pixel_format = SG_PIXELFORMAT_R8,
        .data = sg_image_data{.mip_levels[0] = sg_range{&pixels, sizeof(pixels)}},
        .label = "texture",
    });
    state.bind.views[VIEW_tex] = sg_make_view(&sg_view_desc{
        .texture = sg_texture_view_desc{.image = img},
        .label = "texture-view",
    });
    state.bind.samplers[SMP_smp] = sg_make_sampler(&sg_sampler_desc{
        .min_filter = SG_FILTER_NEAREST,
        .mag_filter = SG_FILTER_NEAREST,
        .label = "sampler",
    });
    sg_shader shd = sokol_make_shader(&sbuftex_sapp_vs_shader, &sbuftex_sapp_fs_shader);
    state.pip = sg_make_pipeline(&sg_pipeline_desc{
        .shader = shd,
        .index_type = SG_INDEXTYPE_UINT16,
        .cull_mode = SG_CULLMODE_BACK,
        .depth = sg_depth_state{.compare = SG_COMPAREFUNC_LESS_EQUAL, .write_enabled = true},
        .label = "pipeline",
    });
}

void frame() {
    if sg_query_features().compute == 0 {
        draw_fallback();
        return;
    }
    vs_params_t vs_params = make_vs_params();
    sg_begin_pass(&sg_pass{.action = state.pass_action, .swapchain = sglue_swapchain()});
    sg_apply_pipeline(state.pip);
    sg_apply_bindings(&state.bind);
    sg_apply_uniforms(UB_vs_params, &sg_range{&vs_params, sizeof(vs_params)});
    sg_draw(0, 36, 1);
    __dbgui_draw();
    sg_end_pass();
    sg_commit();
}

vs_params_t make_vs_params() {
    var t = cast(f32, sapp_frame_duration() * 60.0);
    mat44_t proj = mat44_perspective_fov_rh(vecmath_radians(60.0f), sapp_widthf() / sapp_heightf(), 0.01f, 10.0f);
    mat44_t view = mat44_look_at_rh(vec3(0.0f, 1.5f, 4.0f), vec3(0.0f, 0.0f, 0.0f), vec3(0.0f, 1.0f, 0.0f));
    mat44_t view_proj = mat44_mul_mat44(view, proj);
    state.rx += 1.0f * t;
    state.ry += 2.0f * t;
    mat44_t rxm = mat44_rotation_x(vecmath_radians(state.rx));
    mat44_t rym = mat44_rotation_y(vecmath_radians(state.ry));
    mat44_t model = mat44_mul_mat44(rym, rxm);
    return vs_params_t{.mvp = mat44_mul_mat44(model, view_proj)};
}

void draw_fallback() {
    sdtx_canvas(sapp_widthf() * 0.5f, sapp_heightf() * 0.5f);
    sdtx_pos(1.0f, 1.0f);
    sdtx_puts("STORAGE BUFFERS NOT SUPPORTED");
    sg_begin_pass(&sg_pass{
        .action = sg_pass_action{
            .colors[0] = {
                .load_action = SG_LOADACTION_CLEAR,
                .clear_value = {1.0f, 0.0f, 0.0f, 1.0f},
            },
        },
        .swapchain = sglue_swapchain(),
    });
    sdtx_draw();
    sg_end_pass();
    sg_commit();
}

void cleanup() {
    __dbgui_shutdown();
    if sg_query_features().compute == 0 {
        sdtx_shutdown();
    }
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
        .window_title = "sbuftex-sapp.mc",
        .icon = sapp_icon_desc{.sokol_default = true},
        .logger = sapp_logger{.func = slog_func},
    };
}
