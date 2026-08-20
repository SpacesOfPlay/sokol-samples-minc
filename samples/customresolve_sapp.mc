// Selects the WebGPU backend on the web. Must come before anything that
// imports sokol_all, directly or through another module, so it is
// emitted ahead of the sample's module imports.
//
// For samples using shader features WebGL2 (GLSL ES 3.0) lacks:
// multisample textures and sample_mask() are ES 3.1 / 3.2. Native
// targets are unaffected.
when os(wasm) {
    @gpu "webgpu"
    @define "SOKOL_WGPU"
}

import dbgui;
import imgui_compat;
import sokol_gfx_imgui;
import sokol_app_imgui;

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

// customresolve-sapp.glsl, hand-ported. Three programs: a triangle
// drawn into a 4x MSAA target, a custom resolve that reads the four
// samples itself, and a display pass.
//
// The MSAA fragment shader writes coverage into alpha, 1 where the
// rasterizer covered every sample, 0 otherwise, and the resolve can
// then either weight the samples or highlight the partly-covered
// pixels.

struct Ub_fs_params {
    f32 weight0;
    f32 weight1;
    f32 weight2;
    f32 weight3;
    i32 coverage;
}

struct CustomresolveSappTriangleOut {
    float4 pos;
    float4 color;
}

struct CustomresolveSappResolveOut {
    float4 pos;
}

struct CustomresolveSappDisplayOut {
    float4 pos;
    float2 uv;
}

// --- MSAA pass --------------------------------------------------------

@shader vertex
CustomresolveSappTriangleOut customresolve_sapp_triangle_vs() {
    float4[3] colors = {
        float4{1.0f, 1.0f, 0.0f, 1.0f},
        float4{0.0f, 1.0f, 1.0f, 1.0f},
        float4{1.0f, 0.0f, 1.0f, 1.0f},
    };
    float3[3] positions = {
        float3{0.0f, 0.6f, 0.0f},
        float3{0.5f, 0.0f - 0.6f, 0.0f},
        float3{0.0f - 0.5f, 0.0f - 0.4f, 0.0f},
    };
    i32 vid = cast(i32, vertex_id());
    float3 p = positions[vid];
    CustomresolveSappTriangleOut o;
    o.pos = float4{p.x, p.y, p.z, 1.0f};
    o.color = colors[vid];
    return o;
}

@shader fragment
float4 customresolve_sapp_triangle_fs(CustomresolveSappTriangleOut input) {
    // alpha carries coverage: 1 only where all four samples are lit
    f32 a = 0.0f;
    if (sample_mask() & 15) == 15 { a = 1.0f; }
    return float4{input.color.x, input.color.y, input.color.z, a};
}

// --- custom resolve ---------------------------------------------------

@shader vertex
CustomresolveSappResolveOut customresolve_sapp_resolve_vs() {
    float3[3] positions = {
        float3{0.0f - 1.0f, 0.0f - 1.0f, 0.0f},
        float3{3.0f, 0.0f - 1.0f, 0.0f},
        float3{0.0f - 1.0f, 3.0f, 0.0f},
    };
    float3 p = positions[cast(i32, vertex_id())];
    CustomresolveSappResolveOut o;
    o.pos = float4{p.x, p.y, p.z, 1.0f};
    return o;
}

@shader fragment
float4 customresolve_sapp_resolve_fs(
    CustomresolveSappResolveOut input,
    @uniform(0) Ub_fs_params p,
    @texture(0) Texture2DMS texms,
    // load_sample() takes no sampler, but the sample binds one at this
    // slot for the pass; declaring it keeps the binding valid.
    @sampler(0) Sampler smp
) {
    float2 fc = frag_coord().xy;
    int2 uv = int2{cast(i32, fc.x), cast(i32, fc.y)};
    float4 s0 = load_sample(texms, uv, 0);
    float4 s1 = load_sample(texms, uv, 1);
    float4 s2 = load_sample(texms, uv, 2);
    float4 s3 = load_sample(texms, uv, 3);

    if p.coverage != 0 {
        // alpha < 4 means the triangle only partly covered this pixel
        if (s0.w + s1.w + s2.w + s3.w) < 4.0f {
            return float4{1.0f, 0.0f, 0.0f, 1.0f};   // complex pixel
        }
        return float4{0.0f, 0.0f, 0.0f, 0.0f};       // simple pixel
    }
    return float4{
        s0.x * p.weight0 + s1.x * p.weight1 + s2.x * p.weight2 + s3.x * p.weight3,
        s0.y * p.weight0 + s1.y * p.weight1 + s2.y * p.weight2 + s3.y * p.weight3,
        s0.z * p.weight0 + s1.z * p.weight1 + s2.z * p.weight2 + s3.z * p.weight3,
        1.0f};
}

// --- display ----------------------------------------------------------

@shader vertex
CustomresolveSappDisplayOut customresolve_sapp_display_vs() {
    float3[3] positions = {
        float3{0.0f - 1.0f, 0.0f - 1.0f, 0.0f},
        float3{3.0f, 0.0f - 1.0f, 0.0f},
        float3{0.0f - 1.0f, 3.0f, 0.0f},
    };
    float3 p = positions[cast(i32, vertex_id())];
    CustomresolveSappDisplayOut o;
    o.pos = float4{p.x, p.y, p.z, 1.0f};
    o.uv = float2{(p.x + 1.0f) * 0.5f, (p.y + 1.0f) * 0.5f};
    return o;
}

@shader fragment
float4 customresolve_sapp_display_fs(
    CustomresolveSappDisplayOut input,
    @texture(0) Texture2D tex,
    @sampler(0) Sampler smp
) {
    return sample(tex, smp, input.uv);
}

enum __enum_UB_fs_params {
    UB_fs_params = 0,
    VIEW_texms = 0,
    SMP_smp = 0,
    VIEW_tex = 0,
    __shim_end = 255,
}

// Replaces the sokol-shdc generated customresolve-sapp.glsl.h.
struct fs_params_t {
    f32 weight0;
    f32 weight1;
    f32 weight2;
    f32 weight3;
    i32 coverage;
    u8[12] _pad_tail;
}

private struct state_t {
    struct {
        sg_image img;
        sg_view tex_view;
        sg_pipeline pip;
        sg_pass pass;
    } msaa;
    struct {
        sg_image img;
        sg_view tex_view;
        sg_pipeline pip;
        sg_pass pass;
        sg_bindings bind;
        fs_params_t fs_params;
    } resolve;
    struct {
        sg_pipeline pip;
        sg_pass_action action;
        sg_bindings bind;
    } display;
    sg_sampler smp;
}

private { state_t state; }
fs_params_t default_weights = fs_params_t{
    .weight0 = 0.25f,
    .weight1 = 0.25f,
    .weight2 = 0.25f,
    .weight3 = 0.25f,
};

private {
void init() {
    sg_setup(&sg_desc{.environment = sglue_environment(), .logger = sg_logger{.func = slog_func}});
    sgimgui_setup(&sgimgui_desc_t{});
    sappimgui_setup();
    simgui_setup(&simgui_desc_t{.logger = simgui_logger_t{.func = slog_func}});
    if sg_query_features().msaa_texture_bindings == 0 {
        return;
    }
    state.smp = sg_make_sampler(&sg_sampler_desc{
        .min_filter = SG_FILTER_NEAREST,
        .mag_filter = SG_FILTER_NEAREST,
    });
    state.msaa.img = sg_make_image(&sg_image_desc{
        .usage = sg_image_usage{.color_attachment = true},
        .width = 160,
        .height = 120,
        .pixel_format = SG_PIXELFORMAT_RGBA8,
        .sample_count = 4,
        .label = "msaa-image",
    });
    state.msaa.tex_view = sg_make_view(&sg_view_desc{
        .texture = sg_texture_view_desc{.image = state.msaa.img},
        .label = "msaa-texture-view",
    });
    state.msaa.pip = sg_make_pipeline(&sg_pipeline_desc{
        .shader = sokol_make_shader(&customresolve_sapp_triangle_vs_shader, &customresolve_sapp_triangle_fs_shader),
        .sample_count = 4,
        .depth = sg_depth_state{.pixel_format = SG_PIXELFORMAT_NONE},
        .colors[0] = {.pixel_format = SG_PIXELFORMAT_RGBA8},
        .label = "msaa-pipeline",
    });
    state.msaa.pass = sg_pass{
        .action = sg_pass_action{
            .colors[0] = {
                .load_action = SG_LOADACTION_CLEAR,
                .store_action = SG_STOREACTION_STORE,
                .clear_value = {0.0f, 0.0f, 0.0f, 1.0f},
            },
        },
        .attachments = sg_attachments{
            .colors[0] = sg_make_view(&sg_view_desc{
                .color_attachment = sg_image_view_desc{.image = state.msaa.img},
                .label = "msaa-attachment-view",
            }),
        },
    };
    state.resolve.img = sg_make_image(&sg_image_desc{
        .usage = sg_image_usage{.color_attachment = true},
        .width = 160,
        .height = 120,
        .pixel_format = SG_PIXELFORMAT_RGBA8,
        .sample_count = 1,
        .label = "resolve-image",
    });
    state.resolve.tex_view = sg_make_view(&sg_view_desc{
        .texture = sg_texture_view_desc{.image = state.resolve.img},
        .label = "resolve-texture-view",
    });
    state.resolve.pip = sg_make_pipeline(&sg_pipeline_desc{
        .shader = sokol_make_shader(&customresolve_sapp_resolve_vs_shader, &customresolve_sapp_resolve_fs_shader),
        .sample_count = 1,
        .depth = sg_depth_state{.pixel_format = SG_PIXELFORMAT_NONE},
        .colors[0] = {.pixel_format = SG_PIXELFORMAT_RGBA8},
        .label = "resolve-pipeline",
    });
    state.resolve.pass = sg_pass{
        .action = sg_pass_action{
            .colors[0] = {
                .load_action = SG_LOADACTION_DONTCARE,
                .store_action = SG_STOREACTION_STORE,
            },
        },
        .attachments = sg_attachments{
            .colors[0] = sg_make_view(&sg_view_desc{
                .color_attachment = sg_image_view_desc{.image = state.resolve.img},
                .label = "resolve-attachments-view",
            }),
        },
    };
    state.resolve.bind = sg_bindings{.views[0] = state.msaa.tex_view, .samplers[0] = state.smp};
    state.resolve.fs_params = default_weights;
    state.display.pip = sg_make_pipeline(&sg_pipeline_desc{
        .shader = sokol_make_shader(&customresolve_sapp_display_vs_shader, &customresolve_sapp_display_fs_shader),
        .label = "display pipeline",
    });
    state.display.action = sg_pass_action{.colors[0] = {.load_action = SG_LOADACTION_DONTCARE}};
    state.display.bind = sg_bindings{.views[0] = state.resolve.tex_view, .samplers[0] = state.smp};
}

void frame() {
    draw_ui();
    if sg_query_features().msaa_texture_bindings == 0 {
        draw_fallback();
        return;
    }
    sg_begin_pass(&state.msaa.pass);
    sg_apply_pipeline(state.msaa.pip);
    sg_draw(0, 3, 1);
    sg_end_pass();
    sg_begin_pass(&state.resolve.pass);
    sg_apply_pipeline(state.resolve.pip);
    sg_apply_bindings(&state.resolve.bind);
    sg_apply_uniforms(UB_fs_params, &sg_range{&state.resolve.fs_params, sizeof(state.resolve.fs_params)});
    sg_draw(0, 3, 1);
    sg_end_pass();
    sg_begin_pass(&sg_pass{.action = state.display.action, .swapchain = sglue_swapchain()});
    sg_apply_pipeline(state.display.pip);
    sg_apply_bindings(&state.display.bind);
    sg_draw(0, 3, 1);
    simgui_render();
    sg_end_pass();
    sg_commit();
}

void cleanup() {
    sappimgui_shutdown();
    sgimgui_shutdown();
    simgui_shutdown();
    sg_shutdown();
}

void draw_ui() {
    sappimgui_track_frame();
    simgui_new_frame(&simgui_frame_desc_t{
        .width = sapp_width(),
        .height = sapp_height(),
        .dpi_scale = sapp_dpi_scale(),
        .delta_time = sapp_frame_duration(),
    });
    if ImGui_BeginMainMenuBar() != 0 {
        sgimgui_draw_menu("sokol-gfx");
        sappimgui_draw_menu("sokol-app");
        ImGui_EndMainMenuBar();
    }
    sgimgui_draw();
    sappimgui_draw();
    ImGui_SetNextWindowPos(ImVec2{10.0f, 20.0f}, ImGuiCond_Once);
    if ImGui_Begin("#window", null, ImGuiWindowFlags_NoDecoration | ImGuiWindowFlags_AlwaysAutoResize | ImGuiWindowFlags_NoBackground) != 0 {
        if sg_query_features().msaa_texture_bindings != 0 {
            ImGui_Text("Sample Weights:");
            ImGui_SliderFloat("0", &state.resolve.fs_params.weight0, 0.0f, 1.0f, "%.2f", 0);
            ImGui_SliderFloat("1", &state.resolve.fs_params.weight1, 0.0f, 1.0f, "%.2f", 0);
            ImGui_SliderFloat("2", &state.resolve.fs_params.weight2, 0.0f, 1.0f, "%.2f", 0);
            ImGui_SliderFloat("3", &state.resolve.fs_params.weight3, 0.0f, 1.0f, "%.2f", 0);
            ImGui_CheckboxFlags("show complex pixels", &state.resolve.fs_params.coverage, 1);
            if ImGui_Button("Reset") != 0 {
                state.resolve.fs_params = default_weights;
            }
        } else {
            ImGui_Text("MSAA TEXTURES NOT SUPPORTED ON WEBGL2/GLES3/macOS+GL");
        }
    }
    ImGui_End();
}

void draw_fallback() {
    sg_begin_pass(&sg_pass{
        .action = sg_pass_action{
            .colors[0] = {
                .load_action = SG_LOADACTION_CLEAR,
                .clear_value = {0.5f, 0.0f, 0.0f, 1.0f},
            },
        },
        .swapchain = sglue_swapchain(),
    });
    simgui_render();
    sg_end_pass();
    sg_commit();
}

void input(sapp_event* ev) {
    sappimgui_track_event(ev);
    simgui_handle_event(ev);
}
}

sapp_desc __sapp_sample_main() {
    return sapp_desc{
        .init_cb = init,
        .frame_cb = frame,
        .cleanup_cb = cleanup,
        .event_cb = input,
        .width = 640,
        .height = 480,
        .sample_count = 1,
        .depth_format = SAPP_PIXELFORMAT_NONE,
        .window_title = "customresolve-sapp.mc",
        .icon = sapp_icon_desc{.sokol_default = true},
        .logger = sapp_logger{.func = slog_func},
    };
}
