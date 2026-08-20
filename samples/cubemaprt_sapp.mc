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

// cubemaprt-sapp.glsl - ported to minc @shader.

struct CubemaprtSappVsOut {
    float4 pos;
    float3 world_position;
    float3 world_normal;
    float3 world_eyepos;
    float3 world_lightdir;
    float4 color;
}

struct Ub_shape_uniforms {
    float4x4 mvp;
    float4x4 model;
    float4 shape_color;
    float4 light_dir;
    float4 eye_pos;
}

@shader vertex
CubemaprtSappVsOut cubemaprt_sapp_vs(
    @attr(0) float4 pos,
    @attr(1) float3 norm,
    @uniform(0) Ub_shape_uniforms shape_uniforms
) {
    CubemaprtSappVsOut o;
    o.pos = mul(shape_uniforms.mvp, pos);
    o.world_position = mul(shape_uniforms.model, pos).xyz;
    o.world_normal = mul(shape_uniforms.model, float4{norm, 0.0f}).xyz;
    o.world_eyepos = shape_uniforms.eye_pos.xyz;
    o.world_lightdir = shape_uniforms.light_dir.xyz;
    o.color = shape_uniforms.shape_color;
    return o;
}

float3 light(float3 base_color, float3 eye_vec, float3 normal, float3 light_vec) {
    f32 ambient = 0.25f;
    f32 n_dot_l = max(dot(normal, light_vec), 0.0f);
    f32 diff = n_dot_l + ambient;
    f32 spec_power = 16.0f;
    float3 r = reflect(-light_vec, normal);
    f32 r_dot_v = max(dot(r, eye_vec), 0.0f);
    f32 spec = pow(r_dot_v, spec_power) * n_dot_l;
    return base_color * (diff+ambient) + float3{spec,spec,spec};
}

@shader fragment
float4 cubemaprt_sapp_fs_shapes(
CubemaprtSappVsOut input
) {
    float3 eye_vec = normalize(input.world_eyepos - input.world_position);
    float3 nrm = normalize(input.world_normal);
    float3 light_dir = normalize(input.world_lightdir);
    return float4{light(input.color.xyz, eye_vec, nrm, light_dir), 1.0f};
}

@shader fragment
float4 cubemaprt_sapp_fs_cube(
CubemaprtSappVsOut input,
    @texture(0) TextureCube tex,
    @sampler(0) Sampler smp
) {
    float3 eye_vec = normalize(input.world_eyepos - input.world_position);
    float3 nrm = normalize(input.world_normal);
    float3 light_dir = normalize(input.world_lightdir);
    float3 refl_vec = normalize(input.world_position);
    float3 refl_color = sample(tex, smp, refl_vec).xyz;
    return float4{light(refl_color * input.color.xyz, eye_vec, nrm, light_dir), 1.0f};
}


enum __enum_ATTR_shapes_pos {
    ATTR_shapes_pos = 0,
    ATTR_shapes_norm = 1,
    ATTR_cube_pos = 0,
    ATTR_cube_norm = 1,
    UB_shape_uniforms = 0,
    VIEW_tex = 0,
    SMP_smp = 0,
    __shim_end = 255,
}

type __arr_vec3_t_2 = vec3_t[2];
// Replaces the sokol-shdc generated cubemaprt-sapp.glsl.h.
struct shape_uniforms_t {
    mat44_t mvp;
    mat44_t model;
    vec4_t shape_color;
    vec4_t light_dir;
    vec4_t eye_pos;
}

// NOTE: cubemaps can't be multisampled, so (OFFSCREEN_SAMPLE_COUNT > 1) will be a validation error
/* state struct for the little cubes rotating around the big cube */
struct shape_t {
    mat44_t model;
    vec4_t color;
    vec3_t axis;
    f32 radius;
    f32 angle;
    f32 angular_velocity;
}

// vertex (normals for simple point lighting)
struct vertex_t {
    f32[3] pos;
    f32[3] norm;
}

// a mesh consists of a vertex- and index-buffer
struct mesh_t {
    sg_buffer vbuf;
    sg_buffer ibuf;
    i32 num_elements;
}

// the entire application state
struct app_t {
    sg_image cubemap;
    sg_view cubemap_texview;
    sg_sampler smp;
    sg_view[6] offscreen_color_views;
    sg_view offscreen_depth_view;
    sg_pass_action offscreen_pass_action;
    sg_pass_action display_pass_action;
    mesh_t cube;
    sg_pipeline offscreen_shapes_pip;
    sg_pipeline display_shapes_pip;
    sg_pipeline display_cube_pip;
    mat44_t offscreen_proj;
    vec4_t light_dir;
    f32 rx;
    f32 ry;
    shape_t[32] shapes;
}

private { app_t app; }

private {
u32 xorshift32() {
    xorshift32__x ^= xorshift32__x << 13;
    xorshift32__x ^= xorshift32__x >> 17;
    xorshift32__x ^= xorshift32__x << 5;
    return xorshift32__x;
}

f32 rnd(f32 min_val, f32 max_val) {
    return cast(f32, xorshift32() & 0xFFFF) / 65536.0f * (max_val - min_val) + min_val;
}

void init() {
    sg_setup(&sg_desc{.environment = sglue_environment(), .logger = sg_logger{.func = slog_func}});
    __dbgui_setup();
    app.cubemap = sg_make_image(&sg_image_desc{
        .type = SG_IMAGETYPE_CUBE,
        .usage = sg_image_usage{.color_attachment = true},
        .width = 1024,
        .height = 1024,
        .sample_count = 1,
        .label = "cubemap-color-rt",
    });
    app.cubemap_texview = sg_make_view(&sg_view_desc{
        .texture = sg_texture_view_desc{.image = app.cubemap},
        .label = "cubemap-texview",
    });
    sg_image depth_img = sg_make_image(&sg_image_desc{
        .type = SG_IMAGETYPE_2D,
        .usage = sg_image_usage{.depth_stencil_attachment = true},
        .width = 1024,
        .height = 1024,
        .pixel_format = SG_PIXELFORMAT_DEPTH,
        .sample_count = 1,
        .label = "cubemap-depth-rt",
    });
    for i32 i = 0; i < 6; i++ {
        noinit u8[32] label;
        snprintf(label, sizeof(label), "cubemap-texview-%d", i);
        app.offscreen_color_views[i] = sg_make_view(&sg_view_desc{
            .color_attachment = sg_image_view_desc{.image = app.cubemap, .slice = i},
            .label = label,
        });
    }
    app.offscreen_depth_view = sg_make_view(&sg_view_desc{
        .depth_stencil_attachment = sg_image_view_desc{.image = depth_img},
        .label = "depth-stencil-attachment",
    });
    app.offscreen_pass_action = sg_pass_action{
        .colors[0] = {.load_action = SG_LOADACTION_CLEAR, .clear_value = {0.5f, 0.5f, 0.5f, 1.0f}},
    };
    app.display_pass_action = sg_pass_action{
        .colors[0] = {
            .load_action = SG_LOADACTION_CLEAR,
            .clear_value = {0.75f, 0.75f, 0.75f, 1.0f},
        },
    };
    app.cube = make_cube_mesh();
    var pip_desc = sg_pipeline_desc{
        .shader = sokol_make_shader(&cubemaprt_sapp_vs_shader, &cubemaprt_sapp_fs_shapes_shader),
        .layout = sg_vertex_layout_state{
            .attrs = {
                sg_vertex_attr_state{
                    .offset = cast(u32, &cast(vertex_t*, 0).pos),
                    .format = SG_VERTEXFORMAT_FLOAT3,
                },
                sg_vertex_attr_state{
                    .offset = cast(u32, &cast(vertex_t*, 0).norm),
                    .format = SG_VERTEXFORMAT_FLOAT3,
                },
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
                sg_vertex_attr_state{},
            },
        },
        .index_type = SG_INDEXTYPE_UINT16,
        .cull_mode = SG_CULLMODE_BACK,
        .sample_count = 1,
        .depth = sg_depth_state{
            .pixel_format = SG_PIXELFORMAT_DEPTH,
            .compare = SG_COMPAREFUNC_LESS_EQUAL,
            .write_enabled = true,
        },
        .label = "offscreen-shapes-pipeline",
    };
    app.offscreen_shapes_pip = sg_make_pipeline(&pip_desc);
    pip_desc.sample_count = 4;
    pip_desc.depth.pixel_format = 0;
    pip_desc.label = "display-shapes-pipeline";
    app.display_shapes_pip = sg_make_pipeline(&pip_desc);
    app.display_cube_pip = sg_make_pipeline(&sg_pipeline_desc{
        .shader = sokol_make_shader(&cubemaprt_sapp_vs_shader, &cubemaprt_sapp_fs_cube_shader),
        .layout = sg_vertex_layout_state{
            .attrs = {
                sg_vertex_attr_state{
                    .offset = cast(u32, &cast(vertex_t*, 0).pos),
                    .format = SG_VERTEXFORMAT_FLOAT3,
                },
                sg_vertex_attr_state{
                    .offset = cast(u32, &cast(vertex_t*, 0).norm),
                    .format = SG_VERTEXFORMAT_FLOAT3,
                },
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
                sg_vertex_attr_state{},
            },
        },
        .index_type = SG_INDEXTYPE_UINT16,
        .cull_mode = SG_CULLMODE_BACK,
        .sample_count = 4,
        .depth = sg_depth_state{.compare = SG_COMPAREFUNC_LESS_EQUAL, .write_enabled = true},
    });
    app.smp = sg_make_sampler(&sg_sampler_desc{
        .min_filter = SG_FILTER_LINEAR,
        .mag_filter = SG_FILTER_LINEAR,
    });
    app.offscreen_proj = mat44_perspective_fov_rh(vecmath_radians(90.0f), 1.0f, 0.01f, 100.0f);
    app.light_dir = vec4v3f(vec3_normalize(vec3(-0.75f, 1.0f, 0.0f)), 0.0f);
    for i32 i = 0; i < 32; i++ {
        app.shapes[i].color = vec4(rnd(0.0f, 1.0f), rnd(0.0f, 1.0f), rnd(0.0f, 1.0f), 1.0f);
        app.shapes[i].axis = vec3_normalize(vec3(rnd(-1.0f, 1.0f), rnd(-1.0f, 1.0f), rnd(-1.0f, 1.0f)));
        app.shapes[i].radius = rnd(5.0f, 10.0f);
        app.shapes[i].angle = rnd(0.0f, 360.0f);
        app.shapes[i].angular_velocity = rnd(15.0f, 50.0f) * (rnd(-1.0f, 1.0f) > 0.0f ? 1.0f : -1.0f);
    }
}

void frame() {
    var t = cast(f32, sapp_frame_duration());
    for i32 i = 0; i < 32; i++ {
        app.shapes[i].angle += app.shapes[i].angular_velocity * t;
        mat44_t scale = mat44_scaling(0.25f, 0.25f, 0.25f);
        mat44_t rot = mat44_rotation_axis(app.shapes[i].axis, vecmath_radians(app.shapes[i].angle));
        mat44_t trans = mat44_translation(0.0f, 0.0f, app.shapes[i].radius);
        app.shapes[i].model = mat44_mul_mat44(mat44_mul_mat44(scale, trans), rot);
    }
    __arr_vec3_t_2[6] center_and_up;
    when defined(SOKOL_METAL) || defined(SOKOL_D3D11) || defined(SOKOL_WGPU) {
        center_and_up = {
            {{.x = 1.0f, .y = 0.0f, .z = 0.0f}, {.x = 0.0f, .y = -1.0f, .z = 0.0f}},
            {{.x = -1.0f, .y = 0.0f, .z = 0.0f}, {.x = 0.0f, .y = -1.0f, .z = 0.0f}},
            {{.x = 0.0f, .y = -1.0f, .z = 0.0f}, {.x = 0.0f, .y = 0.0f, .z = -1.0f}},
            {{.x = 0.0f, .y = 1.0f, .z = 0.0f}, {.x = 0.0f, .y = 0.0f, .z = 1.0f}},
            {{.x = 0.0f, .y = 0.0f, .z = 1.0f}, {.x = 0.0f, .y = -1.0f, .z = 0.0f}},
            {{.x = 0.0f, .y = 0.0f, .z = -1.0f}, {.x = 0.0f, .y = -1.0f, .z = 0.0f}},
        };
    } else {
        center_and_up = {
            {{.x = 1.0f, .y = 0.0f, .z = 0.0f}, {.x = 0.0f, .y = -1.0f, .z = 0.0f}},
            {{.x = -1.0f, .y = 0.0f, .z = 0.0f}, {.x = 0.0f, .y = -1.0f, .z = 0.0f}},
            {{.x = 0.0f, .y = 1.0f, .z = 0.0f}, {.x = 0.0f, .y = 0.0f, .z = 1.0f}},
            {{.x = 0.0f, .y = -1.0f, .z = 0.0f}, {.x = 0.0f, .y = 0.0f, .z = -1.0f}},
            {{.x = 0.0f, .y = 0.0f, .z = 1.0f}, {.x = 0.0f, .y = -1.0f, .z = 0.0f}},
            {{.x = 0.0f, .y = 0.0f, .z = -1.0f}, {.x = 0.0f, .y = -1.0f, .z = 0.0f}},
        };
    }
    for i32 face = 0; face < 6; face++ {
        sg_begin_pass(&sg_pass{
            .action = app.offscreen_pass_action,
            .attachments = sg_attachments{
                .colors[0] = app.offscreen_color_views[face],
                .depth_stencil = app.offscreen_depth_view,
            },
        });
        mat44_t view = mat44_look_at_rh(vec3(0.0f, 0.0f, 0.0f), center_and_up[face][0], center_and_up[face][1]);
        mat44_t view_proj = mat44_mul_mat44(view, app.offscreen_proj);
        draw_cubes(app.offscreen_shapes_pip, vec3(0.0f, 0.0f, 0.0f), view_proj);
        sg_end_pass();
    }
    i32 w = sapp_width();
    i32 h = sapp_height();
    sg_begin_pass(&sg_pass{.action = app.display_pass_action, .swapchain = sglue_swapchain()});
    vec3_t eye_pos = vec3(0.0f, 0.0f, 20.0f);
    mat44_t proj = mat44_perspective_fov_rh(vecmath_radians(45.0f), cast(f32, w) / cast(f32, h), 0.01f, 100.0f);
    mat44_t view = mat44_look_at_rh(eye_pos, vec3(0.0f, 0.0f, 0.0f), vec3(0.0f, 1.0f, 0.0f));
    mat44_t view_proj = mat44_mul_mat44(view, proj);
    draw_cubes(app.display_shapes_pip, eye_pos, view_proj);
    app.rx += 0.1f * 60.0f * t;
    app.ry += 0.2f * 60.0f * t;
    mat44_t rxm = mat44_rotation_x(vecmath_radians(app.rx));
    mat44_t rym = mat44_rotation_y(vecmath_radians(app.ry));
    mat44_t model = mat44_mul_mat44(mat44_scaling(2.0f, 2.0f, 2.0f), mat44_mul_mat44(rym, rxm));
    sg_apply_pipeline(app.display_cube_pip);
    sg_apply_bindings(&sg_bindings{
        .vertex_buffers[0] = app.cube.vbuf,
        .index_buffer = app.cube.ibuf,
        .views[0] = app.cubemap_texview,
        .samplers[0] = app.smp,
    });
    var uniforms = shape_uniforms_t{
        .mvp = mat44_mul_mat44(model, view_proj),
        .model = model,
        .shape_color = vec4(1.0f, 1.0f, 1.0f, 1.0f),
        .light_dir = app.light_dir,
        .eye_pos = vec4v3f(eye_pos, 1.0f),
    };
    sg_apply_uniforms(UB_shape_uniforms, &sg_range{&uniforms, sizeof(uniforms)});
    sg_draw(0, app.cube.num_elements, 1);
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
        .window_title = "cubemaprt-sapp.mc",
        .icon = sapp_icon_desc{.sokol_default = true},
        .logger = sapp_logger{.func = slog_func},
    };
}

private {
void draw_cubes(sg_pipeline pip, vec3_t eye_pos, mat44_t view_proj) {
    sg_apply_pipeline(pip);
    sg_apply_bindings(&sg_bindings{
        .vertex_buffers[0] = app.cube.vbuf,
        .index_buffer = app.cube.ibuf,
    });
    for i32 i = 0; i < 32; i++ {
        shape_t* shape = &app.shapes[i];
        var uniforms = shape_uniforms_t{
            .mvp = mat44_mul_mat44(shape.model, view_proj),
            .model = shape.model,
            .shape_color = shape.color,
            .light_dir = app.light_dir,
            .eye_pos = vec4v3f(eye_pos, 1.0f),
        };
        sg_apply_uniforms(UB_shape_uniforms, &sg_range{&uniforms, sizeof(uniforms)});
        sg_draw(0, app.cube.num_elements, 1);
    }
}

mesh_t make_cube_mesh() {
    vertex_t[24] vertices = {
        vertex_t{{-1.0f, -1.0f, -1.0f}, {0.0f, 0.0f, -1.0f}},
        vertex_t{{1.0f, -1.0f, -1.0f}, {0.0f, 0.0f, -1.0f}},
        vertex_t{{1.0f, 1.0f, -1.0f}, {0.0f, 0.0f, -1.0f}},
        vertex_t{{-1.0f, 1.0f, -1.0f}, {0.0f, 0.0f, -1.0f}},
        vertex_t{{-1.0f, -1.0f, 1.0f}, {0.0f, 0.0f, 1.0f}},
        vertex_t{{1.0f, -1.0f, 1.0f}, {0.0f, 0.0f, 1.0f}},
        vertex_t{{1.0f, 1.0f, 1.0f}, {0.0f, 0.0f, 1.0f}},
        vertex_t{{-1.0f, 1.0f, 1.0f}, {0.0f, 0.0f, 1.0f}},
        vertex_t{{-1.0f, -1.0f, -1.0f}, {-1.0f, 0.0f, 0.0f}},
        vertex_t{{-1.0f, 1.0f, -1.0f}, {-1.0f, 0.0f, 0.0f}},
        vertex_t{{-1.0f, 1.0f, 1.0f}, {-1.0f, 0.0f, 0.0f}},
        vertex_t{{-1.0f, -1.0f, 1.0f}, {-1.0f, 0.0f, 0.0f}},
        vertex_t{{1.0f, -1.0f, -1.0f}, {1.0f, 0.0f, 0.0f}},
        vertex_t{{1.0f, 1.0f, -1.0f}, {1.0f, 0.0f, 0.0f}},
        vertex_t{{1.0f, 1.0f, 1.0f}, {1.0f, 0.0f, 0.0f}},
        vertex_t{{1.0f, -1.0f, 1.0f}, {1.0f, 0.0f, 0.0f}},
        vertex_t{{-1.0f, -1.0f, -1.0f}, {0.0f, -1.0f, 0.0f}},
        vertex_t{{-1.0f, -1.0f, 1.0f}, {0.0f, -1.0f, 0.0f}},
        vertex_t{{1.0f, -1.0f, 1.0f}, {0.0f, -1.0f, 0.0f}},
        vertex_t{{1.0f, -1.0f, -1.0f}, {0.0f, -1.0f, 0.0f}},
        vertex_t{{-1.0f, 1.0f, -1.0f}, {0.0f, 1.0f, 0.0f}},
        vertex_t{{-1.0f, 1.0f, 1.0f}, {0.0f, 1.0f, 0.0f}},
        vertex_t{{1.0f, 1.0f, 1.0f}, {0.0f, 1.0f, 0.0f}},
        vertex_t{{1.0f, 1.0f, -1.0f}, {0.0f, 1.0f, 0.0f}},
    };
    u16[36] indices = {
        0, 1, 2, 0, 2, 3, 6, 5, 4, 7, 6, 4, 8, 9, 10, 8, 10, 11, 14, 13, 12, 15, 14, 12, 16, 17, 18,
        16, 18, 19, 22, 21, 20, 23, 22, 20,
    };
    var mesh = mesh_t{
        .vbuf = sg_make_buffer(&sg_buffer_desc{
            .data = sg_range{&vertices, sizeof(vertices)},
            .label = "cube-vertices",
        }),
        .ibuf = sg_make_buffer(&sg_buffer_desc{
            .usage = sg_buffer_usage{.index_buffer = true},
            .data = sg_range{&indices, sizeof(indices)},
            .label = "cube-indices",
        }),
        .num_elements = cast(i32, sizeof(indices) / sizeof(u16)),
    };
    return mesh;
}
u32 xorshift32__x = 0x12345678;
}
