import dbgui;
import imgui_compat;
import sokol_gfx_imgui;
import sokol_app_imgui;
import sapp_util;
import sokol_fetch;

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

// imageblur-sapp.glsl, hand-ported. A separable box blur in compute:
// each workgroup stages a 4x128 tile of the source into shared memory,
// barriers, then writes the filtered result into a storage image. The
// host runs it twice per iteration with `flip` swapping the axis.
//
// The GLSL tile is `shared vec3 tile[4][128]`; @shared arrays are 1-D,
// so it is flattened and indexed r * 128 + c.

const i32 TILE_ROW = 128;

struct Ub_cs_params {
    i32 filter_dim;
    i32 block_dim;
    i32 flip;
}

struct ImageblurSappVsOut {
    float4 pos;
    float2 uv;
}

@shader compute(32, 1, 1)
void imageblur_sapp_cs(
    @texture(0) Texture2D cs_inp_tex,
    // Slot 1: Metal binds storage images and sampled textures in the
    // same [[texture(N)]] space, so slot 0 would collide with
    // cs_inp_tex (D3D11 never noticed, u0 and t0 are separate).
    @storage(rgba8, 1) RWTexture2D cs_outp_tex,
    @sampler(0) Sampler cs_smp,
    @uniform(0) Ub_cs_params p
) {
    @shared float3[512] tile;

    i32 filter_offset = (p.filter_dim - 1) / 2;
    int2 dims = texture_size(cs_inp_tex);
    uint3 wg = group_id();
    uint3 li = local_id();

    float2 base = float2{
        cast(f32, wg.x) * cast(f32, p.block_dim) + cast(f32, li.x) * 4.0f
            - cast(f32, filter_offset),
        cast(f32, wg.y) * 4.0f + cast(f32, li.y)};
    int2 base_index = int2{cast(i32, base.x), cast(i32, base.y)};

    for i32 r = 0; r < 4; r++ {
        for i32 c = 0; c < 4; c++ {
            float2 load_index = float2{base.x + cast(f32, c), base.y + cast(f32, r)};
            if p.flip != 0 {
                load_index = float2{load_index.y, load_index.x};
            }
            float2 uv = float2{(load_index.x + 0.25f) / cast(f32, dims.x),
                               (load_index.y + 0.25f) / cast(f32, dims.y)};
            float4 t = sample_level(cs_inp_tex, cs_smp, uv, 0.0f);
            tile[r * TILE_ROW + 4 * cast(i32, li.x) + c] = float3{t.x, t.y, t.z};
        }
    }

    group_barrier();

    for i32 r = 0; r < 4; r++ {
        for i32 c = 0; c < 4; c++ {
            int2 write_index = int2{base_index.x + c, base_index.y + r};
            if p.flip != 0 {
                write_index = int2{write_index.y, write_index.x};
            }
            i32 center = 4 * cast(i32, li.x) + c;
            if center >= filter_offset && center < TILE_ROW - filter_offset
               && write_index.x < dims.x && write_index.y < dims.y {
                float3 acc = float3{0.0f, 0.0f, 0.0f};
                f32 w = 1.0f / cast(f32, p.filter_dim);
                for i32 f = 0; f < p.filter_dim; f++ {
                    i32 i = center + f - filter_offset;
                    float3 s = tile[r * TILE_ROW + i];
                    acc = float3{acc.x + w * s.x, acc.y + w * s.y, acc.z + w * s.z};
                }
                cs_outp_tex[write_index] = float4{acc.x, acc.y, acc.z, 1.0f};
            }
        }
    }
}

@shader vertex
ImageblurSappVsOut imageblur_sapp_vs() {
    // fullscreen triangle from the vertex index, no vertex buffer
    float2 pos = float2{-1.0f, -1.0f};
    i32 vid = cast(i32, vertex_id());
    if vid == 1 { pos = float2{3.0f, -1.0f}; }
    if vid == 2 { pos = float2{-1.0f, 3.0f}; }
    ImageblurSappVsOut o;
    o.pos = float4{pos.x, pos.y, 0.0f, 1.0f};
    o.uv = float2{(pos.x + 1.0f) * 0.5f, (0.0f - pos.y + 1.0f) * 0.5f};
    return o;
}

@shader fragment
float4 imageblur_sapp_fs(
    ImageblurSappVsOut input,
    @texture(0) Texture2D disp_tex,
    @sampler(0) Sampler disp_smp
) {
    float4 c = sample(disp_tex, disp_smp, input.uv);
    return float4{c.x, c.y, c.z, 1.0f};
}

enum __enum_UB_cs_params {
    UB_cs_params = 0,
    VIEW_cs_inp_tex = 0,
    VIEW_cs_outp_tex = 1,
    SMP_cs_smp = 0,
    VIEW_disp_tex = 0,
    SMP_disp_smp = 0,
    __shim_end = 255,
}

/* Replaces stb_image.h; the samples only use the
   load-from-memory surface, provided by ext/sokol_samples/
   stbi_shim.mc over lib/png.mc + lib/jpeg.mc (RGBA8). Extern-included:
   declarations register, nothing emits. */
type stbi_uc = u8;
// Replaces the sokol-shdc generated imageblur-sapp.glsl.h.
//
/* enum, not #define: transminc folds enum-constant subscripts
   in designator paths. */
struct cs_params_t {
    i32 filter_dim;
    i32 block_dim;
    i32 flip;
    u8[4] _pad_tail;
}

private struct state_t {
    i32 src_width;
    i32 src_height;
    sg_sampler smp;
    struct {
        sg_pipeline pip;
        sg_image src_image;
        sg_view src_tex_view;
        sg_image[2] storage_image;
        sg_view[2] storage_simg_views;
        sg_view[2] storage_tex_views;
    } compute;
    struct {
        sg_pipeline pip;
        sg_pass_action pass_action;
    } display;
    struct {
        i32 filter_size;
        i32 iterations;
    } ui;
    struct {
        bool succeeded;
        bool failed;
    } io;
}

private {
state_t state = state_t{
    .display = {
        .pass_action = {
            .colors[0] = {
                .load_action = SG_LOADACTION_CLEAR,
                .clear_value = {0.0f, 0.0f, 0.0f, 1.0f},
            },
        },
    },
    .ui = {.filter_size = 1, .iterations = 2},
};
u8[262144] file_buffer;
}

private {
void init() {
    sg_setup(&sg_desc{.environment = sglue_environment(), .logger = sg_logger{.func = slog_func}});
    sappimgui_setup();
    sgimgui_setup(&sgimgui_desc_t{});
    simgui_setup(&simgui_desc_t{.logger = simgui_logger_t{.func = slog_func}});
    sfetch_setup(&sfetch_desc_t{
        .max_requests = 1,
        .num_channels = 1,
        .num_lanes = 1,
        .logger = sfetch_logger_t{.func = slog_func},
    });
    state.smp = sg_make_sampler(&sg_sampler_desc{
        .min_filter = SG_FILTER_NEAREST,
        .mag_filter = SG_FILTER_NEAREST,
        .wrap_u = SG_WRAP_CLAMP_TO_EDGE,
        .wrap_v = SG_WRAP_CLAMP_TO_EDGE,
        .label = "nearest-sampler",
    });
    sfetch_send(&sfetch_request_t{
        .path = fileutil_get_path("baboon.png", init__path_buf, cast(u64, sizeof(init__path_buf))),
        .callback = fetch_callback,
        .buffer = sfetch_range_t{&file_buffer, sizeof(file_buffer)},
    });
    state.compute.pip = sg_make_pipeline(&sg_pipeline_desc{
        .compute = true,
        .shader = sokol_make_shader(&imageblur_sapp_cs_shader),
        .label = "compute-pipeline",
    });
    state.display.pip = sg_make_pipeline(&sg_pipeline_desc{
        .shader = sokol_make_shader(&imageblur_sapp_vs_shader, &imageblur_sapp_fs_shader),
        .label = "display-pipeline",
    });
}

void frame() {
    sfetch_dowork();
    draw_ui();
    if state.io.succeeded == 0 {
        sg_begin_pass(&sg_pass{.action = state.display.pass_action, .swapchain = sglue_swapchain()});
        simgui_render();
        sg_end_pass();
        sg_commit();
        return;
    }
    sg_begin_pass(&sg_pass{.compute = true, .label = "blur-pass"});
    sg_apply_pipeline(state.compute.pip);
    blur(0, state.compute.storage_simg_views[0], state.compute.src_tex_view);
    blur(1, state.compute.storage_simg_views[1], state.compute.storage_tex_views[0]);
    for i32 i = 0; i < state.ui.iterations - 1; i++ {
        blur(0, state.compute.storage_simg_views[0], state.compute.storage_tex_views[1]);
        blur(1, state.compute.storage_simg_views[1], state.compute.storage_tex_views[0]);
    }
    sg_end_pass();
    sg_begin_pass(&sg_pass{
        .action = state.display.pass_action,
        .swapchain = sglue_swapchain(),
        .label = "display-pass",
    });
    sg_apply_pipeline(state.display.pip);
    sg_apply_bindings(&sg_bindings{
        .views[0] = state.compute.storage_tex_views[1],
        .samplers[0] = state.smp,
    });
    sg_draw(0, 3, 1);
    simgui_render();
    sg_end_pass();
    sg_commit();
}

void cleanup() {
    sfetch_shutdown();
    sappimgui_shutdown();
    sgimgui_shutdown();
    simgui_shutdown();
    sg_shutdown();
}

void input(sapp_event* ev) {
    sappimgui_track_event(ev);
    simgui_handle_event(ev);
}
}

// perform a horizontal or vertical blur pass in a compute shader
void blur(i32 flip, sg_view dst_simg_view, sg_view src_tex_view) {
    i32 batch = 4;
    i32 tile_dim = 128;
    i32 filter_size = state.ui.filter_size | 1;
    var cs_params = cs_params_t{
        .flip = flip,
        .filter_dim = filter_size,
        .block_dim = tile_dim - (filter_size - 1),
    };
    var src_width = cast(f32, flip != 0 ? state.src_height : state.src_width);
    var src_height = cast(f32, flip != 0 ? state.src_width : state.src_height);
    var num_workgroups_x = cast(i32, ceilf(src_width / cast(f32, cs_params.block_dim)));
    var num_workgroups_y = cast(i32, ceilf(src_height / cast(f32, batch)));
    sg_apply_bindings(&sg_bindings{
        .views[0] = src_tex_view,
        .views[1] = dst_simg_view,
        .samplers[0] = state.smp,
    });
    sg_apply_uniforms(UB_cs_params, &sg_range{&cs_params, sizeof(cs_params)});
    sg_dispatch(num_workgroups_x, num_workgroups_y, 1);
}

// called when texture file has finished loading, this creates a
// regular image object with the source pixels, and a storage attachment
// image object which will be written by the compute shader
private {
void fetch_callback(sfetch_response_t* response) {
    if response.fetched != 0 {
        i32 num_channels;
        i32 desired_channels = 4;
        stbi_uc* pixels = stbi_load_from_memory(response.data.ptr, cast(i32, response.data.size), &state.src_width, &state.src_height, &num_channels, desired_channels);
        if pixels != null {
            state.compute.src_image = sg_make_image(&sg_image_desc{
                .width = state.src_width,
                .height = state.src_height,
                .pixel_format = SG_PIXELFORMAT_RGBA8,
                .data = sg_image_data{
                    .mip_levels[0] = {
                        .ptr = pixels,
                        .size = cast(u64, state.src_width * state.src_height * 4),
                    },
                },
                .label = "source-image",
            });
            state.compute.src_tex_view = sg_make_view(&sg_view_desc{
                .texture = sg_texture_view_desc{.image = state.compute.src_image},
                .label = "source-image-texture-view",
            });
            u8*[2] img_labels = {"storage-image-0", "storage-image-1"};
            u8*[2] tex_view_labels = {"storage-image-tex-view-0", "storage-image-tex-view-1"};
            u8*[2] att_view_labels = {"storage-image-att-view-0", "storage-image-att-view-1"};
            for i32 i = 0; i < 2; i++ {
                state.compute.storage_image[i] = sg_make_image(&sg_image_desc{
                    .usage = sg_image_usage{.storage_image = true},
                    .width = state.src_width,
                    .height = state.src_height,
                    .pixel_format = SG_PIXELFORMAT_RGBA8,
                    .label = img_labels[i],
                });
                state.compute.storage_tex_views[i] = sg_make_view(&sg_view_desc{
                    .texture = sg_texture_view_desc{.image = state.compute.storage_image[i]},
                    .label = tex_view_labels[i],
                });
                state.compute.storage_simg_views[i] = sg_make_view(&sg_view_desc{
                    .storage_image = sg_image_view_desc{.image = state.compute.storage_image[i]},
                    .label = att_view_labels[i],
                });
            }
            state.io.succeeded = true;
        }
    } else if response.failed != 0 {
        state.io.failed = true;
    }
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
        if !state.io.succeeded && !state.io.failed {
            ImGui_Text("Loading...");
        } else if state.io.failed != 0 {
            ImGui_Text("Failed to load source texture!");
        } else {
            ImGui_SliderInt("Filter Size", &state.ui.filter_size, 1, 33);
            ImGui_SliderInt("Iterations", &state.ui.iterations, 1, 10);
        }
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
        .depth_format = SAPP_PIXELFORMAT_NONE,
        .window_title = "imageblur-sapp.mc",
        .icon = sapp_icon_desc{.sokol_default = true},
        .logger = sapp_logger{.func = slog_func},
    };
}
private { u8[512] init__path_buf; }
