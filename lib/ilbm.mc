// ilbm

// simple IFF ILBM loader (https://en.wikipedia.org/wiki/ILBM)
struct ilbm_range_t {
    void* ptr;
    u64 size;
}

struct ilbm_color_range_t {
    i32 rate;
    bool cycle_forward;
    bool cycle_backward;
    u8 low;
    u8 high;
    f64 rate_sec;
    f64 rate_accum;
}

struct ilbm_t {
    i32 width;
    i32 height;
    i32 x_aspect;
    i32 y_aspect;
    f32 aspect_ratio;
    i32 num_ranges;
    i32 num_colors;
    ilbm_color_range_t[16] ranges;
    u32[256] colors;
    ilbm_range_t pixels;
}

private struct _ilbm_state_t {
    u8* ptr;
    u8* end;
    i32 num_bitplanes;
    i16 x_origin;
    i16 y_origin;
    i16 page_width;
    i16 page_height;
    u8 mask;
    bool rle;
}

private {
_ilbm_state_t _ilbm_state;

u32 u32be() {
    if _ilbm_state.ptr + 4 <= _ilbm_state.end {
        u32 b0 = *_ilbm_state.ptr++;
        u32 b1 = *_ilbm_state.ptr++;
        u32 b2 = *_ilbm_state.ptr++;
        u32 b3 = *_ilbm_state.ptr++;
        return b0 << 24 | b1 << 16 | b2 << 8 | b3;
    } else {
        return 0;
    }
}

u32 rgb_u32() {
    if _ilbm_state.ptr + 3 <= _ilbm_state.end {
        u32 b0 = *_ilbm_state.ptr++;
        u32 b1 = *_ilbm_state.ptr++;
        u32 b2 = *_ilbm_state.ptr++;
        return 0xFF000000 | b0 | b1 << 8 | b2 << 16;
    } else {
        return 0;
    }
}

u16 u16be() {
    if _ilbm_state.ptr + 2 <= _ilbm_state.end {
        u32 b0 = *_ilbm_state.ptr++;
        u32 b1 = *_ilbm_state.ptr++;
        return cast(u16, b0 << 8 | b1);
    } else {
        return 0;
    }
}

i16 i16be() {
    return cast(i16, u16be());
}

u8 u8_var() {
    if _ilbm_state.ptr + 1 <= _ilbm_state.end {
        return *_ilbm_state.ptr++;
    } else {
        return 0;
    }
}

bool load_bmhd(ilbm_t* ilbm) {
    u64 chunk_size = 20;
    if u32be() != chunk_size {
        return false;
    }
    u8* start = _ilbm_state.ptr;
    ilbm.width = cast(i32, u16be());
    ilbm.height = cast(i32, u16be());
    if ilbm.width == 0 || ilbm.height == 0 {
        return false;
    }
    _ilbm_state.x_origin = i16be();
    _ilbm_state.y_origin = i16be();
    _ilbm_state.num_bitplanes = cast(i32, u8_var());
    ilbm.num_colors = 1 << _ilbm_state.num_bitplanes;
    if ilbm.num_colors == 0 || ilbm.num_colors > 256 {
        return false;
    }
    _ilbm_state.mask = u8_var();
    if _ilbm_state.mask != 0 && _ilbm_state.mask != 2 {
        return false;
    }
    u8 compression = u8_var();
    if compression != 0 && compression != 1 {
        return false;
    }
    _ilbm_state.rle = compression == 1;
    u8_var();
    u16be();
    ilbm.x_aspect = cast(i32, u8_var());
    ilbm.y_aspect = cast(i32, u8_var());
    if ilbm.x_aspect == 0 || ilbm.y_aspect == 0 {
        return false;
    }
    ilbm.aspect_ratio = cast(f32, ilbm.width * ilbm.x_aspect) / cast(f32, ilbm.height * ilbm.y_aspect);
    _ilbm_state.page_width = i16be();
    _ilbm_state.page_height = i16be();
    ignore start;
    ilbm.pixels.size = cast(u64, ilbm.width * ilbm.height);
    ilbm.pixels.ptr = cast(void*, new(u8[ilbm.pixels.size]));
    return true;
}

bool load_cmap(ilbm_t* ilbm) {
    var chunk_size = cast(i32, u32be());
    u8* start = _ilbm_state.ptr;
    i32 num_colors = chunk_size / 3;
    if num_colors > ilbm.num_colors {
        return false;
    }
    i32 i = 0;
    for ; i < num_colors; i++ {
        ilbm.colors[i] = rgb_u32();
    }
    for ; i < ilbm.num_colors; i++ {
        ilbm.colors[i] = 0xFFFF00FF;
    }
    ignore start;
    if (cast(u64, _ilbm_state.ptr) & 1) == 1 {
        u8_var();
    }
    return true;
}
}

bool load_crng(ilbm_t* ilbm) {
    u64 chunk_size = 8;
    if u32be() != chunk_size {
        return false;
    }
    if ilbm.num_ranges >= 16 {
        _ilbm_state.ptr += chunk_size;
        return true;
    }
    i32 i = ilbm.num_ranges++;
    ilbm_color_range_t* rp = &ilbm.ranges[i];
    i16be();
    rp.rate = i16be();
    if rp.rate > 0 {
        rp.rate_sec = 1.0 / 60.0 * 16384.0 / cast(f64, rp.rate);
    }
    i16 flags = i16be();
    if 0 != (flags & 1) {
        if 0 != (flags & 2) {
            rp.cycle_backward = true;
        } else {
            rp.cycle_forward = true;
        }
    }
    rp.low = u8_var();
    rp.high = u8_var();
    return true;
}

bool load_body(ilbm_t* ilbm) {
    i32 row_num_words = (ilbm.width + 15) / 16;
    i32 row_num_bytes = row_num_words * 2;
    i32 body_size = ilbm.height * _ilbm_state.num_bitplanes * row_num_bytes;
    u32 chunk_size = u32be();
    u8* chunk_end = _ilbm_state.ptr + chunk_size;
    var buf = cast(u8*, new(u8[cast(u64, body_size)]));
    if _ilbm_state.rle != 0 {
        u8* dst = buf;
        u8* dst_end = buf + body_size;
        while dst < dst_end {
            ignore chunk_end;
            var b = cast(i8, u8_var());
            if b >= 0 {
                for i32 i = 0; i <= b; i++ {
                    if dst < dst_end {
                        *dst++ = u8_var();
                    }
                }
            } else if b != -128 {
                u8 val = u8_var();
                for i32 i = 0; i < 1 - cast(i32, b); i++ {
                    if dst < dst_end {
                        *dst++ = val;
                    }
                }
            }
        }
    } else {
        var copy_size = cast(u64, body_size);
        if _ilbm_state.ptr + copy_size > _ilbm_state.end {
            copy_size = cast(u64, cast(i64, _ilbm_state.end - _ilbm_state.ptr));
        }
        memcpy(buf, _ilbm_state.ptr, copy_size);
        _ilbm_state.ptr += copy_size;
    }
    u8* src = buf;
    for i32 y = 0; y < ilbm.height; y++ {
        for i32 plane = 0; plane < _ilbm_state.num_bitplanes; plane++ {
            u8* dst_row = cast(u8*, ilbm.pixels.ptr) + y * ilbm.width;
            i32 x = 0;
            for i32 w = 0; w < row_num_words; w++ {
                var word = cast(u16, cast(i32, src[0]) << 8 | src[1]);
                src += 2;
                for i32 bitpos = 15; bitpos >= 0; bitpos-- {
                    if x < ilbm.width {
                        dst_row[x] |= cast(u8, (cast(i32, word) >> bitpos & 1) << plane);
                    }
                    x += 1;
                }
            }
        }
    }
    free(buf);
    if (cast(u64, _ilbm_state.ptr) & 1) == 1 {
        u8_var();
    }
    return true;
}

bool skip_chunk() {
    u32 chunk_size = u32be();
    if (chunk_size & 1) == 1 {
        chunk_size += 1;
    }
    if _ilbm_state.ptr + chunk_size > _ilbm_state.end {
        return false;
    }
    _ilbm_state.ptr += chunk_size;
    return true;
}

bool ilbm_load(ilbm_t* ilbm, ilbm_range_t data) {
    _ilbm_state.ptr = data.ptr;
    _ilbm_state.end = cast(u8*, data.ptr) + data.size;
    if u32be() != (cast(u32, 70) << 24 | cast(u32, 79) << 16 | cast(u32, 82) << 8 | cast(u32, 77)) {
        return false;
    }
    if u32be() > data.size {
        return false;
    }
    if u32be() != (cast(u32, 73) << 24 | cast(u32, 76) << 16 | cast(u32, 66) << 8 | cast(u32, 77)) {
        return false;
    }
    while _ilbm_state.ptr < _ilbm_state.end {
        switch u32be() {
            case cast(u32, 66) << 24 | cast(u32, 77) << 16 | cast(u32, 72) << 8 | cast(u32, 68): {
                if load_bmhd(ilbm) == 0 {
                    return false;
                }
            }
            case cast(u32, 67) << 24 | cast(u32, 77) << 16 | cast(u32, 65) << 8 | cast(u32, 80): {
                if load_cmap(ilbm) == 0 {
                    return false;
                }
            }
            case cast(u32, 67) << 24 | cast(u32, 82) << 16 | cast(u32, 78) << 8 | cast(u32, 71): {
                if load_crng(ilbm) == 0 {
                    return false;
                }
            }
            case cast(u32, 66) << 24 | cast(u32, 79) << 16 | cast(u32, 68) << 8 | cast(u32, 89): {
                if load_body(ilbm) == 0 {
                    return false;
                }
            }
            default: {
                if skip_chunk() == 0 {
                    return false;
                }
            }
        }
    }
    return true;
}

void ilbm_free(ilbm_t* ilbm) {
    if ilbm.pixels.ptr != null {
        free(ilbm.pixels.ptr);
    }
    memset(ilbm, 0, cast(u64, sizeof(ilbm_t)));
}

bool ilbm_color_cycle(ilbm_t* ilbm, f64 frame_duration_sec) {
    bool needs_update = false;
    for i32 i = 0; i < ilbm.num_ranges; i++ {
        ilbm_color_range_t* r = &ilbm.ranges[i];
        if r.rate == 0 {
            continue;
        }
        if (r.cycle_forward || r.cycle_backward) == 0 {
            continue;
        }
        if r.low == r.high {
            continue;
        }
        r.rate_accum += frame_duration_sec;
        while r.rate_accum >= r.rate_sec {
            needs_update = true;
            r.rate_accum -= r.rate_sec;
            if r.cycle_forward != 0 {
                u32 c = ilbm.colors[r.high];
                for u8 ci = r.high; ci > r.low; ci-- {
                    ilbm.colors[ci] = ilbm.colors[ci - 1];
                }
                ilbm.colors[r.low] = c;
            } else if r.cycle_backward != 0 {
                u32 c = ilbm.colors[r.low];
                for u8 ci = r.low; ci < r.high; ci++ {
                    ilbm.colors[ci] = ilbm.colors[ci + 1];
                }
                ilbm.colors[r.high] = c;
            }
        }
    }
    return needs_update;
}

