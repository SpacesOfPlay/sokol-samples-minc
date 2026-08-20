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

// dyntex3d-sapp.glsl, hand-ported. A full-screen-ish quad built from
// the vertex index alone, sampling a 3D texture at depth `w`.

struct Ub_vs_params {
    f32 w;
}

struct Dyntex3DSappVsOut {
    float4 pos;
    float3 uvw;
}

@shader vertex
Dyntex3DSappVsOut dyntex3d_sapp_vs(@uniform(0) Ub_vs_params p) {
    float2[4] vertices = {
        float2{0.0f, 0.0f},
        float2{1.0f, 0.0f},
        float2{1.0f, 1.0f},
        float2{0.0f, 1.0f},
    };
    i32[6] indices = {0, 1, 2, 2, 3, 0};

    Dyntex3DSappVsOut o;
    i32 idx = indices[vertex_id()];
    float2 v = vertices[idx];
    o.pos = float4{v.x - 0.5f, v.y - 0.5f, 0.5f, 1.0f};
    o.uvw = float3{v.x, v.y, p.w};
    return o;
}

@shader fragment
float4 dyntex3d_sapp_fs(
    Dyntex3DSappVsOut input,
    @texture(0) Texture3D tex,
    @sampler(0) Sampler smp
) {
    return sample(tex, smp, input.uvw);
}

enum __enum_UB_vs_params {
    UB_vs_params = 0,
    VIEW_tex = 0,
    SMP_smp = 0,
    __shim_end = 255,
}

// Replaces the sokol-shdc generated dyntex3d-sapp.glsl.h.
struct vs_params_t {
    f32 w;
    u8[12] _pad_tail;
}

private struct state_t {
    sg_pass_action pass_action;
    sg_pipeline pip;
    sg_image img;
    sg_view texview;
    sg_bindings bind;
    i32 width_height;
    bool immutable;
}

private {
state_t state = state_t{.width_height = 16, .immutable = false};
u32[196608] pixels;
}

private {
void init() {
    sg_setup(&sg_desc{.environment = sglue_environment(), .logger = sg_logger{.func = slog_func}});
    simgui_setup(&simgui_desc_t{.logger = simgui_logger_t{.func = slog_func}});
    sgimgui_setup(&sgimgui_desc_t{});
    sappimgui_setup();
    state.pass_action = sg_pass_action{
        .colors[0] = {.load_action = SG_LOADACTION_CLEAR, .clear_value = {0.0f, 0.0f, 0.0f, 1.0f}},
    };
    state.pip = sg_make_pipeline(&sg_pipeline_desc{
        .shader = sokol_make_shader(&dyntex3d_sapp_vs_shader, &dyntex3d_sapp_fs_shader),
        .primitive_type = SG_PRIMITIVETYPE_TRIANGLE_STRIP,
        .colors[0] = {
            .blend = {
                .enabled = true,
                .src_factor_rgb = SG_BLENDFACTOR_SRC_ALPHA,
                .dst_factor_rgb = SG_BLENDFACTOR_ONE_MINUS_SRC_ALPHA,
            },
        },
        .label = "pipeline",
    });
    state.img = sg_alloc_image();
    state.texview = sg_alloc_view();
    state.bind.views[VIEW_tex] = state.texview;
    recreate_image();
    state.bind.samplers[SMP_smp] = sg_make_sampler(&sg_sampler_desc{
        .min_filter = SG_FILTER_NEAREST,
        .mag_filter = SG_FILTER_NEAREST,
        .wrap_u = SG_WRAP_CLAMP_TO_EDGE,
        .wrap_v = SG_WRAP_CLAMP_TO_EDGE,
        .wrap_w = SG_WRAP_CLAMP_TO_EDGE,
        .label = "sampler",
    });
}

void frame() {
    if state.immutable == 0 {
        update_pixels(sapp_frame_count());
        sg_update_image(state.img, &sg_image_data{.mip_levels[0] = pixels_as_range()});
    }
    sg_begin_pass(&sg_pass{.action = state.pass_action, .swapchain = sglue_swapchain()});
    sg_apply_pipeline(state.pip);
    sg_apply_bindings(&state.bind);
    for i32 slice = 0; slice < 3; slice++ {
        var vs_params = vs_params_t{.w = 0.1f + cast(f32, slice) / 3.0f};
        sg_apply_uniforms(UB_vs_params, &sg_range{&vs_params, sizeof(vs_params)});
        sg_draw(0, 6, 1);
    }
    draw_ui();
    sg_end_pass();
    sg_commit();
}

void input(sapp_event* ev) {
    sappimgui_track_event(ev);
    simgui_handle_event(ev);
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
        .delta_time = sapp_frame_duration(),
        .dpi_scale = sapp_dpi_scale(),
    });
    if ImGui_BeginMainMenuBar() != 0 {
        sgimgui_draw_menu("sokol-gfx");
        sappimgui_draw_menu("sokol-app");
        ImGui_EndMainMenuBar();
    }
    ImGui_SetNextWindowPos(ImVec2{20.0f, 40.0f}, ImGuiCond_Once);
    ImGui_SetNextWindowSize(ImVec2{220.0f, 150.0f}, ImGuiCond_Once);
    ImGui_SetNextWindowBgAlpha(0.35f);
    if ImGui_Begin("Controls", null, ImGuiWindowFlags_NoDecoration | ImGuiWindowFlags_AlwaysAutoResize) != 0 {
        if ImGui_SliderInt("Size", &state.width_height, 16, 256, "%d", ImGuiSliderFlags_Logarithmic) != 0 {
            recreate_image();
        }
        if ImGui_Checkbox("Immutable", &state.immutable) != 0 {
            recreate_image();
        }
    }
    ImGui_End();
    sgimgui_draw();
    sappimgui_draw();
    simgui_render();
}

sg_range pixels_as_range() {
    return sg_range{
        .ptr = pixels,
        .size = 3 * cast(u64, state.width_height * state.width_height) * cast(u64, sizeof(u32)),
    };
}

void recreate_image() {
    if sg_query_image_state(state.img) == SG_RESOURCESTATE_VALID {
        sg_uninit_image(state.img);
        sg_uninit_view(state.texview);
    }
    update_pixels(sapp_frame_count());
    sg_init_image(state.img, &sg_image_desc{
        .type = SG_IMAGETYPE_3D,
        .usage = sg_image_usage{.immutable = state.immutable, .stream_update = !state.immutable},
        .width = state.width_height,
        .height = state.width_height,
        .num_slices = 3,
        .num_mipmaps = 1,
        .pixel_format = SG_PIXELFORMAT_RGBA8,
        .data = sg_image_data{.mip_levels[0] = state.immutable != 0 ? pixels_as_range() : sg_range{}},
        .label = "image",
    });
    sg_init_view(state.texview, &sg_view_desc{
        .texture = sg_texture_view_desc{.image = state.img},
        .label = "texture-view",
    });
}

// put these into macros instead of functions so we don't get an unused warning in release mode
void set_pixel(i32 x, i32 y, i32 z, u32 color) {
    i32 wh = state.width_height;
    pixels[z * wh * wh + y * wh + x] = color;
}

void hori_line(i32 x0, i32 y, i32 z, i32 len, u32 color) {
    for i32 x = x0; x < x0 + len; x++ {
        set_pixel(x, y, z, color);
    }
}

void vert_line(i32 x, i32 y0, i32 z, i32 len, u32 color) {
    for i32 y = y0; y < y0 + len; y++ {
        set_pixel(x, y, z, color);
    }
}

void border(i32 offset, i32 z, u32 color) {
    i32 wh = state.width_height;
    hori_line(offset, offset, z, wh - 2 * offset, color);
    hori_line(offset, wh - 1 - offset, z, wh - 2 * offset, color);
    vert_line(offset, offset, z, wh - 2 * offset, color);
    vert_line(wh - 1 - offset, offset, z, wh - 2 * offset, color);
}

void update_pixels(u64 frame_count) {
    memset(pixels, 0, cast(u64, sizeof(pixels)));
    i32 wh = state.width_height;
    for i32 i = 0; i < 3; i++ {
        border(i, i, update_pixels__colors[i]);
        i32 len = wh - 2 * i;
        i32 z = i;
        {
            i32 x = i;
            i32 y = cast(i32, frame_count / 8 % cast(u64, len)) + i;
            hori_line(x, y, z, len, update_pixels__colors[i]);
        }
        {
            i32 y = i;
            i32 x = cast(i32, frame_count / 8 % cast(u64, len)) + i;
            vert_line(x, y, z, len, update_pixels__colors[i]);
        }
    }
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
        .window_title = "dyntex3d-sapp.mc",
        .icon = sapp_icon_desc{.sokol_default = true},
        .logger = sapp_logger{.func = slog_func},
    };
}
private { u32[3] update_pixels__colors = {0xFF0000FF, 0xFF00FF00, 0xFFFF0000}; }
