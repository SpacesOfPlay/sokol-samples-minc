import dbgui;
import vecmath;

import sokol_all;
import math;

// force high-dpi, sample entry point is __sapp_sample_main()
sapp_desc sokol_main() {
    sapp_desc d = __sapp_sample_main();
    d.high_dpi = true;
    return d;
}

// instancing-compute-sapp.glsl, hand-ported. Two compute programs
// over one read-write storage buffer of particles, then an ordinary
// instanced draw that reads the same buffer as an instance vertex
// buffer (so the render side needs no storage binding).
//
// particle is all-float4, so minc's packed layout and std430 agree at
// 32 bytes and the element needs no padding.

struct particle {
    float4 pos;
    float4 vel;
}

struct Ub_cs_params {
    f32 dt;
    i32 num_particles;
}

struct InstancingComputeSappVsOut {
    float4 pos;
    float4 color;
}

u32 xorshift32(u32 x) {
    x = x ^ (x << 13);
    x = x ^ (x >> 17);
    x = x ^ (x << 5);
    return x;
}

// seed pseudo-random velocities
@shader compute(64, 1, 1)
void instancing_compute_sapp_cs_init(@rwbuffer(0) []particle prt) {
    u32 idx = thread_id().x;
    u32 x = xorshift32(cast(u32, 305419896) + idx);   // 0x12345678
    u32 y = xorshift32(x);
    u32 z = xorshift32(y);
    prt[idx].pos = float4{0.0f, 0.0f, 0.0f, 0.0f};
    prt[idx].vel = float4{
        cast(f32, x & 32767) / 32767.0f - 0.5f,
        cast(f32, y & 32767) / 32767.0f * 0.5f + 2.0f,
        cast(f32, z & 32767) / 32767.0f - 0.5f,
        0.0f};
}

// integrate, and bounce off the floor
@shader compute(64, 1, 1)
void instancing_compute_sapp_cs_update(
    @rwbuffer(0) []particle prt,
    @uniform(0) Ub_cs_params cs_params
) {
    u32 idx = thread_id().x;
    if idx >= cast(u32, cs_params.num_particles) { return; }
    float4 pos = prt[idx].pos;
    float4 vel = prt[idx].vel;
    vel.y = vel.y - 1.0f * cs_params.dt;
    pos = pos + vel * cs_params.dt;
    if pos.y < 0.0f - 2.0f {
        pos.y = 0.0f - 1.8f;
        vel = vel * float4{0.8f, 0.0f - 0.8f, 0.8f, 0.0f};
    }
    prt[idx].pos = pos;
    prt[idx].vel = vel;
}

@shader vertex
InstancingComputeSappVsOut instancing_compute_sapp_vs(
    @attr(0) float3 pos,
    @attr(1) float4 color0,
    @attr(2) float4 inst_pos,
    @uniform float4x4 mvp
) {
    InstancingComputeSappVsOut o;
    float4 p = float4{pos.x + inst_pos.x, pos.y + inst_pos.y, pos.z + inst_pos.z, 1.0f};
    o.pos = mul(mvp, p);
    o.color = color0;
    return o;
}

@shader fragment
float4 instancing_compute_sapp_fs(
InstancingComputeSappVsOut input
) {
    return input.color;
}

enum __enum_UB_vs_params {
    UB_vs_params = 0,
    UB_cs_params = 0,
    VIEW_cs_ssbo = 0,
    ATTR_display_pos = 0,
    ATTR_display_color0 = 1,
    ATTR_display_inst_pos = 2,
    __shim_end = 255,
}

// Replaces the sokol-shdc generated instancing-compute-sapp.glsl.h.
/* compute programs take the single-ShaderMeta overload */
struct vs_params_t {
    mat44_t mvp;
}

/* Tail-padded to 16: the declared uniform-block size rounds up, and
   sg_apply_uniforms asserts the range matches it exactly. */
struct cs_params_t {
    f32 dt;
    i32 num_particles;
    f32[2] _pad;
}

/* Storage-buffer element, matching the minc @shader `particle`. Both
   fields are 4-component, so minc's packed layout and std430 agree at
   32 bytes. The app only uses it for sizeof/stride. */
struct particle_t {
    f32[4] pos;
    f32[4] vel;
}

private struct state_t {
    i32 num_particles;
    f32 ry;
    sg_buffer buf;
    struct {
        sg_view sbuf_view;
        sg_pipeline pip;
    } compute;
    struct {
        sg_buffer vbuf;
        sg_buffer ibuf;
        sg_pipeline pip;
        sg_pass_action pass_action;
    } display;
}

private {
state_t state = state_t{
    .display = {
        .pass_action = {
            .colors[0] = {
                .load_action = SG_LOADACTION_CLEAR,
                .clear_value = {0.0f, 0.2f, 0.1f, 1.0f},
            },
        },
    },
};
}

private {
void init() {
    sg_setup(&sg_desc{.environment = sglue_environment(), .logger = sg_logger{.func = slog_func}});
    __dbgui_setup();
    state.buf = sg_make_buffer(&sg_buffer_desc{
        .size = cast(u64, 512 * 1024 * sizeof(particle_t)),
        .usage = sg_buffer_usage{.vertex_buffer = true, .storage_buffer = true},
        .label = "particle-buffer",
    });
    state.compute.sbuf_view = sg_make_view(&sg_view_desc{
        .storage_buffer = sg_buffer_view_desc{.buffer = state.buf},
        .label = "psrticle-buffer-view",
    });
    state.compute.pip = sg_make_pipeline(&sg_pipeline_desc{
        .compute = true,
        .shader = sokol_make_shader(&instancing_compute_sapp_cs_update_shader),
        .label = "update-pipeline",
    });
    f32 r = 0.05f;
    f32[42] vertices = {
        0.0f, -r, 0.0f, 1.0f, 0.0f, 0.0f, 1.0f, r, 0.0f, r, 0.0f, 1.0f, 0.0f, 1.0f, r, 0.0f, -r,
        0.0f, 0.0f, 1.0f, 1.0f, -r, 0.0f, -r, 1.0f, 1.0f, 0.0f, 1.0f, -r, 0.0f, r, 0.0f, 1.0f, 1.0f,
        1.0f, 0.0f, r, 0.0f, 1.0f, 0.0f, 1.0f, 1.0f,
    };
    u16[24] indices = {0, 1, 2, 0, 2, 3, 0, 3, 4, 0, 4, 1, 5, 1, 2, 5, 2, 3, 5, 3, 4, 5, 4, 1};
    state.display.vbuf = sg_make_buffer(&sg_buffer_desc{
        .data = sg_range{&vertices, sizeof(vertices)},
        .label = "geometry-vbuf",
    });
    state.display.ibuf = sg_make_buffer(&sg_buffer_desc{
        .usage = sg_buffer_usage{.index_buffer = true},
        .data = sg_range{&indices, sizeof(indices)},
        .label = "geometry-ibuf",
    });
    state.display.pip = sg_make_pipeline(&sg_pipeline_desc{
        .shader = sokol_make_shader(&instancing_compute_sapp_vs_shader, &instancing_compute_sapp_fs_shader),
        .layout = sg_vertex_layout_state{
            .buffers[1] = {
                .step_func = SG_VERTEXSTEP_PER_INSTANCE,
                .stride = cast(i32, sizeof(particle_t)),
            },
            .attrs = {
                sg_vertex_attr_state{.format = SG_VERTEXFORMAT_FLOAT3},
                sg_vertex_attr_state{.format = SG_VERTEXFORMAT_FLOAT4},
                sg_vertex_attr_state{.format = SG_VERTEXFORMAT_FLOAT4, .buffer_index = 1},
                sg_vertex_attr_state{},
                sg_vertex_attr_state{},
                sg_vertex_attr_state{},
                sg_vertex_attr_state{},
                sg_vertex_attr_state{},
                sg_vertex_attr_state{},
                sg_vertex_attr_state{},
                sg_vertex_attr_state{},
                sg_vertex_attr_state{},
                sg_vertex_attr_state{},
                sg_vertex_attr_state{},
                sg_vertex_attr_state{},
                sg_vertex_attr_state{},
            },
        },
        .index_type = SG_INDEXTYPE_UINT16,
        .depth = sg_depth_state{.compare = SG_COMPAREFUNC_LESS_EQUAL, .write_enabled = true},
        .cull_mode = SG_CULLMODE_BACK,
        .label = "render-pipeline",
    });
    sg_pipeline pip = sg_make_pipeline(&sg_pipeline_desc{
        .compute = true,
        .shader = sokol_make_shader(&instancing_compute_sapp_cs_init_shader),
    });
    sg_begin_pass(&sg_pass{.compute = true});
    sg_apply_pipeline(pip);
    sg_apply_bindings(&sg_bindings{.views[0] = state.compute.sbuf_view});
    sg_dispatch(512 * 1024 / 64, 1, 1);
    sg_end_pass();
    sg_destroy_pipeline(pip);
}

void frame() {
    state.num_particles += 10;
    if state.num_particles > 512 * 1024 {
        state.num_particles = 512 * 1024;
    }
    var dt = cast(f32, sapp_frame_duration());
    var cs_params = cs_params_t{.dt = dt, .num_particles = state.num_particles};
    sg_begin_pass(&sg_pass{.compute = true, .label = "compute-pass"});
    sg_apply_pipeline(state.compute.pip);
    sg_apply_bindings(&sg_bindings{.views[0] = state.compute.sbuf_view});
    sg_apply_uniforms(UB_cs_params, &sg_range{&cs_params, sizeof(cs_params)});
    sg_dispatch((state.num_particles + 63) / 64, 1, 1);
    sg_end_pass();
    vs_params_t vs_params = compute_vsparams(dt);
    sg_begin_pass(&sg_pass{
        .action = state.display.pass_action,
        .swapchain = sglue_swapchain(),
        .label = "render-pass",
    });
    sg_apply_pipeline(state.display.pip);
    sg_apply_bindings(&sg_bindings{
        .vertex_buffers = {
            state.display.vbuf,
            state.buf,
            sg_buffer{},
            sg_buffer{},
            sg_buffer{},
            sg_buffer{},
            sg_buffer{},
            sg_buffer{},
        },
        .index_buffer = state.display.ibuf,
    });
    sg_apply_uniforms(UB_vs_params, &sg_range{&vs_params, sizeof(vs_params)});
    sg_draw(0, 24, state.num_particles);
    __dbgui_draw();
    sg_end_pass();
    sg_commit();
}

void cleanup() {
    __dbgui_shutdown();
    sg_shutdown();
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
        .window_title = "instancing-compute-sapp.mc",
        .icon = sapp_icon_desc{.sokol_default = true},
        .logger = sapp_logger{.func = slog_func},
    };
}
