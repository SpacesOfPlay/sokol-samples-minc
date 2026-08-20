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

// layerrender-sapp.glsl - ported to minc @shader.

struct LayerrenderSappVs_OffscreenOut {
    float4 pos;
    float3 nrm;
}

@shader vertex
LayerrenderSappVs_OffscreenOut layerrender_sapp_vs_offscreen(
    @attr(0) float4 in_pos,
    @attr(1) float3 in_nrm,
    @uniform float4x4 mvp
) {
    LayerrenderSappVs_OffscreenOut o;
    o.pos = mul(mvp, in_pos);
    o.nrm = in_nrm;
    return o;
}

@shader fragment
float4 layerrender_sapp_fs_offscreen(
LayerrenderSappVs_OffscreenOut input
) {
    return float4{input.nrm * 0.5f + 0.5f, 1.0f};
}

struct LayerrenderSappVs_DisplayOut {
    float4 pos;
    float2 uv;
}

@shader vertex
LayerrenderSappVs_DisplayOut layerrender_sapp_vs_display(
    @attr(0) float4 in_pos,
    @attr(1) float2 in_uv,
    @uniform float4x4 mvp
) {
    LayerrenderSappVs_DisplayOut o;
    o.pos = mul(mvp, in_pos);
    o.uv = in_uv;
    return o;
}

@shader fragment
float4 layerrender_sapp_fs_display(
LayerrenderSappVs_DisplayOut input,
    @texture(0) Texture2DArray tex,
    @sampler(0) Sampler smp
) {
    float3 c0 = sample(tex, smp, float3{input.uv, 0}).xyz;
    float3 c1 = sample(tex, smp, float3{input.uv, 1}).xyz;
    float3 c2 = sample(tex, smp, float3{input.uv, 2}).xyz;
    return float4{(c0 + c1 + c2) * 0.34f, 1.0f};
}


enum __enum_ATTR_offscreen_in_pos {
    ATTR_offscreen_in_pos = 0,
    ATTR_offscreen_in_nrm = 1,
    ATTR_display_in_pos = 0,
    ATTR_display_in_uv = 1,
    UB_vs_params = 0,
    VIEW_tex = 0,
    SMP_smp = 0,
    __shim_end = 255,
}

type __arr_f32_4 = f32[4];
// Replaces the sokol-shdc generated layerrender-sapp.glsl.h.
struct vs_params_t {
    mat44_t mvp;
}

private struct state_t {
    f32 rx;
    f32 ry;
    f64 time;
    sg_buffer vbuf;
    sg_buffer ibuf;
    sg_view tex_view;
    sg_sampler smp;
    struct {
        sg_pipeline pip;
        sg_pass_action pass_action;
        sg_bindings bindings;
        sg_view[3] color_att_views;
        sg_view depth_att_view;
        sshape_element_range_t[3] shapes;
    } offscreen;
    struct {
        sg_pipeline pip;
        sg_pass_action pass_action;
        sg_bindings bindings;
        sshape_element_range_t plane;
    } display;
}

private { state_t state; }

private {
void init() {
    sg_setup(&sg_desc{.environment = sglue_environment(), .logger = sg_logger{.func = slog_func}});
    __dbgui_setup();
    var shp = sshape_state_t{
        .disable = sshape_optional_components_t{.colors = true},
        .vertices = sshape_buffer_state_t{.buffer = sshape_range_t{&init__vertices, sizeof(init__vertices)}},
        .indices = sshape_buffer_state_t{.buffer = sshape_range_t{&init__indices, sizeof(init__indices)}},
    };
    sshape_build_box(&shp, &sshape_box_t{.width = 1.5f, .height = 1.5f, .depth = 1.5f});
    state.offscreen.shapes[0] = sshape_element_range(&shp);
    sshape_build_torus(&shp, &sshape_torus_t{
        .radius = 1.0f,
        .ring_radius = 0.3f,
        .rings = 36,
        .sides = 18,
    });
    state.offscreen.shapes[1] = sshape_element_range(&shp);
    sshape_build_cylinder(&shp, &sshape_cylinder_t{.radius = 1.0f, .height = 1.5f, .slices = 36, .stacks = 1});
    state.offscreen.shapes[2] = sshape_element_range(&shp);
    sshape_build_plane(&shp, &sshape_plane_t{.width = 2.0f, .depth = 2.0f});
    state.display.plane = sshape_element_range(&shp);
    sg_buffer_desc vbuf_desc = sshape_vertex_buffer_desc(&shp);
    vbuf_desc.label = "shape-vertices";
    sg_buffer_desc ibuf_desc = sshape_index_buffer_desc(&shp);
    ibuf_desc.label = "shape-indices";
    state.vbuf = sg_make_buffer(&vbuf_desc);
    state.ibuf = sg_make_buffer(&ibuf_desc);
    sg_image color_img = sg_make_image(&sg_image_desc{
        .usage = sg_image_usage{.color_attachment = true},
        .type = SG_IMAGETYPE_ARRAY,
        .width = 512,
        .height = 512,
        .num_slices = 3,
        .num_mipmaps = 1,
        .pixel_format = SG_PIXELFORMAT_RGBA8,
        .sample_count = 1,
        .label = "color-image",
    });
    sg_image depth_img = sg_make_image(&sg_image_desc{
        .usage = sg_image_usage{.depth_stencil_attachment = true},
        .width = 512,
        .height = 512,
        .num_mipmaps = 1,
        .pixel_format = SG_PIXELFORMAT_DEPTH,
        .sample_count = 1,
        .label = "depth-image",
    });
    state.smp = sg_make_sampler(&sg_sampler_desc{
        .min_filter = SG_FILTER_LINEAR,
        .mag_filter = SG_FILTER_LINEAR,
        .wrap_u = SG_WRAP_CLAMP_TO_EDGE,
        .wrap_v = SG_WRAP_CLAMP_TO_EDGE,
        .label = "sampler",
    });
    for i32 i = 0; i < 3; i++ {
        noinit u8[32] label;
        snprintf(label, sizeof(label), "color-attachment-slice-%d", i);
        state.offscreen.color_att_views[i] = sg_make_view(&sg_view_desc{
            .color_attachment = sg_image_view_desc{.image = color_img, .slice = i},
            .label = label,
        });
    }
    state.offscreen.depth_att_view = sg_make_view(&sg_view_desc{
        .depth_stencil_attachment = sg_image_view_desc{.image = depth_img},
        .label = "depth-attachemnt",
    });
    state.tex_view = sg_make_view(&sg_view_desc{
        .texture = sg_texture_view_desc{.image = color_img},
        .label = "texture-view",
    });
    state.offscreen.pip = sg_make_pipeline(&sg_pipeline_desc{
        .layout = sg_vertex_layout_state{
            .buffers[0] = sshape_vertex_buffer_layout_state(&shp),
            .attrs = {
                sshape_position_vertex_attr_state(&shp),
                sshape_normal_vertex_attr_state(&shp),
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
        .shader = sokol_make_shader(&layerrender_sapp_vs_offscreen_shader, &layerrender_sapp_fs_offscreen_shader),
        .index_type = SG_INDEXTYPE_UINT16,
        .cull_mode = SG_CULLMODE_BACK,
        .sample_count = 1,
        .depth = sg_depth_state{
            .write_enabled = true,
            .compare = SG_COMPAREFUNC_LESS_EQUAL,
            .pixel_format = SG_PIXELFORMAT_DEPTH,
        },
        .colors[0] = {.pixel_format = SG_PIXELFORMAT_RGBA8},
        .label = "offscreen-pipeline",
    });
    state.display.pip = sg_make_pipeline(&sg_pipeline_desc{
        .layout = sg_vertex_layout_state{
            .buffers[0] = sshape_vertex_buffer_layout_state(&shp),
            .attrs = {
                sshape_position_vertex_attr_state(&shp),
                sshape_texcoord_vertex_attr_state(&shp),
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
        .shader = sokol_make_shader(&layerrender_sapp_vs_display_shader, &layerrender_sapp_fs_display_shader),
        .index_type = SG_INDEXTYPE_UINT16,
        .cull_mode = SG_CULLMODE_BACK,
        .sample_count = 1,
        .depth = sg_depth_state{.write_enabled = true, .compare = SG_COMPAREFUNC_LESS_EQUAL},
        .label = "display-pipeline",
    });
    state.offscreen.bindings = sg_bindings{
        .vertex_buffers[0] = state.vbuf,
        .index_buffer = state.ibuf,
    };
    state.display.bindings = sg_bindings{
        .vertex_buffers[0] = state.vbuf,
        .index_buffer = state.ibuf,
        .views[0] = state.tex_view,
        .samplers[0] = state.smp,
    };
    state.offscreen.pass_action = sg_pass_action{
        .colors[0] = {.load_action = SG_LOADACTION_CLEAR, .clear_value = {0.5f, 0.5f, 0.5f, 1.0f}},
    };
    state.display.pass_action = sg_pass_action{
        .colors[0] = {.load_action = SG_LOADACTION_CLEAR, .clear_value = {0.0f, 0.0f, 0.0f, 1.0f}},
    };
}

void frame() {
    f64 dt = sapp_frame_duration();
    state.time += dt;
    state.rx += cast(f32, dt * 20.0f);
    state.ry += cast(f32, dt * 40.0f);
    vs_params_t display_vsparams = compute_display_vsparams();
    for i32 i = 0; i < 3; i++ {
        sg_begin_pass(&sg_pass{
            .action = state.offscreen.pass_action,
            .attachments = sg_attachments{
                .colors[0] = state.offscreen.color_att_views[i],
                .depth_stencil = state.offscreen.depth_att_view,
            },
        });
        sg_apply_pipeline(state.offscreen.pip);
        sg_apply_bindings(&state.offscreen.bindings);
        f32 rx = state.rx;
        f32 ry = state.ry;
        switch i {
            case 0: {
            }
            case 1: {
                rx = -rx;
            }
            default: {
                ry = -ry;
            }
        }
        vs_params_t offscreen_vsparams = compute_offscreen_vsparams(rx, ry);
        sg_apply_uniforms(UB_vs_params, &sg_range{&offscreen_vsparams, sizeof(offscreen_vsparams)});
        sshape_element_range_t shape = state.offscreen.shapes[i];
        sg_draw(shape.base_element, shape.num_elements, 1);
        sg_end_pass();
    }
    sg_begin_pass(&sg_pass{.action = state.display.pass_action, .swapchain = sglue_swapchain()});
    sg_apply_pipeline(state.display.pip);
    sg_apply_bindings(&state.display.bindings);
    sg_apply_uniforms(UB_vs_params, &sg_range{&display_vsparams, sizeof(display_vsparams)});
    sg_draw(state.display.plane.base_element, state.display.plane.num_elements, 1);
    __dbgui_draw();
    sg_end_pass();
    sg_commit();
}

void cleanup() {
    __dbgui_shutdown();
    sg_shutdown();
}

// compute a model-view-projection matrix for offscreen rendering (aspect ratio 1:1)
vs_params_t compute_offscreen_vsparams(f32 rx, f32 ry) {
    mat44_t proj = mat44_perspective_fov_rh(vecmath_radians(60.0f), 1.0f, 0.01f, 10.0f);
    mat44_t view = mat44_look_at_rh(vec3(0.0f, 0.0f, 3.0f), vec3(0.0f, 0.0f, 0.0f), vec3(0.0f, 1.0f, 0.0f));
    mat44_t view_proj = mat44_mul_mat44(view, proj);
    mat44_t rxm = mat44_rotation_x(vecmath_radians(rx));
    mat44_t rym = mat44_rotation_z(vecmath_radians(ry));
    mat44_t model = mat44_mul_mat44(rym, rxm);
    return vs_params_t{.mvp = mat44_mul_mat44(model, view_proj)};
}

// compute a model-view-projection matrix with display aspect ratio
vs_params_t compute_display_vsparams() {
    f32 w = sapp_widthf();
    f32 h = sapp_heightf();
    mat44_t proj = mat44_perspective_fov_rh(vecmath_radians(40.0f), w / h, 0.01f, 10.0f);
    mat44_t view = mat44_look_at_rh(vec3(0.0f, 0.0f, 4.0f), vec3(0.0f, 0.0f, 0.0f), vec3(0.0f, 1.0f, 0.0f));
    mat44_t view_proj = mat44_mul_mat44(view, proj);
    mat44_t model = mat44_rotation_x(vecmath_radians(90.0f));
    return vs_params_t{.mvp = mat44_mul_mat44(model, view_proj)};
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
        .sample_count = 1,
        .window_title = "layerrender-sapp.mc",
        .icon = sapp_icon_desc{.sokol_default = true},
        .logger = sapp_logger{.func = slog_func},
    };
}
private {
u8[98304] init__vertices;
u16[12288] init__indices;
}
