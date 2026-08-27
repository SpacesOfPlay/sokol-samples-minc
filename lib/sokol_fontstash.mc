// sokol_fontstash : transpiled from sokol_fontstash.h
import sokol_all;
import sokol_gl;
import fontstash;

// sokol_fontstash.h shader as minc @shader functions, replacing the
// upstream header's per-backend source text and bytecode blobs.
//
// Interface mirrors the upstream sokol-shdc program, and is the same
// one sokol_gl.h uses — the renderer draws through sokol-gl and must
// match its vertex layout:
//   attrs: position(0) f4, texcoord0(1) f2, color0(2) f4, psize(3) f1
//   uniform block 0 (vertex): mvp + tm, matching _sgl_uniform_t
//   fragment: texture(0) + sampler(0)
// Only the fragment differs: the font atlas is single-channel, so its
// RED channel is read as coverage and modulates the vertex colour.

struct SfonsVsOut {
    float4 pos;
    when gpu(opengl) || gpu(opengles) || gpu(metal) { @point_size f32 psize; }
    float4 uv;
    float4 color;
}

@gpu_layout
struct Ub_sfons_vs_params {
    float4x4 mvp;
    float4x4 tm;
}

@shader vertex
SfonsVsOut sfons_vs(
    @attr(0) float4 position,
    @attr(1) float2 texcoord0,
    @attr(2) float4 color0,
    @attr(3) f32 psize,
    @uniform(0) Ub_sfons_vs_params p
) {
    SfonsVsOut o;
    o.pos = mul(p.mvp, position);
    // Point size reaches Metal and GL only; D3D11 and WGSL have no
    // equivalent, matching the upstream shaders.
    when gpu(opengl) || gpu(opengles) || gpu(metal) {
        o.psize = psize;
    }
    o.uv = mul(p.tm, float4{texcoord0.x, texcoord0.y, 0.0f, 1.0f});
    o.color = color0;
    return o;
}

@shader fragment
float4 sfons_fs(
    SfonsVsOut input,
    @texture(0) Texture2D tex,
    @sampler(0) Sampler smp
) {
    // The atlas is R8: coverage in the red channel, no colour of its
    // own. White with that coverage as alpha, times the vertex colour.
    f32 coverage = sample(tex, smp, float2{input.uv.x, input.uv.y}).x;
    return float4{1.0f, 1.0f, 1.0f, coverage} * input.color;
}

// Shader constructor for sokol_fontstash.h. The header's renderer
// setup calls this instead of building per-backend descriptors.

sg_shader _sfons_minc_shader() {
    return sokol_make_shader(&sfons_vs_shader, &sfons_fs_shader);
}

/*
    sfonst_allocator_t

    Used in sfons_desc_t to provide custom memory-alloc and -free functions
    to sokol_fontstash.h. If memory management should be overridden, both the
    alloc_fn and free_fn function must be provided (e.g. it's not valid to
    override one function but not the other).

    NOTE that this does not affect memory allocation calls inside
    fontstash.h
*/
struct sfons_allocator_t {
    fn(u64, void*): void* alloc_fn;
    fn(void*, void*): void free_fn;
    void* user_data;
}

struct sfons_desc_t {
    i32 width;
    i32 height;
    sfons_allocator_t allocator;
}

//<#shdgen
struct _sfons_t {
    sfons_desc_t desc;
    sg_shader shd;
    sgl_pipeline pip;
    sg_image img;
    sg_view tex_view;
    sg_sampler smp;
    i32 cur_width;
    i32 cur_height;
    bool img_dirty;
}

/*
    sokol_fontstash.h -- renderer for https://github.com/memononen/fontstash
                         on top of sokol_gl.h

    Project URL: https://github.com/floooh/sokol

    Do this:
        #define SOKOL_IMPL or
        #define SOKOL_FONTSTASH_IMPL

    before you include this file in *one* C or C++ file to create the
    implementation.

    The following defines are used by the implementation to select the
    platform-specific embedded shader code (these are the same defines as
    used by sokol_gfx.h and sokol_app.h):

    SOKOL_GLCORE
    SOKOL_GLES3
    SOKOL_D3D11
    SOKOL_METAL
    SOKOL_WGPU
    SOKOL_VULKAN

    ...optionally provide the following macros to override defaults:

    SOKOL_ASSERT(c)     - your own assert macro (default: assert(c))
    SOKOL_FONTSTASH_API_DECL    - public function declaration prefix (default: extern)
    SOKOL_API_DECL      - same as SOKOL_FONTSTASH_API_DECL
    SOKOL_API_IMPL      - public function implementation prefix (default: -)
    SOKOL_UNREACHABLE() - a guard macro for unreachable code (default: assert(false))

    Include the following headers before including sokol_fontstash.h:

        sokol_gfx.h

    Additionally include the following headers for including the sokol_fontstash.h
    implementation:

        sokol_gl.h

    HOW TO
    ======
    --- First initialize sokol-gfx and sokol-gl as usual:

            sg_setup(&(sg_desc){...});
            sgl_setup(&(sgl_desc){...});

    --- Create at least one fontstash context with sfons_create() (this replaces
        glfonsCreate() from fontstash.h's example GL renderer:

            FONScontext* ctx = sfons_create(&(sfons_desc_t){
                .width = atlas_width,
                .height = atlas_height,
            });

        Each FONScontext manages one font atlas texture which can hold rasterized
        glyphs for multiple fonts.

    --- From here on, use fontstash.h's functions "as usual" to add TTF
        font data and draw text. Note that (just like with sokol-gl), text
        rendering can happen anywhere in the frame, not only inside
        a sokol-gfx rendering pass.

    --- You can use the helper function

            uint32_t sfons_rgba(uint8_t r, uint8_t g, uint8_t b, uint8_t a)

        To convert a 0..255 RGBA color into a packed uint32_t color value
        expected by fontstash.h.

    --- Once per frame before calling sgl_draw(), call:

            sfons_flush(FONScontext* ctx)

        ...this will update the dynamic sokol-gfx texture with the latest font
        atlas content.

    --- To actually render the text (and any other sokol-gl draw commands),
        call sgl_draw() inside a sokol-gfx frame.

    --- NOTE that you can mix fontstash.h calls with sokol-gl calls to mix
        text rendering with sokol-gl rendering. You can also use
        sokol-gl's matrix stack to position fontstash.h text in 3D.

    --- finally on application shutdown, call:

            sfons_destroy(FONScontext* ctx)

        before sgl_shutdown() and sg_shutdown()


    WHAT HAPPENS UNDER THE HOOD:
    ============================

    FONScontext* sfons_create(const sfons_desc_t* desc)
        - creates a sokol-gfx shader compatible with sokol-gl
        - creates an sgl_pipeline object with alpha-blending using
          this shader
        - creates a 1-byte-per-pixel font atlas texture via sokol-gfx
          (pixel format SG_PIXELFORMAT_R8)

    fonsDrawText():
        - this will call the following sequence of sokol-gl functions:

            sgl_enable_texture();
            sgl_texture(...);
            sgl_push_pipeline();
            sgl_load_pipeline(...);
            sgl_begin_triangles();
            for each vertex:
                sgl_v2f_t2f_c1i(...);
            sgl_end();
            sgl_pop_pipeline();
            sgl_disable_texture();

        - note that sokol-gl will merge several sgl_*_begin/sgl_end pairs
          into a single draw call if no relevant state has changed, typically
          all calls to fonsDrawText() will be merged into a single draw call
          as long as all calls use the same FONScontext

    sfons_flush(FONScontext* ctx):
        - this will call sg_update_image() on the font atlas texture
          if fontstash.h has added any rasterized glyphs since the last
          frame

    sfons_destroy(FONScontext* ctx):
        - destroy the font atlas texture, sgl_pipeline and sg_shader objects


    MEMORY ALLOCATION OVERRIDE
    ==========================
    You can override the memory allocation functions at initialization time
    like this:

        void* my_alloc(size_t size, void* user_data) {
            return malloc(size);
        }

        void my_free(void* ptr, void* user_data) {
            free(ptr);
        }

        ...
        FONScontext* fons_context = sfons_create(&(sfons_desc_t){
            ...
            .allocator = {
                .alloc_fn = my_alloc,
                .free_fn = my_free,
                .user_data = ...,
            }
        });
        ...

    If no overrides are provided, malloc and free will be used. Please
    note that this doesn't affect any memory allocation performed
    in fontstash.h (unfortunately those are hardwired to malloc/free).

    LICENSE
    =======
    zlib/libpng license

    Copyright (c) 2018 Andre Weissflog

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
/*-- IMPLEMENTATION ----------------------------------------------------------*/
when !(defined(SOKOL_DEBUG)) {
}

private {
void _sfons_clear(void* ptr, u64 size) {
    memset(ptr, 0, size);
}

void* _sfons_malloc(sfons_allocator_t* allocator, u64 size) {
    void* ptr;
    if allocator.alloc_fn != null {
        ptr = allocator.alloc_fn(size, allocator.user_data);
    } else {
        ptr = alloc(cast(i64, size));
    }
    return ptr;
}

void* _sfons_malloc_clear(sfons_allocator_t* allocator, u64 size) {
    void* ptr = _sfons_malloc(allocator, size);
    _sfons_clear(ptr, size);
    return ptr;
}

void _sfons_free(sfons_allocator_t* allocator, void* ptr) {
    if allocator.free_fn != null {
        allocator.free_fn(ptr, allocator.user_data);
    } else {
        free(ptr);
    }
}

i32 _sfons_render_create(void* user_ptr, i32 width, i32 height) {
    var sfons = cast(_sfons_t*, user_ptr);
    if sfons.shd.id == cast(u32, SG_INVALID_ID) {
        sfons.shd = _sfons_minc_shader();
    }
    if sfons.pip.id == cast(u32, SG_INVALID_ID) {
        noinit sg_pipeline_desc pip_desc;
        _sfons_clear(&pip_desc, cast(u64, sizeof(pip_desc)));
        pip_desc.shader = sfons.shd;
        pip_desc.colors[0].blend.enabled = true;
        pip_desc.colors[0].blend.src_factor_rgb = SG_BLENDFACTOR_SRC_ALPHA;
        pip_desc.colors[0].blend.dst_factor_rgb = SG_BLENDFACTOR_ONE_MINUS_SRC_ALPHA;
        pip_desc.label = "fontstash-pipeline";
        sfons.pip = sgl_make_pipeline(&pip_desc);
    }
    if sfons.smp.id == cast(u32, SG_INVALID_ID) {
        noinit sg_sampler_desc smp_desc;
        _sfons_clear(&smp_desc, cast(u64, sizeof(smp_desc)));
        smp_desc.min_filter = SG_FILTER_LINEAR;
        smp_desc.mag_filter = SG_FILTER_LINEAR;
        smp_desc.label = "fontstash-sampler";
        sfons.smp = sg_make_sampler(&smp_desc);
    }
    if sfons.img.id != cast(u32, SG_INVALID_ID) {
        sg_destroy_image(sfons.img);
        sfons.img.id = cast(u32, SG_INVALID_ID);
    }
    if sfons.tex_view.id != cast(u32, SG_INVALID_ID) {
        sg_destroy_view(sfons.tex_view);
        sfons.tex_view.id = cast(u32, SG_INVALID_ID);
    }
    sfons.cur_width = width;
    sfons.cur_height = height;
    noinit sg_image_desc img_desc;
    _sfons_clear(&img_desc, cast(u64, sizeof(img_desc)));
    img_desc.width = sfons.cur_width;
    img_desc.height = sfons.cur_height;
    img_desc.usage.dynamic_update = true;
    img_desc.pixel_format = SG_PIXELFORMAT_R8;
    img_desc.label = "fontstash-image";
    sfons.img = sg_make_image(&img_desc);
    noinit sg_view_desc view_desc;
    _sfons_clear(&view_desc, cast(u64, sizeof(view_desc)));
    view_desc.texture.image = sfons.img;
    view_desc.label = "fontstash-texview";
    sfons.tex_view = sg_make_view(&view_desc);
    return 1;
}

i32 _sfons_render_resize(void* user_ptr, i32 width, i32 height) {
    return _sfons_render_create(user_ptr, width, height);
}

void _sfons_render_update(void* user_ptr, i32* rect, u8* data) {
    ignore rect;
    ignore data;
    var sfons = cast(_sfons_t*, user_ptr);
    sfons.img_dirty = true;
}

void _sfons_render_draw(void* user_ptr, f32* verts, f32* tcoords, u32* colors, i32 nverts) {
    var sfons = cast(_sfons_t*, user_ptr);
    sgl_enable_texture();
    sgl_texture(sfons.tex_view, sfons.smp);
    sgl_push_pipeline();
    sgl_load_pipeline(sfons.pip);
    sgl_begin_triangles();
    for i32 i = 0; i < nverts; i++ {
        sgl_v2f_t2f_c1i(verts[2 * i + 0], verts[2 * i + 1], tcoords[2 * i + 0], tcoords[2 * i + 1], colors[i]);
    }
    sgl_end();
    sgl_pop_pipeline();
    sgl_disable_texture();
}

void _sfons_render_delete(void* user_ptr) {
    var sfons = cast(_sfons_t*, user_ptr);
    if sfons.img.id != cast(u32, SG_INVALID_ID) {
        sg_destroy_image(sfons.img);
        sfons.img.id = cast(u32, SG_INVALID_ID);
    }
    if sfons.tex_view.id != cast(u32, SG_INVALID_ID) {
        sg_destroy_view(sfons.tex_view);
        sfons.tex_view.id = cast(u32, SG_INVALID_ID);
    }
    if sfons.smp.id != cast(u32, SG_INVALID_ID) {
        sg_destroy_sampler(sfons.smp);
        sfons.smp.id = cast(u32, SG_INVALID_ID);
    }
    if sfons.pip.id != cast(u32, SG_INVALID_ID) {
        sgl_destroy_pipeline(sfons.pip);
        sfons.pip.id = cast(u32, SG_INVALID_ID);
    }
    if sfons.shd.id != cast(u32, SG_INVALID_ID) {
        sg_destroy_shader(sfons.shd);
        sfons.shd.id = cast(u32, SG_INVALID_ID);
    }
}

sfons_desc_t _sfons_desc_defaults(sfons_desc_t* desc) {
    sfons_desc_t res = *desc;
    res.width = res.width == 0 ? 512 : res.width;
    res.height = res.height == 0 ? 512 : res.height;
    return res;
}
}

FONScontext* sfons_create(sfons_desc_t* desc) {
    var sfons = cast(_sfons_t*, _sfons_malloc_clear(&desc.allocator, cast(u64, sizeof(_sfons_t))));
    sfons.desc = _sfons_desc_defaults(desc);
    noinit FONSparams params;
    _sfons_clear(&params, cast(u64, sizeof(params)));
    params.width = sfons.desc.width;
    params.height = sfons.desc.height;
    params.flags = cast(u8, FONS_ZERO_TOPLEFT);
    params.renderCreate = _sfons_render_create;
    params.renderResize = _sfons_render_resize;
    params.renderUpdate = _sfons_render_update;
    params.renderDraw = _sfons_render_draw;
    params.renderDelete = _sfons_render_delete;
    params.userPtr = sfons;
    return fonsCreateInternal(&params);
}

void sfons_destroy(FONScontext* ctx) {
    var sfons = cast(_sfons_t*, ctx.params.userPtr);
    fonsDeleteInternal(ctx);
    sfons_allocator_t allocator = sfons.desc.allocator;
    _sfons_free(&allocator, sfons);
}

void sfons_flush(FONScontext* ctx) {
    var sfons = cast(_sfons_t*, ctx.params.userPtr);
    if sfons.img_dirty != 0 {
        sfons.img_dirty = false;
        noinit sg_image_data data;
        _sfons_clear(&data, cast(u64, sizeof(data)));
        data.mip_levels[0].ptr = ctx.texData;
        data.mip_levels[0].size = cast(u64, sfons.cur_width * sfons.cur_height);
        sg_update_image(sfons.img, &data);
    }
}

u32 sfons_rgba(u8 r, u8 g, u8 b, u8 a) {
    return cast(u32, r) | cast(u32, g) << 8 | cast(u32, b) << 16 | cast(u32, a) << 24;
}

