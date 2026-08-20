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

// instancing-sapp.glsl - ported to minc @shader.

struct InstancingSappVsOut {
    float4 pos;
    float4 color;
}

@shader vertex
InstancingSappVsOut instancing_sapp_vs(
    @attr(0) float3 pos,
    @attr(1) float4 color0,
    @attr(2) float3 inst_pos,
    @uniform float4x4 mvp
) {
    InstancingSappVsOut o;
    // upstream GLSL shadows the `in pos` attr with a local of the same
    // name (the initializer sees the outer one there; minc's would not)
    float4 p4 = float4{pos + inst_pos, 1.0f};
    o.pos = mul(mvp, p4);
    o.color = color0;
    return o;
}

@shader fragment
float4 instancing_sapp_fs(
InstancingSappVsOut input
) {
    return input.color;
}


enum __enum_ATTR_instancing_pos {
    ATTR_instancing_pos = 0,
    ATTR_instancing_color0 = 1,
    ATTR_instancing_inst_pos = 2,
    UB_vs_params = 0,
    __shim_end = 255,
}

// Replaces the sokol-shdc generated instancing-sapp.glsl.h.
struct vs_params_t {
    mat44_t mvp;
}

private struct state_t {
    sg_pass_action pass_action;
    sg_pipeline pip;
    sg_bindings bind;
    f32 ry;
    i32 cur_num_particles;
    vec3_t[524288] pos;
    vec3_t[524288] vel;
}

private {
state_t state;

u32 xorshift32() {
    xorshift32__x ^= xorshift32__x << 13;
    xorshift32__x ^= xorshift32__x >> 17;
    xorshift32__x ^= xorshift32__x << 5;
    return xorshift32__x;
}

void init() {
    sg_setup(&sg_desc{.environment = sglue_environment(), .logger = sg_logger{.func = slog_func}});
    __dbgui_setup();
    state.pass_action = sg_pass_action{
        .colors[0] = {.load_action = SG_LOADACTION_CLEAR, .clear_value = {0.0f, 0.0f, 0.0f, 1.0f}},
    };
    f32 r = 0.05f;
    f32[42] vertices = {
        0.0f, -r, 0.0f, 1.0f, 0.0f, 0.0f, 1.0f, r, 0.0f, r, 0.0f, 1.0f, 0.0f, 1.0f, r, 0.0f, -r,
        0.0f, 0.0f, 1.0f, 1.0f, -r, 0.0f, -r, 1.0f, 1.0f, 0.0f, 1.0f, -r, 0.0f, r, 0.0f, 1.0f, 1.0f,
        1.0f, 0.0f, r, 0.0f, 1.0f, 0.0f, 1.0f, 1.0f,
    };
    state.bind.vertex_buffers[0] = sg_make_buffer(&sg_buffer_desc{
        .data = sg_range{&vertices, sizeof(vertices)},
        .label = "geometry-vertices",
    });
    u16[24] indices = {0, 1, 2, 0, 2, 3, 0, 3, 4, 0, 4, 1, 5, 1, 2, 5, 2, 3, 5, 3, 4, 5, 4, 1};
    state.bind.index_buffer = sg_make_buffer(&sg_buffer_desc{
        .usage = sg_buffer_usage{.index_buffer = true},
        .data = sg_range{&indices, sizeof(indices)},
        .label = "geometry-indices",
    });
    state.bind.vertex_buffers[1] = sg_make_buffer(&sg_buffer_desc{
        .size = cast(u64, 512 * 1024 * sizeof(vec3_t)),
        .usage = sg_buffer_usage{.stream_update = true},
        .label = "instance-data",
    });
    sg_shader shd = sokol_make_shader(&instancing_sapp_vs_shader, &instancing_sapp_fs_shader);
    state.pip = sg_make_pipeline(&sg_pipeline_desc{
        .layout = sg_vertex_layout_state{
            .buffers[1] = {.step_func = SG_VERTEXSTEP_PER_INSTANCE},
            .attrs = {
                sg_vertex_attr_state{.format = SG_VERTEXFORMAT_FLOAT3, .buffer_index = 0},
                sg_vertex_attr_state{.format = SG_VERTEXFORMAT_FLOAT4, .buffer_index = 0},
                sg_vertex_attr_state{.format = SG_VERTEXFORMAT_FLOAT3, .buffer_index = 1},
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
        .shader = shd,
        .index_type = SG_INDEXTYPE_UINT16,
        .cull_mode = SG_CULLMODE_BACK,
        .depth = sg_depth_state{.compare = SG_COMPAREFUNC_LESS_EQUAL, .write_enabled = true},
        .label = "instancing-pipeline",
    });
}

void frame() {
    var frame_time = cast(f32, sapp_frame_duration());
    for i32 i = 0; i < 10; i++ {
        if state.cur_num_particles < 512 * 1024 {
            state.pos[state.cur_num_particles] = vec3(0.0f, 0.0f, 0.0f);
            state.vel[state.cur_num_particles] = vec3(cast(f32, xorshift32() & 0x7FFF) / 32767.0f - 0.5f, cast(f32, xorshift32() & 0x7FFF) / 32767.0f * 0.5f + 2.0f, cast(f32, xorshift32() & 0x7FFF) / 32767.0f - 0.5f);
            state.cur_num_particles++;
        } else {
            break;
        }
    }
    for i32 i = 0; i < state.cur_num_particles; i++ {
        state.vel[i].y -= 1.0f * frame_time;
        state.pos[i].x += state.vel[i].x * frame_time;
        state.pos[i].y += state.vel[i].y * frame_time;
        state.pos[i].z += state.vel[i].z * frame_time;
        if state.pos[i].y < -2.0f {
            state.pos[i].y = -1.8f;
            state.vel[i].y = -state.vel[i].y;
            state.vel[i].x *= 0.8f;
            state.vel[i].y *= 0.8f;
            state.vel[i].z *= 0.8f;
        }
    }
    sg_update_buffer(state.bind.vertex_buffers[1], &sg_range{
        .ptr = state.pos,
        .size = cast(u64, state.cur_num_particles) * cast(u64, sizeof(vec3_t)),
    });
    mat44_t proj = mat44_perspective_fov_rh(vecmath_radians(60.0f), sapp_widthf() / sapp_heightf(), 0.01f, 50.0f);
    mat44_t view = mat44_look_at_rh(vec3(0.0f, 1.5f, 8.0f), vec3(0.0f, 0.0f, 0.0f), vec3(0.0f, 1.0f, 0.0f));
    mat44_t view_proj = mat44_mul_mat44(view, proj);
    state.ry += 60.0f * frame_time;
    var vs_params = vs_params_t{.mvp = mat44_mul_mat44(mat44_rotation_y(vecmath_radians(state.ry)), view_proj)};
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
        .window_title = "instancing-sapp.mc",
        .icon = sapp_icon_desc{.sokol_default = true},
        .logger = sapp_logger{.func = slog_func},
    };
}
private { u32 xorshift32__x = 0x12345678; }
