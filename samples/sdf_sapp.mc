import dbgui;

import sokol_all;
import math;

// force high-dpi, sample entry point is __sapp_sample_main()
sapp_desc sokol_main() {
    sapp_desc d = __sapp_sample_main();
    d.high_dpi = true;
    return d;
}

// sdf-sapp.glsl, signed-distance-field raymarching, hand-ported.
//
// Out-params are pointers here and `&x` at the call site; the shader
// backend lowers them to each dialect's out-param spelling. The
// varying carrying screen position is `uv` rather than upstream's
// `pos`, which would collide with the clip-position field.

struct SdfSappVsOut {
    float4 pos;
    float2 uv;
    float3 eye;
    float3 up;
    float3 right;
    float3 fwd;
}

struct Ub_vs_params {
    f32 aspect;
    f32 time;
}

// eye position, orbiting the center
float3 eye_pos(f32 time, float3 center) {
    return center + float3{sin(time * 0.05f) * 3.0f,
                           sin(time * 0.1f) * 2.0f,
                           cos(time * 0.05f) * 3.0f};
}

void lookat(float3 eye, float3 center, float3 up,
            float3* out_fwd, float3* out_right, float3* out_up) {
    *out_fwd = normalize(center - eye);
    *out_right = normalize(cross(*out_fwd, up));
    *out_up = cross(*out_right, *out_fwd);
}

@shader vertex
SdfSappVsOut sdf_sapp_vs(
    @attr(0) float4 position,
    @uniform(0) Ub_vs_params vs_params
) {
    SdfSappVsOut o;
    o.pos = position;
    o.uv = float2{position.x * vs_params.aspect, position.y};
    float3 center = float3{0.0f, 0.0f, 0.0f};
    float3 up_vec = float3{0.0f, 1.0f, 0.0f};
    o.eye = eye_pos(vs_params.time * 5.0f, center);
    lookat(o.eye, center, up_vec, &o.fwd, &o.right, &o.up);
    return o;
}

f32 sd_sphere(float3 p, f32 s) {
    return length(p) - s;
}

f32 sd_mandelbulb(float3 p, float4* res_color) {
    float3 w = p;
    f32 m = dot(w, w);

    float3 aw = abs(w);
    float4 trap = float4{aw.x, aw.y, aw.z, m};
    f32 dz = 1.0f;

    for i32 i = 0; i < 4; i++ {
        f32 m2 = m * m;
        f32 m4 = m2 * m2;
        dz = 8.0f * sqrt(m4 * m2 * m) * dz + 1.0f;

        f32 x = w.x; f32 x2 = x * x; f32 x4 = x2 * x2;
        f32 y = w.y; f32 y2 = y * y; f32 y4 = y2 * y2;
        f32 z = w.z; f32 z2 = z * z; f32 z4 = z2 * z2;

        f32 k3 = x2 + z2;
        f32 k2 = rsqrt(k3 * k3 * k3 * k3 * k3 * k3 * k3);
        f32 k1 = x4 + y4 + z4 - 6.0f * y2 * z2 - 6.0f * x2 * y2 + 2.0f * z2 * x2;
        f32 k4 = x2 - y2 + z2;

        w.x = p.x + 64.0f * x * y * z * (x2 - z2) * k4 * (x4 - 6.0f * x2 * z2 + z4) * k1 * k2;
        w.y = p.y + 0.0f - 16.0f * y2 * k3 * k4 * k4 + k1 * k1;
        w.z = p.z + 0.0f - 8.0f * y * k4 * (x4 * x4 - 28.0f * x4 * x2 * z2 + 70.0f * x4 * z4
                                            - 28.0f * x2 * z2 * z4 + z4 * z4) * k1 * k2;

        float3 aw2 = abs(w);
        trap = min(trap, float4{aw2.x, aw2.y, aw2.z, m});

        m = dot(w, w);
        if m > 256.0f { break; }
    }
    *res_color = float4{m, trap.y, trap.z, trap.w};
    return 0.25f * log(m) * sqrt(m) / dz;
}

f32 d_scene(float3 p, float4* res_color) {
    f32 d = sd_sphere(p, 1.1f);
    if d < 0.1f {
        d = sd_mandelbulb(p, res_color);
    } else {
        *res_color = float4{0.0f, 0.0f, 0.0f, 0.0f};
    }
    return d;
}

// surface normal estimation
float3 surface_normal(float3 p, f32 dp) {
    f32 eps = 0.001f;
    float4 tra;
    f32 x = d_scene(p + float3{eps, 0.0f, 0.0f}, &tra) - dp;
    f32 y = d_scene(p + float3{0.0f, eps, 0.0f}, &tra) - dp;
    f32 z = d_scene(p + float3{0.0f, 0.0f, eps}, &tra) - dp;
    return normalize(float3{x, y, z});
}

float3 calc_color(float3 ro, float3 rd, f32 t, float4 tra) {
    float3 light1 = float3{0.577f, 0.577f, 0.0f - 0.577f};
    float3 light2 = float3{0.0f - 0.707f, 0.0f, 0.707f};

    float3 pos = ro + rd * t;
    float3 nrm = surface_normal(pos, t);
    float3 hal = normalize(light1 - rd);
    f32 occ = clamp(0.05f * log(tra.x), 0.0f, 1.0f);
    f32 fac = clamp(1.0f + dot(rd, nrm), 0.0f, 1.0f);

    // sun
    f32 dif1 = clamp(dot(light1, nrm), 0.0f, 1.0f);
    f32 spe1 = pow(clamp(dot(nrm, hal), 0.0f, 1.0f), 32.0f) * dif1
             * (0.04f + 0.96f * pow(clamp(1.0f - dot(hal, light1), 0.0f, 1.0f), 5.0f));
    // bounce
    f32 dif2 = clamp(0.5f + 0.5f * dot(light2, nrm), 0.0f, 1.0f) * occ;
    // sky
    f32 dif3 = (0.7f + 0.3f * nrm.y) * (0.2f + 0.8f * occ);

    float3 col = float3{0.01f, 0.01f, 0.01f};
    col = mix(col, float3{0.10f, 0.20f, 0.30f}, clamp(tra.y, 0.0f, 1.0f));
    col = mix(col, float3{0.02f, 0.10f, 0.30f}, clamp(tra.z * tra.z, 0.0f, 1.0f));
    col = mix(col, float3{0.30f, 0.10f, 0.02f}, clamp(pow(tra.w, 6.0f), 0.0f, 1.0f));

    f32 amb = 0.05f + 0.95f * occ;
    f32 sss = 4.0f * fac * occ;
    float3 lin = float3{0.0f, 0.0f, 0.0f};
    lin = lin + float3{1.50f, 1.10f, 0.70f} * (7.0f * dif1);
    lin = lin + float3{0.25f, 0.20f, 0.15f} * (4.0f * dif2);
    lin = lin + float3{0.10f, 0.20f, 0.30f} * (1.5f * dif3);
    lin = lin + float3{0.35f, 0.30f, 0.25f} * (2.5f * amb);
    lin = lin + float3{sss, sss, sss};              // fake SSS
    col = col * lin;
    col = float3{pow(col.x, 0.7f), pow(col.y, 0.9f), pow(col.z, 1.0f)};
    col = col + float3{spe1 * 15.0f, spe1 * 15.0f, spe1 * 15.0f};

    // gamma
    return float3{sqrt(col.x), sqrt(col.y), sqrt(col.z)};
}

@shader fragment
float4 sdf_sapp_fs(SdfSappVsOut input) {
    f32 epsilon = 0.001f;
    f32 focal_length = 1.8f;

    float3 ray_origin = input.eye + input.fwd * focal_length
                      + input.right * input.uv.x + input.up * input.uv.y;
    float3 ray_direction = normalize(ray_origin - input.eye);

    float4 tra;
    float3 rgb = float3{0.10f, 0.20f, 0.30f};
    f32 t = 0.0f;
    for i32 i = 0; i < 96; i++ {
        float3 p = ray_origin + ray_direction * t;
        f32 d = d_scene(p, &tra);
        if d < epsilon {
            rgb = calc_color(p, ray_direction, d, tra);
            break;
        } else {
            f32 fi = cast(f32, i);
            rgb = rgb + float3{0.003f * fi, 0.001f * fi, 0.0f};
        }
        if t > 3.0f { break; }
        t += d;
    }
    return float4{rgb.x, rgb.y, rgb.z, 1.0f};
}

enum __enum_ATTR_sdf_position {
    ATTR_sdf_position = 0,
    UB_vs_params = 0,
    __shim_end = 255,
}

// Replaces the sokol-shdc generated sdf-sapp.glsl.h.
struct vs_params_t {
    f32 aspect;
    f32 time;
    u8[8] _pad_tail;
}

private struct state_t {
    sg_pipeline pip;
    sg_bindings bind;
    sg_pass_action pass_action;
    vs_params_t vs_params;
}

private {
state_t state;

void init() {
    sg_setup(&sg_desc{.environment = sglue_environment(), .logger = sg_logger{.func = slog_func}});
    __dbgui_setup();
    f32[6] fsq_verts = {-1.0f, -3.0f, 3.0f, 1.0f, -1.0f, 1.0f};
    state.bind.vertex_buffers[0] = sg_make_buffer(&sg_buffer_desc{
        .data = sg_range{&fsq_verts, sizeof(fsq_verts)},
        .label = "fsq vertices",
    });
    state.pip = sg_make_pipeline(&sg_pipeline_desc{
        .layout = sg_vertex_layout_state{.attrs[0] = {.format = SG_VERTEXFORMAT_FLOAT2}},
        .shader = sokol_make_shader(&sdf_sapp_vs_shader, &sdf_sapp_fs_shader),
    });
    state.pass_action = sg_pass_action{.colors[0] = {.load_action = SG_LOADACTION_DONTCARE}};
}

void frame() {
    i32 w = sapp_width();
    i32 h = sapp_height();
    state.vs_params.time += cast(f32, sapp_frame_duration());
    state.vs_params.aspect = cast(f32, w) / cast(f32, h);
    sg_begin_pass(&sg_pass{.action = state.pass_action, .swapchain = sglue_swapchain()});
    sg_apply_pipeline(state.pip);
    sg_apply_bindings(&state.bind);
    sg_apply_uniforms(UB_vs_params, &sg_range{&state.vs_params, sizeof(state.vs_params)});
    sg_draw(0, 3, 1);
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
        .width = 512,
        .height = 512,
        .depth_format = SAPP_PIXELFORMAT_NONE,
        .window_title = "sdf-sapp.mc",
        .icon = sapp_icon_desc{.sokol_default = true},
        .logger = sapp_logger{.func = slog_func},
    };
}
