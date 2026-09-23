import sokol_shape;
import sokol_cmdbuf;
import vecmath;

import sokol_all;
import math;

// force high-dpi, sample entry point is __sapp_sample_main()
sapp_desc sokol_main() {
    sapp_desc d = __sapp_sample_main();
    d.high_dpi = true;
    return d;
}

// cmdbuf-sapp.glsl - ported to minc @shader

struct CmdbufSappVs_OffscreenOut {
    float4 pos;
    float4 nrm;
}

@shader vertex
CmdbufSappVs_OffscreenOut cmdbuf_sapp_vs_offscreen(
    @attr(0) float4 position,
    @attr(1) float4 normal,
    @uniform float4x4 mvp
) {
    CmdbufSappVs_OffscreenOut o;
    o.pos = mul(mvp, position);
    o.nrm = normal;
    return o;
}

@shader fragment
float4 cmdbuf_sapp_fs_offscreen(
CmdbufSappVs_OffscreenOut input
) {
    return float4{input.nrm.xyz * 0.5f + 0.5f, 1.0f};
}

struct CmdbufSappVs_DefaultOut {
    float4 pos;
    float4 nrm;
    float2 uv;
}

@shader vertex
CmdbufSappVs_DefaultOut cmdbuf_sapp_vs_default(
    @attr(0) float4 position,
    @attr(1) float4 normal,
    @attr(2) float2 texcoord0,
    @uniform float4x4 mvp
) {
    CmdbufSappVs_DefaultOut o;
    o.pos = mul(mvp, position);
    o.uv = texcoord0;
    o.nrm = mul(mvp, normal);
    return o;
}

@shader fragment
float4 cmdbuf_sapp_fs_default(
CmdbufSappVs_DefaultOut input,
    @texture(0) Texture2D tex,
    @sampler(0) Sampler smp
) {
    float4 c = sample(tex, smp, input.uv * float2{20.0f, 10.0f});
    f32 l = clamp(dot(input.nrm.xyz, normalize(float3{1.0f, 1.0f, -1.0f})), 0.0f, 1.0f) * 2.0f;
    return float4{c.xyz * (l + 0.25f), 1.0f};
}


enum __enum_ATTR_offscreen_position {
    ATTR_offscreen_position = 0,
    ATTR_offscreen_normal = 1,
    ATTR_default_position = 0,
    ATTR_default_normal = 1,
    ATTR_default_texcoord0 = 2,
    UB_vs_params = 0,
    VIEW_tex = 0,
    SMP_smp = 0,
    __shim_end = 255,
}

// Replaces the sokol-shdc generated cmdbuf-sapp.glsl.h.
struct vs_params_t {
    mat44_t mvp;
}

private struct state_t {
    struct {
        scb_cmdbuf cmdbuf;
        sg_pass pass;
        sg_pipeline pip;
        sg_bindings bind;
    } offscreen;
    struct {
        scb_cmdbuf cmdbuf;
        sg_pass_action pass_action;
        sg_pipeline pip;
        sg_bindings bind;
    } display;
    sshape_element_range_t cylinder;
    sshape_element_range_t sphere;
    f32 rx;
    f32 ry;
}

/*
    The typical debug UI overlay useful for most sokol-app samples
*/
private {
void __dbgui_setup() {
}

void __dbgui_shutdown() {
}

void __dbgui_draw() {
}

void __dbgui_event(sapp_event* e) {
    ignore e;
}

bool __dbgui_event_with_retval(sapp_event* e) {
    ignore e;
    return false;
}
state_t state;
}

private {
void init() {
    sg_setup(&sg_desc{.environment = sglue_environment(), .logger = sg_logger{.func = slog_func}});
    __dbgui_setup();
    scb_setup(&scb_desc{.cmdbuf_pool_size = 2, .logger = scb_logger{.func = slog_func}});
    state.offscreen.cmdbuf = scb_make_cmdbuf(&scb_cmdbuf_desc{.size = 512, .label = "offscreen-cmdbuf"});
    state.display.cmdbuf = scb_make_cmdbuf(&scb_cmdbuf_desc{.size = 512, .label = "display-cmdbuf"});
    setup_render_resources();
}

void frame() {
    var t = cast(f32, sapp_frame_duration() * 60.0);
    state.rx += 1.0f * t;
    state.ry += 2.0f * t;
    {
        scb_cmdbuf cb = state.offscreen.cmdbuf;
        var vs_params = vs_params_t{.mvp = compute_mvp(state.rx, state.ry, 1.0f, 2.5f)};
        scb_apply_pipeline(cb, state.offscreen.pip);
        scb_apply_bindings(cb, &state.offscreen.bind);
        scb_apply_uniforms(cb, UB_vs_params, &sg_range{&vs_params, sizeof(vs_params)});
        scb_draw(cb, state.cylinder.base_element, state.cylinder.num_elements, 1);
    }
    {
        scb_cmdbuf cb = state.display.cmdbuf;
        var vs_params = vs_params_t{.mvp = compute_mvp(-state.rx * 0.25f, state.ry * 0.25f, sapp_widthf() / sapp_heightf(), 1.5f)};
        scb_apply_pipeline(cb, state.display.pip);
        scb_apply_bindings(cb, &state.display.bind);
        scb_apply_uniforms(cb, UB_vs_params, &sg_range{&vs_params, sizeof(vs_params)});
        scb_draw(cb, state.sphere.base_element, state.sphere.num_elements, 1);
    }
    sg_begin_pass(&state.offscreen.pass);
    scb_submit(state.offscreen.cmdbuf);
    sg_end_pass();
    sg_begin_pass(&sg_pass{.action = state.display.pass_action, .swapchain = sglue_swapchain()});
    scb_submit(state.display.cmdbuf);
    __dbgui_draw();
    sg_end_pass();
    sg_commit();
}

void cleanup() {
    scb_shutdown();
    __dbgui_shutdown();
    sg_shutdown();
}

mat44_t compute_mvp(f32 rx, f32 ry, f32 aspect, f32 eye_dist) {
    mat44_t proj = mat44_perspective_fov_rh(vecmath_radians(45.0f), aspect, 0.01f, 10.0f);
    mat44_t view = mat44_look_at_rh(vec3(0.0f, 0.0f, eye_dist), vec3(0.0f, 0.0f, 0.0f), vec3(0.0f, 1.0f, 0.0f));
    mat44_t view_proj = mat44_mul_mat44(view, proj);
    mat44_t rxm = mat44_rotation_x(vecmath_radians(rx));
    mat44_t rym = mat44_rotation_y(vecmath_radians(ry));
    mat44_t model = mat44_mul_mat44(rxm, rym);
    mat44_t mvp = mat44_mul_mat44(model, view_proj);
    return mvp;
}

void setup_render_resources() {
    state.display.pass_action = sg_pass_action{
        .colors[0] = {
            .load_action = SG_LOADACTION_CLEAR,
            .clear_value = {0.45f, 0.25f, 0.55f, 1.0f},
        },
    };
    var img_desc = sg_image_desc{
        .usage = sg_image_usage{.color_attachment = true},
        .width = 256,
        .height = 256,
        .pixel_format = SG_PIXELFORMAT_RGBA8,
        .sample_count = 1,
        .label = "color-image",
    };
    sg_image color_img = sg_make_image(&img_desc);
    img_desc.pixel_format = SG_PIXELFORMAT_DEPTH;
    img_desc.usage = sg_image_usage{.depth_stencil_attachment = true};
    img_desc.label = "depth-image";
    sg_image depth_img = sg_make_image(&img_desc);
    state.offscreen.pass = sg_pass{
        .attachments = sg_attachments{
            .colors[0] = sg_make_view(&sg_view_desc{
                .color_attachment = sg_image_view_desc{.image = color_img},
                .label = "color-attachment",
            }),
            .depth_stencil = sg_make_view(&sg_view_desc{
                .depth_stencil_attachment = sg_image_view_desc{.image = depth_img},
                .label = "depth-attachment",
            }),
        },
        .action = sg_pass_action{
            .colors[0] = {
                .load_action = SG_LOADACTION_CLEAR,
                .clear_value = {0.25f, 0.25f, 0.35f, 1.0f},
            },
        },
        .label = "offscreen-pass",
    };
    u8[96000] vertices;
    u16[24000] indices;
    var shp = sshape_state_t{
        .disable = sshape_optional_components_t{.colors = true},
        .vertices = sshape_buffer_state_t{.buffer = sshape_range_t{&vertices, sizeof(vertices)}},
        .indices = sshape_buffer_state_t{.buffer = sshape_range_t{&indices, sizeof(indices)}},
    };
    sshape_build_cylinder(&shp, &sshape_cylinder_t{.height = 1.5f, .radius = 0.5f, .slices = 36});
    state.cylinder = sshape_element_range(&shp);
    sshape_build_sphere(&shp, &sshape_sphere_t{.radius = 0.5f, .slices = 72, .stacks = 40});
    state.sphere = sshape_element_range(&shp);
    sg_buffer_desc vbuf_desc = sshape_vertex_buffer_desc(&shp);
    sg_buffer_desc ibuf_desc = sshape_index_buffer_desc(&shp);
    vbuf_desc.label = "shape-vbuf";
    ibuf_desc.label = "shape-ibuf";
    sg_buffer vbuf = sg_make_buffer(&vbuf_desc);
    sg_buffer ibuf = sg_make_buffer(&ibuf_desc);
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
        .shader = sokol_make_shader(&cmdbuf_sapp_vs_offscreen_shader, &cmdbuf_sapp_fs_offscreen_shader),
        .index_type = SG_INDEXTYPE_UINT16,
        .cull_mode = SG_CULLMODE_BACK,
        .sample_count = 1,
        .depth = sg_depth_state{
            .pixel_format = SG_PIXELFORMAT_DEPTH,
            .compare = SG_COMPAREFUNC_LESS_EQUAL,
            .write_enabled = true,
        },
        .colors[0] = {.pixel_format = SG_PIXELFORMAT_RGBA8},
        .label = "offscreen-pipeline",
    });
    state.display.pip = sg_make_pipeline(&sg_pipeline_desc{
        .layout = sg_vertex_layout_state{
            .buffers[0] = sshape_vertex_buffer_layout_state(&shp),
            .attrs = {
                sshape_position_vertex_attr_state(&shp),
                sshape_normal_vertex_attr_state(&shp),
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
            },
        },
        .shader = sokol_make_shader(&cmdbuf_sapp_vs_default_shader, &cmdbuf_sapp_fs_default_shader),
        .index_type = SG_INDEXTYPE_UINT16,
        .cull_mode = SG_CULLMODE_BACK,
        .depth = sg_depth_state{.compare = SG_COMPAREFUNC_LESS_EQUAL, .write_enabled = true},
        .label = "default-pipeline",
    });
    sg_sampler smp = sg_make_sampler(&sg_sampler_desc{
        .min_filter = SG_FILTER_LINEAR,
        .mag_filter = SG_FILTER_LINEAR,
        .wrap_u = SG_WRAP_REPEAT,
        .wrap_v = SG_WRAP_REPEAT,
        .label = "sampler",
    });
    state.offscreen.bind = sg_bindings{.vertex_buffers[0] = vbuf, .index_buffer = ibuf};
    state.display.bind = sg_bindings{
        .vertex_buffers[0] = vbuf,
        .index_buffer = ibuf,
        .views[0] = sg_make_view(&sg_view_desc{
            .texture = sg_texture_view_desc{.image = color_img},
            .label = "texture-view",
        }),
        .samplers[0] = smp,
    };
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
        .window_title = "cmdbuf-sapp.mc",
        .icon = sapp_icon_desc{.sokol_default = true},
        .logger = sapp_logger{.func = slog_func},
    };
}
