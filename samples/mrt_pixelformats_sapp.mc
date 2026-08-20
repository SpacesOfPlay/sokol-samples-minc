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

// mrt-pixelformats-sapp.glsl, hand-ported. An offscreen MRT pass
// writes depth, normal and colour into three render targets of
// different pixel formats, then a quad pass displays each one.
//
// The quad's texture pair is unfilterable: the targets include float
// formats that cannot be filtered on backends that would otherwise
// allow it.

struct Ub_offscreen_params {
    float4x4 mvp;
}

struct Ub_quad_params {
    f32 color_bias;
    f32 color_scale;
}

struct MrtPixelformatsSappOffscreenOut {
    float4 pos;
    float4 vs_proj;
    float4 vs_normal;
    float4 vs_color;
}

// three color attachments: one struct field per target, in order
struct MrtPixelformatsSappOffscreenFsOut {
    float4 frag_depth;
    float4 frag_normal;
    float4 frag_color;
}

struct MrtPixelformatsSappQuadOut {
    float4 pos;
    float2 uv;
}

@shader vertex
MrtPixelformatsSappOffscreenOut mrt_pixelformats_sapp_vs_offscreen(
    @attr(0) float4 in_pos,
    @attr(1) float3 in_normal,
    @attr(2) float4 in_color,
    @uniform(0) Ub_offscreen_params p
) {
    MrtPixelformatsSappOffscreenOut o;
    o.pos = mul(p.mvp, in_pos);
    o.vs_proj = o.pos;
    o.vs_normal = mul(p.mvp, float4{in_normal.x, in_normal.y, in_normal.z, 0.0f});
    o.vs_color = in_color;
    return o;
}

@shader fragment
MrtPixelformatsSappOffscreenFsOut mrt_pixelformats_sapp_fs_offscreen(
MrtPixelformatsSappOffscreenOut input
) {
    MrtPixelformatsSappOffscreenFsOut o;
    f32 z = input.vs_proj.z;
    o.frag_depth = float4{z, z, z, z};
    o.frag_normal = input.vs_normal;
    o.frag_color = input.vs_color;
    return o;
}

@shader vertex
MrtPixelformatsSappQuadOut mrt_pixelformats_sapp_vs_quad(@attr(0) float2 pos) {
    MrtPixelformatsSappQuadOut o;
    o.pos = float4{pos.x * 2.0f - 1.0f, pos.y * 2.0f - 1.0f, 0.5f, 1.0f};
    o.uv = pos;
    return o;
}

@shader fragment
float4 mrt_pixelformats_sapp_fs_quad(
MrtPixelformatsSappQuadOut input,
    @texture(0, unfilterable) Texture2D tex,
    @sampler(0, nonfiltering) Sampler smp,
    @uniform(0) Ub_quad_params p
) {
    float4 t = sample(tex, smp, input.uv);
    return float4{(t.x + p.color_bias) * p.color_scale,
                  (t.y + p.color_bias) * p.color_scale,
                  (t.z + p.color_bias) * p.color_scale,
                  1.0f};
}

enum __enum_UB_offscreen_params {
    UB_offscreen_params = 0,
    UB_quad_params = 0,
    VIEW_tex = 0,
    SMP_smp = 0,
    ATTR_offscreen_in_pos = 0,
    ATTR_offscreen_in_normal = 1,
    ATTR_offscreen_in_color = 2,
    ATTR_quad_pos = 0,
    __shim_end = 255,
}

type __arr_f32_4 = f32[4];
// Replaces the sokol-shdc generated mrt-pixelformats-sapp.glsl.h.
struct offscreen_params_t {
    mat44_t mvp;
}

/* tail-padded to 16: the declared block size rounds up and
   sg_apply_uniforms asserts the range matches exactly */
struct quad_params_t {
    f32 color_bias;
    f32 color_scale;
    f32[2] _pad_tail;
}

// render target pixel formats
// size of offscreen render targets
// a helper struct which bundles an image, a color attachment view and a texture view
struct image_and_views_t {
    sg_image img;
    sg_view att_view;
    sg_view tex_view;
}

private struct state_t {
    bool features_ok;
    struct {
        image_and_views_t depth;
        image_and_views_t normal;
        image_and_views_t color;
        sg_pass pass;
        sg_pipeline pip;
        sg_bindings bind;
        mat44_t view_proj;
        sshape_element_range_t donut;
    } offscreen;
    struct {
        sg_pass_action pass_action;
        sg_buffer vbuf;
        sg_sampler smp;
        sg_pipeline pip;
    } display;
    f32 rx;
    f32 ry;
}

private {
state_t state;

image_and_views_t make_image_and_views(sg_image_desc* img_desc, u8* att_label, u8* tex_label) {
    sg_image img = sg_make_image(img_desc);
    sg_view att_view = sg_make_view(&sg_view_desc{
        .color_attachment = sg_image_view_desc{.image = img},
        .label = att_label,
    });
    sg_view tex_view = sg_make_view(&sg_view_desc{
        .texture = sg_texture_view_desc{.image = img},
        .label = tex_label,
    });
    return image_and_views_t{.img = img, .att_view = att_view, .tex_view = tex_view};
}

void init() {
    sg_setup(&sg_desc{.environment = sglue_environment(), .logger = sg_logger{.func = slog_func}});
    __dbgui_setup();
    state.features_ok = sg_query_pixelformat(SG_PIXELFORMAT_R32F).render && sg_query_pixelformat(SG_PIXELFORMAT_RGBA16F).render && sg_query_pixelformat(SG_PIXELFORMAT_RGBA8).render;
    if state.features_ok == 0 {
        return;
    }
    {
        var img_desc = sg_image_desc{
            .usage = sg_image_usage{.color_attachment = true},
            .pixel_format = SG_PIXELFORMAT_R32F,
            .width = 512,
            .height = 512,
            .sample_count = 1,
            .label = "depth-image",
        };
        state.offscreen.depth = make_image_and_views(&img_desc, "depth-attachment", "depth-texture");
        img_desc.pixel_format = SG_PIXELFORMAT_RGBA16F;
        img_desc.label = "normal-image";
        state.offscreen.normal = make_image_and_views(&img_desc, "normal-attachment", "normal-texture");
        img_desc.pixel_format = SG_PIXELFORMAT_RGBA8;
        img_desc.label = "color-image";
        state.offscreen.color = make_image_and_views(&img_desc, "color-attachment", "color-texture");
        img_desc.usage = sg_image_usage{.depth_stencil_attachment = true};
        img_desc.pixel_format = SG_PIXELFORMAT_DEPTH;
        img_desc.label = "depth-buffer-image";
        sg_image zbuf_img = sg_make_image(&img_desc);
        sg_view zbuf_view = sg_make_view(&sg_view_desc{
            .depth_stencil_attachment = sg_image_view_desc{.image = zbuf_img},
            .label = "depth-buffer-attachment",
        });
        state.offscreen.pass = sg_pass{
            .action = sg_pass_action{
                .colors = {
                    sg_color_attachment_action{
                        .load_action = SG_LOADACTION_CLEAR,
                        .clear_value = {0.0f, 0.0f, 0.0f, 0.0f},
                    },
                    sg_color_attachment_action{
                        .load_action = SG_LOADACTION_CLEAR,
                        .clear_value = {0.0f, 0.0f, 0.0f, 0.0f},
                    },
                    sg_color_attachment_action{
                        .load_action = SG_LOADACTION_CLEAR,
                        .clear_value = {0.0f, 0.0f, 0.0f, 0.0f},
                    },
                    sg_color_attachment_action{},
                    sg_color_attachment_action{},
                    sg_color_attachment_action{},
                    sg_color_attachment_action{},
                    sg_color_attachment_action{},
                },
            },
            .attachments = sg_attachments{
                .colors[0] = state.offscreen.depth.att_view,
                .colors[1] = state.offscreen.normal.att_view,
                .colors[2] = state.offscreen.color.att_view,
                .depth_stencil = zbuf_view,
            },
        };
        u8[72000] vertices;
        u16[6000] indices;
        var shp = sshape_state_t{
            .disable = sshape_optional_components_t{.texcoords = true},
            .vertices = sshape_buffer_state_t{.buffer = sshape_range_t{&vertices, sizeof(vertices)}},
            .indices = sshape_buffer_state_t{.buffer = sshape_range_t{&indices, sizeof(indices)}},
        };
        sshape_build_torus(&shp, &sshape_torus_t{
            .radius = 0.5f,
            .ring_radius = 0.3f,
            .sides = 20,
            .rings = 36,
            .random_colors = true,
        });
        state.offscreen.donut = sshape_element_range(&shp);
        sg_buffer_desc vbuf_desc = sshape_vertex_buffer_desc(&shp);
        sg_buffer_desc ibuf_desc = sshape_index_buffer_desc(&shp);
        sg_buffer vbuf = sg_make_buffer(&vbuf_desc);
        sg_buffer ibuf = sg_make_buffer(&ibuf_desc);
        state.offscreen.pip = sg_make_pipeline(&sg_pipeline_desc{
            .shader = sokol_make_shader(&mrt_pixelformats_sapp_vs_offscreen_shader, &mrt_pixelformats_sapp_fs_offscreen_shader),
            .index_type = SG_INDEXTYPE_UINT16,
            .cull_mode = SG_CULLMODE_BACK,
            .layout = sg_vertex_layout_state{
                .buffers[0] = sshape_vertex_buffer_layout_state(&shp),
                .attrs = {
                    sshape_position_vertex_attr_state(&shp),
                    sshape_normal_vertex_attr_state(&shp),
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
                    sg_vertex_attr_state{},
                },
            },
            .depth = sg_depth_state{
                .pixel_format = SG_PIXELFORMAT_DEPTH,
                .write_enabled = true,
                .compare = SG_COMPAREFUNC_LESS_EQUAL,
            },
            .color_count = 3,
            .colors[0] = {.pixel_format = SG_PIXELFORMAT_R32F},
            .colors[1] = {.pixel_format = SG_PIXELFORMAT_RGBA16F},
            .colors[2] = {.pixel_format = SG_PIXELFORMAT_RGBA8},
        });
        state.offscreen.bind = sg_bindings{.vertex_buffers[0] = vbuf, .index_buffer = ibuf};
        mat44_t proj = mat44_perspective_fov_rh(vecmath_radians(60.0f), 1.0f, 0.01f, 5.0f);
        mat44_t view = mat44_look_at_rh(vec3(0.0f, 0.0f, 2.0f), vec3(0.0f, 0.0f, 0.0f), vec3(0.0f, 1.0f, 0.0f));
        state.offscreen.view_proj = mat44_mul_mat44(view, proj);
    }
    {
        state.display.pass_action = sg_pass_action{
            .colors[0] = {
                .load_action = SG_LOADACTION_CLEAR,
                .clear_value = {0.25f, 0.5f, 0.75f, 1.0f},
            },
        };
        f32[8] quad_vertices = {0.0f, 0.0f, 1.0f, 0.0f, 0.0f, 1.0f, 1.0f, 1.0f};
        state.display.vbuf = sg_make_buffer(&sg_buffer_desc{.data = sg_range{&quad_vertices, sizeof(quad_vertices)}});
        state.display.pip = sg_make_pipeline(&sg_pipeline_desc{
            .shader = sokol_make_shader(&mrt_pixelformats_sapp_vs_quad_shader, &mrt_pixelformats_sapp_fs_quad_shader),
            .primitive_type = SG_PRIMITIVETYPE_TRIANGLE_STRIP,
            .layout = sg_vertex_layout_state{.attrs[0] = {.format = SG_VERTEXFORMAT_FLOAT2}},
        });
        state.display.smp = sg_make_sampler(&sg_sampler_desc{
            .min_filter = SG_FILTER_NEAREST,
            .mag_filter = SG_FILTER_NEAREST,
            .wrap_u = SG_WRAP_CLAMP_TO_EDGE,
            .wrap_v = SG_WRAP_CLAMP_TO_EDGE,
        });
    }
}

void draw_fallback() {
    var pass_action = sg_pass_action{
        .colors[0] = {.load_action = SG_LOADACTION_CLEAR, .clear_value = {1.0f, 0.0f, 0.0f, 1.0f}},
    };
    sg_begin_pass(&sg_pass{.action = pass_action, .swapchain = sglue_swapchain()});
    __dbgui_draw();
    sg_end_pass();
    sg_commit();
}

offscreen_params_t compute_offscreen_params() {
    mat44_t rxm = mat44_rotation_x(vecmath_radians(state.rx));
    mat44_t rzm = mat44_rotation_z(vecmath_radians(state.ry));
    mat44_t model = mat44_mul_mat44(rzm, rxm);
    return offscreen_params_t{.mvp = mat44_mul_mat44(model, state.offscreen.view_proj)};
}

void frame() {
    if state.features_ok == 0 {
        draw_fallback();
        return;
    }
    var t = cast(f32, sapp_frame_duration() * 60.0);
    state.rx += 1.0f * t;
    state.ry += 2.0f * t;
    offscreen_params_t offscreen_params = compute_offscreen_params();
    sg_begin_pass(&state.offscreen.pass);
    sg_apply_pipeline(state.offscreen.pip);
    sg_apply_bindings(&state.offscreen.bind);
    sg_apply_uniforms(UB_offscreen_params, &sg_range{&offscreen_params, sizeof(offscreen_params)});
    sg_draw(state.offscreen.donut.base_element, state.offscreen.donut.num_elements, 1);
    sg_end_pass();
    i32 disp_width = sapp_width();
    i32 disp_height = sapp_height();
    i32 quad_width = disp_width / 4;
    i32 quad_height = quad_width;
    i32 quad_gap = (disp_width - quad_width * 3) / 4;
    i32 x0 = quad_gap;
    i32 y0 = (disp_height - quad_height) / 2;
    var bindings = sg_bindings{
        .vertex_buffers[0] = state.display.vbuf,
        .samplers[0] = state.display.smp,
    };
    sg_begin_pass(&sg_pass{.action = state.display.pass_action, .swapchain = sglue_swapchain()});
    sg_apply_pipeline(state.display.pip);
    var quad_params = quad_params_t{.color_bias = 0.0f, .color_scale = 1.0f};
    for i32 i = 0; i < 3; i++ {
        sg_apply_viewport(x0 + i * (quad_width + quad_gap), y0, quad_width, quad_height, true);
        switch i {
            case 0: {
                bindings.views[VIEW_tex] = state.offscreen.depth.tex_view;
                quad_params.color_bias = 0.0f;
                quad_params.color_scale = 0.5f;
            }
            case 1: {
                bindings.views[VIEW_tex] = state.offscreen.normal.tex_view;
                quad_params.color_bias = 1.0f;
                quad_params.color_scale = 0.5f;
            }
            case 2: {
                bindings.views[VIEW_tex] = state.offscreen.color.tex_view;
                quad_params.color_bias = 0.0f;
                quad_params.color_scale = 1.0f;
            }
        }
        sg_apply_uniforms(UB_quad_params, &sg_range{&quad_params, sizeof(quad_params)});
        sg_apply_bindings(&bindings);
        sg_draw(0, 4, 1);
    }
    sg_apply_viewport(0, 0, disp_width, disp_height, true);
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
        .window_title = "mrt-pixelformats-sapp.mc",
        .icon = sapp_icon_desc{.sokol_default = true},
        .logger = sapp_logger{.func = slog_func},
    };
}
