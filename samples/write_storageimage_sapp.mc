import dbgui;

import sokol_all;
import math;

// force high-dpi, sample entry point is __sapp_sample_main()
sapp_desc sokol_main() {
    sapp_desc d = __sapp_sample_main();
    d.high_dpi = true;
    return d;
}

// write-storageimage-sapp.glsl, hand-ported. A compute pass writes a
// scrolling gradient into a storage image, then a fullscreen triangle
// samples it.

struct Ub_cs_params {
    f32 offset;
}

struct WriteStorageimageSappVsOut {
    float4 pos;
    float2 uv;
}

@shader compute(16, 16, 1)
void write_storageimage_sapp_cs(
    @storage(rgba8) RWTexture2D cs_out_tex,
    @uniform(0) Ub_cs_params cs_params
) {
    int2 size = texture_size(cs_out_tex);
    uint3 gid = thread_id();
    float2 fg = float2{cast(f32, gid.x), cast(f32, gid.y)};
    float2 fsz = float2{cast(f32, size.x), cast(f32, size.y)};

    // GLSL mod(x, y) is x - y * floor(x / y)
    f32 qx = fg.x + fsz.x * cs_params.offset;
    f32 qy = fg.y + fsz.y * cs_params.offset;
    int2 pos = int2{cast(i32, qx - fsz.x * floor(qx / fsz.x)),
                    cast(i32, qy - fsz.y * floor(qy / fsz.y))};

    cs_out_tex[pos] = float4{fg.x / fsz.x, fg.y / fsz.y, 0.0f, 1.0f};
}

@shader vertex
WriteStorageimageSappVsOut write_storageimage_sapp_vs() {
    // fullscreen triangle from the vertex index, no vertex buffer
    float2 pos = float2{-1.0f, -1.0f};
    i32 vid = cast(i32, vertex_id());
    if vid == 1 { pos = float2{3.0f, -1.0f}; }
    if vid == 2 { pos = float2{-1.0f, 3.0f}; }
    WriteStorageimageSappVsOut o;
    o.pos = float4{pos.x, pos.y, 0.0f, 1.0f};
    o.uv = float2{(pos.x + 1.0f) * 0.5f, (0.0f - pos.y + 1.0f) * 0.5f};
    return o;
}

@shader fragment
float4 write_storageimage_sapp_fs(
WriteStorageimageSappVsOut input,
    @texture(0) Texture2D disp_tex,
    @sampler(0) Sampler disp_smp
) {
    float4 c = sample(disp_tex, disp_smp, input.uv);
    return float4{c.x, c.y, c.z, 1.0f};
}

enum __enum_UB_cs_params {
    UB_cs_params = 0,
    VIEW_cs_out_tex = 0,
    VIEW_disp_tex = 0,
    SMP_disp_smp = 0,
    __shim_end = 255,
}

// Replaces the sokol-shdc generated write-storageimage-sapp.glsl.h.
/* compute program takes the single-ShaderMeta overload */
/* Tail-padded to 16: the declared uniform-block size rounds up and
   sg_apply_uniforms asserts the range matches it exactly. */
struct cs_params_t {
    f32 offset;
    f32[3] _pad_tail;
}

private struct state_t {
    f64 time;
    sg_image img;
    struct {
        sg_view simg_view;
        sg_pipeline pip;
    } compute;
    struct {
        sg_view tex_view;
        sg_pipeline pip;
        sg_sampler smp;
        sg_pass_action pass_action;
    } display;
}

private {
state_t state = state_t{.display = {.pass_action = {.colors[0] = {.load_action = SG_LOADACTION_DONTCARE}}}};

void init() {
    sg_setup(&sg_desc{.environment = sglue_environment(), .logger = sg_logger{.func = slog_func}});
    __dbgui_setup();
    state.img = sg_make_image(&sg_image_desc{
        .usage = sg_image_usage{.storage_image = true},
        .width = 256,
        .height = 256,
        .pixel_format = SG_PIXELFORMAT_RGBA8,
        .label = "storage-image",
    });
    state.compute.simg_view = sg_make_view(&sg_view_desc{
        .storage_image = sg_image_view_desc{.image = state.img},
        .label = "storage-image-view",
    });
    state.display.tex_view = sg_make_view(&sg_view_desc{
        .texture = sg_texture_view_desc{.image = state.img},
        .label = "texture-view",
    });
    state.compute.pip = sg_make_pipeline(&sg_pipeline_desc{
        .compute = true,
        .shader = sokol_make_shader(&write_storageimage_sapp_cs_shader),
        .label = "compute-pipeline",
    });
    state.display.pip = sg_make_pipeline(&sg_pipeline_desc{
        .shader = sokol_make_shader(&write_storageimage_sapp_vs_shader, &write_storageimage_sapp_fs_shader),
        .label = "display-pipeline",
    });
    state.display.smp = sg_make_sampler(&sg_sampler_desc{
        .mag_filter = SG_FILTER_LINEAR,
        .min_filter = SG_FILTER_LINEAR,
        .label = "display-sampler",
    });
}

void frame() {
    state.time += sapp_frame_duration();
    f64 time_offset = (sin(state.time * 4.0) + 1.0) * 0.5;
    var cs_params = cs_params_t{.offset = cast(f32, time_offset)};
    sg_begin_pass(&sg_pass{.compute = true, .label = "compute-pass"});
    sg_apply_pipeline(state.compute.pip);
    sg_apply_bindings(&sg_bindings{.views[0] = state.compute.simg_view});
    sg_apply_uniforms(UB_cs_params, &sg_range{&cs_params, sizeof(cs_params)});
    sg_dispatch(256 / 16, 256 / 16, 1);
    sg_end_pass();
    sg_begin_pass(&sg_pass{
        .action = state.display.pass_action,
        .swapchain = sglue_swapchain(),
        .label = "render-pass",
    });
    sg_apply_pipeline(state.display.pip);
    sg_apply_bindings(&sg_bindings{
        .views[0] = state.display.tex_view,
        .samplers[0] = state.display.smp,
    });
    sg_draw(0, 3, 1);
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
        .width = 512,
        .height = 512,
        .window_title = "write-storageimage-sapp.mc",
        .icon = sapp_icon_desc{.sokol_default = true},
        .logger = sapp_logger{.func = slog_func},
    };
}
