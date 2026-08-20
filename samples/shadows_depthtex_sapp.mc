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

// shadows-depthtex-sapp.glsl, hand-ported. Three programs: a depth-only
// shadow pass, a lit display pass that compares against the depth
// texture through a comparison sampler, and a debug pass that shows the
// shadow map as a plain texture.

struct Ub_vs_shadow_params {
    float4x4 mvp;
}

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

struct ShadowsDepthtexSappShadowOut {
    float4 pos;
}

struct ShadowsDepthtexSappDisplayOut {
    float4 pos;
    float3 color;
    float4 light_proj_pos;
    float4 world_pos;
    float3 world_norm;
}

struct ShadowsDepthtexSappDbgOut {
    float4 pos;
    float2 uv;
}

// --- shadow pass: depth only ----------------------------------------

@shader vertex
ShadowsDepthtexSappShadowOut shadows_depthtex_sapp_vs_shadow(
    @attr(0) float4 pos,
    @uniform(0) Ub_vs_shadow_params p
) {
    ShadowsDepthtexSappShadowOut o;
    o.pos = mul(p.mvp, pos);
    // GL clip-space fixup: clip z is [0,1] by convention, GL expects [-1,1].
    when gpu(opengl) || gpu(opengles) {
        o.pos.z = o.pos.z * 2.0f - o.pos.w;
    }
    return o;
}

@shader fragment
float4 shadows_depthtex_sapp_fs_shadow(ShadowsDepthtexSappShadowOut input) {
    // depth-only pass; the pipeline declares no color target
    return float4{0.0f, 0.0f, 0.0f, 1.0f};
}

// --- display pass ----------------------------------------------------

@shader vertex
ShadowsDepthtexSappDisplayOut shadows_depthtex_sapp_vs_display(
    @attr(0) float4 pos,
    @attr(1) float3 norm,
    @uniform(0) Ub_vs_display_params p
) {
    ShadowsDepthtexSappDisplayOut o;
    o.pos = mul(p.mvp, pos);
    o.light_proj_pos = mul(p.light_mvp, pos);
    // upstream's `#if !SOKOL_GLSL`: the GL backends already agree on
    // clip-space y, the others need the flip
    when !gpu(opengl) && !gpu(opengles) {
        o.light_proj_pos.y = 0.0f - o.light_proj_pos.y;
    }
    o.world_pos = mul(p.model, pos);
    float4 n4 = mul(p.model, float4{norm.x, norm.y, norm.z, 0.0f});
    o.world_norm = normalize(float3{n4.x, n4.y, n4.z});
    o.color = p.diff_color;
    return o;
}

@shader fragment
float4 shadows_depthtex_sapp_fs_display(
ShadowsDepthtexSappDisplayOut input,
    @uniform(1) Ub_fs_display_params p,
    @texture(0) Texture2D shadow_map,
    @sampler(0) Sampler shadow_sampler
) {
    f32 spec_power = 2.2f;
    f32 ambient_intensity = 0.25f;
    float3 l = normalize(p.light_dir);
    float3 n = normalize(input.world_norm);
    f32 n_dot_l = dot(n, l);

    float4 c;
    if n_dot_l > 0.0f {
        float3 light_pos = float3{input.light_proj_pos.x / input.light_proj_pos.w,
                                  input.light_proj_pos.y / input.light_proj_pos.w,
                                  input.light_proj_pos.z / input.light_proj_pos.w};
        float2 sm_uv = float2{(light_pos.x + 1.0f) * 0.5f, (light_pos.y + 1.0f) * 0.5f};
        f32 s = sample_cmp(shadow_map, shadow_sampler, sm_uv, light_pos.z);
        f32 diff_intensity = max(n_dot_l * s, 0.0f);

        float3 v = normalize(float3{p.eye_pos.x - input.world_pos.x,
                                    p.eye_pos.y - input.world_pos.y,
                                    p.eye_pos.z - input.world_pos.z});
        float3 r = reflect(float3{0.0f - l.x, 0.0f - l.y, 0.0f - l.z}, n);
        f32 r_dot_v = max(dot(r, v), 0.0f);
        f32 spec_intensity = pow(r_dot_v, spec_power) * n_dot_l * s;

        f32 k = diff_intensity + ambient_intensity;
        c = float4{spec_intensity + k * input.color.x,
                   spec_intensity + k * input.color.y,
                   spec_intensity + k * input.color.z,
                   1.0f};
    } else {
        c = float4{input.color.x * ambient_intensity,
                   input.color.y * ambient_intensity,
                   input.color.z * ambient_intensity,
                   1.0f};
    }
    // gamma
    f32 g = 1.0f / 2.2f;
    return float4{pow(c.x, g), pow(c.y, g), pow(c.z, g), c.w};
}

// --- debug: the shadow map as a plain texture ------------------------
//
// The depth format can't be filtered, so the pair carries upstream's
// @image_sample_type unfilterable_float / @sampler_type nonfiltering.

@shader vertex
ShadowsDepthtexSappDbgOut shadows_depthtex_sapp_vs_dbg(@attr(0) float2 pos) {
    ShadowsDepthtexSappDbgOut o;
    o.pos = float4{pos.x * 2.0f - 1.0f, pos.y * 2.0f - 1.0f, 0.5f, 1.0f};
    o.uv = pos;
    return o;
}

@shader fragment
float4 shadows_depthtex_sapp_fs_dbg(
ShadowsDepthtexSappDbgOut input,
    @texture(0, unfilterable) Texture2D dbg_tex,
    @sampler(0, nonfiltering) Sampler dbg_smp
) {
    f32 d = sample(dbg_tex, dbg_smp, input.uv).x;
    return float4{d, d, d, 1.0f};
}

enum __enum_UB_vs_shadow_params {
    UB_vs_shadow_params = 0,
    UB_vs_display_params = 0,
    UB_fs_display_params = 1,
    VIEW_shadow_map = 0,
    SMP_shadow_sampler = 0,
    VIEW_dbg_tex = 0,
    SMP_dbg_smp = 0,
    ATTR_shadow_pos = 0,
    ATTR_display_pos = 0,
    ATTR_display_norm = 1,
    ATTR_dbg_pos = 0,
    __shim_end = 255,
}

// Replaces the sokol-shdc generated shadows-depthtex-sapp.glsl.h.
struct vs_shadow_params_t {
    mat44_t mvp;
}

/* minc packs a uniform block plainly: diff_color sits at 192, and the
   block rounds to 208. */
struct vs_display_params_t {
    mat44_t mvp;
    mat44_t model;
    mat44_t light_mvp;
    vec3_t diff_color;
    f32 _pad_tail;
}

/* light_dir at 0, eye_pos at 12 (packed, not std140), rounded to 32. */
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
        .colors[0] = {.load_action = SG_LOADACTION_CLEAR, .clear_value = {0.25f, 0.25f, 0.5f, 1.0f}},
    };
    sg_image shadow_map_img = sg_make_image(&sg_image_desc{
        .usage = sg_image_usage{.depth_stencil_attachment = true},
        .width = 2048,
        .height = 2048,
        .pixel_format = SG_PIXELFORMAT_DEPTH,
        .sample_count = 1,
        .label = "shadow-map",
    });
    sg_view shadow_map_ds_view = sg_make_view(&sg_view_desc{
        .depth_stencil_attachment = sg_image_view_desc{.image = shadow_map_img},
        .label = "shadow-map-depth-stencil-view",
    });
    sg_view shadow_map_tex_view = sg_make_view(&sg_view_desc{
        .texture = sg_texture_view_desc{.image = shadow_map_img},
        .label = "shadow-map-tex-view",
    });
    state.shadow.pass = sg_pass{
        .action = sg_pass_action{
            .depth = sg_depth_attachment_action{
                .load_action = SG_LOADACTION_CLEAR,
                .store_action = SG_STOREACTION_STORE,
                .clear_value = 1.0f,
            },
        },
        .attachments = sg_attachments{.depth_stencil = shadow_map_ds_view},
    };
    sg_sampler shadow_sampler = sg_make_sampler(&sg_sampler_desc{
        .min_filter = SG_FILTER_LINEAR,
        .mag_filter = SG_FILTER_LINEAR,
        .wrap_u = SG_WRAP_CLAMP_TO_EDGE,
        .wrap_v = SG_WRAP_CLAMP_TO_EDGE,
        .compare = SG_COMPAREFUNC_LESS,
        .label = "shadow-sampler",
    });
    state.shadow.pip = sg_make_pipeline(&sg_pipeline_desc{
        .layout = sg_vertex_layout_state{
            .buffers[0] = {.stride = cast(i32, 6 * sizeof(f32))},
            .attrs[0] = {.format = SG_VERTEXFORMAT_FLOAT3},
        },
        .shader = sokol_make_shader(&shadows_depthtex_sapp_vs_shadow_shader, &shadows_depthtex_sapp_fs_shadow_shader),
        .index_type = SG_INDEXTYPE_UINT16,
        .cull_mode = SG_CULLMODE_FRONT,
        .sample_count = 1,
        .depth = sg_depth_state{
            .pixel_format = SG_PIXELFORMAT_DEPTH,
            .compare = SG_COMPAREFUNC_LESS_EQUAL,
            .write_enabled = true,
        },
        .colors[0] = {.pixel_format = SG_PIXELFORMAT_NONE},
        .label = "shadow-pipeline",
    });
    state.shadow.bind = sg_bindings{.vertex_buffers[0] = state.vbuf, .index_buffer = state.ibuf};
    state.display.pip = sg_make_pipeline(&sg_pipeline_desc{
        .layout = sg_vertex_layout_state{
            .attrs[0] = {.format = SG_VERTEXFORMAT_FLOAT3},
            .attrs[1] = {.format = SG_VERTEXFORMAT_FLOAT3},
        },
        .shader = sokol_make_shader(&shadows_depthtex_sapp_vs_display_shader, &shadows_depthtex_sapp_fs_display_shader),
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
        .shader = sokol_make_shader(&shadows_depthtex_sapp_vs_dbg_shader, &shadows_depthtex_sapp_fs_dbg_shader),
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
    vec3_t cube_color = vec3(0.5f, 1.0f, 0.5f);
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
        .window_title = "shadows-depthtex-sapp.mc",
        .icon = sapp_icon_desc{.sokol_default = true},
        .logger = sapp_logger{.func = slog_func},
    };
}
