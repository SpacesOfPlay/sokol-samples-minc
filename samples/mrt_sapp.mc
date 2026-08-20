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

// mrt-sapp.glsl - ported to minc @shader.

struct MrtSappVs_OffscreenOut {
    float4 pos;
    f32 bright;
}

@shader vertex
MrtSappVs_OffscreenOut mrt_sapp_vs_offscreen(
    @attr(0) float4 pos,
    @attr(1) f32 bright0,
    @uniform float4x4 mvp
) {
    MrtSappVs_OffscreenOut o;
    o.pos = mul(mvp, pos);
    o.bright = bright0;
    return o;
}

// Three color attachments: one struct field per target, in order.
struct MrtSappFs_OffscreenOut {
    float4 frag_color_0;
    float4 frag_color_1;
    float4 frag_color_2;
}

@shader fragment
MrtSappFs_OffscreenOut mrt_sapp_fs_offscreen(
MrtSappVs_OffscreenOut input
) {
    MrtSappFs_OffscreenOut o;
    o.frag_color_0 = float4{input.bright, 0.0f, 0.0f, 1.0f};
    o.frag_color_1 = float4{0.0f, input.bright, 0.0f, 1.0f};
    o.frag_color_2 = float4{0.0f, 0.0f, input.bright, 1.0f};
    return o;
}

struct MrtSappVs_FsqOut {
    float4 pos;
    float2 uv0;
    float2 uv1;
    float2 uv2;
}

@shader vertex
MrtSappVs_FsqOut mrt_sapp_vs_fsq(
    @attr(0) float2 pos,
    @uniform float2 offset
) {
    MrtSappVs_FsqOut o;
    o.pos = float4{pos*2.0f-1.0f, 0.5f, 1.0f};
    o.uv0 = pos + float2{offset.x, 0.0f};
    o.uv1 = pos + float2{0.0f, offset.y};
    o.uv2 = pos;
    return o;
}

@shader fragment
float4 mrt_sapp_fs_fsq(
MrtSappVs_FsqOut input,
    @texture(0) Texture2D tex0,
    @texture(1) Texture2D tex1,
    @texture(2) Texture2D tex2,
    @sampler(0) Sampler smp
) {
    float3 c0 = sample(tex0, smp, input.uv0).xyz;
    float3 c1 = sample(tex1, smp, input.uv1).xyz;
    float3 c2 = sample(tex2, smp, input.uv2).xyz;
    return float4{c0 + c1 + c2, 1.0f};
}

struct MrtSappVs_DbgOut {
    float4 pos;
    float2 uv;
}

@shader vertex
MrtSappVs_DbgOut mrt_sapp_vs_dbg(
    @attr(0) float2 pos
) {
    MrtSappVs_DbgOut o;
    o.pos = float4{pos*2.0f-1.0f, 0.5f, 1.0f};
    o.uv = pos;
    return o;
}

@shader fragment
float4 mrt_sapp_fs_dbg(
MrtSappVs_DbgOut input,
    @texture(0) Texture2D tex,
    @sampler(0) Sampler smp
) {
    return float4{sample(tex, smp,input.uv).xyz, 1.0f};
}


enum __enum_ATTR_offscreen_pos {
    ATTR_offscreen_pos = 0,
    ATTR_offscreen_bright0 = 1,
    ATTR_fsq_pos = 0,
    ATTR_dbg_pos = 0,
    UB_offscreen_params = 0,
    UB_fsq_params = 0,
    VIEW_tex0 = 0,
    VIEW_tex1 = 1,
    VIEW_tex2 = 2,
    SMP_smp = 0,
    VIEW_tex = 0,
    SMP_smp = 0,
    __shim_end = 255,
}

// Replaces the sokol-shdc generated mrt-sapp.glsl.h.
struct offscreen_params_t {
    mat44_t mvp;
}

struct fsq_params_t {
    vec2_t offset;
    u8[8] _pad_tail;
}

private struct state_t {
    struct {
        sg_pipeline pip;
        sg_bindings bind;
        sg_pass pass;
    } offscreen;
    struct {
        sg_pipeline pip;
        sg_bindings bind;
        sg_pass_action pass_action;
    } display;
    struct {
        sg_pipeline pip;
        sg_bindings bind;
    } dbg;
    struct {
        sg_image[3] color;
        sg_image[3] resolve;
        sg_image depth;
    } images;
    f32 rx;
    f32 ry;
}

struct vertex_t {
    f32 x;
    f32 y;
    f32 z;
    f32 b;
}

private { state_t state; }

private {
void init() {
    sg_setup(&sg_desc{.environment = sglue_environment(), .logger = sg_logger{.func = slog_func}});
    __dbgui_setup();
    state.display.pass_action = sg_pass_action{
        .colors[0] = {.load_action = SG_LOADACTION_DONTCARE},
        .depth = sg_depth_attachment_action{.load_action = SG_LOADACTION_DONTCARE},
        .stencil = sg_stencil_attachment_action{.load_action = SG_LOADACTION_DONTCARE},
    };
    for i32 i = 0; i < 3; i++ {
        state.images.color[i] = sg_alloc_image();
        state.images.resolve[i] = sg_alloc_image();
        state.offscreen.pass.attachments.colors[i] = sg_alloc_view();
        state.offscreen.pass.attachments.resolves[i] = sg_alloc_view();
        state.display.bind.views[VIEW_tex0 + i] = sg_alloc_view();
    }
    state.images.depth = sg_alloc_image();
    state.offscreen.pass.attachments.depth_stencil = sg_alloc_view();
    reinit_attachments(sapp_width(), sapp_height());
    vertex_t[24] cube_vertices = {
        vertex_t{-1.0f, -1.0f, -1.0f, 1.0f},
        vertex_t{1.0f, -1.0f, -1.0f, 1.0f},
        vertex_t{1.0f, 1.0f, -1.0f, 1.0f},
        vertex_t{-1.0f, 1.0f, -1.0f, 1.0f},
        vertex_t{-1.0f, -1.0f, 1.0f, 0.8f},
        vertex_t{1.0f, -1.0f, 1.0f, 0.8f},
        vertex_t{1.0f, 1.0f, 1.0f, 0.8f},
        vertex_t{-1.0f, 1.0f, 1.0f, 0.8f},
        vertex_t{-1.0f, -1.0f, -1.0f, 0.6f},
        vertex_t{-1.0f, 1.0f, -1.0f, 0.6f},
        vertex_t{-1.0f, 1.0f, 1.0f, 0.6f},
        vertex_t{-1.0f, -1.0f, 1.0f, 0.6f},
        vertex_t{1.0f, -1.0f, -1.0f, 0.4f},
        vertex_t{1.0f, 1.0f, -1.0f, 0.4f},
        vertex_t{1.0f, 1.0f, 1.0f, 0.4f},
        vertex_t{1.0f, -1.0f, 1.0f, 0.4f},
        vertex_t{-1.0f, -1.0f, -1.0f, 0.5f},
        vertex_t{-1.0f, -1.0f, 1.0f, 0.5f},
        vertex_t{1.0f, -1.0f, 1.0f, 0.5f},
        vertex_t{1.0f, -1.0f, -1.0f, 0.5f},
        vertex_t{-1.0f, 1.0f, -1.0f, 0.7f},
        vertex_t{-1.0f, 1.0f, 1.0f, 0.7f},
        vertex_t{1.0f, 1.0f, 1.0f, 0.7f},
        vertex_t{1.0f, 1.0f, -1.0f, 0.7f},
    };
    state.offscreen.bind.vertex_buffers[0] = sg_make_buffer(&sg_buffer_desc{
        .data = sg_range{&cube_vertices, sizeof(cube_vertices)},
        .label = "cube vertices",
    });
    u16[36] cube_indices = {
        0, 1, 2, 0, 2, 3, 6, 5, 4, 7, 6, 4, 8, 9, 10, 8, 10, 11, 14, 13, 12, 15, 14, 12, 16, 17, 18,
        16, 18, 19, 22, 21, 20, 23, 22, 20,
    };
    state.offscreen.bind.index_buffer = sg_make_buffer(&sg_buffer_desc{
        .usage = sg_buffer_usage{.index_buffer = true},
        .data = sg_range{&cube_indices, sizeof(cube_indices)},
        .label = "cube indices",
    });
    state.offscreen.pip = sg_make_pipeline(&sg_pipeline_desc{
        .shader = sokol_make_shader(&mrt_sapp_vs_offscreen_shader, &mrt_sapp_fs_offscreen_shader),
        .layout = sg_vertex_layout_state{
            .buffers[0] = {.stride = cast(i32, sizeof(vertex_t))},
            .attrs = {
                sg_vertex_attr_state{
                    .offset = cast(u32, &cast(vertex_t*, 0).x),
                    .format = SG_VERTEXFORMAT_FLOAT3,
                },
                sg_vertex_attr_state{
                    .offset = cast(u32, &cast(vertex_t*, 0).b),
                    .format = SG_VERTEXFORMAT_FLOAT,
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
        .depth = sg_depth_state{
            .pixel_format = SG_PIXELFORMAT_DEPTH,
            .compare = SG_COMPAREFUNC_LESS_EQUAL,
            .write_enabled = true,
        },
        .color_count = 3,
        .label = "offscreen pipeline",
    });
    state.offscreen.pass.action = sg_pass_action{
        .colors = {
            sg_color_attachment_action{
                .load_action = SG_LOADACTION_CLEAR,
                .store_action = SG_STOREACTION_DONTCARE,
                .clear_value = {0.25f, 0.0f, 0.0f, 1.0f},
            },
            sg_color_attachment_action{
                .load_action = SG_LOADACTION_CLEAR,
                .store_action = SG_STOREACTION_DONTCARE,
                .clear_value = {0.0f, 0.25f, 0.0f, 1.0f},
            },
            sg_color_attachment_action{
                .load_action = SG_LOADACTION_CLEAR,
                .store_action = SG_STOREACTION_DONTCARE,
                .clear_value = {0.0f, 0.0f, 0.25f, 1.0f},
            },
            sg_color_attachment_action{},
            sg_color_attachment_action{},
            sg_color_attachment_action{},
            sg_color_attachment_action{},
            sg_color_attachment_action{},
        },
    };
    f32[8] quad_vertices = {0.0f, 0.0f, 1.0f, 0.0f, 0.0f, 1.0f, 1.0f, 1.0f};
    sg_buffer quad_vbuf = sg_make_buffer(&sg_buffer_desc{
        .data = sg_range{&quad_vertices, sizeof(quad_vertices)},
        .label = "quad vertices",
    });
    state.display.pip = sg_make_pipeline(&sg_pipeline_desc{
        .shader = sokol_make_shader(&mrt_sapp_vs_fsq_shader, &mrt_sapp_fs_fsq_shader),
        .layout = sg_vertex_layout_state{.attrs[0] = {.format = SG_VERTEXFORMAT_FLOAT2}},
        .primitive_type = SG_PRIMITIVETYPE_TRIANGLE_STRIP,
        .label = "fullscreen quad pipeline",
    });
    sg_sampler smp = sg_make_sampler(&sg_sampler_desc{
        .min_filter = SG_FILTER_LINEAR,
        .mag_filter = SG_FILTER_LINEAR,
        .wrap_u = SG_WRAP_CLAMP_TO_EDGE,
        .wrap_v = SG_WRAP_CLAMP_TO_EDGE,
        .label = "sampler",
    });
    state.display.bind.vertex_buffers[0] = quad_vbuf;
    state.display.bind.samplers[SMP_smp] = smp;
    state.dbg.pip = sg_make_pipeline(&sg_pipeline_desc{
        .shader = sokol_make_shader(&mrt_sapp_vs_dbg_shader, &mrt_sapp_fs_dbg_shader),
        .layout = sg_vertex_layout_state{.attrs[0] = {.format = SG_VERTEXFORMAT_FLOAT2}},
        .primitive_type = SG_PRIMITIVETYPE_TRIANGLE_STRIP,
        .label = "dbgvis quad pipeline",
    });
    state.dbg.bind = sg_bindings{.vertex_buffers[0] = quad_vbuf, .samplers[0] = smp};
}

void frame() {
    mat44_t proj = mat44_perspective_fov_rh(vecmath_radians(60.0f), sapp_widthf() / sapp_heightf(), 0.01f, 10.0f);
    mat44_t view = mat44_look_at_rh(vec3(0.0f, 1.5f, 4.0f), vec3(0.0f, 0.0f, 0.0f), vec3(0.0f, 1.0f, 0.0f));
    mat44_t view_proj = mat44_mul_mat44(view, proj);
    var t = cast(f32, sapp_frame_duration() * 60.0);
    state.rx += 1.0f * t;
    state.ry += 2.0f * t;
    mat44_t rxm = mat44_rotation_x(vecmath_radians(state.rx));
    mat44_t rym = mat44_rotation_y(vecmath_radians(state.ry));
    mat44_t model = mat44_mul_mat44(rym, rxm);
    var offscreen_params = offscreen_params_t{.mvp = mat44_mul_mat44(model, view_proj)};
    var fsq_params = fsq_params_t{.offset = vec2(vecmath_sin(state.rx * 0.01f) * 0.1f, vecmath_sin(state.ry * 0.01f) * 0.1f)};
    sg_begin_pass(&state.offscreen.pass);
    sg_apply_pipeline(state.offscreen.pip);
    sg_apply_bindings(&state.offscreen.bind);
    sg_apply_uniforms(UB_offscreen_params, &sg_range{&offscreen_params, sizeof(offscreen_params)});
    sg_draw(0, 36, 1);
    sg_end_pass();
    sg_begin_pass(&sg_pass{.action = state.display.pass_action, .swapchain = sglue_swapchain()});
    sg_apply_pipeline(state.display.pip);
    sg_apply_bindings(&state.display.bind);
    sg_apply_uniforms(UB_fsq_params, &sg_range{&fsq_params, sizeof(fsq_params)});
    sg_draw(0, 4, 1);
    sg_apply_pipeline(state.dbg.pip);
    for i32 i = 0; i < 3; i++ {
        sg_apply_viewport(i * 100, 0, 100, 100, false);
        state.dbg.bind.views[VIEW_tex] = state.display.bind.views[VIEW_tex0 + i];
        sg_apply_bindings(&state.dbg.bind);
        sg_draw(0, 4, 1);
    }
    sg_apply_viewport(0, 0, sapp_width(), sapp_height(), false);
    __dbgui_draw();
    sg_end_pass();
    sg_commit();
}

void cleanup() {
    __dbgui_shutdown();
    sg_shutdown();
}

// listen for window-resize events and recreate offscreen rendertargets
void event(sapp_event* e) {
    if e.type == SAPP_EVENTTYPE_RESIZED {
        reinit_attachments(e.framebuffer_width, e.framebuffer_height);
    }
    __dbgui_event(e);
}

// called initially and when window size changes, will re-initialize
// the offscreen render target images to a new size and then re-initialize
// the associated view objects
void reinit_attachments(i32 width, i32 height) {
    for i32 i = 0; i < 3; i++ {
        sg_uninit_image(state.images.color[i]);
        sg_uninit_image(state.images.resolve[i]);
        sg_uninit_view(state.offscreen.pass.attachments.colors[i]);
        sg_uninit_view(state.offscreen.pass.attachments.resolves[i]);
        sg_uninit_view(state.display.bind.views[VIEW_tex + i]);
    }
    sg_uninit_image(state.images.depth);
    sg_uninit_view(state.offscreen.pass.attachments.depth_stencil);
    u8*[3] msaa_image_labels = {"msaa-image-red", "msaa-image-green", "msaa-image-blue"};
    u8*[3] resolve_image_labels = {"resolve-image-red", "resolve-image-green", "resolve-image-blue"};
    u8*[3] color_attachment_labels = {
        "color-attachment-red", "color-attachment-green", "color-attachment-blue",
    };
    u8*[3] resolve_attachment_labels = {
        "resolve-attachment-red", "resolve-attachment-green", "resolve-attachment-blue",
    };
    u8*[3] tex_view_labels = {"texture-view-red", "texture-view-green", "texture-view-blue"};
    for i32 i = 0; i < 3; i++ {
        sg_init_image(state.images.color[i], &sg_image_desc{
            .usage = sg_image_usage{.color_attachment = true},
            .width = width,
            .height = height,
            .sample_count = 4,
            .label = msaa_image_labels[i],
        });
        sg_init_image(state.images.resolve[i], &sg_image_desc{
            .usage = sg_image_usage{.resolve_attachment = true},
            .width = width,
            .height = height,
            .sample_count = 1,
            .label = resolve_image_labels[i],
        });
        sg_init_view(state.offscreen.pass.attachments.colors[i], &sg_view_desc{
            .color_attachment = sg_image_view_desc{.image = state.images.color[i]},
            .label = color_attachment_labels[i],
        });
        sg_init_view(state.offscreen.pass.attachments.resolves[i], &sg_view_desc{
            .resolve_attachment = sg_image_view_desc{.image = state.images.resolve[i]},
            .label = resolve_attachment_labels[i],
        });
        sg_init_view(state.display.bind.views[VIEW_tex0 + i], &sg_view_desc{
            .texture = sg_texture_view_desc{.image = state.images.resolve[i]},
            .label = tex_view_labels[i],
        });
    }
    sg_init_image(state.images.depth, &sg_image_desc{
        .usage = sg_image_usage{.depth_stencil_attachment = true},
        .width = width,
        .height = height,
        .pixel_format = SG_PIXELFORMAT_DEPTH,
        .sample_count = 4,
        .label = "depth-image",
    });
    sg_init_view(state.offscreen.pass.attachments.depth_stencil, &sg_view_desc{
        .depth_stencil_attachment = sg_image_view_desc{.image = state.images.depth},
        .label = "depth-attachment",
    });
}
}

sapp_desc __sapp_sample_main() {
    return sapp_desc{
        .init_cb = init,
        .frame_cb = frame,
        .cleanup_cb = cleanup,
        .event_cb = event,
        .width = 800,
        .height = 600,
        .sample_count = 4,
        .window_title = "mrt-sapp.mc",
        .icon = sapp_icon_desc{.sokol_default = true},
        .logger = sapp_logger{.func = slog_func},
    };
}
