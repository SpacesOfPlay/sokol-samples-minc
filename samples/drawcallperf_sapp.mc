import dbgui;
import imgui_compat;
import sokol_gfx_imgui;
import sokol_app_imgui;
import sokol_time;
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

// drawcallperf-sapp.glsl, hand-ported. Per-frame view-projection in
// uniform block 0, per-instance world position in block 1, so the
// sample can vary how much uniform traffic each draw call costs.

struct Ub_vs_per_frame {
    float4x4 viewproj;
}

struct Ub_vs_per_instance {
    float4 world_pos;
}

struct DrawcallperfSappVsOut {
    float4 pos;
    float2 uv;
    f32 bright;
}

@shader vertex
DrawcallperfSappVsOut drawcallperf_sapp_vs(
    @attr(0) float3 in_pos,
    @attr(1) float2 in_uv,
    @attr(2) f32 in_bright,
    @uniform(0) Ub_vs_per_frame pf,
    @uniform(1) Ub_vs_per_instance pi
) {
    DrawcallperfSappVsOut o;
    float4 p = float4{pi.world_pos.x + in_pos.x * 0.05f,
                      pi.world_pos.y + in_pos.y * 0.05f,
                      pi.world_pos.z + in_pos.z * 0.05f,
                      pi.world_pos.w + 1.0f};
    o.pos = mul(pf.viewproj, p);
    o.uv = in_uv;
    o.bright = in_bright;
    return o;
}

@shader fragment
float4 drawcallperf_sapp_fs(
    DrawcallperfSappVsOut input,
    @texture(0) Texture2D tex,
    @sampler(0) Sampler smp
) {
    float4 c = sample(tex, smp, input.uv);
    return float4{c.x * input.bright, c.y * input.bright, c.z * input.bright, 1.0f};
}

enum __enum_ATTR_drawcallperf_in_pos {
    ATTR_drawcallperf_in_pos = 0,
    ATTR_drawcallperf_in_uv = 1,
    ATTR_drawcallperf_in_bright = 2,
    UB_vs_per_frame = 0,
    UB_vs_per_instance = 1,
    VIEW_tex = 0,
    SMP_smp = 0,
    __shim_end = 255,
}

type __arr_u32_8 = u32[8];
// Replaces the sokol-shdc generated drawcallperf-sapp.glsl.h.
struct vs_per_frame_t {
    mat44_t viewproj;
}

struct vs_per_instance_t {
    vec4_t world_pos;
}

private struct state_t {
    sg_pass_action pass_action;
    sg_image[3] img;
    sg_view[3] view;
    sg_pipeline pip;
    sg_bindings bind;
    i32 num_instances;
    i32 bind_frequency;
    f32 angle;
    u64 last_time;
    struct {
        i32 num_uniform_updates;
        i32 num_binding_updates;
        i32 num_draw_calls;
    } stats;
    u8* backend;
}

private {
state_t state;
vs_per_instance_t[100000] positions;
}

private {
u32 xorshift32() {
    xorshift32__x ^= xorshift32__x << 13;
    xorshift32__x ^= xorshift32__x >> 17;
    xorshift32__x ^= xorshift32__x << 5;
    return xorshift32__x;
}

vec4_t rand_pos() {
    f32 x = cast(f32, xorshift32() & 0xFFFF) / 65536.0f - 0.5f;
    f32 y = cast(f32, xorshift32() & 0xFFFF) / 65536.0f - 0.5f;
    f32 z = cast(f32, xorshift32() & 0xFFFF) / 65536.0f - 0.5f;
    return vec4_normalize(vec4(x, y, z, 0.0f));
}

void init() {
    stm_setup();
    sg_setup(&sg_desc{
        .environment = sglue_environment(),
        .logger = sg_logger{.func = slog_func},
        .uniform_buffer_size = 100000 * 256 + 1024,
    });
    sgimgui_setup(&sgimgui_desc_t{});
    sappimgui_setup();
    simgui_setup(&simgui_desc_t{.logger = simgui_logger_t{.func = slog_func}});
    state.pass_action = sg_pass_action{
        .colors[0] = {.load_action = SG_LOADACTION_CLEAR, .clear_value = {0.0f, 0.5f, 0.75f, 1.0f}},
    };
    state.num_instances = 100;
    state.bind_frequency = 1000;
    switch sg_query_backend() {
        case SG_BACKEND_GLCORE: {
            state.backend = "GLCORE";
        }
        case SG_BACKEND_GLES3: {
            state.backend = "GLES3";
        }
        case SG_BACKEND_D3D11: {
            state.backend = "D3D11";
        }
        case SG_BACKEND_METAL_IOS: {
            state.backend = "METAL_IOS";
        }
        case SG_BACKEND_METAL_MACOS: {
            state.backend = "METAL_MACOS";
        }
        case SG_BACKEND_METAL_SIMULATOR: {
            state.backend = "METAL_SIMULATOR";
        }
        case SG_BACKEND_WGPU: {
            state.backend = "WGPU";
        }
        case SG_BACKEND_VULKAN: {
            state.backend = "VULKAN";
        }
        case SG_BACKEND_DUMMY: {
            state.backend = "DUMMY";
        }
        default: {
            state.backend = "???";
        }
    }
    state.bind.vertex_buffers[0] = sg_make_buffer(&sg_buffer_desc{.data = sg_range{&init__vertices, sizeof(init__vertices)}});
    state.bind.index_buffer = sg_make_buffer(&sg_buffer_desc{
        .usage = sg_buffer_usage{.index_buffer = true},
        .data = sg_range{&init__indices, sizeof(init__indices)},
    });
    noinit __arr_u32_8[8] pixels;
    for i32 i = 0; i < 3; i++ {
        u32 color;
        switch i {
            case 0: {
                color = 0xFF0000FF;
            }
            case 1: {
                color = 0xFF00FF00;
            }
            default: {
                color = 0xFFFF0000;
            }
        }
        for i32 y = 0; y < 8; y++ {
            for i32 x = 0; x < 8; x++ {
                pixels[y][x] = color;
            }
        }
        state.img[i] = sg_make_image(&sg_image_desc{
            .width = 8,
            .height = 8,
            .pixel_format = SG_PIXELFORMAT_RGBA8,
            .data = sg_image_data{.mip_levels[0] = sg_range{&pixels, sizeof(pixels)}},
        });
        state.view[i] = sg_make_view(&sg_view_desc{.texture = sg_texture_view_desc{.image = state.img[i]}});
    }
    state.bind.samplers[SMP_smp] = sg_make_sampler(&sg_sampler_desc{
        .min_filter = SG_FILTER_NEAREST,
        .mag_filter = SG_FILTER_NEAREST,
    });
    state.pip = sg_make_pipeline(&sg_pipeline_desc{
        .layout = sg_vertex_layout_state{
            .attrs = {
                sg_vertex_attr_state{.format = SG_VERTEXFORMAT_FLOAT3},
                sg_vertex_attr_state{.format = SG_VERTEXFORMAT_FLOAT2},
                sg_vertex_attr_state{.format = SG_VERTEXFORMAT_FLOAT},
                sg_vertex_attr_state{},
                sg_vertex_attr_state{},
                sg_vertex_attr_state{},
                sg_vertex_attr_state{},
                sg_vertex_attr_state{},
                sg_vertex_attr_state{},
                sg_vertex_attr_state{},
                sg_vertex_attr_state{},
                sg_vertex_attr_state{},
                sg_vertex_attr_state{},
                sg_vertex_attr_state{},
                sg_vertex_attr_state{},
                sg_vertex_attr_state{},
            },
        },
        .shader = sokol_make_shader(&drawcallperf_sapp_vs_shader, &drawcallperf_sapp_fs_shader),
        .index_type = SG_INDEXTYPE_UINT16,
        .cull_mode = SG_CULLMODE_BACK,
        .depth = sg_depth_state{.write_enabled = true, .compare = SG_COMPAREFUNC_LESS_EQUAL},
    });
    for i32 i = 0; i < 100000; i++ {
        positions[i].world_pos = rand_pos();
    }
}

mat44_t compute_viewproj() {
    f32 w = sapp_widthf();
    f32 h = sapp_heightf();
    state.angle = fmodf(state.angle + 0.01f, 360.0f);
    f32 dist = 4.5f;
    vec3_t eye = vec3(vecmath_sin(state.angle) * dist, 1.5f, vecmath_cos(state.angle) * dist);
    mat44_t proj = mat44_perspective_fov_rh(vecmath_radians(60.0f), w / h, 0.01f, 10.0f);
    mat44_t view = mat44_look_at_rh(eye, vec3(0.0f, 0.0f, 0.0f), vec3(0.0f, 1.0f, 0.0f));
    return mat44_mul_mat44(view, proj);
}

void frame() {
    drawui();
    if state.num_instances < 1 {
        state.num_instances = 1;
    } else if state.num_instances > 100000 {
        state.num_instances = 100000;
    }
    var vs_per_frame = vs_per_frame_t{.viewproj = compute_viewproj()};
    state.stats.num_uniform_updates = 0;
    state.stats.num_binding_updates = 0;
    state.stats.num_draw_calls = 0;
    sg_begin_pass(&sg_pass{.action = state.pass_action, .swapchain = sglue_swapchain()});
    sg_apply_pipeline(state.pip);
    sg_apply_uniforms(UB_vs_per_frame, &sg_range{&vs_per_frame, sizeof(vs_per_frame)});
    state.stats.num_uniform_updates++;
    state.bind.views[VIEW_tex] = state.view[0];
    sg_apply_bindings(&state.bind);
    state.stats.num_binding_updates++;
    i32 cur_bind_count = 0;
    i32 cur_img = 0;
    for i32 i = 0; i < state.num_instances; i++ {
        if ++cur_bind_count == state.bind_frequency {
            cur_bind_count = 0;
            if cur_img == 3 {
                cur_img = 0;
            }
            state.bind.views[VIEW_tex] = state.view[cur_img++];
            sg_apply_bindings(&state.bind);
            state.stats.num_binding_updates++;
        }
        sg_apply_uniforms(UB_vs_per_instance, &sg_range{&positions[i], sizeof(positions[i])});
        state.stats.num_uniform_updates++;
        sg_draw(0, 36, 1);
        state.stats.num_draw_calls++;
    }
    simgui_render();
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

void drawui() {
    f64 frame_measured_time = stm_sec(stm_laptime(&state.last_time));
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
    ImGui_SetNextWindowPos(ImVec2{20.0f, 20.0f}, ImGuiCond_Once);
    ImGui_SetNextWindowSize(ImVec2{600.0f, 200.0f}, ImGuiCond_Once);
    if ImGui_Begin("Controls", null, ImGuiWindowFlags_NoResize) != 0 {
        ImGui_Text("Each cube/instance is 1 16-byte uniform update and 1 draw call\n");
        ImGui_Text("DC/texture is the number of adjacent draw calls with the same texture binding\n");
        ImGui_SliderInt("Num Instances", &state.num_instances, 100, 100000, "%d", ImGuiSliderFlags_Logarithmic);
        ImGui_SliderInt("DC/texture", &state.bind_frequency, 1, 1000, "%d", ImGuiSliderFlags_Logarithmic);
        ImGui_Text("Backend: %s", state.backend);
        ImGui_Text("Frame duration: %.4fms", frame_measured_time * 1000.0);
        ImGui_Text("sg_apply_bindings(): %d\n", state.stats.num_binding_updates);
        ImGui_Text("sg_apply_uniforms(): %d\n", state.stats.num_uniform_updates);
        ImGui_Text("sg_draw(): %d\n", state.stats.num_draw_calls);
    }
    ImGui_End();
    sgimgui_draw();
    sappimgui_draw();
}
}

sapp_desc __sapp_sample_main() {
    return sapp_desc{
        .init_cb = init,
        .frame_cb = frame,
        .cleanup_cb = cleanup,
        .event_cb = input,
        .width = 1024,
        .height = 768,
        .sample_count = 4,
        .window_title = "drawcallperf-sapp.mc",
        .icon = sapp_icon_desc{.sokol_default = true},
        .logger = sapp_logger{.func = slog_func},
    };
}
private {
u32 xorshift32__x = 0x12345678;
f32[144] init__vertices = {
    -1.0f, -1.0f, -1.0f, 0.0f, 0.0f, 1.0f, 1.0f, -1.0f, -1.0f, 1.0f, 0.0f, 1.0f, 1.0f, 1.0f, -1.0f,
    1.0f, 1.0f, 1.0f, -1.0f, 1.0f, -1.0f, 0.0f, 1.0f, 1.0f, -1.0f, -1.0f, 1.0f, 0.0f, 0.0f, 0.9f,
    1.0f, -1.0f, 1.0f, 1.0f, 0.0f, 0.9f, 1.0f, 1.0f, 1.0f, 1.0f, 1.0f, 0.9f, -1.0f, 1.0f, 1.0f,
    0.0f, 1.0f, 0.9f, -1.0f, -1.0f, -1.0f, 0.0f, 0.0f, 0.8f, -1.0f, 1.0f, -1.0f, 1.0f, 0.0f, 0.8f,
    -1.0f, 1.0f, 1.0f, 1.0f, 1.0f, 0.8f, -1.0f, -1.0f, 1.0f, 0.0f, 1.0f, 0.8f, 1.0f, -1.0f, -1.0f,
    0.0f, 0.0f, 0.7f, 1.0f, 1.0f, -1.0f, 1.0f, 0.0f, 0.7f, 1.0f, 1.0f, 1.0f, 1.0f, 1.0f, 0.7f, 1.0f,
    -1.0f, 1.0f, 0.0f, 1.0f, 0.7f, -1.0f, -1.0f, -1.0f, 0.0f, 0.0f, 0.6f, -1.0f, -1.0f, 1.0f, 1.0f,
    0.0f, 0.6f, 1.0f, -1.0f, 1.0f, 1.0f, 1.0f, 0.6f, 1.0f, -1.0f, -1.0f, 0.0f, 1.0f, 0.6f, -1.0f,
    1.0f, -1.0f, 0.0f, 0.0f, 0.5f, -1.0f, 1.0f, 1.0f, 1.0f, 0.0f, 0.5f, 1.0f, 1.0f, 1.0f, 1.0f,
    1.0f, 0.5f, 1.0f, 1.0f, -1.0f, 0.0f, 1.0f, 0.5f,
};
u16[36] init__indices = {
    0, 1, 2, 0, 2, 3, 6, 5, 4, 7, 6, 4, 8, 9, 10, 8, 10, 11, 14, 13, 12, 15, 14, 12, 16, 17, 18, 16,
    18, 19, 22, 21, 20, 23, 22, 20,
};
}
