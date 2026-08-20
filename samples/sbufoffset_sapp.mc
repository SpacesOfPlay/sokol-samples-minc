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

// sbufoffset-sapp.glsl, hand-ported. One storage buffer holds both the
// index block and the vertex block; views bind each at its own 256-byte
// aligned offset. Two compute programs fill them from const tables,
// then the draw pulls vertices from the second view.

@gpu_layout
struct sb_vertex {
    float3 pos;
    float4 color;
}

struct sb_index {
    u32 i;
}

struct SbufoffsetSappVsOut {
    float4 pos;
    float4 color;
}

const u32[36] src_indices = {
    0, 1, 2,  0, 2, 3,
    6, 5, 4,  7, 6, 4,
    8, 9, 10,  8, 10, 11,
    14, 13, 12,  15, 14, 12,
    16, 17, 18,  16, 18, 19,
    22, 21, 20,  23, 22, 20
};

@shader compute(32, 1, 1)
void sbufoffset_sapp_cs_init_indices(@rwbuffer(0) []sb_index idx) {
    u32 i = thread_id().x;
    if i < 36 {
        idx[i].i = src_indices[i];
    }
}

// Upstream keeps one const table of sb_vertex; @shader consts admit
// scalars, vectors, matrices and arrays of those, but not arrays of
// structs, so the table is split into parallel position and colour
// arrays (see lang doc/FEATURE_shader_const_struct_arrays.md).
const float3[24] src_pos = {
    float3{-1.0f, -1.0f, -1.0f}, float3{ 1.0f, -1.0f, -1.0f},
    float3{ 1.0f,  1.0f, -1.0f}, float3{-1.0f,  1.0f, -1.0f},
    float3{-1.0f, -1.0f,  1.0f}, float3{ 1.0f, -1.0f,  1.0f},
    float3{ 1.0f,  1.0f,  1.0f}, float3{-1.0f,  1.0f,  1.0f},
    float3{-1.0f, -1.0f, -1.0f}, float3{-1.0f,  1.0f, -1.0f},
    float3{-1.0f,  1.0f,  1.0f}, float3{-1.0f, -1.0f,  1.0f},
    float3{ 1.0f, -1.0f, -1.0f}, float3{ 1.0f,  1.0f, -1.0f},
    float3{ 1.0f,  1.0f,  1.0f}, float3{ 1.0f, -1.0f,  1.0f},
    float3{-1.0f, -1.0f, -1.0f}, float3{-1.0f, -1.0f,  1.0f},
    float3{ 1.0f, -1.0f,  1.0f}, float3{ 1.0f, -1.0f, -1.0f},
    float3{-1.0f,  1.0f, -1.0f}, float3{-1.0f,  1.0f,  1.0f},
    float3{ 1.0f,  1.0f,  1.0f}, float3{ 1.0f,  1.0f, -1.0f},
};

const float4[24] src_color = {
    float4{1.0f, 0.0f, 0.0f, 1.0f}, float4{1.0f, 0.0f, 0.0f, 1.0f},
    float4{1.0f, 0.0f, 0.0f, 1.0f}, float4{1.0f, 0.0f, 0.0f, 1.0f},
    float4{0.0f, 1.0f, 0.0f, 1.0f}, float4{0.0f, 1.0f, 0.0f, 1.0f},
    float4{0.0f, 1.0f, 0.0f, 1.0f}, float4{0.0f, 1.0f, 0.0f, 1.0f},
    float4{0.0f, 0.0f, 1.0f, 1.0f}, float4{0.0f, 0.0f, 1.0f, 1.0f},
    float4{0.0f, 0.0f, 1.0f, 1.0f}, float4{0.0f, 0.0f, 1.0f, 1.0f},
    float4{1.0f, 0.5f, 0.0f, 1.0f}, float4{1.0f, 0.5f, 0.0f, 1.0f},
    float4{1.0f, 0.5f, 0.0f, 1.0f}, float4{1.0f, 0.5f, 0.0f, 1.0f},
    float4{0.0f, 0.5f, 1.0f, 1.0f}, float4{0.0f, 0.5f, 1.0f, 1.0f},
    float4{0.0f, 0.5f, 1.0f, 1.0f}, float4{0.0f, 0.5f, 1.0f, 1.0f},
    float4{1.0f, 0.0f, 0.5f, 1.0f}, float4{1.0f, 0.0f, 0.5f, 1.0f},
    float4{1.0f, 0.0f, 0.5f, 1.0f}, float4{1.0f, 0.0f, 0.5f, 1.0f},
};

@shader compute(32, 1, 1)
void sbufoffset_sapp_cs_init_vertices(@rwbuffer(0) []sb_vertex vtx) {
    u32 i = thread_id().x;
    if i < 24 {
        vtx[i].pos = src_pos[i];
        vtx[i].color = src_color[i];
    }
}

@shader vertex
SbufoffsetSappVsOut sbufoffset_sapp_vs(
    @buffer(0) []sb_vertex vtx,
    @uniform float4x4 mvp
) {
    sb_vertex v = vtx[vertex_id()];
    SbufoffsetSappVsOut o;
    o.pos = mul(mvp, float4{v.pos.x, v.pos.y, v.pos.z, 1.0f});
    o.color = v.color;
    return o;
}

@shader fragment
float4 sbufoffset_sapp_fs(
SbufoffsetSappVsOut input
) {
    return input.color;
}

enum __enum_UB_vs_params {
    UB_vs_params = 0,
    VIEW_cs_idx_ssbo = 0,
    VIEW_cs_vtx_ssbo = 0,
    VIEW_vs_vtx_ssbo = 0,
    __shim_end = 255,
}

// Replaces the sokol-shdc generated sbufoffset-sapp.glsl.h.
/* compute programs take the single-ShaderMeta overload */
struct vs_params_t {
    mat44_t mvp;
}

/* Storage-buffer elements, matching the @gpu_layout minc struct. */
struct sb_vertex_t {
    vec3_t pos;
    f32 _pad;
    vec4_t color;
}

struct sb_index_t {
    u32 i;
}

private struct state_t {
    f32 rx;
    f32 ry;
    sg_buffer buf;
    sg_view vtx_view;
    sg_pipeline pip;
    sg_pass_action pass_action;
}

private { state_t state; }

private {
u64 roundup(u64 val, u64 round_to) {
    return val + (round_to - 1) & ~(round_to - 1);
}

void init() {
    sg_setup(&sg_desc{.environment = sglue_environment(), .logger = sg_logger{.func = slog_func}});
    __dbgui_setup();
    if sg_query_features().compute == 0 {
        sdtx_setup(&sdtx_desc_t{
            .fonts[0] = sdtx_font_cpc(),
            .logger = sdtx_logger_t{.func = slog_func},
        });
        state.pass_action = sg_pass_action{
            .colors[0] = {
                .load_action = SG_LOADACTION_CLEAR,
                .clear_value = {1.0f, 0.0f, 0.0f, 1.0f},
            },
        };
        return;
    }
    state.pass_action = sg_pass_action{
        .colors[0] = {
            .load_action = SG_LOADACTION_CLEAR,
            .clear_value = {0.25f, 0.375f, 0.125f, 1.0f},
        },
    };
    u64 vertices_offset = roundup(cast(u64, 36 * sizeof(u32)), 256);
    state.buf = sg_make_buffer(&sg_buffer_desc{
        .usage = sg_buffer_usage{.index_buffer = true, .storage_buffer = true},
        .size = vertices_offset + cast(u64, 24 * sizeof(sb_vertex_t)),
        .label = "storage-buffer",
    });
    sg_view idx_view = sg_make_view(&sg_view_desc{
        .storage_buffer = sg_buffer_view_desc{.buffer = state.buf, .offset = 0},
        .label = "index-view",
    });
    state.vtx_view = sg_make_view(&sg_view_desc{
        .storage_buffer = sg_buffer_view_desc{.buffer = state.buf, .offset = cast(i32, vertices_offset)},
        .label = "vertex-view",
    });
    sg_pipeline idx_init_pip = sg_make_pipeline(&sg_pipeline_desc{
        .compute = true,
        .shader = sokol_make_shader(&sbufoffset_sapp_cs_init_indices_shader),
        .label = "init-indices-pipeline",
    });
    sg_pipeline vtx_init_pip = sg_make_pipeline(&sg_pipeline_desc{
        .compute = true,
        .shader = sokol_make_shader(&sbufoffset_sapp_cs_init_vertices_shader),
        .label = "init-vertices-pipeline",
    });
    state.pip = sg_make_pipeline(&sg_pipeline_desc{
        .shader = sokol_make_shader(&sbufoffset_sapp_vs_shader, &sbufoffset_sapp_fs_shader),
        .index_type = SG_INDEXTYPE_UINT32,
        .cull_mode = SG_CULLMODE_BACK,
        .depth = sg_depth_state{.write_enabled = true, .compare = SG_COMPAREFUNC_LESS_EQUAL},
        .label = "render-pipeline",
    });
    sg_begin_pass(&sg_pass{.compute = true});
    sg_apply_pipeline(idx_init_pip);
    sg_apply_bindings(&sg_bindings{.views[0] = idx_view});
    sg_dispatch((36 - 1) / 32 + 1, 1, 1);
    sg_apply_pipeline(vtx_init_pip);
    sg_apply_bindings(&sg_bindings{.views[0] = state.vtx_view});
    sg_dispatch((24 - 1) / 32 + 1, 1, 1);
    sg_end_pass();
    sg_destroy_view(idx_view);
    sg_destroy_pipeline(idx_init_pip);
    sg_destroy_pipeline(vtx_init_pip);
}

void frame() {
    if sg_query_features().compute == 0 {
        draw_fallback();
        return;
    }
    vs_params_t vs_params = compute_vsparams();
    sg_begin_pass(&sg_pass{.action = state.pass_action, .swapchain = sglue_swapchain()});
    sg_apply_pipeline(state.pip);
    sg_apply_bindings(&sg_bindings{
        .index_buffer = state.buf,
        .index_buffer_offset = 0,
        .views[0] = state.vtx_view,
    });
    sg_apply_uniforms(UB_vs_params, &sg_range{&vs_params, sizeof(vs_params)});
    sg_draw(0, 36, 1);
    __dbgui_draw();
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

vs_params_t compute_vsparams() {
    f32 w = sapp_widthf();
    f32 h = sapp_heightf();
    var t = cast(f32, sapp_frame_duration() * 60.0);
    mat44_t proj = mat44_perspective_fov_rh(vecmath_radians(60.0f), w / h, 0.01f, 10.0f);
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
    sdtx_puts("COMPUTE SHADERS NOT SUPPORTED ON THIS BACKEND");
    sg_begin_pass(&sg_pass{.action = state.pass_action, .swapchain = sglue_swapchain()});
    sdtx_draw();
    sg_end_pass();
    sg_commit();
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
        .window_title = "sbufoffset-sapp.mc",
        .icon = sapp_icon_desc{.sokol_default = true},
        .logger = sapp_logger{.func = slog_func},
    };
}
