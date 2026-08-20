import dbgui;
import imgui_compat;
import sokol_gl;
import vecmath;

// sapp samples that use Dear ImGui
import sokol_all;
import imgui;
import sokol_imgui;
import math;

// Keeps upstream's high_dpi default (off, so sapp_dpi_scale() is 1 and
// framebuffer pixels equal ImGui points). For samples that feed
// sapp_width()/sapp_height() straight into ImGui coordinates; with
// high-dpi on, io.DisplaySize is width / dpi_scale and those windows
// land off-screen toward the bottom right.
sapp_desc sokol_main() {
    return __sapp_sample_main();
}

// imgui-usercallback-sapp.glsl, hand-ported. Flat-shaded geometry
// drawn from an ImGui draw-list user callback.

struct Ub_vs_params {
    float4x4 mvp;
}

struct ImguiUsercallbackSappVsOut {
    float4 pos;
    float4 color;
}

@shader vertex
ImguiUsercallbackSappVsOut imgui_usercallback_sapp_vs(
    @attr(0) float4 position,
    @attr(1) float4 color0,
    @uniform(0) Ub_vs_params p
) {
    ImguiUsercallbackSappVsOut o;
    o.pos = mul(p.mvp, position);
    o.color = color0;
    return o;
}

@shader fragment
float4 imgui_usercallback_sapp_fs(ImguiUsercallbackSappVsOut input) {
    return input.color;
}

enum __enum_ATTR_scene_position {
    ATTR_scene_position = 0,
    ATTR_scene_color0 = 1,
    UB_vs_params = 0,
    __shim_end = 255,
}

// Replaces the sokol-shdc generated imgui-usercallback-sapp.glsl.h.
struct vs_params_t {
    mat44_t mvp;
}

private struct state_t {
    sg_pass_action default_pass_action;
    struct {
        f32 rx;
        f32 ry;
        sg_pass_action pass_action;
        sg_pipeline pip;
        sg_bindings bind;
    } scene1;
    struct {
        f32 r0;
        f32 r1;
        sgl_pipeline pip;
    } scene2;
}

// global application state
private {
state_t state;
// vertices and indices for rendering a cube via sokol-gfx
f32[168] cube_vertices = {
    -1.0f, -1.0f, -1.0f, 1.0f, 0.0f, 0.0f, 1.0f, 1.0f, -1.0f, -1.0f, 1.0f, 0.0f, 0.0f, 1.0f, 1.0f,
    1.0f, -1.0f, 1.0f, 0.0f, 0.0f, 1.0f, -1.0f, 1.0f, -1.0f, 1.0f, 0.0f, 0.0f, 1.0f, -1.0f, -1.0f,
    1.0f, 0.0f, 1.0f, 0.0f, 1.0f, 1.0f, -1.0f, 1.0f, 0.0f, 1.0f, 0.0f, 1.0f, 1.0f, 1.0f, 1.0f, 0.0f,
    1.0f, 0.0f, 1.0f, -1.0f, 1.0f, 1.0f, 0.0f, 1.0f, 0.0f, 1.0f, -1.0f, -1.0f, -1.0f, 0.0f, 0.0f,
    1.0f, 1.0f, -1.0f, 1.0f, -1.0f, 0.0f, 0.0f, 1.0f, 1.0f, -1.0f, 1.0f, 1.0f, 0.0f, 0.0f, 1.0f,
    1.0f, -1.0f, -1.0f, 1.0f, 0.0f, 0.0f, 1.0f, 1.0f, 1.0f, -1.0f, -1.0f, 1.0f, 0.5f, 0.0f, 1.0f,
    1.0f, 1.0f, -1.0f, 1.0f, 0.5f, 0.0f, 1.0f, 1.0f, 1.0f, 1.0f, 1.0f, 0.5f, 0.0f, 1.0f, 1.0f,
    -1.0f, 1.0f, 1.0f, 0.5f, 0.0f, 1.0f, -1.0f, -1.0f, -1.0f, 0.0f, 0.5f, 1.0f, 1.0f, -1.0f, -1.0f,
    1.0f, 0.0f, 0.5f, 1.0f, 1.0f, 1.0f, -1.0f, 1.0f, 0.0f, 0.5f, 1.0f, 1.0f, 1.0f, -1.0f, -1.0f,
    0.0f, 0.5f, 1.0f, 1.0f, -1.0f, 1.0f, -1.0f, 1.0f, 0.0f, 0.5f, 1.0f, -1.0f, 1.0f, 1.0f, 1.0f,
    0.0f, 0.5f, 1.0f, 1.0f, 1.0f, 1.0f, 1.0f, 0.0f, 0.5f, 1.0f, 1.0f, 1.0f, -1.0f, 1.0f, 0.0f, 0.5f,
    1.0f,
};
u16[36] cube_indices = {
    0, 1, 2, 0, 2, 3, 6, 5, 4, 7, 6, 4, 8, 9, 10, 8, 10, 11, 14, 13, 12, 15, 14, 12, 16, 17, 18, 16,
    18, 19, 22, 21, 20, 23, 22, 20,
};

void init() {
    sg_setup(&sg_desc{.environment = sglue_environment(), .logger = sg_logger{.func = slog_func}});
    simgui_setup(&simgui_desc_t{.logger = simgui_logger_t{.func = slog_func}});
    sgl_setup(&sgl_desc_t{.logger = sgl_logger_t{.func = slog_func}});
    state.default_pass_action = sg_pass_action{
        .colors[0] = {.load_action = SG_LOADACTION_CLEAR, .clear_value = {0.0f, 0.5f, 0.7f, 1.0f}},
    };
    {
        state.scene1.bind.vertex_buffers[0] = sg_make_buffer(&sg_buffer_desc{
            .data = sg_range{&cube_vertices, sizeof(cube_vertices)},
            .label = "cube-vertices",
        });
        state.scene1.bind.index_buffer = sg_make_buffer(&sg_buffer_desc{
            .usage = sg_buffer_usage{.index_buffer = true},
            .data = sg_range{&cube_indices, sizeof(cube_indices)},
            .label = "cube-indices",
        });
        state.scene1.pip = sg_make_pipeline(&sg_pipeline_desc{
            .layout = sg_vertex_layout_state{
                .attrs[0] = {.format = SG_VERTEXFORMAT_FLOAT3},
                .attrs[1] = {.format = SG_VERTEXFORMAT_FLOAT4},
            },
            .shader = sokol_make_shader(&imgui_usercallback_sapp_vs_shader, &imgui_usercallback_sapp_fs_shader),
            .index_type = SG_INDEXTYPE_UINT16,
            .depth = sg_depth_state{.compare = SG_COMPAREFUNC_LESS_EQUAL, .write_enabled = true},
            .cull_mode = SG_CULLMODE_BACK,
            .label = "cube-pipeline",
        });
    }
    {
        state.scene2.pip = sgl_make_pipeline(&sg_pipeline_desc{
            .depth = sg_depth_state{.write_enabled = true, .compare = SG_COMPAREFUNC_LESS_EQUAL},
            .cull_mode = SG_CULLMODE_BACK,
        });
    }
}

// an ImGui draw callback to render directly with sokol-gfx
void draw_scene_1(ImDrawList* dl, ImDrawCmd* cmd) {
    ignore dl;
    var cx = cast(i32, cmd.ClipRect.x);
    var cy = cast(i32, cmd.ClipRect.y);
    var cw = cast(i32, cmd.ClipRect.z - cmd.ClipRect.x);
    var ch = cast(i32, cmd.ClipRect.w - cmd.ClipRect.y);
    sg_apply_scissor_rect(cx, cy, cw, ch, true);
    sg_apply_viewport(cx, cy, 360, 360, true);
    var t = cast(f32, sapp_frame_duration() * 60.0);
    mat44_t proj = mat44_perspective_fov_rh(vecmath_radians(60.0f), 1.0f, 0.01f, 10.0f);
    mat44_t view = mat44_look_at_rh(vec3(0.0f, 1.5f, 4.0f), vec3(0.0f, 0.0f, 0.0f), vec3(0.0f, 1.0f, 0.0f));
    mat44_t view_proj = mat44_mul_mat44(view, proj);
    state.scene1.rx += 1.0f * t;
    state.scene1.ry += 2.0f * t;
    mat44_t rxm = mat44_rotation_x(vecmath_radians(state.scene1.rx));
    mat44_t rym = mat44_rotation_y(vecmath_radians(state.scene1.ry));
    mat44_t model = mat44_mul_mat44(rym, rxm);
    var vs_params = vs_params_t{.mvp = mat44_mul_mat44(model, view_proj)};
    sg_apply_pipeline(state.scene1.pip);
    sg_apply_bindings(&state.scene1.bind);
    sg_apply_uniforms(UB_vs_params, &sg_range{&vs_params, sizeof(vs_params)});
    sg_draw(0, 36, 1);
}

// helper function to draw a cube via sokol-gl
void cube_sgl() {
    sgl_begin_quads();
    sgl_c3f(1.0f, 0.0f, 0.0f);
    sgl_v3f_t2f(-1.0f, 1.0f, -1.0f, -1.0f, 1.0f);
    sgl_v3f_t2f(1.0f, 1.0f, -1.0f, 1.0f, 1.0f);
    sgl_v3f_t2f(1.0f, -1.0f, -1.0f, 1.0f, -1.0f);
    sgl_v3f_t2f(-1.0f, -1.0f, -1.0f, -1.0f, -1.0f);
    sgl_c3f(0.0f, 1.0f, 0.0f);
    sgl_v3f_t2f(cast(f32, -1.0), cast(f32, -1.0), 1.0f, -1.0f, 1.0f);
    sgl_v3f_t2f(1.0f, cast(f32, -1.0), 1.0f, 1.0f, 1.0f);
    sgl_v3f_t2f(1.0f, 1.0f, 1.0f, 1.0f, -1.0f);
    sgl_v3f_t2f(cast(f32, -1.0), 1.0f, 1.0f, -1.0f, -1.0f);
    sgl_c3f(0.0f, 0.0f, 1.0f);
    sgl_v3f_t2f(cast(f32, -1.0), cast(f32, -1.0), 1.0f, -1.0f, 1.0f);
    sgl_v3f_t2f(cast(f32, -1.0), 1.0f, 1.0f, 1.0f, 1.0f);
    sgl_v3f_t2f(cast(f32, -1.0), 1.0f, cast(f32, -1.0), 1.0f, -1.0f);
    sgl_v3f_t2f(cast(f32, -1.0), cast(f32, -1.0), cast(f32, -1.0), -1.0f, -1.0f);
    sgl_c3f(1.0f, 0.5f, 0.0f);
    sgl_v3f_t2f(1.0f, cast(f32, -1.0), 1.0f, -1.0f, 1.0f);
    sgl_v3f_t2f(1.0f, cast(f32, -1.0), cast(f32, -1.0), 1.0f, 1.0f);
    sgl_v3f_t2f(1.0f, 1.0f, cast(f32, -1.0), 1.0f, -1.0f);
    sgl_v3f_t2f(1.0f, 1.0f, 1.0f, -1.0f, -1.0f);
    sgl_c3f(0.0f, 0.5f, 1.0f);
    sgl_v3f_t2f(1.0f, cast(f32, -1.0), cast(f32, -1.0), -1.0f, 1.0f);
    sgl_v3f_t2f(1.0f, cast(f32, -1.0), 1.0f, 1.0f, 1.0f);
    sgl_v3f_t2f(cast(f32, -1.0), cast(f32, -1.0), 1.0f, 1.0f, -1.0f);
    sgl_v3f_t2f(cast(f32, -1.0), cast(f32, -1.0), cast(f32, -1.0), -1.0f, -1.0f);
    sgl_c3f(1.0f, 0.0f, 0.5f);
    sgl_v3f_t2f(cast(f32, -1.0), 1.0f, cast(f32, -1.0), -1.0f, 1.0f);
    sgl_v3f_t2f(cast(f32, -1.0), 1.0f, 1.0f, 1.0f, 1.0f);
    sgl_v3f_t2f(1.0f, 1.0f, 1.0f, 1.0f, -1.0f);
    sgl_v3f_t2f(1.0f, 1.0f, cast(f32, -1.0), -1.0f, -1.0f);
    sgl_end();
}

// another ImGui draw callback to render via sokol-gl
void draw_scene_2(ImDrawList* dl, ImDrawCmd* cmd) {
    ignore dl;
    var t = cast(f32, sapp_frame_duration() * 60.0);
    var cx = cast(i32, cmd.ClipRect.x);
    var cy = cast(i32, cmd.ClipRect.y);
    var cw = cast(i32, cmd.ClipRect.z - cmd.ClipRect.x);
    var ch = cast(i32, cmd.ClipRect.w - cmd.ClipRect.y);
    sgl_scissor_rect(cx, cy, cw, ch, true);
    sgl_viewport(cx, cy, 360, 360, true);
    state.scene2.r0 += 1.0f * t;
    state.scene2.r1 += 2.0f * t;
    sgl_defaults();
    sgl_load_pipeline(state.scene2.pip);
    sgl_matrix_mode_projection();
    sgl_perspective(sgl_rad(45.0f), 1.0f, 0.1f, 100.0f);
    sgl_matrix_mode_modelview();
    sgl_translate(0.0f, 0.0f, -12.0f);
    sgl_rotate(sgl_rad(state.scene2.r0), 1.0f, 0.0f, 0.0f);
    sgl_rotate(sgl_rad(state.scene2.r1), 0.0f, 1.0f, 0.0f);
    cube_sgl();
    sgl_push_matrix();
    sgl_translate(0.0f, 0.0f, 3.0f);
    sgl_scale(0.5f, 0.5f, 0.5f);
    sgl_rotate(-2.0f * sgl_rad(state.scene2.r0), 1.0f, 0.0f, 0.0f);
    sgl_rotate(-2.0f * sgl_rad(state.scene2.r1), 0.0f, 1.0f, 0.0f);
    cube_sgl();
    sgl_push_matrix();
    sgl_translate(0.0f, 0.0f, 3.0f);
    sgl_scale(0.5f, 0.5f, 0.5f);
    sgl_rotate(-3.0f * sgl_rad(2.0f * state.scene2.r0), 1.0f, 0.0f, 0.0f);
    sgl_rotate(3.0f * sgl_rad(2.0f * state.scene2.r1), 0.0f, 0.0f, 1.0f);
    cube_sgl();
    sgl_pop_matrix();
    sgl_pop_matrix();
    sgl_draw();
}

void frame() {
    i32 w = sapp_width();
    i32 h = sapp_height();
    simgui_new_frame(&simgui_frame_desc_t{
        .width = w,
        .height = h,
        .delta_time = sapp_frame_duration(),
        .dpi_scale = sapp_dpi_scale(),
    });
    ImGui_SetNextWindowPos(ImVec2{20.0f, 20.0f}, ImGuiCond_Once);
    ImGui_SetNextWindowSize(ImVec2{800.0f, 400.0f}, ImGuiCond_Once);
    if ImGui_Begin("Dear ImGui", null, 0) != 0 {
        if ImGui_BeginChild("sokol-gfx", ImVec2{360.0f, 360.0f}, ImGuiChildFlags_Borders, ImGuiWindowFlags_None) != 0 {
            ImDrawList* dl = ImGui_GetWindowDrawList();
            ImDrawList_AddCallback(dl, draw_scene_1);
        }
        ImGui_EndChild();
        ImGui_SameLine(0.0f, 10.0f);
        if ImGui_BeginChild("sokol-gl", ImVec2{360.0f, 360.0f}, ImGuiChildFlags_Borders, ImGuiWindowFlags_None) != 0 {
            ImDrawList* dl = ImGui_GetWindowDrawList();
            ImDrawList_AddCallback(dl, draw_scene_2);
        }
        ImGui_EndChild();
    }
    ImGui_End();
    sg_begin_pass(&sg_pass{.action = state.default_pass_action, .swapchain = sglue_swapchain()});
    simgui_render();
    sg_end_pass();
    sg_commit();
}

void cleanup() {
    sgl_shutdown();
    simgui_shutdown();
    sg_shutdown();
}

void input(sapp_event* ev) {
    simgui_handle_event(ev);
}
}

sapp_desc __sapp_sample_main() {
    return sapp_desc{
        .init_cb = init,
        .frame_cb = frame,
        .cleanup_cb = cleanup,
        .event_cb = input,
        .width = 860,
        .height = 440,
        .window_title = "imgui-usercallback-sapp.mc",
        .icon = sapp_icon_desc{.sokol_default = true},
        .logger = sapp_logger{.func = slog_func},
    };
}
