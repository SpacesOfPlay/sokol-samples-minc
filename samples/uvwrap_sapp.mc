import dbgui;

import sokol_all;
import math;

// force high-dpi, sample entry point is __sapp_sample_main()
sapp_desc sokol_main() {
    sapp_desc d = __sapp_sample_main();
    d.high_dpi = true;
    return d;
}

// uvwrap-sapp.glsl - ported to minc @shader.

struct UvwrapSappVsOut {
    float4 pos;
    float2 uv;
}

struct Ub_vs_params {
    float2 offset;
    float2 scale;
}

@shader vertex
UvwrapSappVsOut uvwrap_sapp_vs(
    @attr(0) float4 pos,
    @uniform(0) Ub_vs_params vs_params
) {
    UvwrapSappVsOut o;
    o.pos = float4{pos.xy * vs_params.scale + vs_params.offset, 0.5f, 1.0f};
    o.uv = (pos.xy + 1.0f) - 0.5f;
    return o;
}

@shader fragment
float4 uvwrap_sapp_fs(
UvwrapSappVsOut input,
    @texture(0) Texture2D tex,
    @sampler(0) Sampler smp
) {
    return sample(tex, smp, input.uv);
}


enum __enum_ATTR_uvwrap_pos {
    ATTR_uvwrap_pos = 0,
    UB_vs_params = 0,
    VIEW_tex = 0,
    SMP_smp = 0,
    __shim_end = 255,
}

type __arr_u32_8 = u32[8];
// Replaces the sokol-shdc generated uvwrap-sapp.glsl.h.
struct vs_params_t {
    f32[2] offset;
    f32[2] scale;
}

private struct state_t {
    sg_buffer vbuf;
    sg_view tex_view;
    sg_sampler[5] smp;
    sg_pipeline pip;
    sg_pass_action pass_action;
}

private {
state_t state;

void init() {
    sg_setup(&sg_desc{.environment = sglue_environment(), .logger = sg_logger{.func = slog_func}});
    __dbgui_setup();
    f32[8] quad_vertices = {-1.0f, 1.0f, 1.0f, 1.0f, -1.0f, -1.0f, 1.0f, -1.0f};
    state.vbuf = sg_make_buffer(&sg_buffer_desc{.data = sg_range{&quad_vertices, sizeof(quad_vertices)}});
    u32 o = 0xFF555555;
    u32 W = 0xFFFFFFFF;
    u32 R = 0xFF0000FF;
    u32 G = 0xFF00FF00;
    u32 B = 0xFFFF0000;
    __arr_u32_8[8] test_pixels = {
        {R, R, R, R, G, G, G, G},
        {R, o, o, o, o, o, o, G},
        {R, o, o, o, o, o, o, G},
        {R, o, o, W, W, o, o, G},
        {B, o, o, W, W, o, o, R},
        {B, o, o, o, o, o, o, R},
        {B, o, o, o, o, o, o, R},
        {B, B, B, B, R, R, R, R},
    };
    sg_image img = sg_make_image(&sg_image_desc{
        .width = 8,
        .height = 8,
        .data = sg_image_data{.mip_levels[0] = sg_range{&test_pixels, sizeof(test_pixels)}},
    });
    state.tex_view = sg_make_view(&sg_view_desc{.texture = sg_texture_view_desc{.image = img}});
    for i32 i = SG_WRAP_REPEAT; i <= SG_WRAP_MIRRORED_REPEAT; i++ {
        state.smp[i] = sg_make_sampler(&sg_sampler_desc{
            .wrap_u = cast(sg_wrap, i),
            .wrap_v = cast(sg_wrap, i),
            .border_color = SG_BORDERCOLOR_OPAQUE_BLACK,
        });
    }
    state.pip = sg_make_pipeline(&sg_pipeline_desc{
        .shader = sokol_make_shader(&uvwrap_sapp_vs_shader, &uvwrap_sapp_fs_shader),
        .layout = sg_vertex_layout_state{.attrs[0] = {.format = SG_VERTEXFORMAT_FLOAT2}},
        .primitive_type = SG_PRIMITIVETYPE_TRIANGLE_STRIP,
    });
    state.pass_action = sg_pass_action{
        .colors[0] = {.load_action = SG_LOADACTION_CLEAR, .clear_value = {0.0f, 0.5f, 0.7f, 1.0f}},
    };
}

void frame() {
    sg_begin_pass(&sg_pass{.action = state.pass_action, .swapchain = sglue_swapchain()});
    sg_apply_pipeline(state.pip);
    for i32 i = SG_WRAP_REPEAT; i <= SG_WRAP_MIRRORED_REPEAT; i++ {
        sg_apply_bindings(&sg_bindings{
            .vertex_buffers[0] = state.vbuf,
            .views[0] = state.tex_view,
            .samplers[0] = state.smp[i],
        });
        f32 x_offset = 0.0f;
        f32 y_offset = 0.0f;
        switch i {
            case SG_WRAP_REPEAT: {
                x_offset = -0.5f;
                y_offset = 0.5f;
            }
            case SG_WRAP_CLAMP_TO_EDGE: {
                x_offset = 0.5f;
                y_offset = 0.5f;
            }
            case SG_WRAP_CLAMP_TO_BORDER: {
                x_offset = -0.5f;
                y_offset = -0.5f;
            }
            case SG_WRAP_MIRRORED_REPEAT: {
                x_offset = 0.5f;
                y_offset = -0.5f;
            }
        }
        var vs_params = vs_params_t{.offset = {x_offset, y_offset}, .scale = {0.4f, 0.4f}};
        sg_apply_uniforms(UB_vs_params, &sg_range{&vs_params, sizeof(vs_params)});
        sg_draw(0, 4, 1);
    }
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
        .depth_format = SAPP_PIXELFORMAT_NONE,
        .window_title = "uvwrap-sapp.mc",
        .icon = sapp_icon_desc{.sokol_default = true},
        .logger = sapp_logger{.func = slog_func},
    };
}
