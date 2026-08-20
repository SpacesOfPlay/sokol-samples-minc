import dbgui;
import sokol_debugtext;

import sokol_all;
import math;

// force high-dpi, sample entry point is __sapp_sample_main()
sapp_desc sokol_main() {
    sapp_desc d = __sapp_sample_main();
    d.high_dpi = true;
    return d;
}

// srgb-offscreen-sapp.glsl - ported to minc @shader.

struct SrgbOffscreenSappTriangle_VsOut {
    float4 pos;
    float4 color;
}

const float4[3] colors = {
    float4{1.0f, 0.0f, 0.0f, 1.0f},
    float4{0.0f, 1.0f, 0.0f, 1.0f},
    float4{0.0f, 0.0f, 1.0f, 1.0f},
};
const float2[3] positions = {
    float2{0.0f, 0.5f},
    float2{0.5f, -0.5f},
    float2{-0.5f, -0.5f},
};

@shader vertex
SrgbOffscreenSappTriangle_VsOut srgb_offscreen_sapp_triangle_vs(

) {
    SrgbOffscreenSappTriangle_VsOut o;
    o.pos = float4{positions[vertex_id()], 0.0f, 1.0f};
    o.color = colors[vertex_id()];
    return o;
}

@shader fragment
float4 srgb_offscreen_sapp_triangle_fs(
SrgbOffscreenSappTriangle_VsOut input
) {
    return input.color;
}

struct SrgbOffscreenSappFullscreen_VsOut {
    float4 pos;
    float2 uv;
}

@shader vertex
SrgbOffscreenSappFullscreen_VsOut srgb_offscreen_sapp_fullscreen_vs(

) {
    SrgbOffscreenSappFullscreen_VsOut o;
    f32 x = (vertex_id() & 1) != 0 ? 2.0f : 0.0f;
    f32 y = (vertex_id() & 2) != 0 ? 2.0f : 0.0f;
    o.pos = float4{float2{x, y} * 2.0f - 1.0f, 0.0f, 1.0f};
    o.uv = float2{x, 1.0f - y};
    return o;
}

@shader fragment
float4 srgb_offscreen_sapp_fullscreen_fs(
SrgbOffscreenSappFullscreen_VsOut input,
    @texture(0) Texture2D tex,
    @sampler(0) Sampler smp
) {
    return sample(tex, smp, input.uv);
}


enum __enum_VIEW_tex {
    VIEW_tex = 0,
    SMP_smp = 0,
    __shim_end = 255,
}

private struct state_t {
    struct {
        sg_image img;
        sg_view tex_view;
        sg_pass pass;
        sg_pipeline pip;
    } nomsaa;
    struct {
        sg_image msaa_img;
        sg_image resolve_img;
        sg_view tex_view;
        sg_pass pass;
        sg_pipeline pip;
    } msaa;
    struct {
        sg_pipeline pip;
        sg_sampler smp;
        sg_pass_action pass_action;
    } display;
}

private { state_t state; }

private {
void init() {
    sg_setup(&sg_desc{.environment = sglue_environment(), .logger = sg_logger{.func = slog_func}});
    __dbgui_setup();
    sdtx_setup(&sdtx_desc_t{
        .fonts[0] = sdtx_font_oric(),
        .logger = sdtx_logger_t{.func = slog_func},
    });
    state.display.smp = sg_make_sampler(&sg_sampler_desc{
        .min_filter = SG_FILTER_NEAREST,
        .mag_filter = SG_FILTER_NEAREST,
        .label = "sampler",
    });
    state.display.pip = sg_make_pipeline(&sg_pipeline_desc{
        .shader = sokol_make_shader(&srgb_offscreen_sapp_fullscreen_vs_shader, &srgb_offscreen_sapp_fullscreen_fs_shader),
        .label = "display-pipeline",
    });
    state.display.pass_action = sg_pass_action{.colors[0] = {.load_action = SG_LOADACTION_DONTCARE}};
    sg_shader triangle_shader = sokol_make_shader(&srgb_offscreen_sapp_triangle_vs_shader, &srgb_offscreen_sapp_triangle_fs_shader);
    state.nomsaa.img = sg_make_image(&sg_image_desc{
        .usage = sg_image_usage{.color_attachment = true},
        .width = 256,
        .height = 128,
        .pixel_format = SG_PIXELFORMAT_SRGB8A8,
        .label = "nomsaa-image",
    });
    state.nomsaa.tex_view = sg_make_view(&sg_view_desc{
        .texture = sg_texture_view_desc{.image = state.nomsaa.img},
        .label = "nomsaa-tex-view",
    });
    state.nomsaa.pass = sg_pass{
        .action = sg_pass_action{
            .colors[0] = {
                .load_action = SG_LOADACTION_CLEAR,
                .clear_value = {0.0f, 0.05f, 0.025f, 1.0f},
            },
        },
        .attachments = sg_attachments{
            .colors[0] = sg_make_view(&sg_view_desc{
                .color_attachment = sg_image_view_desc{.image = state.nomsaa.img},
                .label = "nomsaa-att-view",
            }),
        },
        .label = "nomsaa-pass",
    };
    state.nomsaa.pip = sg_make_pipeline(&sg_pipeline_desc{
        .shader = triangle_shader,
        .colors[0] = {.pixel_format = SG_PIXELFORMAT_SRGB8A8},
        .label = "nomsaa-pipeline",
    });
    state.msaa.msaa_img = sg_make_image(&sg_image_desc{
        .usage = sg_image_usage{.color_attachment = true},
        .width = 256,
        .height = 128,
        .pixel_format = SG_PIXELFORMAT_SRGB8A8,
        .sample_count = 4,
        .label = "msaa-image",
    });
    state.msaa.resolve_img = sg_make_image(&sg_image_desc{
        .usage = sg_image_usage{.resolve_attachment = true},
        .width = 256,
        .height = 128,
        .sample_count = 1,
        .pixel_format = SG_PIXELFORMAT_SRGB8A8,
        .label = "msaa-resolve-image",
    });
    state.msaa.tex_view = sg_make_view(&sg_view_desc{
        .texture = sg_texture_view_desc{.image = state.msaa.resolve_img},
        .label = "msaa-tex-view",
    });
    state.msaa.pass = sg_pass{
        .action = sg_pass_action{
            .colors[0] = {
                .load_action = SG_LOADACTION_CLEAR,
                .store_action = SG_STOREACTION_DONTCARE,
                .clear_value = {0.0f, 0.025f, 0.05f, 1.0f},
            },
        },
        .attachments = sg_attachments{
            .colors[0] = sg_make_view(&sg_view_desc{.color_attachment = sg_image_view_desc{.image = state.msaa.msaa_img}}),
            .resolves[0] = sg_make_view(&sg_view_desc{.resolve_attachment = sg_image_view_desc{.image = state.msaa.resolve_img}}),
        },
        .label = "msaa-pass",
    };
    state.msaa.pip = sg_make_pipeline(&sg_pipeline_desc{
        .shader = triangle_shader,
        .sample_count = 4,
        .colors[0] = {.pixel_format = SG_PIXELFORMAT_SRGB8A8},
        .label = "msaa-pipeline",
    });
}

void frame() {
    print_webgl2_note();
    sg_begin_pass(&state.nomsaa.pass);
    sg_apply_pipeline(state.nomsaa.pip);
    sg_draw(0, 3, 1);
    sg_end_pass();
    sg_begin_pass(&state.msaa.pass);
    sg_apply_pipeline(state.msaa.pip);
    sg_draw(0, 3, 1);
    sg_end_pass();
    i32 w = sapp_width();
    i32 wh = w / 2;
    i32 h = sapp_height();
    sg_begin_pass(&sg_pass{.action = state.display.pass_action, .swapchain = sglue_swapchain()});
    sg_apply_pipeline(state.display.pip);
    sg_apply_viewport(0, 0, wh, h, true);
    sg_apply_bindings(&sg_bindings{
        .views[0] = state.nomsaa.tex_view,
        .samplers[0] = state.display.smp,
    });
    sg_draw(0, 3, 1);
    sg_apply_viewport(wh, 0, wh + 1, h, true);
    sg_apply_bindings(&sg_bindings{
        .views[0] = state.msaa.tex_view,
        .samplers[0] = state.display.smp,
    });
    sg_draw(0, 3, 1);
    sg_apply_viewport(0, 0, w, h, true);
    sdtx_draw();
    __dbgui_draw();
    sg_end_pass();
    sg_commit();
}

void cleanup() {
    __dbgui_shutdown();
    sdtx_shutdown();
    sg_shutdown();
}

void print_webgl2_note() {
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
        .srgb = true,
        .window_title = "srgb-offscreen-sapp.mc",
        .icon = sapp_icon_desc{.sokol_default = true},
        .logger = sapp_logger{.func = slog_func},
    };
}
