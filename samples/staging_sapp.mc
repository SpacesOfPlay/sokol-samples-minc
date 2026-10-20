import dbgui;
import sokol_shape;
import vecmath;

import sokol_all;
import math;

// force high-dpi, sample entry point is __sapp_sample_main()
sapp_desc sokol_main() {
    sapp_desc d = __sapp_sample_main();
    d.high_dpi = true;
    return d;
}

// staging-sapp.glsl, hand-ported.

struct StagingSappVsOut {
    float4 pos;
    float3 normal;
    float2 uv;
    float4 color;
}

struct Ub_vs_params {
    float4x4 mvp;
    float4x4 model;
}

@shader vertex
StagingSappVsOut staging_sapp_vs(
    @attr(0) float4 in_pos,
    @attr(1) float3 in_normal,
    @attr(2) float2 in_uv,
    @attr(3) float4 in_color,
    @uniform(0) Ub_vs_params vs_params
) {
    StagingSappVsOut o;
    o.pos = mul(vs_params.mvp, in_pos);
    o.normal = (mul(vs_params.model, float4{in_normal, 0.0f})).xyz;
    o.uv = in_uv * 10.0f;
    o.color = in_color;
    return o;
}

float3 gamma(float3 c) {
    return pow(c, float3{1.0f/2.2f});
}

@shader fragment
float4 staging_sapp_fs(
StagingSappVsOut input
) {
    const float3 light_dir = normalize(float3{1.0f, 1.0f, 1.0f});
    const f32 ambient = 0.1f;
    const f32 n_dot_l = max(dot(normalize(input.normal), light_dir), 0.0f);
    // checkerboard from uv
    f32 s = floor(input.uv.x) + floor(input.uv.y);
    f32 cb = max(s - 2.0f * floor(s / 2.0f), 0.15f);
    const float3 rgb = float3{cb} * input.color.rgb * (ambient + n_dot_l);
    return float4{gamma(rgb), 1.0f};
}


enum __enum_ATTR_shape_in_pos {
    ATTR_shape_in_pos = 0,
    ATTR_shape_in_normal = 1,
    ATTR_shape_in_uv = 2,
    ATTR_shape_in_color = 3,
    UB_vs_params = 0,
    __shim_end = 255,
}

// Replaces the sokol-shdc generated staging-sapp.glsl.h.
struct vs_params_t {
    mat44_t mvp;
    mat44_t model;
}

private struct state_t {
    sg_buffer vertex_buffer;
    sg_buffer index_buffer;
    sg_buffer vertex_staging_buffer;
    sg_buffer index_staging_buffer;
    sg_pipeline pip;
    sg_pass_action pass_action;
    i32 vtx_segment_size;
    i32 idx_segment_size;
    f64 shape_change_tracker;
    f32 rx;
    f32 ry;
    sshape_element_range_t[6] shapes;
    u32 next_segment;
    u32 next_shape_type;
}

private {
state_t state = state_t{
    .pass_action = sg_pass_action{
        .colors[0] = {.load_action = SG_LOADACTION_CLEAR, .clear_value = {0.1f, 0.1f, 0.15f, 1.0f}},
    },
};
}

private {
void init() {
    sg_setup(&sg_desc{.environment = sglue_environment(), .logger = sg_logger{.func = slog_func}});
    _dbgui_setup();
    var vtx_comps = sshape_optional_components_t{.colors = true, .texcoords = true, .normals = true};
    state.vtx_segment_size = 4096 * cast(i32, sshape_vertex_size(&vtx_comps));
    state.idx_segment_size = cast(i32, 4096 * 3 * sizeof(u16));
    state.vertex_staging_buffer = sg_make_buffer(&sg_buffer_desc{
        .usage = sg_buffer_usage{.staging_buffer = true, .write_transient = true, .copy_src = true},
        .size = cast(u64, state.vtx_segment_size),
        .label = "vertex-staging-buffer",
    });
    state.index_staging_buffer = sg_make_buffer(&sg_buffer_desc{
        .usage = sg_buffer_usage{
            .staging_index_buffer = true,
            .write_transient = true,
            .copy_src = true,
        },
        .size = cast(u64, state.idx_segment_size),
        .label = "index-staging-buffer",
    });
    state.vertex_buffer = sg_make_buffer(&sg_buffer_desc{
        .usage = sg_buffer_usage{.vertex_buffer = true, .copy_dst = true},
        .size = cast(u64, 6 * state.vtx_segment_size),
        .label = "vertex-buffer",
    });
    state.index_buffer = sg_make_buffer(&sg_buffer_desc{
        .usage = sg_buffer_usage{.index_buffer = true, .copy_dst = true},
        .size = cast(u64, 6 * state.idx_segment_size),
        .label = "index-buffer",
    });
    state.pip = sg_make_pipeline(&sg_pipeline_desc{
        .shader = sokol_make_shader(&staging_sapp_vs_shader, &staging_sapp_fs_shader),
        .layout = sg_vertex_layout_state{
            .attrs[0] = {.format = SG_VERTEXFORMAT_FLOAT3},
            .attrs[1] = {.format = SG_VERTEXFORMAT_BYTE4N},
            .attrs[3] = {.format = SG_VERTEXFORMAT_UBYTE4N},
            .attrs[2] = {.format = SG_VERTEXFORMAT_USHORT2N},
        },
        .index_type = SG_INDEXTYPE_UINT16,
        .cull_mode = SG_CULLMODE_BACK,
        .depth = sg_depth_state{.write_enabled = true, .compare = SG_COMPAREFUNC_LESS_EQUAL},
        .label = "shape-pipeline",
    });
}

void frame() {
    f64 dt = sapp_frame_duration();
    state.shape_change_tracker -= dt;
    if state.shape_change_tracker < 0.0 {
        state.shape_change_tracker += 0.5;
        update_next_segment();
    }
    vs_params_t vs_params = compute_vsparams(dt);
    _dbgui_update();
    sg_begin_pass(&sg_pass{.action = state.pass_action, .swapchain = sglue_swapchain()});
    sg_apply_pipeline(state.pip);
    sg_apply_uniforms(UB_vs_params, &sg_range{&vs_params, sizeof(vs_params)});
    for u32 seg = 0; seg < 6; seg++ {
        if state.shapes[seg].num_elements > 0 {
            apply_segment_viewport(seg);
            sg_apply_bindings(&sg_bindings{
                .vertex_buffers[0] = state.vertex_buffer,
                .vertex_buffer_offsets[0] = cast(i32, seg * cast(u32, state.vtx_segment_size)),
                .index_buffer = state.index_buffer,
                .index_buffer_offset = cast(i32, seg * cast(u32, state.idx_segment_size)),
            });
            sg_draw(state.shapes[seg].base_element, state.shapes[seg].num_elements, 1);
        }
    }
    _dbgui_draw();
    sg_end_pass();
    sg_commit();
}

void cleanup() {
    _dbgui_shutdown();
    sg_shutdown();
}

void apply_segment_viewport(u32 seg) {
    var row = cast(i32, seg & 1);
    var col = cast(i32, seg >> 1);
    i32 seg_h = sapp_height() / 2;
    i32 seg_w = sapp_width() / (6 / 2);
    i32 seg_x = col * seg_w;
    i32 seg_y = row * seg_h;
    sg_apply_viewport(seg_x, seg_y, seg_w, seg_h, true);
}

vs_params_t compute_vsparams(f64 dt) {
    var t = cast(f32, dt * 60.0);
    state.rx += 1.0f * t;
    state.ry += 2.0f * t;
    f32 w = sapp_widthf();
    f32 h = sapp_heightf();
    mat44_t proj = mat44_perspective_fov_rh(vecmath_radians(60.0f), w / h, 0.01f, 10.0f);
    mat44_t view = mat44_look_at_rh(vec3(0.0f, 0.0f, 3.0f), vec3(0.0f, 0.0f, 0.0f), vec3(0.0f, 1.0f, 0.0f));
    mat44_t view_proj = mat44_mul_mat44(view, proj);
    mat44_t rxm = mat44_rotation_x(vecmath_radians(state.rx));
    mat44_t rym = mat44_rotation_y(vecmath_radians(state.ry));
    mat44_t model = mat44_mul_mat44(rym, rxm);
    return vs_params_t{.mvp = mat44_mul_mat44(model, view_proj), .model = model};
}

u32 xorshift32() {
    xorshift32__x ^= xorshift32__x << 13;
    xorshift32__x ^= xorshift32__x >> 17;
    xorshift32__x ^= xorshift32__x << 5;
    return xorshift32__x;
}

void update_next_segment() {
    u32 seg = state.next_segment;
    u32 shape_type = state.next_shape_type;
    state.next_segment = (state.next_segment + 1) % 6;
    state.next_shape_type = (state.next_shape_type + 1) % 4;
    u32 color = xorshift32() + 0x00666666 | 0xFF000000;
    var shp = sshape_state_t{
        .vertices = sshape_buffer_state_t{
            .buffer = sshape_range_t{
                &update_next_segment__vertices, sizeof(update_next_segment__vertices),
            },
        },
        .indices = sshape_buffer_state_t{
            .buffer = sshape_range_t{
                &update_next_segment__indices, sizeof(update_next_segment__indices),
            },
        },
    };
    switch shape_type {
        case 0: {
            sshape_build_box(&shp, &sshape_box_t{
                .width = 1.0f,
                .height = 1.0f,
                .depth = 1.0f,
                .tiles = 1,
                .color = color,
            });
        }
        case 1: {
            sshape_build_sphere(&shp, &sshape_sphere_t{
                .radius = 0.75f,
                .slices = 36,
                .stacks = 20,
                .color = color,
            });
        }
        case 2: {
            sshape_build_cylinder(&shp, &sshape_cylinder_t{
                .radius = 0.5f,
                .height = 1.5f,
                .slices = 36,
                .stacks = 10,
                .color = color,
            });
        }
        default: {
            sshape_build_torus(&shp, &sshape_torus_t{
                .radius = 0.5f,
                .ring_radius = 0.3f,
                .rings = 36,
                .sides = 18,
                .color = color,
            });
        }
    }
    state.shapes[seg] = sshape_element_range(&shp);
    sg_range vtx_data = sshape_vertex_buffer_desc(&shp).data;
    sg_range idx_data = sshape_index_buffer_desc(&shp).data;
    sg_write_buffer_transient(&sg_write_buffer_desc{
        .src = sg_write_buffer_source{.data = vtx_data},
        .dst = sg_buffer_location{.buffer = state.vertex_staging_buffer},
    });
    sg_write_buffer_transient(&sg_write_buffer_desc{
        .src = sg_write_buffer_source{.data = idx_data},
        .dst = sg_buffer_location{.buffer = state.index_staging_buffer},
    });
    sg_copy_buffer_to_buffer(&sg_copy_buffer_to_buffer_desc{
        .src = sg_buffer_location{.buffer = state.vertex_staging_buffer},
        .dst = sg_buffer_location{
            .buffer = state.vertex_buffer,
            .offset = cast(u64, seg * cast(u32, state.vtx_segment_size)),
        },
        .size = vtx_data.size,
    });
    sg_copy_buffer_to_buffer(&sg_copy_buffer_to_buffer_desc{
        .src = sg_buffer_location{.buffer = state.index_staging_buffer},
        .dst = sg_buffer_location{
            .buffer = state.index_buffer,
            .offset = cast(u64, seg * cast(u32, state.idx_segment_size)),
        },
        .size = idx_data.size,
    });
}
}

sapp_desc __sapp_sample_main() {
    return sapp_desc{
        .init_cb = init,
        .frame_cb = frame,
        .cleanup_cb = cleanup,
        .event_cb = _dbgui_event,
        .width = 800,
        .height = 600,
        .sample_count = 4,
        .window_title = "staging-sapp.mc",
        .icon = sapp_icon_desc{.sokol_default = true},
        .logger = sapp_logger{.func = slog_func},
    };
}
private {
u32 xorshift32__x = 0x12345678;
u8[98304] update_next_segment__vertices;
u16[4096 * 3] update_next_segment__indices;
}
