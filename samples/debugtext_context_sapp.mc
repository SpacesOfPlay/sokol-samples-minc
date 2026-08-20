import dbgui;
import sokol_debugtext;
import vecmath;

import sokol_all;
import math;

// force high-dpi, sample entry point is __sapp_sample_main()
sapp_desc sokol_main() {
    sapp_desc d = __sapp_sample_main();
    d.high_dpi = true;
    return d;
}

// debugtext-context-sapp.glsl - ported to minc @shader.

struct DebugtextContextSappVsOut {
    float4 pos;
    float2 uv;
}

@shader vertex
DebugtextContextSappVsOut debugtext_context_sapp_vs(
    @attr(0) float4 pos,
    @attr(1) float2 texcoord0,
    @uniform float4x4 mvp
) {
    DebugtextContextSappVsOut o;
    o.pos = mul(mvp, pos);
    o.uv = texcoord0;
    // upstream's `#if SOKOL_GLSL`: GL render targets have a bottom-left
    // origin, the others top-left.
    when gpu(opengl) || gpu(opengles) {
        o.uv.y = 1.0f - o.uv.y;
    }
    return o;
}

@shader fragment
float4 debugtext_context_sapp_fs(
DebugtextContextSappVsOut input,
    @texture(0) Texture2D tex,
    @sampler(0) Sampler smp
) {
    return sample(tex, smp, input.uv);
}


enum __enum_ATTR_debugtext_context_pos {
    ATTR_debugtext_context_pos = 0,
    ATTR_debugtext_context_texcoord0 = 1,
    UB_vs_params = 0,
    VIEW_tex = 0,
    SMP_smp = 0,
    __shim_end = 255,
}

// Replaces the sokol-shdc generated debugtext-context-sapp.glsl.h.
struct vs_params_t {
    mat44_t mvp;
}

struct __anon_debugtext_context_sapp_struct_0 {
    sdtx_context text_context;
    sg_view tex_view;
    sg_pass pass;
}

private struct state_t {
    f32 rx;
    f32 ry;
    sg_buffer vbuf;
    sg_buffer ibuf;
    sg_pipeline pip;
    sg_sampler smp;
    sg_pass_action pass_action;
    __anon_debugtext_context_sapp_struct_0[6] passes;
}

struct vertex_t {
    f32 x;
    f32 y;
    f32 z;
    u16 u;
    u16 v;
}

private {
state_t state;
// face background colors
sg_color[6] bg = {
    sg_color{0.0f, 0.0f, 0.5f, 1.0f},
    sg_color{0.0f, 0.5f, 0.0f, 1.0f},
    sg_color{0.5f, 0.0f, 0.0f, 1.0f},
    sg_color{0.5f, 0.0f, 0.25f, 1.0f},
    sg_color{0.5f, 0.25f, 0.0f, 1.0f},
    sg_color{0.0f, 0.25f, 0.5f, 1.0f},
};

void init() {
    sg_setup(&sg_desc{.environment = sglue_environment(), .logger = sg_logger{.func = slog_func}});
    __dbgui_setup();
    sdtx_setup(&sdtx_desc_t{
        .fonts = {
            sdtx_font_kc853(),
            sdtx_font_kc854(),
            sdtx_font_z1013(),
            sdtx_font_cpc(),
            sdtx_font_c64(),
            sdtx_font_oric(),
            sdtx_font_desc_t{},
            sdtx_font_desc_t{},
        },
        .logger = sdtx_logger_t{.func = slog_func},
    });
    vertex_t[24] vertices = {
        vertex_t{-1.0f, -1.0f, -1.0f, 0, 0},
        vertex_t{1.0f, -1.0f, -1.0f, 32767, 0},
        vertex_t{1.0f, 1.0f, -1.0f, 32767, 32767},
        vertex_t{-1.0f, 1.0f, -1.0f, 0, 32767},
        vertex_t{-1.0f, -1.0f, 1.0f, 32767, 0},
        vertex_t{1.0f, -1.0f, 1.0f, 0, 0},
        vertex_t{1.0f, 1.0f, 1.0f, 0, 32767},
        vertex_t{-1.0f, 1.0f, 1.0f, 32767, 32767},
        vertex_t{-1.0f, -1.0f, -1.0f, 0, 0},
        vertex_t{-1.0f, 1.0f, -1.0f, 32767, 0},
        vertex_t{-1.0f, 1.0f, 1.0f, 32767, 32767},
        vertex_t{-1.0f, -1.0f, 1.0f, 0, 32767},
        vertex_t{1.0f, -1.0f, -1.0f, 32767, 0},
        vertex_t{1.0f, 1.0f, -1.0f, 0, 0},
        vertex_t{1.0f, 1.0f, 1.0f, 0, 32767},
        vertex_t{1.0f, -1.0f, 1.0f, 32767, 32767},
        vertex_t{-1.0f, -1.0f, -1.0f, 0, 0},
        vertex_t{-1.0f, -1.0f, 1.0f, 32767, 0},
        vertex_t{1.0f, -1.0f, 1.0f, 32767, 32767},
        vertex_t{1.0f, -1.0f, -1.0f, 0, 32767},
        vertex_t{-1.0f, 1.0f, -1.0f, 32767, 0},
        vertex_t{-1.0f, 1.0f, 1.0f, 0, 0},
        vertex_t{1.0f, 1.0f, 1.0f, 0, 32767},
        vertex_t{1.0f, 1.0f, -1.0f, 32767, 32767},
    };
    state.vbuf = sg_make_buffer(&sg_buffer_desc{
        .data = sg_range{&vertices, sizeof(vertices)},
        .label = "cube-vertices",
    });
    u16[36] indices = {
        0, 1, 2, 0, 2, 3, 6, 5, 4, 7, 6, 4, 8, 9, 10, 8, 10, 11, 14, 13, 12, 15, 14, 12, 16, 17, 18,
        16, 18, 19, 22, 21, 20, 23, 22, 20,
    };
    state.ibuf = sg_make_buffer(&sg_buffer_desc{
        .usage = sg_buffer_usage{.index_buffer = true},
        .data = sg_range{&indices, sizeof(indices)},
        .label = "cube-indices",
    });
    state.pip = sg_make_pipeline(&sg_pipeline_desc{
        .layout = sg_vertex_layout_state{
            .attrs[0] = {.format = SG_VERTEXFORMAT_FLOAT3},
            .attrs[1] = {.format = SG_VERTEXFORMAT_SHORT2N},
        },
        .shader = sokol_make_shader(&debugtext_context_sapp_vs_shader, &debugtext_context_sapp_fs_shader),
        .index_type = SG_INDEXTYPE_UINT16,
        .cull_mode = SG_CULLMODE_BACK,
        .depth = sg_depth_state{.compare = SG_COMPAREFUNC_LESS_EQUAL, .write_enabled = true},
        .label = "cube-pipeline",
    });
    for i32 i = 0; i < 6; i++ {
        state.passes[i].text_context = sdtx_make_context(&sdtx_context_desc_t{
            .char_buf_size = 64,
            .canvas_width = 32,
            .canvas_height = cast(f32, 32 / 2),
            .color_format = SG_PIXELFORMAT_RGBA8,
            .depth_format = SG_PIXELFORMAT_NONE,
            .sample_count = 1,
        });
        sg_image img = sg_make_image(&sg_image_desc{
            .usage = sg_image_usage{.color_attachment = true},
            .width = 32,
            .height = 32,
            .pixel_format = SG_PIXELFORMAT_RGBA8,
            .sample_count = 1,
        });
        state.passes[i].tex_view = sg_make_view(&sg_view_desc{.texture = sg_texture_view_desc{.image = img}});
        state.passes[i].pass = sg_pass{
            .attachments = sg_attachments{.colors[0] = sg_make_view(&sg_view_desc{.color_attachment = sg_image_view_desc{.image = img}})},
            .action = sg_pass_action{.colors[0] = {.load_action = SG_LOADACTION_CLEAR, .clear_value = bg[i]}},
        };
    }
    state.smp = sg_make_sampler(&sg_sampler_desc{
        .min_filter = SG_FILTER_NEAREST,
        .mag_filter = SG_FILTER_NEAREST,
    });
}
}

// compute the model-view-proj matrix for rendering the rotating cube
vs_params_t compute_vs_params(i32 w, i32 h) {
    mat44_t proj = mat44_perspective_fov_rh(vecmath_radians(60.0f), cast(f32, w) / cast(f32, h), 0.01f, 10.0f);
    mat44_t view = mat44_look_at_rh(vec3(0.0f, 1.5f, 4.0f), vec3(0.0f, 0.0f, 0.0f), vec3(0.0f, 1.0f, 0.0f));
    mat44_t view_proj = mat44_mul_mat44(view, proj);
    noinit vs_params_t vs_params;
    mat44_t rxm = mat44_rotation_x(vecmath_radians(state.rx));
    mat44_t rym = mat44_rotation_y(vecmath_radians(state.ry));
    mat44_t model = mat44_mul_mat44(rym, rxm);
    vs_params.mvp = mat44_mul_mat44(model, view_proj);
    return vs_params;
}

private {
void frame() {
    i32 disp_width = sapp_width();
    i32 disp_height = sapp_height();
    var t = cast(f32, sapp_frame_duration() * 60.0);
    var frame_count = cast(u32, sapp_frame_count());
    state.rx += 0.25f * t;
    state.ry += 0.5f * t;
    vs_params_t vs_params = compute_vs_params(disp_width, disp_height);
    sdtx_set_context(SDTX_DEFAULT_CONTEXT);
    sdtx_canvas(cast(f32, disp_width) * 0.5f, cast(f32, disp_height) * 0.5f);
    sdtx_origin(3.0f, 3.0f);
    sdtx_puts("Hello from main context!\n");
    sdtx_printf("Frame count: %d\n", frame_count);
    for i32 i = 0; i < 6; i++ {
        sdtx_set_context(state.passes[i].text_context);
        sdtx_origin(1.0f, 0.5f);
        sdtx_font(i);
        sdtx_printf("%02X", frame_count / 16 + cast(u32, i) & 0xFF);
    }
    for i32 i = 0; i < 6; i++ {
        sg_begin_pass(&state.passes[i].pass);
        sdtx_set_context(state.passes[i].text_context);
        sdtx_draw();
        sg_end_pass();
    }
    sg_begin_pass(&sg_pass{.action = state.pass_action, .swapchain = sglue_swapchain()});
    sg_apply_pipeline(state.pip);
    sg_apply_uniforms(UB_vs_params, &sg_range{&vs_params, sizeof(vs_params)});
    for i32 i = 0; i < 6; i++ {
        sg_apply_bindings(&sg_bindings{
            .vertex_buffers[0] = state.vbuf,
            .index_buffer = state.ibuf,
            .views[0] = state.passes[i].tex_view,
            .samplers[0] = state.smp,
        });
        sg_draw(i * 6, 6, 1);
    }
    sdtx_set_context(SDTX_DEFAULT_CONTEXT);
    sdtx_draw();
    __dbgui_draw();
    sg_end_pass();
    sg_commit();
}

void cleanup() {
    sdtx_shutdown();
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
        .sample_count = 4,
        .window_title = "debugtext-context-sapp.mc",
        .icon = sapp_icon_desc{.sokol_default = true},
        .logger = sapp_logger{.func = slog_func},
    };
}
