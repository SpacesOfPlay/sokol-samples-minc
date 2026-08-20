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

// vertextexture-sapp.glsl, hand-ported.
//
// An offscreen pass renders 2D simplex-noise plasma into a texture,
// then the display pass synthesizes a 256x256 grid of vertices with no
// vertex buffer at all: each vertex reads its own plasma texel in the
// VERTEX stage and displaces itself by the alpha channel.
//
// Ashima Arts' simplex noise (MIT), transliterated from upstream's
// @block noise_utils. GLSL's wide swizzles are written out
// component-wise, and the two mod289 overloads become mod289_2 /
// mod289_3.

struct Ub_plasma_params {
    f32 time;
}

struct VertextextureSappPlasmaOut {
    float4 pos;
    float2 uv;
}

struct VertextextureSappDisplayOut {
    float4 pos;
    float4 color;
}

float3 mod289_3(float3 x) {
    return x - floor(x * (1.0f / 289.0f)) * 289.0f;
}

float2 mod289_2(float2 x) {
    return x - floor(x * (1.0f / 289.0f)) * 289.0f;
}

float3 permute3(float3 x) {
    return mod289_3(((x * 34.0f) + 1.0f) * x);
}

f32 snoise(float2 v) {
    // (3-sqrt(3))/6, 0.5*(sqrt(3)-1), -1+2*C.x, 1/41
    f32 cx = 0.211324865405187f;
    f32 cy = 0.366025403784439f;
    f32 cz = 0.0f - 0.577350269189626f;
    f32 cw = 0.024390243902439f;

    // first corner
    float2 i = floor(float2{v.x + (v.x * cy + v.y * cy), v.y + (v.x * cy + v.y * cy)});
    float2 x0 = float2{v.x - i.x + (i.x * cx + i.y * cx), v.y - i.y + (i.x * cx + i.y * cx)};

    // other corners
    float2 i1 = x0.x > x0.y ? float2{1.0f, 0.0f} : float2{0.0f, 1.0f};
    float4 x12 = float4{x0.x + cx, x0.y + cx, x0.x + cz, x0.y + cz};
    x12.x = x12.x - i1.x;
    x12.y = x12.y - i1.y;

    // permutations
    i = mod289_2(i);
    float3 p = permute3(permute3(float3{i.y + 0.0f, i.y + i1.y, i.y + 1.0f})
                        + float3{i.x + 0.0f, i.x + i1.x, i.x + 1.0f});

    float3 m = max(float3{0.5f - (x0.x * x0.x + x0.y * x0.y),
                          0.5f - (x12.x * x12.x + x12.y * x12.y),
                          0.5f - (x12.z * x12.z + x12.w * x12.w)},
                   float3{0.0f, 0.0f, 0.0f});
    m = m * m;
    m = m * m;

    // gradients: 41 points uniformly over a line, mapped onto a diamond
    float3 x = float3{2.0f * frac(p.x * cw) - 1.0f,
                      2.0f * frac(p.y * cw) - 1.0f,
                      2.0f * frac(p.z * cw) - 1.0f};
    float3 h = abs(x) - 0.5f;
    float3 ox = floor(x + 0.5f);
    float3 a0 = x - ox;

    // normalise gradients implicitly by scaling m
    m = m * (1.79284291400159f - 0.85373472095314f * (a0 * a0 + h * h));

    float3 g;
    g.x = a0.x * x0.x + h.x * x0.y;
    g.y = a0.y * x12.x + h.y * x12.y;
    g.z = a0.z * x12.z + h.z * x12.w;
    return 130.0f * dot(m, g);
}

// --- offscreen: plasma into a fullscreen triangle -------------------

@shader vertex
VertextextureSappPlasmaOut vertextexture_sapp_vs_plasma() {
    // fullscreen triangle from the vertex index, no vertex buffer
    float2 pos = float2{-1.0f, -1.0f};
    i32 vid = cast(i32, vertex_id());
    if vid == 1 { pos = float2{3.0f, -1.0f}; }
    if vid == 2 { pos = float2{-1.0f, 3.0f}; }
    VertextextureSappPlasmaOut o;
    o.pos = float4{pos.x, pos.y, 0.0f, 1.0f};
    o.uv = float2{(pos.x + 1.0f) * 0.5f, (pos.y + 1.0f) * 0.5f};
    return o;
}

@shader fragment
float4 vertextexture_sapp_fs_plasma(
VertextextureSappPlasmaOut input,
    @uniform(0) Ub_plasma_params plasma_params
) {
    f32 t = plasma_params.time;
    float2 uv = input.uv;
    float2 dx = float2{t, 0.0f};
    float2 dy = float2{0.0f, t};
    float2 dxy = float2{t, t};

    f32 red = snoise(float2{uv.x * 1.5f + dx.x, uv.y * 1.5f + dx.y}) * 0.5f + 0.5f;
    red = red + snoise(float2{uv.x * 5.0f + dx.x, uv.y * 5.0f + dx.y}) * 0.15f;
    red = red + snoise(float2{uv.x * 5.0f + dy.x, uv.y * 5.0f + dy.y}) * 0.15f;

    f32 green = snoise(float2{uv.x * 1.5f + dy.x, uv.y * 1.5f + dy.y}) * 0.5f + 0.5f;
    green = green + snoise(float2{uv.x * 5.0f + dy.x, uv.y * 5.0f + dy.y}) * 0.15f;
    green = green + snoise(float2{uv.x * 5.0f + dx.x, uv.y * 5.0f + dx.y}) * 0.15f;

    f32 blue = snoise(float2{uv.x * 1.5f + dxy.x, uv.y * 1.5f + dxy.y}) * 0.5f + 0.5f;
    blue = blue + snoise(float2{uv.x * 5.0f + dxy.x, uv.y * 5.0f + dxy.y}) * 0.15f;
    blue = blue + snoise(float2{uv.x * 5.0f - dxy.x, uv.y * 5.0f - dxy.y}) * 0.15f;

    f32 height = snoise(float2{uv.x * 3.0f + dxy.x, uv.y * 3.0f + dxy.y}) * 0.5f + 0.5f;
    height = height + snoise(float2{uv.x * 20.0f + dy.x, uv.y * 20.0f + dy.y}) * 0.1f;
    height = height + snoise(float2{uv.x * 20.0f - dy.x, uv.y * 20.0f - dy.y}) * 0.1f;

    return float4{red, green, blue, height * 0.2f};
}

// --- display: vertices synthesized in the vertex shader -------------

@shader vertex
VertextextureSappDisplayOut vertextexture_sapp_vs_display(
    @texture(0) Texture2D tex,
    @sampler(0) Sampler smp,
    @uniform(0) float4x4 mvp
) {
    // restore tile coords from the vertex index
    i32 vid = cast(i32, vertex_id());
    int2 tile_xz = int2{vid & 255, vid >> 8};
    f32 dxz = 2.0f / 256.0f;

    // the plasma value computed in the offscreen pass, in the VERTEX stage
    float4 plasma = tex[tile_xz];

    float4 pos = float4{-1.0f + cast(f32, tile_xz.x) * dxz,
                        plasma.w,
                        -1.0f + cast(f32, tile_xz.y) * dxz,
                        1.0f};
    VertextextureSappDisplayOut o;
    o.pos = mul(mvp, pos);
    o.color = float4{plasma.x, plasma.y, plasma.z, 1.0f};
    return o;
}

@shader fragment
float4 vertextexture_sapp_fs_display(
VertextextureSappDisplayOut input
) {
    return input.color;
}

enum __enum_UB_plasma_params {
    UB_plasma_params = 0,
    UB_vs_params = 0,
    VIEW_tex = 0,
    SMP_smp = 0,
    __shim_end = 255,
}

// Replaces the sokol-shdc generated vertextexture-sapp.glsl.h.
struct plasma_params_t {
    f32 time;
    u8[12] _pad_tail;
}

struct vs_params_t {
    mat44_t mvp;
}

private struct state_t {
    f64 time;
    f32 ry;
    struct {
        sg_image img;
        sg_pipeline pip;
        sg_pass pass;
        plasma_params_t plasma_params;
    } offscreen;
    struct {
        sg_buffer ibuf;
        sg_pipeline pip;
        sg_pass_action pass_action;
        sg_bindings bind;
    } display;
}

// plane number of tiles along edge (don't change this since the value is hardcoded in shader)
private { state_t state; }

private {
void init() {
    sg_setup(&sg_desc{.environment = sglue_environment(), .logger = sg_logger{.func = slog_func}});
    __dbgui_setup();
    state.offscreen.img = sg_make_image(&sg_image_desc{
        .usage = sg_image_usage{.color_attachment = true},
        .width = 256,
        .height = 256,
        .pixel_format = SG_PIXELFORMAT_RGBA8,
        .sample_count = 1,
        .label = "plasma-texture",
    });
    state.offscreen.pass = sg_pass{
        .action = sg_pass_action{.colors[0] = {.load_action = SG_LOADACTION_DONTCARE}},
        .attachments = sg_attachments{
            .colors[0] = sg_make_view(&sg_view_desc{
                .color_attachment = sg_image_view_desc{.image = state.offscreen.img},
                .label = "plasma-texture-attachment",
            }),
        },
    };
    state.offscreen.pip = sg_make_pipeline(&sg_pipeline_desc{
        .shader = sokol_make_shader(&vertextexture_sapp_vs_plasma_shader, &vertextexture_sapp_fs_plasma_shader),
        .colors[0] = {.pixel_format = SG_PIXELFORMAT_RGBA8},
        .depth = sg_depth_state{.pixel_format = SG_PIXELFORMAT_NONE},
        .sample_count = 1,
        .label = "plasma-pipeline",
    });
    {
        u16 tiles = 255;
        var ibuf_size = cast(u64, tiles * tiles * 6 * sizeof(u16));
        u16* indices = alloc(cast(i64, ibuf_size));
        u16* ptr = indices;
        for u16 y = 0; y < tiles; y++ {
            for u16 x = 0; x < tiles; x++ {
                var i0 = cast(u16, y * (tiles + 1) + x);
                var i1 = cast(u16, i0 + 1);
                var i2 = cast(u16, i0 + tiles + 1);
                var i3 = cast(u16, i2 + 1);
                *ptr++ = i0;
                *ptr++ = i1;
                *ptr++ = i3;
                *ptr++ = i0;
                *ptr++ = i3;
                *ptr++ = i2;
            }
        }
        state.display.ibuf = sg_make_buffer(&sg_buffer_desc{
            .usage = sg_buffer_usage{.index_buffer = true},
            .data = sg_range{.ptr = indices, .size = ibuf_size},
            .label = "plane-indices",
        });
        free(indices);
    }
    state.display.pip = sg_make_pipeline(&sg_pipeline_desc{
        .shader = sokol_make_shader(&vertextexture_sapp_vs_display_shader, &vertextexture_sapp_fs_display_shader),
        .index_type = SG_INDEXTYPE_UINT16,
        .cull_mode = SG_CULLMODE_NONE,
        .depth = sg_depth_state{.compare = SG_COMPAREFUNC_LESS_EQUAL, .write_enabled = true},
        .label = "render-pipeline",
    });
    state.display.pass_action = sg_pass_action{
        .colors[0] = {.load_action = SG_LOADACTION_CLEAR, .clear_value = {0.0f, 0.0f, 0.0f, 1.0f}},
    };
    sg_sampler smp = sg_make_sampler(&sg_sampler_desc{
        .min_filter = SG_FILTER_NEAREST,
        .mag_filter = SG_FILTER_NEAREST,
        .label = "plasma-sampler",
    });
    state.display.bind = sg_bindings{
        .index_buffer = state.display.ibuf,
        .views[0] = sg_make_view(&sg_view_desc{
            .texture = sg_texture_view_desc{.image = state.offscreen.img},
            .label = "plasma-texture-view",
        }),
        .samplers[0] = smp,
    };
}

void frame() {
    state.offscreen.plasma_params.time += cast(f32, sapp_frame_duration());
    sg_begin_pass(&state.offscreen.pass);
    sg_apply_pipeline(state.offscreen.pip);
    sg_apply_uniforms(UB_plasma_params, &sg_range{
        &state.offscreen.plasma_params, sizeof(state.offscreen.plasma_params),
    });
    sg_draw(0, 3, 1);
    sg_end_pass();
    i32 num_elements = 255 * 255 * 6;
    vs_params_t vs_params = compute_vsparams();
    sg_begin_pass(&sg_pass{.action = state.display.pass_action, .swapchain = sglue_swapchain()});
    sg_apply_pipeline(state.display.pip);
    sg_apply_bindings(&state.display.bind);
    sg_apply_uniforms(UB_vs_params, &sg_range{&vs_params, sizeof(vs_params)});
    sg_draw(0, num_elements, 1);
    __dbgui_draw();
    sg_end_pass();
    sg_commit();
}

void cleanup() {
    __dbgui_shutdown();
    sg_shutdown();
}

// compute the model-view-projection matrix used in the display pass
vs_params_t compute_vsparams() {
    f32 w = sapp_widthf();
    f32 h = sapp_heightf();
    var t = cast(f32, sapp_frame_duration() * 60.0);
    mat44_t proj = mat44_perspective_fov_rh(vecmath_radians(60.0f), w / h, 0.01f, 10.0f);
    mat44_t view = mat44_look_at_rh(vec3(0.0f, 1.0f, 2.5f), vec3(0.0f, 0.0f, 0.0f), vec3(0.0f, 1.0f, 0.0f));
    mat44_t view_proj = mat44_mul_mat44(view, proj);
    state.ry += 0.5f * t;
    mat44_t model = mat44_rotation_y(vecmath_radians(state.ry));
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
        .sample_count = 4,
        .window_title = "vertextexture-sapp.mc",
        .icon = sapp_icon_desc{.sokol_default = true},
        .logger = sapp_logger{.func = slog_func},
    };
}
