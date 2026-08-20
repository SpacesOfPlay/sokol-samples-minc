import dbgui;
import imgui_compat;
import sokol_gfx_imgui;
import sokol_app_imgui;
import sapp_util;
import sokol_fetch;
import qoi;
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

// blend-playground-sapp.glsl
//

struct Ub_bg_params {
    f32 dark;
    f32 light;
}

struct Ub_img_vs_params {
    float2 offset;
    float2 scale;
}

@gpu_layout
struct Ub_img_fs_params {
    float4 src1_color;
    f32 alpha_scale;
    i32 premultiplied_alpha;
}

struct BlendPlaygroundSappFsqOut {
    float4 pos;
    float2 uv;
}

struct BlendPlaygroundSappImgOut {
    float4 pos;
    float2 uv;
}

// The second output feeds the blend equation, not a second attachment.
struct BlendPlaygroundSappDualsrcOut {
    float4 frag_color;
    @blend_src float4 frag_blend;
}

// --- fullscreen quad, shared by the bg and compose passes -------------

@shader vertex
BlendPlaygroundSappFsqOut blend_playground_sapp_vs_fsq() {
    // one oversized triangle from the vertex index; uv flipped to match
    // upstream's @glsl_options flip_vert_y
    BlendPlaygroundSappFsqOut o;
    i32 vid = cast(i32, vertex_id());
    if vid == 0 {
        o.pos = float4{-1.0f, 1.0f, 0.0f, 1.0f};
        o.uv = float2{0.0f, 0.0f};
    } else if vid == 1 {
        o.pos = float4{3.0f, 1.0f, 0.0f, 1.0f};
        o.uv = float2{2.0f, 0.0f};
    } else {
        o.pos = float4{-1.0f, -3.0f, 0.0f, 1.0f};
        o.uv = float2{0.0f, 2.0f};
    }
    return o;
}

@shader fragment
float4 blend_playground_sapp_fs_bg(
    BlendPlaygroundSappFsqOut input,
    @uniform(0) Ub_bg_params p
) {
    float2 fc = frag_coord().xy;
    u32 x = cast(u32, floor(fc.x / 15.0f));
    u32 y = cast(u32, floor(fc.y / 15.0f));
    f32 v = p.dark;
    if ((x ^ y) & cast(u32, 1)) == cast(u32, 0) { v = p.light; }
    return float4{v, v, v, 1.0f};
}

@shader fragment
float4 blend_playground_sapp_fs_compose(
    BlendPlaygroundSappFsqOut input,
    @texture(0) Texture2D tex,
    @sampler(0) Sampler smp
) {
    return sample(tex, smp, input.uv);
}

// --- the image quad ---------------------------------------------------

@shader vertex
BlendPlaygroundSappImgOut blend_playground_sapp_vs_img(
    @uniform(0) Ub_img_vs_params p
) {
    float2[4] pos = {
        float2{-1.0f, -1.0f},
        float2{1.0f, -1.0f},
        float2{-1.0f, 1.0f},
        float2{1.0f, 1.0f},
    };
    float2 v = pos[cast(i32, vertex_id())];
    BlendPlaygroundSappImgOut o;
    o.pos = float4{v.x * p.scale.x + p.offset.x, v.y * p.scale.y + p.offset.y,
                   0.0f, 1.0f};
    o.uv = float2{v.x * 0.5f + 0.5f, v.y * -0.5f + 0.5f};
    return o;
}

@shader fragment
float4 blend_playground_sapp_fs_img_std(
    BlendPlaygroundSappImgOut input,
    @uniform(1) Ub_img_fs_params p,
    @texture(0) Texture2D tex,
    @sampler(0) Sampler smp
) {
    float4 c = sample(tex, smp, input.uv);
    c.w = c.w * p.alpha_scale;
    if p.premultiplied_alpha != 0 {
        c = float4{c.x * c.w, c.y * c.w, c.z * c.w, c.w};
    }
    return c;
}

// GLES
when gpu(opengles) {
    @shader fragment
    float4 blend_playground_sapp_fs_img_dualsrc(
        BlendPlaygroundSappImgOut input,
        @uniform(1) Ub_img_fs_params p,
        @texture(0) Texture2D tex,
        @sampler(0) Sampler smp
    ) {
        float4 c = sample(tex, smp, input.uv);
        c.w = c.w * p.alpha_scale;
        if p.premultiplied_alpha != 0 {
            c = float4{c.x * c.w, c.y * c.w, c.z * c.w, c.w};
        }
        return c;
    }
}

when !gpu(opengles) {
    @shader fragment
    BlendPlaygroundSappDualsrcOut blend_playground_sapp_fs_img_dualsrc(
        BlendPlaygroundSappImgOut input,
        @uniform(1) Ub_img_fs_params p,
        @texture(0) Texture2D tex,
        @sampler(0) Sampler smp
    ) {
        float4 c = sample(tex, smp, input.uv);
        c.w = c.w * p.alpha_scale;
        if p.premultiplied_alpha != 0 {
            c = float4{c.x * c.w, c.y * c.w, c.z * c.w, c.w};
        }
        BlendPlaygroundSappDualsrcOut o;
        o.frag_color = c;
        o.frag_blend = p.src1_color;
        return o;
    }
}

enum __enum_UB_bg_params {
    UB_bg_params = 0,
    UB_img_vs_params = 0,
    UB_img_fs_params = 1,
    VIEW_tex = 0,
    SMP_smp = 0,
    __shim_end = 255,
}

enum __enum_SHADER_STD {
    SHADER_STD = 0,
    SHADER_DUALSRC = 1,
    NUM_SHADERS = 2,
}

/* Replaces the sokol-shdc generated blend-playground-sapp.glsl.h. */
struct bg_params_t {
    f32 dark;
    f32 light;
    u8[8] _pad_tail;
}

struct img_vs_params_t {
    vec2_t offset;
    vec2_t scale;
}

struct img_fs_params_t {
    vec4_t src1_color;
    f32 alpha_scale;
    i32 premultiplied_alpha;
    u8[8] _pad_tail;
}

private struct state_t {
    sg_pipeline bg_pip;
    sg_blend_state blend;
    sg_color blend_color;
    sg_color src1_color;
    struct {
        bool valid;
        sg_image img;
        sg_view tex_view;
        sg_sampler smp;
        sg_pipeline pip;
        sg_shader[2] shaders;
        f32 width;
        f32 height;
    } image;
    struct {
        sg_image img;
        sg_view att_view;
        sg_view tex_view;
        sg_sampler smp;
        sg_pipeline pip;
    } compose;
    struct {
        f32 scale;
        vec2_t offset;
    } ctrl;
    struct {
        f32 alpha_scale;
        bool premultiplied_alpha;
        i32 src_factor_rgb_sel;
        i32 dst_factor_rgb_sel;
        i32 op_rgb_sel;
        i32 src_factor_alpha_sel;
        i32 dst_factor_alpha_sel;
        i32 op_alpha_sel;
        u8* msg;
    } ui;
    struct {
        sfetch_error_t error;
        bool qoi_decode_failed;
        u8[786432] buf;
    } file;
}

private {
u8*[19] blend_factor_names = {
    "Zero", "One", "SrcColor", "OneMinusSrcColor", "SrcAlpha", "OneMinusSrcAlpha", "DstColor",
    "OneMinusDstColor", "DstAlpha", "OneMinusDstAlpha", "SrcAlphaSaturated", "BlendColor",
    "OneMinusBlendColor", "BlendAlpha", "OneMinusBlendAlpha", "Src1Color", "OneMinusSrc1Color",
    "Src1Alpha", "OneMinusSrc1Alpha",
};
sg_blend_factor[19] blend_factors = {
    SG_BLENDFACTOR_ZERO, SG_BLENDFACTOR_ONE, SG_BLENDFACTOR_SRC_COLOR,
    SG_BLENDFACTOR_ONE_MINUS_SRC_COLOR, SG_BLENDFACTOR_SRC_ALPHA,
    SG_BLENDFACTOR_ONE_MINUS_SRC_ALPHA, SG_BLENDFACTOR_DST_COLOR,
    SG_BLENDFACTOR_ONE_MINUS_DST_COLOR, SG_BLENDFACTOR_DST_ALPHA,
    SG_BLENDFACTOR_ONE_MINUS_DST_ALPHA, SG_BLENDFACTOR_SRC_ALPHA_SATURATED,
    SG_BLENDFACTOR_BLEND_COLOR, SG_BLENDFACTOR_ONE_MINUS_BLEND_COLOR, SG_BLENDFACTOR_BLEND_ALPHA,
    SG_BLENDFACTOR_ONE_MINUS_BLEND_ALPHA, SG_BLENDFACTOR_SRC1_COLOR,
    SG_BLENDFACTOR_ONE_MINUS_SRC1_COLOR, SG_BLENDFACTOR_SRC1_ALPHA,
    SG_BLENDFACTOR_ONE_MINUS_SRC1_ALPHA,
};
u8*[5] blend_op_names = {"Add", "Subtract", "ReverseSubtract", "Min", "Max"};
sg_blend_op[5] blend_ops = {
    SG_BLENDOP_ADD, SG_BLENDOP_SUBTRACT, SG_BLENDOP_REVERSE_SUBTRACT, SG_BLENDOP_MIN,
    SG_BLENDOP_MAX,
};
state_t state;
}

private {
void init() {
    sg_setup(&sg_desc{.environment = sglue_environment(), .logger = sg_logger{.func = slog_func}});
    sgimgui_setup(&sgimgui_desc_t{});
    sappimgui_setup();
    simgui_setup(&simgui_desc_t{.logger = simgui_logger_t{.func = slog_func}});
    sfetch_setup(&sfetch_desc_t{
        .max_requests = 1,
        .num_channels = 1,
        .num_lanes = 1,
        .logger = sfetch_logger_t{.func = slog_func},
    });
    ctrl_reset();
    state.blend.enabled = true;
    state.blend_color = sg_color{1.0f, 1.0f, 1.0f, 1.0f};
    state.src1_color = sg_color{1.0f, 1.0f, 1.0f, 1.0f};
    state.ui.alpha_scale = 1.0f;
    set_src_factor_rgb(SG_BLENDFACTOR_SRC_ALPHA);
    set_dst_factor_rgb(SG_BLENDFACTOR_ONE_MINUS_SRC_ALPHA);
    set_op_rgb(SG_BLENDOP_ADD);
    set_src_factor_alpha(SG_BLENDFACTOR_ZERO);
    set_dst_factor_alpha(SG_BLENDFACTOR_ONE);
    set_op_alpha(SG_BLENDOP_ADD);
    state.bg_pip = sg_make_pipeline(&sg_pipeline_desc{
        .shader = sokol_make_shader(&blend_playground_sapp_vs_fsq_shader, &blend_playground_sapp_fs_bg_shader),
        .depth = sg_depth_state{.write_enabled = false, .pixel_format = SG_PIXELFORMAT_NONE},
        .colors[0] = {.pixel_format = SG_PIXELFORMAT_RGBA8},
        .label = "background-pipeline",
    });
    state.image.shaders[SHADER_STD] = sokol_make_shader(&blend_playground_sapp_vs_img_shader, &blend_playground_sapp_fs_img_std_shader);
    if sg_query_features().dual_source_blending != 0 {
        state.image.shaders[SHADER_DUALSRC] = sokol_make_shader(&blend_playground_sapp_vs_img_shader, &blend_playground_sapp_fs_img_dualsrc_shader);
    }
    state.image.smp = sg_make_sampler(&sg_sampler_desc{
        .min_filter = SG_FILTER_LINEAR,
        .mag_filter = SG_FILTER_LINEAR,
        .wrap_u = SG_WRAP_CLAMP_TO_EDGE,
        .wrap_v = SG_WRAP_CLAMP_TO_EDGE,
        .label = "img-sampler",
    });
    recreate_pipeline();
    recreate_compose_image_and_views();
    state.compose.smp = sg_make_sampler(&sg_sampler_desc{
        .min_filter = SG_FILTER_NEAREST,
        .mag_filter = SG_FILTER_NEAREST,
        .wrap_u = SG_WRAP_CLAMP_TO_EDGE,
        .wrap_v = SG_WRAP_CLAMP_TO_EDGE,
        .label = "offscreen-sampler",
    });
    state.compose.pip = sg_make_pipeline(&sg_pipeline_desc{
        .shader = sokol_make_shader(&blend_playground_sapp_vs_fsq_shader, &blend_playground_sapp_fs_compose_shader),
        .primitive_type = SG_PRIMITIVETYPE_TRIANGLE_STRIP,
        .color_count = 1,
        .colors[0] = {
            .blend = {
                .enabled = true,
                .src_factor_rgb = SG_BLENDFACTOR_SRC_ALPHA,
                .dst_factor_rgb = SG_BLENDFACTOR_ONE_MINUS_SRC_ALPHA,
                .src_factor_alpha = SG_BLENDFACTOR_ZERO,
                .dst_factor_alpha = SG_BLENDFACTOR_ONE,
            },
        },
        .label = "offscreen-pipeline",
    });
    noinit u8[512] path_buf;
    state.file.error = SFETCH_ERROR_NO_ERROR;
    sfetch_send(&sfetch_request_t{
        .path = fileutil_get_path("dice.qoi", path_buf, cast(u64, sizeof(path_buf))),
        .callback = fetch_callback,
        .buffer = sfetch_range_t{&state.file.buf, sizeof(state.file.buf)},
    });
}

void frame() {
    sfetch_dowork();
    bool pip_dirty = draw_ui();
    if pip_dirty != 0 {
        recreate_pipeline();
    }
    sg_begin_pass(&sg_pass{
        .action = sg_pass_action{.colors[0] = {.load_action = SG_LOADACTION_DONTCARE}},
        .attachments = sg_attachments{.colors[0] = state.compose.att_view},
    });
    var bg_params = bg_params_t{.light = 0.6f, .dark = 0.4f};
    sg_apply_pipeline(state.bg_pip);
    sg_apply_uniforms(UB_bg_params, &sg_range{&bg_params, sizeof(bg_params)});
    sg_draw(0, 3, 1);
    if state.image.valid != 0 {
        img_vs_params_t img_vs_params = image_vs_params();
        img_fs_params_t img_fs_params = image_fs_params();
        sg_apply_pipeline(state.image.pip);
        sg_apply_bindings(&sg_bindings{
            .views[0] = state.image.tex_view,
            .samplers[0] = state.image.smp,
        });
        sg_apply_uniforms(UB_img_vs_params, &sg_range{&img_vs_params, sizeof(img_vs_params)});
        sg_apply_uniforms(UB_img_fs_params, &sg_range{&img_fs_params, sizeof(img_fs_params)});
        sg_draw(0, 4, 1);
    }
    sg_end_pass();
    sg_begin_pass(&sg_pass{
        .action = sg_pass_action{
            .colors[0] = {
                .load_action = SG_LOADACTION_CLEAR,
                .clear_value = {1.0f, 0.0f, 1.0f, 1.0f},
            },
        },
        .swapchain = sglue_swapchain(),
    });
    sg_apply_pipeline(state.compose.pip);
    sg_apply_bindings(&sg_bindings{
        .views[0] = state.compose.tex_view,
        .samplers[0] = state.compose.smp,
    });
    sg_draw(0, 3, 1);
    simgui_render();
    sg_end_pass();
    sg_commit();
}

void cleanup() {
    sfetch_shutdown();
    sappimgui_shutdown();
    simgui_shutdown();
    sgimgui_shutdown();
    sg_shutdown();
}

void input(sapp_event* ev) {
    sappimgui_track_event(ev);
    if simgui_handle_event(ev) != 0 {
        return;
    } else {
        switch ev.type {
            case SAPP_EVENTTYPE_RESIZED: {
                recreate_compose_image_and_views();
            }
            case SAPP_EVENTTYPE_KEY_DOWN: {
                if ev.key_code == SAPP_KEYCODE_SPACE {
                    ctrl_reset();
                }
            }
            case SAPP_EVENTTYPE_MOUSE_MOVE: {
                if (ev.modifiers & cast(u32, SAPP_MODIFIER_LMB)) != 0 {
                    ctrl_move(ev.mouse_dx, ev.mouse_dy);
                }
            }
            case SAPP_EVENTTYPE_MOUSE_SCROLL: {
                ctrl_scale(ev.scroll_y * 0.25f);
            }
            default: {
            }
        }
    }
}

bool draw_ui() {
    bool pip_dirty = false;
    sappimgui_track_frame();
    simgui_new_frame(&simgui_frame_desc_t{
        .width = sapp_width(),
        .height = sapp_height(),
        .delta_time = sapp_frame_duration(),
        .dpi_scale = sapp_dpi_scale(),
    });
    if ImGui_BeginMainMenuBar() != 0 {
        sgimgui_draw_menu("sokol-gfx");
        sappimgui_draw_menu("sokol-app");
        ImGui_EndMainMenuBar();
    }
    sgimgui_draw();
    sappimgui_draw();
    ImGui_SetNextWindowPos(ImVec2{20.0f, 30.0f}, ImGuiCond_Once);
    if ImGui_Begin("Controls", null, ImGuiWindowFlags_AlwaysAutoResize) != 0 {
        if state.file.error != SFETCH_ERROR_NO_ERROR {
            ImGui_Text("Failed to load image.");
        } else if state.image.valid == 0 {
            ImGui_Text("Loading image...");
        } else {
            ImGui_SeparatorText("Camera");
            ImGui_SliderFloat("Zoom", &state.ctrl.scale, 0.25f, 4.0f);
            ImGui_SliderFloat2("Pan", &state.ctrl.offset.x, -sapp_widthf() * 0.5f, cast(f32, sapp_width()) * 0.5f);
            if ImGui_Button("Reset") != 0 {
                state.ctrl.scale = 1.0f;
                state.ctrl.offset = vec2(0.0f, 0.0f);
            }
            ImGui_SeparatorText("Texture Properties");
            ImGui_SliderFloat("Alpha Scale", &state.ui.alpha_scale, 0.0f, 1.0f);
            ImGui_Checkbox("Premultiplied Alpha", &state.ui.premultiplied_alpha);
            ImGui_SeparatorText("RGB Blend State");
            if ImGui_Combo("Src Factor##RGB", &state.ui.src_factor_rgb_sel, blend_factor_names, 19) != 0 {
                set_src_factor_rgb(blend_factors[state.ui.src_factor_rgb_sel]);
                validate_rgb();
                pip_dirty = true;
            }
            if ImGui_Combo("Blend Op##RGB", &state.ui.op_rgb_sel, blend_op_names, 5) != 0 {
                set_op_rgb(blend_ops[state.ui.op_rgb_sel]);
                validate_rgb();
                pip_dirty = true;
            }
            if ImGui_Combo("Dst Factor##RGB", &state.ui.dst_factor_rgb_sel, blend_factor_names, 19) != 0 {
                set_dst_factor_rgb(blend_factors[state.ui.dst_factor_rgb_sel]);
                validate_rgb();
                pip_dirty = true;
            }
            ImGui_SeparatorText("Alpha Blend State");
            if ImGui_Combo("Src Factor##Alpha", &state.ui.src_factor_alpha_sel, blend_factor_names, 19) != 0 {
                set_src_factor_alpha(blend_factors[state.ui.src_factor_alpha_sel]);
                validate_alpha();
                pip_dirty = true;
            }
            if ImGui_Combo("Blend Op##Alpha", &state.ui.op_alpha_sel, blend_op_names, 5) != 0 {
                set_op_alpha(blend_ops[state.ui.op_alpha_sel]);
                validate_alpha();
                pip_dirty = true;
            }
            if ImGui_Combo("Dst Factor##Alpha", &state.ui.dst_factor_alpha_sel, blend_factor_names, 19) != 0 {
                set_dst_factor_alpha(blend_factors[state.ui.dst_factor_alpha_sel]);
                validate_alpha();
                pip_dirty = true;
            }
            ImGui_SeparatorText("Input Colors");
            if ImGui_ColorEdit4("Blend Color", &state.blend_color.r, ImGuiColorEditFlags_AlphaBar) != 0 {
                pip_dirty = true;
            }
            ImGui_ColorEdit4("Src1 Color", &state.src1_color.r, ImGuiColorEditFlags_AlphaBar);
            ImGui_SeparatorText("Validation");
            if null == state.ui.msg {
                ImGui_Text("All ok.");
            } else {
                ImGui_Text("%s", state.ui.msg);
            }
        }
    }
    ImGui_End();
    return pip_dirty;
}

void recreate_pipeline() {
    if state.image.pip.id != cast(u32, SG_INVALID_ID) {
        sg_destroy_pipeline(state.image.pip);
        state.image.pip.id = cast(u32, SG_INVALID_ID);
    }
    i32 shd_index = sg_query_features().dual_source_blending && is_dualsrc_blend() ? SHADER_DUALSRC : SHADER_STD;
    state.image.pip = sg_make_pipeline(&sg_pipeline_desc{
        .shader = state.image.shaders[shd_index],
        .primitive_type = SG_PRIMITIVETYPE_TRIANGLE_STRIP,
        .depth = sg_depth_state{.pixel_format = SG_PIXELFORMAT_NONE, .write_enabled = false},
        .color_count = 1,
        .colors[0] = {.pixel_format = SG_PIXELFORMAT_RGBA8, .blend = state.blend},
        .blend_color = state.blend_color,
        .label = "img-pipeline",
    });
}

void recreate_compose_image_and_views() {
    if state.compose.img.id != cast(u32, SG_INVALID_ID) {
        sg_destroy_image(state.compose.img);
        state.compose.img.id = cast(u32, SG_INVALID_ID);
    }
    if state.compose.att_view.id != cast(u32, SG_INVALID_ID) {
        sg_destroy_view(state.compose.att_view);
        state.compose.att_view.id = cast(u32, SG_INVALID_ID);
    }
    if state.compose.tex_view.id != cast(u32, SG_INVALID_ID) {
        sg_destroy_view(state.compose.tex_view);
        state.compose.tex_view.id = cast(u32, SG_INVALID_ID);
    }
    state.compose.img = sg_make_image(&sg_image_desc{
        .usage = sg_image_usage{.color_attachment = true},
        .width = sapp_width(),
        .height = sapp_height(),
        .pixel_format = SG_PIXELFORMAT_RGBA8,
        .label = "compose-image",
    });
    state.compose.att_view = sg_make_view(&sg_view_desc{
        .color_attachment = sg_image_view_desc{.image = state.compose.img},
        .label = "compose-color-attachment",
    });
    state.compose.tex_view = sg_make_view(&sg_view_desc{
        .texture = sg_texture_view_desc{.image = state.compose.img},
        .label = "compose-tex-view",
    });
}

void create_image(void* qoi_data_ptr, u64 qoi_data_size) {
    if state.image.img.id != cast(u32, SG_INVALID_ID) {
        sg_destroy_image(state.image.img);
        state.image.img.id = cast(u32, SG_INVALID_ID);
    }
    if state.image.tex_view.id != cast(u32, SG_INVALID_ID) {
        sg_destroy_view(state.image.tex_view);
        state.image.tex_view.id = cast(u32, SG_INVALID_ID);
    }
    state.image.valid = false;
    noinit qoi_desc qoi;
    void* pixels = qoi_decode(qoi_data_ptr, cast(i32, qoi_data_size), &qoi, 4);
    if pixels == null {
        state.file.qoi_decode_failed = true;
        return;
    }
    state.image.width = cast(f32, qoi.width);
    state.image.height = cast(f32, qoi.height);
    state.image.img = sg_make_image(&sg_image_desc{
        .pixel_format = SG_PIXELFORMAT_RGBA8,
        .width = cast(i32, qoi.width),
        .height = cast(i32, qoi.height),
        .data = sg_image_data{.mip_levels[0] = {.ptr = pixels, .size = qoi.width * qoi.height * 4}},
        .label = "qoi-image",
    });
    free(pixels);
    state.image.tex_view = sg_make_view(&sg_view_desc{
        .texture = sg_texture_view_desc{.image = state.image.img},
        .label = "qoi-image-texview",
    });
    state.image.valid = true;
}

img_vs_params_t image_vs_params() {
    return img_vs_params_t{
        .offset = vec2_t{
            .x = state.ctrl.offset.x / (0.5f * sapp_widthf()),
            .y = -state.ctrl.offset.y / (0.5f * sapp_heightf()),
        },
        .scale = vec2_t{
            .x = state.image.width / sapp_widthf() * state.ctrl.scale,
            .y = state.image.height / sapp_heightf() * state.ctrl.scale,
        },
    };
}

img_fs_params_t image_fs_params() {
    return img_fs_params_t{
        .alpha_scale = state.ui.alpha_scale,
        .premultiplied_alpha = state.ui.premultiplied_alpha != 0 ? 1 : 0,
        .src1_color = vec4_t{
            .x = state.src1_color.r,
            .y = state.src1_color.g,
            .z = state.src1_color.b,
            .w = state.src1_color.a,
        },
    };
}

void fetch_callback(sfetch_response_t* response) {
    if response.fetched != 0 {
        state.file.error = SFETCH_ERROR_NO_ERROR;
        create_image(response.data.ptr, response.data.size);
    } else if response.failed != 0 {
        state.file.error = response.error_code;
    }
}

void ctrl_reset() {
    state.ctrl.scale = cast(f32, 0.75);
    state.ctrl.offset.x = 0.0f;
    state.ctrl.offset.y = 0.0f;
}

void ctrl_move(f32 dx, f32 dy) {
    state.ctrl.offset.x += dx;
    state.ctrl.offset.y += dy;
}

void ctrl_scale(f32 ds) {
    state.ctrl.scale *= expf(ds);
    if state.ctrl.scale > 4.0f {
        state.ctrl.scale = 4.0f;
    } else if state.ctrl.scale < 0.25f {
        state.ctrl.scale = 0.25f;
    }
}

bool is_dualsrc_blend_factor(sg_blend_factor f) {
    return f == SG_BLENDFACTOR_SRC1_ALPHA || f == SG_BLENDFACTOR_SRC1_COLOR || f == SG_BLENDFACTOR_ONE_MINUS_SRC1_ALPHA || f == SG_BLENDFACTOR_ONE_MINUS_SRC1_COLOR;
}

bool is_dualsrc_blend() {
    return is_dualsrc_blend_factor(state.blend.src_factor_rgb) || is_dualsrc_blend_factor(state.blend.dst_factor_rgb) || is_dualsrc_blend_factor(state.blend.src_factor_alpha) || is_dualsrc_blend_factor(state.blend.dst_factor_alpha);
}

bool is_blend_color(sg_blend_factor f) {
    return f == SG_BLENDFACTOR_BLEND_COLOR || f == SG_BLENDFACTOR_ONE_MINUS_BLEND_COLOR;
}

bool is_blend_alpha(sg_blend_factor f) {
    return f == SG_BLENDFACTOR_BLEND_ALPHA || f == SG_BLENDFACTOR_ONE_MINUS_BLEND_ALPHA;
}

i32 find_blend_factor_index(sg_blend_factor f) {
    for i32 i = 0; i < 19; i++ {
        if f == blend_factors[i] {
            return i;
        }
    }
    return 0;
}

i32 find_blend_op_index(sg_blend_op op) {
    for i32 i = 0; i < 5; i++ {
        if op == blend_ops[i] {
            return i;
        }
    }
    return 0;
}

void validate_rgb() {
    state.ui.msg = null;
    sg_blend_factor src_rgb = state.blend.src_factor_rgb;
    sg_blend_factor dst_rgb = state.blend.dst_factor_rgb;
    sg_blend_op op_rgb = state.blend.op_rgb;
    if op_rgb == SG_BLENDOP_MIN || op_rgb == SG_BLENDOP_MAX {
        if src_rgb != SG_BLENDFACTOR_ONE || dst_rgb != SG_BLENDFACTOR_ONE {
            set_src_factor_rgb(SG_BLENDFACTOR_ONE);
            set_dst_factor_rgb(SG_BLENDFACTOR_ONE);
            state.ui.msg = "Blend op min/max requires src/dst factor one/one";
        }
    }
    if is_dualsrc_blend() && !sg_query_features().dual_source_blending {
        set_src_factor_rgb(SG_BLENDFACTOR_SRC_ALPHA);
        set_dst_factor_rgb(SG_BLENDFACTOR_ONE_MINUS_SRC_ALPHA);
        set_op_rgb(SG_BLENDOP_ADD);
        state.ui.msg = "Dual source blending not supported";
    }
    if sg_query_backend() == SG_BACKEND_GLES3 {
        if is_blend_color(src_rgb) && is_blend_alpha(dst_rgb) || is_blend_alpha(src_rgb) && is_blend_color(dst_rgb) {
            set_src_factor_rgb(SG_BLENDFACTOR_SRC_ALPHA);
            set_dst_factor_rgb(SG_BLENDFACTOR_ONE_MINUS_SRC_ALPHA);
            set_op_rgb(SG_BLENDOP_ADD);
            state.ui.msg = "Invalid blend combo on WebGL2";
        }
    }
}

void validate_alpha() {
    state.ui.msg = null;
    sg_blend_factor src_a = state.blend.src_factor_alpha;
    sg_blend_factor dst_a = state.blend.dst_factor_alpha;
    sg_blend_op op_a = state.blend.op_alpha;
    if op_a == SG_BLENDOP_MIN || op_a == SG_BLENDOP_MAX {
        if src_a != SG_BLENDFACTOR_ONE || dst_a != SG_BLENDFACTOR_ONE {
            set_src_factor_alpha(SG_BLENDFACTOR_ONE);
            set_dst_factor_alpha(SG_BLENDFACTOR_ONE);
            state.ui.msg = "Blend op min/max requires src/dst factor one/one";
        }
    } else if is_dualsrc_blend() && !sg_query_features().dual_source_blending {
        set_src_factor_alpha(SG_BLENDFACTOR_ZERO);
        set_dst_factor_alpha(SG_BLENDFACTOR_ONE);
        state.ui.msg = "Dual source blending not supported";
    }
}

void set_src_factor_rgb(sg_blend_factor f) {
    state.blend.src_factor_rgb = f;
    state.ui.src_factor_rgb_sel = find_blend_factor_index(f);
}

void set_dst_factor_rgb(sg_blend_factor f) {
    state.blend.dst_factor_rgb = f;
    state.ui.dst_factor_rgb_sel = find_blend_factor_index(f);
}

void set_op_rgb(sg_blend_op op) {
    state.blend.op_rgb = op;
    state.ui.op_rgb_sel = find_blend_op_index(op);
}

void set_src_factor_alpha(sg_blend_factor f) {
    state.blend.src_factor_alpha = f;
    state.ui.src_factor_alpha_sel = find_blend_factor_index(f);
}

void set_dst_factor_alpha(sg_blend_factor f) {
    state.blend.dst_factor_alpha = f;
    state.ui.dst_factor_alpha_sel = find_blend_factor_index(f);
}

void set_op_alpha(sg_blend_op op) {
    state.blend.op_alpha = op;
    state.ui.op_alpha_sel = find_blend_op_index(op);
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
        .sample_count = 1,
        .depth_format = SAPP_PIXELFORMAT_NONE,
        .window_title = "blend-playground-sapp.mc",
        .icon = sapp_icon_desc{.sokol_default = true},
        .logger = sapp_logger{.func = slog_func},
    };
}
