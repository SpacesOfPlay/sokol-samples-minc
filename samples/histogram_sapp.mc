import dbgui;
import sapp_util;
import sokol_fetch;
import vecmath;

import sokol_all;
import math;

// force high-dpi, sample entry point is __sapp_sample_main()
sapp_desc sokol_main() {
    sapp_desc d = __sapp_sample_main();
    d.high_dpi = true;
    return d;
}

// histogram-sapp.glsl, hand-ported.
//
// Bins are a flat []u32, four per bin (r, g, b, pad), matching
// hist_bin_t. Bin 0 holds the per-channel maximum.

const i32 NUM_BINS = 256;

struct Ub_vs_params {
    float4x4 mvp;
    float4x4 mv;
}

struct Ub_vs_hist_params {
    i32 channel;
}

struct HistogramSappShapeOut {
    float4 pos;
    float2 uv;
    float3 view_pos;
}

struct HistogramSappHistOut {
    float4 pos;
    float4 color;
}

@shader compute(64, 1, 1)
void histogram_sapp_cs_clear(@rwbuffer(0) []u32 clear_bins) {
    u32 i = thread_id().x * 4;
    clear_bins[i] = 0;
    clear_bins[i + 1] = 0;
    clear_bins[i + 2] = 0;
    clear_bins[i + 3] = 0;
}

@shader vertex
HistogramSappShapeOut histogram_sapp_vs_shape(
    @attr(0) float3 in_pos,
    @attr(1) float2 in_uv,
    @uniform(0) Ub_vs_params vs_params
) {
    HistogramSappShapeOut o;
    float4 p = float4{in_pos.x, in_pos.y, in_pos.z, 1.0f};
    o.pos = mul(vs_params.mvp, p);
    o.view_pos = mul(vs_params.mv, p).xyz;
    o.uv = in_uv;
    return o;
}

u32 bin_index(f32 c) {
    i32 i = cast(i32, clamp(c, 0.0f, 1.0f) * cast(f32, NUM_BINS));
    if i > NUM_BINS - 1 { i = NUM_BINS - 1; }
    return cast(u32, i);
}

@shader fragment
float4 histogram_sapp_fs_shape(
    HistogramSappShapeOut input,
    @rwbuffer(0) []u32 out_bins,
    @texture(1) Texture2D shape_tex,
    @sampler(0) Sampler shape_smp
) {
    // flat face normal, facing the viewer
    float3 n = normalize(cross(ddx(input.view_pos), ddy(input.view_pos)));
    if dot(n, input.view_pos) >= 0.0f { n = n * (0.0f - 1.0f); }
    float3 light_dir = normalize(float3{0.0f - 0.5f, 1.0f, 1.0f});
    f32 intensity = 0.25f + 0.75f * max(dot(n, light_dir), 0.0f);
    float3 rgb = sample(shape_tex, shape_smp, input.uv).xyz * intensity;

    u32 r_index = bin_index(rgb.x);
    u32 g_index = bin_index(rgb.y);
    u32 b_index = bin_index(rgb.z);
    if r_index > 0 {
        u32 cur = atomic_add(out_bins, r_index * 4, 1) + 1;
        atomic_max(out_bins, 0, cur);
    }
    if g_index > 0 {
        u32 cur = atomic_add(out_bins, g_index * 4 + 1, 1) + 1;
        atomic_max(out_bins, 1, cur);
    }
    if b_index > 0 {
        u32 cur = atomic_add(out_bins, b_index * 4 + 2, 1) + 1;
        atomic_max(out_bins, 2, cur);
    }
    return float4{rgb.x, rgb.y, rgb.z, 1.0f};
}

// One bar per instance; instance 0 is bin 1.
@shader vertex
HistogramSappHistOut histogram_sapp_vs_display_hist(
    @uniform(0) Ub_vs_hist_params p,
    @buffer(0) []u32 in_bins
) {
    HistogramSappHistOut o;
    u32 ch = cast(u32, p.channel);
    u32 max_count = max(in_bins[ch], cast(u32, 1));
    u32 inst = instance_id();
    u32 count = in_bins[(inst + 1) * 4 + ch];
    f32 height = cast(f32, count) / cast(f32, max_count);

    // triangle strip: (0,0), (1,0), (0,1), (1,1)
    u32 vid = vertex_id();
    f32 px = (cast(f32, inst) + cast(f32, vid & 1)) / cast(f32, NUM_BINS - 1);
    f32 py = cast(f32, (vid >> 1) & 1) * height;
    o.pos = float4{px * 2.0f - 1.0f, py * 2.0f - 1.0f, 0.0f, 1.0f};

    f32 v = cast(f32, inst + 1) / 255.0f;
    float4 c = float4{0.0f, 0.0f, 0.0f, 1.0f};
    if p.channel == 0 {
        c.x = v;
    } else if p.channel == 1 {
        c.y = v;
    } else {
        c.z = v;
    }
    o.color = c;
    return o;
}

@shader fragment
float4 histogram_sapp_fs_display_hist(HistogramSappHistOut input) {
    return input.color;
}

enum __enum_ATTR_shape_in_pos {
    ATTR_shape_in_pos = 0,
    ATTR_shape_in_uv = 1,
    UB_vs_params = 0,
    UB_vs_hist_params = 0,
    VIEW_hist_clear = 0,
    VIEW_hist_out = 0,
    VIEW_hist_in = 0,
    VIEW_shape_tex = 1,
    SMP_shape_smp = 0,
    __shim_end = 255,
}

/* Replaces stb_image.h; the samples only use the
   load-from-memory surface, provided by ext/sokol_samples/
   stbi_shim.mc over lib/png.mc + lib/jpeg.mc (RGBA8). Extern-included:
   declarations register, nothing emits. */
type stbi_uc = u8;
// Replaces the sokol-shdc generated histogram-sapp.glsl.h.
/* compute programs take the single-ShaderMeta overload */
struct vs_params_t {
    mat44_t mvp;
    mat44_t mv;
}

struct vs_hist_params_t {
    i32 channel;
    u8[12] _pad_tail;
}

/* Storage-buffer element, used for sizeof only. */
struct hist_bin_t {
    u32 r;
    u32 g;
    u32 b;
    u32 pad;
}

private struct state_t {
    struct {
        sg_buffer sbuf;
        sg_view sbuf_view;
        sg_pipeline clear_pip;
        sg_pipeline draw_pip;
    } histogram;
    struct {
        sg_buffer vbuf;
        sg_buffer ibuf;
        sg_pipeline pip;
        sg_image img;
        sg_view tex_view;
        sg_sampler smp;
    } cube;
    f32 rx;
    f32 ry;
    bool load_failed;
}

private {
state_t state;
u8[256 * 1024] file_buffer;
f32[120] cube_vertices = {
    -1.0f, -1.0f, -1.0f, 0.0f, 0.0f, 1.0f, -1.0f, -1.0f, 1.0f, 0.0f, 1.0f, 1.0f, -1.0f, 1.0f, 1.0f,
    -1.0f, 1.0f, -1.0f, 0.0f, 1.0f, -1.0f, -1.0f, 1.0f, 0.0f, 0.0f, 1.0f, -1.0f, 1.0f, 1.0f, 0.0f,
    1.0f, 1.0f, 1.0f, 1.0f, 1.0f, -1.0f, 1.0f, 1.0f, 0.0f, 1.0f, -1.0f, -1.0f, -1.0f, 0.0f, 0.0f,
    -1.0f, 1.0f, -1.0f, 1.0f, 0.0f, -1.0f, 1.0f, 1.0f, 1.0f, 1.0f, -1.0f, -1.0f, 1.0f, 0.0f, 1.0f,
    1.0f, -1.0f, -1.0f, 0.0f, 0.0f, 1.0f, 1.0f, -1.0f, 1.0f, 0.0f, 1.0f, 1.0f, 1.0f, 1.0f, 1.0f,
    1.0f, -1.0f, 1.0f, 0.0f, 1.0f, -1.0f, -1.0f, -1.0f, 0.0f, 0.0f, -1.0f, -1.0f, 1.0f, 1.0f, 0.0f,
    1.0f, -1.0f, 1.0f, 1.0f, 1.0f, 1.0f, -1.0f, -1.0f, 0.0f, 1.0f, -1.0f, 1.0f, -1.0f, 0.0f, 0.0f,
    -1.0f, 1.0f, 1.0f, 1.0f, 0.0f, 1.0f, 1.0f, 1.0f, 1.0f, 1.0f, 1.0f, 1.0f, -1.0f, 0.0f, 1.0f,
};
u16[36] cube_indices = {
    0, 1, 2, 0, 2, 3, 6, 5, 4, 7, 6, 4, 8, 9, 10, 8, 10, 11, 14, 13, 12, 15, 14, 12, 16, 17, 18, 16,
    18, 19, 22, 21, 20, 23, 22, 20,
};
}

private {
void init() {
    sg_setup(&sg_desc{.environment = sglue_environment(), .logger = sg_logger{.func = slog_func}});
    _dbgui_setup();
    sfetch_setup(&sfetch_desc_t{.logger = sfetch_logger_t{.func = slog_func}});
    state.histogram.sbuf = sg_make_buffer(&sg_buffer_desc{
        .usage = sg_buffer_usage{.storage_buffer = true},
        .size = cast(u64, 256 * sizeof(hist_bin_t)),
        .label = "histogram-buffer",
    });
    state.histogram.sbuf_view = sg_make_view(&sg_view_desc{
        .storage_buffer = sg_buffer_view_desc{.buffer = state.histogram.sbuf},
        .label = "histogram-buffer-view",
    });
    state.histogram.clear_pip = sg_make_pipeline(&sg_pipeline_desc{
        .compute = true,
        .shader = sokol_make_shader(&histogram_sapp_cs_clear_shader),
        .label = "histogram-clear-pipeline",
    });
    state.cube.vbuf = sg_make_buffer(&sg_buffer_desc{
        .data = sg_range{&cube_vertices, sizeof(cube_vertices)},
        .label = "cube-vertices",
    });
    state.cube.ibuf = sg_make_buffer(&sg_buffer_desc{
        .usage = sg_buffer_usage{.index_buffer = true},
        .data = sg_range{&cube_indices, sizeof(cube_indices)},
        .label = "cube-indices",
    });
    state.cube.pip = sg_make_pipeline(&sg_pipeline_desc{
        .shader = sokol_make_shader(&histogram_sapp_vs_shape_shader, &histogram_sapp_fs_shape_shader),
        .layout = sg_vertex_layout_state{
            .attrs[0] = {.format = SG_VERTEXFORMAT_FLOAT3},
            .attrs[1] = {.format = SG_VERTEXFORMAT_FLOAT2},
        },
        .index_type = SG_INDEXTYPE_UINT16,
        .cull_mode = SG_CULLMODE_BACK,
        .depth = sg_depth_state{.write_enabled = true, .compare = SG_COMPAREFUNC_LESS_EQUAL},
        .label = "cube-pipeline",
    });
    state.cube.smp = sg_make_sampler(&sg_sampler_desc{
        .min_filter = SG_FILTER_NEAREST,
        .mag_filter = SG_FILTER_NEAREST,
        .label = "sampler",
    });
    state.cube.img = sg_alloc_image();
    state.cube.tex_view = sg_alloc_view();
    state.histogram.draw_pip = sg_make_pipeline(&sg_pipeline_desc{
        .shader = sokol_make_shader(&histogram_sapp_vs_display_hist_shader, &histogram_sapp_fs_display_hist_shader),
        .primitive_type = SG_PRIMITIVETYPE_TRIANGLE_STRIP,
        .label = "display-histogram-pipeline",
    });
    noinit u8[512] path_buf;
    sfetch_send(&sfetch_request_t{
        .path = fileutil_get_path("baboon.png", path_buf, cast(u64, sizeof(path_buf))),
        .callback = fetch_callback,
        .buffer = sfetch_range_t{&file_buffer, sizeof(file_buffer)},
    });
}

void frame() {
    sfetch_dowork();
    vs_params_t vs_params = compute_vsparams();
    sg_begin_pass(&sg_pass{.compute = true});
    sg_apply_pipeline(state.histogram.clear_pip);
    sg_apply_bindings(&sg_bindings{.views[0] = state.histogram.sbuf_view});
    sg_dispatch(256 / 64, 1, 1);
    sg_end_pass();
    var action = sg_pass_action{
        .colors[0] = {
            .load_action = SG_LOADACTION_CLEAR,
            .clear_value = state.load_failed != 0 ? sg_color{1.0f, 0.0f, 0.0f, 1.0f} : sg_color{0.5f, 0.5f, 0.5f, 1.0f},
        },
    };
    sg_swapchain swapchain = sglue_swapchain();
    sg_begin_pass(&sg_pass{.action = action, .swapchain = swapchain});
    sg_apply_pipeline(state.cube.pip);
    sg_apply_bindings(&sg_bindings{
        .vertex_buffers[0] = state.cube.vbuf,
        .index_buffer = state.cube.ibuf,
        .views = {
            state.histogram.sbuf_view,
            state.cube.tex_view,
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
        .samplers[0] = state.cube.smp,
    });
    sg_apply_uniforms(UB_vs_params, &sg_range{&vs_params, sizeof(vs_params)});
    sg_draw(0, 36, 1);
    sg_end_pass();
    _dbgui_update();
    sg_begin_pass(&sg_pass{
        .action = sg_pass_action{
            .colors[0] = {.load_action = SG_LOADACTION_LOAD},
            .depth = sg_depth_attachment_action{.load_action = SG_LOADACTION_DONTCARE},
        },
        .swapchain = swapchain,
    });
    i32 w = sapp_width() - 2 * 20;
    i32 x = 20;
    i32 h = sapp_height() / 10;
    i32 y0 = sapp_height() - 4 * h;
    sg_apply_pipeline(state.histogram.draw_pip);
    sg_apply_bindings(&sg_bindings{.views[0] = state.histogram.sbuf_view});
    for i32 i = 0; i < 3; i++ {
        var vs_hist_params = vs_hist_params_t{.channel = i};
        sg_apply_viewport(x, y0 + i * h, w, h, true);
        sg_apply_uniforms(UB_vs_hist_params, &sg_range{&vs_hist_params, sizeof(vs_hist_params)});
        sg_draw(0, 4, 256 - 1);
    }
    _dbgui_draw();
    sg_end_pass();
    sg_commit();
}

void cleanup() {
    sfetch_shutdown();
    _dbgui_shutdown();
    sg_shutdown();
}

void fetch_callback(sfetch_response_t* response) {
    if response.fetched != 0 {
        i32 png_width;
        i32 png_height;
        i32 num_channels;
        i32 desired_channels = 4;
        stbi_uc* pixels = stbi_load_from_memory(response.data.ptr, cast(i32, response.data.size), &png_width, &png_height, &num_channels, desired_channels);
        if pixels != null {
            sg_init_image(state.cube.img, &sg_image_desc{
                .width = png_width,
                .height = png_height,
                .pixel_format = SG_PIXELFORMAT_RGBA8,
                .data = sg_image_data{
                    .mip_levels[0] = {.ptr = pixels, .size = cast(u64, png_width * png_height * 4)},
                },
                .label = "png-image",
            });
            stbi_image_free(pixels);
            sg_init_view(state.cube.tex_view, &sg_view_desc{
                .texture = sg_texture_view_desc{.image = state.cube.img},
                .label = "png-texture-view",
            });
        } else {
            state.load_failed = true;
        }
    } else if response.failed != 0 {
        state.load_failed = true;
    }
}

vs_params_t compute_vsparams() {
    var t = cast(f32, sapp_frame_duration() * 60.0);
    state.rx += 1.0f * t;
    state.ry += 2.0f * t;
    f32 w = sapp_widthf();
    f32 h = sapp_heightf();
    mat44_t proj = mat44_perspective_fov_rh(vecmath_radians(60.0f), w / h, 0.01f, 10.0f);
    mat44_t view = mat44_look_at_rh(vec3(0.0f, 1.5f, 4.0f), vec3(0.0f, 0.0f, 0.0f), vec3(0.0f, 1.0f, 0.0f));
    mat44_t view_proj = mat44_mul_mat44(view, proj);
    mat44_t rxm = mat44_rotation_x(vecmath_radians(state.rx));
    mat44_t rym = mat44_rotation_y(vecmath_radians(state.ry));
    mat44_t model = mat44_mul_mat44(rym, rxm);
    return vs_params_t{.mvp = mat44_mul_mat44(model, view_proj), .mv = mat44_mul_mat44(model, view)};
}
}

sapp_desc __sapp_sample_main() {
    return sapp_desc{
        .init_cb = init,
        .frame_cb = frame,
        .cleanup_cb = cleanup,
        .event_cb = _dbgui_event,
        .width = 800,
        .height = 600,
        .window_title = "histogram-sapp.mc",
        .icon = sapp_icon_desc{.sokol_default = true},
        .logger = sapp_logger{.func = slog_func},
    };
}
