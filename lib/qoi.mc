// qoi

/*

Copyright (c) 2021, Dominic Szablewski - https://phoboslab.org
SPDX-License-Identifier: MIT


QOI - The "Quite OK Image" format for fast, lossless image compression

-- About

QOI encodes and decodes images in a lossless format. Compared to stb_image and
stb_image_write QOI offers 20x-50x faster encoding, 3x-4x faster decoding and
20% better compression.


-- Synopsis

// Define `QOI_IMPLEMENTATION` in *one* C/C++ file before including this
// library to create the implementation.

#define QOI_IMPLEMENTATION
#include "qoi.h"

// Encode and store an RGBA buffer to the file system. The qoi_desc describes
// the input pixel data.
qoi_write("image_new.qoi", rgba_pixels, &(qoi_desc){
	.width = 1920,
	.height = 1080,
	.channels = 4,
	.colorspace = QOI_SRGB
});

// Load and decode a QOI image from the file system into a 32bbp RGBA buffer.
// The qoi_desc struct will be filled with the width, height, number of channels
// and colorspace read from the file header.
qoi_desc desc;
void *rgba_pixels = qoi_read("image.qoi", &desc, 4);



-- Documentation

This library provides the following functions;
- qoi_read    -- read and decode a QOI file
- qoi_decode  -- decode the raw bytes of a QOI image from memory
- qoi_write   -- encode and write a QOI file
- qoi_encode  -- encode an rgba buffer into a QOI image in memory

See the function declaration below for the signature and more information.

If you don't want/need the qoi_read and qoi_write functions, you can define
QOI_NO_STDIO before including this library.

This library uses malloc() and free(). To supply your own malloc implementation
you can define QOI_MALLOC and QOI_FREE before including this library.

This library uses memset() to zero-initialize the index. To supply your own
implementation you can define QOI_ZEROARR before including this library.


-- Data Format

A QOI file has a 14 byte header, followed by any number of data "chunks" and an
8-byte end marker.

struct qoi_header_t {
	char     magic[4];   // magic bytes "qoif"
	uint32_t width;      // image width in pixels (BE)
	uint32_t height;     // image height in pixels (BE)
	uint8_t  channels;   // 3 = RGB, 4 = RGBA
	uint8_t  colorspace; // 0 = sRGB with linear alpha, 1 = all channels linear
};

Images are encoded row by row, left to right, top to bottom. The decoder and
encoder start with {r: 0, g: 0, b: 0, a: 255} as the previous pixel value. An
image is complete when all pixels specified by width * height have been covered.

Pixels are encoded as
 - a run of the previous pixel
 - an index into an array of previously seen pixels
 - a difference to the previous pixel value in r,g,b
 - full r,g,b or r,g,b,a values

The color channels are assumed to not be premultiplied with the alpha channel
("un-premultiplied alpha").

A running array[64] (zero-initialized) of previously seen pixel values is
maintained by the encoder and decoder. Each pixel that is seen by the encoder
and decoder is put into this array at the position formed by a hash function of
the color value. In the encoder, if the pixel value at the index matches the
current pixel, this index position is written to the stream as QOI_OP_INDEX.
The hash function for the index is:

	index_position = (r * 3 + g * 5 + b * 7 + a * 11) % 64

Each chunk starts with a 2- or 8-bit tag, followed by a number of data bits. The
bit length of chunks is divisible by 8 - i.e. all chunks are byte aligned. All
values encoded in these data bits have the most significant bit on the left.

The 8-bit tags have precedence over the 2-bit tags. A decoder must check for the
presence of an 8-bit tag first.

The byte stream's end is marked with 7 0x00 bytes followed a single 0x01 byte.


The possible chunks are:


.- QOI_OP_INDEX ----------.
|         Byte[0]         |
|  7  6  5  4  3  2  1  0 |
|-------+-----------------|
|  0  0 |     index       |
`-------------------------`
2-bit tag b00
6-bit index into the color index array: 0..63

A valid encoder must not issue 2 or more consecutive QOI_OP_INDEX chunks to the
same index. QOI_OP_RUN should be used instead.


.- QOI_OP_DIFF -----------.
|         Byte[0]         |
|  7  6  5  4  3  2  1  0 |
|-------+-----+-----+-----|
|  0  1 |  dr |  dg |  db |
`-------------------------`
2-bit tag b01
2-bit   red channel difference from the previous pixel between -2..1
2-bit green channel difference from the previous pixel between -2..1
2-bit  blue channel difference from the previous pixel between -2..1

The difference to the current channel values are using a wraparound operation,
so "1 - 2" will result in 255, while "255 + 1" will result in 0.

Values are stored as unsigned integers with a bias of 2. E.g. -2 is stored as
0 (b00). 1 is stored as 3 (b11).

The alpha value remains unchanged from the previous pixel.


.- QOI_OP_LUMA -------------------------------------.
|         Byte[0]         |         Byte[1]         |
|  7  6  5  4  3  2  1  0 |  7  6  5  4  3  2  1  0 |
|-------+-----------------+-------------+-----------|
|  1  0 |  green diff     |   dr - dg   |  db - dg  |
`---------------------------------------------------`
2-bit tag b10
6-bit green channel difference from the previous pixel -32..31
4-bit   red channel difference minus green channel difference -8..7
4-bit  blue channel difference minus green channel difference -8..7

The green channel is used to indicate the general direction of change and is
encoded in 6 bits. The red and blue channels (dr and db) base their diffs off
of the green channel difference and are encoded in 4 bits. I.e.:
	dr_dg = (cur_px.r - prev_px.r) - (cur_px.g - prev_px.g)
	db_dg = (cur_px.b - prev_px.b) - (cur_px.g - prev_px.g)

The difference to the current channel values are using a wraparound operation,
so "10 - 13" will result in 253, while "250 + 7" will result in 1.

Values are stored as unsigned integers with a bias of 32 for the green channel
and a bias of 8 for the red and blue channel.

The alpha value remains unchanged from the previous pixel.


.- QOI_OP_RUN ------------.
|         Byte[0]         |
|  7  6  5  4  3  2  1  0 |
|-------+-----------------|
|  1  1 |       run       |
`-------------------------`
2-bit tag b11
6-bit run-length repeating the previous pixel: 1..62

The run-length is stored with a bias of -1. Note that the run-lengths 63 and 64
(b111110 and b111111) are illegal as they are occupied by the QOI_OP_RGB and
QOI_OP_RGBA tags.


.- QOI_OP_RGB ------------------------------------------.
|         Byte[0]         | Byte[1] | Byte[2] | Byte[3] |
|  7  6  5  4  3  2  1  0 | 7 .. 0  | 7 .. 0  | 7 .. 0  |
|-------------------------+---------+---------+---------|
|  1  1  1  1  1  1  1  0 |   red   |  green  |  blue   |
`-------------------------------------------------------`
8-bit tag b11111110
8-bit   red channel value
8-bit green channel value
8-bit  blue channel value

The alpha value remains unchanged from the previous pixel.


.- QOI_OP_RGBA ---------------------------------------------------.
|         Byte[0]         | Byte[1] | Byte[2] | Byte[3] | Byte[4] |
|  7  6  5  4  3  2  1  0 | 7 .. 0  | 7 .. 0  | 7 .. 0  | 7 .. 0  |
|-------------------------+---------+---------+---------+---------|
|  1  1  1  1  1  1  1  1 |   red   |  green  |  blue   |  alpha  |
`-----------------------------------------------------------------`
8-bit tag b11111111
8-bit   red channel value
8-bit green channel value
8-bit  blue channel value
8-bit alpha channel value

*/
/* -----------------------------------------------------------------------------
Header - Public functions */
/* A pointer to a qoi_desc struct has to be supplied to all of qoi's functions.
It describes either the input format (for qoi_write and qoi_encode), or is
filled with the description read from the file header (for qoi_read and
qoi_decode).

The colorspace in this qoi_desc is an enum where
	0 = sRGB, i.e. gamma scaled RGB channels and a linear alpha channel
	1 = all channels are linear
You may use the constants QOI_SRGB or QOI_LINEAR. The colorspace is purely
informative. It will be saved to the file header, but does not affect
how chunks are en-/decoded. */
struct qoi_desc {
    u32 width;
    u32 height;
    u8 channels;
    u8 colorspace;
}

/* -----------------------------------------------------------------------------
Implementation */
/* 2GB is the max file size that this implementation can safely handle. We guard
against anything larger than that, assuming the worst case with 5 bytes per
pixel, rounded down to a nice clean value. 400 million pixels ought to be
enough for anybody. */
unsafe_union qoi_rgba_t {
    struct {
        u8 r;
        u8 g;
        u8 b;
        u8 a;
    } rgba;
    u32 v;
}

private {
u8[8] qoi_padding = {0, 0, 0, 0, 0, 0, 0, 1};

void qoi_write_32(u8* bytes, i32* p, u32 v) {
    bytes[(*p)++] = cast(u8, (0xff000000 & v) >> 24);
    bytes[(*p)++] = cast(u8, (0x00ff0000 & v) >> 16);
    bytes[(*p)++] = cast(u8, (0x0000ff00 & v) >> 8);
    bytes[(*p)++] = cast(u8, 0x000000ff & v);
}

u32 qoi_read_32(u8* bytes, i32* p) {
    u32 a = bytes[(*p)++];
    u32 b = bytes[(*p)++];
    u32 c = bytes[(*p)++];
    u32 d = bytes[(*p)++];
    return a << 24 | b << 16 | c << 8 | d;
}
}

void* qoi_encode(void* data, qoi_desc* desc, i32* out_len) {
    i32 i;
    i32 max_size;
    i32 p;
    i32 run;
    i32 px_len;
    i32 px_end;
    i32 px_pos;
    i32 channels;
    u8* bytes;
    u8* pixels;
    noinit qoi_rgba_t[64] index;
    qoi_rgba_t px;
    qoi_rgba_t px_prev;
    if data == null || out_len == null || desc == null || desc.width == 0 || desc.height == 0 || desc.channels < 3 || desc.channels > 4 || desc.colorspace > 1 || desc.height >= cast(u32, 400000000) / desc.width {
        return null;
    }
    max_size = cast(i32, desc.width * desc.height * (desc.channels + 1) + 14 + sizeof(qoi_padding));
    p = 0;
    bytes = cast(u8*, alloc(cast(i64, max_size)));
    if bytes == null {
        return null;
    }
    qoi_write_32(bytes, &p, cast(u32, 113) << 24 | cast(u32, 111) << 16 | cast(u32, 105) << 8 | cast(u32, 102));
    qoi_write_32(bytes, &p, desc.width);
    qoi_write_32(bytes, &p, desc.height);
    bytes[p++] = desc.channels;
    bytes[p++] = desc.colorspace;
    pixels = cast(u8*, data);
    memset(index, 0, cast(u64, sizeof(index)));
    run = 0;
    px_prev.rgba.r = 0;
    px_prev.rgba.g = 0;
    px_prev.rgba.b = 0;
    px_prev.rgba.a = 255;
    px = px_prev;
    px_len = cast(i32, desc.width * desc.height * desc.channels);
    px_end = px_len - desc.channels;
    channels = cast(i32, desc.channels);
    for px_pos = 0; px_pos < px_len; px_pos += channels {
        px.rgba.r = pixels[px_pos + 0];
        px.rgba.g = pixels[px_pos + 1];
        px.rgba.b = pixels[px_pos + 2];
        if channels == 4 {
            px.rgba.a = pixels[px_pos + 3];
        }
        if px.v == px_prev.v {
            run++;
            if run == 62 || px_pos == px_end {
                bytes[p++] = cast(u8, 0xc0 | run - 1);
                run = 0;
            }
        } else {
            i32 index_pos;
            if run > 0 {
                bytes[p++] = cast(u8, 0xc0 | run - 1);
                run = 0;
            }
            index_pos = cast(i32, px.rgba.r * 3 + px.rgba.g * 5 + px.rgba.b * 7 + px.rgba.a * 11 & cast(u32, 64 - 1));
            if index[index_pos].v == px.v {
                bytes[p++] = cast(u8, 0x00 | index_pos);
            } else {
                index[index_pos] = px;
                if px.rgba.a == px_prev.rgba.a {
                    var vr = cast(i8, px.rgba.r - px_prev.rgba.r);
                    var vg = cast(i8, px.rgba.g - px_prev.rgba.g);
                    var vb = cast(i8, px.rgba.b - px_prev.rgba.b);
                    var vg_r = cast(i8, vr - vg);
                    var vg_b = cast(i8, vb - vg);
                    if vr > -3 && vr < 2 && vg > -3 && vg < 2 && vb > -3 && vb < 2 {
                        bytes[p++] = cast(u8, 0x40 | vr + 2 << 4 | vg + 2 << 2 | vb + 2);
                    } else if vg_r > -9 && vg_r < 8 && vg > -33 && vg < 32 && vg_b > -9 && vg_b < 8 {
                        bytes[p++] = cast(u8, 0x80 | vg + 32);
                        bytes[p++] = cast(u8, vg_r + 8 << 4 | vg_b + 8);
                    } else {
                        bytes[p++] = 0xfe;
                        bytes[p++] = px.rgba.r;
                        bytes[p++] = px.rgba.g;
                        bytes[p++] = px.rgba.b;
                    }
                } else {
                    bytes[p++] = 0xff;
                    bytes[p++] = px.rgba.r;
                    bytes[p++] = px.rgba.g;
                    bytes[p++] = px.rgba.b;
                    bytes[p++] = px.rgba.a;
                }
            }
        }
        px_prev = px;
    }
    for i = 0; i < cast(i32, sizeof(qoi_padding)); i++ {
        bytes[p++] = qoi_padding[i];
    }
    *out_len = p;
    return bytes;
}

void* qoi_decode(void* data, i32 size, qoi_desc* desc, i32 channels) {
    u8* bytes;
    u32 header_magic;
    u8* pixels;
    noinit qoi_rgba_t[64] index;
    qoi_rgba_t px;
    i32 px_len;
    i32 chunks_len;
    i32 px_pos;
    i32 p = 0;
    i32 run = 0;
    if data == null || desc == null || channels != 0 && channels != 3 && channels != 4 || size < 14 + cast(i32, sizeof(qoi_padding)) {
        return null;
    }
    bytes = cast(u8*, data);
    header_magic = qoi_read_32(bytes, &p);
    desc.width = qoi_read_32(bytes, &p);
    desc.height = qoi_read_32(bytes, &p);
    desc.channels = bytes[p++];
    desc.colorspace = bytes[p++];
    if desc.width == 0 || desc.height == 0 || desc.channels < 3 || desc.channels > 4 || desc.colorspace > 1 || header_magic != (cast(u32, 113) << 24 | cast(u32, 111) << 16 | cast(u32, 105) << 8 | cast(u32, 102)) || desc.height >= cast(u32, 400000000) / desc.width {
        return null;
    }
    if channels == 0 {
        channels = cast(i32, desc.channels);
    }
    px_len = cast(i32, desc.width * desc.height * cast(u32, channels));
    pixels = cast(u8*, alloc(cast(i64, px_len)));
    if pixels == null {
        return null;
    }
    memset(index, 0, cast(u64, sizeof(index)));
    px.rgba.r = 0;
    px.rgba.g = 0;
    px.rgba.b = 0;
    px.rgba.a = 255;
    chunks_len = size - cast(i32, sizeof(qoi_padding));
    for px_pos = 0; px_pos < px_len; px_pos += channels {
        if run > 0 {
            run--;
        } else if p < chunks_len {
            var b1 = cast(i32, bytes[p++]);
            if b1 == 0xfe {
                px.rgba.r = bytes[p++];
                px.rgba.g = bytes[p++];
                px.rgba.b = bytes[p++];
            } else if b1 == 0xff {
                px.rgba.r = bytes[p++];
                px.rgba.g = bytes[p++];
                px.rgba.b = bytes[p++];
                px.rgba.a = bytes[p++];
            } else if (b1 & 0xc0) == 0x00 {
                px = index[b1];
            } else if (b1 & 0xc0) == 0x40 {
                px.rgba.r += cast(u8, (b1 >> 4 & 0x03) - 2);
                px.rgba.g += cast(u8, (b1 >> 2 & 0x03) - 2);
                px.rgba.b += cast(u8, (b1 & 0x03) - 2);
            } else if (b1 & 0xc0) == 0x80 {
                var b2 = cast(i32, bytes[p++]);
                i32 vg = (b1 & 0x3f) - 32;
                px.rgba.r += cast(u8, vg - 8 + (b2 >> 4 & 0x0f));
                px.rgba.g += cast(u8, vg);
                px.rgba.b += cast(u8, vg - 8 + (b2 & 0x0f));
            } else if (b1 & 0xc0) == 0xc0 {
                run = b1 & 0x3f;
            }
            index[px.rgba.r * 3 + px.rgba.g * 5 + px.rgba.b * 7 + px.rgba.a * 11 & cast(u32, 64 - 1)] = px;
        }
        pixels[px_pos + 0] = px.rgba.r;
        pixels[px_pos + 1] = px.rgba.g;
        pixels[px_pos + 2] = px.rgba.b;
        if channels == 4 {
            pixels[px_pos + 3] = px.rgba.a;
        }
    }
    return pixels;
}

