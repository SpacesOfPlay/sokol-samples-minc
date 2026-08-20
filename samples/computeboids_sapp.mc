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

// computeboids-sapp.glsl, hand-ported. A boids flocking step in a
// compute shader, double-buffered (read one storage buffer, write the
// other), then an instanced draw that reads the current buffer.
//
// particle is two float2s: std430 aligns a 2-component vector to 8, so
// pos@0 / vel@8 / stride 16, the same as minc's packed layout, and
// the element needs no padding.

struct particle {
    float2 pos;
    float2 vel;
}

struct Ub_sim_params {
    f32 dt;
    f32 rule1_distance;
    f32 rule2_distance;
    f32 rule3_distance;
    f32 rule1_scale;
    f32 rule2_scale;
    f32 rule3_scale;
    i32 num_particles;
}

struct ComputeboidsSappVsOut {
    float4 pos;
    float4 color;
}

@shader compute(64, 1, 1)
void computeboids_sapp_cs(
    @buffer(0) []particle prt_in,
    @rwbuffer(1) []particle prt_out,
    @uniform(0) Ub_sim_params p
) {
    u32 idx = thread_id().x;
    if idx >= cast(u32, p.num_particles) { return; }

    float2 v_pos = prt_in[idx].pos;
    float2 v_vel = prt_in[idx].vel;
    float2 c_mass = float2{0.0f, 0.0f};
    float2 c_vel = float2{0.0f, 0.0f};
    float2 col_vel = float2{0.0f, 0.0f};
    i32 c_mass_count = 0;
    i32 c_vel_count = 0;

    for i32 i = 0; i < p.num_particles; i++ {
        if cast(u32, i) == idx { continue; }
        float2 pos = prt_in[i].pos;
        float2 vel = prt_in[i].vel;
        f32 dist = distance(pos, v_pos);
        if dist < p.rule1_distance {
            c_mass = c_mass + pos;
            c_mass_count++;
        }
        if dist < p.rule2_distance {
            col_vel = col_vel - (pos - v_pos);
        }
        if dist < p.rule3_distance {
            c_vel = c_vel + vel;
            c_vel_count++;
        }
    }
    if c_mass_count > 0 {
        c_mass = c_mass / cast(f32, c_mass_count) - v_pos;
    }
    if c_vel_count > 0 {
        c_vel = c_vel / cast(f32, c_vel_count);
    }
    v_vel = v_vel + c_mass * p.rule1_scale + col_vel * p.rule2_scale
            + c_vel * p.rule3_scale;

    // clamp velocity for a more pleasing simulation
    v_vel = normalize(v_vel) * clamp(length(v_vel), 0.0f, 0.1f);

    // kinematic update, wrapping at the boundary
    v_pos = v_pos + v_vel * p.dt;
    if v_pos.x < 0.0f - 1.0f { v_pos.x = 1.0f; }
    else if v_pos.x > 1.0f { v_pos.x = 0.0f - 1.0f; }
    if v_pos.y < 0.0f - 1.0f { v_pos.y = 1.0f; }
    else if v_pos.y > 1.0f { v_pos.y = 0.0f - 1.0f; }

    prt_out[idx].pos = v_pos;
    prt_out[idx].vel = v_vel;
}

@shader vertex
ComputeboidsSappVsOut computeboids_sapp_vs(@buffer(0) []particle prt) {
    float2[3] verts = {
        float2{0.0f - 0.01f, 0.0f - 0.02f},
        float2{0.01f, 0.0f - 0.02f},
        float2{0.0f, 0.02f},
    };

    float2 v_pos = verts[vertex_id()];
    float2 i_pos = prt[instance_id()].pos;
    float2 i_vel = prt[instance_id()].vel;
    f32 angle = 0.0f - atan2(i_vel.x, i_vel.y);
    float2 pos = float2{
        (v_pos.x * cos(angle)) - (v_pos.y * sin(angle)),
        (v_pos.x * sin(angle)) + (v_pos.y * cos(angle)),
    };

    ComputeboidsSappVsOut o;
    o.pos = float4{pos.x + i_pos.x, pos.y + i_pos.y, 0.0f, 1.0f};
    o.color = float4{
        1.0f - sin(angle + 1.0f) - i_vel.y,
        pos.x * 100.0f - i_vel.y + 0.1f,
        i_vel.x + cos(angle + 0.5f),
        1.0f};
    return o;
}

@shader fragment
float4 computeboids_sapp_fs(ComputeboidsSappVsOut input) {
    return input.color;
}

enum __enum_UB_sim_params {
    UB_sim_params = 0,
    VIEW_cs_ssbo_in = 0,
    VIEW_cs_ssbo_out = 1,
    VIEW_vs_ssbo = 0,
    __shim_end = 255,
}

// Replaces the sokol-shdc generated computeboids-sapp.glsl.h.
//
/* @block common: the storage-buffer element. Two 2-component vectors,
   so std430 and minc's packed layout agree at 16 bytes. */
struct particle_t {
    f32[2] pos;
    f32[2] vel;
}

/* 7 floats + 1 int = 32 bytes, already a multiple of 16. */
struct sim_params_t {
    f32 dt;
    f32 rule1_distance;
    f32 rule2_distance;
    f32 rule3_distance;
    f32 rule1_scale;
    f32 rule2_scale;
    f32 rule3_scale;
    i32 num_particles;
}

private struct state_t {
    sim_params_t sim_params;
    struct {
        sg_buffer[2] buf;
        sg_view[2] view;
        sg_pipeline pip;
    } compute;
    struct {
        sg_pipeline pip;
        sg_pass_action pass_action;
    } display;
}

private {
state_t state = state_t{
    .sim_params = sim_params_t{
        .dt = 0.04f,
        .rule1_distance = 0.1f,
        .rule2_distance = 0.025f,
        .rule3_distance = 0.025f,
        .rule1_scale = 0.02f,
        .rule2_scale = 0.05f,
        .rule3_scale = 0.005f,
        .num_particles = 1500,
    },
    .display = {
        .pass_action = {
            .colors[0] = {
                .load_action = SG_LOADACTION_CLEAR,
                .clear_value = {0.0f, 0.15f, 0.3f, 1.0f},
            },
        },
    },
};
}

private {
u32 xorshift32() {
    xorshift32__x ^= xorshift32__x << 13;
    xorshift32__x ^= xorshift32__x >> 17;
    xorshift32__x ^= xorshift32__x << 5;
    return xorshift32__x;
}

// return a pseudo-random float between -1.0f and +1.0
f32 rnd() {
    return (cast(f32, xorshift32() & 0xFFFF) / cast(f32, 0xFFFF) - 0.5f) * 2.0f;
}

void init() {
    sg_setup(&sg_desc{.environment = sglue_environment(), .logger = sg_logger{.func = slog_func}});
    sappimgui_setup();
    sgimgui_setup(&sgimgui_desc_t{});
    simgui_setup(&simgui_desc_t{.logger = simgui_logger_t{.func = slog_func}});
    {
        var initial_data_size = cast(u64, 10000 * sizeof(particle_t));
        var initial_data = cast(particle_t*, new(u8[initial_data_size]));
        for u64 i = 0; i < 10000; i++ {
            initial_data[i] = particle_t{.pos = {rnd(), rnd()}, .vel = {rnd() * 0.1f, rnd() * 0.1f}};
        }
        for u64 i = 0; i < 2; i++ {
            state.compute.buf[i] = sg_make_buffer(&sg_buffer_desc{
                .usage = sg_buffer_usage{.storage_buffer = true},
                .data = sg_range{.ptr = initial_data, .size = initial_data_size},
                .label = i == 0 ? "particle-buffer-0" : "particle-buffer-1",
            });
            state.compute.view[i] = sg_make_view(&sg_view_desc{
                .storage_buffer = sg_buffer_view_desc{.buffer = state.compute.buf[i]},
                .label = i == 0 ? "particle-view-0" : "particle-view-1",
            });
        }
        free(initial_data);
    }
    state.compute.pip = sg_make_pipeline(&sg_pipeline_desc{
        .compute = true,
        .shader = sokol_make_shader(&computeboids_sapp_cs_shader),
        .label = "compute-pipeline",
    });
    state.display.pip = sg_make_pipeline(&sg_pipeline_desc{
        .shader = sokol_make_shader(&computeboids_sapp_vs_shader, &computeboids_sapp_fs_shader),
        .label = "render-pipeline",
    });
}

void frame() {
    draw_ui();
    sg_view in_view = state.compute.view[sapp_frame_count() & 1];
    sg_view out_view = state.compute.view[sapp_frame_count() + 1 & 1];
    sg_begin_pass(&sg_pass{.compute = true, .label = "compute-pass"});
    sg_apply_pipeline(state.compute.pip);
    sg_apply_bindings(&sg_bindings{
        .views = {
            in_view,
            out_view,
            sg_view{},
            sg_view{},
            sg_view{},
            sg_view{},
            sg_view{},
            sg_view{},
            sg_view{},
            sg_view{},
            sg_view{},
            sg_view{},
            sg_view{},
            sg_view{},
            sg_view{},
            sg_view{},
            sg_view{},
            sg_view{},
            sg_view{},
            sg_view{},
            sg_view{},
            sg_view{},
            sg_view{},
            sg_view{},
            sg_view{},
            sg_view{},
            sg_view{},
            sg_view{},
            sg_view{},
            sg_view{},
            sg_view{},
            sg_view{},
        },
    });
    sg_apply_uniforms(UB_sim_params, &sg_range{&state.sim_params, sizeof(state.sim_params)});
    sg_dispatch((state.sim_params.num_particles + 63) / 64, 1, 1);
    sg_end_pass();
    sg_begin_pass(&sg_pass{.action = state.display.pass_action, .swapchain = sglue_swapchain()});
    sg_apply_pipeline(state.display.pip);
    sg_apply_bindings(&sg_bindings{.views[0] = out_view});
    sg_draw(0, 3, state.sim_params.num_particles);
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

void input(sapp_event* ev) {
    sappimgui_track_event(ev);
    simgui_handle_event(ev);
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
    ImGui_SetNextWindowBgAlpha(0.8f);
    ImGui_SetNextWindowPos(ImVec2{10.0f, 30.0f}, ImGuiCond_Once);
    ImGuiWindowFlags flags = ImGuiWindowFlags_NoDecoration | ImGuiWindowFlags_AlwaysAutoResize | ImGuiWindowFlags_NoBringToFrontOnFocus | ImGuiWindowFlags_NoFocusOnAppearing;
    if ImGui_Begin("controls", null, flags) != 0 {
        ImGui_SliderFloat("Delta T", &state.sim_params.dt, 0.01f, 0.1f);
        ImGui_SliderFloat("Rule1 Distance", &state.sim_params.rule1_distance, 0.0f, 0.2f);
        ImGui_SliderFloat("Rule2 Distance", &state.sim_params.rule2_distance, 0.0f, 0.1f);
        ImGui_SliderFloat("Rule3 Distance", &state.sim_params.rule3_distance, 0.0f, 0.1f);
        ImGui_SliderFloat("Rule1 Scale", &state.sim_params.rule1_scale, 0.0f, 0.1f);
        ImGui_SliderFloat("Rule2 Scale", &state.sim_params.rule2_scale, 0.0f, 0.1f);
        ImGui_SliderFloat("Rule3 Scale", &state.sim_params.rule3_scale, 0.0f, 0.1f);
        ImGui_SliderInt("Num Boids", &state.sim_params.num_particles, 0, 10000);
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
        .width = 800,
        .height = 600,
        .sample_count = 4,
        .depth_format = SAPP_PIXELFORMAT_NONE,
        .window_title = "computeboids-sapp.mc",
        .icon = sapp_icon_desc{.sokol_default = true},
        .logger = sapp_logger{.func = slog_func},
    };
}
private { u32 xorshift32__x = 0x12345678; }
