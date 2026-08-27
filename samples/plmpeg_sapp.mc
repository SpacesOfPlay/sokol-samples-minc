import dbgui;
import sapp_util;
import sokol_fetch;
import vecmath;
import pl_mpeg;

import sokol_all;
import math;

// force high-dpi, sample entry point is __sapp_sample_main()
sapp_desc sokol_main() {
    sapp_desc d = __sapp_sample_main();
    d.high_dpi = true;
    return d;
}

// Extra prelude for samples using sokol_audio.h.
import sokol_audio;

// plmpeg-sapp.glsl, hand-ported to minc @shader.
// Interface mirrors the sokol-shdc program `plmpeg`:
//   attrs: pos(0), normal(1), texcoord(2); uniform block 0: vs_params
//   { mvp }; fragment: the three YCbCr planes + one sampler.

struct PlmpegSappVsOut {
    float4 pos;
    float2 uv;
}

@shader vertex
PlmpegSappVsOut plmpeg_sapp_vs(
    @attr(0) float4 pos,
    @attr(1) float3 normal,
    @attr(2) float2 texcoord,
    @uniform float4x4 mvp
) {
    PlmpegSappVsOut o;
    // The cube is stretched to the video's 16:9 and pushed out along
    // its face normals so the six faces separate.
    float4 p = pos * float4{1.76f, 1.0f, 1.76f, 1.0f}
             + float4{normal * 0.5f, 0.0f};
    o.pos = mul(mvp, p);
    o.uv = texcoord;
    return o;
}

// pl_mpeg hands back three single-channel planes rather than RGB, so
// the conversion happens here. Upstream writes it as `vec4(y,cb,cr,1)
// * rec601`, a row-vector product against a column-major literal;
// written out per channel it is the plain BT.601 matrix, and does not
// depend on either convention being read the same way twice.
@shader fragment
float4 plmpeg_sapp_fs(
    PlmpegSappVsOut input,
    @texture(0) Texture2D tex_y,
    @texture(1) Texture2D tex_cb,
    @texture(2) Texture2D tex_cr,
    @sampler(0) Sampler smp
) {
    f32 y  = sample(tex_y,  smp, input.uv).x;
    f32 cb = sample(tex_cb, smp, input.uv).x;
    f32 cr = sample(tex_cr, smp, input.uv).x;
    return float4{
        1.16438f * y                    + 1.59603f * cr - 0.87079f,
        1.16438f * y - 0.39176f * cb    - 0.81297f * cr + 0.52959f,
        1.16438f * y + 2.01723f * cb                    - 1.08139f,
        1.0f};
}

enum __enum_ATTR_plmpeg_pos {
    ATTR_plmpeg_pos = 0,
    ATTR_plmpeg_normal = 1,
    ATTR_plmpeg_texcoord = 2,
    UB_vs_params = 0,
    VIEW_tex_y = 0,
    VIEW_tex_cb = 1,
    VIEW_tex_cr = 2,
    SMP_smp = 0,
    __shim_end = 255,
}

// Replaces the sokol-shdc generated plmpeg-sapp.glsl.h.
struct vs_params_t {
    mat44_t mvp;
}

// a simple ring buffer for the circular buffer queue
struct ring_t {
    u32 head;
    u32 tail;
    i32[4 + 1] buf;
}

// a vertex with position, normal and texcoords
struct vertex_t {
    f32 x;
    f32 y;
    f32 z;
    f32 nx;
    f32 ny;
    f32 nz;
    f32 u;
    f32 v;
}

struct __anon_plmpeg_sapp_struct_6 {
    i32 width;
    i32 height;
    u64 last_upd_frame;
    sg_image img;
}

private struct state_t {
    plm_t* plm;
    plm_buffer_t* plm_buffer;
    sg_pipeline pip;
    sg_bindings bind;
    sg_pass_action pass_action;
    __anon_plmpeg_sapp_struct_6[3] images;
    ring_t free_buffers;
    ring_t full_buffers;
    i32 cur_download_buffer;
    i32 cur_read_buffer;
    u32 cur_read_pos;
    f32 ry;
    u64 cur_frame;
}

private {
u8* filename = "big-buck-bunny.mpg";
// statically allocated streaming buffers
u8:[4][1024 * 1024] buf;
// how much of each buffer holds file data: the last chunk is short
u32[4] buf_valid;
// the file has been streamed to its end
bool fetch_finished;
}
// application state
private { state_t state; }

// (re)start streaming the file from the beginning
private {
void start_fetch() {
    noinit u8[512] path_buf;
    sfetch_send(&sfetch_request_t{
        .path = fileutil_get_path(filename, path_buf, cast(u64, sizeof(path_buf))),
        .callback = fetch_callback,
        .buffer = sfetch_range_t{
            &buf[state.cur_download_buffer], sizeof(buf[state.cur_download_buffer]),
        },
        .chunk_size = cast(u32, 128 * 1024),
    });
}

// the sokol-app init-callback
void init() {
    for i32 i = 0; i < 4; i++ {
        ring_enqueue(&state.free_buffers, i);
    }
    state.cur_download_buffer = ring_dequeue(&state.free_buffers);
    state.cur_read_buffer = -1;
    sfetch_setup(&sfetch_desc_t{
        .max_requests = 1,
        .num_channels = 1,
        .num_lanes = 1,
        .logger = sfetch_logger_t{.func = slog_func},
    });
    start_fetch();
    sg_setup(&sg_desc{.environment = sglue_environment(), .logger = sg_logger{.func = slog_func}});
    __dbgui_setup();
    vertex_t[16] vertices = {
        vertex_t{-1.0f, -1.0f, -1.0f, 0.0f, 0.0f, -1.0f, 1.0f, 1.0f},
        vertex_t{1.0f, -1.0f, -1.0f, 0.0f, 0.0f, -1.0f, 0.0f, 1.0f},
        vertex_t{1.0f, 1.0f, -1.0f, 0.0f, 0.0f, -1.0f, 0.0f, 0.0f},
        vertex_t{-1.0f, 1.0f, -1.0f, 0.0f, 0.0f, -1.0f, 1.0f, 0.0f},
        vertex_t{-1.0f, -1.0f, 1.0f, 0.0f, 0.0f, 1.0f, 0.0f, 1.0f},
        vertex_t{1.0f, -1.0f, 1.0f, 0.0f, 0.0f, 1.0f, 1.0f, 1.0f},
        vertex_t{1.0f, 1.0f, 1.0f, 0.0f, 0.0f, 1.0f, 1.0f, 0.0f},
        vertex_t{-1.0f, 1.0f, 1.0f, 0.0f, 0.0f, 1.0f, 0.0f, 0.0f},
        vertex_t{-1.0f, -1.0f, -1.0f, -1.0f, 0.0f, 0.0f, 0.0f, 1.0f},
        vertex_t{-1.0f, 1.0f, -1.0f, -1.0f, 0.0f, 0.0f, 0.0f, 0.0f},
        vertex_t{-1.0f, 1.0f, 1.0f, -1.0f, 0.0f, 0.0f, 1.0f, 0.0f},
        vertex_t{-1.0f, -1.0f, 1.0f, -1.0f, 0.0f, 0.0f, 1.0f, 1.0f},
        vertex_t{1.0f, -1.0f, -1.0f, 1.0f, 0.0f, 0.0f, 1.0f, 1.0f},
        vertex_t{1.0f, 1.0f, -1.0f, 1.0f, 0.0f, 0.0f, 1.0f, 0.0f},
        vertex_t{1.0f, 1.0f, 1.0f, 1.0f, 0.0f, 0.0f, 0.0f, 0.0f},
        vertex_t{1.0f, -1.0f, 1.0f, 1.0f, 0.0f, 0.0f, 0.0f, 1.0f},
    };
    state.bind.vertex_buffers[0] = sg_make_buffer(&sg_buffer_desc{
        .data = sg_range{&vertices, sizeof(vertices)},
        .label = "vertices",
    });
    u16[24] indices = {
        0, 1, 2, 0, 2, 3, 6, 5, 4, 7, 6, 4, 8, 9, 10, 8, 10, 11, 14, 13, 12, 15, 14, 12,
    };
    state.bind.index_buffer = sg_make_buffer(&sg_buffer_desc{
        .usage = sg_buffer_usage{.index_buffer = true},
        .data = sg_range{&indices, sizeof(indices)},
        .label = "indices",
    });
    state.pip = sg_make_pipeline(&sg_pipeline_desc{
        .layout = sg_vertex_layout_state{
            .attrs[0] = {.format = SG_VERTEXFORMAT_FLOAT3},
            .attrs[1] = {.format = SG_VERTEXFORMAT_FLOAT3},
            .attrs[2] = {.format = SG_VERTEXFORMAT_FLOAT2},
        },
        .shader = sokol_make_shader(&plmpeg_sapp_vs_shader, &plmpeg_sapp_fs_shader),
        .index_type = SG_INDEXTYPE_UINT16,
        .cull_mode = SG_CULLMODE_NONE,
        .depth = sg_depth_state{.compare = SG_COMPAREFUNC_LESS_EQUAL, .write_enabled = true},
        .label = "pipeline",
    });
    state.bind.samplers[SMP_smp] = sg_make_sampler(&sg_sampler_desc{
        .min_filter = SG_FILTER_LINEAR,
        .mag_filter = SG_FILTER_LINEAR,
        .wrap_u = SG_WRAP_CLAMP_TO_EDGE,
        .wrap_v = SG_WRAP_CLAMP_TO_EDGE,
        .label = "sampler",
    });
    state.pass_action = sg_pass_action{
        .colors[0] = {
            .load_action = SG_LOADACTION_CLEAR,
            .clear_value = {0.0f, 0.569f, 0.918f, 1.0f},
        },
    };
}

// Back to the top of the clip. plm_set_loop() cannot do this on a
// streaming buffer: plm_buffer_rewind() resets the read position of
// bytes the buffer no longer holds, so the file is fetched again.
void restart_stream() {
    plm_rewind(state.plm);
    state.free_buffers.head = 0;
    state.free_buffers.tail = 0;
    state.full_buffers.head = 0;
    state.full_buffers.tail = 0;
    for i32 i = 0; i < 4; i++ {
        ring_enqueue(&state.free_buffers, i);
    }
    state.cur_download_buffer = ring_dequeue(&state.free_buffers);
    state.cur_read_buffer = -1;
    state.cur_read_pos = 0;
    fetch_finished = false;
    start_fetch();
}

// the sokol-app frame callback (video decoding and rendering)
void frame() {
    state.cur_frame++;
    sfetch_dowork();
    if state.plm != null {
        if !ring_empty(&state.full_buffers) || state.cur_read_buffer != -1 {
            plm_decode(state.plm, sapp_frame_duration());
        } else if fetch_finished != 0 {
            restart_stream();
        }
    } else if ring_count(&state.full_buffers) == 2 {
        state.plm_buffer = plm_buffer_create_with_capacity(cast(u64, 1024 * 1024));
        plm_buffer_set_load_callback(state.plm_buffer, plmpeg_load_callback, null);
        state.plm = plm_create_with_buffer(state.plm_buffer, true);
        plm_set_video_decode_callback(state.plm, video_cb, null);
        plm_set_audio_decode_callback(state.plm, audio_cb, null);
        plm_set_loop(state.plm, true);
        plm_set_audio_enabled(state.plm, true, 0);
        plm_set_audio_lead_time(state.plm, 0.25);
        if plm_get_num_audio_streams(state.plm) > 0 {
            saudio_setup(&saudio_desc{
                .sample_rate = plm_get_samplerate(state.plm),
                .buffer_frames = 4096,
                .num_packets = 256,
                .num_channels = 2,
                .logger = saudio_logger{.func = slog_func},
            });
        }
    }
    mat44_t proj = mat44_perspective_fov_rh(vecmath_radians(60.0f), sapp_widthf() / sapp_heightf(), 0.01f, 10.0f);
    mat44_t view = mat44_look_at_rh(vec3(0.0f, 0.0f, 5.0f), vec3(0.0f, 0.0f, 0.0f), vec3(0.0f, 1.0f, 0.0f));
    mat44_t view_proj = mat44_mul_mat44(view, proj);
    state.ry += -0.1f * 60.0f * cast(f32, sapp_frame_duration());
    mat44_t model = mat44_rotation_y(vecmath_radians(state.ry));
    var vs_params = vs_params_t{.mvp = mat44_mul_mat44(model, view_proj)};
    sg_begin_pass(&sg_pass{.action = state.pass_action, .swapchain = sglue_swapchain()});
    if state.bind.views[0].id != cast(u32, SG_INVALID_ID) {
        sg_apply_pipeline(state.pip);
        sg_apply_bindings(&state.bind);
        sg_apply_uniforms(UB_vs_params, &sg_range{&vs_params, sizeof(vs_params)});
        sg_draw(0, 24, 1);
    }
    __dbgui_draw();
    sg_end_pass();
    sg_commit();
}

// the sokol-sapp cleanup callback
void cleanup() {
    __dbgui_shutdown();
    if state.plm_buffer != null {
        plm_buffer_destroy(state.plm_buffer);
    }
    sg_shutdown();
}

// (re-)create a video plane texture on demand, and update it with decoded video-plane data
void validate_texture(i32 slot, plm_plane_t* plane, u8* img_label, u8* view_label) {
    if state.images[slot].width != cast(i32, plane.width) || state.images[slot].height != cast(i32, plane.height) {
        state.images[slot].width = cast(i32, plane.width);
        state.images[slot].height = cast(i32, plane.height);
        sg_destroy_image(state.images[slot].img);
        state.images[slot].img = sg_make_image(&sg_image_desc{
            .width = cast(i32, plane.width),
            .height = cast(i32, plane.height),
            .pixel_format = SG_PIXELFORMAT_R8,
            .usage = sg_image_usage{.stream_update = true},
            .label = img_label,
        });
        sg_destroy_view(state.bind.views[slot]);
        state.bind.views[slot] = sg_make_view(&sg_view_desc{
            .texture = sg_texture_view_desc{.image = state.images[slot].img},
            .label = view_label,
        });
    }
    if state.images[slot].last_upd_frame != state.cur_frame {
        state.images[slot].last_upd_frame = state.cur_frame;
        sg_update_image(state.images[slot].img, &sg_image_data{
            .mip_levels[0] = {
                .ptr = plane.data,
                .size = cast(u64, plane.width * plane.height * sizeof(u8)),
            },
        });
    }
}

// the pl_mpeg video callback, copies decoded video data into textures
void video_cb(plm_t* mpeg, plm_frame_t* frame, void* user) {
    ignore mpeg;
    ignore user;
    validate_texture(VIEW_tex_y, &frame.y, "image-y", "texview-y");
    validate_texture(VIEW_tex_cb, &frame.cb, "image-cb", "texview-cb");
    validate_texture(VIEW_tex_cr, &frame.cr, "image-cr", "texview-cr");
}

// the pl_mpeg audio callback, forwards decoded audio samples to sokol-audio
void audio_cb(plm_t* mpeg, plm_samples_t* samples, void* user) {
    ignore mpeg;
    ignore user;
    // cap the audio backlog: the fifo (256 packets of 128 frames)
    // drains in real time only, so audio queued beyond the 0.25s
    // decode lead plays as a fixed AV lag; drop and resync instead
    if 256 * 128 - saudio_expect() > 16384 {
        return;
    }
    saudio_push(samples.interleaved, cast(i32, samples.count));
}

// the sokol-fetch response callback
void fetch_callback(sfetch_response_t* response) {
    if response.finished != 0 {
        fetch_finished = true;
    }
    if response.fetched != 0 {
        buf_valid[state.cur_download_buffer] = cast(u32, response.data.size);
        ring_enqueue(&state.full_buffers, state.cur_download_buffer);
        if ring_full(&state.full_buffers) || ring_empty(&state.free_buffers) {
            sfetch_pause(response.handle);
        } else {
            state.cur_download_buffer = ring_dequeue(&state.free_buffers);
            sfetch_unbind_buffer(response.handle);
            sfetch_bind_buffer(response.handle, sfetch_range_t{
                &buf[state.cur_download_buffer], sizeof(buf[state.cur_download_buffer]),
            });
        }
    } else if response.paused != 0 {
        if ring_empty(&state.free_buffers) == 0 {
            state.cur_download_buffer = ring_dequeue(&state.free_buffers);
            sfetch_unbind_buffer(response.handle);
            sfetch_bind_buffer(response.handle, sfetch_range_t{
                &buf[state.cur_download_buffer], sizeof(buf[state.cur_download_buffer]),
            });
            sfetch_continue(response.handle);
        }
    }
}

// the plmpeg load callback, this is called when plmpeg needs new data,
// this takes buffers loaded with video data from the "full-queue"
// as needed
void plmpeg_load_callback(plm_buffer_t* self, void* user) {
    ignore user;
    if state.cur_read_buffer == -1 {
        if ring_empty(&state.full_buffers) != 0 {
            return;
        }
        state.cur_read_buffer = ring_dequeue(&state.full_buffers);
        state.cur_read_pos = 0;
    }
    plm_buffer_discard_read_bytes(self);
    var bytes_wanted = cast(u32, self.capacity - self.length);
    u32 bytes_available = buf_valid[state.cur_read_buffer] - state.cur_read_pos;
    u32 bytes_to_copy = bytes_wanted > bytes_available ? bytes_available : bytes_wanted;
    u8* dst = self.bytes + self.length;
    u8* src = &buf[state.cur_read_buffer][state.cur_read_pos];
    memcpy(dst, src, cast(u64, bytes_to_copy));
    self.length += bytes_to_copy;
    state.cur_read_pos += bytes_to_copy;
    if state.cur_read_pos == buf_valid[state.cur_read_buffer] {
        ring_enqueue(&state.free_buffers, state.cur_read_buffer);
        state.cur_read_buffer = -1;
    }
}
}

// sokol-app entry function
sapp_desc __sapp_sample_main() {
    return sapp_desc{
        .init_cb = init,
        .frame_cb = frame,
        .cleanup_cb = cleanup,
        .event_cb = __dbgui_event,
        .width = 960,
        .height = 540,
        .sample_count = 4,
        .window_title = "plmpeg-sapp.mc",
        .icon = sapp_icon_desc{.sokol_default = true},
        .logger = sapp_logger{.func = slog_func},
    };
}

//=== a simple ring buffer implementation ====================================*/
private {
u32 ring_wrap(u32 i) {
    return i % cast(u32, 4 + 1);
}

bool ring_full(ring_t* rb) {
    return ring_wrap(rb.head + 1) == rb.tail;
}

bool ring_empty(ring_t* rb) {
    return rb.head == rb.tail;
}

u32 ring_count(ring_t* rb) {
    u32 count;
    if rb.head >= rb.tail {
        count = rb.head - rb.tail;
    } else {
        count = rb.head + cast(u32, 4 + 1) - rb.tail;
    }
    return count;
}

void ring_enqueue(ring_t* rb, i32 val) {
    rb.buf[rb.head] = val;
    rb.head = ring_wrap(rb.head + 1);
}

i32 ring_dequeue(ring_t* rb) {
    i32 slot_id = rb.buf[rb.tail];
    rb.tail = ring_wrap(rb.tail + 1);
    return slot_id;
}
}
