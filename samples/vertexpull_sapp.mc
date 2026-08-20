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

// vertexpull-sapp.glsl, vertex data pulled from a readonly storage
// buffer instead of a vertex buffer. Hand-ported: the generator has no
// spelling for a `buffer` block, so the element struct and the
// @buffer(0) parameter are written out.
//
// @gpu_layout puts color on its 16-byte boundary, giving the 32-byte
// element the GPU reads; the C shim's sb_vertex_t matches it.

@gpu_layout
struct sb_vertex {
    float3 pos;
    float4 color;
}

struct VertexpullSappVsOut {
    float4 pos;
    float4 color;
}

@shader vertex
VertexpullSappVsOut vertexpull_sapp_vs(
    @buffer(0) []sb_vertex vtx,
    @uniform float4x4 mvp
) {
    VertexpullSappVsOut o;
    sb_vertex v = vtx[vertex_id()];
    o.pos = mul(mvp, float4{v.pos.x, v.pos.y, v.pos.z, 1.0f});
    o.color = v.color;
    return o;
}

@shader fragment
float4 vertexpull_sapp_fs(
VertexpullSappVsOut input
) {
    return input.color;
}

enum __enum_UB_vs_params {
    UB_vs_params = 0,
    VIEW_ssbo = 0,
    __shim_end = 255,
}

// Replaces the sokol-shdc generated vertexpull-sapp.glsl.h.
struct vs_params_t {
    mat44_t mvp;
}

/* Storage-buffer element, matching the @gpu_layout minc struct: color
   sits on its 16-byte boundary, so the element is 32 bytes. */
struct sb_vertex_t {
    f32[3] pos;
    f32 _pad;
    f32[4] color;
}

private struct state_t {
    f32 rx;
    f32 ry;
    sg_pipeline pip;
    sg_bindings bind;
    sg_pass_action pass_action;
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
    sb_vertex_t[24] vertices = {
        sb_vertex_t{.pos = {-1.0f, -1.0f, -1.0f}, .color = {1.0f, 0.0f, 0.0f, 1.0f}},
        sb_vertex_t{.pos = {1.0f, -1.0f, -1.0f}, .color = {1.0f, 0.0f, 0.0f, 1.0f}},
        sb_vertex_t{.pos = {1.0f, 1.0f, -1.0f}, .color = {1.0f, 0.0f, 0.0f, 1.0f}},
        sb_vertex_t{.pos = {-1.0f, 1.0f, -1.0f}, .color = {1.0f, 0.0f, 0.0f, 1.0f}},
        sb_vertex_t{.pos = {-1.0f, -1.0f, 1.0f}, .color = {0.0f, 1.0f, 0.0f, 1.0f}},
        sb_vertex_t{.pos = {1.0f, -1.0f, 1.0f}, .color = {0.0f, 1.0f, 0.0f, 1.0f}},
        sb_vertex_t{.pos = {1.0f, 1.0f, 1.0f}, .color = {0.0f, 1.0f, 0.0f, 1.0f}},
        sb_vertex_t{.pos = {-1.0f, 1.0f, 1.0f}, .color = {0.0f, 1.0f, 0.0f, 1.0f}},
        sb_vertex_t{.pos = {-1.0f, -1.0f, -1.0f}, .color = {0.0f, 0.0f, 1.0f, 1.0f}},
        sb_vertex_t{.pos = {-1.0f, 1.0f, -1.0f}, .color = {0.0f, 0.0f, 1.0f, 1.0f}},
        sb_vertex_t{.pos = {-1.0f, 1.0f, 1.0f}, .color = {0.0f, 0.0f, 1.0f, 1.0f}},
        sb_vertex_t{.pos = {-1.0f, -1.0f, 1.0f}, .color = {0.0f, 0.0f, 1.0f, 1.0f}},
        sb_vertex_t{.pos = {1.0f, -1.0f, -1.0f}, .color = {1.0f, 0.5f, 0.0f, 1.0f}},
        sb_vertex_t{.pos = {1.0f, 1.0f, -1.0f}, .color = {1.0f, 0.5f, 0.0f, 1.0f}},
        sb_vertex_t{.pos = {1.0f, 1.0f, 1.0f}, .color = {1.0f, 0.5f, 0.0f, 1.0f}},
        sb_vertex_t{.pos = {1.0f, -1.0f, 1.0f}, .color = {1.0f, 0.5f, 0.0f, 1.0f}},
        sb_vertex_t{.pos = {-1.0f, -1.0f, -1.0f}, .color = {0.0f, 0.5f, 1.0f, 1.0f}},
        sb_vertex_t{.pos = {-1.0f, -1.0f, 1.0f}, .color = {0.0f, 0.5f, 1.0f, 1.0f}},
        sb_vertex_t{.pos = {1.0f, -1.0f, 1.0f}, .color = {0.0f, 0.5f, 1.0f, 1.0f}},
        sb_vertex_t{.pos = {1.0f, -1.0f, -1.0f}, .color = {0.0f, 0.5f, 1.0f, 1.0f}},
        sb_vertex_t{.pos = {-1.0f, 1.0f, -1.0f}, .color = {1.0f, 0.0f, 0.5f, 1.0f}},
        sb_vertex_t{.pos = {-1.0f, 1.0f, 1.0f}, .color = {1.0f, 0.0f, 0.5f, 1.0f}},
        sb_vertex_t{.pos = {1.0f, 1.0f, 1.0f}, .color = {1.0f, 0.0f, 0.5f, 1.0f}},
        sb_vertex_t{.pos = {1.0f, 1.0f, -1.0f}, .color = {1.0f, 0.0f, 0.5f, 1.0f}},
    };
    sg_buffer sbuf = sg_make_buffer(&sg_buffer_desc{
        .usage = sg_buffer_usage{.storage_buffer = true},
        .data = sg_range{&vertices, sizeof(vertices)},
        .label = "cube-vertices",
    });
    u16[36] indices = {
        0, 1, 2, 0, 2, 3, 6, 5, 4, 7, 6, 4, 8, 9, 10, 8, 10, 11, 14, 13, 12, 15, 14, 12, 16, 17, 18,
        16, 18, 19, 22, 21, 20, 23, 22, 20,
    };
    sg_buffer ibuf = sg_make_buffer(&sg_buffer_desc{
        .usage = sg_buffer_usage{.index_buffer = true},
        .data = sg_range{&indices, sizeof(indices)},
        .label = "cube-indices",
    });
    state.pip = sg_make_pipeline(&sg_pipeline_desc{
        .shader = sokol_make_shader(&vertexpull_sapp_vs_shader, &vertexpull_sapp_fs_shader),
        .index_type = SG_INDEXTYPE_UINT16,
        .cull_mode = SG_CULLMODE_BACK,
        .depth = sg_depth_state{.write_enabled = true, .compare = SG_COMPAREFUNC_LESS_EQUAL},
        .label = "cube-pipeline",
    });
    state.bind = sg_bindings{
        .index_buffer = ibuf,
        .views[0] = sg_make_view(&sg_view_desc{
            .storage_buffer = sg_buffer_view_desc{.buffer = sbuf, .offset = 0},
            .label = "cube-vertices-view",
        }),
    };
    state.pass_action = sg_pass_action{
        .colors[0] = {.load_action = SG_LOADACTION_CLEAR, .clear_value = {0.75f, 0.5f, 0.25f, 1.0f}},
    };
}

void frame() {
    if sg_query_features().compute == 0 {
        draw_fallback();
        return;
    }
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
        .window_title = "vertexpull-sapp.mc",
        .icon = sapp_icon_desc{.sokol_default = true},
        .logger = sapp_logger{.func = slog_func},
    };
}
