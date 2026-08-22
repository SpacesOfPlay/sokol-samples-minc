// sokol_framebuffer
import sokol_all;

// sokol_framebuffer.h shaders as minc @shader functions, replacing
// the upstream header's per-backend source text and bytecode blobs.

struct SfbFsqOut {
    float4 pos;
    float2 uv;
}

@gpu_layout
struct Ub_sfb_offscreen_vs_params {
    float2 uv_offset;
    float2 uv_scale;
}

@gpu_layout
struct Ub_sfb_render_vs_params {
    i32 rotate;
}

// Fullscreen triangle for the offscreen pass: the emulated framebuffer
// texture is drawn into an RGBA8 target, with the cliprect applied
// through the uv transform.
@shader vertex
SfbFsqOut sfb_offscreen_vs(@uniform(0) Ub_sfb_offscreen_vs_params p) {
    SfbFsqOut o;
    i32 vid = cast(i32, vertex_id());
    f32 x = 0.0f;
    f32 y = 0.0f;
    if (vid & 1) != 0 { x = 2.0f; }
    if (vid & 2) != 0 { y = 2.0f; }
    o.pos = float4{x * 2.0f - 1.0f, y * 2.0f - 1.0f, 0.5f, 1.0f};
    o.uv = float2{x, 1.0f - y} * p.uv_scale + p.uv_offset;
    // GL renders the offscreen target bottom-up; flipping here keeps
    // the texture contents identical across backends.
    when gpu(opengl) || gpu(opengles) {
        o.pos.y = 0.0f - o.pos.y;
    }
    return o;
}

@shader fragment
float4 sfb_rgba8_fs(
    SfbFsqOut input,
    @texture(0) Texture2D fb_tex,
    @sampler(0) Sampler smp
) {
    return sample(fb_tex, smp, input.uv);
}

// Palette lookup: the framebuffer texture holds 8-bit indices in the
// red channel, the 256x1 palette texture holds the colors.
@shader fragment
float4 sfb_palette8_fs(
    SfbFsqOut input,
    @texture(0) Texture2D fb_tex,
    @texture(1) Texture2D pal_tex,
    @sampler(0) Sampler smp
) {
    f32 idx = sample(fb_tex, smp, input.uv).x;
    float4 c = sample(pal_tex, smp, float2{idx, 0.0f});
    return float4{c.x, c.y, c.z, 1.0f};
}

// Fullscreen triangle for the display pass, with optional 90 degree
// rotation for portrait displays.
@shader vertex
SfbFsqOut sfb_render_vs(@uniform(0) Ub_sfb_render_vs_params p) {
    SfbFsqOut o;
    i32 vid = cast(i32, vertex_id());
    f32 x = 0.0f;
    f32 y = 0.0f;
    if (vid & 1) != 0 { x = 2.0f; }
    if (vid & 2) != 0 { y = 2.0f; }
    o.pos = float4{x * 2.0f - 1.0f, y * 2.0f - 1.0f, 0.5f, 1.0f};
    if p.rotate == 0 {
        o.uv = float2{x, 1.0f - y};
    } else {
        o.uv = float2{1.0f - y, 1.0f - x};
    }
    return o;
}

@shader fragment
float4 sfb_render_fs(
    SfbFsqOut input,
    @texture(0) Texture2D tex,
    @sampler(0) Sampler smp
) {
    float4 c = sample(tex, smp, input.uv);
    return float4{c.x, c.y, c.z, 1.0f};
}

// Shader constructors for sokol_framebuffer.h. The header's create
// functions call these instead of building per-backend descriptors.

sg_shader _sfb_minc_rgba8_shader() {
    return sokol_make_shader(&sfb_offscreen_vs_shader, &sfb_rgba8_fs_shader);
}

sg_shader _sfb_minc_palette8_shader() {
    return sokol_make_shader(&sfb_offscreen_vs_shader, &sfb_palette8_fs_shader);
}

sg_shader _sfb_minc_render_shader() {
    return sokol_make_shader(&sfb_render_vs_shader, &sfb_render_fs_shader);
}

enum __enum_SFB_INVALID_ID {
    SFB_INVALID_ID = 0,
}

/*
    sfb_resource_state

    The state of a framebuffer object, obtainable via sfb_query_framebuffer_state().
    Publicly visible values are only SFB_RESOURCESTATE_VALID
    and SFB_RESOURCESTATE_FAILED.
*/
enum sfb_resource_state {
    SFB_RESOURCESTATE_INITIAL = 0,
    SFB_RESOURCESTATE_ALLOC = 1,
    SFB_RESOURCESTATE_VALID = 2,
    SFB_RESOURCESTATE_FAILED = 3,
    SFB_RESOURCESTATE_INVALID = 4,
    _SFB_RESOURCESTATE_FORCE_U32 = 2147483647,
}

/*
    sfb_format

    The framebuffer pixel format. Either RGBA8 direct color where each
    pixel is an uint32_t, or paletted format with uint8_t pixels as
    index into a 256 entry color palette.
*/
enum sfb_format {
    _SFB_FORMAT_DEFAULT = 0,
    SFB_FORMAT_RGBA8 = 1,
    SFB_FORMAT_PALETTE8 = 2,
    _SFB_FORMAT_FORCE_U32 = 2147483647,
}

enum __enum__SFB_SLOT_SHIFT {
    _SFB_SLOT_SHIFT = 16,
    _SFB_SLOT_MASK = 65535,
    _SFB_MAX_POOL_SIZE = 65536,
    _SFB_DEFAULT_FRAMEBUFFER_POOL_SIZE = 8,
}

// >>logging
enum _sfb_log_item_t {
    _SFB_LOGITEM_OK = 0,
    _SFB_LOGITEM_MALLOC_FAILED = 1,
    _SFB_LOGITEM_FRAMEBUFFER_POOL_EXHAUSTED = 2,
    _SFB_LOGITEM_INVALID_FRAMEBUFFER_WIDTH = 3,
    _SFB_LOGITEM_INVALID_FRAMEBUFFER_HEIGHT = 4,
    _SFB_LOGITEM_UPDATE_INVALID_FRAMEBUFFER_HANDLE = 5,
    _SFB_LOGITEM_UPDATE_FRAMEBUFFER_RESOURCESTATE_NOT_VALID = 6,
    _SFB_LOGITEM_UPDATE_PALETTE_RANGE_IGNORED = 7,
    _SFB_LOGITEM_UPDATE_PIXEL_RANGE_SIZE_RGBA8 = 8,
    _SFB_LOGITEM_UPDATE_PIXEL_RANGE_SIZE_PALETTE8 = 9,
    _SFB_LOGITEM_UPDATE_PALETTE_RANGE_SIZE = 10,
    _SFB_LOGITEM_RENDER_EX_INVALID_FRAMEBUFFER_HANDLE = 11,
    _SFB_LOGITEM_RENDER_EX_FRAMEBUFFER_RESOURCESTATE_NOT_VALID = 12,
}

/*
    sfb_framebuffer

    A framebuffer handle, created with sfb_make_framebuffer(), destroyed
    with sfb_destroy_framebuffer()
*/
struct sfb_framebuffer {
    u32 id;
}

/*
    sfb_rect

    Used as clipping rectangle in struct sfb_framebuffer_desc
    and sfb_resize_desc.
*/
struct sfb_rect {
    i32 x;
    i32 y;
    i32 width;
    i32 height;
}

/*
    sfb_render_pass_desc

    Describes render pass properties in an sfb_framebuffer_desc (color-
    and depth-pixel-format, sample count). This is used to create the
    sg_pipeline objects applied in the render functions. When rendering
    to a default swapchain all the values can remain at default (zero).
*/
struct sfb_render_pass_desc {
    sg_pixel_format color_format;
    sg_pixel_format depth_format;
    i32 sample_count;
}

/*
    sfb_framebuffer_desc

    Creation parameters for a framebuffer object. Passed into
    sfb_make_framebuffer().
*/
struct sfb_framebuffer_desc {
    i32 width;
    i32 height;
    i32 prescale;
    sfb_format format;
    sfb_rect cliprect;
    bool rotate90;
    sfb_render_pass_desc render_pass;
}

/*
    sfb_resize_desc

    Parameters for sfb_resize(). Needs to be called before sfb_update() in a
    frame if with potentially new framebuffer size parameters or clipping
    rectangle. Note that the sfb_resize() function can be called even when no
    resizing needs to happen, in that case the function will be a silent no-op
    and return false. When the function returns true this means that internal
    image objects had been recreated and need to be repopulated again via
    sfb_update()

    Resizing is slightly cheaper than destroying and creating the frambuffer
    because only image objects needs to be re-created, but no pipeline objects.
*/
struct sfb_resize_desc {
    i32 width;
    i32 height;
    i32 prescale;
    sfb_rect cliprect;
}

/*
    sfb_update_desc

    Passed into sfb_update() to update the pixel-date and/or color-palette-data
    The sfb_update() function should only be called when any of the above
    actually changes, at most once per frame, and outside any sokol-gfx pass.
*/
struct sfb_update_desc {
    sg_range pixels;
    sg_range palette;
}

/*
    sfb_render_overrides

    Passed into sfb_render_ex() to override the default shader. Mainly
    useful to inject custom shaders (like CRT shaders).

    TODO: add more details once sokol_crt.h is ready.
*/
struct sfb_render_desc {
    bool use_nearest_filter;
    sg_pipeline pip;
    sg_view[32] views;
    sg_sampler[12] samplers;
    sg_range[8] uniforms;
}

/*
    sfb_texture_info

    Nested struct in sfb_framebuffer_info to describe the properties of
    an internal image/view pair.
*/
struct sfb_texture_info {
    i32 width;
    i32 height;
    sg_pixel_format pixel_format;
    sg_image image;
    sg_view tex_view;
}

/*
    sfb_framebuffer_info

    Result of sfb_query_framebuffer_info(), returns handles to the internally
    managed images, texture views and samplers, image sizes and pixel formats.
    This is mostly useful when completely replacing the sfb_render[_ex]()
    functions with a complete custom implementation (like a CRT shader which
    requires multiple render passes).
*/
struct sfb_framebuffer_info {
    sfb_texture_info update;
    sfb_texture_info offscreen;
    sfb_texture_info palette;
    sg_sampler nearest_sampler;
    sg_sampler linear_sampler;
}

/*
    sfb_allocator

    Used in sfb_desc to provide custom memory-alloc and -free functions
    to sokol_framebuffer.h. If memory management should be overridden, both the
    alloc and free function must be provided (e.g. it's not valid to
    override one function but not the other).
*/
struct sfb_allocator {
    fn(u64, void*): void* alloc_fn;
    fn(void*, void*): void free_fn;
    void* user_data;
}

/*
    sfb_logger

    Used in sfb_desc to provide a custom logging and error reporting
    callback to sokol_framebuffer.h.
*/
struct sfb_logger {
    fn(u8*, u32, u32, u8*, u32, u8*, void*): void func;
    void* user_data;
}

/*
    Initialization parameters passed into sfb_setup(). You should at least
    provide a logging function, otherwise you won't see any error logging.
*/
struct sfb_desc {
    i32 framebuffer_pool_size;
    sfb_allocator allocator;
    sfb_logger logger;
}

struct _sfb_slot_t {
    u32 id;
    sfb_resource_state state;
}

struct _sfb_framebuffer_t {
    _sfb_slot_t slot;
    i32 width;
    i32 height;
    i32 prescale;
    sfb_format format;
    sfb_rect cliprect;
    bool rotate90;
    sfb_render_pass_desc render_pass;
    struct {
        sg_image img;
        sg_view tex_view;
    } update;
    struct {
        sg_image img;
        sg_view tex_view;
        sg_view att_view;
    } offscreen;
    struct {
        sg_image img;
        sg_view tex_view;
    } palette;
    sg_pipeline offscreen_pip;
    sg_pipeline render_pip;
}

// resource pool housekeeping struct
struct _sfb_pool_t {
    i32 size;
    i32 queue_top;
    u32* gen_ctrs;
    i32* free_queue;
}

struct _sfb_pools_t {
    _sfb_pool_t framebuffer_pool;
    _sfb_framebuffer_t* framebuffers;
}

struct _sfb_offscreen_vs_params_t {
    f32[2] uv_offset;
    f32[2] uv_scale;
}

struct _sfb_render_vs_params_t {
    i32 rotate;
    u8[12] _pad;
}

struct _sfb_state_t {
    u32 init_tag;
    sfb_desc desc;
    _sfb_pools_t pools;
    struct {
        sg_shader palette8;
        sg_shader rgba8;
        sg_shader render;
    } shd;
    struct {
        sg_sampler nearest;
        sg_sampler linear;
    } smp;
}

/*
    sokol_framebuffer.h -- pixel framebuffer for CPU rendering

    Project URL: https://github.com/floooh/sokol

    Optionally provide the following defines with your own implementations:

    SOKOL_ASSERT(c)     - your own assert macro (default: assert(c))
    SOKOL_FRAMEBUFFER_API_DECL - public function declaration prefix (default: extern)
    SOKOL_API_DECL      - same as SOKOL_FRAMEBUFFER_API_DECL
    SOKOL_API_IMPL      - public function implementation prefix (default: -)

    If sokol_framebuffer.h is compiled as a DLL, define the following before
    including the declaration or implementation:

    SOKOL_DLL

    NOTE: the implementation is written in C99 and cannot be compiled in C++ mode,
    the declaration can be used from C++ though.

    WHAT
    ====
    Provides old-school pixel framebuffers for CPU rendering in two pixel format:

    - direct RGBA8 (32 bits per pixel)
    - 8-bits per pixel indexing a 256-entry RGBA8 color palette

    HOW
    ===
    First initialize sokol_framebuffer.h via:

        sfb_setup(&(sfb_desc){
            .logger.func = slog_func,
        });

    If you need more than 8 framebuffers at the same time, increase the
    framebuffer pool:

        sfb_setup(&(sfb_desc){
            .framebuffer_pool_size = 129,
            .logger.func = slog_func,
        });

    You can also provide a custom allocator:

        sfb_setup(&(sfb_desc){
            .framebuffer_pool_size = 129,
            .allocator = {
                .alloc_fn = my_malloc,
                .free_fn = my_free,
                .user_data = my_user_data,
            }
            .logger.func = slog_func,
        });

    Next, create one or more framebuffers. You need to provide at least
    a width and height:

        sfb_framebuffer fb = sfb_make_framebuffer(&(sfb_framebuffer_desc){
            .width = 320,
            .height = 256,
        });

    By default this creates an RGBA8 framebuffer. To get the paletted format
    (1 byte per pixel and 256 color palette entries):

        sfb_framebuffer fb = sfb_make_framebuffer(&(sfb_framebuffer_desc){
            .width = 320,
            .height = 256,
            .format = SFB_FORMAT_PALETTE8,
        });

    You can also provide a 'prescale factor'. This allows to balance
    pixel crispiness against bluriness. E.g. if you want your final rendered
    framebuffer to look less blurry but not quite have the harsh look
    of nearest filtering, try a prescale factor of 2:

        sfb_framebuffer fb = sfb_make_framebuffer(&(sfb_framebuffer_desc){
            .width = 320,
            .height = 256,
            .format = SFB_FORMAT_PALETTE8,
            .prescale = 2,
        });

    You can rotate the framebuffer by 90 degrees, this is mainly useful to
    emulate some classic arcade machines where a regular 4:3 CRT was installed
    in 'portrait mode':

        sfb_framebuffer fb = sfb_make_framebuffer(&(sfb_framebuffer_desc){
            .width = 320,
            .height = 256,
            .format = SFB_FORMAT_PALETTE8,
            .prescale = 2,
            .rotate90 = true,
        });

    You can define a sub-rectangle of the framebuffer to be rendered. For instance
    to only render the upper-left quadrant of a 320x256 framebuffer:

        sfb_framebuffer fb = sfb_make_framebuffer(&(sfb_framebuffer_desc){
            .width = 512
            .height = 512,
            .format = SFB_FORMAT_PALETTE8,
            .prescale = 2,
            .rotate90 = true,
            .cliprect = {
                .x = 0,
                .y = 0,
                .width = 160,
                .height = 128,
            }
        });

    Finally if you plan to render the framebuffer in a render pass with different
    properties than the default swapchain format, you'll need to provide
    a color- and depth-pixelformat and a sample count which matches the
    properties of the render pass:

        sfb_framebuffer fb = sfb_make_framebuffer(&(sfb_framebuffer_desc){
            .width = 320,
            .height = 256,
            .format = SFB_FORMAT_PALETTE8,
            .prescale = 2,
            .rotate90 = true,
            .render_pass = {
                .color_format = SG_PIXELFORMAT_...
                .depth_format = SG_PIXELFORMAT_...
                .sample_count = ...,
            },
        });

    The actual pixel buffer and color palette are owned by you. For a 320x256
    framebuffer with 32-bits per pixel (SFB_FORMAT_RGBA8), use an uint32_t
    buffer like this:

        uint32_t pixels[256][320];

    For the paletted format (1 byte per pixel and a 256 entry color palette):

        uint8_t pixels[256][320];
        uint32_t palette[256];

    ...now 'render' into the pixel and palette buffers with the CPU.

    An RGBA8 pixel or palette entry split into red, green, blue, alpha like this:

        |AAAAAAAA|BBBBBBBB|GGGGGGGG|RRRRRRRR|

    E.g. bits 24 to 31 are the alpha component, bits 16 to 23 the blue component,
    bits 8 to 15 to green component and bits 0 to 7 the red component. Or typically:

        uint8_t a = 255;
        uint8_t r = ...;
        uint8_t g = ...;
        uint8_t b = ...;
        uint32 pixel = (a << 24) | (b << 16) | (g << 8) | r;

    Whenever the pixel buffer or color palette content changes, call sfb_update()
    outside a sokol-gfx render pass, and ONLY ONCE PER FRAME at most:

        sfb_update(fb, &(sfb_update_desc){
            .pixels = SG_RANGE(pixels),
            .palette = SG_RANGE(palette),
        });

    Of course for an RGBA8 framebuffer you'd only provide the pixels:

        sfb_update(fb, &(sfb_update_desc){
            .pixels = SG_RANGE(pixels),
        });

    ...but even for a paletted framebuffer you can omit the data that doesn't
    change. E.g. when only the palette changes but not the pixel data:

        sfb_update(fb, &(sfb_update_desc){
            .palette = SG_RANGE(palette),
        });

    ...or vice versa when only the pixels but not the palette entries change:

        sfb_update(fb, &(sfb_update_desc){
            .pixels = SG_RANGE(pixels),
        });

    The sfb_update() function will do up to two calls to the sokol-gfx
    function sg_update_image() - once for the pixel data and once for the
    palette data (this is why the function must only be called at most
    once per frame), and then do an render pass into an internal color attachment
    texture (this is why the function must be called outside any sokol-gfx
    pass).

    Finally, to render your framebuffer to the display, call sfb_render()
    *inside* a sokol-gfx render pass:

        sg_begin_pass(...);
        sfb_render(fb);
        ...
        sg_end_pass();

    This will stretch the framebuffer to the whole canvas which might distort
    its aspect ratio. If you want a fixed aspect ratio consider setting a
    viewport with the help of sokol_letterbox.h.

    For more control over the rendering process, call sfb_render_ex() instead.
    For instance to override the default sampler with linear filtering and
    instead use a builtin sampler with nearest filtering:

        sfb_render_ex(fb, &(sfb_render_desc){
            .use_nearest_filter = true,
        });

    Note though that the prescale factor provided in the sfb_make_framebuffer()
    call is a better way to tweak bluriness vs crispiness. Only use the
    nearest-filter override if you want a 100% pixelized look.

    The main purpose of sfb_render_ex() is to inject a more advanced shader though
    (like a CRT shader).

    TODO: refer to a future sokol_crt.h header.

    If any of the sizing properties of the framebuffer changes, call:

        bool size_changed = sfb_resize(fb, &(sfb_resize_desc){
            .width = new_width,
            .height = new_height,
            .prescale = new_prescale,
            .cliprect = new_cliprect
        });

    The sfb_resize() function is 'lazy', it will only destroy and recreate internal
    objects when actually needed (e.g. the size of image objects has changed). In
    that case, true is returned. When the function returns false, it was
    basically a cheap no-op.

    If you want to do the final rendering entirely yourself you can get handles
    to all the internally used resources of a framebuffer object via:

        sfb_framebuffer_info info = sfb_query_framebuffer_info(fb);

    This returns handles to all internal image, view and sampler objects
    as well as image sizes and pixel formats.

    To query the current 'resource state' of a framebuffer:

        sfb_resoure_state state = sfb_query_framebuffer_state(fb);

    ...this is mainly useful to check whether framebuffer creation via
    sfb_make_framebuffer() had failed.

    To get a copy the the sfb_framebuffer_desc struct (patched with defaults)
    of a framebuffer object:

        sfb_framebuffer_desc desc = sfb_query_framebuffer_desc(fb);

    To destroy a framebuffer object:

        sfb_destroy_framebuffer(fb);

    ...calling sfb_shutdown() will also destroy any remaining framebuffer
    objects:

        sfb_shutdown();


    LICENSE
    =======

    zlib/libpng license

    Copyright (c) 2026 Andre Weissflog

    This software is provided 'as-is', without any express or implied warranty.
    In no event will the authors be held liable for any damages arising from the
    use of this software.

    Permission is granted to anyone to use this software for any purpose,
    including commercial applications, and to alter it and redistribute it
    freely, subject to the following restrictions:

        1. The origin of this software must not be misrepresented; you must not
        claim that you wrote the original software. If you use this software in a
        product, an acknowledgment in the product documentation would be
        appreciated but is not required.

        2. Altered source versions must be plainly marked as such, and must not
        be misrepresented as being the original software.

        3. This notice may not be removed or altered from any source
        distribution.
*/
/*=== IMPLEMENTATION =========================================================*/
when !(defined(SOKOL_DEBUG)) {
}
private {
_sfb_state_t _sfb;
u8*[13] _sfb_log_messages = {
    "OK: Ok", "MALLOC_FAILED: memory allocation failed",
    "FRAMEBUFFER_POOL_EXHAUSTED: framebuffer pool exhausted (sfb_desc.framebuffer_pool_size)",
    "INVALID_FRAMEBUFFER_WIDTH: sfb_framebuffer_desc.width must be > 0",
    "INVALID_FRAMEBUFFER_HEIGHT: sfb_framebuffer_desc.height must be > 0",
    "UPDATE_INVALID_FRAMEBUFFER_HANDLE: sfb_update: framebuffer handle not valid",
    "UPDATE_FRAMEBUFFER_RESOURCESTATE_NOT_VALID: sfb_update: framebuffer not in valid resource state",
    "UPDATE_PALETTE_RANGE_IGNORED: sfb_update: sfb_update_desc.palette is ignored for non-paletted framebuffer",
    "UPDATE_PIXEL_RANGE_SIZE_RGBA8: sfb_update: unexpected sfb_update_desc.pixels.size, must be (width * height * 4) bytes",
    "UPDATE_PIXEL_RANGE_SIZE_PALETTE8: sfb_update: unexpected sfb_update_desc.pixels.size, must be (width * height) bytes",
    "UPDATE_PALETTE_RANGE_SIZE: sfb_update: unexpected sfb_update_desc.palette.size, must be 256 * 4 bytes",
    "RENDER_EX_INVALID_FRAMEBUFFER_HANDLE: sfb_render_ex: framebuffer handle not valid",
    "RENDER_EX_FRAMEBUFFER_RESOURCESTATE_NOT_VALID: sfb_render_ex: framebuffer not in valid resource state",
};

void _sfb_log(_sfb_log_item_t log_item, u32 log_level, u8* msg, u32 line_nr) {
    if _sfb.desc.logger.func != null {
        u8* filename = null;
        filename = "sokol_framebuffer.h";
        if null == msg {
            msg = _sfb_log_messages[log_item];
        }
        _sfb.desc.logger.func("sfb", log_level, cast(u32, log_item), msg, line_nr, filename, _sfb.desc.logger.user_data);
    } else {
        if log_level == 0 {
            abort();
        }
    }
}

// >>memory
void _sfb_clear(void* ptr, u64 size) {
    assert(ptr && size > 0);
    memset(ptr, 0, size);
}

void* _sfb_malloc(u64 size) {
    assert(size > 0);
    void* ptr;
    if _sfb.desc.allocator.alloc_fn != null {
        ptr = _sfb.desc.allocator.alloc_fn(size, _sfb.desc.allocator.user_data);
    } else {
        ptr = alloc(cast(i64, size));
    }
    if null == ptr {
        _sfb_log(_SFB_LOGITEM_MALLOC_FAILED, 0, null, 4727);
    }
    return ptr;
}

void* _sfb_malloc_clear(u64 size) {
    void* ptr = _sfb_malloc(size);
    _sfb_clear(ptr, size);
    return ptr;
}

void _sfb_free(void* ptr) {
    if _sfb.desc.allocator.free_fn != null {
        _sfb.desc.allocator.free_fn(ptr, _sfb.desc.allocator.user_data);
    } else {
        free(ptr);
    }
}

// >>pool
void _sfb_pool_init(_sfb_pool_t* pool, i32 num) {
    assert(pool && num >= 1);
    pool.size = num + 1;
    pool.queue_top = 0;
    u64 gen_ctrs_size = cast(u64, sizeof(u32)) * cast(u64, pool.size);
    pool.gen_ctrs = cast(u32*, _sfb_malloc_clear(gen_ctrs_size));
    pool.free_queue = cast(i32*, _sfb_malloc_clear(cast(u64, sizeof(i32)) * cast(u64, num)));
    for i32 i = pool.size - 1; i >= 1; i-- {
        pool.free_queue[pool.queue_top++] = i;
    }
}

void _sfb_pool_discard(_sfb_pool_t* pool) {
    assert(cast(i64, pool));
    assert(cast(i64, pool.free_queue));
    _sfb_free(pool.free_queue);
    pool.free_queue = null;
    assert(cast(i64, pool.gen_ctrs));
    _sfb_free(pool.gen_ctrs);
    pool.gen_ctrs = null;
    pool.size = 0;
    pool.queue_top = 0;
}

i32 _sfb_pool_alloc_index(_sfb_pool_t* pool) {
    assert(cast(i64, pool));
    assert(cast(i64, pool.free_queue));
    if pool.queue_top > 0 {
        i32 slot_index = pool.free_queue[--pool.queue_top];
        assert(slot_index > 0 && slot_index < pool.size);
        return slot_index;
    } else {
        return 0;
    }
}

void _sfb_pool_free_index(_sfb_pool_t* pool, i32 slot_index) {
    assert(slot_index > 0 && slot_index < pool.size);
    assert(cast(i64, pool));
    assert(cast(i64, pool.free_queue));
    assert(pool.queue_top < pool.size);
    when defined(SOKOL_DEBUG) {
        for i32 i = 0; i < pool.queue_top; i++ {
            assert(pool.free_queue[i] != slot_index);
        }
    }
    pool.free_queue[pool.queue_top++] = slot_index;
    assert(pool.queue_top <= pool.size - 1);
}

void _sfb_setup_pools(_sfb_pools_t* p, sfb_desc* desc) {
    assert(cast(i64, p));
    assert(cast(i64, desc));
    assert(desc.framebuffer_pool_size > 0 && desc.framebuffer_pool_size < _SFB_MAX_POOL_SIZE);
    _sfb_pool_init(&p.framebuffer_pool, desc.framebuffer_pool_size);
    u64 fb_pool_byte_size = cast(u64, sizeof(_sfb_framebuffer_t)) * cast(u64, p.framebuffer_pool.size);
    p.framebuffers = cast(_sfb_framebuffer_t*, _sfb_malloc_clear(fb_pool_byte_size));
}

void _sfb_discard_pools(_sfb_pools_t* p) {
    assert(cast(i64, p));
    _sfb_free(p.framebuffers);
    p.framebuffers = null;
    _sfb_pool_discard(&p.framebuffer_pool);
}

/* allocate the slot at slot_index:
    - bump the slot's generation counter
    - create a resource id from the generation counter and slot index
    - set the slot's id to this id
    - set the slot's state to ALLOC
    - return the resource id
*/
u32 _sfb_slot_alloc(_sfb_pool_t* pool, _sfb_slot_t* slot, i32 slot_index) {
    assert(pool && pool.gen_ctrs);
    assert(slot_index > 0 && slot_index < pool.size);
    assert(slot.id == cast(u32, SFB_INVALID_ID));
    assert(slot.state == SFB_RESOURCESTATE_INITIAL);
    u32 ctr = ++pool.gen_ctrs[slot_index];
    slot.id = ctr << cast(u32, _SFB_SLOT_SHIFT) | cast(u32, slot_index & _SFB_SLOT_MASK);
    slot.state = SFB_RESOURCESTATE_ALLOC;
    return slot.id;
}

// extract slot index from id
i32 _sfb_slot_index(u32 id) {
    var slot_index = cast(i32, id & cast(u32, _SFB_SLOT_MASK));
    assert(0 != slot_index);
    return slot_index;
}

// returns pointer to resource by id without matching id check
_sfb_framebuffer_t* _sfb_framebuffer_at(u32 fb_id) {
    assert(cast(u32, SFB_INVALID_ID) != fb_id);
    i32 slot_index = _sfb_slot_index(fb_id);
    assert(slot_index > 0 && slot_index < _sfb.pools.framebuffer_pool.size);
    return &_sfb.pools.framebuffers[slot_index];
}

// returns pointer to resource with matching id check, may return 0
_sfb_framebuffer_t* _sfb_lookup_framebuffer(u32 fb_id) {
    if cast(u32, SFB_INVALID_ID) != fb_id {
        _sfb_framebuffer_t* fb = _sfb_framebuffer_at(fb_id);
        if fb.slot.id == fb_id {
            return fb;
        }
    }
    return null;
}

sfb_framebuffer _sfb_alloc_framebuffer() {
    noinit sfb_framebuffer res;
    i32 slot_index = _sfb_pool_alloc_index(&_sfb.pools.framebuffer_pool);
    if 0 != slot_index {
        res.id = _sfb_slot_alloc(&_sfb.pools.framebuffer_pool, &_sfb.pools.framebuffers[slot_index].slot, slot_index);
    } else {
        res.id = cast(u32, SFB_INVALID_ID);
        _sfb_log(_SFB_LOGITEM_FRAMEBUFFER_POOL_EXHAUSTED, 1, null, 4728);
    }
    return res;
}

void _sfb_dealloc_framebuffer(_sfb_framebuffer_t* fb) {
    assert(fb && fb.slot.state == SFB_RESOURCESTATE_ALLOC && fb.slot.id != cast(u32, SFB_INVALID_ID));
    _sfb_pool_free_index(&_sfb.pools.framebuffer_pool, _sfb_slot_index(fb.slot.id));
    _sfb_clear(fb, cast(u64, sizeof(_sfb_framebuffer_t)));
}

sfb_desc _sfb_desc_defaults(sfb_desc* desc) {
    assert(cast(i64, desc));
    sfb_desc res = *desc;
    res.framebuffer_pool_size = res.framebuffer_pool_size == 0 ? _SFB_DEFAULT_FRAMEBUFFER_POOL_SIZE : res.framebuffer_pool_size;
    return res;
}

void _sfb_destroy_update_images_and_views(_sfb_framebuffer_t* fb) {
    assert(cast(i64, fb));
    sg_destroy_image(fb.update.img);
    sg_destroy_view(fb.update.tex_view);
}

void _sfb_destroy_offscreen_images_and_views(_sfb_framebuffer_t* fb) {
    assert(cast(i64, fb));
    sg_destroy_image(fb.offscreen.img);
    sg_destroy_view(fb.offscreen.tex_view);
    sg_destroy_view(fb.offscreen.att_view);
}

void _sfb_destroy_palette_images_and_views(_sfb_framebuffer_t* fb) {
    assert(cast(i64, fb));
    sg_destroy_image(fb.palette.img);
    sg_destroy_view(fb.palette.tex_view);
}

bool _sfb_create_update_images_and_views(_sfb_framebuffer_t* fb) {
    assert(cast(i64, fb));
    bool valid = true;
    fb.update.img = sg_make_image(&sg_image_desc{
        .usage = sg_image_usage{.dynamic_update = true},
        .width = fb.width,
        .height = fb.height,
        .pixel_format = fb.format == SFB_FORMAT_RGBA8 ? SG_PIXELFORMAT_RGBA8 : SG_PIXELFORMAT_R8,
        .label = "sfb-update-image",
    });
    valid &= sg_query_image_state(fb.update.img) == SG_RESOURCESTATE_VALID;
    fb.update.tex_view = sg_make_view(&sg_view_desc{
        .texture = sg_texture_view_desc{.image = fb.update.img},
        .label = "sfb-update-tex-view",
    });
    valid &= sg_query_view_state(fb.update.tex_view) == SG_RESOURCESTATE_VALID;
    return valid;
}

bool _sfb_create_offscreen_images_and_views(_sfb_framebuffer_t* fb) {
    assert(cast(i64, fb));
    bool valid = true;
    fb.offscreen.img = sg_make_image(&sg_image_desc{
        .usage = sg_image_usage{.color_attachment = true},
        .width = fb.cliprect.width * fb.prescale,
        .height = fb.cliprect.height * fb.prescale,
        .pixel_format = SG_PIXELFORMAT_RGBA8,
        .label = "sfb-offscreen-image",
    });
    valid &= sg_query_image_state(fb.offscreen.img) == SG_RESOURCESTATE_VALID;
    fb.offscreen.tex_view = sg_make_view(&sg_view_desc{
        .texture = sg_texture_view_desc{.image = fb.offscreen.img},
        .label = "sfb-offscreen-texture-view",
    });
    valid &= sg_query_view_state(fb.offscreen.tex_view) == SG_RESOURCESTATE_VALID;
    fb.offscreen.att_view = sg_make_view(&sg_view_desc{
        .color_attachment = sg_image_view_desc{.image = fb.offscreen.img},
        .label = "sfb-offscreen-attachment-view",
    });
    valid &= sg_query_view_state(fb.offscreen.att_view) == SG_RESOURCESTATE_VALID;
    return valid;
}

bool _sfb_create_palette_images_and_views(_sfb_framebuffer_t* fb) {
    assert(cast(i64, fb));
    bool valid = true;
    if fb.format == SFB_FORMAT_PALETTE8 {
        fb.palette.img = sg_make_image(&sg_image_desc{
            .usage = sg_image_usage{.dynamic_update = true},
            .width = 256,
            .height = 1,
            .pixel_format = SG_PIXELFORMAT_RGBA8,
            .label = "sfb-palette-img",
        });
        valid &= sg_query_image_state(fb.palette.img) == SG_RESOURCESTATE_VALID;
        fb.palette.tex_view = sg_make_view(&sg_view_desc{.texture = sg_texture_view_desc{.image = fb.palette.img}});
        valid &= sg_query_view_state(fb.palette.tex_view) == SG_RESOURCESTATE_VALID;
    }
    return valid;
}

void _sfb_init_framebuffer(_sfb_framebuffer_t* fb, sfb_framebuffer_desc* desc) {
    assert(fb && fb.slot.state == SFB_RESOURCESTATE_ALLOC);
    assert(cast(i64, desc));
    if desc.width <= 0 {
        _sfb_log(_SFB_LOGITEM_INVALID_FRAMEBUFFER_WIDTH, 1, null, 4728);
        fb.slot.state = SFB_RESOURCESTATE_FAILED;
        return;
    }
    if desc.height <= 0 {
        _sfb_log(_SFB_LOGITEM_INVALID_FRAMEBUFFER_HEIGHT, 1, null, 4728);
        fb.slot.state = SFB_RESOURCESTATE_FAILED;
        return;
    }
    fb.width = desc.width;
    fb.height = desc.height;
    fb.prescale = desc.prescale == 0 ? 1 : desc.prescale;
    fb.format = desc.format == 0 ? SFB_FORMAT_RGBA8 : desc.format;
    fb.cliprect.x = desc.cliprect.x;
    fb.cliprect.y = desc.cliprect.y;
    fb.cliprect.width = desc.cliprect.width == 0 ? fb.width : desc.cliprect.width;
    fb.cliprect.height = desc.cliprect.height == 0 ? fb.height : desc.cliprect.height;
    fb.rotate90 = desc.rotate90;
    fb.render_pass = desc.render_pass;
    bool valid = _sfb_create_update_images_and_views(fb);
    valid &= _sfb_create_offscreen_images_and_views(fb);
    valid &= _sfb_create_palette_images_and_views(fb);
    fb.offscreen_pip = sg_make_pipeline(&sg_pipeline_desc{
        .shader = fb.format == SFB_FORMAT_PALETTE8 ? _sfb.shd.palette8 : _sfb.shd.rgba8,
        .depth = sg_depth_state{.pixel_format = SG_PIXELFORMAT_NONE},
        .colors[0] = {.pixel_format = SG_PIXELFORMAT_RGBA8},
        .label = "sfb-pipeline",
    });
    valid &= sg_query_pipeline_state(fb.offscreen_pip) == SG_RESOURCESTATE_VALID;
    fb.render_pip = sg_make_pipeline(&sg_pipeline_desc{
        .shader = _sfb.shd.render,
        .sample_count = fb.render_pass.sample_count,
        .depth = sg_depth_state{.pixel_format = fb.render_pass.depth_format},
        .colors[0] = {.pixel_format = fb.render_pass.color_format},
        .label = "sfb-render-pipeline",
    });
    valid &= sg_query_pipeline_state(fb.render_pip) == SG_RESOURCESTATE_VALID;
    fb.slot.state = valid != 0 ? SFB_RESOURCESTATE_VALID : SFB_RESOURCESTATE_FAILED;
}

void _sfb_uninit_framebuffer(_sfb_framebuffer_t* fb) {
    assert(fb && (fb.slot.state == SFB_RESOURCESTATE_VALID || fb.slot.state == SFB_RESOURCESTATE_FAILED));
    _sfb_destroy_palette_images_and_views(fb);
    _sfb_destroy_offscreen_images_and_views(fb);
    _sfb_destroy_update_images_and_views(fb);
    sg_destroy_pipeline(fb.offscreen_pip);
    sg_destroy_pipeline(fb.render_pip);
    fb.slot.state = SFB_RESOURCESTATE_ALLOC;
}

void _sfb_discard_all_resources() {
    for i32 i = 1; i < _sfb.pools.framebuffer_pool.size; i++ {
        sfb_resource_state state = _sfb.pools.framebuffers[i].slot.state;
        if state == SFB_RESOURCESTATE_VALID || state == SFB_RESOURCESTATE_FAILED {
            _sfb_uninit_framebuffer(&_sfb.pools.framebuffers[i]);
        }
    }
}

bool _sfb_validate_update(_sfb_framebuffer_t* fb, sfb_update_desc* desc) {
    if fb == null {
        _sfb_log(_SFB_LOGITEM_UPDATE_INVALID_FRAMEBUFFER_HANDLE, 1, null, 4728);
        return false;
    }
    if fb.slot.state != SFB_RESOURCESTATE_VALID {
        _sfb_log(_SFB_LOGITEM_UPDATE_FRAMEBUFFER_RESOURCESTATE_NOT_VALID, 1, null, 4728);
        return false;
    }
    if desc.pixels.ptr != null {
        if fb.format == SFB_FORMAT_PALETTE8 {
            if desc.pixels.size != cast(u64, fb.width * fb.height) {
                _sfb_log(_SFB_LOGITEM_UPDATE_PIXEL_RANGE_SIZE_PALETTE8, 1, null, 4728);
                return false;
            }
        } else {
            if desc.pixels.size != cast(u64, fb.width * fb.height * 4) {
                _sfb_log(_SFB_LOGITEM_UPDATE_PIXEL_RANGE_SIZE_RGBA8, 1, null, 4728);
                return false;
            }
        }
    }
    if desc.palette.ptr != null {
        if fb.format == SFB_FORMAT_PALETTE8 {
            if desc.palette.size != cast(u64, 256 * sizeof(u32)) {
                _sfb_log(_SFB_LOGITEM_UPDATE_PALETTE_RANGE_SIZE, 1, null, 4728);
                return false;
            }
        }
    }
    return true;
}
}

private {
void _sfb_create_palette8_shader() {
    _sfb.shd.palette8 = _sfb_minc_palette8_shader();
}

void _sfb_create_rgba8_shader() {
    _sfb.shd.rgba8 = _sfb_minc_rgba8_shader();
}

void _sfb_create_render_shader() {
    _sfb.shd.render = _sfb_minc_render_shader();
}

void _sfb_create_shaders() {
    _sfb_create_palette8_shader();
    _sfb_create_rgba8_shader();
    _sfb_create_render_shader();
}

void _sfb_destroy_shaders() {
    sg_destroy_shader(_sfb.shd.palette8);
    sg_destroy_shader(_sfb.shd.rgba8);
    sg_destroy_shader(_sfb.shd.render);
}

void _sfb_create_samplers() {
    _sfb.smp.nearest = sg_make_sampler(&sg_sampler_desc{
        .min_filter = SG_FILTER_NEAREST,
        .mag_filter = SG_FILTER_NEAREST,
        .wrap_u = SG_WRAP_CLAMP_TO_EDGE,
        .wrap_v = SG_WRAP_CLAMP_TO_EDGE,
        .label = "sfb-nearest-sampler",
    });
    _sfb.smp.linear = sg_make_sampler(&sg_sampler_desc{
        .min_filter = SG_FILTER_LINEAR,
        .mag_filter = SG_FILTER_LINEAR,
        .wrap_u = SG_WRAP_CLAMP_TO_EDGE,
        .wrap_v = SG_WRAP_CLAMP_TO_EDGE,
        .label = "sfb-linear-sampler",
    });
}

void _sfb_destroy_samplers() {
    sg_destroy_sampler(_sfb.smp.nearest);
    sg_destroy_sampler(_sfb.smp.linear);
}

void _sfb_render(_sfb_framebuffer_t* fb, sfb_render_desc* desc) {
    assert(cast(i64, desc));
    if fb == null {
        _sfb_log(_SFB_LOGITEM_RENDER_EX_INVALID_FRAMEBUFFER_HANDLE, 1, null, 4728);
        return;
    }
    if fb.slot.state != SFB_RESOURCESTATE_VALID {
        _sfb_log(_SFB_LOGITEM_RENDER_EX_FRAMEBUFFER_RESOURCESTATE_NOT_VALID, 1, null, 4728);
        return;
    }
    sg_pipeline pip = desc.pip.id != cast(u32, SG_INVALID_ID) ? desc.pip : fb.render_pip;
    sg_bindings bindings;
    bindings.views[0] = fb.offscreen.tex_view;
    for i32 i = 1; i < SG_MAX_VIEW_BINDSLOTS; i++ {
        bindings.views[i] = desc.views[i];
    }
    for i32 i = 0; i < SG_MAX_SAMPLER_BINDSLOTS; i++ {
        bindings.samplers[i] = desc.samplers[i];
    }
    if bindings.samplers[0].id == cast(u32, SG_INVALID_ID) {
        bindings.samplers[0] = desc.use_nearest_filter != 0 ? _sfb.smp.nearest : _sfb.smp.linear;
    }
    sg_apply_pipeline(pip);
    sg_apply_bindings(&bindings);
    var vs_params = _sfb_render_vs_params_t{.rotate = cast(i32, fb.rotate90)};
    sg_apply_uniforms(0, &sg_range{&vs_params, sizeof(vs_params)});
    for i32 ub_slot = 1; ub_slot < SG_MAX_UNIFORMBLOCK_BINDSLOTS; ub_slot++ {
        if desc.uniforms[ub_slot].ptr != null {
            sg_apply_uniforms(ub_slot, &desc.uniforms[ub_slot]);
        }
    }
    sg_draw(0, 3, 1);
}
}

// >>public
void sfb_setup(sfb_desc* desc) {
    assert(cast(i64, desc));
    assert(desc.allocator.alloc_fn && desc.allocator.free_fn || !desc.allocator.alloc_fn && !desc.allocator.free_fn);
    _sfb_clear(&_sfb, cast(u64, sizeof(_sfb)));
    _sfb.init_tag = 0xDCBADCBA;
    _sfb.desc = _sfb_desc_defaults(desc);
    _sfb_setup_pools(&_sfb.pools, &_sfb.desc);
    _sfb_create_samplers();
    _sfb_create_shaders();
}

void sfb_shutdown() {
    assert(0xDCBADCBA == _sfb.init_tag);
    _sfb_destroy_shaders();
    _sfb_destroy_samplers();
    _sfb_discard_all_resources();
    _sfb_discard_pools(&_sfb.pools);
    _sfb_clear(&_sfb, cast(u64, sizeof(_sfb)));
}

sfb_framebuffer sfb_make_framebuffer(sfb_framebuffer_desc* desc) {
    assert(0xDCBADCBA == _sfb.init_tag);
    assert(cast(i64, desc));
    sfb_framebuffer fb_id = _sfb_alloc_framebuffer();
    if fb_id.id != cast(u32, SFB_INVALID_ID) {
        _sfb_framebuffer_t* fb = _sfb_framebuffer_at(fb_id.id);
        assert(fb && fb.slot.state == SFB_RESOURCESTATE_ALLOC);
        _sfb_init_framebuffer(fb, desc);
        assert(fb.slot.state == SFB_RESOURCESTATE_VALID || fb.slot.state == SFB_RESOURCESTATE_FAILED);
    }
    return fb_id;
}

void sfb_destroy_framebuffer(sfb_framebuffer fb_id) {
    assert(0xDCBADCBA == _sfb.init_tag);
    _sfb_framebuffer_t* fb = _sfb_lookup_framebuffer(fb_id.id);
    if fb != null {
        if fb.slot.state == SFB_RESOURCESTATE_VALID || fb.slot.state == SFB_RESOURCESTATE_FAILED {
            _sfb_uninit_framebuffer(fb);
            assert(fb.slot.state == SFB_RESOURCESTATE_ALLOC);
        }
        if fb.slot.state == SFB_RESOURCESTATE_ALLOC {
            _sfb_dealloc_framebuffer(fb);
            assert(fb.slot.state == SFB_RESOURCESTATE_INITIAL);
        }
    }
}

sfb_resource_state sfb_query_framebuffer_state(sfb_framebuffer fb_id) {
    assert(0xDCBADCBA == _sfb.init_tag);
    _sfb_framebuffer_t* fb = _sfb_lookup_framebuffer(fb_id.id);
    return fb != null ? fb.slot.state : SFB_RESOURCESTATE_INVALID;
}

sfb_framebuffer_info sfb_query_framebuffer_info(sfb_framebuffer fb_id) {
    assert(0xDCBADCBA == _sfb.init_tag);
    _sfb_framebuffer_t* fb = _sfb_lookup_framebuffer(fb_id.id);
    if fb != null {
        return sfb_framebuffer_info{
            .update = sfb_texture_info{
                .width = fb.width,
                .height = fb.height,
                .pixel_format = fb.format == SFB_FORMAT_RGBA8 ? SG_PIXELFORMAT_RGBA8 : SG_PIXELFORMAT_R8,
                .image = fb.update.img,
                .tex_view = fb.update.tex_view,
            },
            .offscreen = sfb_texture_info{
                .width = fb.cliprect.width * fb.prescale,
                .height = fb.cliprect.height * fb.prescale,
                .pixel_format = SG_PIXELFORMAT_RGBA8,
                .image = fb.offscreen.img,
                .tex_view = fb.offscreen.tex_view,
            },
            .palette = sfb_texture_info{
                .width = 256,
                .height = 1,
                .pixel_format = SG_PIXELFORMAT_RGBA8,
                .image = fb.palette.img,
                .tex_view = fb.palette.tex_view,
            },
            .nearest_sampler = _sfb.smp.nearest,
            .linear_sampler = _sfb.smp.linear,
        };
    } else {
        return sfb_framebuffer_info{};
    }
}

sfb_framebuffer_desc sfb_query_framebuffer_desc(sfb_framebuffer fb_id) {
    assert(0xDCBADCBA == _sfb.init_tag);
    _sfb_framebuffer_t* fb = _sfb_lookup_framebuffer(fb_id.id);
    if fb != null {
        return sfb_framebuffer_desc{
            .width = fb.width,
            .height = fb.height,
            .prescale = fb.prescale,
            .format = fb.format,
            .cliprect = fb.cliprect,
            .rotate90 = fb.rotate90,
            .render_pass = fb.render_pass,
        };
    } else {
        return sfb_framebuffer_desc{};
    }
}

bool sfb_resize(sfb_framebuffer fb_id, sfb_resize_desc* desc) {
    assert(0xDCBADCBA == _sfb.init_tag);
    assert(cast(i64, desc));
    _sfb_framebuffer_t* fb = _sfb_lookup_framebuffer(fb_id.id);
    bool retval = false;
    if fb != null {
        if desc.width != fb.width || desc.height != fb.height {
            retval = true;
            _sfb_destroy_update_images_and_views(fb);
            fb.width = desc.width;
            fb.height = desc.height;
            bool res = _sfb_create_update_images_and_views(fb);
            if res == 0 {
                fb.slot.state = SFB_RESOURCESTATE_FAILED;
            }
        }
        i32 prescale = desc.prescale == 0 ? 1 : desc.prescale;
        i32 cw = desc.cliprect.width == 0 ? fb.width : desc.cliprect.width;
        i32 ch = desc.cliprect.height == 0 ? fb.height : desc.cliprect.height;
        if prescale != fb.prescale || cw != fb.cliprect.width || ch != fb.cliprect.height {
            retval = true;
            _sfb_destroy_offscreen_images_and_views(fb);
            fb.prescale = prescale;
            fb.cliprect.width = desc.cliprect.width;
            fb.cliprect.height = desc.cliprect.height;
            bool res = _sfb_create_offscreen_images_and_views(fb);
            if res == 0 {
                fb.slot.state = SFB_RESOURCESTATE_FAILED;
            }
        }
        fb.cliprect.x = desc.cliprect.x;
        fb.cliprect.y = desc.cliprect.y;
    }
    return retval;
}

void sfb_update(sfb_framebuffer fb_id, sfb_update_desc* desc) {
    assert(0xDCBADCBA == _sfb.init_tag);
    assert(cast(i64, desc));
    _sfb_framebuffer_t* fb = _sfb_lookup_framebuffer(fb_id.id);
    if _sfb_validate_update(fb, desc) == 0 {
        return;
    }
    if desc.pixels.ptr != null {
        sg_update_image(fb.update.img, &sg_image_data{.mip_levels[0] = desc.pixels});
    }
    if fb.format == SFB_FORMAT_PALETTE8 && desc.palette.ptr {
        sg_update_image(fb.palette.img, &sg_image_data{.mip_levels[0] = desc.palette});
    }
    sg_begin_pass(&sg_pass{
        .action = sg_pass_action{.colors[0] = {.load_action = SG_LOADACTION_DONTCARE}},
        .attachments = sg_attachments{.colors[0] = fb.offscreen.att_view},
        .label = "sfb-offscreen-pass",
    });
    sg_apply_pipeline(fb.offscreen_pip);
    sg_apply_bindings(&sg_bindings{
        .views = {
            fb.update.tex_view,
            fb.palette.tex_view,
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
        .samplers[0] = _sfb.smp.nearest,
    });
    var vs_params = _sfb_offscreen_vs_params_t{
        .uv_offset = {
            cast(f32, fb.cliprect.x) / cast(f32, fb.width),
            cast(f32, fb.cliprect.y) / cast(f32, fb.height),
        },
        .uv_scale = {
            cast(f32, fb.cliprect.width) / cast(f32, fb.width),
            cast(f32, fb.cliprect.height) / cast(f32, fb.height),
        },
    };
    sg_apply_uniforms(0, &sg_range{&vs_params, sizeof(vs_params)});
    sg_draw(0, 3, 1);
    sg_end_pass();
}

void sfb_render(sfb_framebuffer fb_id) {
    assert(0xDCBADCBA == _sfb.init_tag);
    _sfb_framebuffer_t* fb = _sfb_lookup_framebuffer(fb_id.id);
    _sfb_render(fb, &sfb_render_desc{});
}

void sfb_render_ex(sfb_framebuffer fb_id, sfb_render_desc* desc) {
    assert(0xDCBADCBA == _sfb.init_tag);
    assert(cast(i64, desc));
    _sfb_framebuffer_t* fb = _sfb_lookup_framebuffer(fb_id.id);
    _sfb_render(fb, desc);
}

