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

// instancing-pull-sapp.glsl, hand-ported. Both the vertex data and the
// per-instance offsets come from readonly storage buffers, indexed by
// vertex_id() and instance_id(); no vertex buffer is bound at all.
//
// Both elements need @gpu_layout. sb_vertex packs to 28 with color at
// 12, and the GPU wants it at 16 in a 32-byte element. sb_instance is a
// lone float3: 12 packed, but the GPU aligns the struct to its widest
// member and reads a 16-byte stride.

@gpu_layout
struct sb_vertex {
    float3 pos;
    float4 color;
}

@gpu_layout
struct sb_instance {
    float3 pos;
}

struct InstancingPullSappVsOut {
    float4 pos;
    float4 color;
}

@shader vertex
InstancingPullSappVsOut instancing_pull_sapp_vs(
    @buffer(0) []sb_vertex vtx,
    @buffer(1) []sb_instance inst,
    @uniform float4x4 mvp
) {
    sb_vertex v = vtx[vertex_id()];
    sb_instance i = inst[instance_id()];
    float4 pos = float4{v.pos.x + i.pos.x, v.pos.y + i.pos.y, v.pos.z + i.pos.z, 1.0f};
    InstancingPullSappVsOut o;
    o.pos = mul(mvp, pos);
    o.color = v.color;
    return o;
}

@shader fragment
float4 instancing_pull_sapp_fs(
InstancingPullSappVsOut input
) {
    return input.color;
}

enum __enum_UB_vs_params {
    UB_vs_params = 0,
    VIEW_vertices = 0,
    VIEW_instances = 1,
    __shim_end = 255,
}

// Replaces the sokol-shdc generated instancing-pull-sapp.glsl.h.
struct vs_params_t {
    mat44_t mvp;
}

/* Storage-buffer elements, matching the @gpu_layout minc structs. */
struct sb_vertex_t {
    vec3_t pos;
    f32 _pad;
    vec4_t color;
}

struct sb_instance_t {
    vec3_t pos;
    f32 _pad;
}

private struct state_t {
    sg_pass_action pass_action;
    sg_buffer inst_buf;
    sg_pipeline pip;
    sg_bindings bind;
    f32 ry;
    i32 cur_num_particles;
    sb_instance_t[524288] inst;
    vec3_t[524288] vel;
}

private { state_t state; }

private {
u32 xorshift32() {
    xorshift32__x ^= xorshift32__x << 13;
    xorshift32__x ^= xorshift32__x >> 17;
    xorshift32__x ^= xorshift32__x << 5;
    return xorshift32__x;
}

void init() {
    sg_setup(&sg_desc{.environment = sglue_environment(), .logger = sg_logger{.func = slog_func}});
    __dbgui_setup();
    if sg_query_features().compute == 0 {
        sdtx_setup(&sdtx_desc_t{.fonts[0] = sdtx_font_cpc()});
        return;
    }
    state.pass_action = sg_pass_action{
        .colors[0] = {.load_action = SG_LOADACTION_CLEAR, .clear_value = {0.0f, 0.1f, 0.2f, 1.0f}},
    };
    f32 r = 0.05f;
    sb_vertex_t[6] vertices = {
        sb_vertex_t{.pos = vec3(0.0f, -r, 0.0f), .color = vec4(1.0f, 0.0f, 0.0f, 1.0f)},
        sb_vertex_t{.pos = vec3(r, 0.0f, r), .color = vec4(0.0f, 1.0f, 0.0f, 1.0f)},
        sb_vertex_t{.pos = vec3(r, 0.0f, -r), .color = vec4(0.0f, 0.0f, 1.0f, 1.0f)},
        sb_vertex_t{.pos = vec3(-r, 0.0f, -r), .color = vec4(1.0f, 1.0f, 0.0f, 1.0f)},
        sb_vertex_t{.pos = vec3(-r, 0.0f, r), .color = vec4(0.0f, 1.0f, 1.0f, 1.0f)},
        sb_vertex_t{.pos = vec3(0.0f, r, 0.0f), .color = vec4(1.0f, 0.0f, 1.0f, 1.0f)},
    };
    sg_buffer sbuf = sg_make_buffer(&sg_buffer_desc{
        .usage = sg_buffer_usage{.storage_buffer = true},
        .data = sg_range{&vertices, sizeof(vertices)},
        .label = "geometry-vertices",
    });
    state.bind.views[VIEW_vertices] = sg_make_view(&sg_view_desc{
        .storage_buffer = sg_buffer_view_desc{.buffer = sbuf},
        .label = "geometry-vertices-view",
    });
    u16[24] indices = {0, 1, 2, 0, 2, 3, 0, 3, 4, 0, 4, 1, 5, 1, 2, 5, 2, 3, 5, 3, 4, 5, 4, 1};
    state.bind.index_buffer = sg_make_buffer(&sg_buffer_desc{
        .usage = sg_buffer_usage{.index_buffer = true},
        .data = sg_range{&indices, sizeof(indices)},
        .label = "geometry-indices",
    });
    state.inst_buf = sg_make_buffer(&sg_buffer_desc{
        .usage = sg_buffer_usage{.storage_buffer = true, .stream_update = true},
        .size = cast(u64, 512 * 1024 * sizeof(sb_instance_t)),
        .label = "instance-data",
    });
    state.bind.views[VIEW_instances] = sg_make_view(&sg_view_desc{
        .storage_buffer = sg_buffer_view_desc{.buffer = state.inst_buf},
        .label = "instance-data-view",
    });
    state.pip = sg_make_pipeline(&sg_pipeline_desc{
        .shader = sokol_make_shader(&instancing_pull_sapp_vs_shader, &instancing_pull_sapp_fs_shader),
        .index_type = SG_INDEXTYPE_UINT16,
        .cull_mode = SG_CULLMODE_BACK,
        .depth = sg_depth_state{.compare = SG_COMPAREFUNC_LESS_EQUAL, .write_enabled = true},
        .label = "instancing-pipeline",
    });
}

void frame() {
    if sg_query_features().compute == 0 {
        draw_fallback();
        return;
    }
    var frame_time = cast(f32, sapp_frame_duration());
    emit_particles();
    update_particles(frame_time);
    sg_update_buffer(state.inst_buf, &sg_range{
        .ptr = state.inst,
        .size = cast(u64, state.cur_num_particles) * cast(u64, sizeof(sb_instance_t)),
    });
    vs_params_t vs_params = compute_vsparams(frame_time);
    sg_begin_pass(&sg_pass{.action = state.pass_action, .swapchain = sglue_swapchain()});
    sg_apply_pipeline(state.pip);
    sg_apply_bindings(&state.bind);
    sg_apply_uniforms(UB_vs_params, &sg_range{&vs_params, sizeof(vs_params)});
    sg_draw(0, 24, state.cur_num_particles);
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

void emit_particles() {
    for i32 i = 0; i < 10; i++ {
        if state.cur_num_particles < 512 * 1024 {
            state.inst[state.cur_num_particles].pos = vec3(0.0f, 0.0f, 0.0f);
            state.vel[state.cur_num_particles] = vec3(cast(f32, xorshift32() & 0x7FFF) / 32767.0f - 0.5f, cast(f32, xorshift32() & 0x7FFF) / 32767.0f * 0.5f + 2.0f, cast(f32, xorshift32() & 0x7FFF) / 32767.0f - 0.5f);
            state.cur_num_particles++;
        } else {
            break;
        }
    }
}

void update_particles(f32 frame_time) {
    for i32 i = 0; i < state.cur_num_particles; i++ {
        state.vel[i].y -= 1.0f * frame_time;
        state.inst[i].pos.x += state.vel[i].x * frame_time;
        state.inst[i].pos.y += state.vel[i].y * frame_time;
        state.inst[i].pos.z += state.vel[i].z * frame_time;
        if state.inst[i].pos.y < -2.0f {
            state.inst[i].pos.y = -1.8f;
            state.vel[i].y = -state.vel[i].y;
            state.vel[i].x *= 0.8f;
            state.vel[i].y *= 0.8f;
            state.vel[i].z *= 0.8f;
        }
    }
}

vs_params_t compute_vsparams(f32 frame_time) {
    mat44_t proj = mat44_perspective_fov_rh(vecmath_radians(60.0f), sapp_widthf() / sapp_heightf(), 0.01f, 50.0f);
    mat44_t view = mat44_look_at_rh(vec3(0.0f, 1.5f, 8.0f), vec3(0.0f, 0.0f, 0.0f), vec3(0.0f, 1.0f, 0.0f));
    mat44_t view_proj = mat44_mul_mat44(view, proj);
    state.ry += 60.0f * frame_time;
    return vs_params_t{.mvp = mat44_mul_mat44(mat44_rotation_y(vecmath_radians(state.ry)), view_proj)};
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
        .window_title = "instancing-pull-sapp.mc",
        .icon = sapp_icon_desc{.sokol_default = true},
        .logger = sapp_logger{.func = slog_func},
    };
}
private { u32 xorshift32__x = 0x12345678; }
