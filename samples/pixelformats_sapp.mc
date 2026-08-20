import dbgui;
import imgui_compat;
import vecmath;

// sapp samples that use Dear ImGui
import sokol_all;
import imgui;
import sokol_imgui;
import math;

// upstream samples leave high_dpi off and blur on scaled displays.
// Forced enabled here.
sapp_desc sokol_main() {
    sapp_desc d = __sapp_sample_main();
    d.high_dpi = true;
    return d;
}

// pixelformats-sapp.glsl, hand-ported. A vertex-coloured cube drawn
// into every renderable pixel format, over an animated checker
// background computed from the fragment coordinate.

struct Ub_cube_vs_params {
    float4x4 mvp;
}

struct Ub_bg_fs_params {
    f32 tick;
}

struct PixelformatsSappCubeOut {
    float4 pos;
    float4 color;
}

struct PixelformatsSappBgOut {
    float4 pos;
}

@shader vertex
PixelformatsSappCubeOut pixelformats_sapp_vs_cube(
    @attr(0) float4 pos,
    @attr(1) float4 color0,
    @uniform(0) Ub_cube_vs_params p
) {
    PixelformatsSappCubeOut o;
    o.pos = mul(p.mvp, pos);
    o.color = color0;
    return o;
}

@shader fragment
float4 pixelformats_sapp_fs_cube(PixelformatsSappCubeOut input) {
    return input.color;
}

@shader vertex
PixelformatsSappBgOut pixelformats_sapp_vs_bg(@attr(0) float2 position) {
    PixelformatsSappBgOut o;
    o.pos = float4{position.x, position.y, 0.5f, 1.0f};
    return o;
}

@shader fragment
float4 pixelformats_sapp_fs_bg(
    PixelformatsSappBgOut input,
    @uniform(0) Ub_bg_fs_params p
) {
    float2 fc = frag_coord().xy;
    float2 xy = fract(float2{(fc.x - p.tick) / 10.0f, (fc.y - p.tick) / 10.0f});
    f32 v = xy.x * xy.y;
    return float4{v, v, v, 1.0f};
}

enum __enum_ATTR_cube_pos {
    ATTR_cube_pos = 0,
    ATTR_cube_color0 = 1,
    ATTR_bg_position = 0,
    UB_cube_vs_params = 0,
    UB_bg_fs_params = 0,
    __shim_end = 255,
}

type __arr_u32_8 = u32[8];
// Replaces the sokol-shdc generated pixelformats-sapp.glsl.h.
struct cube_vs_params_t {
    mat44_t mvp;
}

struct bg_fs_params_t {
    f32 tick;
    u8[12] _pad_tail;
}

struct image_and_views_t {
    sg_image img;
    sg_view tex_view;
    sg_view att_view;
}

struct __anon_pixelformats_sapp_struct_2 {
    bool valid;
    image_and_views_t unfiltered;
    image_and_views_t filtered;
    image_and_views_t render;
    image_and_views_t blend;
    image_and_views_t msaa_render;
    image_and_views_t msaa_resolve;
    sg_pipeline cube_render_pip;
    sg_pipeline cube_blend_pip;
    sg_pipeline cube_msaa_pip;
    sg_pipeline bg_render_pip;
    sg_pipeline bg_msaa_pip;
}

private struct state_t {
    __anon_pixelformats_sapp_struct_2[69] fmt;
    sg_view depth_att_view;
    sg_view msaa_depth_att_view;
    sg_sampler smp_linear;
    sg_bindings cube_bindings;
    sg_bindings bg_bindings;
    f32 rx;
    f32 ry;
    cube_vs_params_t cube_vs_params;
    bg_fs_params_t bg_fs_params;
}

private { state_t state; }

// helper function to construct ImTextureRef from ImTextureID
// FIXME: remove when Dear Bindings offers such helper
private {
ImTextureRef imtexref(ImTextureID tex_id) {
    return ImTextureRef{._TexID = tex_id};
}
// a 'disabled' texture pattern with a cross
__arr_u32_8[8] disabled_texture_pixels = {
    {0xFF0000FF, 0xFFCCCCCC, 0xFFCCCCCC, 0xFFCCCCCC, 0xFFCCCCCC, 0xFFCCCCCC, 0xFFCCCCCC, 0xFF0000FF},
    {0xFFCCCCCC, 0xFF0000FF, 0xFFCCCCCC, 0xFFCCCCCC, 0xFFCCCCCC, 0xFFCCCCCC, 0xFF0000FF, 0xFFCCCCCC},
    {0xFFCCCCCC, 0xFFCCCCCC, 0xFF0000FF, 0xFFCCCCCC, 0xFFCCCCCC, 0xFF0000FF, 0xFFCCCCCC, 0xFFCCCCCC},
    {0xFFCCCCCC, 0xFFCCCCCC, 0xFFCCCCCC, 0xFF0000FF, 0xFF0000FF, 0xFFCCCCCC, 0xFFCCCCCC, 0xFFCCCCCC},
    {0xFFCCCCCC, 0xFFCCCCCC, 0xFFCCCCCC, 0xFF0000FF, 0xFF0000FF, 0xFFCCCCCC, 0xFFCCCCCC, 0xFFCCCCCC},
    {0xFFCCCCCC, 0xFFCCCCCC, 0xFF0000FF, 0xFFCCCCCC, 0xFFCCCCCC, 0xFF0000FF, 0xFFCCCCCC, 0xFFCCCCCC},
    {0xFFCCCCCC, 0xFF0000FF, 0xFFCCCCCC, 0xFFCCCCCC, 0xFFCCCCCC, 0xFFCCCCCC, 0xFF0000FF, 0xFFCCCCCC},
    {0xFF0000FF, 0xFFCCCCCC, 0xFFCCCCCC, 0xFFCCCCCC, 0xFFCCCCCC, 0xFFCCCCCC, 0xFFCCCCCC, 0xFF0000FF},
};

void init() {
    sg_setup(&sg_desc{
        .pipeline_pool_size = 256,
        .image_pool_size = 256,
        .view_pool_size = 512,
        .environment = sglue_environment(),
        .logger = sg_logger{.func = slog_func},
    });
    simgui_setup(&simgui_desc_t{.logger = simgui_logger_t{.func = slog_func}});
    state.depth_att_view = sg_make_view(&sg_view_desc{
        .depth_stencil_attachment = sg_image_view_desc{
            .image = sg_make_image(&sg_image_desc{
                .usage = sg_image_usage{.depth_stencil_attachment = true},
                .width = 64,
                .height = 64,
                .pixel_format = SG_PIXELFORMAT_DEPTH,
                .sample_count = 1,
            }),
        },
    });
    state.msaa_depth_att_view = sg_make_view(&sg_view_desc{
        .depth_stencil_attachment = sg_image_view_desc{
            .image = sg_make_image(&sg_image_desc{
                .usage = sg_image_usage{.depth_stencil_attachment = true},
                .width = 64,
                .height = 64,
                .pixel_format = SG_PIXELFORMAT_DEPTH,
                .sample_count = 4,
            }),
        },
    });
    image_and_views_t invalid_img = make_image_and_views(&sg_image_desc{
        .width = 8,
        .height = 8,
        .data = sg_image_data{.mip_levels[0] = sg_range{&disabled_texture_pixels, sizeof(disabled_texture_pixels)}},
    }, true, SG_VIEWTYPE_INVALID);
    for i32 i = 0; i < _SG_PIXELFORMAT_NUM; i++ {
        state.fmt[i].unfiltered = invalid_img;
        state.fmt[i].filtered = invalid_img;
        state.fmt[i].render = invalid_img;
        state.fmt[i].blend = invalid_img;
        state.fmt[i].msaa_resolve = invalid_img;
    }
    state.smp_linear = sg_make_sampler(&sg_sampler_desc{
        .min_filter = SG_FILTER_LINEAR,
        .mag_filter = SG_FILTER_LINEAR,
    });
    var cube_render_pip_desc = sg_pipeline_desc{
        .layout = sg_vertex_layout_state{
            .attrs[0] = {.format = SG_VERTEXFORMAT_FLOAT3},
            .attrs[1] = {.format = SG_VERTEXFORMAT_FLOAT4},
        },
        .shader = sokol_make_shader(&pixelformats_sapp_vs_cube_shader, &pixelformats_sapp_fs_cube_shader),
        .index_type = SG_INDEXTYPE_UINT16,
        .cull_mode = SG_CULLMODE_BACK,
        .sample_count = 1,
        .depth = sg_depth_state{
            .write_enabled = true,
            .pixel_format = SG_PIXELFORMAT_DEPTH,
            .compare = SG_COMPAREFUNC_LESS_EQUAL,
        },
    };
    var bg_render_pip_desc = sg_pipeline_desc{
        .layout = sg_vertex_layout_state{.attrs[0] = {.format = SG_VERTEXFORMAT_FLOAT2}},
        .shader = sokol_make_shader(&pixelformats_sapp_vs_bg_shader, &pixelformats_sapp_fs_bg_shader),
        .primitive_type = SG_PRIMITIVETYPE_TRIANGLE_STRIP,
        .sample_count = 1,
        .depth = sg_depth_state{.pixel_format = SG_PIXELFORMAT_DEPTH},
    };
    sg_pipeline_desc cube_blend_pip_desc = cube_render_pip_desc;
    cube_blend_pip_desc.colors[0].blend = sg_blend_state{
        .enabled = true,
        .src_factor_rgb = SG_BLENDFACTOR_ONE,
        .dst_factor_rgb = SG_BLENDFACTOR_ONE,
    };
    sg_pipeline_desc cube_msaa_pip_desc = cube_render_pip_desc;
    sg_pipeline_desc bg_msaa_pip_desc = bg_render_pip_desc;
    cube_msaa_pip_desc.sample_count = 4;
    bg_msaa_pip_desc.sample_count = 4;
    for i32 i = SG_PIXELFORMAT_NONE + 1; i < SG_PIXELFORMAT_DEPTH; i++ {
        var fmt = cast(sg_pixel_format, i);
        sg_range img_data = gen_pixels(fmt);
        if img_data.ptr != null {
            state.fmt[i].valid = true;
            sg_pixelformat_info fmt_info = sg_query_pixelformat(fmt);
            if fmt_info.sample != 0 {
                image_and_views_t img = make_image_and_views(&sg_image_desc{
                    .width = 8,
                    .height = 8,
                    .pixel_format = fmt,
                    .data = sg_image_data{.mip_levels[0] = img_data},
                }, true, SG_VIEWTYPE_INVALID);
                state.fmt[i].unfiltered = img;
                if fmt_info.filter != 0 {
                    state.fmt[i].filtered = img;
                }
            }
            if fmt_info.render != 0 {
                state.fmt[i].render = make_image_and_views(&sg_image_desc{
                    .usage = sg_image_usage{.color_attachment = true},
                    .width = 64,
                    .height = 64,
                    .pixel_format = fmt,
                    .sample_count = 1,
                }, true, SG_VIEWTYPE_COLORATTACHMENT);
                cube_render_pip_desc.colors[0].pixel_format = fmt;
                bg_render_pip_desc.colors[0].pixel_format = fmt;
                state.fmt[i].cube_render_pip = sg_make_pipeline(&cube_render_pip_desc);
                state.fmt[i].bg_render_pip = sg_make_pipeline(&bg_render_pip_desc);
            }
            if fmt_info.blend != 0 {
                state.fmt[i].blend = make_image_and_views(&sg_image_desc{
                    .usage = sg_image_usage{.color_attachment = true},
                    .width = 64,
                    .height = 64,
                    .pixel_format = fmt,
                    .sample_count = 1,
                }, true, SG_VIEWTYPE_COLORATTACHMENT);
                cube_blend_pip_desc.colors[0].pixel_format = fmt;
                state.fmt[i].cube_blend_pip = sg_make_pipeline(&cube_blend_pip_desc);
            }
            if fmt_info.msaa != 0 {
                state.fmt[i].msaa_render = make_image_and_views(&sg_image_desc{
                    .usage = sg_image_usage{.color_attachment = true},
                    .width = 64,
                    .height = 64,
                    .pixel_format = fmt,
                    .sample_count = 4,
                }, false, SG_VIEWTYPE_COLORATTACHMENT);
                state.fmt[i].msaa_resolve = make_image_and_views(&sg_image_desc{
                    .usage = sg_image_usage{.resolve_attachment = true},
                    .width = 64,
                    .height = 64,
                    .pixel_format = fmt,
                    .sample_count = 1,
                }, true, SG_VIEWTYPE_RESOLVEATTACHMENT);
                cube_msaa_pip_desc.colors[0].pixel_format = fmt;
                bg_msaa_pip_desc.colors[0].pixel_format = fmt;
                state.fmt[i].cube_msaa_pip = sg_make_pipeline(&cube_msaa_pip_desc);
                state.fmt[i].bg_msaa_pip = sg_make_pipeline(&bg_msaa_pip_desc);
            }
        }
    }
    f32[168] cube_vertices = {
        -1.0f, -1.0f, -1.0f, 0.7f, 0.3f, 0.3f, 1.0f, 1.0f, -1.0f, -1.0f, 0.7f, 0.3f, 0.3f, 1.0f,
        1.0f, 1.0f, -1.0f, 0.7f, 0.3f, 0.3f, 1.0f, -1.0f, 1.0f, -1.0f, 0.7f, 0.3f, 0.3f, 1.0f,
        -1.0f, -1.0f, 1.0f, 0.3f, 0.7f, 0.3f, 1.0f, 1.0f, -1.0f, 1.0f, 0.3f, 0.7f, 0.3f, 1.0f, 1.0f,
        1.0f, 1.0f, 0.3f, 0.7f, 0.3f, 1.0f, -1.0f, 1.0f, 1.0f, 0.3f, 0.7f, 0.3f, 1.0f, -1.0f, -1.0f,
        -1.0f, 0.3f, 0.3f, 0.7f, 1.0f, -1.0f, 1.0f, -1.0f, 0.3f, 0.3f, 0.7f, 1.0f, -1.0f, 1.0f,
        1.0f, 0.3f, 0.3f, 0.7f, 1.0f, -1.0f, -1.0f, 1.0f, 0.3f, 0.3f, 0.7f, 1.0f, 1.0f, -1.0f,
        -1.0f, 0.7f, 0.5f, 0.3f, 1.0f, 1.0f, 1.0f, -1.0f, 0.7f, 0.5f, 0.3f, 1.0f, 1.0f, 1.0f, 1.0f,
        0.7f, 0.5f, 0.3f, 1.0f, 1.0f, -1.0f, 1.0f, 0.7f, 0.5f, 0.3f, 1.0f, -1.0f, -1.0f, -1.0f,
        0.3f, 0.5f, 0.7f, 1.0f, -1.0f, -1.0f, 1.0f, 0.3f, 0.5f, 0.7f, 1.0f, 1.0f, -1.0f, 1.0f, 0.3f,
        0.5f, 0.7f, 1.0f, 1.0f, -1.0f, -1.0f, 0.3f, 0.5f, 0.7f, 1.0f, -1.0f, 1.0f, -1.0f, 0.7f,
        0.3f, 0.5f, 1.0f, -1.0f, 1.0f, 1.0f, 0.7f, 0.3f, 0.5f, 1.0f, 1.0f, 1.0f, 1.0f, 0.7f, 0.3f,
        0.5f, 1.0f, 1.0f, 1.0f, -1.0f, 0.7f, 0.3f, 0.5f, 1.0f,
    };
    state.cube_bindings.vertex_buffers[0] = sg_make_buffer(&sg_buffer_desc{.data = sg_range{&cube_vertices, sizeof(cube_vertices)}});
    u16[36] cube_indices = {
        0, 1, 2, 0, 2, 3, 6, 5, 4, 7, 6, 4, 8, 9, 10, 8, 10, 11, 14, 13, 12, 15, 14, 12, 16, 17, 18,
        16, 18, 19, 22, 21, 20, 23, 22, 20,
    };
    state.cube_bindings.index_buffer = sg_make_buffer(&sg_buffer_desc{
        .usage = sg_buffer_usage{.index_buffer = true},
        .data = sg_range{&cube_indices, sizeof(cube_indices)},
    });
    f32[8] vertices = {-1.0f, -1.0f, 1.0f, -1.0f, -1.0f, 1.0f, 1.0f, 1.0f};
    state.bg_bindings.vertex_buffers[0] = sg_make_buffer(&sg_buffer_desc{.data = sg_range{&vertices, sizeof(vertices)}});
}

void frame() {
    i32 w = sapp_width();
    i32 h = sapp_height();
    var t = cast(f32, sapp_frame_duration() * 60.0);
    mat44_t proj = mat44_perspective_fov_rh(vecmath_radians(60.0f), 1.0f, 0.01f, 10.0f);
    mat44_t view = mat44_look_at_rh(vec3(0.0f, 1.5f, 6.0f), vec3(0.0f, 0.0f, 0.0f), vec3(0.0f, 1.0f, 0.0f));
    mat44_t view_proj = mat44_mul_mat44(view, proj);
    state.rx += 1.0f * t;
    state.ry += 2.0f * t;
    mat44_t rxm = mat44_rotation_x(vecmath_radians(state.rx));
    mat44_t rym = mat44_rotation_y(vecmath_radians(state.ry));
    mat44_t model = mat44_mul_mat44(rym, rxm);
    state.cube_vs_params.mvp = mat44_mul_mat44(model, view_proj);
    state.bg_fs_params.tick += 1.0f * t;
    for i32 i = SG_PIXELFORMAT_NONE + 1; i < SG_PIXELFORMAT_DEPTH; i++ {
        if state.fmt[i].valid == 0 {
            continue;
        }
        var fmt = cast(sg_pixel_format, i);
        sg_pixelformat_info fmt_info = sg_query_pixelformat(fmt);
        if fmt_info.render != 0 {
            sg_begin_pass(&sg_pass{
                .attachments = sg_attachments{
                    .colors[0] = state.fmt[i].render.att_view,
                    .depth_stencil = state.depth_att_view,
                },
            });
            sg_apply_pipeline(state.fmt[i].bg_render_pip);
            sg_apply_bindings(&state.bg_bindings);
            sg_apply_uniforms(UB_bg_fs_params, &sg_range{&state.bg_fs_params, sizeof(state.bg_fs_params)});
            sg_draw(0, 4, 1);
            sg_apply_pipeline(state.fmt[i].cube_render_pip);
            sg_apply_bindings(&state.cube_bindings);
            sg_apply_uniforms(UB_cube_vs_params, &sg_range{&state.cube_vs_params, sizeof(state.cube_vs_params)});
            sg_draw(0, 36, 1);
            sg_end_pass();
        }
        if fmt_info.blend != 0 {
            sg_begin_pass(&sg_pass{
                .attachments = sg_attachments{
                    .colors[0] = state.fmt[i].blend.att_view,
                    .depth_stencil = state.depth_att_view,
                },
            });
            sg_apply_pipeline(state.fmt[i].bg_render_pip);
            sg_apply_bindings(&state.bg_bindings);
            sg_apply_uniforms(UB_bg_fs_params, &sg_range{&state.bg_fs_params, sizeof(state.bg_fs_params)});
            sg_draw(0, 4, 1);
            sg_apply_pipeline(state.fmt[i].cube_blend_pip);
            sg_apply_bindings(&state.cube_bindings);
            sg_apply_uniforms(UB_cube_vs_params, &sg_range{&state.cube_vs_params, sizeof(state.cube_vs_params)});
            sg_draw(0, 36, 1);
            sg_end_pass();
        }
        if fmt_info.msaa != 0 {
            sg_begin_pass(&sg_pass{
                .attachments = sg_attachments{
                    .colors[0] = state.fmt[i].msaa_render.att_view,
                    .resolves[0] = state.fmt[i].msaa_resolve.att_view,
                    .depth_stencil = state.msaa_depth_att_view,
                },
                .action = sg_pass_action{.colors[0] = {.store_action = SG_STOREACTION_DONTCARE}},
            });
            sg_apply_pipeline(state.fmt[i].bg_msaa_pip);
            sg_apply_bindings(&state.bg_bindings);
            sg_apply_uniforms(UB_bg_fs_params, &sg_range{&state.bg_fs_params, sizeof(state.bg_fs_params)});
            sg_draw(0, 4, 1);
            sg_apply_pipeline(state.fmt[i].cube_msaa_pip);
            sg_apply_bindings(&state.cube_bindings);
            sg_apply_uniforms(UB_cube_vs_params, &sg_range{&state.cube_vs_params, sizeof(state.cube_vs_params)});
            sg_draw(0, 36, 1);
            sg_end_pass();
        }
    }
    simgui_new_frame(&simgui_frame_desc_t{
        .width = w,
        .height = h,
        .delta_time = sapp_frame_duration(),
        .dpi_scale = sapp_dpi_scale(),
    });
    ImGui_SetNextWindowSize(ImVec2{640.0f, 480.0f}, ImGuiCond_Once);
    if ImGui_Begin("Pixel Formats (without UINT and SINT formats)", null, 0) != 0 {
        ImGui_Text("format");
        ImGui_SameLine(264.0f, 0.0f);
        ImGui_Text("sample");
        ImGui_SameLine(cast(f32, 264 + 1 * 66), 0.0f);
        ImGui_Text("filter");
        ImGui_SameLine(cast(f32, 264 + 2 * 66), 0.0f);
        ImGui_Text("render");
        ImGui_SameLine(cast(f32, 264 + 3 * 66), 0.0f);
        ImGui_Text("blend");
        ImGui_SameLine(cast(f32, 264 + 4 * 66), 0.0f);
        ImGui_Text("msaa");
        ImGui_Separator();
        ImGui_BeginChild("#scrollregion", ImVec2{0.0f, 0.0f}, false, ImGuiWindowFlags_None);
        for i32 i = SG_PIXELFORMAT_NONE + 1; i < SG_PIXELFORMAT_DEPTH; i++ {
            if state.fmt[i].valid == 0 {
                continue;
            }
            u8* fmt_string = pixelformat_string(cast(sg_pixel_format, i));
            if ImGui_BeginChild(fmt_string, ImVec2{0.0f, 80.0f}, ImGuiChildFlags_None, ImGuiWindowFlags_NoMouseInputs | ImGuiWindowFlags_NoScrollbar) != 0 {
                ImGui_Text("%s", fmt_string);
                ImGui_SameLine(256.0f, 0.0f);
                ImGui_Image(imtexref(simgui_imtextureid(state.fmt[i].unfiltered.tex_view)), ImVec2{64.0f, 64.0f});
                ImGui_SameLine();
                ImGui_Image(imtexref(simgui_imtextureid_with_sampler(state.fmt[i].filtered.tex_view, state.smp_linear)), ImVec2{64.0f, 64.0f});
                ImGui_SameLine();
                ImGui_Image(imtexref(simgui_imtextureid(state.fmt[i].render.tex_view)), ImVec2{64.0f, 64.0f});
                ImGui_SameLine();
                ImGui_Image(imtexref(simgui_imtextureid(state.fmt[i].blend.tex_view)), ImVec2{64.0f, 64.0f});
                ImGui_SameLine();
                ImGui_Image(imtexref(simgui_imtextureid(state.fmt[i].msaa_resolve.tex_view)), ImVec2{64.0f, 64.0f});
            }
            ImGui_EndChild();
        }
        ImGui_EndChild();
    }
    ImGui_End();
    sg_begin_pass(&sg_pass{
        .action = sg_pass_action{
            .colors[0] = {
                .load_action = SG_LOADACTION_CLEAR,
                .clear_value = {0.0f, 0.5f, 0.7f, 1.0f},
            },
        },
        .swapchain = sglue_swapchain(),
    });
    simgui_render();
    sg_end_pass();
    sg_commit();
}

void input(sapp_event* e) {
    simgui_handle_event(e);
}

void cleanup() {
    simgui_shutdown();
    sg_shutdown();
}
}

sapp_desc __sapp_sample_main() {
    return sapp_desc{
        .init_cb = init,
        .frame_cb = frame,
        .event_cb = input,
        .cleanup_cb = cleanup,
        .width = 800,
        .height = 600,
        .icon = sapp_icon_desc{.sokol_default = true},
        .window_title = "pixelformats-sapp.mc",
        .logger = sapp_logger{.func = slog_func},
    };
}

// create image object and associated views
private {
image_and_views_t make_image_and_views(sg_image_desc* img_desc, bool has_tex_view, sg_view_type att_view_type) {
    var res = image_and_views_t{.img = sg_make_image(img_desc)};
    if has_tex_view != 0 {
        res.tex_view = sg_make_view(&sg_view_desc{.texture = sg_texture_view_desc{.image = res.img}});
    }
    if att_view_type == SG_VIEWTYPE_COLORATTACHMENT {
        res.att_view = sg_make_view(&sg_view_desc{.color_attachment = sg_image_view_desc{.image = res.img}});
    } else if att_view_type == SG_VIEWTYPE_RESOLVEATTACHMENT {
        res.att_view = sg_make_view(&sg_view_desc{.resolve_attachment = sg_image_view_desc{.image = res.img}});
    }
    return res;
}
// generate checkerboard pixel values
u8[1024] pixels;

void gen_pixels_8(u8 val) {
    u8* ptr = pixels;
    for i32 y = 0; y < 8; y++ {
        for i32 x = 0; x < 8; x++ {
            *ptr++ = ((x ^ y) & 1) != 0 ? val : 0;
        }
    }
}

void gen_pixels_16(u16 val) {
    var ptr = cast(u16*, pixels);
    for i32 y = 0; y < 8; y++ {
        for i32 x = 0; x < 8; x++ {
            *ptr++ = ((x ^ y) & 1) != 0 ? val : 0;
        }
    }
}

void gen_pixels_32(u32 val) {
    var ptr = cast(u32*, pixels);
    for i32 y = 0; y < 8; y++ {
        for i32 x = 0; x < 8; x++ {
            *ptr++ = ((x ^ y) & 1) != 0 ? val : 0;
        }
    }
}

void gen_pixels_64(u64 val) {
    var ptr = cast(u64*, pixels);
    for i32 y = 0; y < 8; y++ {
        for i32 x = 0; x < 8; x++ {
            *ptr++ = ((x ^ y) & 1) != 0 ? val : 0;
        }
    }
}

void gen_pixels_128(u64 hi, u64 lo) {
    var ptr = cast(u64*, pixels);
    for i32 y = 0; y < 8; y++ {
        for i32 x = 0; x < 8; x++ {
            *ptr++ = ((x ^ y) & 1) != 0 ? lo : 0;
            *ptr++ = ((x ^ y) & 1) != 0 ? hi : 0;
        }
    }
}

sg_range gen_pixels(sg_pixel_format fmt) {
    switch fmt {
        case SG_PIXELFORMAT_R8: {
            gen_pixels_8(0xFF);
            return sg_range{pixels, 8 * 8};
        }
        case SG_PIXELFORMAT_R8SN: {
            gen_pixels_8(0x7F);
            return sg_range{pixels, 8 * 8};
        }
        case SG_PIXELFORMAT_R16: {
            gen_pixels_16(0xFFFF);
            return sg_range{pixels, 8 * 8 * 2};
        }
        case SG_PIXELFORMAT_R16SN: {
            gen_pixels_16(0x7FFF);
            return sg_range{pixels, 8 * 8 * 2};
        }
        case SG_PIXELFORMAT_R16F: {
            gen_pixels_16(0x3C00);
            return sg_range{pixels, 8 * 8 * 2};
        }
        case SG_PIXELFORMAT_RG8: {
            gen_pixels_16(0xFFFF);
            return sg_range{pixels, 8 * 8 * 2};
        }
        case SG_PIXELFORMAT_RG8SN: {
            gen_pixels_16(0x7F7F);
            return sg_range{pixels, 8 * 8 * 2};
        }
        case SG_PIXELFORMAT_R32F: {
            gen_pixels_32(0x3F800000);
            return sg_range{pixels, 8 * 8 * 4};
        }
        case SG_PIXELFORMAT_RG16: {
            gen_pixels_32(0xFFFFFFFF);
            return sg_range{pixels, 8 * 8 * 4};
        }
        case SG_PIXELFORMAT_RG16SN: {
            gen_pixels_32(0x7FFF7FFF);
            return sg_range{pixels, 8 * 8 * 4};
        }
        case SG_PIXELFORMAT_RG16F: {
            gen_pixels_32(0x3C003C00);
            return sg_range{pixels, 8 * 8 * 4};
        }
        case SG_PIXELFORMAT_RGBA8: {
            gen_pixels_32(0xFFFFFFFF);
            return sg_range{pixels, 8 * 8 * 4};
        }
        case SG_PIXELFORMAT_SRGB8A8: {
            gen_pixels_32(0xFFFFFFFF);
            return sg_range{pixels, 8 * 8 * 4};
        }
        case SG_PIXELFORMAT_RGBA8SN: {
            gen_pixels_32(0x7F7F7F7F);
            return sg_range{pixels, 8 * 8 * 4};
        }
        case SG_PIXELFORMAT_BGRA8: {
            gen_pixels_32(0xFFFFFFFF);
            return sg_range{pixels, 8 * 8 * 4};
        }
        case SG_PIXELFORMAT_SBGR8A8: {
            gen_pixels_32(0xFFFFFFFF);
            return sg_range{pixels, 8 * 8 * 4};
        }
        case SG_PIXELFORMAT_RGB10A2: {
            gen_pixels_32(cast(u32, 0x3 << 30 | 0x3FF << 20 | 0x3FF << 10 | 0x3FF));
            return sg_range{pixels, 8 * 8 * 4};
        }
        case SG_PIXELFORMAT_RG11B10F: {
            gen_pixels_32(cast(u32, 0x1E0 << 22 | 0x3C0 << 11 | 0x3C0));
            return sg_range{pixels, 8 * 8 * 4};
        }
        case SG_PIXELFORMAT_RG32F: {
            gen_pixels_64(0x3F8000003F800000);
            return sg_range{pixels, 8 * 8 * 8};
        }
        case SG_PIXELFORMAT_RGBA16: {
            gen_pixels_64(0xFFFFFFFFFFFFFFFF);
            return sg_range{pixels, 8 * 8 * 8};
        }
        case SG_PIXELFORMAT_RGBA16SN: {
            gen_pixels_64(0x7FFF7FFF7FFF7FFF);
            return sg_range{pixels, 8 * 8 * 8};
        }
        case SG_PIXELFORMAT_RGBA16F: {
            gen_pixels_64(0x3C003C003C003C00);
            return sg_range{pixels, 8 * 8 * 8};
        }
        case SG_PIXELFORMAT_RGBA32F: {
            gen_pixels_128(0x3F8000003F800000, 0x3F8000003F800000);
            return sg_range{pixels, 8 * 8 * 16};
        }
        default: {
            return sg_range{};
        }
    }
}

/* translate pixel format enum to string */
u8* pixelformat_string(sg_pixel_format fmt) {
    switch fmt {
        case SG_PIXELFORMAT_NONE: {
            return "SG_PIXELFORMAT_NONE";
        }
        case SG_PIXELFORMAT_R8: {
            return "SG_PIXELFORMAT_R8";
        }
        case SG_PIXELFORMAT_R8SN: {
            return "SG_PIXELFORMAT_R8SN";
        }
        case SG_PIXELFORMAT_R8UI: {
            return "SG_PIXELFORMAT_R8UI";
        }
        case SG_PIXELFORMAT_R8SI: {
            return "SG_PIXELFORMAT_R8SI";
        }
        case SG_PIXELFORMAT_R16: {
            return "SG_PIXELFORMAT_R16";
        }
        case SG_PIXELFORMAT_R16SN: {
            return "SG_PIXELFORMAT_R16SN";
        }
        case SG_PIXELFORMAT_R16UI: {
            return "SG_PIXELFORMAT_R16UI";
        }
        case SG_PIXELFORMAT_R16SI: {
            return "SG_PIXELFORMAT_R16SI";
        }
        case SG_PIXELFORMAT_R16F: {
            return "SG_PIXELFORMAT_R16F";
        }
        case SG_PIXELFORMAT_RG8: {
            return "SG_PIXELFORMAT_RG8";
        }
        case SG_PIXELFORMAT_RG8SN: {
            return "SG_PIXELFORMAT_RG8SN";
        }
        case SG_PIXELFORMAT_RG8UI: {
            return "SG_PIXELFORMAT_RG8UI";
        }
        case SG_PIXELFORMAT_RG8SI: {
            return "SG_PIXELFORMAT_RG8SI";
        }
        case SG_PIXELFORMAT_R32UI: {
            return "SG_PIXELFORMAT_R32UI";
        }
        case SG_PIXELFORMAT_R32SI: {
            return "SG_PIXELFORMAT_R32SI";
        }
        case SG_PIXELFORMAT_R32F: {
            return "SG_PIXELFORMAT_R32F";
        }
        case SG_PIXELFORMAT_RG16: {
            return "SG_PIXELFORMAT_RG16";
        }
        case SG_PIXELFORMAT_RG16SN: {
            return "SG_PIXELFORMAT_RG16SN";
        }
        case SG_PIXELFORMAT_RG16UI: {
            return "SG_PIXELFORMAT_RG16UI";
        }
        case SG_PIXELFORMAT_RG16SI: {
            return "SG_PIXELFORMAT_RG16SI";
        }
        case SG_PIXELFORMAT_RG16F: {
            return "SG_PIXELFORMAT_RG16F";
        }
        case SG_PIXELFORMAT_RGBA8: {
            return "SG_PIXELFORMAT_RGBA8";
        }
        case SG_PIXELFORMAT_SRGB8A8: {
            return "SG_PIXELFORMAT_SRGB8A8";
        }
        case SG_PIXELFORMAT_RGBA8SN: {
            return "SG_PIXELFORMAT_RGBA8SN";
        }
        case SG_PIXELFORMAT_RGBA8UI: {
            return "SG_PIXELFORMAT_RGBA8UI";
        }
        case SG_PIXELFORMAT_RGBA8SI: {
            return "SG_PIXELFORMAT_RGBA8SI";
        }
        case SG_PIXELFORMAT_BGRA8: {
            return "SG_PIXELFORMAT_BGRA8";
        }
        case SG_PIXELFORMAT_SBGR8A8: {
            return "SG_PIXELFORMAT_SBGRA8";
        }
        case SG_PIXELFORMAT_RGB10A2: {
            return "SG_PIXELFORMAT_RGB10A2";
        }
        case SG_PIXELFORMAT_RG11B10F: {
            return "SG_PIXELFORMAT_RG11B10F";
        }
        case SG_PIXELFORMAT_RG32UI: {
            return "SG_PIXELFORMAT_RG32UI";
        }
        case SG_PIXELFORMAT_RG32SI: {
            return "SG_PIXELFORMAT_RG32SI";
        }
        case SG_PIXELFORMAT_RG32F: {
            return "SG_PIXELFORMAT_RG32F";
        }
        case SG_PIXELFORMAT_RGBA16: {
            return "SG_PIXELFORMAT_RGBA16";
        }
        case SG_PIXELFORMAT_RGBA16SN: {
            return "SG_PIXELFORMAT_RGBA16SN";
        }
        case SG_PIXELFORMAT_RGBA16UI: {
            return "SG_PIXELFORMAT_RGBA16UI";
        }
        case SG_PIXELFORMAT_RGBA16SI: {
            return "SG_PIXELFORMAT_RGBA16SI";
        }
        case SG_PIXELFORMAT_RGBA16F: {
            return "SG_PIXELFORMAT_RGBA16F";
        }
        case SG_PIXELFORMAT_RGBA32UI: {
            return "SG_PIXELFORMAT_RGBA32UI";
        }
        case SG_PIXELFORMAT_RGBA32SI: {
            return "SG_PIXELFORMAT_RGBA32SI";
        }
        case SG_PIXELFORMAT_RGBA32F: {
            return "SG_PIXELFORMAT_RGBA32F";
        }
        case SG_PIXELFORMAT_DEPTH: {
            return "SG_PIXELFORMAT_DEPTH";
        }
        case SG_PIXELFORMAT_DEPTH_STENCIL: {
            return "SG_PIXELFORMAT_DEPTH_STENCIL";
        }
        case SG_PIXELFORMAT_BC1_RGBA: {
            return "SG_PIXELFORMAT_BC1_RGBA";
        }
        case SG_PIXELFORMAT_BC2_RGBA: {
            return "SG_PIXELFORMAT_BC2_RGBA";
        }
        case SG_PIXELFORMAT_BC3_RGBA: {
            return "SG_PIXELFORMAT_BC3_RGBA";
        }
        case SG_PIXELFORMAT_BC4_R: {
            return "SG_PIXELFORMAT_BC4_R";
        }
        case SG_PIXELFORMAT_BC4_RSN: {
            return "SG_PIXELFORMAT_BC4_RSN";
        }
        case SG_PIXELFORMAT_BC5_RG: {
            return "SG_PIXELFORMAT_BC5_RG";
        }
        case SG_PIXELFORMAT_BC5_RGSN: {
            return "SG_PIXELFORMAT_BC5_RGSN";
        }
        case SG_PIXELFORMAT_BC6H_RGBF: {
            return "SG_PIXELFORMAT_BC6H_RGBF";
        }
        case SG_PIXELFORMAT_BC6H_RGBUF: {
            return "SG_PIXELFORMAT_BC6H_RGBUF";
        }
        case SG_PIXELFORMAT_BC7_RGBA: {
            return "SG_PIXELFORMAT_BC7_RGBA";
        }
        case SG_PIXELFORMAT_ETC2_RGB8: {
            return "SG_PIXELFORMAT_ETC2_RGB8";
        }
        case SG_PIXELFORMAT_ETC2_RGB8A1: {
            return "SG_PIXELFORMAT_ETC2_RGB8A1";
        }
        default: {
            return "???";
        }
    }
}
}
