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

// texcube-sapp.glsl - ported to minc @shader.

struct TexcubeSappVsOut {
    float4 pos;
    float4 color;
    float2 uv;
}

@shader vertex
TexcubeSappVsOut texcube_sapp_vs(
    @attr(0) float4 pos,
    @attr(1) float4 color0,
    @attr(2) float2 texcoord0,
    @uniform float4x4 mvp
) {
    TexcubeSappVsOut o;
    o.pos = mul(mvp, pos);
    o.color = color0;
    o.uv = texcoord0 * 5.0f;
    return o;
}

@shader fragment
float4 texcube_sapp_fs(
TexcubeSappVsOut input,
    @texture(0) Texture2D tex,
    @sampler(0) Sampler smp
) {
    return sample(tex, smp, input.uv) * input.color;
}


enum __enum_ATTR_texcube_pos {
    ATTR_texcube_pos = 0,
    ATTR_texcube_color0 = 1,
    ATTR_texcube_texcoord0 = 2,
    UB_vs_params = 0,
    VIEW_tex = 0,
    SMP_smp = 0,
    __shim_end = 255,
}

// Replaces the sokol-shdc generated texcube-sapp.glsl.h.
struct vs_params_t {
    mat44_t mvp;
}

private struct state_t {
    f32 rx;
    f32 ry;
    sg_pass_action pass_action;
    sg_pipeline pip;
    sg_bindings bind;
}

struct vertex_t {
    f32 x;
    f32 y;
    f32 z;
    u32 color;
    i16 u;
    i16 v;
}

private { state_t state; }

private {
void init() {
    sg_setup(&sg_desc{.environment = sglue_environment(), .logger = sg_logger{.func = slog_func}});
    __dbgui_setup();
    vertex_t[24] vertices = {
        vertex_t{-1.0f, -1.0f, -1.0f, 0xFF0000FF, 0, 0},
        vertex_t{1.0f, -1.0f, -1.0f, 0xFF0000FF, 32767, 0},
        vertex_t{1.0f, 1.0f, -1.0f, 0xFF0000FF, 32767, 32767},
        vertex_t{-1.0f, 1.0f, -1.0f, 0xFF0000FF, 0, 32767},
        vertex_t{-1.0f, -1.0f, 1.0f, 0xFF00FF00, 0, 0},
        vertex_t{1.0f, -1.0f, 1.0f, 0xFF00FF00, 32767, 0},
        vertex_t{1.0f, 1.0f, 1.0f, 0xFF00FF00, 32767, 32767},
        vertex_t{-1.0f, 1.0f, 1.0f, 0xFF00FF00, 0, 32767},
        vertex_t{-1.0f, -1.0f, -1.0f, 0xFFFF0000, 0, 0},
        vertex_t{-1.0f, 1.0f, -1.0f, 0xFFFF0000, 32767, 0},
        vertex_t{-1.0f, 1.0f, 1.0f, 0xFFFF0000, 32767, 32767},
        vertex_t{-1.0f, -1.0f, 1.0f, 0xFFFF0000, 0, 32767},
        vertex_t{1.0f, -1.0f, -1.0f, 0xFFFF007F, 0, 0},
        vertex_t{1.0f, 1.0f, -1.0f, 0xFFFF007F, 32767, 0},
        vertex_t{1.0f, 1.0f, 1.0f, 0xFFFF007F, 32767, 32767},
        vertex_t{1.0f, -1.0f, 1.0f, 0xFFFF007F, 0, 32767},
        vertex_t{-1.0f, -1.0f, -1.0f, 0xFFFF7F00, 0, 0},
        vertex_t{-1.0f, -1.0f, 1.0f, 0xFFFF7F00, 32767, 0},
        vertex_t{1.0f, -1.0f, 1.0f, 0xFFFF7F00, 32767, 32767},
        vertex_t{1.0f, -1.0f, -1.0f, 0xFFFF7F00, 0, 32767},
        vertex_t{-1.0f, 1.0f, -1.0f, 0xFF007FFF, 0, 0},
        vertex_t{-1.0f, 1.0f, 1.0f, 0xFF007FFF, 32767, 0},
        vertex_t{1.0f, 1.0f, 1.0f, 0xFF007FFF, 32767, 32767},
        vertex_t{1.0f, 1.0f, -1.0f, 0xFF007FFF, 0, 32767},
    };
    state.bind.vertex_buffers[0] = sg_make_buffer(&sg_buffer_desc{
        .data = sg_range{&vertices, sizeof(vertices)},
        .label = "texcube-vertices",
    });
    u16[36] indices = {
        0, 1, 2, 0, 2, 3, 6, 5, 4, 7, 6, 4, 8, 9, 10, 8, 10, 11, 14, 13, 12, 15, 14, 12, 16, 17, 18,
        16, 18, 19, 22, 21, 20, 23, 22, 20,
    };
    state.bind.index_buffer = sg_make_buffer(&sg_buffer_desc{
        .usage = sg_buffer_usage{.index_buffer = true},
        .data = sg_range{&indices, sizeof(indices)},
        .label = "texcube-indices",
    });
    u32[16] pixels = {
        0xFFFFFFFF, 0xFF000000, 0xFFFFFFFF, 0xFF000000, 0xFF000000, 0xFFFFFFFF, 0xFF000000,
        0xFFFFFFFF, 0xFFFFFFFF, 0xFF000000, 0xFFFFFFFF, 0xFF000000, 0xFF000000, 0xFFFFFFFF,
        0xFF000000, 0xFFFFFFFF,
    };
    sg_image img = sg_make_image(&sg_image_desc{
        .width = 4,
        .height = 4,
        .data = sg_image_data{.mip_levels[0] = sg_range{&pixels, sizeof(pixels)}},
        .label = "texcube-image",
    });
    state.bind.views[VIEW_tex] = sg_make_view(&sg_view_desc{
        .texture = sg_texture_view_desc{.image = img},
        .label = "texcube-texture-view",
    });
    state.bind.samplers[SMP_smp] = sg_make_sampler(&sg_sampler_desc{.label = "texcube-sampler"});
    sg_shader shd = sokol_make_shader(&texcube_sapp_vs_shader, &texcube_sapp_fs_shader);
    state.pip = sg_make_pipeline(&sg_pipeline_desc{
        .layout = sg_vertex_layout_state{
            .attrs[0] = {.format = SG_VERTEXFORMAT_FLOAT3},
            .attrs[1] = {.format = SG_VERTEXFORMAT_UBYTE4N},
            .attrs[2] = {.format = SG_VERTEXFORMAT_SHORT2N},
        },
        .shader = shd,
        .index_type = SG_INDEXTYPE_UINT16,
        .cull_mode = SG_CULLMODE_BACK,
        .depth = sg_depth_state{.compare = SG_COMPAREFUNC_LESS_EQUAL, .write_enabled = true},
        .label = "texcube-pipeline",
    });
    state.pass_action = sg_pass_action{
        .colors[0] = {.load_action = SG_LOADACTION_CLEAR, .clear_value = {0.25f, 0.5f, 0.75f, 1.0f}},
    };
}

void frame() {
    var t = cast(f32, sapp_frame_duration() * 60.0);
    state.rx += 1.0f * t;
    state.ry += 2.0f * t;
    vs_params_t vs_params = compute_vsparams(state.rx, state.ry);
    sg_begin_pass(&sg_pass{.action = state.pass_action, .swapchain = sglue_swapchain()});
    sg_apply_pipeline(state.pip);
    sg_apply_bindings(&state.bind);
    sg_apply_uniforms(UB_vs_params, &sg_range{&vs_params, sizeof(vs_params)});
    sg_draw(0, 36, 1);
    __dbgui_draw();
    sg_end_pass();
    sg_commit();
}

void cleanup() {
    __dbgui_shutdown();
    sg_shutdown();
}

vs_params_t compute_vsparams(f32 rx, f32 ry) {
    f32 w = sapp_widthf();
    f32 h = sapp_heightf();
    mat44_t proj = mat44_perspective_fov_rh(vecmath_radians(60.0f), w / h, 0.01f, 10.0f);
    mat44_t view = mat44_look_at_rh(vec3(0.0f, 1.5f, 4.0f), vec3(0.0f, 0.0f, 0.0f), vec3(0.0f, 1.0f, 0.0f));
    mat44_t view_proj = mat44_mul_mat44(view, proj);
    mat44_t rxm = mat44_rotation_x(vecmath_radians(rx));
    mat44_t rym = mat44_rotation_y(vecmath_radians(ry));
    mat44_t model = mat44_mul_mat44(rym, rxm);
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
        .window_title = "texcube-sapp.mc",
        .icon = sapp_icon_desc{.sokol_default = true},
        .logger = sapp_logger{.func = slog_func},
        .html5 = sapp_html5_desc{.use_emsc_set_main_loop = true},
    };
}
