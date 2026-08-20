import dbgui;
import sokol_debugtext;
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

// shapes-sapp.glsl - ported to minc @shader.

struct ShapesSappVsOut {
    float4 pos;
    float4 color;
}

@gpu_layout
struct Ub_vs_params {
    float4x4 mvp;
    f32 draw_mode;
}

@shader vertex
ShapesSappVsOut shapes_sapp_vs(
    @attr(0) float4 position,
    @attr(1) float3 normal,
    @attr(2) float2 texcoord,
    @attr(3) float4 color0,
    @uniform(0) Ub_vs_params vs_params
) {
    ShapesSappVsOut o;
    o.pos = mul(vs_params.mvp, position);
    if (vs_params.draw_mode == 0.0f) {
    o.color = float4{(normal + 1.0f) * 0.5f, 1.0f};
    }
    else if (vs_params.draw_mode == 1.0f) {
    o.color = float4{texcoord, 0.0f, 1.0f};
    }
    else {
    o.color = color0;
    }
    return o;
}

@shader fragment
float4 shapes_sapp_fs(
ShapesSappVsOut input
) {
    return input.color;
}


enum __enum_ATTR_shapes_position {
    ATTR_shapes_position = 0,
    ATTR_shapes_normal = 1,
    ATTR_shapes_texcoord = 2,
    ATTR_shapes_color0 = 3,
    UB_vs_params = 0,
    __shim_end = 255,
}

enum __enum_BOX {
    BOX = 0,
    PLANE = 1,
    SPHERE = 2,
    CYLINDER = 3,
    TORUS = 4,
    NUM_SHAPES = 5,
}

type __arr_f32_4 = f32[4];
// Replaces the sokol-shdc generated shapes-sapp.glsl.h.
struct vs_params_t {
    mat44_t mvp;
    f32 draw_mode;
    u8[12] _pad_tail;
}

struct shape_t {
    vec3_t pos;
    sshape_element_range_t draw;
}

private struct state_t {
    sg_pass_action pass_action;
    sg_pipeline pip;
    sg_buffer vbuf;
    sg_buffer ibuf;
    shape_t[5] shapes;
    vs_params_t vs_params;
    f32 rx;
    f32 ry;
}

private {
state_t state;

void init() {
    sg_setup(&sg_desc{.environment = sglue_environment(), .logger = sg_logger{.func = slog_func}});
    sdtx_setup(&sdtx_desc_t{
        .fonts[0] = sdtx_font_oric(),
        .logger = sdtx_logger_t{.func = slog_func},
    });
    __dbgui_setup();
    state.pass_action = sg_pass_action{
        .colors[0] = {.load_action = SG_LOADACTION_CLEAR, .clear_value = {0.0f, 0.0f, 0.0f, 1.0f}},
    };
    state.shapes[BOX].pos = vec3(-1.0f, 1.0f, 0.0f);
    state.shapes[PLANE].pos = vec3(1.0f, 1.0f, 0.0f);
    state.shapes[SPHERE].pos = vec3(-2.0f, -1.0f, 0.0f);
    state.shapes[CYLINDER].pos = vec3(2.0f, -1.0f, 0.0f);
    state.shapes[TORUS].pos = vec3(0.0f, -1.0f, 0.0f);
    noinit u16[16384] indices;
    var shp = sshape_state_t{
        .vertices = sshape_buffer_state_t{.buffer = sshape_range_t{&init__vertices, sizeof(init__vertices)}},
        .indices = sshape_buffer_state_t{.buffer = sshape_range_t{&indices, sizeof(indices)}},
    };
    sshape_build_box(&shp, &sshape_box_t{
        .width = 1.0f,
        .height = 1.0f,
        .depth = 1.0f,
        .tiles = 10,
        .random_colors = true,
    });
    state.shapes[BOX].draw = sshape_element_range(&shp);
    sshape_build_plane(&shp, &sshape_plane_t{
        .width = 1.0f,
        .depth = 1.0f,
        .tiles = 10,
        .random_colors = true,
    });
    state.shapes[PLANE].draw = sshape_element_range(&shp);
    sshape_build_sphere(&shp, &sshape_sphere_t{
        .radius = 0.75f,
        .slices = 36,
        .stacks = 20,
        .random_colors = true,
    });
    state.shapes[SPHERE].draw = sshape_element_range(&shp);
    sshape_build_cylinder(&shp, &sshape_cylinder_t{
        .radius = 0.5f,
        .height = 1.5f,
        .slices = 36,
        .stacks = 10,
        .random_colors = true,
    });
    state.shapes[CYLINDER].draw = sshape_element_range(&shp);
    sshape_build_torus(&shp, &sshape_torus_t{
        .radius = 0.5f,
        .ring_radius = 0.3f,
        .rings = 36,
        .sides = 18,
        .random_colors = true,
    });
    state.shapes[TORUS].draw = sshape_element_range(&shp);
    sg_buffer_desc vbuf_desc = sshape_vertex_buffer_desc(&shp);
    sg_buffer_desc ibuf_desc = sshape_index_buffer_desc(&shp);
    state.vbuf = sg_make_buffer(&vbuf_desc);
    state.ibuf = sg_make_buffer(&ibuf_desc);
    state.pip = sg_make_pipeline(&sg_pipeline_desc{
        .shader = sokol_make_shader(&shapes_sapp_vs_shader, &shapes_sapp_fs_shader),
        .layout = sg_vertex_layout_state{
            .buffers[0] = sshape_vertex_buffer_layout_state(&shp),
            .attrs = {
                sshape_position_vertex_attr_state(&shp),
                sshape_normal_vertex_attr_state(&shp),
                sshape_texcoord_vertex_attr_state(&shp),
                sshape_color_vertex_attr_state(&shp),
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
        .cull_mode = SG_CULLMODE_NONE,
        .depth = sg_depth_state{.compare = SG_COMPAREFUNC_LESS_EQUAL, .write_enabled = true},
    });
}

void frame() {
    sdtx_canvas(cast(f32, sapp_width()) * 0.5f, cast(f32, sapp_height()) * 0.5f);
    sdtx_pos(0.5f, 0.5f);
    sdtx_puts("press key to switch draw mode:\n\n  1: vertex normals\n  2: texture coords\n  3: vertex color");
    mat44_t proj = mat44_perspective_fov_rh(vecmath_radians(60.0f), sapp_widthf() / sapp_heightf(), 0.01f, 10.0f);
    mat44_t view = mat44_look_at_rh(vec3(0.0f, 1.5f, 4.0f), vec3(0.0f, 0.0f, 0.0f), vec3(0.0f, 1.0f, 0.0f));
    mat44_t view_proj = mat44_mul_mat44(view, proj);
    var t = cast(f32, sapp_frame_duration() * 60.0);
    state.rx += 1.0f * t;
    state.ry += 2.0f * t;
    mat44_t rxm = mat44_rotation_x(vecmath_radians(state.rx));
    mat44_t rym = mat44_rotation_y(vecmath_radians(state.ry));
    mat44_t rm = mat44_mul_mat44(rym, rxm);
    sg_begin_pass(&sg_pass{.action = state.pass_action, .swapchain = sglue_swapchain()});
    sg_apply_pipeline(state.pip);
    sg_apply_bindings(&sg_bindings{.vertex_buffers[0] = state.vbuf, .index_buffer = state.ibuf});
    for i32 i = 0; i < NUM_SHAPES; i++ {
        mat44_t model = mat44_mul_mat44(rm, mat44_translation(state.shapes[i].pos.x, state.shapes[i].pos.y, state.shapes[i].pos.z));
        state.vs_params.mvp = mat44_mul_mat44(model, view_proj);
        sg_apply_uniforms(UB_vs_params, &sg_range{&state.vs_params, sizeof(state.vs_params)});
        sg_draw(state.shapes[i].draw.base_element, state.shapes[i].draw.num_elements, 1);
    }
    sdtx_draw();
    __dbgui_draw();
    sg_end_pass();
    sg_commit();
}

void input(sapp_event* ev) {
    if ev.type == SAPP_EVENTTYPE_KEY_DOWN {
        switch ev.key_code {
            case SAPP_KEYCODE_1: {
                state.vs_params.draw_mode = 0.0f;
            }
            case SAPP_KEYCODE_2: {
                state.vs_params.draw_mode = 1.0f;
            }
            case SAPP_KEYCODE_3: {
                state.vs_params.draw_mode = 2.0f;
            }
            default: {
            }
        }
    }
    __dbgui_event(ev);
}

void cleanup() {
    __dbgui_shutdown();
    sdtx_shutdown();
    sg_shutdown();
}
}

sapp_desc __sapp_sample_main() {
    return sapp_desc{
        .init_cb = init,
        .frame_cb = frame,
        .cleanup_cb = cleanup,
        .event_cb = input,
        .width = 800,
        .height = 600,
        .sample_count = 4,
        .window_title = "shapes-sapp.mc",
        .icon = sapp_icon_desc{.sokol_default = true},
        .logger = sapp_logger{.func = slog_func},
    };
}
private { u8[147456] init__vertices; }
