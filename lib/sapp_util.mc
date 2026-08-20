// sapp_util

// stb_image adapter over lib/png.mc + lib/jpeg.mc. The samples decode
// to RGBA8 (desired_channels always 4).

import png;
import jpeg;

u8* stbi_load_from_memory(u8* buf, i32 len, i32* x, i32* y, i32* comp, i32 req_comp) {
    u8* pixels = null;
    i32 w = 0;
    i32 h = 0;
    if len >= 2 && *(buf + 0) == 0xFF && *(buf + 1) == 0xD8 {
        JpegImage img = jpeg_decode(buf, len);
        pixels = img.pixels;
        w = img.width;
        h = img.height;
    } else {
        PngImage img = png_decode(buf, len);
        pixels = img.pixels;
        w = img.width;
        h = img.height;
    }
    if pixels == null { return null; }
    if x != null { *x = w; }
    if y != null { *y = h; }
    if comp != null { *comp = 4; }
    return pixels;
}

void stbi_image_free(void* p) {
    // the samples decode once at startup, we leak this memory...
    ignore p;
}


u8* fileutil_get_path(u8* filename, u8* buf, u64 buf_size) {
    str prefix = "data/";
    u64 i = 0;
    while i < cast(u64, prefix.len) && i + 1 < buf_size {
        *(buf + i) = *(prefix.data + i);
        i++;
    }
    u64 j = 0;
    while i + 1 < buf_size && *(filename + j) != 0 {
        *(buf + i) = *(filename + j);
        i++;
        j++;
    }
    *(buf + i) = 0;
    return buf;
}

