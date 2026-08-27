// pl_mpeg : transpiled from pl_mpeg.h

// -----------------------------------------------------------------------------
// plm_buffer implementation
enum plm_buffer_mode {
    PLM_BUFFER_MODE_FILE = 0,
    PLM_BUFFER_MODE_FIXED_MEM = 1,
    PLM_BUFFER_MODE_DYNAMIC_MEM = 2,
}

// Callback function type for decoded video frames used by the high-level
// plm_* interface
type plm_video_decode_callback = fn(plm_t*, plm_frame_t*, void*): void;
// Callback function type for decoded audio samples used by the high-level
// plm_* interface
type plm_audio_decode_callback = fn(plm_t*, plm_samples_t*, void*): void;
// Callback function for plm_buffer when it needs more data
type plm_buffer_load_callback = fn(plm_buffer_t*, void*): void;
// Demuxed MPEG PS packet
// The type maps directly to the various MPEG-PES start codes. pts is the
// presentation time stamp of the packet in seconds. Not all packets have
// a pts value.
struct plm_packet_t {
    i32 type;
    f64 pts;
    u64 length;
    u8* data;
}

// Decoded Video Plane
// The byte length of the data is width * height. Note that different planes
// have different sizes: the Luma plane (Y) is double the size of each of
// the two Chroma planes (Cr, Cb) - i.e. 4 times the byte length.
// Also note that the size of the plane does *not* denote the size of the
// displayed frame. The sizes of planes are always rounded up to the nearest
// macroblock (16px).
struct plm_plane_t {
    u32 width;
    u32 height;
    u8* data;
}

// Decoded Video Frame
// width and height denote the desired display size of the frame. This may be
// different from the internal size of the 3 planes.
struct plm_frame_t {
    f64 time;
    u32 width;
    u32 height;
    plm_plane_t y;
    plm_plane_t cr;
    plm_plane_t cb;
}

// Decoded Audio Samples
// Samples are stored as normalized (-1, 1) float either interleaved, or if
// PLM_AUDIO_SEPARATE_CHANNELS is defined, in two separate arrays.
// The `count` is always PLM_AUDIO_SAMPLES_PER_FRAME and just there for
// convenience.
struct plm_samples_t {
    f64 time;
    u32 count;
    f32[1152] left;
    f32[1152] right;
    f32[1152 * 2] interleaved;
}

// -----------------------------------------------------------------------------
// -----------------------------------------------------------------------------
// IMPLEMENTATION
// -----------------------------------------------------------------------------
// plm (high-level interface) implementation
struct plm_t {
    plm_demux_t* demux;
    f64 time;
    i32 has_ended;
    i32 loop;
    i32 video_packet_type;
    plm_buffer_t* video_buffer;
    plm_video_t* video_decoder;
    i32 audio_packet_type;
    f64 audio_lead_time;
    plm_buffer_t* audio_buffer;
    plm_audio_t* audio_decoder;
    plm_video_decode_callback video_decode_callback;
    void* video_decode_callback_user_data;
    plm_audio_decode_callback audio_decode_callback;
    void* audio_decode_callback_user_data;
}

struct plm_buffer_t {
    u64 bit_index;
    u64 capacity;
    u64 length;
    i32 free_when_done;
    i32 close_when_done;
    void* fh;
    plm_buffer_load_callback load_callback;
    void* load_callback_user_data;
    u8* bytes;
    plm_buffer_mode mode;
}

struct plm_vlc_t {
    i16 index;
    i16 value;
}

struct plm_vlc_uint_t {
    i16 index;
    u16 value;
}

struct plm_demux_t {
    plm_buffer_t* buffer;
    i32 destroy_buffer_when_done;
    f64 system_clock_ref;
    i32 has_pack_header;
    i32 has_system_header;
    i32 num_audio_streams;
    i32 num_video_streams;
    plm_packet_t current_packet;
    plm_packet_t next_packet;
}

struct plm_video_motion_t {
    i32 full_px;
    i32 is_set;
    i32 r_size;
    i32 h;
    i32 v;
}

struct plm_video_t {
    f64 framerate;
    f64 time;
    i32 frames_decoded;
    i32 width;
    i32 height;
    i32 mb_width;
    i32 mb_height;
    i32 mb_size;
    i32 luma_width;
    i32 luma_height;
    i32 chroma_width;
    i32 chroma_height;
    i32 start_code;
    i32 picture_type;
    plm_video_motion_t motion_forward;
    plm_video_motion_t motion_backward;
    i32 has_sequence_header;
    i32 quantizer_scale;
    i32 slice_begin;
    i32 macroblock_address;
    i32 mb_row;
    i32 mb_col;
    i32 macroblock_type;
    i32 macroblock_intra;
    i32[3] dc_predictor;
    plm_buffer_t* buffer;
    i32 destroy_buffer_when_done;
    plm_frame_t frame_current;
    plm_frame_t frame_forward;
    plm_frame_t frame_backward;
    u8* frames_data;
    i32[64] block_data;
    u8[64] intra_quant_matrix;
    u8[64] non_intra_quant_matrix;
    i32 has_reference_frame;
    i32 assume_no_b_frames;
}

struct plm_quantizer_spec_t {
    u16 levels;
    u8 group;
    u8 bits;
}

struct plm_audio_t {
    f64 time;
    i32 samples_decoded;
    i32 samplerate_index;
    i32 bitrate_index;
    i32 version;
    i32 layer;
    i32 mode;
    i32 bound;
    i32 v_pos;
    i32 next_frame_data_size;
    plm_buffer_t* buffer;
    i32 destroy_buffer_when_done;
    plm_quantizer_spec_t*:[2][32] allocation;
    u8:[2][32] scale_factor_info;
    i32:[2][32][3] scale_factor;
    i32:[2][32][3] sample;
    plm_samples_t samples;
    f32[1024] D;
    f32[1024] V;
    f32[32] U;
}

// -----------------------------------------------------------------------------
// plm_demux public API
// Demux an MPEG Program Stream (PS) data into separate packages
// Various Packet Types
private {
i32 PLM_DEMUX_PACKET_PRIVATE = 0xBD;
i32 PLM_DEMUX_PACKET_AUDIO_1 = 0xC0;
i32 PLM_DEMUX_PACKET_AUDIO_2 = 0xC1;
i32 PLM_DEMUX_PACKET_AUDIO_3 = 0xC2;
i32 PLM_DEMUX_PACKET_AUDIO_4 = 0xC2;
i32 PLM_DEMUX_PACKET_VIDEO_1 = 0xE0;
}

plm_t* plm_create_with_file(void* fh, i32 close_when_done) {
    plm_buffer_t* buffer = plm_buffer_create_with_file(fh, close_when_done);
    return plm_create_with_buffer(buffer, 1);
}

plm_t* plm_create_with_memory(u8* bytes, u64 length, i32 free_when_done) {
    plm_buffer_t* buffer = plm_buffer_create_with_memory(bytes, length, free_when_done);
    return plm_create_with_buffer(buffer, 1);
}

plm_t* plm_create_with_buffer(plm_buffer_t* buffer, i32 destroy_when_done) {
    var self = new(plm_t);
    memset(self, 0, cast(u64, sizeof(plm_t)));
    self.demux = plm_demux_create(buffer, destroy_when_done);
    self.video_packet_type = PLM_DEMUX_PACKET_VIDEO_1;
    self.video_buffer = plm_buffer_create_with_capacity(cast(u64, 128 * 1024));
    plm_buffer_set_load_callback(self.video_buffer, plm_read_video_packet, self);
    self.audio_packet_type = PLM_DEMUX_PACKET_AUDIO_1;
    self.audio_buffer = plm_buffer_create_with_capacity(cast(u64, 128 * 1024));
    plm_buffer_set_load_callback(self.audio_buffer, plm_read_audio_packet, self);
    self.video_decoder = plm_video_create_with_buffer(self.video_buffer, 1);
    self.audio_decoder = plm_audio_create_with_buffer(self.audio_buffer, 1);
    return self;
}

void plm_destroy(plm_t* self) {
    plm_video_destroy(self.video_decoder);
    plm_audio_destroy(self.audio_decoder);
    plm_demux_destroy(self.demux);
    free(self);
}

i32 plm_get_audio_enabled(plm_t* self) {
    return self.audio_packet_type != 0;
}

void plm_set_audio_enabled(plm_t* self, i32 enabled, i32 stream_index) {
    self.audio_packet_type = enabled && stream_index >= 0 && stream_index < 4 ? PLM_DEMUX_PACKET_AUDIO_1 + stream_index : 0;
}

i32 plm_get_video_enabled(plm_t* self) {
    return self.video_packet_type != 0;
}

void plm_set_video_enabled(plm_t* self, i32 enabled) {
    self.video_packet_type = enabled != 0 ? PLM_DEMUX_PACKET_VIDEO_1 : 0;
}

i32 plm_get_width(plm_t* self) {
    return plm_video_get_width(self.video_decoder);
}

i32 plm_get_height(plm_t* self) {
    return plm_video_get_height(self.video_decoder);
}

f64 plm_get_framerate(plm_t* self) {
    return plm_video_get_framerate(self.video_decoder);
}

i32 plm_get_num_audio_streams(plm_t* self) {
    i32 num_streams = plm_demux_get_num_audio_streams(self.demux);
    return num_streams == 0 && plm_get_samplerate(self) ? 1 : num_streams;
}

i32 plm_get_samplerate(plm_t* self) {
    return plm_audio_get_samplerate(self.audio_decoder);
}

f64 plm_get_audio_lead_time(plm_t* self) {
    return self.audio_lead_time;
}

void plm_set_audio_lead_time(plm_t* self, f64 lead_time) {
    self.audio_lead_time = lead_time;
}

f64 plm_get_time(plm_t* self) {
    return self.time;
}

void plm_rewind(plm_t* self) {
    plm_video_rewind(self.video_decoder);
    plm_audio_rewind(self.audio_decoder);
    plm_demux_rewind(self.demux);
    self.time = 0.0;
}

i32 plm_get_loop(plm_t* self) {
    return self.loop;
}

void plm_set_loop(plm_t* self, i32 loop) {
    self.loop = loop;
}

i32 plm_has_ended(plm_t* self) {
    return self.has_ended;
}

void plm_set_video_decode_callback(plm_t* self, plm_video_decode_callback fp, void* user) {
    self.video_decode_callback = fp;
    self.video_decode_callback_user_data = user;
}

void plm_set_audio_decode_callback(plm_t* self, plm_audio_decode_callback fp, void* user) {
    self.audio_decode_callback = fp;
    self.audio_decode_callback_user_data = user;
}

i32 plm_decode(plm_t* self, f64 tick) {
    i32 decode_video = self.video_decode_callback && self.video_packet_type;
    i32 decode_audio = self.audio_decode_callback && self.audio_packet_type;
    if !decode_video && !decode_audio {
        return 0;
    }
    i32 did_decode = 0;
    i32 video_ended = 0;
    i32 audio_ended = 0;
    f64 video_target_time = self.time + tick;
    f64 audio_target_time = self.time + tick;
    if self.audio_lead_time > 0.0 && decode_audio {
        video_target_time -= self.audio_lead_time;
    } else {
        audio_target_time -= self.audio_lead_time;
    }
    while true {
        did_decode = 0;
        if decode_video && plm_video_get_time(self.video_decoder) < video_target_time {
            plm_frame_t* frame = plm_video_decode(self.video_decoder);
            if frame != null {
                self.video_decode_callback(self, frame, self.video_decode_callback_user_data);
                did_decode = 1;
            } else {
                video_ended = 1;
            }
        }
        if decode_audio && plm_audio_get_time(self.audio_decoder) < audio_target_time {
            plm_samples_t* samples = plm_audio_decode(self.audio_decoder);
            if samples != null {
                self.audio_decode_callback(self, samples, self.audio_decode_callback_user_data);
                did_decode = 1;
            } else {
                audio_ended = 1;
            }
        }
        if !(did_decode != 0) { break; }
    }
    if (!decode_video || video_ended) && (!decode_audio || audio_ended) {
        plm_handle_end(self);
    } else {
        self.time += tick;
    }
    return did_decode != 0 ? 1 : 0;
}

plm_frame_t* plm_decode_video(plm_t* self) {
    if self.video_packet_type == 0 {
        return null;
    }
    plm_frame_t* frame = plm_video_decode(self.video_decoder);
    if frame != null {
        self.time = frame.time;
    } else {
        plm_handle_end(self);
    }
    return frame;
}

plm_samples_t* plm_decode_audio(plm_t* self) {
    if self.audio_packet_type == 0 {
        return null;
    }
    plm_samples_t* samples = plm_audio_decode(self.audio_decoder);
    if samples != null {
        self.time = samples.time;
    } else {
        plm_handle_end(self);
    }
    return samples;
}

void plm_handle_end(plm_t* self) {
    if self.loop != 0 {
        plm_rewind(self);
    } else {
        self.has_ended = 1;
    }
}

void plm_read_video_packet(plm_buffer_t* buffer, void* user) {
    var self = cast(plm_t*, user);
    plm_read_packets(self, self.video_packet_type);
}

void plm_read_audio_packet(plm_buffer_t* buffer, void* user) {
    var self = cast(plm_t*, user);
    plm_read_packets(self, self.audio_packet_type);
}

void plm_read_packets(plm_t* self, i32 requested_type) {
    plm_packet_t* packet;
    while true {
        packet = plm_demux_decode(self.demux);
        if packet == null {
            break;
        }
        if packet.type == self.video_packet_type {
            plm_buffer_write(self.video_buffer, packet.data, packet.length);
        } else if packet.type == self.audio_packet_type {
            plm_buffer_write(self.audio_buffer, packet.data, packet.length);
        }
        if packet.type == requested_type {
            return;
        }
    }
}

plm_buffer_t* plm_buffer_create_with_file(void* fh, i32 close_when_done) {
    plm_buffer_t* self = plm_buffer_create_with_capacity(cast(u64, 128 * 1024));
    self.fh = fh;
    self.close_when_done = close_when_done;
    self.mode = PLM_BUFFER_MODE_FILE;
    plm_buffer_set_load_callback(self, plm_buffer_load_file_callback, null);
    return self;
}

plm_buffer_t* plm_buffer_create_with_memory(u8* bytes, u64 length, i32 free_when_done) {
    var self = new(plm_buffer_t);
    memset(self, 0, cast(u64, sizeof(plm_buffer_t)));
    self.capacity = length;
    self.length = length;
    self.free_when_done = free_when_done;
    self.bytes = bytes;
    self.mode = PLM_BUFFER_MODE_FIXED_MEM;
    return self;
}

plm_buffer_t* plm_buffer_create_with_capacity(u64 capacity) {
    var self = new(plm_buffer_t);
    memset(self, 0, cast(u64, sizeof(plm_buffer_t)));
    self.capacity = capacity;
    self.free_when_done = 1;
    self.bytes = cast(u8*, alloc(cast(i64, capacity)));
    self.mode = PLM_BUFFER_MODE_DYNAMIC_MEM;
    return self;
}

void plm_buffer_destroy(plm_buffer_t* self) {
    if self.fh && self.close_when_done {
        0;
    }
    if self.free_when_done != 0 {
        free(self.bytes);
    }
    free(self);
}

u64 plm_buffer_write(plm_buffer_t* self, u8* bytes, u64 length) {
    if self.mode == PLM_BUFFER_MODE_FIXED_MEM {
        return 0;
    }
    plm_buffer_discard_read_bytes(self);
    u64 bytes_available = self.capacity - self.length;
    if bytes_available < length {
        u64 new_size = self.capacity;
        while true {
            new_size *= 2;
            if !(new_size - self.length < length) { break; }
        }
        self.bytes = cast(u8*, realloc(self.bytes, new_size));
        self.capacity = new_size;
    }
    memcpy(self.bytes + self.length, bytes, length);
    self.length += length;
    return length;
}

void plm_buffer_set_load_callback(plm_buffer_t* self, plm_buffer_load_callback fp, void* user) {
    self.load_callback = fp;
    self.load_callback_user_data = user;
}

void plm_buffer_rewind(plm_buffer_t* self) {
    if self.fh != null {
        0;
        self.length = 0;
    }
    if self.mode != PLM_BUFFER_MODE_FIXED_MEM {
        self.length = 0;
    }
    self.bit_index = 0;
}

void plm_buffer_discard_read_bytes(plm_buffer_t* self) {
    u64 byte_pos = self.bit_index >> 3;
    if byte_pos == self.length {
        self.bit_index = 0;
        self.length = 0;
    } else if byte_pos > 0 {
        memmove(self.bytes, self.bytes + byte_pos, self.length - byte_pos);
        self.bit_index -= byte_pos << 3;
        self.length -= byte_pos;
    }
}

void plm_buffer_load_file_callback(plm_buffer_t* self, void* user) {
    plm_buffer_discard_read_bytes(self);
    u64 bytes_available = self.capacity - self.length;
    u64 bytes_read = 0;
    self.length += bytes_read;
}

i32 plm_buffer_has(plm_buffer_t* self, u64 count) {
    u64 remaining = (self.length << 3) - self.bit_index;
    if remaining >= count {
        return 1;
    }
    if self.load_callback != null {
        self.load_callback(self, self.load_callback_user_data);
        return (self.length << 3) - self.bit_index >= count;
    } else {
        return 0;
    }
}

i32 plm_buffer_read(plm_buffer_t* self, i32 count) {
    if plm_buffer_has(self, cast(u64, count)) == 0 {
        return 0;
    }
    i32 value = 0;
    while count != 0 {
        var current_byte = cast(i32, self.bytes[self.bit_index >> 3]);
        var remaining = cast(i32, 8 - (self.bit_index & 7));
        i32 read_var = remaining < count ? remaining : count;  // renamed from: read
        i32 shift = remaining - read_var;
        i32 mask = 0xff >> 8 - read_var;
        value = value << read_var | (current_byte & mask << shift) >> shift;
        self.bit_index += cast(u64, read_var);
        count -= read_var;
    }
    return value;
}

void plm_buffer_align(plm_buffer_t* self) {
    self.bit_index = self.bit_index + 7 >> 3 << 3;
}

void plm_buffer_skip(plm_buffer_t* self, u64 count) {
    if plm_buffer_has(self, count) != 0 {
        self.bit_index += count;
    }
}

i32 plm_buffer_skip_bytes(plm_buffer_t* self, u8 v) {
    plm_buffer_align(self);
    i32 skipped = 0;
    while plm_buffer_has(self, 8) && self.bytes[self.bit_index >> 3] == v {
        self.bit_index += 8;
        skipped++;
    }
    return skipped;
}

i32 plm_buffer_next_start_code(plm_buffer_t* self) {
    plm_buffer_align(self);
    while plm_buffer_has(self, cast(u64, 5 << 3)) != 0 {
        u64 byte_index = self.bit_index >> 3;
        if self.bytes[byte_index] == 0x00 && self.bytes[byte_index + 1] == 0x00 && self.bytes[byte_index + 2] == 0x01 {
            self.bit_index = byte_index + 4 << 3;
            return cast(i32, self.bytes[byte_index + 3]);
        }
        self.bit_index += 8;
    }
    self.bit_index = self.length << 3;
    return -1;
}

i32 plm_buffer_find_start_code(plm_buffer_t* self, i32 code) {
    i32 current = 0;
    while 1 != 0 {
        current = plm_buffer_next_start_code(self);
        if current == code || current == -1 {
            return current;
        }
    }
    return -1;
}

i32 plm_buffer_no_start_code(plm_buffer_t* self) {
    if plm_buffer_has(self, cast(u64, 5 << 3)) == 0 {
        return 0;
    }
    u64 byte_index = self.bit_index + 7 >> 3;
    return !(self.bytes[byte_index] == 0x00 && self.bytes[byte_index + 1] == 0x00 && self.bytes[byte_index + 2] == 0x01);
}

i16 plm_buffer_read_vlc(plm_buffer_t* self, plm_vlc_t* table) {
    plm_vlc_t state;
    while true {
        state = table[state.index + plm_buffer_read(self, 1)];
        if !(state.index > 0) { break; }
    }
    return state.value;
}

u16 plm_buffer_read_vlc_uint(plm_buffer_t* self, plm_vlc_uint_t* table) {
    return cast(u16, plm_buffer_read_vlc(self, cast(plm_vlc_t*, table)));
}
// ----------------------------------------------------------------------------
// plm_demux implementation
private {
i32 START_PACK = 0xBA;
i32 START_END = 0xB9;
i32 START_SYSTEM = 0xBB;
}

plm_demux_t* plm_demux_create(plm_buffer_t* buffer, i32 destroy_when_done) {
    var self = new(plm_demux_t);
    memset(self, 0, cast(u64, sizeof(plm_demux_t)));
    self.buffer = buffer;
    self.destroy_buffer_when_done = destroy_when_done;
    if plm_buffer_find_start_code(self.buffer, START_PACK) != -1 {
        plm_demux_decode_pack_header(self);
    }
    if plm_buffer_find_start_code(self.buffer, START_SYSTEM) != -1 {
        plm_demux_decode_system_header(self);
    }
    return self;
}

void plm_demux_destroy(plm_demux_t* self) {
    if self.destroy_buffer_when_done != 0 {
        plm_buffer_destroy(self.buffer);
    }
    free(self);
}

i32 plm_demux_get_num_video_streams(plm_demux_t* self) {
    return self.num_video_streams;
}

i32 plm_demux_get_num_audio_streams(plm_demux_t* self) {
    return self.num_audio_streams;
}

void plm_demux_rewind(plm_demux_t* self) {
    plm_buffer_rewind(self.buffer);
}

plm_packet_t* plm_demux_decode(plm_demux_t* self) {
    if self.current_packet.length != 0 {
        u64 bits_till_next_packet = self.current_packet.length << 3;
        if plm_buffer_has(self.buffer, bits_till_next_packet) == 0 {
            return null;
        }
        plm_buffer_skip(self.buffer, bits_till_next_packet);
        self.current_packet.length = 0;
    }
    if self.has_pack_header == 0 {
        if plm_buffer_find_start_code(self.buffer, START_PACK) != -1 {
            plm_demux_decode_pack_header(self);
        } else {
            return null;
        }
    }
    if self.has_system_header == 0 {
        if plm_buffer_find_start_code(self.buffer, START_SYSTEM) != -1 {
            plm_demux_decode_system_header(self);
        } else {
            return null;
        }
    }
    if self.next_packet.length != 0 {
        return plm_demux_get_packet(self);
    }
    i32 code;
    while true {
        code = plm_buffer_next_start_code(self.buffer);
        if code == PLM_DEMUX_PACKET_VIDEO_1 || code == PLM_DEMUX_PACKET_PRIVATE || code >= PLM_DEMUX_PACKET_AUDIO_1 && code <= PLM_DEMUX_PACKET_AUDIO_4 {
            return plm_demux_decode_packet(self, code);
        }
        if !(code != -1) { break; }
    }
    return null;
}

f64 plm_demux_read_time(plm_demux_t* self) {
    i64 clock = plm_buffer_read(self.buffer, 3) << 30;
    plm_buffer_skip(self.buffer, 1);
    clock |= plm_buffer_read(self.buffer, 15) << 15;
    plm_buffer_skip(self.buffer, 1);
    clock |= plm_buffer_read(self.buffer, 15);
    plm_buffer_skip(self.buffer, 1);
    return cast(f64, clock) / 90000.0;
}

void plm_demux_decode_pack_header(plm_demux_t* self) {
    if plm_buffer_read(self.buffer, 4) != 0x02 {
        return;
    }
    self.system_clock_ref = plm_demux_read_time(self);
    plm_buffer_skip(self.buffer, 1);
    plm_buffer_skip(self.buffer, 22);
    plm_buffer_skip(self.buffer, 1);
    self.has_pack_header = 1;
}

void plm_demux_decode_system_header(plm_demux_t* self) {
    plm_buffer_skip(self.buffer, 16);
    plm_buffer_skip(self.buffer, 24);
    self.num_audio_streams = plm_buffer_read(self.buffer, 6);
    plm_buffer_skip(self.buffer, 5);
    self.num_video_streams = plm_buffer_read(self.buffer, 5);
    self.has_system_header = 1;
}

plm_packet_t* plm_demux_decode_packet(plm_demux_t* self, i32 start_code) {
    if plm_buffer_has(self.buffer, cast(u64, 8 << 3)) == 0 {
        return null;
    }
    self.next_packet.type = start_code;
    self.next_packet.length = cast(u64, plm_buffer_read(self.buffer, 16));
    self.next_packet.length -= cast(u64, plm_buffer_skip_bytes(self.buffer, 0xff));
    if plm_buffer_read(self.buffer, 2) == 0x01 {
        plm_buffer_skip(self.buffer, 16);
        self.next_packet.length -= 2;
    }
    i32 pts_dts_marker = plm_buffer_read(self.buffer, 2);
    if pts_dts_marker == 0x03 {
        self.next_packet.pts = plm_demux_read_time(self);
        plm_buffer_skip(self.buffer, 40);
        self.next_packet.length -= 10;
    } else if pts_dts_marker == 0x02 {
        self.next_packet.pts = plm_demux_read_time(self);
        self.next_packet.length -= 5;
    } else if pts_dts_marker == 0x00 {
        self.next_packet.pts = 0.0;
        plm_buffer_skip(self.buffer, 4);
        self.next_packet.length -= 1;
    } else {
        return null;
    }
    return plm_demux_get_packet(self);
}

plm_packet_t* plm_demux_get_packet(plm_demux_t* self) {
    if plm_buffer_has(self.buffer, self.next_packet.length << 3) == 0 {
        return null;
    }
    self.current_packet.data = self.buffer.bytes + (self.buffer.bit_index >> 3);
    self.current_packet.length = self.next_packet.length;
    self.current_packet.type = self.next_packet.type;
    self.current_packet.pts = self.next_packet.pts;
    self.next_packet.length = 0;
    return &self.current_packet;
}
// -----------------------------------------------------------------------------
// plm_video implementation
// Inspired by Java MPEG-1 Video Decoder and Player by Zoltan Korandi
// https://sourceforge.net/projects/javampeg1video/
private {
i32 PLM_VIDEO_PICTURE_TYPE_INTRA = 1;
i32 PLM_VIDEO_PICTURE_TYPE_PREDICTIVE = 2;
i32 PLM_VIDEO_PICTURE_TYPE_B = 3;
i32 PLM_START_SEQUENCE = 0xB3;
i32 PLM_START_SLICE_FIRST = 0x01;
i32 PLM_START_SLICE_LAST = 0xAF;
i32 PLM_START_PICTURE = 0x00;
i32 PLM_START_EXTENSION = 0xB5;
i32 PLM_START_USER_DATA = 0xB2;
f64[16] PLM_VIDEO_PICTURE_RATE = {
    0.0, 23.976, 24.0, 25.0, 29.97, 30.0, 50.0, 59.94, 60.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0,
};
u8[64] PLM_VIDEO_ZIG_ZAG = {
    0, 1, 8, 16, 9, 2, 3, 10, 17, 24, 32, 25, 18, 11, 4, 5, 12, 19, 26, 33, 40, 48, 41, 34, 27, 20,
    13, 6, 7, 14, 21, 28, 35, 42, 49, 56, 57, 50, 43, 36, 29, 22, 15, 23, 30, 37, 44, 51, 58, 59,
    52, 45, 38, 31, 39, 46, 53, 60, 61, 54, 47, 55, 62, 63,
};
u8[64] PLM_VIDEO_INTRA_QUANT_MATRIX = {
    8, 16, 19, 22, 26, 27, 29, 34, 16, 16, 22, 24, 27, 29, 34, 37, 19, 22, 26, 27, 29, 34, 34, 38,
    22, 22, 26, 27, 29, 34, 37, 40, 22, 26, 27, 29, 32, 35, 40, 48, 26, 27, 29, 32, 35, 40, 48, 58,
    26, 27, 29, 34, 38, 46, 56, 69, 27, 29, 35, 38, 46, 56, 69, 83,
};
u8[64] PLM_VIDEO_NON_INTRA_QUANT_MATRIX = {
    16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16,
    16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16,
    16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16,
};
u8[64] PLM_VIDEO_PREMULTIPLIER_MATRIX = {
    32, 44, 42, 38, 32, 25, 17, 9, 44, 62, 58, 52, 44, 35, 24, 12, 42, 58, 55, 49, 42, 33, 23, 12,
    38, 52, 49, 44, 38, 30, 20, 10, 32, 44, 42, 38, 32, 25, 17, 9, 25, 35, 33, 30, 25, 20, 14, 7,
    17, 24, 23, 20, 17, 14, 9, 5, 9, 12, 12, 10, 9, 7, 5, 2,
};
plm_vlc_t[80] PLM_VIDEO_MACROBLOCK_ADDRESS_INCREMENT = {
    plm_vlc_t{1 << 1, 0},
    plm_vlc_t{0, 1},
    plm_vlc_t{2 << 1, 0},
    plm_vlc_t{3 << 1, 0},
    plm_vlc_t{4 << 1, 0},
    plm_vlc_t{5 << 1, 0},
    plm_vlc_t{0, 3},
    plm_vlc_t{0, 2},
    plm_vlc_t{6 << 1, 0},
    plm_vlc_t{7 << 1, 0},
    plm_vlc_t{0, 5},
    plm_vlc_t{0, 4},
    plm_vlc_t{8 << 1, 0},
    plm_vlc_t{9 << 1, 0},
    plm_vlc_t{0, 7},
    plm_vlc_t{0, 6},
    plm_vlc_t{10 << 1, 0},
    plm_vlc_t{11 << 1, 0},
    plm_vlc_t{12 << 1, 0},
    plm_vlc_t{13 << 1, 0},
    plm_vlc_t{14 << 1, 0},
    plm_vlc_t{15 << 1, 0},
    plm_vlc_t{16 << 1, 0},
    plm_vlc_t{17 << 1, 0},
    plm_vlc_t{18 << 1, 0},
    plm_vlc_t{19 << 1, 0},
    plm_vlc_t{0, 9},
    plm_vlc_t{0, 8},
    plm_vlc_t{-1, 0},
    plm_vlc_t{20 << 1, 0},
    plm_vlc_t{-1, 0},
    plm_vlc_t{21 << 1, 0},
    plm_vlc_t{22 << 1, 0},
    plm_vlc_t{23 << 1, 0},
    plm_vlc_t{0, 15},
    plm_vlc_t{0, 14},
    plm_vlc_t{0, 13},
    plm_vlc_t{0, 12},
    plm_vlc_t{0, 11},
    plm_vlc_t{0, 10},
    plm_vlc_t{24 << 1, 0},
    plm_vlc_t{25 << 1, 0},
    plm_vlc_t{26 << 1, 0},
    plm_vlc_t{27 << 1, 0},
    plm_vlc_t{28 << 1, 0},
    plm_vlc_t{29 << 1, 0},
    plm_vlc_t{30 << 1, 0},
    plm_vlc_t{31 << 1, 0},
    plm_vlc_t{32 << 1, 0},
    plm_vlc_t{-1, 0},
    plm_vlc_t{-1, 0},
    plm_vlc_t{33 << 1, 0},
    plm_vlc_t{34 << 1, 0},
    plm_vlc_t{35 << 1, 0},
    plm_vlc_t{36 << 1, 0},
    plm_vlc_t{37 << 1, 0},
    plm_vlc_t{38 << 1, 0},
    plm_vlc_t{39 << 1, 0},
    plm_vlc_t{0, 21},
    plm_vlc_t{0, 20},
    plm_vlc_t{0, 19},
    plm_vlc_t{0, 18},
    plm_vlc_t{0, 17},
    plm_vlc_t{0, 16},
    plm_vlc_t{0, 35},
    plm_vlc_t{-1, 0},
    plm_vlc_t{-1, 0},
    plm_vlc_t{0, 34},
    plm_vlc_t{0, 33},
    plm_vlc_t{0, 32},
    plm_vlc_t{0, 31},
    plm_vlc_t{0, 30},
    plm_vlc_t{0, 29},
    plm_vlc_t{0, 28},
    plm_vlc_t{0, 27},
    plm_vlc_t{0, 26},
    plm_vlc_t{0, 25},
    plm_vlc_t{0, 24},
    plm_vlc_t{0, 23},
    plm_vlc_t{0, 22},
};
plm_vlc_t[4] PLM_VIDEO_MACROBLOCK_TYPE_INTRA = {
    plm_vlc_t{1 << 1, 0},
    plm_vlc_t{0, 0x01},
    plm_vlc_t{-1, 0},
    plm_vlc_t{0, 0x11},
};
plm_vlc_t[14] PLM_VIDEO_MACROBLOCK_TYPE_PREDICTIVE = {
    plm_vlc_t{1 << 1, 0},
    plm_vlc_t{0, 0x0a},
    plm_vlc_t{2 << 1, 0},
    plm_vlc_t{0, 0x02},
    plm_vlc_t{3 << 1, 0},
    plm_vlc_t{0, 0x08},
    plm_vlc_t{4 << 1, 0},
    plm_vlc_t{5 << 1, 0},
    plm_vlc_t{6 << 1, 0},
    plm_vlc_t{0, 0x12},
    plm_vlc_t{0, 0x1a},
    plm_vlc_t{0, 0x01},
    plm_vlc_t{-1, 0},
    plm_vlc_t{0, 0x11},
};
plm_vlc_t[22] PLM_VIDEO_MACROBLOCK_TYPE_B = {
    plm_vlc_t{1 << 1, 0},
    plm_vlc_t{2 << 1, 0},
    plm_vlc_t{3 << 1, 0},
    plm_vlc_t{4 << 1, 0},
    plm_vlc_t{0, 0x0c},
    plm_vlc_t{0, 0x0e},
    plm_vlc_t{5 << 1, 0},
    plm_vlc_t{6 << 1, 0},
    plm_vlc_t{0, 0x04},
    plm_vlc_t{0, 0x06},
    plm_vlc_t{7 << 1, 0},
    plm_vlc_t{8 << 1, 0},
    plm_vlc_t{0, 0x08},
    plm_vlc_t{0, 0x0a},
    plm_vlc_t{9 << 1, 0},
    plm_vlc_t{10 << 1, 0},
    plm_vlc_t{0, 0x1e},
    plm_vlc_t{0, 0x01},
    plm_vlc_t{-1, 0},
    plm_vlc_t{0, 0x11},
    plm_vlc_t{0, 0x16},
    plm_vlc_t{0, 0x1a},
};
plm_vlc_t*[4] PLM_VIDEO_MACROBLOCK_TYPE = {
    null, PLM_VIDEO_MACROBLOCK_TYPE_INTRA, PLM_VIDEO_MACROBLOCK_TYPE_PREDICTIVE,
    PLM_VIDEO_MACROBLOCK_TYPE_B,
};
plm_vlc_t[126] PLM_VIDEO_CODE_BLOCK_PATTERN = {
    plm_vlc_t{1 << 1, 0},
    plm_vlc_t{2 << 1, 0},
    plm_vlc_t{3 << 1, 0},
    plm_vlc_t{4 << 1, 0},
    plm_vlc_t{5 << 1, 0},
    plm_vlc_t{6 << 1, 0},
    plm_vlc_t{7 << 1, 0},
    plm_vlc_t{8 << 1, 0},
    plm_vlc_t{9 << 1, 0},
    plm_vlc_t{10 << 1, 0},
    plm_vlc_t{11 << 1, 0},
    plm_vlc_t{12 << 1, 0},
    plm_vlc_t{13 << 1, 0},
    plm_vlc_t{0, 60},
    plm_vlc_t{14 << 1, 0},
    plm_vlc_t{15 << 1, 0},
    plm_vlc_t{16 << 1, 0},
    plm_vlc_t{17 << 1, 0},
    plm_vlc_t{18 << 1, 0},
    plm_vlc_t{19 << 1, 0},
    plm_vlc_t{20 << 1, 0},
    plm_vlc_t{21 << 1, 0},
    plm_vlc_t{22 << 1, 0},
    plm_vlc_t{23 << 1, 0},
    plm_vlc_t{0, 32},
    plm_vlc_t{0, 16},
    plm_vlc_t{0, 8},
    plm_vlc_t{0, 4},
    plm_vlc_t{24 << 1, 0},
    plm_vlc_t{25 << 1, 0},
    plm_vlc_t{26 << 1, 0},
    plm_vlc_t{27 << 1, 0},
    plm_vlc_t{28 << 1, 0},
    plm_vlc_t{29 << 1, 0},
    plm_vlc_t{30 << 1, 0},
    plm_vlc_t{31 << 1, 0},
    plm_vlc_t{0, 62},
    plm_vlc_t{0, 2},
    plm_vlc_t{0, 61},
    plm_vlc_t{0, 1},
    plm_vlc_t{0, 56},
    plm_vlc_t{0, 52},
    plm_vlc_t{0, 44},
    plm_vlc_t{0, 28},
    plm_vlc_t{0, 40},
    plm_vlc_t{0, 20},
    plm_vlc_t{0, 48},
    plm_vlc_t{0, 12},
    plm_vlc_t{32 << 1, 0},
    plm_vlc_t{33 << 1, 0},
    plm_vlc_t{34 << 1, 0},
    plm_vlc_t{35 << 1, 0},
    plm_vlc_t{36 << 1, 0},
    plm_vlc_t{37 << 1, 0},
    plm_vlc_t{38 << 1, 0},
    plm_vlc_t{39 << 1, 0},
    plm_vlc_t{40 << 1, 0},
    plm_vlc_t{41 << 1, 0},
    plm_vlc_t{42 << 1, 0},
    plm_vlc_t{43 << 1, 0},
    plm_vlc_t{0, 63},
    plm_vlc_t{0, 3},
    plm_vlc_t{0, 36},
    plm_vlc_t{0, 24},
    plm_vlc_t{44 << 1, 0},
    plm_vlc_t{45 << 1, 0},
    plm_vlc_t{46 << 1, 0},
    plm_vlc_t{47 << 1, 0},
    plm_vlc_t{48 << 1, 0},
    plm_vlc_t{49 << 1, 0},
    plm_vlc_t{50 << 1, 0},
    plm_vlc_t{51 << 1, 0},
    plm_vlc_t{52 << 1, 0},
    plm_vlc_t{53 << 1, 0},
    plm_vlc_t{54 << 1, 0},
    plm_vlc_t{55 << 1, 0},
    plm_vlc_t{56 << 1, 0},
    plm_vlc_t{57 << 1, 0},
    plm_vlc_t{58 << 1, 0},
    plm_vlc_t{59 << 1, 0},
    plm_vlc_t{0, 34},
    plm_vlc_t{0, 18},
    plm_vlc_t{0, 10},
    plm_vlc_t{0, 6},
    plm_vlc_t{0, 33},
    plm_vlc_t{0, 17},
    plm_vlc_t{0, 9},
    plm_vlc_t{0, 5},
    plm_vlc_t{-1, 0},
    plm_vlc_t{60 << 1, 0},
    plm_vlc_t{61 << 1, 0},
    plm_vlc_t{62 << 1, 0},
    plm_vlc_t{0, 58},
    plm_vlc_t{0, 54},
    plm_vlc_t{0, 46},
    plm_vlc_t{0, 30},
    plm_vlc_t{0, 57},
    plm_vlc_t{0, 53},
    plm_vlc_t{0, 45},
    plm_vlc_t{0, 29},
    plm_vlc_t{0, 38},
    plm_vlc_t{0, 26},
    plm_vlc_t{0, 37},
    plm_vlc_t{0, 25},
    plm_vlc_t{0, 43},
    plm_vlc_t{0, 23},
    plm_vlc_t{0, 51},
    plm_vlc_t{0, 15},
    plm_vlc_t{0, 42},
    plm_vlc_t{0, 22},
    plm_vlc_t{0, 50},
    plm_vlc_t{0, 14},
    plm_vlc_t{0, 41},
    plm_vlc_t{0, 21},
    plm_vlc_t{0, 49},
    plm_vlc_t{0, 13},
    plm_vlc_t{0, 35},
    plm_vlc_t{0, 19},
    plm_vlc_t{0, 11},
    plm_vlc_t{0, 7},
    plm_vlc_t{0, 39},
    plm_vlc_t{0, 27},
    plm_vlc_t{0, 59},
    plm_vlc_t{0, 55},
    plm_vlc_t{0, 47},
    plm_vlc_t{0, 31},
};
plm_vlc_t[68] PLM_VIDEO_MOTION = {
    plm_vlc_t{1 << 1, 0},
    plm_vlc_t{},
    plm_vlc_t{2 << 1, 0},
    plm_vlc_t{3 << 1, 0},
    plm_vlc_t{4 << 1, 0},
    plm_vlc_t{5 << 1, 0},
    plm_vlc_t{0, 1},
    plm_vlc_t{0, -1},
    plm_vlc_t{6 << 1, 0},
    plm_vlc_t{7 << 1, 0},
    plm_vlc_t{0, 2},
    plm_vlc_t{0, -2},
    plm_vlc_t{8 << 1, 0},
    plm_vlc_t{9 << 1, 0},
    plm_vlc_t{0, 3},
    plm_vlc_t{0, -3},
    plm_vlc_t{10 << 1, 0},
    plm_vlc_t{11 << 1, 0},
    plm_vlc_t{12 << 1, 0},
    plm_vlc_t{13 << 1, 0},
    plm_vlc_t{-1, 0},
    plm_vlc_t{14 << 1, 0},
    plm_vlc_t{15 << 1, 0},
    plm_vlc_t{16 << 1, 0},
    plm_vlc_t{17 << 1, 0},
    plm_vlc_t{18 << 1, 0},
    plm_vlc_t{0, 4},
    plm_vlc_t{0, -4},
    plm_vlc_t{-1, 0},
    plm_vlc_t{19 << 1, 0},
    plm_vlc_t{20 << 1, 0},
    plm_vlc_t{21 << 1, 0},
    plm_vlc_t{0, 7},
    plm_vlc_t{0, -7},
    plm_vlc_t{0, 6},
    plm_vlc_t{0, -6},
    plm_vlc_t{0, 5},
    plm_vlc_t{0, -5},
    plm_vlc_t{22 << 1, 0},
    plm_vlc_t{23 << 1, 0},
    plm_vlc_t{24 << 1, 0},
    plm_vlc_t{25 << 1, 0},
    plm_vlc_t{26 << 1, 0},
    plm_vlc_t{27 << 1, 0},
    plm_vlc_t{28 << 1, 0},
    plm_vlc_t{29 << 1, 0},
    plm_vlc_t{30 << 1, 0},
    plm_vlc_t{31 << 1, 0},
    plm_vlc_t{32 << 1, 0},
    plm_vlc_t{33 << 1, 0},
    plm_vlc_t{0, 10},
    plm_vlc_t{0, -10},
    plm_vlc_t{0, 9},
    plm_vlc_t{0, -9},
    plm_vlc_t{0, 8},
    plm_vlc_t{0, -8},
    plm_vlc_t{0, 16},
    plm_vlc_t{0, -16},
    plm_vlc_t{0, 15},
    plm_vlc_t{0, -15},
    plm_vlc_t{0, 14},
    plm_vlc_t{0, -14},
    plm_vlc_t{0, 13},
    plm_vlc_t{0, -13},
    plm_vlc_t{0, 12},
    plm_vlc_t{0, -12},
    plm_vlc_t{0, 11},
    plm_vlc_t{0, -11},
};
plm_vlc_t[18] PLM_VIDEO_DCT_SIZE_LUMINANCE = {
    plm_vlc_t{1 << 1, 0},
    plm_vlc_t{2 << 1, 0},
    plm_vlc_t{0, 1},
    plm_vlc_t{0, 2},
    plm_vlc_t{3 << 1, 0},
    plm_vlc_t{4 << 1, 0},
    plm_vlc_t{},
    plm_vlc_t{0, 3},
    plm_vlc_t{0, 4},
    plm_vlc_t{5 << 1, 0},
    plm_vlc_t{0, 5},
    plm_vlc_t{6 << 1, 0},
    plm_vlc_t{0, 6},
    plm_vlc_t{7 << 1, 0},
    plm_vlc_t{0, 7},
    plm_vlc_t{8 << 1, 0},
    plm_vlc_t{0, 8},
    plm_vlc_t{-1, 0},
};
plm_vlc_t[18] PLM_VIDEO_DCT_SIZE_CHROMINANCE = {
    plm_vlc_t{1 << 1, 0},
    plm_vlc_t{2 << 1, 0},
    plm_vlc_t{},
    plm_vlc_t{0, 1},
    plm_vlc_t{0, 2},
    plm_vlc_t{3 << 1, 0},
    plm_vlc_t{0, 3},
    plm_vlc_t{4 << 1, 0},
    plm_vlc_t{0, 4},
    plm_vlc_t{5 << 1, 0},
    plm_vlc_t{0, 5},
    plm_vlc_t{6 << 1, 0},
    plm_vlc_t{0, 6},
    plm_vlc_t{7 << 1, 0},
    plm_vlc_t{0, 7},
    plm_vlc_t{8 << 1, 0},
    plm_vlc_t{0, 8},
    plm_vlc_t{-1, 0},
};
plm_vlc_t*[3] PLM_VIDEO_DCT_SIZE = {
    PLM_VIDEO_DCT_SIZE_LUMINANCE, PLM_VIDEO_DCT_SIZE_CHROMINANCE, PLM_VIDEO_DCT_SIZE_CHROMINANCE,
};
//  dct_coeff bitmap:
//    0xff00  run
//    0x00ff  level
//  Decoded values are unsigned. Sign bit follows in the stream.
plm_vlc_uint_t[224] PLM_VIDEO_DCT_COEFF = {
    plm_vlc_uint_t{1 << 1, 0},
    plm_vlc_uint_t{0, 0x0001},
    plm_vlc_uint_t{2 << 1, 0},
    plm_vlc_uint_t{3 << 1, 0},
    plm_vlc_uint_t{4 << 1, 0},
    plm_vlc_uint_t{5 << 1, 0},
    plm_vlc_uint_t{6 << 1, 0},
    plm_vlc_uint_t{0, 0x0101},
    plm_vlc_uint_t{7 << 1, 0},
    plm_vlc_uint_t{8 << 1, 0},
    plm_vlc_uint_t{9 << 1, 0},
    plm_vlc_uint_t{10 << 1, 0},
    plm_vlc_uint_t{0, 0x0002},
    plm_vlc_uint_t{0, 0x0201},
    plm_vlc_uint_t{11 << 1, 0},
    plm_vlc_uint_t{12 << 1, 0},
    plm_vlc_uint_t{13 << 1, 0},
    plm_vlc_uint_t{14 << 1, 0},
    plm_vlc_uint_t{15 << 1, 0},
    plm_vlc_uint_t{0, 0x0003},
    plm_vlc_uint_t{0, 0x0401},
    plm_vlc_uint_t{0, 0x0301},
    plm_vlc_uint_t{16 << 1, 0},
    plm_vlc_uint_t{0, 0xffff},
    plm_vlc_uint_t{17 << 1, 0},
    plm_vlc_uint_t{18 << 1, 0},
    plm_vlc_uint_t{0, 0x0701},
    plm_vlc_uint_t{0, 0x0601},
    plm_vlc_uint_t{0, 0x0102},
    plm_vlc_uint_t{0, 0x0501},
    plm_vlc_uint_t{19 << 1, 0},
    plm_vlc_uint_t{20 << 1, 0},
    plm_vlc_uint_t{21 << 1, 0},
    plm_vlc_uint_t{22 << 1, 0},
    plm_vlc_uint_t{0, 0x0202},
    plm_vlc_uint_t{0, 0x0901},
    plm_vlc_uint_t{0, 0x0004},
    plm_vlc_uint_t{0, 0x0801},
    plm_vlc_uint_t{23 << 1, 0},
    plm_vlc_uint_t{24 << 1, 0},
    plm_vlc_uint_t{25 << 1, 0},
    plm_vlc_uint_t{26 << 1, 0},
    plm_vlc_uint_t{27 << 1, 0},
    plm_vlc_uint_t{28 << 1, 0},
    plm_vlc_uint_t{29 << 1, 0},
    plm_vlc_uint_t{30 << 1, 0},
    plm_vlc_uint_t{0, 0x0d01},
    plm_vlc_uint_t{0, 0x0006},
    plm_vlc_uint_t{0, 0x0c01},
    plm_vlc_uint_t{0, 0x0b01},
    plm_vlc_uint_t{0, 0x0302},
    plm_vlc_uint_t{0, 0x0103},
    plm_vlc_uint_t{0, 0x0005},
    plm_vlc_uint_t{0, 0x0a01},
    plm_vlc_uint_t{31 << 1, 0},
    plm_vlc_uint_t{32 << 1, 0},
    plm_vlc_uint_t{33 << 1, 0},
    plm_vlc_uint_t{34 << 1, 0},
    plm_vlc_uint_t{35 << 1, 0},
    plm_vlc_uint_t{36 << 1, 0},
    plm_vlc_uint_t{37 << 1, 0},
    plm_vlc_uint_t{38 << 1, 0},
    plm_vlc_uint_t{39 << 1, 0},
    plm_vlc_uint_t{40 << 1, 0},
    plm_vlc_uint_t{41 << 1, 0},
    plm_vlc_uint_t{42 << 1, 0},
    plm_vlc_uint_t{43 << 1, 0},
    plm_vlc_uint_t{44 << 1, 0},
    plm_vlc_uint_t{45 << 1, 0},
    plm_vlc_uint_t{46 << 1, 0},
    plm_vlc_uint_t{0, 0x1001},
    plm_vlc_uint_t{0, 0x0502},
    plm_vlc_uint_t{0, 0x0007},
    plm_vlc_uint_t{0, 0x0203},
    plm_vlc_uint_t{0, 0x0104},
    plm_vlc_uint_t{0, 0x0f01},
    plm_vlc_uint_t{0, 0x0e01},
    plm_vlc_uint_t{0, 0x0402},
    plm_vlc_uint_t{47 << 1, 0},
    plm_vlc_uint_t{48 << 1, 0},
    plm_vlc_uint_t{49 << 1, 0},
    plm_vlc_uint_t{50 << 1, 0},
    plm_vlc_uint_t{51 << 1, 0},
    plm_vlc_uint_t{52 << 1, 0},
    plm_vlc_uint_t{53 << 1, 0},
    plm_vlc_uint_t{54 << 1, 0},
    plm_vlc_uint_t{55 << 1, 0},
    plm_vlc_uint_t{56 << 1, 0},
    plm_vlc_uint_t{57 << 1, 0},
    plm_vlc_uint_t{58 << 1, 0},
    plm_vlc_uint_t{59 << 1, 0},
    plm_vlc_uint_t{60 << 1, 0},
    plm_vlc_uint_t{61 << 1, 0},
    plm_vlc_uint_t{62 << 1, 0},
    plm_vlc_uint_t{-1, 0},
    plm_vlc_uint_t{63 << 1, 0},
    plm_vlc_uint_t{64 << 1, 0},
    plm_vlc_uint_t{65 << 1, 0},
    plm_vlc_uint_t{66 << 1, 0},
    plm_vlc_uint_t{67 << 1, 0},
    plm_vlc_uint_t{68 << 1, 0},
    plm_vlc_uint_t{69 << 1, 0},
    plm_vlc_uint_t{70 << 1, 0},
    plm_vlc_uint_t{71 << 1, 0},
    plm_vlc_uint_t{72 << 1, 0},
    plm_vlc_uint_t{73 << 1, 0},
    plm_vlc_uint_t{74 << 1, 0},
    plm_vlc_uint_t{75 << 1, 0},
    plm_vlc_uint_t{76 << 1, 0},
    plm_vlc_uint_t{77 << 1, 0},
    plm_vlc_uint_t{0, 0x000b},
    plm_vlc_uint_t{0, 0x0802},
    plm_vlc_uint_t{0, 0x0403},
    plm_vlc_uint_t{0, 0x000a},
    plm_vlc_uint_t{0, 0x0204},
    plm_vlc_uint_t{0, 0x0702},
    plm_vlc_uint_t{0, 0x1501},
    plm_vlc_uint_t{0, 0x1401},
    plm_vlc_uint_t{0, 0x0009},
    plm_vlc_uint_t{0, 0x1301},
    plm_vlc_uint_t{0, 0x1201},
    plm_vlc_uint_t{0, 0x0105},
    plm_vlc_uint_t{0, 0x0303},
    plm_vlc_uint_t{0, 0x0008},
    plm_vlc_uint_t{0, 0x0602},
    plm_vlc_uint_t{0, 0x1101},
    plm_vlc_uint_t{78 << 1, 0},
    plm_vlc_uint_t{79 << 1, 0},
    plm_vlc_uint_t{80 << 1, 0},
    plm_vlc_uint_t{81 << 1, 0},
    plm_vlc_uint_t{82 << 1, 0},
    plm_vlc_uint_t{83 << 1, 0},
    plm_vlc_uint_t{84 << 1, 0},
    plm_vlc_uint_t{85 << 1, 0},
    plm_vlc_uint_t{86 << 1, 0},
    plm_vlc_uint_t{87 << 1, 0},
    plm_vlc_uint_t{88 << 1, 0},
    plm_vlc_uint_t{89 << 1, 0},
    plm_vlc_uint_t{90 << 1, 0},
    plm_vlc_uint_t{91 << 1, 0},
    plm_vlc_uint_t{0, 0x0a02},
    plm_vlc_uint_t{0, 0x0902},
    plm_vlc_uint_t{0, 0x0503},
    plm_vlc_uint_t{0, 0x0304},
    plm_vlc_uint_t{0, 0x0205},
    plm_vlc_uint_t{0, 0x0107},
    plm_vlc_uint_t{0, 0x0106},
    plm_vlc_uint_t{0, 0x000f},
    plm_vlc_uint_t{0, 0x000e},
    plm_vlc_uint_t{0, 0x000d},
    plm_vlc_uint_t{0, 0x000c},
    plm_vlc_uint_t{0, 0x1a01},
    plm_vlc_uint_t{0, 0x1901},
    plm_vlc_uint_t{0, 0x1801},
    plm_vlc_uint_t{0, 0x1701},
    plm_vlc_uint_t{0, 0x1601},
    plm_vlc_uint_t{92 << 1, 0},
    plm_vlc_uint_t{93 << 1, 0},
    plm_vlc_uint_t{94 << 1, 0},
    plm_vlc_uint_t{95 << 1, 0},
    plm_vlc_uint_t{96 << 1, 0},
    plm_vlc_uint_t{97 << 1, 0},
    plm_vlc_uint_t{98 << 1, 0},
    plm_vlc_uint_t{99 << 1, 0},
    plm_vlc_uint_t{100 << 1, 0},
    plm_vlc_uint_t{101 << 1, 0},
    plm_vlc_uint_t{102 << 1, 0},
    plm_vlc_uint_t{103 << 1, 0},
    plm_vlc_uint_t{0, 0x001f},
    plm_vlc_uint_t{0, 0x001e},
    plm_vlc_uint_t{0, 0x001d},
    plm_vlc_uint_t{0, 0x001c},
    plm_vlc_uint_t{0, 0x001b},
    plm_vlc_uint_t{0, 0x001a},
    plm_vlc_uint_t{0, 0x0019},
    plm_vlc_uint_t{0, 0x0018},
    plm_vlc_uint_t{0, 0x0017},
    plm_vlc_uint_t{0, 0x0016},
    plm_vlc_uint_t{0, 0x0015},
    plm_vlc_uint_t{0, 0x0014},
    plm_vlc_uint_t{0, 0x0013},
    plm_vlc_uint_t{0, 0x0012},
    plm_vlc_uint_t{0, 0x0011},
    plm_vlc_uint_t{0, 0x0010},
    plm_vlc_uint_t{104 << 1, 0},
    plm_vlc_uint_t{105 << 1, 0},
    plm_vlc_uint_t{106 << 1, 0},
    plm_vlc_uint_t{107 << 1, 0},
    plm_vlc_uint_t{108 << 1, 0},
    plm_vlc_uint_t{109 << 1, 0},
    plm_vlc_uint_t{110 << 1, 0},
    plm_vlc_uint_t{111 << 1, 0},
    plm_vlc_uint_t{0, 0x0028},
    plm_vlc_uint_t{0, 0x0027},
    plm_vlc_uint_t{0, 0x0026},
    plm_vlc_uint_t{0, 0x0025},
    plm_vlc_uint_t{0, 0x0024},
    plm_vlc_uint_t{0, 0x0023},
    plm_vlc_uint_t{0, 0x0022},
    plm_vlc_uint_t{0, 0x0021},
    plm_vlc_uint_t{0, 0x0020},
    plm_vlc_uint_t{0, 0x010e},
    plm_vlc_uint_t{0, 0x010d},
    plm_vlc_uint_t{0, 0x010c},
    plm_vlc_uint_t{0, 0x010b},
    plm_vlc_uint_t{0, 0x010a},
    plm_vlc_uint_t{0, 0x0109},
    plm_vlc_uint_t{0, 0x0108},
    plm_vlc_uint_t{0, 0x0112},
    plm_vlc_uint_t{0, 0x0111},
    plm_vlc_uint_t{0, 0x0110},
    plm_vlc_uint_t{0, 0x010f},
    plm_vlc_uint_t{0, 0x0603},
    plm_vlc_uint_t{0, 0x1002},
    plm_vlc_uint_t{0, 0x0f02},
    plm_vlc_uint_t{0, 0x0e02},
    plm_vlc_uint_t{0, 0x0d02},
    plm_vlc_uint_t{0, 0x0c02},
    plm_vlc_uint_t{0, 0x0b02},
    plm_vlc_uint_t{0, 0x1f01},
    plm_vlc_uint_t{0, 0x1e01},
    plm_vlc_uint_t{0, 0x1d01},
    plm_vlc_uint_t{0, 0x1c01},
    plm_vlc_uint_t{0, 0x1b01},
};

u8 plm_clamp(i32 n) {
    return cast(u8, n > 255 ? 255 : n < 0 ? 0 : n);
}
}

plm_video_t* plm_video_create_with_buffer(plm_buffer_t* buffer, i32 destroy_when_done) {
    var self = new(plm_video_t);
    memset(self, 0, cast(u64, sizeof(plm_video_t)));
    self.buffer = buffer;
    self.destroy_buffer_when_done = destroy_when_done;
    self.start_code = plm_buffer_find_start_code(self.buffer, PLM_START_SEQUENCE);
    if self.start_code != -1 {
        plm_video_decode_sequence_header(self);
    }
    return self;
}

void plm_video_destroy(plm_video_t* self) {
    if self.destroy_buffer_when_done != 0 {
        plm_buffer_destroy(self.buffer);
    }
    if self.has_sequence_header != 0 {
        free(self.frames_data);
    }
    free(self);
}

f64 plm_video_get_framerate(plm_video_t* self) {
    return self.framerate;
}

i32 plm_video_get_width(plm_video_t* self) {
    return self.width;
}

i32 plm_video_get_height(plm_video_t* self) {
    return self.height;
}

void plm_video_set_no_delay(plm_video_t* self, i32 no_delay) {
    self.assume_no_b_frames = no_delay;
}

f64 plm_video_get_time(plm_video_t* self) {
    return self.time;
}

void plm_video_rewind(plm_video_t* self) {
    plm_buffer_rewind(self.buffer);
    self.time = 0.0;
    self.frames_decoded = 0;
    self.has_reference_frame = 0;
}

plm_frame_t* plm_video_decode(plm_video_t* self) {
    if self.has_sequence_header == 0 {
        self.start_code = plm_buffer_find_start_code(self.buffer, PLM_START_SEQUENCE);
        if self.start_code == -1 {
            return null;
        }
        plm_video_decode_sequence_header(self);
    }
    plm_frame_t* frame = null;
    while true {
        if self.start_code != PLM_START_PICTURE {
            self.start_code = plm_buffer_find_start_code(self.buffer, PLM_START_PICTURE);
        }
        if self.start_code == -1 {
            return null;
        }
        plm_video_decode_picture(self);
        if self.assume_no_b_frames != 0 {
            frame = &self.frame_backward;
        } else if self.picture_type == PLM_VIDEO_PICTURE_TYPE_B {
            frame = &self.frame_current;
        } else if self.has_reference_frame != 0 {
            frame = &self.frame_forward;
        } else {
            self.has_reference_frame = 1;
        }
        if !(frame == null) { break; }
    }
    frame.time = self.time;
    self.frames_decoded++;
    self.time = cast(f64, self.frames_decoded) / self.framerate;
    return frame;
}

void plm_video_decode_sequence_header(plm_video_t* self) {
    i32 previous_width = self.width;
    i32 previous_height = self.height;
    self.width = plm_buffer_read(self.buffer, 12);
    self.height = plm_buffer_read(self.buffer, 12);
    plm_buffer_skip(self.buffer, 4);
    self.framerate = PLM_VIDEO_PICTURE_RATE[plm_buffer_read(self.buffer, 4)];
    plm_buffer_skip(self.buffer, cast(u64, 18 + 1 + 10 + 1));
    if plm_buffer_read(self.buffer, 1) != 0 {
        for i32 i = 0; i < 64; i++ {
            var idx = cast(i32, PLM_VIDEO_ZIG_ZAG[i]);
            self.intra_quant_matrix[idx] = cast(u8, plm_buffer_read(self.buffer, 8));
        }
    } else {
        memcpy(self.intra_quant_matrix, PLM_VIDEO_INTRA_QUANT_MATRIX, cast(u64, 64));
    }
    if plm_buffer_read(self.buffer, 1) != 0 {
        for i32 i = 0; i < 64; i++ {
            var idx = cast(i32, PLM_VIDEO_ZIG_ZAG[i]);
            self.non_intra_quant_matrix[idx] = cast(u8, plm_buffer_read(self.buffer, 8));
        }
    } else {
        memcpy(self.non_intra_quant_matrix, PLM_VIDEO_NON_INTRA_QUANT_MATRIX, cast(u64, 64));
    }
    if self.has_sequence_header != 0 {
        if self.width == previous_width && self.height == previous_height {
            return;
        }
        free(self.frames_data);
    }
    self.mb_width = self.width + 15 >> 4;
    self.mb_height = self.height + 15 >> 4;
    self.mb_size = self.mb_width * self.mb_height;
    self.luma_width = self.mb_width << 4;
    self.luma_height = self.mb_height << 4;
    self.chroma_width = self.mb_width << 3;
    self.chroma_height = self.mb_height << 3;
    var luma_plane_size = cast(u64, self.luma_width * self.luma_height);
    var chroma_plane_size = cast(u64, self.chroma_width * self.chroma_height);
    u64 frame_data_size = luma_plane_size + 2 * chroma_plane_size;
    self.frames_data = cast(u8*, alloc(cast(i64, frame_data_size * 3)));
    plm_video_init_frame(self, &self.frame_current, self.frames_data + frame_data_size * 0);
    plm_video_init_frame(self, &self.frame_forward, self.frames_data + frame_data_size * 1);
    plm_video_init_frame(self, &self.frame_backward, self.frames_data + frame_data_size * 2);
    self.has_sequence_header = 1;
}

void plm_video_init_frame(plm_video_t* self, plm_frame_t* frame, u8* base) {
    var luma_plane_size = cast(u64, self.luma_width * self.luma_height);
    var chroma_plane_size = cast(u64, self.chroma_width * self.chroma_height);
    frame.width = cast(u32, self.width);
    frame.height = cast(u32, self.height);
    frame.y.width = cast(u32, self.luma_width);
    frame.y.height = cast(u32, self.luma_height);
    frame.y.data = base;
    frame.cr.width = cast(u32, self.chroma_width);
    frame.cr.height = cast(u32, self.chroma_height);
    frame.cr.data = base + luma_plane_size;
    frame.cb.width = cast(u32, self.chroma_width);
    frame.cb.height = cast(u32, self.chroma_height);
    frame.cb.data = base + luma_plane_size + chroma_plane_size;
}

void plm_video_decode_picture(plm_video_t* self) {
    plm_buffer_skip(self.buffer, 10);
    self.picture_type = plm_buffer_read(self.buffer, 3);
    plm_buffer_skip(self.buffer, 16);
    if self.picture_type <= 0 || self.picture_type > PLM_VIDEO_PICTURE_TYPE_B {
        return;
    }
    if self.picture_type == PLM_VIDEO_PICTURE_TYPE_PREDICTIVE || self.picture_type == PLM_VIDEO_PICTURE_TYPE_B {
        self.motion_forward.full_px = plm_buffer_read(self.buffer, 1);
        i32 f_code = plm_buffer_read(self.buffer, 3);
        if f_code == 0 {
            return;
        }
        self.motion_forward.r_size = f_code - 1;
    }
    if self.picture_type == PLM_VIDEO_PICTURE_TYPE_B {
        self.motion_backward.full_px = plm_buffer_read(self.buffer, 1);
        i32 f_code = plm_buffer_read(self.buffer, 3);
        if f_code == 0 {
            return;
        }
        self.motion_backward.r_size = f_code - 1;
    }
    plm_frame_t frame_temp = self.frame_forward;
    if self.picture_type == PLM_VIDEO_PICTURE_TYPE_INTRA || self.picture_type == PLM_VIDEO_PICTURE_TYPE_PREDICTIVE {
        self.frame_forward = self.frame_backward;
    }
    while true {
        self.start_code = plm_buffer_next_start_code(self.buffer);
        if !(self.start_code == PLM_START_EXTENSION || self.start_code == PLM_START_USER_DATA) { break; }
    }
    while self.start_code >= PLM_START_SLICE_FIRST && self.start_code <= PLM_START_SLICE_LAST {
        plm_video_decode_slice(self, self.start_code & 0x000000FF);
        if self.macroblock_address == self.mb_size - 1 {
            break;
        }
        self.start_code = plm_buffer_next_start_code(self.buffer);
    }
    if self.picture_type == PLM_VIDEO_PICTURE_TYPE_INTRA || self.picture_type == PLM_VIDEO_PICTURE_TYPE_PREDICTIVE {
        self.frame_backward = self.frame_current;
        self.frame_current = frame_temp;
    }
}

void plm_video_decode_slice(plm_video_t* self, i32 slice) {
    self.slice_begin = 1;
    self.macroblock_address = (slice - 1) * self.mb_width - 1;
    self.motion_forward.h = 0;
    self.motion_backward.h = self.motion_forward.h;
    self.motion_forward.v = 0;
    self.motion_backward.v = self.motion_forward.v;
    self.dc_predictor[0] = 128;
    self.dc_predictor[1] = 128;
    self.dc_predictor[2] = 128;
    self.quantizer_scale = plm_buffer_read(self.buffer, 5);
    while plm_buffer_read(self.buffer, 1) != 0 {
        plm_buffer_skip(self.buffer, 8);
    }
    while true {
        plm_video_decode_macroblock(self);
        if !(self.macroblock_address < self.mb_size - 1 && plm_buffer_no_start_code(self.buffer)) { break; }
    }
}

void plm_video_decode_macroblock(plm_video_t* self) {
    i32 increment = 0;
    i32 t = plm_buffer_read_vlc(self.buffer, PLM_VIDEO_MACROBLOCK_ADDRESS_INCREMENT);
    while t == 34 {
        t = plm_buffer_read_vlc(self.buffer, PLM_VIDEO_MACROBLOCK_ADDRESS_INCREMENT);
    }
    while t == 35 {
        increment += 33;
        t = plm_buffer_read_vlc(self.buffer, PLM_VIDEO_MACROBLOCK_ADDRESS_INCREMENT);
    }
    increment += t;
    if self.slice_begin != 0 {
        self.slice_begin = 0;
        self.macroblock_address += increment;
    } else {
        if self.macroblock_address + increment >= self.mb_size {
            return;
        }
        if increment > 1 {
            self.dc_predictor[0] = 128;
            self.dc_predictor[1] = 128;
            self.dc_predictor[2] = 128;
            if self.picture_type == PLM_VIDEO_PICTURE_TYPE_PREDICTIVE {
                self.motion_forward.h = 0;
                self.motion_forward.v = 0;
            }
        }
        while increment > 1 {
            self.macroblock_address++;
            self.mb_row = self.macroblock_address / self.mb_width;
            self.mb_col = self.macroblock_address % self.mb_width;
            plm_video_predict_macroblock(self);
            increment--;
        }
        self.macroblock_address++;
    }
    self.mb_row = self.macroblock_address / self.mb_width;
    self.mb_col = self.macroblock_address % self.mb_width;
    if self.mb_col >= self.mb_width || self.mb_row >= self.mb_height {
        return;
    }
    plm_vlc_t* table = PLM_VIDEO_MACROBLOCK_TYPE[self.picture_type];
    self.macroblock_type = plm_buffer_read_vlc(self.buffer, table);
    self.macroblock_intra = self.macroblock_type & 0x01;
    self.motion_forward.is_set = self.macroblock_type & 0x08;
    self.motion_backward.is_set = self.macroblock_type & 0x04;
    if (self.macroblock_type & 0x10) != 0 {
        self.quantizer_scale = plm_buffer_read(self.buffer, 5);
    }
    if self.macroblock_intra != 0 {
        self.motion_forward.h = 0;
        self.motion_backward.h = self.motion_forward.h;
        self.motion_forward.v = 0;
        self.motion_backward.v = self.motion_forward.v;
    } else {
        self.dc_predictor[0] = 128;
        self.dc_predictor[1] = 128;
        self.dc_predictor[2] = 128;
        plm_video_decode_motion_vectors(self);
        plm_video_predict_macroblock(self);
    }
    i32 cbp = (self.macroblock_type & 0x02) != 0 ? plm_buffer_read_vlc(self.buffer, PLM_VIDEO_CODE_BLOCK_PATTERN) : self.macroblock_intra != 0 ? 0x3f : 0;
    {
        i32 block = 0;
        i32 mask = 0x20;
        for ; block < 6; block++ {
            if (cbp & mask) != 0 {
                plm_video_decode_block(self, block);
            }
            mask >>= 1;
        }
    }
}

void plm_video_decode_motion_vectors(plm_video_t* self) {
    if self.motion_forward.is_set != 0 {
        i32 r_size = self.motion_forward.r_size;
        self.motion_forward.h = plm_video_decode_motion_vector(self, r_size, self.motion_forward.h);
        self.motion_forward.v = plm_video_decode_motion_vector(self, r_size, self.motion_forward.v);
    } else if self.picture_type == PLM_VIDEO_PICTURE_TYPE_PREDICTIVE {
        self.motion_forward.h = 0;
        self.motion_forward.v = 0;
    }
    if self.motion_backward.is_set != 0 {
        i32 r_size = self.motion_backward.r_size;
        self.motion_backward.h = plm_video_decode_motion_vector(self, r_size, self.motion_backward.h);
        self.motion_backward.v = plm_video_decode_motion_vector(self, r_size, self.motion_backward.v);
    }
}

i32 plm_video_decode_motion_vector(plm_video_t* self, i32 r_size, i32 motion) {
    i32 fscale = 1 << r_size;
    i32 m_code = plm_buffer_read_vlc(self.buffer, PLM_VIDEO_MOTION);
    i32 r = 0;
    i32 d;
    if m_code != 0 && fscale != 1 {
        r = plm_buffer_read(self.buffer, r_size);
        d = (abs(m_code) - 1 << r_size) + r + 1;
        if m_code < 0 {
            d = -d;
        }
    } else {
        d = m_code;
    }
    motion += d;
    if motion > (fscale << 4) - 1 {
        motion -= fscale << 5;
    } else if motion < -fscale << 4 {
        motion += fscale << 5;
    }
    return motion;
}

void plm_video_predict_macroblock(plm_video_t* self) {
    i32 fw_h = self.motion_forward.h;
    i32 fw_v = self.motion_forward.v;
    if self.motion_forward.full_px != 0 {
        fw_h <<= 1;
        fw_v <<= 1;
    }
    if self.picture_type == PLM_VIDEO_PICTURE_TYPE_B {
        i32 bw_h = self.motion_backward.h;
        i32 bw_v = self.motion_backward.v;
        if self.motion_backward.full_px != 0 {
            bw_h <<= 1;
            bw_v <<= 1;
        }
        if self.motion_forward.is_set != 0 {
            plm_video_copy_macroblock(self, fw_h, fw_v, &self.frame_forward);
            if self.motion_backward.is_set != 0 {
                plm_video_interpolate_macroblock(self, bw_h, bw_v, &self.frame_backward);
            }
        } else {
            plm_video_copy_macroblock(self, bw_h, bw_v, &self.frame_backward);
        }
    } else {
        plm_video_copy_macroblock(self, fw_h, fw_v, &self.frame_forward);
    }
}

void plm_video_copy_macroblock(plm_video_t* self, i32 motion_h, i32 motion_v, plm_frame_t* d) {
    plm_frame_t* s = &self.frame_current;
    plm_video_process_macroblock(self, s.y.data, d.y.data, motion_h, motion_v, 16, 0);
    plm_video_process_macroblock(self, s.cr.data, d.cr.data, motion_h / 2, motion_v / 2, 8, 0);
    plm_video_process_macroblock(self, s.cb.data, d.cb.data, motion_h / 2, motion_v / 2, 8, 0);
}

void plm_video_interpolate_macroblock(plm_video_t* self, i32 motion_h, i32 motion_v, plm_frame_t* d) {
    plm_frame_t* s = &self.frame_current;
    plm_video_process_macroblock(self, s.y.data, d.y.data, motion_h, motion_v, 16, 1);
    plm_video_process_macroblock(self, s.cr.data, d.cr.data, motion_h / 2, motion_v / 2, 8, 1);
    plm_video_process_macroblock(self, s.cb.data, d.cb.data, motion_h / 2, motion_v / 2, 8, 1);
}

void plm_video_process_macroblock(plm_video_t* self, u8* d, u8* s, i32 motion_h, i32 motion_v, i32 block_size, i32 interpolate) {
    i32 dw = self.mb_width * block_size;
    i32 hp = motion_h >> 1;
    i32 vp = motion_v >> 1;
    i32 odd_h = (motion_h & 1) == 1;
    i32 odd_v = (motion_v & 1) == 1;
    var si = cast(u32, (self.mb_row * block_size + vp) * dw + self.mb_col * block_size + hp);
    var di = cast(u32, (self.mb_row * dw + self.mb_col) * block_size);
    var max_address = cast(u32, dw * (self.mb_height * block_size - block_size + 1) - block_size);
    if si > max_address || di > max_address {
        return;
    }
    switch interpolate << 2 | odd_h << 1 | odd_v {
        case 0 << 2 | 0 << 1 | 0: {
            while true {
                i32 dest_scan = dw - block_size;
                i32 source_scan = dw - block_size;
                for i32 y = 0; y < block_size; y++ {
                    for i32 x = 0; x < block_size; x++ {
                        d[di] = s[si];
                        si++;
                        di++;
                    }
                    si += cast(u32, source_scan);
                    di += cast(u32, dest_scan);
                }
                if !(0 != 0) { break; }
            }
        }
        case 0 << 2 | 0 << 1 | 1: {
            while true {
                i32 dest_scan = dw - block_size;
                i32 source_scan = dw - block_size;
                for i32 y = 0; y < block_size; y++ {
                    for i32 x = 0; x < block_size; x++ {
                        d[di] = cast(u8, s[si] + s[si + cast(u32, dw)] + 1 >> 1);
                        si++;
                        di++;
                    }
                    si += cast(u32, source_scan);
                    di += cast(u32, dest_scan);
                }
                if !(0 != 0) { break; }
            }
        }
        case 0 << 2 | 1 << 1 | 0: {
            while true {
                i32 dest_scan = dw - block_size;
                i32 source_scan = dw - block_size;
                for i32 y = 0; y < block_size; y++ {
                    for i32 x = 0; x < block_size; x++ {
                        d[di] = cast(u8, s[si] + s[si + 1] + 1 >> 1);
                        si++;
                        di++;
                    }
                    si += cast(u32, source_scan);
                    di += cast(u32, dest_scan);
                }
                if !(0 != 0) { break; }
            }
        }
        case 0 << 2 | 1 << 1 | 1: {
            while true {
                i32 dest_scan = dw - block_size;
                i32 source_scan = dw - block_size;
                for i32 y = 0; y < block_size; y++ {
                    for i32 x = 0; x < block_size; x++ {
                        d[di] = cast(u8, s[si] + s[si + 1] + s[si + cast(u32, dw)] + s[si + cast(u32, dw) + 1] + 2 >> 2);
                        si++;
                        di++;
                    }
                    si += cast(u32, source_scan);
                    di += cast(u32, dest_scan);
                }
                if !(0 != 0) { break; }
            }
        }
        case 1 << 2 | 0 << 1 | 0: {
            while true {
                i32 dest_scan = dw - block_size;
                i32 source_scan = dw - block_size;
                for i32 y = 0; y < block_size; y++ {
                    for i32 x = 0; x < block_size; x++ {
                        d[di] = cast(u8, d[di] + s[si] + 1 >> 1);
                        si++;
                        di++;
                    }
                    si += cast(u32, source_scan);
                    di += cast(u32, dest_scan);
                }
                if !(0 != 0) { break; }
            }
        }
        case 1 << 2 | 0 << 1 | 1: {
            while true {
                i32 dest_scan = dw - block_size;
                i32 source_scan = dw - block_size;
                for i32 y = 0; y < block_size; y++ {
                    for i32 x = 0; x < block_size; x++ {
                        d[di] = cast(u8, d[di] + (s[si] + s[si + cast(u32, dw)] + 1 >> 1) + 1 >> 1);
                        si++;
                        di++;
                    }
                    si += cast(u32, source_scan);
                    di += cast(u32, dest_scan);
                }
                if !(0 != 0) { break; }
            }
        }
        case 1 << 2 | 1 << 1 | 0: {
            while true {
                i32 dest_scan = dw - block_size;
                i32 source_scan = dw - block_size;
                for i32 y = 0; y < block_size; y++ {
                    for i32 x = 0; x < block_size; x++ {
                        d[di] = cast(u8, d[di] + (s[si] + s[si + 1] + 1 >> 1) + 1 >> 1);
                        si++;
                        di++;
                    }
                    si += cast(u32, source_scan);
                    di += cast(u32, dest_scan);
                }
                if !(0 != 0) { break; }
            }
        }
        case 1 << 2 | 1 << 1 | 1: {
            while true {
                i32 dest_scan = dw - block_size;
                i32 source_scan = dw - block_size;
                for i32 y = 0; y < block_size; y++ {
                    for i32 x = 0; x < block_size; x++ {
                        d[di] = cast(u8, d[di] + (s[si] + s[si + 1] + s[si + cast(u32, dw)] + s[si + cast(u32, dw) + 1] + 2 >> 2) + 1 >> 1);
                        si++;
                        di++;
                    }
                    si += cast(u32, source_scan);
                    di += cast(u32, dest_scan);
                }
                if !(0 != 0) { break; }
            }
        }
    }
}

void plm_video_decode_block(plm_video_t* self, i32 block) {
    i32 n = 0;
    u8* quant_matrix;
    if self.macroblock_intra != 0 {
        i32 predictor;
        i32 dct_size;
        i32 plane_index = block > 3 ? block - 3 : 0;
        predictor = self.dc_predictor[plane_index];
        dct_size = plm_buffer_read_vlc(self.buffer, PLM_VIDEO_DCT_SIZE[plane_index]);
        if dct_size > 0 {
            i32 differential = plm_buffer_read(self.buffer, dct_size);
            if (differential & 1 << dct_size - 1) != 0 {
                self.block_data[0] = predictor + differential;
            } else {
                self.block_data[0] = predictor + (-1 << dct_size | differential + 1);
            }
        } else {
            self.block_data[0] = predictor;
        }
        self.dc_predictor[plane_index] = self.block_data[0];
        self.block_data[0] <<= 3 + 5;
        quant_matrix = self.intra_quant_matrix;
        n = 1;
    } else {
        quant_matrix = self.non_intra_quant_matrix;
    }
    i32 level = 0;
    while 1 != 0 {
        i32 run = 0;
        u16 coeff = plm_buffer_read_vlc_uint(self.buffer, PLM_VIDEO_DCT_COEFF);
        if coeff == 0x0001 && n > 0 && plm_buffer_read(self.buffer, 1) == 0 {
            break;
        }
        if coeff == 0xffff {
            run = plm_buffer_read(self.buffer, 6);
            level = plm_buffer_read(self.buffer, 8);
            if level == 0 {
                level = plm_buffer_read(self.buffer, 8);
            } else if level == 128 {
                level = plm_buffer_read(self.buffer, 8) - 256;
            } else if level > 128 {
                level = level - 256;
            }
        } else {
            run = cast(i32, coeff) >> 8;
            level = cast(i32, coeff & 0xff);
            if plm_buffer_read(self.buffer, 1) != 0 {
                level = -level;
            }
        }
        n += run;
        if n < 0 || n >= 64 {
            return;
        }
        var de_zig_zagged = cast(i32, PLM_VIDEO_ZIG_ZAG[n]);
        n++;
        level <<= 1;
        if self.macroblock_intra == 0 {
            level += level < 0 ? -1 : 1;
        }
        level = level * self.quantizer_scale * quant_matrix[de_zig_zagged] >> 4;
        if (level & 1) == 0 {
            level -= level > 0 ? 1 : -1;
        }
        if level > 2047 {
            level = 2047;
        } else if level < -2048 {
            level = -2048;
        }
        self.block_data[de_zig_zagged] = level * PLM_VIDEO_PREMULTIPLIER_MATRIX[de_zig_zagged];
    }
    u8* d;
    i32 dw;
    i32 di;
    if block < 4 {
        d = self.frame_current.y.data;
        dw = self.luma_width;
        di = self.mb_row * self.luma_width + self.mb_col << 4;
        if (block & 1) != 0 {
            di += 8;
        }
        if (block & 2) != 0 {
            di += self.luma_width << 3;
        }
    } else {
        d = block == 4 ? self.frame_current.cb.data : self.frame_current.cr.data;
        dw = self.chroma_width;
        di = (self.mb_row * self.luma_width << 2) + (self.mb_col << 3);
    }
    i32* s = self.block_data;
    i32 si = 0;
    if self.macroblock_intra != 0 {
        if n == 1 {
            var clamped = cast(i32, plm_clamp(s[0] + 128 >> 8));
            while true {
                i32 dest_scan = dw - 8;
                i32 source_scan = 8 - 8;
                for i32 y = 0; y < 8; y++ {
                    for i32 x = 0; x < 8; x++ {
                        d[di] = cast(u8, clamped);
                        si++;
                        di++;
                    }
                    si += source_scan;
                    di += dest_scan;
                }
                if !(0 != 0) { break; }
            }
            s[0] = 0;
        } else {
            plm_video_idct(s);
            while true {
                i32 dest_scan = dw - 8;
                i32 source_scan = 8 - 8;
                for i32 y = 0; y < 8; y++ {
                    for i32 x = 0; x < 8; x++ {
                        d[di] = plm_clamp(s[si]);
                        si++;
                        di++;
                    }
                    si += source_scan;
                    di += dest_scan;
                }
                if !(0 != 0) { break; }
            }
            memset(self.block_data, 0, cast(u64, sizeof(self.block_data)));
        }
    } else {
        if n == 1 {
            i32 value = s[0] + 128 >> 8;
            while true {
                i32 dest_scan = dw - 8;
                i32 source_scan = 8 - 8;
                for i32 y = 0; y < 8; y++ {
                    for i32 x = 0; x < 8; x++ {
                        d[di] = plm_clamp(d[di] + value);
                        si++;
                        di++;
                    }
                    si += source_scan;
                    di += dest_scan;
                }
                if !(0 != 0) { break; }
            }
            s[0] = 0;
        } else {
            plm_video_idct(s);
            while true {
                i32 dest_scan = dw - 8;
                i32 source_scan = 8 - 8;
                for i32 y = 0; y < 8; y++ {
                    for i32 x = 0; x < 8; x++ {
                        d[di] = plm_clamp(d[di] + s[si]);
                        si++;
                        di++;
                    }
                    si += source_scan;
                    di += dest_scan;
                }
                if !(0 != 0) { break; }
            }
            memset(self.block_data, 0, cast(u64, sizeof(self.block_data)));
        }
    }
}

void plm_video_idct(i32* block) {
    i32 b1;
    i32 b3;
    i32 b4;
    i32 b6;
    i32 b7;
    i32 tmp1;
    i32 tmp2;
    i32 m0;
    i32 x0;
    i32 x1;
    i32 x2;
    i32 x3;
    i32 x4;
    i32 y3;
    i32 y4;
    i32 y5;
    i32 y6;
    i32 y7;
    for i32 i = 0; i < 8; ++i {
        b1 = block[4 * 8 + i];
        b3 = block[2 * 8 + i] + block[6 * 8 + i];
        b4 = block[5 * 8 + i] - block[3 * 8 + i];
        tmp1 = block[1 * 8 + i] + block[7 * 8 + i];
        tmp2 = block[3 * 8 + i] + block[5 * 8 + i];
        b6 = block[1 * 8 + i] - block[7 * 8 + i];
        b7 = tmp1 + tmp2;
        m0 = block[0 * 8 + i];
        x4 = (b6 * 473 - b4 * 196 + 128 >> 8) - b7;
        x0 = x4 - ((tmp1 - tmp2) * 362 + 128 >> 8);
        x1 = m0 - b1;
        x2 = ((block[2 * 8 + i] - block[6 * 8 + i]) * 362 + 128 >> 8) - b3;
        x3 = m0 + b1;
        y3 = x1 + x2;
        y4 = x3 + b3;
        y5 = x1 - x2;
        y6 = x3 - b3;
        y7 = -x0 - (b4 * 473 + b6 * 196 + 128 >> 8);
        block[0 * 8 + i] = b7 + y4;
        block[1 * 8 + i] = x4 + y3;
        block[2 * 8 + i] = y5 - x0;
        block[3 * 8 + i] = y6 - y7;
        block[4 * 8 + i] = y6 + y7;
        block[5 * 8 + i] = x0 + y5;
        block[6 * 8 + i] = y3 - x4;
        block[7 * 8 + i] = y4 - b7;
    }
    for i32 i = 0; i < 64; i += 8 {
        b1 = block[4 + i];
        b3 = block[2 + i] + block[6 + i];
        b4 = block[5 + i] - block[3 + i];
        tmp1 = block[1 + i] + block[7 + i];
        tmp2 = block[3 + i] + block[5 + i];
        b6 = block[1 + i] - block[7 + i];
        b7 = tmp1 + tmp2;
        m0 = block[0 + i];
        x4 = (b6 * 473 - b4 * 196 + 128 >> 8) - b7;
        x0 = x4 - ((tmp1 - tmp2) * 362 + 128 >> 8);
        x1 = m0 - b1;
        x2 = ((block[2 + i] - block[6 + i]) * 362 + 128 >> 8) - b3;
        x3 = m0 + b1;
        y3 = x1 + x2;
        y4 = x3 + b3;
        y5 = x1 - x2;
        y6 = x3 - b3;
        y7 = -x0 - (b4 * 473 + b6 * 196 + 128 >> 8);
        block[0 + i] = b7 + y4 + 128 >> 8;
        block[1 + i] = x4 + y3 + 128 >> 8;
        block[2 + i] = y5 - x0 + 128 >> 8;
        block[3 + i] = y6 - y7 + 128 >> 8;
        block[4 + i] = y6 + y7 + 128 >> 8;
        block[5 + i] = x0 + y5 + 128 >> 8;
        block[6 + i] = y3 - x4 + 128 >> 8;
        block[7 + i] = y4 - b7 + 128 >> 8;
    }
}

void plm_frame_to_rgb(plm_frame_t* frame, u8* rgb) {
    var w = cast(i32, frame.y.width);
    i32 w2 = w >> 1;
    i32 y_index1 = 0;
    i32 y_index2 = w;
    var y_next_2_lines = cast(i32, cast(u32, w) + (cast(u32, w) - frame.width));
    i32 c_index = 0;
    var c_next_line = cast(i32, cast(u32, w2) - (frame.width >> 1));
    i32 rgb_index1 = 0;
    var rgb_index2 = cast(i32, frame.width * 3);
    var rgb_next_2_lines = cast(i32, frame.width * 3);
    var cols = cast(i32, frame.width >> 1);
    var rows = cast(i32, frame.height >> 1);
    i32 ccb;
    i32 ccr;
    i32 r;
    i32 g;
    i32 b;
    u8* y = frame.y.data;
    u8* cb = frame.cb.data;
    u8* cr = frame.cr.data;
    for i32 row = 0; row < rows; row++ {
        for i32 col = 0; col < cols; col++ {
            ccb = cast(i32, cb[c_index]);
            ccr = cast(i32, cr[c_index]);
            c_index++;
            r = ccr + (ccr * 103 >> 8) - 179;
            g = (ccb * 88 >> 8) - 44 + (ccr * 183 >> 8) - 91;
            b = ccb + (ccb * 198 >> 8) - 227;
            var y1 = cast(i32, y[y_index1++]);
            var y2 = cast(i32, y[y_index1++]);
            rgb[rgb_index1 + 0] = plm_clamp(y1 + r);
            rgb[rgb_index1 + 1] = plm_clamp(y1 - g);
            rgb[rgb_index1 + 2] = plm_clamp(y1 + b);
            rgb[rgb_index1 + 3] = plm_clamp(y2 + r);
            rgb[rgb_index1 + 4] = plm_clamp(y2 - g);
            rgb[rgb_index1 + 5] = plm_clamp(y2 + b);
            rgb_index1 += 6;
            var y3 = cast(i32, y[y_index2++]);
            var y4 = cast(i32, y[y_index2++]);
            rgb[rgb_index2 + 0] = plm_clamp(y3 + r);
            rgb[rgb_index2 + 1] = plm_clamp(y3 - g);
            rgb[rgb_index2 + 2] = plm_clamp(y3 + b);
            rgb[rgb_index2 + 3] = plm_clamp(y4 + r);
            rgb[rgb_index2 + 4] = plm_clamp(y4 - g);
            rgb[rgb_index2 + 5] = plm_clamp(y4 + b);
            rgb_index2 += 6;
        }
        y_index1 += y_next_2_lines;
        y_index2 += y_next_2_lines;
        rgb_index1 += rgb_next_2_lines;
        rgb_index2 += rgb_next_2_lines;
        c_index += c_next_line;
    }
}
// -----------------------------------------------------------------------------
// plm_audio implementation
// Based on kjmp2 by Martin J. Fiedler
// http://keyj.emphy.de/kjmp2/
private {
i32 PLM_AUDIO_FRAME_SYNC = 0x7ff;
i32 PLM_AUDIO_MPEG_2_5 = 0x0;
i32 PLM_AUDIO_MPEG_2 = 0x2;
i32 PLM_AUDIO_MPEG_1 = 0x3;
i32 PLM_AUDIO_LAYER_III = 0x1;
i32 PLM_AUDIO_LAYER_II = 0x2;
i32 PLM_AUDIO_LAYER_I = 0x3;
i32 PLM_AUDIO_MODE_STEREO = 0x0;
i32 PLM_AUDIO_MODE_JOINT_STEREO = 0x1;
i32 PLM_AUDIO_MODE_DUAL_CHANNEL = 0x2;
i32 PLM_AUDIO_MODE_MONO = 0x3;
u16[8] PLM_AUDIO_SAMPLE_RATE = {44100, 48000, 32000, 0, 22050, 24000, 16000, 0};
i16[28] PLM_AUDIO_BIT_RATE = {
    32, 48, 56, 64, 80, 96, 112, 128, 160, 192, 224, 256, 320, 384, 8, 16, 24, 32, 40, 48, 56, 64,
    80, 96, 112, 128, 144, 160,
};
i32[3] PLM_AUDIO_SCALEFACTOR_BASE = {0x02000000, 0x01965FEA, 0x01428A30};
f32[512] PLM_AUDIO_SYNTHESIS_WINDOW = {
    0.0f, -0.5f, -0.5f, -0.5f, -0.5f, -0.5f, -0.5f, -1.0f, -1.0f, -1.0f, -1.0f, -1.5f, -1.5f, -2.0f,
    -2.0f, -2.5f, -2.5f, -3.0f, -3.5f, -3.5f, -4.0f, -4.5f, -5.0f, -5.5f, -6.5f, -7.0f, -8.0f,
    -8.5f, -9.5f, -10.5f, -12.0f, -13.0f, -14.5f, -15.5f, -17.5f, -19.0f, -20.5f, -22.5f, -24.5f,
    -26.5f, -29.0f, -31.5f, -34.0f, -36.5f, -39.5f, -42.5f, -45.5f, -48.5f, -52.0f, -55.5f, -58.5f,
    -62.5f, -66.0f, -69.5f, -73.5f, -77.0f, -80.5f, -84.5f, -88.0f, -91.5f, -95.0f, -98.0f, -101.0f,
    -104.0f, 106.5f, 109.0f, 111.0f, 112.5f, 113.5f, 114.0f, 114.0f, 113.5f, 112.0f, 110.5f, 107.5f,
    104.0f, 100.0f, 94.5f, 88.5f, 81.5f, 73.0f, 63.5f, 53.0f, 41.5f, 28.5f, 14.5f, -1.0f, -18.0f,
    -36.0f, -55.5f, -76.5f, -98.5f, -122.0f, -147.0f, -173.5f, -200.5f, -229.5f, -259.5f, -290.5f,
    -322.5f, -355.5f, -389.5f, -424.0f, -459.5f, -495.5f, -532.0f, -568.5f, -605.0f, -641.5f,
    -678.0f, -714.0f, -749.0f, -783.5f, -817.0f, -849.0f, -879.5f, -908.5f, -935.0f, -959.5f,
    -981.0f, -1000.5f, -1016.0f, -1028.5f, -1037.5f, -1042.5f, -1043.5f, -1040.0f, -1031.5f,
    1018.5f, 1000.0f, 976.0f, 946.5f, 911.0f, 869.5f, 822.0f, 767.5f, 707.0f, 640.0f, 565.5f,
    485.0f, 397.0f, 302.5f, 201.0f, 92.5f, -22.5f, -144.0f, -272.5f, -407.0f, -547.5f, -694.0f,
    -846.0f, -1003.0f, -1165.0f, -1331.5f, -1502.0f, -1675.5f, -1852.5f, -2031.5f, -2212.5f,
    -2394.0f, -2576.5f, -2758.5f, -2939.5f, -3118.5f, -3294.5f, -3467.5f, -3635.5f, -3798.5f,
    -3955.0f, -4104.5f, -4245.5f, -4377.5f, -4499.0f, -4609.5f, -4708.0f, -4792.5f, -4863.5f,
    -4919.0f, -4958.0f, -4979.5f, -4983.0f, -4967.5f, -4931.5f, -4875.0f, -4796.0f, -4694.5f,
    -4569.5f, -4420.0f, -4246.0f, -4046.0f, -3820.0f, -3567.0f, 3287.0f, 2979.5f, 2644.0f, 2280.5f,
    1888.0f, 1467.5f, 1018.5f, 541.0f, 35.0f, -499.0f, -1061.0f, -1650.0f, -2266.5f, -2909.0f,
    -3577.0f, -4270.0f, -4987.5f, -5727.5f, -6490.0f, -7274.0f, -8077.5f, -8899.5f, -9739.0f,
    -10594.5f, -11464.5f, -12347.0f, -13241.0f, -14144.5f, -15056.0f, -15973.5f, -16895.5f,
    -17820.0f, -18744.5f, -19668.0f, -20588.0f, -21503.0f, -22410.5f, -23308.5f, -24195.0f,
    -25068.5f, -25926.5f, -26767.0f, -27589.0f, -28389.0f, -29166.5f, -29919.0f, -30644.5f,
    -31342.0f, -32009.5f, -32645.0f, -33247.0f, -33814.5f, -34346.0f, -34839.5f, -35295.0f,
    -35710.0f, -36084.5f, -36417.5f, -36707.5f, -36954.0f, -37156.5f, -37315.0f, -37428.0f,
    -37496.0f, 37519.0f, 37496.0f, 37428.0f, 37315.0f, 37156.5f, 36954.0f, 36707.5f, 36417.5f,
    36084.5f, 35710.0f, 35295.0f, 34839.5f, 34346.0f, 33814.5f, 33247.0f, 32645.0f, 32009.5f,
    31342.0f, 30644.5f, 29919.0f, 29166.5f, 28389.0f, 27589.0f, 26767.0f, 25926.5f, 25068.5f,
    24195.0f, 23308.5f, 22410.5f, 21503.0f, 20588.0f, 19668.0f, 18744.5f, 17820.0f, 16895.5f,
    15973.5f, 15056.0f, 14144.5f, 13241.0f, 12347.0f, 11464.5f, 10594.5f, 9739.0f, 8899.5f, 8077.5f,
    7274.0f, 6490.0f, 5727.5f, 4987.5f, 4270.0f, 3577.0f, 2909.0f, 2266.5f, 1650.0f, 1061.0f,
    499.0f, -35.0f, -541.0f, -1018.5f, -1467.5f, -1888.0f, -2280.5f, -2644.0f, -2979.5f, 3287.0f,
    3567.0f, 3820.0f, 4046.0f, 4246.0f, 4420.0f, 4569.5f, 4694.5f, 4796.0f, 4875.0f, 4931.5f,
    4967.5f, 4983.0f, 4979.5f, 4958.0f, 4919.0f, 4863.5f, 4792.5f, 4708.0f, 4609.5f, 4499.0f,
    4377.5f, 4245.5f, 4104.5f, 3955.0f, 3798.5f, 3635.5f, 3467.5f, 3294.5f, 3118.5f, 2939.5f,
    2758.5f, 2576.5f, 2394.0f, 2212.5f, 2031.5f, 1852.5f, 1675.5f, 1502.0f, 1331.5f, 1165.0f,
    1003.0f, 846.0f, 694.0f, 547.5f, 407.0f, 272.5f, 144.0f, 22.5f, -92.5f, -201.0f, -302.5f,
    -397.0f, -485.0f, -565.5f, -640.0f, -707.0f, -767.5f, -822.0f, -869.5f, -911.0f, -946.5f,
    -976.0f, -1000.0f, 1018.5f, 1031.5f, 1040.0f, 1043.5f, 1042.5f, 1037.5f, 1028.5f, 1016.0f,
    1000.5f, 981.0f, 959.5f, 935.0f, 908.5f, 879.5f, 849.0f, 817.0f, 783.5f, 749.0f, 714.0f, 678.0f,
    641.5f, 605.0f, 568.5f, 532.0f, 495.5f, 459.5f, 424.0f, 389.5f, 355.5f, 322.5f, 290.5f, 259.5f,
    229.5f, 200.5f, 173.5f, 147.0f, 122.0f, 98.5f, 76.5f, 55.5f, 36.0f, 18.0f, 1.0f, -14.5f, -28.5f,
    -41.5f, -53.0f, -63.5f, -73.0f, -81.5f, -88.5f, -94.5f, -100.0f, -104.0f, -107.5f, -110.5f,
    -112.0f, -113.5f, -114.0f, -114.0f, -113.5f, -112.5f, -111.0f, -109.0f, 106.5f, 104.0f, 101.0f,
    98.0f, 95.0f, 91.5f, 88.0f, 84.5f, 80.5f, 77.0f, 73.5f, 69.5f, 66.0f, 62.5f, 58.5f, 55.5f,
    52.0f, 48.5f, 45.5f, 42.5f, 39.5f, 36.5f, 34.0f, 31.5f, 29.0f, 26.5f, 24.5f, 22.5f, 20.5f,
    19.0f, 17.5f, 15.5f, 14.5f, 13.0f, 12.0f, 10.5f, 9.5f, 8.5f, 8.0f, 7.0f, 6.5f, 5.5f, 5.0f, 4.5f,
    4.0f, 3.5f, 3.5f, 3.0f, 2.5f, 2.5f, 2.0f, 2.0f, 1.5f, 1.5f, 1.0f, 1.0f, 1.0f, 1.0f, 0.5f, 0.5f,
    0.5f, 0.5f, 0.5f, 0.5f,
};
// Quantizer lookup, step 1: bitrate classes
u8:[2][16] PLM_AUDIO_QUANT_LUT_STEP_1 = {
    {0, 0, 1, 1, 1, 2, 2, 2, 2, 2, 2, 2, 2, 2},
    {0, 0, 0, 0, 0, 0, 1, 1, 1, 2, 2, 2, 2, 2},
};
// Quantizer lookup, step 2: bitrate class, sample rate -> B2 table idx, sblimit
u8:[3][3] QUANT_LUT_STEP_2 = {{8, 8, 12}, {91, 91, 91}, {94, 91, 94}};
// Quantizer lookup, step 3: B2 table, subband -> nbal, row index
// (upper 4 bits: nbal, lower 4 bits: row index)
u8:[3][32] PLM_AUDIO_QUANT_LUT_STEP_3 = {
    {0x44, 0x44, 0x34, 0x34, 0x34, 0x34, 0x34, 0x34, 0x34, 0x34, 0x34, 0x34},
    {
        0x43, 0x43, 0x43, 0x42, 0x42, 0x42, 0x42, 0x42, 0x42, 0x42, 0x42, 0x31, 0x31, 0x31, 0x31,
        0x31, 0x31, 0x31, 0x31, 0x31, 0x31, 0x31, 0x31, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20,
    },
    {
        0x45, 0x45, 0x45, 0x45, 0x34, 0x34, 0x34, 0x34, 0x34, 0x34, 0x34, 0x24, 0x24, 0x24, 0x24,
        0x24, 0x24, 0x24, 0x24, 0x24, 0x24, 0x24, 0x24, 0x24, 0x24, 0x24, 0x24, 0x24, 0x24, 0x24,
    },
};
// Quantizer lookup, step 4: table row, allocation[] value -> quant table index
u8:[6][16] PLM_AUDIO_QUANT_LUT_STEP4 = {
    {0, 1, 2, 17},
    {0, 1, 2, 3, 4, 5, 6, 17},
    {0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 17},
    {0, 1, 3, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17},
    {0, 1, 2, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 17},
    {0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15},
};
plm_quantizer_spec_t[17] PLM_AUDIO_QUANT_TAB = {
    plm_quantizer_spec_t{3, 1, 5},
    plm_quantizer_spec_t{5, 1, 7},
    plm_quantizer_spec_t{7, 0, 3},
    plm_quantizer_spec_t{9, 1, 10},
    plm_quantizer_spec_t{15, 0, 4},
    plm_quantizer_spec_t{31, 0, 5},
    plm_quantizer_spec_t{63, 0, 6},
    plm_quantizer_spec_t{127, 0, 7},
    plm_quantizer_spec_t{255, 0, 8},
    plm_quantizer_spec_t{511, 0, 9},
    plm_quantizer_spec_t{1023, 0, 10},
    plm_quantizer_spec_t{2047, 0, 11},
    plm_quantizer_spec_t{4095, 0, 12},
    plm_quantizer_spec_t{8191, 0, 13},
    plm_quantizer_spec_t{16383, 0, 14},
    plm_quantizer_spec_t{32767, 0, 15},
    plm_quantizer_spec_t{65535, 0, 16},
};
}

plm_audio_t* plm_audio_create_with_buffer(plm_buffer_t* buffer, i32 destroy_when_done) {
    var self = new(plm_audio_t);
    memset(self, 0, cast(u64, sizeof(plm_audio_t)));
    self.samples.count = 1152;
    self.buffer = buffer;
    self.destroy_buffer_when_done = destroy_when_done;
    self.samplerate_index = 3;
    memcpy(self.D, PLM_AUDIO_SYNTHESIS_WINDOW, cast(u64, 512 * sizeof(f32)));
    memcpy(self.D + 512, PLM_AUDIO_SYNTHESIS_WINDOW, cast(u64, 512 * sizeof(f32)));
    if plm_buffer_has(self.buffer, 48) != 0 {
        self.next_frame_data_size = plm_audio_decode_header(self);
    }
    return self;
}

void plm_audio_destroy(plm_audio_t* self) {
    if self.destroy_buffer_when_done != 0 {
        plm_buffer_destroy(self.buffer);
    }
    free(self);
}

i32 plm_audio_get_samplerate(plm_audio_t* self) {
    return cast(i32, PLM_AUDIO_SAMPLE_RATE[self.samplerate_index]);
}

f64 plm_audio_get_time(plm_audio_t* self) {
    return self.time;
}

void plm_audio_rewind(plm_audio_t* self) {
    plm_buffer_rewind(self.buffer);
    self.time = 0.0;
    self.samples_decoded = 0;
    self.next_frame_data_size = 0;
    memset(self.V, 0, cast(u64, sizeof(self.V)));
    memset(self.U, 0, cast(u64, sizeof(self.U)));
}

plm_samples_t* plm_audio_decode(plm_audio_t* self) {
    if self.next_frame_data_size == 0 {
        if plm_buffer_has(self.buffer, 48) == 0 {
            return null;
        }
        self.next_frame_data_size = plm_audio_decode_header(self);
    }
    if self.next_frame_data_size == 0 || !plm_buffer_has(self.buffer, cast(u64, self.next_frame_data_size << 3)) {
        return null;
    }
    plm_audio_decode_frame(self);
    self.next_frame_data_size = 0;
    self.samples.time = self.time;
    self.samples_decoded += 1152;
    self.time = cast(f64, self.samples_decoded) / cast(f64, PLM_AUDIO_SAMPLE_RATE[self.samplerate_index]);
    return &self.samples;
}

i32 plm_audio_decode_header(plm_audio_t* self) {
    plm_buffer_skip_bytes(self.buffer, 0x00);
    i32 sync = plm_buffer_read(self.buffer, 11);
    self.version = plm_buffer_read(self.buffer, 2);
    self.layer = plm_buffer_read(self.buffer, 2);
    i32 hasCRC = !plm_buffer_read(self.buffer, 1);
    if sync != PLM_AUDIO_FRAME_SYNC || self.version != PLM_AUDIO_MPEG_1 || self.layer != PLM_AUDIO_LAYER_II {
        return 0;
    }
    self.bitrate_index = plm_buffer_read(self.buffer, 4) - 1;
    if self.bitrate_index > 13 {
        return 0;
    }
    self.samplerate_index = plm_buffer_read(self.buffer, 2);
    if self.samplerate_index == 3 {
        return 0;
    }
    if self.version == PLM_AUDIO_MPEG_2 {
        self.samplerate_index += 4;
        self.bitrate_index += 14;
    }
    i32 padding = plm_buffer_read(self.buffer, 1);
    plm_buffer_skip(self.buffer, 1);
    self.mode = plm_buffer_read(self.buffer, 2);
    self.bound = 0;
    if self.mode == PLM_AUDIO_MODE_JOINT_STEREO {
        self.bound = plm_buffer_read(self.buffer, 2) + 1 << 2;
    } else {
        plm_buffer_skip(self.buffer, 2);
        self.bound = self.mode == PLM_AUDIO_MODE_MONO ? 0 : 32;
    }
    plm_buffer_skip(self.buffer, 4);
    if hasCRC != 0 {
        plm_buffer_skip(self.buffer, 16);
    }
    i32 bitrate = PLM_AUDIO_BIT_RATE[self.bitrate_index];
    var samplerate = cast(i32, PLM_AUDIO_SAMPLE_RATE[self.samplerate_index]);
    i32 frame_size = 144000 * bitrate / samplerate + padding;
    return frame_size - (hasCRC != 0 ? 6 : 4);
}

void plm_audio_decode_frame(plm_audio_t* self) {
    i32 tab3 = 0;
    i32 sblimit = 0;
    if self.version == PLM_AUDIO_MPEG_2 {
        tab3 = 2;
        sblimit = 30;
    } else {
        i32 tab1 = self.mode == PLM_AUDIO_MODE_MONO ? 0 : 1;
        var tab2 = cast(i32, PLM_AUDIO_QUANT_LUT_STEP_1[tab1][self.bitrate_index]);
        tab3 = cast(i32, QUANT_LUT_STEP_2[tab2][self.samplerate_index]);
        sblimit = tab3 & 63;
        tab3 >>= 6;
    }
    if self.bound > sblimit {
        self.bound = sblimit;
    }
    for i32 sb = 0; sb < self.bound; sb++ {
        self.allocation[0][sb] = plm_audio_read_allocation(self, sb, tab3);
        self.allocation[1][sb] = plm_audio_read_allocation(self, sb, tab3);
    }
    for i32 sb = self.bound; sb < sblimit; sb++ {
        self.allocation[1][sb] = plm_audio_read_allocation(self, sb, tab3);
        self.allocation[0][sb] = self.allocation[1][sb];
    }
    i32 channels = self.mode == PLM_AUDIO_MODE_MONO ? 1 : 2;
    for i32 sb = 0; sb < sblimit; sb++ {
        for i32 ch = 0; ch < channels; ch++ {
            if self.allocation[ch][sb] != null {
                self.scale_factor_info[ch][sb] = cast(u8, plm_buffer_read(self.buffer, 2));
            }
        }
        if self.mode == PLM_AUDIO_MODE_MONO {
            self.scale_factor_info[1][sb] = self.scale_factor_info[0][sb];
        }
    }
    for i32 sb = 0; sb < sblimit; sb++ {
        for i32 ch = 0; ch < channels; ch++ {
            if self.allocation[ch][sb] != null {
                i32* sf = self.scale_factor[ch][sb];
                switch self.scale_factor_info[ch][sb] {
                    case 0: {
                        sf[0] = plm_buffer_read(self.buffer, 6);
                        sf[1] = plm_buffer_read(self.buffer, 6);
                        sf[2] = plm_buffer_read(self.buffer, 6);
                    }
                    case 1: {
                        sf[1] = plm_buffer_read(self.buffer, 6);
                        sf[0] = sf[1];
                        sf[2] = plm_buffer_read(self.buffer, 6);
                    }
                    case 2: {
                        sf[2] = plm_buffer_read(self.buffer, 6);
                        sf[1] = sf[2];
                        sf[0] = sf[1];
                    }
                    case 3: {
                        sf[0] = plm_buffer_read(self.buffer, 6);
                        sf[2] = plm_buffer_read(self.buffer, 6);
                        sf[1] = sf[2];
                    }
                }
            }
        }
        if self.mode == PLM_AUDIO_MODE_MONO {
            self.scale_factor[1][sb][0] = self.scale_factor[0][sb][0];
            self.scale_factor[1][sb][1] = self.scale_factor[0][sb][1];
            self.scale_factor[1][sb][2] = self.scale_factor[0][sb][2];
        }
    }
    i32 out_pos = 0;
    for i32 part = 0; part < 3; part++ {
        for i32 granule = 0; granule < 4; granule++ {
            for i32 sb = 0; sb < self.bound; sb++ {
                plm_audio_read_samples(self, 0, sb, part);
                plm_audio_read_samples(self, 1, sb, part);
            }
            for i32 sb = self.bound; sb < sblimit; sb++ {
                plm_audio_read_samples(self, 0, sb, part);
                self.sample[1][sb][0] = self.sample[0][sb][0];
                self.sample[1][sb][1] = self.sample[0][sb][1];
                self.sample[1][sb][2] = self.sample[0][sb][2];
            }
            for i32 sb = sblimit; sb < 32; sb++ {
                self.sample[0][sb][0] = 0;
                self.sample[0][sb][1] = 0;
                self.sample[0][sb][2] = 0;
                self.sample[1][sb][0] = 0;
                self.sample[1][sb][1] = 0;
                self.sample[1][sb][2] = 0;
            }
            for i32 p = 0; p < 3; p++ {
                self.v_pos = self.v_pos - 64 & 1023;
                for i32 ch = 0; ch < 2; ch++ {
                    plm_audio_matrix_transform(self.sample[ch], p, self.V, self.v_pos);
                    memset(self.U, 0, cast(u64, sizeof(self.U)));
                    i32 d_index = 512 - (self.v_pos >> 1);
                    i32 v_index = self.v_pos % 128 >> 1;
                    while v_index < 1024 {
                        for i32 i = 0; i < 32; ++i {
                            self.U[i] += self.D[d_index++] * self.V[v_index++];
                        }
                        v_index += 128 - 32;
                        d_index += 64 - 32;
                    }
                    d_index -= 512 - 32;
                    v_index = 128 - 32 + 1024 - v_index;
                    while v_index < 1024 {
                        for i32 i = 0; i < 32; ++i {
                            self.U[i] += self.D[d_index++] * self.V[v_index++];
                        }
                        v_index += 128 - 32;
                        d_index += 64 - 32;
                    }
                    when defined(PLM_AUDIO_SEPARATE_CHANNELS) {
                        f32* out_channel = ch == 0 ? self.samples.left : self.samples.right;
                        for i32 j = 0; j < 32; j++ {
                            out_channel[out_pos + j] = self.U[j] / 2147418112.0f;
                        }
                    } else {
                        for i32 j = 0; j < 32; j++ {
                            self.samples.interleaved[(out_pos + j << 1) + ch] = self.U[j] / 2147418112.0f;
                        }
                    }
                }
                out_pos += 32;
            }
        }
    }
    plm_buffer_align(self.buffer);
}

plm_quantizer_spec_t* plm_audio_read_allocation(plm_audio_t* self, i32 sb, i32 tab3) {
    var tab4 = cast(i32, PLM_AUDIO_QUANT_LUT_STEP_3[tab3][sb]);
    var qtab = cast(i32, PLM_AUDIO_QUANT_LUT_STEP4[tab4 & 15][plm_buffer_read(self.buffer, tab4 >> 4)]);
    return qtab != 0 ? &PLM_AUDIO_QUANT_TAB[qtab - 1] : null;
}

void plm_audio_read_samples(plm_audio_t* self, i32 ch, i32 sb, i32 part) {
    plm_quantizer_spec_t* q = self.allocation[ch][sb];
    i32 sf = self.scale_factor[ch][sb][part];
    i32* sample = self.sample[ch][sb];
    i32 val = 0;
    if q == null {
        sample[2] = 0;
        sample[1] = sample[2];
        sample[0] = sample[1];
        return;
    }
    if sf == 63 {
        sf = 0;
    } else {
        i32 shift = sf / 3 | 0;
        sf = PLM_AUDIO_SCALEFACTOR_BASE[sf % 3] + (1 << shift >> 1) >> shift;
    }
    var adj = cast(i32, q.levels);
    if q.group != 0 {
        val = plm_buffer_read(self.buffer, cast(i32, q.bits));
        sample[0] = val % adj;
        val /= adj;
        sample[1] = val % adj;
        sample[2] = val / adj;
    } else {
        sample[0] = plm_buffer_read(self.buffer, cast(i32, q.bits));
        sample[1] = plm_buffer_read(self.buffer, cast(i32, q.bits));
        sample[2] = plm_buffer_read(self.buffer, cast(i32, q.bits));
    }
    i32 scale = 65536 / (adj + 1);
    adj = (adj + 1 >> 1) - 1;
    val = (adj - sample[0]) * scale;
    sample[0] = val * (sf >> 12) + (val * (sf & 4095) + 2048 >> 12) >> 12;
    val = (adj - sample[1]) * scale;
    sample[1] = val * (sf >> 12) + (val * (sf & 4095) + 2048 >> 12) >> 12;
    val = (adj - sample[2]) * scale;
    sample[2] = val * (sf >> 12) + (val * (sf & 4095) + 2048 >> 12) >> 12;
}

void plm_audio_matrix_transform(i32[3]* s, i32 ss, f32* d, i32 dp) {
    f32 t01;
    f32 t02;
    f32 t03;
    f32 t04;
    f32 t05;
    f32 t06;
    f32 t07;
    f32 t08;
    f32 t09;
    f32 t10;
    f32 t11;
    f32 t12;
    f32 t13;
    f32 t14;
    f32 t15;
    f32 t16;
    f32 t17;
    f32 t18;
    f32 t19;
    f32 t20;
    f32 t21;
    f32 t22;
    f32 t23;
    f32 t24;
    f32 t25;
    f32 t26;
    f32 t27;
    f32 t28;
    f32 t29;
    f32 t30;
    f32 t31;
    f32 t32;
    f32 t33;
    t01 = cast(f32, s[0][ss] + s[31][ss]);
    t02 = cast(f32, s[0][ss] - s[31][ss]) * 0.500602998235f;
    t03 = cast(f32, s[1][ss] + s[30][ss]);
    t04 = cast(f32, s[1][ss] - s[30][ss]) * 0.505470959898f;
    t05 = cast(f32, s[2][ss] + s[29][ss]);
    t06 = cast(f32, s[2][ss] - s[29][ss]) * 0.515447309923f;
    t07 = cast(f32, s[3][ss] + s[28][ss]);
    t08 = cast(f32, s[3][ss] - s[28][ss]) * 0.53104259109f;
    t09 = cast(f32, s[4][ss] + s[27][ss]);
    t10 = cast(f32, s[4][ss] - s[27][ss]) * 0.553103896034f;
    t11 = cast(f32, s[5][ss] + s[26][ss]);
    t12 = cast(f32, s[5][ss] - s[26][ss]) * 0.582934968206f;
    t13 = cast(f32, s[6][ss] + s[25][ss]);
    t14 = cast(f32, s[6][ss] - s[25][ss]) * 0.622504123036f;
    t15 = cast(f32, s[7][ss] + s[24][ss]);
    t16 = cast(f32, s[7][ss] - s[24][ss]) * 0.674808341455f;
    t17 = cast(f32, s[8][ss] + s[23][ss]);
    t18 = cast(f32, s[8][ss] - s[23][ss]) * 0.744536271002f;
    t19 = cast(f32, s[9][ss] + s[22][ss]);
    t20 = cast(f32, s[9][ss] - s[22][ss]) * 0.839349645416f;
    t21 = cast(f32, s[10][ss] + s[21][ss]);
    t22 = cast(f32, s[10][ss] - s[21][ss]) * 0.972568237862f;
    t23 = cast(f32, s[11][ss] + s[20][ss]);
    t24 = cast(f32, s[11][ss] - s[20][ss]) * 1.16943993343f;
    t25 = cast(f32, s[12][ss] + s[19][ss]);
    t26 = cast(f32, s[12][ss] - s[19][ss]) * 1.48416461631f;
    t27 = cast(f32, s[13][ss] + s[18][ss]);
    t28 = cast(f32, s[13][ss] - s[18][ss]) * 2.05778100995f;
    t29 = cast(f32, s[14][ss] + s[17][ss]);
    t30 = cast(f32, s[14][ss] - s[17][ss]) * 3.40760841847f;
    t31 = cast(f32, s[15][ss] + s[16][ss]);
    t32 = cast(f32, s[15][ss] - s[16][ss]) * 10.1900081235f;
    t33 = t01 + t31;
    t31 = (t01 - t31) * 0.502419286188f;
    t01 = t03 + t29;
    t29 = (t03 - t29) * 0.52249861494f;
    t03 = t05 + t27;
    t27 = (t05 - t27) * 0.566944034816f;
    t05 = t07 + t25;
    t25 = (t07 - t25) * 0.64682178336f;
    t07 = t09 + t23;
    t23 = (t09 - t23) * 0.788154623451f;
    t09 = t11 + t21;
    t21 = (t11 - t21) * 1.06067768599f;
    t11 = t13 + t19;
    t19 = (t13 - t19) * 1.72244709824f;
    t13 = t15 + t17;
    t17 = (t15 - t17) * 5.10114861869f;
    t15 = t33 + t13;
    t13 = (t33 - t13) * 0.509795579104f;
    t33 = t01 + t11;
    t01 = (t01 - t11) * 0.601344886935f;
    t11 = t03 + t09;
    t09 = (t03 - t09) * 0.899976223136f;
    t03 = t05 + t07;
    t07 = (t05 - t07) * 2.56291544774f;
    t05 = t15 + t03;
    t15 = (t15 - t03) * 0.541196100146f;
    t03 = t33 + t11;
    t11 = (t33 - t11) * 1.30656296488f;
    t33 = t05 + t03;
    t05 = (t05 - t03) * 0.707106781187f;
    t03 = t15 + t11;
    t15 = (t15 - t11) * 0.707106781187f;
    t03 += t15;
    t11 = t13 + t07;
    t13 = (t13 - t07) * 0.541196100146f;
    t07 = t01 + t09;
    t09 = (t01 - t09) * 1.30656296488f;
    t01 = t11 + t07;
    t07 = (t11 - t07) * 0.707106781187f;
    t11 = t13 + t09;
    t13 = (t13 - t09) * 0.707106781187f;
    t11 += t13;
    t01 += t11;
    t11 += t07;
    t07 += t13;
    t09 = t31 + t17;
    t31 = (t31 - t17) * 0.509795579104f;
    t17 = t29 + t19;
    t29 = (t29 - t19) * 0.601344886935f;
    t19 = t27 + t21;
    t21 = (t27 - t21) * 0.899976223136f;
    t27 = t25 + t23;
    t23 = (t25 - t23) * 2.56291544774f;
    t25 = t09 + t27;
    t09 = (t09 - t27) * 0.541196100146f;
    t27 = t17 + t19;
    t19 = (t17 - t19) * 1.30656296488f;
    t17 = t25 + t27;
    t27 = (t25 - t27) * 0.707106781187f;
    t25 = t09 + t19;
    t19 = (t09 - t19) * 0.707106781187f;
    t25 += t19;
    t09 = t31 + t23;
    t31 = (t31 - t23) * 0.541196100146f;
    t23 = t29 + t21;
    t21 = (t29 - t21) * 1.30656296488f;
    t29 = t09 + t23;
    t23 = (t09 - t23) * 0.707106781187f;
    t09 = t31 + t21;
    t31 = (t31 - t21) * 0.707106781187f;
    t09 += t31;
    t29 += t09;
    t09 += t23;
    t23 += t31;
    t17 += t29;
    t29 += t25;
    t25 += t09;
    t09 += t27;
    t27 += t23;
    t23 += t19;
    t19 += t31;
    t21 = t02 + t32;
    t02 = (t02 - t32) * 0.502419286188f;
    t32 = t04 + t30;
    t04 = (t04 - t30) * 0.52249861494f;
    t30 = t06 + t28;
    t28 = (t06 - t28) * 0.566944034816f;
    t06 = t08 + t26;
    t08 = (t08 - t26) * 0.64682178336f;
    t26 = t10 + t24;
    t10 = (t10 - t24) * 0.788154623451f;
    t24 = t12 + t22;
    t22 = (t12 - t22) * 1.06067768599f;
    t12 = t14 + t20;
    t20 = (t14 - t20) * 1.72244709824f;
    t14 = t16 + t18;
    t16 = (t16 - t18) * 5.10114861869f;
    t18 = t21 + t14;
    t14 = (t21 - t14) * 0.509795579104f;
    t21 = t32 + t12;
    t32 = (t32 - t12) * 0.601344886935f;
    t12 = t30 + t24;
    t24 = (t30 - t24) * 0.899976223136f;
    t30 = t06 + t26;
    t26 = (t06 - t26) * 2.56291544774f;
    t06 = t18 + t30;
    t18 = (t18 - t30) * 0.541196100146f;
    t30 = t21 + t12;
    t12 = (t21 - t12) * 1.30656296488f;
    t21 = t06 + t30;
    t30 = (t06 - t30) * 0.707106781187f;
    t06 = t18 + t12;
    t12 = (t18 - t12) * 0.707106781187f;
    t06 += t12;
    t18 = t14 + t26;
    t26 = (t14 - t26) * 0.541196100146f;
    t14 = t32 + t24;
    t24 = (t32 - t24) * 1.30656296488f;
    t32 = t18 + t14;
    t14 = (t18 - t14) * 0.707106781187f;
    t18 = t26 + t24;
    t24 = (t26 - t24) * 0.707106781187f;
    t18 += t24;
    t32 += t18;
    t18 += t14;
    t26 = t14 + t24;
    t14 = t02 + t16;
    t02 = (t02 - t16) * 0.509795579104f;
    t16 = t04 + t20;
    t04 = (t04 - t20) * 0.601344886935f;
    t20 = t28 + t22;
    t22 = (t28 - t22) * 0.899976223136f;
    t28 = t08 + t10;
    t10 = (t08 - t10) * 2.56291544774f;
    t08 = t14 + t28;
    t14 = (t14 - t28) * 0.541196100146f;
    t28 = t16 + t20;
    t20 = (t16 - t20) * 1.30656296488f;
    t16 = t08 + t28;
    t28 = (t08 - t28) * 0.707106781187f;
    t08 = t14 + t20;
    t20 = (t14 - t20) * 0.707106781187f;
    t08 += t20;
    t14 = t02 + t10;
    t02 = (t02 - t10) * 0.541196100146f;
    t10 = t04 + t22;
    t22 = (t04 - t22) * 1.30656296488f;
    t04 = t14 + t10;
    t10 = (t14 - t10) * 0.707106781187f;
    t14 = t02 + t22;
    t02 = (t02 - t22) * 0.707106781187f;
    t14 += t02;
    t04 += t14;
    t14 += t10;
    t10 += t02;
    t16 += t04;
    t04 += t08;
    t08 += t14;
    t14 += t28;
    t28 += t10;
    t10 += t20;
    t20 += t02;
    t21 += t16;
    t16 += t32;
    t32 += t04;
    t04 += t06;
    t06 += t08;
    t08 += t18;
    t18 += t14;
    t14 += t30;
    t30 += t28;
    t28 += t26;
    t26 += t10;
    t10 += t12;
    t12 += t20;
    t20 += t24;
    t24 += t02;
    d[dp + 48] = -t33;
    d[dp + 47] = -t21;
    d[dp + 49] = d[dp + 47];
    d[dp + 46] = -t17;
    d[dp + 50] = d[dp + 46];
    d[dp + 45] = -t16;
    d[dp + 51] = d[dp + 45];
    d[dp + 44] = -t01;
    d[dp + 52] = d[dp + 44];
    d[dp + 43] = -t32;
    d[dp + 53] = d[dp + 43];
    d[dp + 42] = -t29;
    d[dp + 54] = d[dp + 42];
    d[dp + 41] = -t04;
    d[dp + 55] = d[dp + 41];
    d[dp + 40] = -t03;
    d[dp + 56] = d[dp + 40];
    d[dp + 39] = -t06;
    d[dp + 57] = d[dp + 39];
    d[dp + 38] = -t25;
    d[dp + 58] = d[dp + 38];
    d[dp + 37] = -t08;
    d[dp + 59] = d[dp + 37];
    d[dp + 36] = -t11;
    d[dp + 60] = d[dp + 36];
    d[dp + 35] = -t18;
    d[dp + 61] = d[dp + 35];
    d[dp + 34] = -t09;
    d[dp + 62] = d[dp + 34];
    d[dp + 33] = -t14;
    d[dp + 63] = d[dp + 33];
    d[dp + 32] = -t05;
    d[dp + 0] = t05;
    d[dp + 31] = -t30;
    d[dp + 1] = t30;
    d[dp + 30] = -t27;
    d[dp + 2] = t27;
    d[dp + 29] = -t28;
    d[dp + 3] = t28;
    d[dp + 28] = -t07;
    d[dp + 4] = t07;
    d[dp + 27] = -t26;
    d[dp + 5] = t26;
    d[dp + 26] = -t23;
    d[dp + 6] = t23;
    d[dp + 25] = -t10;
    d[dp + 7] = t10;
    d[dp + 24] = -t15;
    d[dp + 8] = t15;
    d[dp + 23] = -t12;
    d[dp + 9] = t12;
    d[dp + 22] = -t19;
    d[dp + 10] = t19;
    d[dp + 21] = -t20;
    d[dp + 11] = t20;
    d[dp + 20] = -t13;
    d[dp + 12] = t13;
    d[dp + 19] = -t24;
    d[dp + 13] = t24;
    d[dp + 18] = -t31;
    d[dp + 14] = t31;
    d[dp + 17] = -t02;
    d[dp + 15] = t02;
    d[dp + 16] = cast(f32, 0.0);
}

