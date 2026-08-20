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

// shadows-sapp.glsl, hand-ported to minc @shader.
// RGBA8-encoded depth shadow map (no comparison sampler needed).
// sample_shadow / sample_shadow_pcf are inlined into the display FS:
// minc texture/sampler handles cannot be passed to helper functions.
// upstream flips light_proj_pos.y for non-GL clip space (mirrored here
// with `when !gpu(opengl)`) and marks the dbg pass @glsl_options
// flip_vert_y, which we don't, the debug thumbnail in the corner is
// therefore vertically mirrored vs D3D/Metal.

// --- util helpers (pure) ---------------------------------------------

float4 shadows_encode_depth(f32 v) {
    float4 enc = float4{1.0f, 255.0f, 65025.0f, 16581375.0f} * v;
    enc = fract(enc);
    enc -= enc.yzww * float4{1.0f / 255.0f, 1.0f / 255.0f, 1.0f / 255.0f, 0.0f};
    return enc;
}

f32 shadows_decode_depth(float4 rgba) {
    return dot(rgba, float4{1.0f, 1.0f / 255.0f, 1.0f / 65025.0f, 1.0f / 16581375.0f});
}

// --- shadow pass -----------------------------------------------------

struct ShadowsShadowOut {
    float4 pos;
    float2 proj_zw;
}

@shader vertex
ShadowsShadowOut shadows_sapp_vs_shadow(
    @attr(0) float4 pos,
    @uniform float4x4 mvp
) {
    ShadowsShadowOut o;
    o.pos = mul(mvp, pos);
    o.proj_zw = o.pos.zw;
    return o;
}

@shader fragment
float4 shadows_sapp_fs_shadow(ShadowsShadowOut input) {
    f32 depth = input.proj_zw.x / input.proj_zw.y;
    return shadows_encode_depth(depth);
}

// --- display pass ----------------------------------------------------

@gpu_layout
struct Ub_vs_display_params {
    float4x4 mvp;
    float4x4 model;
    float4x4 light_mvp;
    float3 diff_color;
}

@gpu_layout
struct Ub_fs_display_params {
    float3 light_dir;
    float3 eye_pos;
}

struct ShadowsDisplayOut {
    float4 pos;
    float3 color;
    float4 light_proj_pos;
    float4 world_pos;
    float3 world_norm;
}

@shader vertex
ShadowsDisplayOut shadows_sapp_vs_display(
    @attr(0) float4 pos,
    @attr(1) float3 norm,
    @uniform(0) Ub_vs_display_params vs_display_params
) {
    ShadowsDisplayOut o;
    o.pos = mul(vs_display_params.mvp, pos);
    o.light_proj_pos = mul(vs_display_params.light_mvp, pos);
    // upstream's `#if !SOKOL_GLSL`: the GL backends already agree on
    // clip-space y, the others need the flip
    when !gpu(opengl) && !gpu(opengles) {
        o.light_proj_pos.y = 0.0f - o.light_proj_pos.y;
    }
    o.world_pos = mul(vs_display_params.model, pos);
    o.world_norm = normalize(mul(vs_display_params.model, float4{norm, 0.0f}).xyz);
    o.color = vs_display_params.diff_color;
    return o;
}

@shader fragment
float4 shadows_sapp_fs_display(
    ShadowsDisplayOut input,
    @texture(0) Texture2D shadow_map,
    @sampler(0) Sampler shadow_sampler,
    // Slot 1: UB_fs_display_params is 1 (the vs display block holds 0),
    // and on WebGPU a same-slot vs+fs pair collides in @group(0).
    @uniform(1) Ub_fs_display_params fs_display_params
) {
    int2 sm_isize = texture_size(shadow_map);
    float2 sm_size = float2{cast(f32, sm_isize.x), cast(f32, sm_isize.y)};
    f32 spec_power = 2.2f;
    f32 ambient_intensity = 0.25f;
    float3 l = normalize(fs_display_params.light_dir);
    float3 n = normalize(input.world_norm);
    f32 n_dot_l = dot(n, l);
    float4 out_color;
    if n_dot_l > 0.0f {
        float3 light_pos = input.light_proj_pos.xyz / input.light_proj_pos.w;
        float3 sm_pos = float3{(light_pos.xy + 1.0f) * 0.5f, light_pos.z};
        // sample_shadow_pcf, inlined (5x5 taps)
        f32 s_sum = 0.0f;
        for i32 x = -2; x <= 2; x++ {
            for i32 y = -2; y <= 2; y++ {
                float2 offset = float2{cast(f32, x), cast(f32, y)} / sm_size;
                f32 depth = shadows_decode_depth(
                    sample(shadow_map, shadow_sampler, sm_pos.xy + offset));
                s_sum += step(sm_pos.z, depth);
            }
        }
        f32 s = s_sum / 25.0f;
        f32 diff_intensity = max(n_dot_l * s, 0.0f);
        float3 v = normalize(fs_display_params.eye_pos - input.world_pos.xyz);
        float3 r = reflect(-l, n);
        f32 r_dot_v = max(dot(r, v), 0.0f);
        f32 spec_intensity = pow(r_dot_v, spec_power) * n_dot_l * s;
        out_color = float4{float3{spec_intensity, spec_intensity, spec_intensity}
                           + (diff_intensity + ambient_intensity) * input.color, 1.0f};
    } else {
        out_color = float4{input.color * ambient_intensity, 1.0f};
    }
    // gamma
    f32 p = 1.0f / 2.2f;
    return float4{pow(out_color.x, p), pow(out_color.y, p), pow(out_color.z, p), out_color.w};
}

// --- shadow-map debug view -------------------------------------------

struct ShadowsDbgOut {
    float4 pos;
    float2 uv;
}

@shader vertex
ShadowsDbgOut shadows_sapp_vs_dbg(@attr(0) float2 pos) {
    ShadowsDbgOut o;
    o.pos = float4{pos * 2.0f - 1.0f, 0.5f, 1.0f};
    o.uv = pos;
    return o;
}

@shader fragment
float4 shadows_sapp_fs_dbg(
    ShadowsDbgOut input,
    @texture(0) Texture2D dbg_tex,
    @sampler(0) Sampler dbg_smp
) {
    f32 depth = shadows_decode_depth(sample(dbg_tex, dbg_smp, input.uv));
    return float4{depth, depth, depth, 1.0f};
}

enum __enum_ATTR_shadow_pos {
    ATTR_shadow_pos = 0,
    ATTR_display_pos = 0,
    ATTR_display_norm = 1,
    ATTR_dbg_pos = 0,
    UB_vs_shadow_params = 0,
    UB_vs_display_params = 0,
    UB_fs_display_params = 1,
    VIEW_shadow_map = 0,
    SMP_shadow_sampler = 0,
    VIEW_dbg_tex = 0,
    SMP_dbg_smp = 0,
    __shim_end = 255,
}

// Replaces the sokol-shdc generated shadows-sapp.glsl.h.
struct vs_shadow_params_t {
    mat44_t mvp;
}

struct vs_display_params_t {
    mat44_t mvp;
    mat44_t model;
    mat44_t light_mvp;
    vec3_t diff_color;
    u8[4] _pad_tail;
}

struct fs_display_params_t {
    vec3_t light_dir;
    u8[4] _pad_12;
    vec3_t eye_pos;
    u8[4] _pad_tail;
}

private struct state_t {
    sg_buffer vbuf;
    sg_buffer ibuf;
    f32 ry;
    struct {
        sg_pass pass;
        sg_pipeline pip;
        sg_bindings bind;
    } shadow;
    struct {
        sg_pass_action pass_action;
        sg_pipeline pip;
        sg_bindings bind;
    } display;
    struct {
        sg_pipeline pip;
        sg_bindings bind;
    } dbg;
}

private {
state_t state;

void init() {
    sg_setup(&sg_desc{.environment = sglue_environment(), .logger = sg_logger{.func = slog_func}});
    __dbgui_setup();
    f32[168] scene_vertices = {
        -1.0f, -1.0f, -1.0f, 0.0f, 0.0f, -1.0f, 1.0f, -1.0f, -1.0f, 0.0f, 0.0f, -1.0f, 1.0f, 1.0f,
        -1.0f, 0.0f, 0.0f, -1.0f, -1.0f, 1.0f, -1.0f, 0.0f, 0.0f, -1.0f, -1.0f, -1.0f, 1.0f, 0.0f,
        0.0f, 1.0f, 1.0f, -1.0f, 1.0f, 0.0f, 0.0f, 1.0f, 1.0f, 1.0f, 1.0f, 0.0f, 0.0f, 1.0f, -1.0f,
        1.0f, 1.0f, 0.0f, 0.0f, 1.0f, -1.0f, -1.0f, -1.0f, -1.0f, 0.0f, 0.0f, -1.0f, 1.0f, -1.0f,
        -1.0f, 0.0f, 0.0f, -1.0f, 1.0f, 1.0f, -1.0f, 0.0f, 0.0f, -1.0f, -1.0f, 1.0f, -1.0f, 0.0f,
        0.0f, 1.0f, -1.0f, -1.0f, 1.0f, 0.0f, 0.0f, 1.0f, 1.0f, -1.0f, 1.0f, 0.0f, 0.0f, 1.0f, 1.0f,
        1.0f, 1.0f, 0.0f, 0.0f, 1.0f, -1.0f, 1.0f, 1.0f, 0.0f, 0.0f, -1.0f, -1.0f, -1.0f, 0.0f,
        -1.0f, 0.0f, -1.0f, -1.0f, 1.0f, 0.0f, -1.0f, 0.0f, 1.0f, -1.0f, 1.0f, 0.0f, -1.0f, 0.0f,
        1.0f, -1.0f, -1.0f, 0.0f, -1.0f, 0.0f, -1.0f, 1.0f, -1.0f, 0.0f, 1.0f, 0.0f, -1.0f, 1.0f,
        1.0f, 0.0f, 1.0f, 0.0f, 1.0f, 1.0f, 1.0f, 0.0f, 1.0f, 0.0f, 1.0f, 1.0f, -1.0f, 0.0f, 1.0f,
        0.0f, -5.0f, 0.0f, -5.0f, 0.0f, 1.0f, 0.0f, -5.0f, 0.0f, 5.0f, 0.0f, 1.0f, 0.0f, 5.0f, 0.0f,
        5.0f, 0.0f, 1.0f, 0.0f, 5.0f, 0.0f, -5.0f, 0.0f, 1.0f, 0.0f,
    };
    state.vbuf = sg_make_buffer(&sg_buffer_desc{
        .data = sg_range{&scene_vertices, sizeof(scene_vertices)},
        .label = "cube-vertices",
    });
    u16[42] scene_indices = {
        0, 1, 2, 0, 2, 3, 6, 5, 4, 7, 6, 4, 8, 9, 10, 8, 10, 11, 14, 13, 12, 15, 14, 12, 16, 17, 18,
        16, 18, 19, 22, 21, 20, 23, 22, 20, 26, 25, 24, 27, 26, 24,
    };
    state.ibuf = sg_make_buffer(&sg_buffer_desc{
        .usage = sg_buffer_usage{.index_buffer = true},
        .data = sg_range{&scene_indices, sizeof(scene_indices)},
        .label = "cube-indices",
    });
    state.display.pass_action = sg_pass_action{
        .colors[0] = {.load_action = SG_LOADACTION_CLEAR, .clear_value = {0.25f, 0.5f, 0.25f, 1.0f}},
    };
    sg_image shadow_map_img = sg_make_image(&sg_image_desc{
        .usage = sg_image_usage{.color_attachment = true},
        .width = 2048,
        .height = 2048,
        .pixel_format = SG_PIXELFORMAT_RGBA8,
        .sample_count = 1,
        .label = "shadow-map",
    });
    sg_image shadow_depth_img = sg_make_image(&sg_image_desc{
        .usage = sg_image_usage{.depth_stencil_attachment = true},
        .width = 2048,
        .height = 2048,
        .pixel_format = SG_PIXELFORMAT_DEPTH,
        .sample_count = 1,
        .label = "shadow-depth-buffer",
    });
    sg_view shadow_map_att_view = sg_make_view(&sg_view_desc{
        .color_attachment = sg_image_view_desc{.image = shadow_map_img},
        .label = "shadow-map-att-view",
    });
    sg_view shadow_map_tex_view = sg_make_view(&sg_view_desc{
        .texture = sg_texture_view_desc{.image = shadow_map_img},
        .label = "shadow-map-tex-view",
    });
    sg_view shadow_depth_att_view = sg_make_view(&sg_view_desc{
        .depth_stencil_attachment = sg_image_view_desc{.image = shadow_depth_img},
        .label = "shadow-depth-attachment",
    });
    state.shadow.pass = sg_pass{
        .action = sg_pass_action{
            .colors[0] = {
                .load_action = SG_LOADACTION_CLEAR,
                .clear_value = {1.0f, 1.0f, 1.0f, 1.0f},
            },
        },
        .attachments = sg_attachments{
            .colors[0] = shadow_map_att_view,
            .depth_stencil = shadow_depth_att_view,
        },
    };
    sg_sampler shadow_sampler = sg_make_sampler(&sg_sampler_desc{
        .min_filter = SG_FILTER_NEAREST,
        .mag_filter = SG_FILTER_NEAREST,
        .wrap_u = SG_WRAP_CLAMP_TO_EDGE,
        .wrap_v = SG_WRAP_CLAMP_TO_EDGE,
        .label = "shadow-sampler",
    });
    state.shadow.pip = sg_make_pipeline(&sg_pipeline_desc{
        .layout = sg_vertex_layout_state{
            .buffers[0] = {.stride = cast(i32, 6 * sizeof(f32))},
            .attrs[0] = {.format = SG_VERTEXFORMAT_FLOAT3},
        },
        .shader = sokol_make_shader(&shadows_sapp_vs_shadow_shader, &shadows_sapp_fs_shadow_shader),
        .index_type = SG_INDEXTYPE_UINT16,
        .cull_mode = SG_CULLMODE_FRONT,
        .sample_count = 1,
        .colors[0] = {.pixel_format = SG_PIXELFORMAT_RGBA8},
        .depth = sg_depth_state{
            .pixel_format = SG_PIXELFORMAT_DEPTH,
            .compare = SG_COMPAREFUNC_LESS_EQUAL,
            .write_enabled = true,
        },
        .label = "shadow-pipeline",
    });
    state.shadow.bind = sg_bindings{.vertex_buffers[0] = state.vbuf, .index_buffer = state.ibuf};
    state.display.pip = sg_make_pipeline(&sg_pipeline_desc{
        .layout = sg_vertex_layout_state{
            .attrs[0] = {.format = SG_VERTEXFORMAT_FLOAT3},
            .attrs[1] = {.format = SG_VERTEXFORMAT_FLOAT3},
        },
        .shader = sokol_make_shader(&shadows_sapp_vs_display_shader, &shadows_sapp_fs_display_shader),
        .index_type = SG_INDEXTYPE_UINT16,
        .cull_mode = SG_CULLMODE_BACK,
        .depth = sg_depth_state{.compare = SG_COMPAREFUNC_LESS_EQUAL, .write_enabled = true},
        .label = "display-pipeline",
    });
    state.display.bind = sg_bindings{
        .vertex_buffers[0] = state.vbuf,
        .index_buffer = state.ibuf,
        .views[0] = shadow_map_tex_view,
        .samplers[0] = shadow_sampler,
    };
    f32[8] dbg_vertices = {0.0f, 0.0f, 1.0f, 0.0f, 0.0f, 1.0f, 1.0f, 1.0f};
    sg_buffer dbg_vbuf = sg_make_buffer(&sg_buffer_desc{
        .data = sg_range{&dbg_vertices, sizeof(dbg_vertices)},
        .label = "debug-vertices",
    });
    state.dbg.pip = sg_make_pipeline(&sg_pipeline_desc{
        .layout = sg_vertex_layout_state{.attrs[0] = {.format = SG_VERTEXFORMAT_FLOAT2}},
        .shader = sokol_make_shader(&shadows_sapp_vs_dbg_shader, &shadows_sapp_fs_dbg_shader),
        .primitive_type = SG_PRIMITIVETYPE_TRIANGLE_STRIP,
        .label = "debug-pipeline",
    });
    sg_sampler dbg_smp = sg_make_sampler(&sg_sampler_desc{
        .min_filter = SG_FILTER_NEAREST,
        .mag_filter = SG_FILTER_NEAREST,
        .wrap_u = SG_WRAP_CLAMP_TO_EDGE,
        .wrap_v = SG_WRAP_CLAMP_TO_EDGE,
        .label = "debug-sampler",
    });
    state.dbg.bind = sg_bindings{
        .vertex_buffers[0] = dbg_vbuf,
        .views[0] = shadow_map_tex_view,
        .samplers[0] = dbg_smp,
    };
}

void frame() {
    var t = cast(f32, sapp_frame_duration() * 60.0);
    state.ry += 0.2f * t;
    vec3_t eye_pos = vec3(5.0f, 5.0f, 5.0f);
    mat44_t plane_model = mat44_identity();
    mat44_t cube_model = mat44_translation(0.0f, 1.5f, 0.0f);
    vec3_t plane_color = vec3(1.0f, 0.5f, 0.0f);
    vec3_t cube_color = vec3(0.5f, 0.5f, 1.0f);
    mat44_t rym = mat44_rotation_y(vecmath_radians(state.ry));
    vec4_t light_pos = vec4_transform(vec4(50.0f, 50.0f, -50.0f, 1.0f), rym);
    mat44_t light_view = mat44_look_at_rh(vec4_xyz(light_pos), vec3(0.0f, 1.5f, 0.0f), vec3(0.0f, 1.0f, 0.0f));
    mat44_t light_proj = mat44_ortho_off_center_rh(-5.0f, 5.0f, -5.0f, 5.0f, 0.0f, 100.0f);
    mat44_t light_view_proj = mat44_mul_mat44(light_view, light_proj);
    var cube_vs_shadow_params = vs_shadow_params_t{.mvp = mat44_mul_mat44(cube_model, light_view_proj)};
    mat44_t proj = mat44_perspective_fov_rh(vecmath_radians(60.0f), sapp_widthf() / sapp_heightf(), 0.01f, 100.0f);
    mat44_t view = mat44_look_at_rh(eye_pos, vec3(0.0f, 0.0f, 0.0f), vec3(0.0f, 1.0f, 0.0f));
    mat44_t view_proj = mat44_mul_mat44(view, proj);
    var fs_display_params = fs_display_params_t{
        .light_dir = vec3_normalize(vec4_xyz(light_pos)),
        .eye_pos = eye_pos,
    };
    var plane_vs_display_params = vs_display_params_t{
        .mvp = mat44_mul_mat44(plane_model, view_proj),
        .model = plane_model,
        .light_mvp = mat44_mul_mat44(plane_model, light_view_proj),
        .diff_color = plane_color,
    };
    var cube_vs_display_params = vs_display_params_t{
        .mvp = mat44_mul_mat44(cube_model, view_proj),
        .model = cube_model,
        .light_mvp = mat44_mul_mat44(cube_model, light_view_proj),
        .diff_color = cube_color,
    };
    sg_begin_pass(&state.shadow.pass);
    sg_apply_pipeline(state.shadow.pip);
    sg_apply_bindings(&state.shadow.bind);
    sg_apply_uniforms(UB_vs_shadow_params, &sg_range{&cube_vs_shadow_params, sizeof(cube_vs_shadow_params)});
    sg_draw(0, 36, 1);
    sg_end_pass();
    sg_begin_pass(&sg_pass{.action = state.display.pass_action, .swapchain = sglue_swapchain()});
    sg_apply_pipeline(state.display.pip);
    sg_apply_bindings(&state.display.bind);
    sg_apply_uniforms(UB_fs_display_params, &sg_range{&fs_display_params, sizeof(fs_display_params)});
    sg_apply_uniforms(UB_vs_display_params, &sg_range{&plane_vs_display_params, sizeof(plane_vs_display_params)});
    sg_draw(36, 6, 1);
    sg_apply_uniforms(UB_vs_display_params, &sg_range{&cube_vs_display_params, sizeof(cube_vs_display_params)});
    sg_draw(0, 36, 1);
    sg_apply_pipeline(state.dbg.pip);
    sg_apply_bindings(&state.dbg.bind);
    sg_apply_viewport(sapp_width() - 150, 0, 150, 150, false);
    sg_draw(0, 4, 1);
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
        .window_title = "shadows-sapp.mc",
        .icon = sapp_icon_desc{.sokol_default = true},
        .logger = sapp_logger{.func = slog_func},
    };
}
