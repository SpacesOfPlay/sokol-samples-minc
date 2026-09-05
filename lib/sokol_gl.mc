// sokol_gl : transpiled from sokol_gl.h
import sokol_all;

// sokol_gl.h shader as minc @shader functions, replacing the upstream
// header's per-backend source text and bytecode blobs.
//
// Interface mirrors the upstream sokol-shdc program:
//   attrs: position(0) f4, texcoord0(1) f2, color0(2) f4, psize(3) f1
//   uniform block 0 (vertex): mvp + tm, matching _sgl_uniform_t
//   fragment: texture(0) + sampler(0)

struct SglVsOut {
    float4 pos;
    when gpu(opengl) || gpu(opengles) || gpu(metal) { @point_size f32 psize; }
    float4 uv;
    float4 color;
}

@gpu_layout
struct Ub_sgl_vs_params {
    float4x4 mvp;
    float4x4 tm;
}

@shader vertex
SglVsOut sgl_vs(
    @attr(0) float4 position,
    @attr(1) float2 texcoord0,
    @attr(2) float4 color0,
    @attr(3) f32 psize,
    @uniform(0) Ub_sgl_vs_params p
) {
    SglVsOut o;
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
float4 sgl_fs(
    SglVsOut input,
    @texture(0) Texture2D tex,
    @sampler(0) Sampler smp
) {
    return sample(tex, smp, float2{input.uv.x, input.uv.y}) * input.color;
}

// Shader constructor for sokol_gl.h. The header's setup calls this
// instead of building per-backend descriptors.

sg_shader _sgl_minc_shader() {
    return sokol_make_shader(&sgl_vs_shader, &sgl_fs_shader);
}

/*
    sgl_log_item_t

    Log items are defined via X-Macros, and expanded to an
    enum 'sgl_log_item' - and in debug mode only - corresponding strings.

    Used as parameter in the logging callback.
*/
enum sgl_log_item_t {
    SGL_LOGITEM_OK = 0,
    SGL_LOGITEM_MALLOC_FAILED = 1,
    SGL_LOGITEM_MAKE_PIPELINE_FAILED = 2,
    SGL_LOGITEM_PIPELINE_POOL_EXHAUSTED = 3,
    SGL_LOGITEM_ADD_COMMIT_LISTENER_FAILED = 4,
    SGL_LOGITEM_CONTEXT_POOL_EXHAUSTED = 5,
    SGL_LOGITEM_CANNOT_DESTROY_DEFAULT_CONTEXT = 6,
}

//<#shdgen
// ████████ ██    ██ ██████  ███████ ███████
//    ██     ██  ██  ██   ██ ██      ██
//    ██      ████   ██████  █████   ███████
//    ██       ██    ██      ██           ██
//    ██       ██    ██      ███████ ███████
//
// >>types
enum _sgl_primitive_type_t {
    SGL_PRIMITIVETYPE_POINTS = 0,
    SGL_PRIMITIVETYPE_LINES = 1,
    SGL_PRIMITIVETYPE_LINE_STRIP = 2,
    SGL_PRIMITIVETYPE_TRIANGLES = 3,
    SGL_PRIMITIVETYPE_TRIANGLE_STRIP = 4,
    SGL_PRIMITIVETYPE_QUADS = 5,
    SGL_NUM_PRIMITIVE_TYPES = 6,
}

enum _sgl_matrix_mode_t {
    SGL_MATRIXMODE_MODELVIEW = 0,
    SGL_MATRIXMODE_PROJECTION = 1,
    SGL_MATRIXMODE_TEXTURE = 2,
    SGL_NUM_MATRIXMODES = 3,
}

enum _sgl_command_type_t {
    SGL_COMMAND_DRAW = 0,
    SGL_COMMAND_VIEWPORT = 1,
    SGL_COMMAND_SCISSOR_RECT = 2,
}

/*
    sgl_logger_t

    Used in sgl_desc_t to provide a custom logging and error reporting
    callback to sokol-gl.
*/
struct sgl_logger_t {
    fn(u8*, u32, u32, u8*, u32, u8*, void*): void func;
    void* user_data;
}

/* sokol_gl pipeline handle (created with sgl_make_pipeline()) */
struct sgl_pipeline {
    u32 id;
}

/* a context handle (created with sgl_make_context()) */
struct sgl_context {
    u32 id;
}

/*
    sgl_error_t

    Errors are reset each frame after calling sgl_draw(),
    get the last error code with sgl_error()
*/
struct sgl_error_t {
    bool any;
    bool vertices_full;
    bool uniforms_full;
    bool commands_full;
    bool stack_overflow;
    bool stack_underflow;
    bool no_context;
}

/*
    sgl_context_desc_t

    Describes the initialization parameters of a rendering context.
    Creating additional contexts is useful if you want to render
    in separate sokol-gfx passes.
*/
struct sgl_context_desc_t {
    i32 max_vertices;
    i32 max_commands;
    sg_pixel_format color_format;
    sg_pixel_format depth_format;
    i32 sample_count;
}

/*
    sgl_allocator_t

    Used in sgl_desc_t to provide custom memory-alloc and -free functions
    to sokol_gl.h. If memory management should be overridden, both the
    alloc and free function must be provided (e.g. it's not valid to
    override one function but not the other).
*/
struct sgl_allocator_t {
    fn(u64, void*): void* alloc_fn;
    fn(void*, void*): void free_fn;
    void* user_data;
}

struct sgl_desc_t {
    i32 max_vertices;
    i32 max_commands;
    i32 context_pool_size;
    i32 pipeline_pool_size;
    sg_pixel_format color_format;
    sg_pixel_format depth_format;
    i32 sample_count;
    sg_face_winding face_winding;
    sgl_allocator_t allocator;
    sgl_logger_t logger;
}

struct _sgl_slot_t {
    u32 id;
    sg_resource_state state;
}

struct _sgl_pool_t {
    i32 size;
    i32 queue_top;
    u32* gen_ctrs;
    i32* free_queue;
}

struct _sgl_pipeline_t {
    _sgl_slot_t slot;
    sg_pipeline[6] pip;
}

struct _sgl_pipeline_pool_t {
    _sgl_pool_t pool;
    _sgl_pipeline_t* pips;
}

struct _sgl_vertex_t {
    f32[3] pos;
    f32[2] uv;
    u32 rgba;
    f32 psize;
}

struct _sgl_matrix_t {
    f32:[4][4] v;
}

struct _sgl_uniform_t {
    _sgl_matrix_t mvp;
    _sgl_matrix_t tm;
}

struct _sgl_draw_args_t {
    sg_pipeline pip;
    sg_view view;
    sg_sampler smp;
    i32 base_vertex;
    i32 num_vertices;
    i32 uniform_index;
}

struct _sgl_viewport_args_t {
    i32 x;
    i32 y;
    i32 w;
    i32 h;
    bool origin_top_left;
}

struct _sgl_scissor_rect_args_t {
    i32 x;
    i32 y;
    i32 w;
    i32 h;
    bool origin_top_left;
}

unsafe_union _sgl_args_t {
    _sgl_draw_args_t draw;
    _sgl_viewport_args_t viewport;
    _sgl_scissor_rect_args_t scissor_rect;
}

struct _sgl_command_t {
    _sgl_command_type_t cmd;
    i32 layer_id;
    _sgl_args_t args;
}

struct _sgl_context_t {
    _sgl_slot_t slot;
    sgl_context_desc_t desc;
    u32 frame_id;
    u32 update_frame_id;
    struct {
        i32 cap;
        i32 next;
        _sgl_vertex_t* ptr;
    } vertices;
    struct {
        i32 cap;
        i32 next;
        _sgl_uniform_t* ptr;
    } uniforms;
    struct {
        i32 cap;
        i32 next;
        _sgl_command_t* ptr;
    } commands;
    i32 base_vertex;
    i32 quad_vtx_count;
    sgl_error_t error;
    bool in_begin;
    i32 layer_id;
    f32 u;
    f32 v;
    u32 rgba;
    f32 point_size;
    _sgl_primitive_type_t cur_prim_type;
    sg_view cur_view;
    sg_sampler cur_smp;
    bool texturing_enabled;
    bool matrix_dirty;
    sg_buffer vbuf;
    sgl_pipeline def_pip;
    sg_bindings bind;
    i32 pip_tos;
    sgl_pipeline[64] pip_stack;
    _sgl_matrix_mode_t cur_matrix_mode;
    i32[3] matrix_tos;
    _sgl_matrix_t:[3][64] matrix_stack;
}

struct _sgl_context_pool_t {
    _sgl_pool_t pool;
    _sgl_context_t* contexts;
}

struct _sgl_t {
    u32 init_cookie;
    sgl_desc_t desc;
    sg_image def_img;
    sg_view def_view;
    sg_sampler def_smp;
    sg_shader shd;
    sgl_context def_ctx_id;
    sgl_context cur_ctx_id;
    _sgl_context_t* cur_ctx;
    _sgl_pipeline_pool_t pip_pool;
    _sgl_context_pool_t context_pool;
}

/*
    sokol_gl.h -- OpenGL 1.x style rendering on top of sokol_gfx.h

    Project URL: https://github.com/floooh/sokol

    Do this:
        #define SOKOL_IMPL or
        #define SOKOL_GL_IMPL
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
    SOKOL_GL_API_DECL   - public function declaration prefix (default: extern)
    SOKOL_API_DECL      - same as SOKOL_GL_API_DECL
    SOKOL_API_IMPL      - public function implementation prefix (default: -)
    SOKOL_UNREACHABLE() - a guard macro for unreachable code (default: assert(false))

    If sokol_gl.h is compiled as a DLL, define the following before
    including the declaration or implementation:

    SOKOL_DLL

    On Windows, SOKOL_DLL will define SOKOL_GL_API_DECL as __declspec(dllexport)
    or __declspec(dllimport) as needed.

    Include the following headers before including sokol_gl.h:

        sokol_gfx.h

    Matrix functions have been taken from MESA and Regal.

    FEATURE OVERVIEW:
    =================
    sokol_gl.h implements a subset of the OpenGLES 1.x feature set useful for
    when you just want to quickly render a bunch of triangles or
    lines without having to mess with buffers and shaders.

    The current feature set is mostly useful for debug visualizations
    and simple UI-style 2D rendering:

    What's implemented:
        - vertex components:
            - position (x, y, z)
            - 2D texture coords (u, v)
            - color (r, g, b, a)
        - primitive types:
            - triangle list and strip
            - line list and strip
            - quad list (TODO: quad strips)
            - point list
        - one texture layer (no multi-texturing)
        - viewport and scissor-rect with selectable origin (top-left or bottom-left)
        - all GL 1.x matrix stack functions, and additionally equivalent
          functions for gluPerspective and gluLookat

    Notable GLES 1.x features that are *NOT* implemented:
        - vertex lighting (this is the most likely GL feature that might be added later)
        - vertex arrays (although providing whole chunks of vertex data at once
          might be a useful feature for a later version)
        - texture coordinate generation
        - line width
        - all pixel store functions
        - no ALPHA_TEST
        - no clear functions (clearing is handled by the sokol-gfx render pass)
        - fog

    Notable differences to GL:
        - No "enum soup" for render states etc, instead there's a
          'pipeline stack', this is similar to GL's matrix stack,
          but for pipeline-state-objects. The pipeline object at
          the top of the pipeline stack defines the active set of render states
        - All angles are in radians, not degrees (note the sgl_rad() and
          sgl_deg() conversion functions)
        - No enable/disable state for scissor test, this is always enabled

    STEP BY STEP:
    =============
    --- To initialize sokol-gl, call:

            sgl_setup(const sgl_desc_t* desc)

        NOTE that sgl_setup() must be called *after* initializing sokol-gfx
        (via sg_setup). This is because sgl_setup() needs to create
        sokol-gfx resource objects.

        If you're intending to render to the default pass, and also don't
        want to tweak memory usage, and don't want any logging output you can
        just keep sgl_desc_t zero-initialized:

            sgl_setup(&(sgl_desc_t*){ 0 });

        In this case, sokol-gl will create internal sg_pipeline objects that
        are compatible with the sokol-app default framebuffer.

        I would recommend to at least install a logging callback so that
        you'll see any warnings and errors. The easiest way is through
        sokol_log.h:

            #include "sokol_log.h"

            sgl_setup(&(sgl_desc_t){
                .logger.func = slog_func.
            });

        If you want to render into a framebuffer with different pixel-format
        and MSAA attributes you need to provide the matching attributes in the
        sgl_setup() call:

            sgl_setup(&(sgl_desc_t*){
                .color_format = SG_PIXELFORMAT_...,
                .depth_format = SG_PIXELFORMAT_...,
                .sample_count = ...,
            });

        To reduce memory usage, or if you need to create more then the default number of
        contexts, pipelines, vertices or draw commands, set the following sgl_desc_t
        members:

            .context_pool_size      (default: 4)
            .pipeline_pool_size     (default: 64)
            .max_vertices       (default: 64k)
            .max_commands       (default: 16k)

        Finally you can change the face winding for front-facing triangles
        and quads:

            .face_winding    - default is SG_FACEWINDING_CCW

        The default winding for front faces is counter-clock-wise. This is
        the same as OpenGL's default, but different from sokol-gfx.

    --- Optionally create additional context objects if you want to render into
        multiple sokol-gfx render passes (or generally if you want to
        use multiple independent sokol-gl "state buckets")

            sgl_context ctx = sgl_make_context(const sgl_context_desc_t* desc)

        For details on rendering with sokol-gl contexts, search below for
        WORKING WITH CONTEXTS.

    --- Optionally create pipeline-state-objects if you need render state
        that differs from sokol-gl's default state:

            sgl_pipeline pip = sgl_make_pipeline(const sg_pipeline_desc* desc)

        ...this creates a pipeline object that's compatible with the currently
        active context, alternatively call:

            sgl_pipeline_pip = sgl_context_make_pipeline(sgl_context ctx, const sg_pipeline_desc* desc)

        ...to create a pipeline object that's compatible with an explicitly
        provided context.

        The similarity with sokol_gfx.h's sg_pipeline type and sg_make_pipeline()
        function is intended. sgl_make_pipeline() also takes a standard
        sokol-gfx sg_pipeline_desc object to describe the render state, but
        without:
            - shader
            - vertex layout
            - color- and depth-pixel-formats
            - primitive type (lines, triangles, ...)
            - MSAA sample count
        Those will be filled in by sgl_make_pipeline(). Note that each
        call to sgl_make_pipeline() needs to create several sokol-gfx
        pipeline objects (one for each primitive type).

        'depth.write_enabled' will be forced to 'false' if the context this
        pipeline object is intended for has its depth pixel format set to
        SG_PIXELFORMAT_NONE (which means the framebuffer this context is used
        with doesn't have a depth-stencil surface).

    --- if you need to destroy sgl_pipeline objects before sgl_shutdown():

            sgl_destroy_pipeline(sgl_pipeline pip)

    --- After sgl_setup() you can call any of the sokol-gl functions anywhere
        in a frame, *except* sgl_draw(). The 'vanilla' functions
        will only change internal sokol-gl state, and not call any sokol-gfx
        functions.

    --- Unlike OpenGL, sokol-gl has a function to reset internal state to
        a known default. This is useful at the start of a sequence of
        rendering operations:

            void sgl_defaults(void)

        This will set the following default state:

            - current texture coordinate to u=0.0f, v=0.0f
            - current color to white (rgba all 1.0f)
            - current point size to 1.0f
            - unbind the current texture and texturing will be disabled
            - *all* matrices will be set to identity (also the projection matrix)
            - the default render state will be set by loading the 'default pipeline'
              into the top of the pipeline stack

        The current matrix- and pipeline-stack-depths will not be changed by
        sgl_defaults().

    --- change the currently active renderstate through the
        pipeline-stack functions, this works similar to the
        traditional GL matrix stack:

            ...load the default pipeline state on the top of the pipeline stack:

                sgl_load_default_pipeline()

            ...load a specific pipeline on the top of the pipeline stack:

                sgl_load_pipeline(sgl_pipeline pip)

            ...push and pop the pipeline stack:
                sgl_push_pipeline()
                sgl_pop_pipeline()

    --- control texturing with:

            sgl_enable_texture()
            sgl_disable_texture()
            sgl_texture(sg_view tex_view, sg_sampler smp)

        NOTE: the tex_view and smp handles can be invalid (SG_INVALID_ID), in this
        case, sokol-gl will fall back to the internal default (white) texture
        and sampler.

    --- set the current viewport and scissor rect with:

            sgl_viewport(int x, int y, int w, int h, bool origin_top_left)
            sgl_scissor_rect(int x, int y, int w, int h, bool origin_top_left)

        ...or call these alternatives which take float arguments (this might allow
        to avoid casting between float and integer in more strongly typed languages
        when floating point pixel coordinates are used):

            sgl_viewportf(float x, float y, float w, float h, bool origin_top_left)
            sgl_scissor_rectf(float x, float y, float w, float h, bool origin_top_left)

        ...these calls add a new command to the internal command queue, so
        that the viewport or scissor rect are set at the right time relative
        to other sokol-gl calls.

    --- adjust the transform matrices, matrix manipulation works just like
        the OpenGL matrix stack:

        ...set the current matrix mode:

            sgl_matrix_mode_modelview()
            sgl_matrix_mode_projection()
            sgl_matrix_mode_texture()

        ...load the identity matrix into the current matrix:

            sgl_load_identity()

        ...translate, rotate and scale the current matrix:

            sgl_translate(float x, float y, float z)
            sgl_rotate(float angle_rad, float x, float y, float z)
            sgl_scale(float x, float y, float z)

        NOTE that all angles in sokol-gl are in radians, not in degree.
        Convert between radians and degree with the helper functions:

            float sgl_rad(float deg)        - degrees to radians
            float sgl_deg(float rad)        - radians to degrees

        ...directly load the current matrix from a float[16] array:

            sgl_load_matrix(const float m[16])
            sgl_load_transpose_matrix(const float m[16])

        ...directly multiply the current matrix from a float[16] array:

            sgl_mult_matrix(const float m[16])
            sgl_mult_transpose_matrix(const float m[16])

        The memory layout of those float[16] arrays is the same as in OpenGL.

        ...more matrix functions:

            sgl_frustum(float left, float right, float bottom, float top, float near, float far)
            sgl_ortho(float left, float right, float bottom, float top, float near, float far)
            sgl_perspective(float fov_y, float aspect, float near, float far)
            sgl_lookat(float eye_x, float eye_y, float eye_z, float center_x, float center_y, float center_z, float up_x, float up_y, float up_z)

        These functions work the same as glFrustum(), glOrtho(), gluPerspective()
        and gluLookAt().

        ...and finally to push / pop the current matrix stack:

            sgl_push_matrix(void)
            sgl_pop_matrix(void)

        Again, these work the same as glPushMatrix() and glPopMatrix().

    --- perform primitive rendering:

        ...set the current texture coordinate and color 'registers' with or
        point size with:

            sgl_t2f(float u, float v)   - set current texture coordinate
            sgl_c*(...)                 - set current color
            sgl_point_size(float size)  - set current point size

        There are several functions for setting the color (as float values,
        unsigned byte values, packed as unsigned 32-bit integer, with
        and without alpha).

        NOTE that these are the only functions that can be called both inside
        sgl_begin_*() / sgl_end() and outside.

        Also NOTE that point size is currently hardwired to 1.0f if the D3D11
        backend is used.

        ...start a primitive vertex sequence with:

            sgl_begin_points()
            sgl_begin_lines()
            sgl_begin_line_strip()
            sgl_begin_triangles()
            sgl_begin_triangle_strip()
            sgl_begin_quads()

        ...after sgl_begin_*() specify vertices:

            sgl_v*(...)
            sgl_v*_t*(...)
            sgl_v*_c*(...)
            sgl_v*_t*_c*(...)

        These functions write a new vertex to sokol-gl's internal vertex buffer,
        optionally with texture-coords and color. If the texture coordinate
        and/or color is missing, it will be taken from the current texture-coord
        and color 'register'.

        ...finally, after specifying vertices, call:

            sgl_end()

        This will record a new draw command in sokol-gl's internal command
        list, or it will extend the previous draw command if no relevant
        state has changed since the last sgl_begin/end pair.

    --- inside a sokol-gfx rendering pass, call the sgl_draw() function
        to render the currently active context:

            sgl_draw()

        ...or alternatively call:

            sgl_context_draw(ctx)

        ...to render an explicitly provided context.

        This will render everything that has been recorded in the context since
        the last call to sgl_draw() through sokol-gfx, and will 'rewind' the internal
        vertex-, uniform- and command-buffers.

    --- each sokol-gl context tracks internal error states which can
        be obtains via:

            sgl_error_t sgl_error()

        ...alternatively with an explicit context argument:

            sgl_error_t sgl_context_error(ctx);

        ...this returns a struct with the following booleans:

            .any                - true if any of the below errors is true
            .vertices_full      - internal vertex buffer is full (checked in sgl_end())
            .uniforms_full      - the internal uniforms buffer is full (checked in sgl_end())
            .commands_full      - the internal command buffer is full (checked in sgl_end())
            .stack_overflow     - matrix- or pipeline-stack overflow
            .stack_underflow    - matrix- or pipeline-stack underflow
            .no_context         - the active context no longer exists

        ...depending on the above error state, sgl_draw() may skip rendering
        completely, or only draw partial geometry

    --- you can get the number of recorded vertices and draw commands in the current
        frame and active sokol-gl context via:

            int sgl_num_vertices()
            int sgl_num_commands()

        ...this allows you to check whether the vertex or command pools are running
        full before the overflow actually happens (in this case you could also
        check the error booleans in the result of sgl_error()).

    RENDER LAYERS
    =============
    Render layers allow to split sokol-gl rendering into separate draw-command
    groups which can then be rendered separately in a sokol-gfx draw pass. This
    allows to mix/interleave sokol-gl rendering with other render operations.

    Layered rendering is controlled through two functions:

        sgl_layer(int layer_id)
        sgl_draw_layer(int layer_id)

    (and the context-variant sgl_draw_layer(): sgl_context_draw_layer()

    The sgl_layer() function sets the 'current layer', any sokol-gl calls
    which internally record draw commands will also store the current layer
    in the draw command, and later in a sokol-gfx render pass, a call
    to sgl_draw_layer() will only render the draw commands that have
    a matching layer.

    The default layer is '0', this is active after sokol-gl setup, and
    is also restored at the start of a new frame (but *not* by calling
    sgl_defaults()).

    NOTE that calling sgl_draw() is equivalent with sgl_draw_layer(0)
    (in general you should either use either use sgl_draw() or
    sgl_draw_layer() in an application, but not both).

    WORKING WITH CONTEXTS:
    ======================
    If you want to render to more than one sokol-gfx render pass you need to
    work with additional sokol-gl context objects (one context object for
    each offscreen rendering pass, in addition to the implicitly created
    'default context'.

    All sokol-gl state is tracked per context, and there is always a "current
    context" (with the notable exception that the currently set context is
    destroyed, more on that later).

    Using multiple contexts can also be useful if you only render in
    a single pass, but want to maintain multiple independent "state buckets".

    To create new context object, call:

        sgl_context ctx = sgl_make_context(&(sgl_context_desc){
            .max_vertices = ...,        // default: 64k
            .max_commands = ...,        // default: 16k
            .color_format = ...,
            .depth_format = ...,
            .sample_count = ...,
        });

    The color_format, depth_format and sample_count items must be compatible
    with the render pass the sgl_draw() or sgL_context_draw() function
    will be called in.

    Creating a context does *not* make the context current. To do this, call:

        sgl_set_context(ctx);

    The currently active context will implicitly be used by most sokol-gl functions
    which don't take an explicit context handle as argument.

    To switch back to the default context, pass the global constant SGL_DEFAULT_CONTEXT:

        sgl_set_context(SGL_DEFAULT_CONTEXT);

    ...or alternatively use the function sgl_default_context() instead of the
    global constant:

        sgl_set_context(sgl_default_context());

    To get the currently active context, call:

        sgl_context cur_ctx = sgl_get_context();

    The following functions exist in two variants, one which use the currently
    active context (set with sgl_set_context()), and another version which
    takes an explicit context handle instead:

        sgl_make_pipeline() vs sgl_context_make_pipeline()
        sgl_error() vs sgl_context_error();
        sgl_draw() vs sgl_context_draw();

    Except for using the currently active context versus a provided context
    handle, the two variants are exactlyidentical, e.g. the following
    code sequences do the same thing:

        sgl_set_context(ctx);
        sgl_pipeline pip = sgl_make_pipeline(...);
        sgl_error_t err = sgl_error();
        sgl_draw();

        vs

        sgl_pipeline pip = sgl_context_make_pipeline(ctx, ...);
        sgl_error_t err = sgl_context_error(ctx);
        sgl_context_draw(ctx);

    Destroying the currently active context is a 'soft error'. All following
    calls which require a currently active context will silently fail,
    and sgl_error() will return SGL_ERROR_NO_CONTEXT.

    UNDER THE HOOD:
    ===============
    sokol_gl.h works by recording vertex data and rendering commands into
    memory buffers, and then drawing the recorded commands via sokol_gfx.h

    The only functions which call into sokol_gfx.h are:
        - sgl_setup()
        - sgl_shutdown()
        - sgl_draw() (and variants)

    sgl_setup() must be called after initializing sokol-gfx.
    sgl_shutdown() must be called before shutting down sokol-gfx.
    sgl_draw() must be called once per frame inside a sokol-gfx render pass.

    All other sokol-gl function can be called anywhere in a frame, since
    they just record data into memory buffers owned by sokol-gl.

    What happens in:

        sgl_setup():
            Unique resources shared by all contexts are created:
                - a shader object (using embedded shader source or byte code)
                - an 8x8 white default texture
            The default context is created, which involves:
                - 3 memory buffers are created, one for vertex data,
                  one for uniform data, and one for commands
                - a dynamic vertex buffer is created
                - the default sgl_pipeline object is created, which involves
                  creating 5 sg_pipeline objects

            One vertex is 24 bytes:
                - float3 position
                - float2 texture coords
                - uint32_t color

            One uniform block is 128 bytes:
                - mat4 model-view-projection matrix
                - mat4 texture matrix

            One draw command is ca. 24 bytes for the actual
            command code plus command arguments.

            Each sgl_end() consumes one command, and one uniform block
            (only when the matrices have changed).
            The required size for one sgl_begin/end pair is (at most):

                (152 + 24 * num_verts) bytes

        sgl_shutdown():
            - all sokol-gfx resources (buffer, shader, default-texture and
              all pipeline objects) are destroyed
            - the 3 memory buffers are freed

        sgl_draw() (and variants)
            - copy all recorded vertex data into the dynamic sokol-gfx buffer
              via a call to sg_update_buffer()
            - for each recorded command:
                - if the layer number stored in the command doesn't match
                  the layer that's to be rendered, skip to the next
                  command
                - if it's a viewport command, call sg_apply_viewport()
                - if it's a scissor-rect command, call sg_apply_scissor_rect()
                - if it's a draw command:
                    - depending on what has changed since the last draw command,
                      call sg_apply_pipeline(), sg_apply_bindings() and
                      sg_apply_uniforms()
                    - finally call sg_draw()

    All other functions only modify the internally tracked state, add
    data to the vertex, uniform and command buffers, or manipulate
    the matrix stack.

    ON DRAW COMMAND MERGING
    =======================
    Not every call to sgl_end() will automatically record a new draw command.
    If possible, the previous draw command will simply be extended,
    resulting in fewer actual draw calls later in sgl_draw().

    A draw command will be merged with the previous command if "no relevant
    state has changed" since the last sgl_end(), meaning:

    - no calls to sgl_viewport() and sgl_scissor_rect()
    - the primitive type hasn't changed
    - the primitive type isn't a 'strip type' (no line or triangle strip)
    - the pipeline state object hasn't changed
    - the current layer hasn't changed
    - none of the matrices has changed
    - none of the texture state has changed

    Merging a draw command simply means that the number of vertices
    to render in the previous draw command will be incremented by the
    number of vertices in the new draw command.

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
            sgl_setup(&(sgl_desc_t){
                // ...
                .allocator = {
                    .alloc_fn = my_alloc,
                    .free_fn = my_free,
                    .user_data = ...;
                }
            });
        ...

    If no overrides are provided, malloc and free will be used.


    ERROR REPORTING AND LOGGING
    ===========================
    To get any logging information at all you need to provide a logging callback in the setup call,
    the easiest way is to use sokol_log.h:

        #include "sokol_log.h"

        sgl_setup(&(sgl_desc_t){
            // ...
            .logger.func = slog_func
        });

    To override logging with your own callback, first write a logging function like this:

        void my_log(const char* tag,                // e.g. 'sgl'
                    uint32_t log_level,             // 0=panic, 1=error, 2=warn, 3=info
                    uint32_t log_item_id,           // SGL_LOGITEM_*
                    const char* message_or_null,    // a message string, may be nullptr in release mode
                    uint32_t line_nr,               // line number in sokol_gl.h
                    const char* filename_or_null,   // source filename, may be nullptr in release mode
                    void* user_data)
        {
            ...
        }

    ...and then setup sokol-gl like this:

        sgl_setup(&(sgl_desc_t){
            .logger = {
                .func = my_log,
                .user_data = my_user_data,
            }
        });

    The provided logging function must be reentrant (e.g. be callable from
    different threads).

    If you don't want to provide your own custom logger it is highly recommended to use
    the standard logger in sokol_log.h instead, otherwise you won't see any warnings or
    errors.


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
/* the default context handle */
sgl_context SGL_DEFAULT_CONTEXT = sgl_context{0x00010001};
// ██ ███    ███ ██████  ██      ███████ ███    ███ ███████ ███    ██ ████████  █████  ████████ ██  ██████  ███    ██
// ██ ████  ████ ██   ██ ██      ██      ████  ████ ██      ████   ██    ██    ██   ██    ██    ██ ██    ██ ████   ██
// ██ ██ ████ ██ ██████  ██      █████   ██ ████ ██ █████   ██ ██  ██    ██    ███████    ██    ██ ██    ██ ██ ██  ██
// ██ ██  ██  ██ ██      ██      ██      ██  ██  ██ ██      ██  ██ ██    ██    ██   ██    ██    ██ ██    ██ ██  ██ ██
// ██ ██      ██ ██      ███████ ███████ ██      ██ ███████ ██   ████    ██    ██   ██    ██    ██  ██████  ██   ████
//
// >>implementation
when !(defined(SOKOL_DEBUG)) {
}
private {
_sgl_t _sgl;
// ██       ██████   ██████   ██████  ██ ███    ██  ██████
// ██      ██    ██ ██       ██       ██ ████   ██ ██
// ██      ██    ██ ██   ███ ██   ███ ██ ██ ██  ██ ██   ███
// ██      ██    ██ ██    ██ ██    ██ ██ ██  ██ ██ ██    ██
// ███████  ██████   ██████   ██████  ██ ██   ████  ██████
//
// >>logging
u8*[7] _sgl_log_messages = {
    "OK: Ok", "MALLOC_FAILED: memory allocation failed",
    "MAKE_PIPELINE_FAILED: sg_make_pipeline() failed",
    "PIPELINE_POOL_EXHAUSTED: pipeline pool exhausted (use sgl_desc_t.pipeline_pool_size to adjust)",
    "ADD_COMMIT_LISTENER_FAILED: sg_add_commit_listener() failed",
    "CONTEXT_POOL_EXHAUSTED: context pool exhausted (use sgl_desc_t.context_pool_size to adjust)",
    "CANNOT_DESTROY_DEFAULT_CONTEXT: cannot destroy default context",
};

void _sgl_log(sgl_log_item_t log_item, u32 log_level, u32 line_nr) {
    if _sgl.desc.logger.func != null {
        u8* filename = __file__;
        u8* message = _sgl_log_messages[log_item];
        _sgl.desc.logger.func("sgl", log_level, cast(u32, log_item), message, line_nr, filename, _sgl.desc.logger.user_data);
    } else {
        if log_level == 0 {
            abort();
        }
    }
}

// ███    ███ ███████ ███    ███  ██████  ██████  ██    ██
// ████  ████ ██      ████  ████ ██    ██ ██   ██  ██  ██
// ██ ████ ██ █████   ██ ████ ██ ██    ██ ██████    ████
// ██  ██  ██ ██      ██  ██  ██ ██    ██ ██   ██    ██
// ██      ██ ███████ ██      ██  ██████  ██   ██    ██
//
// >>memory
void _sgl_clear(void* ptr, u64 size) {
    assert(ptr && size > 0);
    memset(ptr, 0, size);
}

void* _sgl_malloc(u64 size) {
    assert(size > 0);
    void* ptr;
    if _sgl.desc.allocator.alloc_fn != null {
        ptr = _sgl.desc.allocator.alloc_fn(size, _sgl.desc.allocator.user_data);
    } else {
        ptr = alloc(cast(i64, size));
    }
    if null == ptr {
        _sgl_log(SGL_LOGITEM_MALLOC_FAILED, 0, __line__);
    }
    return ptr;
}

void* _sgl_malloc_clear(u64 size) {
    void* ptr = _sgl_malloc(size);
    _sgl_clear(ptr, size);
    return ptr;
}

void _sgl_free(void* ptr) {
    if _sgl.desc.allocator.free_fn != null {
        _sgl.desc.allocator.free_fn(ptr, _sgl.desc.allocator.user_data);
    } else {
        free(ptr);
    }
}

// ██████   ██████   ██████  ██
// ██   ██ ██    ██ ██    ██ ██
// ██████  ██    ██ ██    ██ ██
// ██      ██    ██ ██    ██ ██
// ██       ██████   ██████  ███████
//
// >>pool
void _sgl_init_pool(_sgl_pool_t* pool, i32 num) {
    assert(pool && num >= 1);
    pool.size = num + 1;
    pool.queue_top = 0;
    u64 gen_ctrs_size = cast(u64, sizeof(u32)) * cast(u64, pool.size);
    pool.gen_ctrs = cast(u32*, _sgl_malloc_clear(gen_ctrs_size));
    pool.free_queue = cast(i32*, _sgl_malloc_clear(cast(u64, sizeof(i32)) * cast(u64, num)));
    for i32 i = pool.size - 1; i >= 1; i-- {
        pool.free_queue[pool.queue_top++] = i;
    }
}

void _sgl_discard_pool(_sgl_pool_t* pool) {
    assert(cast(i64, pool));
    assert(cast(i64, pool.free_queue));
    _sgl_free(pool.free_queue);
    pool.free_queue = null;
    assert(cast(i64, pool.gen_ctrs));
    _sgl_free(pool.gen_ctrs);
    pool.gen_ctrs = null;
    pool.size = 0;
    pool.queue_top = 0;
}

i32 _sgl_pool_alloc_index(_sgl_pool_t* pool) {
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

void _sgl_pool_free_index(_sgl_pool_t* pool, i32 slot_index) {
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

/* allocate the slot at slot_index:
    - bump the slot's generation counter
    - create a resource id from the generation counter and slot index
    - set the slot's id to this id
    - set the slot's state to ALLOC
    - return the resource id
*/
u32 _sgl_slot_alloc(_sgl_pool_t* pool, _sgl_slot_t* slot, i32 slot_index) {
    assert(pool && pool.gen_ctrs);
    assert(slot_index > 0 && slot_index < pool.size);
    assert(slot.state == SG_RESOURCESTATE_INITIAL && slot.id == cast(u32, SG_INVALID_ID));
    u32 ctr = ++pool.gen_ctrs[slot_index];
    slot.id = ctr << 16 | cast(u32, slot_index & (1 << 16) - 1);
    slot.state = SG_RESOURCESTATE_ALLOC;
    return slot.id;
}

/* extract slot index from id */
i32 _sgl_slot_index(u32 id) {
    var slot_index = cast(i32, id & cast(u32, (1 << 16) - 1));
    assert(0 != slot_index);
    return slot_index;
}

// ██████  ██ ██████  ███████ ██      ██ ███    ██ ███████ ███████
// ██   ██ ██ ██   ██ ██      ██      ██ ████   ██ ██      ██
// ██████  ██ ██████  █████   ██      ██ ██ ██  ██ █████   ███████
// ██      ██ ██      ██      ██      ██ ██  ██ ██ ██           ██
// ██      ██ ██      ███████ ███████ ██ ██   ████ ███████ ███████
//
// >>pipelines
void _sgl_reset_pipeline(_sgl_pipeline_t* pip) {
    assert(cast(i64, pip));
    _sgl_clear(pip, cast(u64, sizeof(_sgl_pipeline_t)));
}

void _sgl_setup_pipeline_pool(i32 pool_size) {
    assert(pool_size > 0 && pool_size < 1 << 16);
    _sgl_init_pool(&_sgl.pip_pool.pool, pool_size);
    u64 pool_byte_size = cast(u64, sizeof(_sgl_pipeline_t)) * cast(u64, _sgl.pip_pool.pool.size);
    _sgl.pip_pool.pips = cast(_sgl_pipeline_t*, _sgl_malloc_clear(pool_byte_size));
}

void _sgl_discard_pipeline_pool() {
    assert(null != _sgl.pip_pool.pips);
    _sgl_free(_sgl.pip_pool.pips);
    _sgl.pip_pool.pips = null;
    _sgl_discard_pool(&_sgl.pip_pool.pool);
}

/* get pipeline pointer without id-check */
_sgl_pipeline_t* _sgl_pipeline_at(u32 pip_id) {
    assert(cast(u32, SG_INVALID_ID) != pip_id);
    i32 slot_index = _sgl_slot_index(pip_id);
    assert(slot_index > 0 && slot_index < _sgl.pip_pool.pool.size);
    return &_sgl.pip_pool.pips[slot_index];
}

/* get pipeline pointer with id-check, returns 0 if no match */
_sgl_pipeline_t* _sgl_lookup_pipeline(u32 pip_id) {
    if cast(u32, SG_INVALID_ID) != pip_id {
        _sgl_pipeline_t* pip = _sgl_pipeline_at(pip_id);
        if pip.slot.id == pip_id {
            return pip;
        }
    }
    return null;
}

/* make pipeline id from uint32_t id */
sgl_pipeline _sgl_make_pip_id(u32 pip_id) {
    var pip = sgl_pipeline{pip_id};
    return pip;
}

sgl_pipeline _sgl_alloc_pipeline() {
    noinit sgl_pipeline res;
    i32 slot_index = _sgl_pool_alloc_index(&_sgl.pip_pool.pool);
    if 0 != slot_index {
        res = _sgl_make_pip_id(_sgl_slot_alloc(&_sgl.pip_pool.pool, &_sgl.pip_pool.pips[slot_index].slot, slot_index));
    } else {
        res = _sgl_make_pip_id(cast(u32, SG_INVALID_ID));
    }
    return res;
}

void _sgl_init_pipeline(sgl_pipeline pip_id, sg_pipeline_desc* in_desc, sgl_context_desc_t* ctx_desc) {
    assert(pip_id.id != cast(u32, SG_INVALID_ID) && in_desc && ctx_desc);
    sg_pipeline_desc desc = *in_desc;
    desc.layout.buffers[0].stride = cast(i32, sizeof(_sgl_vertex_t));
    {
        sg_vertex_attr_state* pos = &desc.layout.attrs[0];
        pos.offset = cast(i32, cast(u32, &cast(_sgl_vertex_t*, 0).pos));
        pos.format = SG_VERTEXFORMAT_FLOAT3;
    }
    {
        sg_vertex_attr_state* uv = &desc.layout.attrs[1];
        uv.offset = cast(i32, cast(u32, &cast(_sgl_vertex_t*, 0).uv));
        uv.format = SG_VERTEXFORMAT_FLOAT2;
    }
    {
        sg_vertex_attr_state* rgba = &desc.layout.attrs[2];
        rgba.offset = cast(i32, cast(u32, &cast(_sgl_vertex_t*, 0).rgba));
        rgba.format = SG_VERTEXFORMAT_UBYTE4N;
    }
    {
        sg_vertex_attr_state* psize = &desc.layout.attrs[3];
        psize.offset = cast(i32, cast(u32, &cast(_sgl_vertex_t*, 0).psize));
        psize.format = SG_VERTEXFORMAT_FLOAT;
    }
    if in_desc.shader.id == cast(u32, SG_INVALID_ID) {
        desc.shader = _sgl.shd;
    }
    desc.index_type = SG_INDEXTYPE_NONE;
    desc.sample_count = ctx_desc.sample_count;
    if desc.face_winding == _SG_FACEWINDING_DEFAULT {
        desc.face_winding = _sgl.desc.face_winding;
    }
    desc.depth.pixel_format = ctx_desc.depth_format;
    if ctx_desc.depth_format == SG_PIXELFORMAT_NONE {
        desc.depth.write_enabled = false;
    }
    desc.colors[0].pixel_format = ctx_desc.color_format;
    if desc.colors[0].write_mask == _SG_COLORMASK_DEFAULT {
        desc.colors[0].write_mask = SG_COLORMASK_RGB;
    }
    _sgl_pipeline_t* pip = _sgl_lookup_pipeline(pip_id.id);
    assert(pip && pip.slot.state == SG_RESOURCESTATE_ALLOC);
    pip.slot.state = SG_RESOURCESTATE_VALID;
    for i32 i = 0; i < SGL_NUM_PRIMITIVE_TYPES; i++ {
        switch i {
            case SGL_PRIMITIVETYPE_POINTS: {
                desc.primitive_type = SG_PRIMITIVETYPE_POINTS;
            }
            case SGL_PRIMITIVETYPE_LINES: {
                desc.primitive_type = SG_PRIMITIVETYPE_LINES;
            }
            case SGL_PRIMITIVETYPE_LINE_STRIP: {
                desc.primitive_type = SG_PRIMITIVETYPE_LINE_STRIP;
            }
            case SGL_PRIMITIVETYPE_TRIANGLES: {
                desc.primitive_type = SG_PRIMITIVETYPE_TRIANGLES;
            }
            case SGL_PRIMITIVETYPE_TRIANGLE_STRIP, SGL_PRIMITIVETYPE_QUADS: {
                desc.primitive_type = SG_PRIMITIVETYPE_TRIANGLE_STRIP;
            }
        }
        if SGL_PRIMITIVETYPE_QUADS == i {
            pip.pip[i] = pip.pip[SGL_PRIMITIVETYPE_TRIANGLES];
        } else {
            pip.pip[i] = sg_make_pipeline(&desc);
            if pip.pip[i].id == cast(u32, SG_INVALID_ID) {
                _sgl_log(SGL_LOGITEM_MAKE_PIPELINE_FAILED, 1, __line__);
                pip.slot.state = SG_RESOURCESTATE_FAILED;
            }
        }
    }
}

sgl_pipeline _sgl_make_pipeline(sg_pipeline_desc* desc, sgl_context_desc_t* ctx_desc) {
    assert(desc && ctx_desc);
    sgl_pipeline pip_id = _sgl_alloc_pipeline();
    if pip_id.id != cast(u32, SG_INVALID_ID) {
        _sgl_init_pipeline(pip_id, desc, ctx_desc);
    } else {
        _sgl_log(SGL_LOGITEM_PIPELINE_POOL_EXHAUSTED, 1, __line__);
    }
    return pip_id;
}

void _sgl_destroy_pipeline(sgl_pipeline pip_id) {
    _sgl_pipeline_t* pip = _sgl_lookup_pipeline(pip_id.id);
    if pip != null {
        sg_push_debug_group("sokol-gl");
        for i32 i = 0; i < SGL_NUM_PRIMITIVE_TYPES; i++ {
            if i != SGL_PRIMITIVETYPE_QUADS {
                sg_destroy_pipeline(pip.pip[i]);
            }
        }
        sg_pop_debug_group();
        _sgl_reset_pipeline(pip);
        _sgl_pool_free_index(&_sgl.pip_pool.pool, _sgl_slot_index(pip_id.id));
    }
}

sg_pipeline _sgl_get_pipeline(sgl_pipeline pip_id, _sgl_primitive_type_t prim_type) {
    _sgl_pipeline_t* pip = _sgl_lookup_pipeline(pip_id.id);
    if pip != null {
        return pip.pip[prim_type];
    } else {
        var dummy_id = sg_pipeline{SG_INVALID_ID};
        return dummy_id;
    }
}

//  ██████  ██████  ███    ██ ████████ ███████ ██   ██ ████████ ███████
// ██      ██    ██ ████   ██    ██    ██       ██ ██     ██    ██
// ██      ██    ██ ██ ██  ██    ██    █████     ███      ██    ███████
// ██      ██    ██ ██  ██ ██    ██    ██       ██ ██     ██         ██
//  ██████  ██████  ██   ████    ██    ███████ ██   ██    ██    ███████
//
// >>contexts
void _sgl_reset_context(_sgl_context_t* ctx) {
    assert(cast(i64, ctx));
    assert(null == ctx.vertices.ptr);
    assert(null == ctx.uniforms.ptr);
    assert(null == ctx.commands.ptr);
    _sgl_clear(ctx, cast(u64, sizeof(_sgl_context_t)));
}

void _sgl_setup_context_pool(i32 pool_size) {
    assert(pool_size > 0 && pool_size < 1 << 16);
    _sgl_init_pool(&_sgl.context_pool.pool, pool_size);
    u64 pool_byte_size = cast(u64, sizeof(_sgl_context_t)) * cast(u64, _sgl.context_pool.pool.size);
    _sgl.context_pool.contexts = cast(_sgl_context_t*, _sgl_malloc_clear(pool_byte_size));
}

void _sgl_discard_context_pool() {
    assert(null != _sgl.context_pool.contexts);
    _sgl_free(_sgl.context_pool.contexts);
    _sgl.context_pool.contexts = null;
    _sgl_discard_pool(&_sgl.context_pool.pool);
}

// get context pointer without id-check
_sgl_context_t* _sgl_context_at(u32 ctx_id) {
    assert(cast(u32, SG_INVALID_ID) != ctx_id);
    i32 slot_index = _sgl_slot_index(ctx_id);
    assert(slot_index > 0 && slot_index < _sgl.context_pool.pool.size);
    return &_sgl.context_pool.contexts[slot_index];
}

// get context pointer with id-check, returns 0 if no match
_sgl_context_t* _sgl_lookup_context(u32 ctx_id) {
    if cast(u32, SG_INVALID_ID) != ctx_id {
        _sgl_context_t* ctx = _sgl_context_at(ctx_id);
        if ctx.slot.id == ctx_id {
            return ctx;
        }
    }
    return null;
}

// make context id from uint32_t id
sgl_context _sgl_make_ctx_id(u32 ctx_id) {
    var ctx = sgl_context{ctx_id};
    return ctx;
}

sgl_context _sgl_alloc_context() {
    noinit sgl_context res;
    i32 slot_index = _sgl_pool_alloc_index(&_sgl.context_pool.pool);
    if 0 != slot_index {
        res = _sgl_make_ctx_id(_sgl_slot_alloc(&_sgl.context_pool.pool, &_sgl.context_pool.contexts[slot_index].slot, slot_index));
    } else {
        res = _sgl_make_ctx_id(cast(u32, SG_INVALID_ID));
    }
    return res;
}

// return sgl_context_desc_t with patched defaults
sgl_context_desc_t _sgl_context_desc_defaults(sgl_context_desc_t* desc) {
    sgl_context_desc_t res = *desc;
    res.max_vertices = desc.max_vertices == 0 ? 1 << 16 : desc.max_vertices;
    res.max_commands = desc.max_commands == 0 ? 1 << 14 : desc.max_commands;
    return res;
}
}

private {
void _sgl_init_context(sgl_context ctx_id, sgl_context_desc_t* in_desc) {
    assert(ctx_id.id != cast(u32, SG_INVALID_ID) && in_desc);
    _sgl_context_t* ctx = _sgl_lookup_context(ctx_id.id);
    assert(cast(i64, ctx));
    ctx.desc = _sgl_context_desc_defaults(in_desc);
    ctx.frame_id = 1;
    ctx.cur_view = _sgl.def_view;
    ctx.cur_smp = _sgl.def_smp;
    ctx.vertices.cap = ctx.desc.max_vertices;
    ctx.uniforms.cap = ctx.desc.max_commands;
    ctx.commands.cap = ctx.uniforms.cap;
    ctx.vertices.ptr = cast(_sgl_vertex_t*, _sgl_malloc(cast(u64, ctx.vertices.cap) * cast(u64, sizeof(_sgl_vertex_t))));
    ctx.uniforms.ptr = cast(_sgl_uniform_t*, _sgl_malloc(cast(u64, ctx.uniforms.cap) * cast(u64, sizeof(_sgl_uniform_t))));
    ctx.commands.ptr = cast(_sgl_command_t*, _sgl_malloc(cast(u64, ctx.commands.cap) * cast(u64, sizeof(_sgl_command_t))));
    sg_push_debug_group("sokol-gl");
    noinit sg_buffer_desc vbuf_desc;
    _sgl_clear(&vbuf_desc, cast(u64, sizeof(vbuf_desc)));
    vbuf_desc.size = cast(u64, ctx.vertices.cap) * cast(u64, sizeof(_sgl_vertex_t));
    vbuf_desc.usage.vertex_buffer = true;
    vbuf_desc.usage.stream_update = true;
    vbuf_desc.label = "sgl-vertex-buffer";
    ctx.vbuf = sg_make_buffer(&vbuf_desc);
    assert(cast(u32, SG_INVALID_ID) != ctx.vbuf.id);
    ctx.bind.vertex_buffers[0] = ctx.vbuf;
    noinit sg_pipeline_desc def_pip_desc;
    _sgl_clear(&def_pip_desc, cast(u64, sizeof(def_pip_desc)));
    def_pip_desc.depth.write_enabled = true;
    ctx.def_pip = _sgl_make_pipeline(&def_pip_desc, &ctx.desc);
    if sg_add_commit_listener(_sgl_make_commit_listener(ctx)) == 0 {
        _sgl_log(SGL_LOGITEM_ADD_COMMIT_LISTENER_FAILED, 1, __line__);
    }
    sg_pop_debug_group();
    ctx.rgba = 0xFFFFFFFF;
    ctx.point_size = 1.0f;
    for i32 i = 0; i < SGL_NUM_MATRIXMODES; i++ {
        _sgl_identity(&ctx.matrix_stack[i][0]);
    }
    ctx.pip_stack[0] = ctx.def_pip;
    ctx.matrix_dirty = true;
}

sgl_context _sgl_make_context(sgl_context_desc_t* desc) {
    assert(cast(i64, desc));
    sgl_context ctx_id = _sgl_alloc_context();
    if ctx_id.id != cast(u32, SG_INVALID_ID) {
        _sgl_init_context(ctx_id, desc);
    } else {
        _sgl_log(SGL_LOGITEM_CONTEXT_POOL_EXHAUSTED, 1, __line__);
    }
    return ctx_id;
}

void _sgl_destroy_context(sgl_context ctx_id) {
    _sgl_context_t* ctx = _sgl_lookup_context(ctx_id.id);
    if ctx != null {
        assert(cast(i64, ctx.vertices.ptr));
        assert(cast(i64, ctx.uniforms.ptr));
        assert(cast(i64, ctx.commands.ptr));
        _sgl_free(ctx.vertices.ptr);
        _sgl_free(ctx.uniforms.ptr);
        _sgl_free(ctx.commands.ptr);
        ctx.vertices.ptr = null;
        ctx.uniforms.ptr = null;
        ctx.commands.ptr = null;
        sg_push_debug_group("sokol-gl");
        sg_destroy_buffer(ctx.vbuf);
        _sgl_destroy_pipeline(ctx.def_pip);
        sg_remove_commit_listener(_sgl_make_commit_listener(ctx));
        sg_pop_debug_group();
        _sgl_reset_context(ctx);
        _sgl_pool_free_index(&_sgl.context_pool.pool, _sgl_slot_index(ctx_id.id));
    }
}

// ███    ███ ██ ███████  ██████
// ████  ████ ██ ██      ██
// ██ ████ ██ ██ ███████ ██
// ██  ██  ██ ██      ██ ██
// ██      ██ ██ ███████  ██████
//
// >>misc
sgl_error_t _sgl_error_defaults() {
    noinit sgl_error_t defaults;
    _sgl_clear(&defaults, cast(u64, sizeof(defaults)));
    return defaults;
}

i32 _sgl_num_vertices(_sgl_context_t* ctx) {
    return ctx.vertices.next;
}

i32 _sgl_num_commands(_sgl_context_t* ctx) {
    return ctx.commands.next;
}

void _sgl_begin(_sgl_context_t* ctx, _sgl_primitive_type_t mode) {
    ctx.in_begin = true;
    ctx.base_vertex = ctx.vertices.next;
    ctx.quad_vtx_count = 0;
    ctx.cur_prim_type = mode;
}

void _sgl_rewind(_sgl_context_t* ctx) {
    ctx.frame_id++;
    ctx.vertices.next = 0;
    ctx.uniforms.next = 0;
    ctx.commands.next = 0;
    ctx.base_vertex = 0;
    ctx.error = _sgl_error_defaults();
    ctx.layer_id = 0;
    ctx.matrix_dirty = true;
}

// called from inside sokol-gfx sg_commit()
void _sgl_commit_listener(void* userdata) {
    _sgl_context_t* ctx = _sgl_lookup_context(cast(u32, cast(u64, userdata)));
    if ctx != null {
        _sgl_rewind(ctx);
    }
}

sg_commit_listener _sgl_make_commit_listener(_sgl_context_t* ctx) {
    var listener = sg_commit_listener{_sgl_commit_listener, cast(void*, cast(u64, ctx.slot.id))};
    return listener;
}

_sgl_vertex_t* _sgl_next_vertex(_sgl_context_t* ctx) {
    if ctx.vertices.next < ctx.vertices.cap {
        return &ctx.vertices.ptr[ctx.vertices.next++];
    } else {
        ctx.error.vertices_full = true;
        ctx.error.any = true;
        return null;
    }
}

_sgl_uniform_t* _sgl_next_uniform(_sgl_context_t* ctx) {
    if ctx.uniforms.next < ctx.uniforms.cap {
        return &ctx.uniforms.ptr[ctx.uniforms.next++];
    } else {
        ctx.error.uniforms_full = true;
        ctx.error.any = true;
        return null;
    }
}

_sgl_command_t* _sgl_cur_command(_sgl_context_t* ctx) {
    if ctx.commands.next > 0 {
        return &ctx.commands.ptr[ctx.commands.next - 1];
    } else {
        return null;
    }
}

_sgl_command_t* _sgl_next_command(_sgl_context_t* ctx) {
    if ctx.commands.next < ctx.commands.cap {
        return &ctx.commands.ptr[ctx.commands.next++];
    } else {
        ctx.error.commands_full = true;
        ctx.error.any = true;
        return null;
    }
}

u32 _sgl_pack_rgbab(u8 r, u8 g, u8 b, u8 a) {
    return cast(u32, a) << 24 | cast(u32, b) << 16 | cast(u32, g) << 8 | r;
}

f32 _sgl_clamp(f32 v, f32 lo, f32 hi) {
    if v < lo {
        return lo;
    } else if v > hi {
        return hi;
    } else {
        return v;
    }
}

u32 _sgl_pack_rgbaf(f32 r, f32 g, f32 b, f32 a) {
    var r_u8 = cast(u8, _sgl_clamp(r, 0.0f, 1.0f) * 255.0f);
    var g_u8 = cast(u8, _sgl_clamp(g, 0.0f, 1.0f) * 255.0f);
    var b_u8 = cast(u8, _sgl_clamp(b, 0.0f, 1.0f) * 255.0f);
    var a_u8 = cast(u8, _sgl_clamp(a, 0.0f, 1.0f) * 255.0f);
    return _sgl_pack_rgbab(r_u8, g_u8, b_u8, a_u8);
}

void _sgl_vtx(_sgl_context_t* ctx, f32 x, f32 y, f32 z, f32 u, f32 v, u32 rgba) {
    assert(cast(i64, ctx.in_begin));
    _sgl_vertex_t* vtx;
    if ctx.cur_prim_type == SGL_PRIMITIVETYPE_QUADS && (ctx.quad_vtx_count & 3) == 3 {
        vtx = _sgl_next_vertex(ctx);
        if vtx != null {
            *vtx = *(vtx - 3);
        }
        vtx = _sgl_next_vertex(ctx);
        if vtx != null {
            *vtx = *(vtx - 2);
        }
    }
    vtx = _sgl_next_vertex(ctx);
    if vtx != null {
        vtx.pos[0] = x;
        vtx.pos[1] = y;
        vtx.pos[2] = z;
        vtx.uv[0] = u;
        vtx.uv[1] = v;
        vtx.rgba = rgba;
        vtx.psize = ctx.point_size;
    }
    ctx.quad_vtx_count++;
}

void _sgl_identity(_sgl_matrix_t* m) {
    for i32 c = 0; c < 4; c++ {
        for i32 r = 0; r < 4; r++ {
            m.v[c][r] = r == c ? 1.0f : 0.0f;
        }
    }
}

void _sgl_transpose(_sgl_matrix_t* dst, _sgl_matrix_t* m) {
    assert(dst != m);
    for i32 c = 0; c < 4; c++ {
        for i32 r = 0; r < 4; r++ {
            dst.v[r][c] = m.v[c][r];
        }
    }
}

/* _sgl_rotate, _sgl_frustum, _sgl_ortho from MESA m_matric.c */
void _sgl_matmul4(_sgl_matrix_t* p, _sgl_matrix_t* a, _sgl_matrix_t* b) {
    for i32 r = 0; r < 4; r++ {
        f32 ai0 = a.v[0][r];
        f32 ai1 = a.v[1][r];
        f32 ai2 = a.v[2][r];
        f32 ai3 = a.v[3][r];
        p.v[0][r] = ai0 * b.v[0][0] + ai1 * b.v[0][1] + ai2 * b.v[0][2] + ai3 * b.v[0][3];
        p.v[1][r] = ai0 * b.v[1][0] + ai1 * b.v[1][1] + ai2 * b.v[1][2] + ai3 * b.v[1][3];
        p.v[2][r] = ai0 * b.v[2][0] + ai1 * b.v[2][1] + ai2 * b.v[2][2] + ai3 * b.v[2][3];
        p.v[3][r] = ai0 * b.v[3][0] + ai1 * b.v[3][1] + ai2 * b.v[3][2] + ai3 * b.v[3][3];
    }
}

void _sgl_mul(_sgl_matrix_t* dst, _sgl_matrix_t* m) {
    _sgl_matmul4(dst, dst, m);
}

void _sgl_rotate(_sgl_matrix_t* dst, f32 a, f32 x, f32 y, f32 z) {
    f32 s = sin(a);
    f32 c = cos(a);
    f32 mag = sqrt(x * x + y * y + z * z);
    if mag < 0.0001f {
        return;
    }
    x /= mag;
    y /= mag;
    z /= mag;
    f32 xx = x * x;
    f32 yy = y * y;
    f32 zz = z * z;
    f32 xy = x * y;
    f32 yz = y * z;
    f32 zx = z * x;
    f32 xs = x * s;
    f32 ys = y * s;
    f32 zs = z * s;
    f32 one_c = 1.0f - c;
    noinit _sgl_matrix_t m;
    m.v[0][0] = one_c * xx + c;
    m.v[1][0] = one_c * xy - zs;
    m.v[2][0] = one_c * zx + ys;
    m.v[3][0] = 0.0f;
    m.v[0][1] = one_c * xy + zs;
    m.v[1][1] = one_c * yy + c;
    m.v[2][1] = one_c * yz - xs;
    m.v[3][1] = 0.0f;
    m.v[0][2] = one_c * zx - ys;
    m.v[1][2] = one_c * yz + xs;
    m.v[2][2] = one_c * zz + c;
    m.v[3][2] = 0.0f;
    m.v[0][3] = 0.0f;
    m.v[1][3] = 0.0f;
    m.v[2][3] = 0.0f;
    m.v[3][3] = 1.0f;
    _sgl_mul(dst, &m);
}

void _sgl_scale(_sgl_matrix_t* dst, f32 x, f32 y, f32 z) {
    for i32 r = 0; r < 4; r++ {
        dst.v[0][r] *= x;
        dst.v[1][r] *= y;
        dst.v[2][r] *= z;
    }
}

void _sgl_translate(_sgl_matrix_t* dst, f32 x, f32 y, f32 z) {
    for i32 r = 0; r < 4; r++ {
        dst.v[3][r] = dst.v[0][r] * x + dst.v[1][r] * y + dst.v[2][r] * z + dst.v[3][r];
    }
}

void _sgl_frustum(_sgl_matrix_t* dst, f32 left, f32 right, f32 bottom, f32 top, f32 znear, f32 zfar) {
    f32 x = 2.0f * znear / (right - left);
    f32 y = 2.0f * znear / (top - bottom);
    f32 a = (right + left) / (right - left);
    f32 b = (top + bottom) / (top - bottom);
    f32 c = -(zfar + znear) / (zfar - znear);
    f32 d = -(2.0f * zfar * znear) / (zfar - znear);
    noinit _sgl_matrix_t m;
    m.v[0][0] = x;
    m.v[0][1] = 0.0f;
    m.v[0][2] = 0.0f;
    m.v[0][3] = 0.0f;
    m.v[1][0] = 0.0f;
    m.v[1][1] = y;
    m.v[1][2] = 0.0f;
    m.v[1][3] = 0.0f;
    m.v[2][0] = a;
    m.v[2][1] = b;
    m.v[2][2] = c;
    m.v[2][3] = -1.0f;
    m.v[3][0] = 0.0f;
    m.v[3][1] = 0.0f;
    m.v[3][2] = d;
    m.v[3][3] = 0.0f;
    _sgl_mul(dst, &m);
}

void _sgl_ortho(_sgl_matrix_t* dst, f32 left, f32 right, f32 bottom, f32 top, f32 znear, f32 zfar) {
    noinit _sgl_matrix_t m;
    m.v[0][0] = 2.0f / (right - left);
    m.v[1][0] = 0.0f;
    m.v[2][0] = 0.0f;
    m.v[3][0] = -(right + left) / (right - left);
    m.v[0][1] = 0.0f;
    m.v[1][1] = 2.0f / (top - bottom);
    m.v[2][1] = 0.0f;
    m.v[3][1] = -(top + bottom) / (top - bottom);
    m.v[0][2] = 0.0f;
    m.v[1][2] = 0.0f;
    m.v[2][2] = -2.0f / (zfar - znear);
    m.v[3][2] = -(zfar + znear) / (zfar - znear);
    m.v[0][3] = 0.0f;
    m.v[1][3] = 0.0f;
    m.v[2][3] = 0.0f;
    m.v[3][3] = 1.0f;
    _sgl_mul(dst, &m);
}

/* _sgl_perspective, _sgl_lookat from Regal project.c */
void _sgl_perspective(_sgl_matrix_t* dst, f32 fovy, f32 aspect, f32 znear, f32 zfar) {
    f32 sine = sin(fovy / 2.0f);
    f32 delta_z = zfar - znear;
    if delta_z == 0.0f || sine == 0.0f || aspect == 0.0f {
        return;
    }
    f32 cotan = cos(fovy / 2.0f) / sine;
    noinit _sgl_matrix_t m;
    _sgl_identity(&m);
    m.v[0][0] = cotan / aspect;
    m.v[1][1] = cotan;
    m.v[2][2] = -(zfar + znear) / delta_z;
    m.v[2][3] = -1.0f;
    m.v[3][2] = -2.0f * znear * zfar / delta_z;
    m.v[3][3] = 0.0f;
    _sgl_mul(dst, &m);
}

void _sgl_normalize(f32* v) {
    f32 r = sqrt(v[0] * v[0] + v[1] * v[1] + v[2] * v[2]);
    if r == 0.0f {
        return;
    }
    v[0] /= r;
    v[1] /= r;
    v[2] /= r;
}

void _sgl_cross(f32* v1, f32* v2, f32* res) {
    res[0] = v1[1] * v2[2] - v1[2] * v2[1];
    res[1] = v1[2] * v2[0] - v1[0] * v2[2];
    res[2] = v1[0] * v2[1] - v1[1] * v2[0];
}

void _sgl_lookat(_sgl_matrix_t* dst, f32 eye_x, f32 eye_y, f32 eye_z, f32 center_x, f32 center_y, f32 center_z, f32 up_x, f32 up_y, f32 up_z) {
    noinit f32[3] fwd;
    noinit f32[3] side;
    noinit f32[3] up;
    fwd[0] = center_x - eye_x;
    fwd[1] = center_y - eye_y;
    fwd[2] = center_z - eye_z;
    up[0] = up_x;
    up[1] = up_y;
    up[2] = up_z;
    _sgl_normalize(fwd);
    _sgl_cross(fwd, up, side);
    _sgl_normalize(side);
    _sgl_cross(side, fwd, up);
    noinit _sgl_matrix_t m;
    _sgl_identity(&m);
    m.v[0][0] = side[0];
    m.v[1][0] = side[1];
    m.v[2][0] = side[2];
    m.v[0][1] = up[0];
    m.v[1][1] = up[1];
    m.v[2][1] = up[2];
    m.v[0][2] = -fwd[0];
    m.v[1][2] = -fwd[1];
    m.v[2][2] = -fwd[2];
    _sgl_mul(dst, &m);
    _sgl_translate(dst, -eye_x, -eye_y, -eye_z);
}

/* current top-of-stack projection matrix */
_sgl_matrix_t* _sgl_matrix_projection(_sgl_context_t* ctx) {
    return &ctx.matrix_stack[SGL_MATRIXMODE_PROJECTION][ctx.matrix_tos[SGL_MATRIXMODE_PROJECTION]];
}

/* get top-of-stack modelview matrix */
_sgl_matrix_t* _sgl_matrix_modelview(_sgl_context_t* ctx) {
    return &ctx.matrix_stack[SGL_MATRIXMODE_MODELVIEW][ctx.matrix_tos[SGL_MATRIXMODE_MODELVIEW]];
}

/* get top-of-stack texture matrix */
_sgl_matrix_t* _sgl_matrix_texture(_sgl_context_t* ctx) {
    return &ctx.matrix_stack[SGL_MATRIXMODE_TEXTURE][ctx.matrix_tos[SGL_MATRIXMODE_TEXTURE]];
}

/* get pointer to current top-of-stack of current matrix mode */
_sgl_matrix_t* _sgl_matrix(_sgl_context_t* ctx) {
    return &ctx.matrix_stack[ctx.cur_matrix_mode][ctx.matrix_tos[ctx.cur_matrix_mode]];
}

sgl_desc_t _sgl_desc_defaults(sgl_desc_t* desc) {
    assert(desc.allocator.alloc_fn && desc.allocator.free_fn || !desc.allocator.alloc_fn && !desc.allocator.free_fn);
    sgl_desc_t res = *desc;
    res.max_vertices = desc.max_vertices == 0 ? 1 << 16 : desc.max_vertices;
    res.max_commands = desc.max_commands == 0 ? 1 << 14 : desc.max_commands;
    res.context_pool_size = desc.context_pool_size == 0 ? 4 : desc.context_pool_size;
    res.pipeline_pool_size = desc.pipeline_pool_size == 0 ? 64 : desc.pipeline_pool_size;
    res.face_winding = desc.face_winding == 0 ? SG_FACEWINDING_CCW : desc.face_winding;
    return res;
}

// create resources which are shared between all contexts
void _sgl_setup_common() {
    sg_push_debug_group("sokol-gl");
    noinit u32[64] pixels;
    for i32 i = 0; i < 64; i++ {
        pixels[i] = 0xFFFFFFFF;
    }
    noinit sg_image_desc img_desc;
    _sgl_clear(&img_desc, cast(u64, sizeof(img_desc)));
    img_desc.type = SG_IMAGETYPE_2D;
    img_desc.width = 8;
    img_desc.height = 8;
    img_desc.num_mipmaps = 1;
    img_desc.pixel_format = SG_PIXELFORMAT_RGBA8;
    img_desc.data.mip_levels[0] = sg_range{&pixels, sizeof(pixels)};
    img_desc.label = "sgl-default-texture";
    _sgl.def_img = sg_make_image(&img_desc);
    assert(cast(u32, SG_INVALID_ID) != _sgl.def_img.id);
    noinit sg_view_desc view_desc;
    _sgl_clear(&view_desc, cast(u64, sizeof(view_desc)));
    view_desc.texture.image = _sgl.def_img;
    view_desc.label = "sgl-default-texture-view";
    _sgl.def_view = sg_make_view(&view_desc);
    assert(cast(u32, SG_INVALID_ID) != _sgl.def_view.id);
    noinit sg_sampler_desc smp_desc;
    _sgl_clear(&smp_desc, cast(u64, sizeof(smp_desc)));
    smp_desc.min_filter = SG_FILTER_NEAREST;
    smp_desc.mag_filter = SG_FILTER_NEAREST;
    smp_desc.label = "sgl-default-sampler";
    _sgl.def_smp = sg_make_sampler(&smp_desc);
    assert(cast(u32, SG_INVALID_ID) != _sgl.def_smp.id);
    _sgl.shd = _sgl_minc_shader();
    assert(cast(u32, SG_INVALID_ID) != _sgl.shd.id);
    sg_pop_debug_group();
}

// discard resources which are shared between all contexts
void _sgl_discard_common() {
    sg_push_debug_group("sokol-gl");
    sg_destroy_view(_sgl.def_view);
    sg_destroy_image(_sgl.def_img);
    sg_destroy_sampler(_sgl.def_smp);
    sg_destroy_shader(_sgl.shd);
    sg_pop_debug_group();
}

bool _sgl_is_default_context(sgl_context ctx_id) {
    return ctx_id.id == SGL_DEFAULT_CONTEXT.id;
}

void _sgl_draw(_sgl_context_t* ctx, i32 layer_id) {
    assert(cast(i64, ctx));
    if ctx.vertices.next > 0 && ctx.commands.next > 0 {
        sg_push_debug_group("sokol-gl");
        var cur_pip_id = cast(u32, SG_INVALID_ID);
        var cur_tex_id = cast(u32, SG_INVALID_ID);
        var cur_smp_id = cast(u32, SG_INVALID_ID);
        i32 cur_uniform_index = -1;
        if ctx.update_frame_id != ctx.frame_id {
            ctx.update_frame_id = ctx.frame_id;
            var range = sg_range{
                ctx.vertices.ptr, cast(u64, ctx.vertices.next) * cast(u64, sizeof(_sgl_vertex_t)),
            };
            sg_update_buffer(ctx.vbuf, &range);
        }
        for i32 i = 0; i < ctx.commands.next; i++ {
            _sgl_command_t* cmd = &ctx.commands.ptr[i];
            if cmd.layer_id != layer_id {
                continue;
            }
            switch cmd.cmd {
                case SGL_COMMAND_VIEWPORT: {
                    {
                        _sgl_viewport_args_t* args = &cmd.args.viewport;
                        sg_apply_viewport(args.x, args.y, args.w, args.h, args.origin_top_left);
                    }
                }
                case SGL_COMMAND_SCISSOR_RECT: {
                    {
                        _sgl_scissor_rect_args_t* args = &cmd.args.scissor_rect;
                        sg_apply_scissor_rect(args.x, args.y, args.w, args.h, args.origin_top_left);
                    }
                }
                case SGL_COMMAND_DRAW: {
                    {
                        _sgl_draw_args_t* args = &cmd.args.draw;
                        if args.pip.id != cur_pip_id {
                            sg_apply_pipeline(args.pip);
                            cur_pip_id = args.pip.id;
                            cur_tex_id = cast(u32, SG_INVALID_ID);
                            cur_smp_id = cast(u32, SG_INVALID_ID);
                            cur_uniform_index = -1;
                        }
                        if cur_tex_id != args.view.id || cur_smp_id != args.smp.id {
                            ctx.bind.views[0] = args.view;
                            ctx.bind.samplers[0] = args.smp;
                            sg_apply_bindings(&ctx.bind);
                            cur_tex_id = args.view.id;
                            cur_smp_id = args.smp.id;
                        }
                        if cur_uniform_index != args.uniform_index {
                            var ub_range = sg_range{
                                &ctx.uniforms.ptr[args.uniform_index], sizeof(_sgl_uniform_t),
                            };
                            sg_apply_uniforms(0, &ub_range);
                            cur_uniform_index = args.uniform_index;
                        }
                        if args.num_vertices > 0 {
                            sg_draw(args.base_vertex, args.num_vertices, 1);
                        }
                    }
                }
            }
        }
        sg_pop_debug_group();
    }
}

sgl_context_desc_t _sgl_as_context_desc(sgl_desc_t* desc) {
    noinit sgl_context_desc_t ctx_desc;
    _sgl_clear(&ctx_desc, cast(u64, sizeof(ctx_desc)));
    ctx_desc.max_vertices = desc.max_vertices;
    ctx_desc.max_commands = desc.max_commands;
    ctx_desc.color_format = desc.color_format;
    ctx_desc.depth_format = desc.depth_format;
    ctx_desc.sample_count = desc.sample_count;
    return ctx_desc;
}
}

// ██████  ██    ██ ██████  ██      ██  ██████
// ██   ██ ██    ██ ██   ██ ██      ██ ██
// ██████  ██    ██ ██████  ██      ██ ██
// ██      ██    ██ ██   ██ ██      ██ ██
// ██       ██████  ██████  ███████ ██  ██████
//
// >>public
void sgl_setup(sgl_desc_t* desc) {
    assert(cast(i64, desc));
    _sgl_clear(&_sgl, cast(u64, sizeof(_sgl)));
    _sgl.init_cookie = 0xABCDABCD;
    _sgl.desc = _sgl_desc_defaults(desc);
    _sgl_setup_pipeline_pool(_sgl.desc.pipeline_pool_size);
    _sgl_setup_context_pool(_sgl.desc.context_pool_size);
    _sgl_setup_common();
    sgl_context_desc_t ctx_desc = _sgl_as_context_desc(&_sgl.desc);
    _sgl.def_ctx_id = sgl_make_context(&ctx_desc);
    assert(SGL_DEFAULT_CONTEXT.id == _sgl.def_ctx_id.id);
    sgl_set_context(_sgl.def_ctx_id);
}

void sgl_shutdown() {
    assert(0xABCDABCD == _sgl.init_cookie);
    for i32 i = 0; i < _sgl.context_pool.pool.size; i++ {
        _sgl_context_t* ctx = &_sgl.context_pool.contexts[i];
        _sgl_destroy_context(_sgl_make_ctx_id(ctx.slot.id));
    }
    for i32 i = 0; i < _sgl.pip_pool.pool.size; i++ {
        _sgl_pipeline_t* pip = &_sgl.pip_pool.pips[i];
        _sgl_destroy_pipeline(_sgl_make_pip_id(pip.slot.id));
    }
    _sgl_discard_context_pool();
    _sgl_discard_pipeline_pool();
    _sgl_discard_common();
    _sgl.init_cookie = 0;
}

sgl_error_t sgl_error() {
    _sgl_context_t* ctx = _sgl.cur_ctx;
    if ctx != null {
        return ctx.error;
    } else {
        sgl_error_t err = _sgl_error_defaults();
        err.no_context = true;
        err.any = true;
        return err;
    }
}

sgl_error_t sgl_context_error(sgl_context ctx_id) {
    _sgl_context_t* ctx = _sgl_lookup_context(ctx_id.id);
    if ctx != null {
        return ctx.error;
    } else {
        sgl_error_t err = _sgl_error_defaults();
        err.no_context = true;
        err.any = true;
        return err;
    }
}

f32 sgl_rad(f32 deg) {
    return deg * cast(f32, 3.141592653589793) / 180.0f;
}

f32 sgl_deg(f32 rad) {
    return rad * 180.0f / cast(f32, 3.141592653589793);
}

sgl_context sgl_make_context(sgl_context_desc_t* desc) {
    assert(0xABCDABCD == _sgl.init_cookie);
    return _sgl_make_context(desc);
}

void sgl_destroy_context(sgl_context ctx_id) {
    assert(0xABCDABCD == _sgl.init_cookie);
    if _sgl_is_default_context(ctx_id) != 0 {
        _sgl_log(SGL_LOGITEM_CANNOT_DESTROY_DEFAULT_CONTEXT, 2, __line__);
        return;
    }
    _sgl_destroy_context(ctx_id);
    _sgl.cur_ctx = _sgl_lookup_context(_sgl.cur_ctx_id.id);
}

void sgl_set_context(sgl_context ctx_id) {
    assert(0xABCDABCD == _sgl.init_cookie);
    if _sgl_is_default_context(ctx_id) != 0 {
        _sgl.cur_ctx_id = _sgl.def_ctx_id;
    } else {
        _sgl.cur_ctx_id = ctx_id;
    }
    _sgl.cur_ctx = _sgl_lookup_context(_sgl.cur_ctx_id.id);
}

sgl_context sgl_get_context() {
    assert(0xABCDABCD == _sgl.init_cookie);
    return _sgl.cur_ctx_id;
}

sgl_context sgl_default_context() {
    return SGL_DEFAULT_CONTEXT;
}

i32 sgl_num_vertices() {
    assert(0xABCDABCD == _sgl.init_cookie);
    _sgl_context_t* ctx = _sgl.cur_ctx;
    if ctx != null {
        return _sgl_num_vertices(ctx);
    } else {
        return 0;
    }
}

i32 sgl_num_commands() {
    assert(0xABCDABCD == _sgl.init_cookie);
    _sgl_context_t* ctx = _sgl.cur_ctx;
    if ctx != null {
        return _sgl_num_commands(ctx);
    } else {
        return 0;
    }
}

sgl_pipeline sgl_make_pipeline(sg_pipeline_desc* desc) {
    assert(0xABCDABCD == _sgl.init_cookie);
    _sgl_context_t* ctx = _sgl.cur_ctx;
    if ctx != null {
        return _sgl_make_pipeline(desc, &ctx.desc);
    } else {
        return _sgl_make_pip_id(cast(u32, SG_INVALID_ID));
    }
}

sgl_pipeline sgl_context_make_pipeline(sgl_context ctx_id, sg_pipeline_desc* desc) {
    assert(0xABCDABCD == _sgl.init_cookie);
    _sgl_context_t* ctx = _sgl_lookup_context(ctx_id.id);
    if ctx != null {
        return _sgl_make_pipeline(desc, &ctx.desc);
    } else {
        return _sgl_make_pip_id(cast(u32, SG_INVALID_ID));
    }
}

void sgl_destroy_pipeline(sgl_pipeline pip_id) {
    assert(0xABCDABCD == _sgl.init_cookie);
    _sgl_destroy_pipeline(pip_id);
}

void sgl_load_pipeline(sgl_pipeline pip_id) {
    assert(0xABCDABCD == _sgl.init_cookie);
    _sgl_context_t* ctx = _sgl.cur_ctx;
    if ctx == null {
        return;
    }
    assert(ctx.pip_tos >= 0 && ctx.pip_tos < 64);
    ctx.pip_stack[ctx.pip_tos] = pip_id;
}

void sgl_load_default_pipeline() {
    assert(0xABCDABCD == _sgl.init_cookie);
    _sgl_context_t* ctx = _sgl.cur_ctx;
    if ctx == null {
        return;
    }
    assert(ctx.pip_tos >= 0 && ctx.pip_tos < 64);
    ctx.pip_stack[ctx.pip_tos] = ctx.def_pip;
}

void sgl_push_pipeline() {
    assert(0xABCDABCD == _sgl.init_cookie);
    _sgl_context_t* ctx = _sgl.cur_ctx;
    if ctx == null {
        return;
    }
    if ctx.pip_tos < 64 - 1 {
        ctx.pip_tos++;
        ctx.pip_stack[ctx.pip_tos] = ctx.pip_stack[ctx.pip_tos - 1];
    } else {
        ctx.error.stack_overflow = true;
        ctx.error.any = true;
    }
}

void sgl_pop_pipeline() {
    assert(0xABCDABCD == _sgl.init_cookie);
    _sgl_context_t* ctx = _sgl.cur_ctx;
    if ctx == null {
        return;
    }
    if ctx.pip_tos > 0 {
        ctx.pip_tos--;
    } else {
        ctx.error.stack_underflow = true;
        ctx.error.any = true;
    }
}

void sgl_defaults() {
    assert(0xABCDABCD == _sgl.init_cookie);
    _sgl_context_t* ctx = _sgl.cur_ctx;
    if ctx == null {
        return;
    }
    assert(cast(i64, !ctx.in_begin));
    ctx.u = 0.0f;
    ctx.v = 0.0f;
    ctx.rgba = 0xFFFFFFFF;
    ctx.point_size = 1.0f;
    ctx.texturing_enabled = false;
    ctx.cur_view = _sgl.def_view;
    ctx.cur_smp = _sgl.def_smp;
    sgl_load_default_pipeline();
    _sgl_identity(_sgl_matrix_texture(ctx));
    _sgl_identity(_sgl_matrix_modelview(ctx));
    _sgl_identity(_sgl_matrix_projection(ctx));
    ctx.cur_matrix_mode = SGL_MATRIXMODE_MODELVIEW;
    ctx.matrix_dirty = true;
}

void sgl_layer(i32 layer_id) {
    assert(0xABCDABCD == _sgl.init_cookie);
    _sgl_context_t* ctx = _sgl.cur_ctx;
    if ctx == null {
        return;
    }
    assert(cast(i64, !ctx.in_begin));
    ctx.layer_id = layer_id;
}

void sgl_viewport(i32 x, i32 y, i32 w, i32 h, bool origin_top_left) {
    assert(0xABCDABCD == _sgl.init_cookie);
    _sgl_context_t* ctx = _sgl.cur_ctx;
    if ctx == null {
        return;
    }
    assert(cast(i64, !ctx.in_begin));
    _sgl_command_t* cmd = _sgl_next_command(ctx);
    if cmd != null {
        cmd.cmd = SGL_COMMAND_VIEWPORT;
        cmd.layer_id = ctx.layer_id;
        cmd.args.viewport.x = x;
        cmd.args.viewport.y = y;
        cmd.args.viewport.w = w;
        cmd.args.viewport.h = h;
        cmd.args.viewport.origin_top_left = origin_top_left;
    }
}

void sgl_viewportf(f32 x, f32 y, f32 w, f32 h, bool origin_top_left) {
    sgl_viewport(cast(i32, x), cast(i32, y), cast(i32, w), cast(i32, h), origin_top_left);
}

void sgl_scissor_rect(i32 x, i32 y, i32 w, i32 h, bool origin_top_left) {
    assert(0xABCDABCD == _sgl.init_cookie);
    _sgl_context_t* ctx = _sgl.cur_ctx;
    if ctx == null {
        return;
    }
    assert(cast(i64, !ctx.in_begin));
    _sgl_command_t* cmd = _sgl_next_command(ctx);
    if cmd != null {
        cmd.cmd = SGL_COMMAND_SCISSOR_RECT;
        cmd.layer_id = ctx.layer_id;
        cmd.args.scissor_rect.x = x;
        cmd.args.scissor_rect.y = y;
        cmd.args.scissor_rect.w = w;
        cmd.args.scissor_rect.h = h;
        cmd.args.scissor_rect.origin_top_left = origin_top_left;
    }
}

void sgl_scissor_rectf(f32 x, f32 y, f32 w, f32 h, bool origin_top_left) {
    sgl_scissor_rect(cast(i32, x), cast(i32, y), cast(i32, w), cast(i32, h), origin_top_left);
}

void sgl_enable_texture() {
    assert(0xABCDABCD == _sgl.init_cookie);
    _sgl_context_t* ctx = _sgl.cur_ctx;
    if ctx == null {
        return;
    }
    assert(cast(i64, !ctx.in_begin));
    ctx.texturing_enabled = true;
}

void sgl_disable_texture() {
    assert(0xABCDABCD == _sgl.init_cookie);
    _sgl_context_t* ctx = _sgl.cur_ctx;
    if ctx == null {
        return;
    }
    assert(cast(i64, !ctx.in_begin));
    ctx.texturing_enabled = false;
}

void sgl_texture(sg_view tex_view, sg_sampler smp) {
    assert(0xABCDABCD == _sgl.init_cookie);
    _sgl_context_t* ctx = _sgl.cur_ctx;
    if ctx == null {
        return;
    }
    assert(cast(i64, !ctx.in_begin));
    if cast(u32, SG_INVALID_ID) != tex_view.id {
        ctx.cur_view = tex_view;
    } else {
        ctx.cur_view = _sgl.def_view;
    }
    if cast(u32, SG_INVALID_ID) != smp.id {
        ctx.cur_smp = smp;
    } else {
        ctx.cur_smp = _sgl.def_smp;
    }
}

void sgl_begin_points() {
    assert(0xABCDABCD == _sgl.init_cookie);
    _sgl_context_t* ctx = _sgl.cur_ctx;
    if ctx == null {
        return;
    }
    assert(cast(i64, !ctx.in_begin));
    _sgl_begin(ctx, SGL_PRIMITIVETYPE_POINTS);
}

void sgl_begin_lines() {
    assert(0xABCDABCD == _sgl.init_cookie);
    _sgl_context_t* ctx = _sgl.cur_ctx;
    if ctx == null {
        return;
    }
    assert(cast(i64, !ctx.in_begin));
    _sgl_begin(ctx, SGL_PRIMITIVETYPE_LINES);
}

void sgl_begin_line_strip() {
    assert(0xABCDABCD == _sgl.init_cookie);
    _sgl_context_t* ctx = _sgl.cur_ctx;
    if ctx == null {
        return;
    }
    assert(cast(i64, !ctx.in_begin));
    _sgl_begin(ctx, SGL_PRIMITIVETYPE_LINE_STRIP);
}

void sgl_begin_triangles() {
    assert(0xABCDABCD == _sgl.init_cookie);
    _sgl_context_t* ctx = _sgl.cur_ctx;
    if ctx == null {
        return;
    }
    assert(cast(i64, !ctx.in_begin));
    _sgl_begin(ctx, SGL_PRIMITIVETYPE_TRIANGLES);
}

void sgl_begin_triangle_strip() {
    assert(0xABCDABCD == _sgl.init_cookie);
    _sgl_context_t* ctx = _sgl.cur_ctx;
    if ctx == null {
        return;
    }
    assert(cast(i64, !ctx.in_begin));
    _sgl_begin(ctx, SGL_PRIMITIVETYPE_TRIANGLE_STRIP);
}

void sgl_begin_quads() {
    assert(0xABCDABCD == _sgl.init_cookie);
    _sgl_context_t* ctx = _sgl.cur_ctx;
    if ctx == null {
        return;
    }
    assert(cast(i64, !ctx.in_begin));
    _sgl_begin(ctx, SGL_PRIMITIVETYPE_QUADS);
}

void sgl_end() {
    assert(0xABCDABCD == _sgl.init_cookie);
    _sgl_context_t* ctx = _sgl.cur_ctx;
    if ctx == null {
        return;
    }
    assert(cast(i64, ctx.in_begin));
    assert(ctx.vertices.next >= ctx.base_vertex);
    ctx.in_begin = false;
    bool matrix_dirty = ctx.matrix_dirty;
    if matrix_dirty != 0 {
        ctx.matrix_dirty = false;
        _sgl_uniform_t* uni = _sgl_next_uniform(ctx);
        if uni != null {
            _sgl_matmul4(&uni.mvp, _sgl_matrix_projection(ctx), _sgl_matrix_modelview(ctx));
            uni.tm = *_sgl_matrix_texture(ctx);
        }
    }
    if ctx.error.any != 0 {
        return;
    }
    sg_pipeline pip = _sgl_get_pipeline(ctx.pip_stack[ctx.pip_tos], ctx.cur_prim_type);
    sg_view view = ctx.texturing_enabled != 0 ? ctx.cur_view : _sgl.def_view;
    sg_sampler smp = ctx.texturing_enabled != 0 ? ctx.cur_smp : _sgl.def_smp;
    _sgl_command_t* cur_cmd = _sgl_cur_command(ctx);
    bool merge_cmd = false;
    if cur_cmd != null {
        if cur_cmd.cmd == SGL_COMMAND_DRAW && cur_cmd.layer_id == ctx.layer_id && ctx.cur_prim_type != SGL_PRIMITIVETYPE_LINE_STRIP && ctx.cur_prim_type != SGL_PRIMITIVETYPE_TRIANGLE_STRIP && !matrix_dirty && cur_cmd.args.draw.view.id == view.id && cur_cmd.args.draw.smp.id == smp.id && cur_cmd.args.draw.pip.id == pip.id {
            merge_cmd = true;
        }
    }
    if merge_cmd != 0 {
        cur_cmd.args.draw.num_vertices += ctx.vertices.next - ctx.base_vertex;
    } else {
        _sgl_command_t* cmd = _sgl_next_command(ctx);
        if cmd != null {
            assert(ctx.uniforms.next > 0);
            cmd.cmd = SGL_COMMAND_DRAW;
            cmd.layer_id = ctx.layer_id;
            cmd.args.draw.view = view;
            cmd.args.draw.smp = smp;
            cmd.args.draw.pip = _sgl_get_pipeline(ctx.pip_stack[ctx.pip_tos], ctx.cur_prim_type);
            cmd.args.draw.base_vertex = ctx.base_vertex;
            cmd.args.draw.num_vertices = ctx.vertices.next - ctx.base_vertex;
            cmd.args.draw.uniform_index = ctx.uniforms.next - 1;
        }
    }
}

void sgl_point_size(f32 s) {
    _sgl_context_t* ctx = _sgl.cur_ctx;
    if ctx != null {
        ctx.point_size = s;
    }
}

void sgl_t2f(f32 u, f32 v) {
    _sgl_context_t* ctx = _sgl.cur_ctx;
    if ctx != null {
        ctx.u = u;
        ctx.v = v;
    }
}

void sgl_c3f(f32 r, f32 g, f32 b) {
    _sgl_context_t* ctx = _sgl.cur_ctx;
    if ctx != null {
        ctx.rgba = _sgl_pack_rgbaf(r, g, b, 1.0f);
    }
}

void sgl_c4f(f32 r, f32 g, f32 b, f32 a) {
    _sgl_context_t* ctx = _sgl.cur_ctx;
    if ctx != null {
        ctx.rgba = _sgl_pack_rgbaf(r, g, b, a);
    }
}

void sgl_c3b(u8 r, u8 g, u8 b) {
    _sgl_context_t* ctx = _sgl.cur_ctx;
    if ctx != null {
        ctx.rgba = _sgl_pack_rgbab(r, g, b, 255);
    }
}

void sgl_c4b(u8 r, u8 g, u8 b, u8 a) {
    _sgl_context_t* ctx = _sgl.cur_ctx;
    if ctx != null {
        ctx.rgba = _sgl_pack_rgbab(r, g, b, a);
    }
}

void sgl_c1i(u32 rgba) {
    _sgl_context_t* ctx = _sgl.cur_ctx;
    if ctx != null {
        ctx.rgba = rgba;
    }
}

void sgl_v2f(f32 x, f32 y) {
    _sgl_context_t* ctx = _sgl.cur_ctx;
    if ctx != null {
        _sgl_vtx(ctx, x, y, 0.0f, ctx.u, ctx.v, ctx.rgba);
    }
}

void sgl_v3f(f32 x, f32 y, f32 z) {
    _sgl_context_t* ctx = _sgl.cur_ctx;
    if ctx != null {
        _sgl_vtx(ctx, x, y, z, ctx.u, ctx.v, ctx.rgba);
    }
}

void sgl_v2f_t2f(f32 x, f32 y, f32 u, f32 v) {
    _sgl_context_t* ctx = _sgl.cur_ctx;
    if ctx != null {
        _sgl_vtx(ctx, x, y, 0.0f, u, v, ctx.rgba);
    }
}

void sgl_v3f_t2f(f32 x, f32 y, f32 z, f32 u, f32 v) {
    _sgl_context_t* ctx = _sgl.cur_ctx;
    if ctx != null {
        _sgl_vtx(ctx, x, y, z, u, v, ctx.rgba);
    }
}

void sgl_v2f_c3f(f32 x, f32 y, f32 r, f32 g, f32 b) {
    _sgl_context_t* ctx = _sgl.cur_ctx;
    if ctx != null {
        _sgl_vtx(ctx, x, y, 0.0f, ctx.u, ctx.v, _sgl_pack_rgbaf(r, g, b, 1.0f));
    }
}

void sgl_v2f_c3b(f32 x, f32 y, u8 r, u8 g, u8 b) {
    _sgl_context_t* ctx = _sgl.cur_ctx;
    if ctx != null {
        _sgl_vtx(ctx, x, y, 0.0f, ctx.u, ctx.v, _sgl_pack_rgbab(r, g, b, 255));
    }
}

void sgl_v2f_c4f(f32 x, f32 y, f32 r, f32 g, f32 b, f32 a) {
    _sgl_context_t* ctx = _sgl.cur_ctx;
    if ctx != null {
        _sgl_vtx(ctx, x, y, 0.0f, ctx.u, ctx.v, _sgl_pack_rgbaf(r, g, b, a));
    }
}

void sgl_v2f_c4b(f32 x, f32 y, u8 r, u8 g, u8 b, u8 a) {
    _sgl_context_t* ctx = _sgl.cur_ctx;
    if ctx != null {
        _sgl_vtx(ctx, x, y, 0.0f, ctx.u, ctx.v, _sgl_pack_rgbab(r, g, b, a));
    }
}

void sgl_v2f_c1i(f32 x, f32 y, u32 rgba) {
    _sgl_context_t* ctx = _sgl.cur_ctx;
    if ctx != null {
        _sgl_vtx(ctx, x, y, 0.0f, ctx.u, ctx.v, rgba);
    }
}

void sgl_v3f_c3f(f32 x, f32 y, f32 z, f32 r, f32 g, f32 b) {
    _sgl_context_t* ctx = _sgl.cur_ctx;
    if ctx != null {
        _sgl_vtx(ctx, x, y, z, ctx.u, ctx.v, _sgl_pack_rgbaf(r, g, b, 1.0f));
    }
}

void sgl_v3f_c3b(f32 x, f32 y, f32 z, u8 r, u8 g, u8 b) {
    _sgl_context_t* ctx = _sgl.cur_ctx;
    if ctx != null {
        _sgl_vtx(ctx, x, y, z, ctx.u, ctx.v, _sgl_pack_rgbab(r, g, b, 255));
    }
}

void sgl_v3f_c4f(f32 x, f32 y, f32 z, f32 r, f32 g, f32 b, f32 a) {
    _sgl_context_t* ctx = _sgl.cur_ctx;
    if ctx != null {
        _sgl_vtx(ctx, x, y, z, ctx.u, ctx.v, _sgl_pack_rgbaf(r, g, b, a));
    }
}

void sgl_v3f_c4b(f32 x, f32 y, f32 z, u8 r, u8 g, u8 b, u8 a) {
    _sgl_context_t* ctx = _sgl.cur_ctx;
    if ctx != null {
        _sgl_vtx(ctx, x, y, z, ctx.u, ctx.v, _sgl_pack_rgbab(r, g, b, a));
    }
}

void sgl_v3f_c1i(f32 x, f32 y, f32 z, u32 rgba) {
    _sgl_context_t* ctx = _sgl.cur_ctx;
    if ctx != null {
        _sgl_vtx(ctx, x, y, z, ctx.u, ctx.v, rgba);
    }
}

void sgl_v2f_t2f_c3f(f32 x, f32 y, f32 u, f32 v, f32 r, f32 g, f32 b) {
    _sgl_context_t* ctx = _sgl.cur_ctx;
    if ctx != null {
        _sgl_vtx(ctx, x, y, 0.0f, u, v, _sgl_pack_rgbaf(r, g, b, 1.0f));
    }
}

void sgl_v2f_t2f_c3b(f32 x, f32 y, f32 u, f32 v, u8 r, u8 g, u8 b) {
    _sgl_context_t* ctx = _sgl.cur_ctx;
    if ctx != null {
        _sgl_vtx(ctx, x, y, 0.0f, u, v, _sgl_pack_rgbab(r, g, b, 255));
    }
}

void sgl_v2f_t2f_c4f(f32 x, f32 y, f32 u, f32 v, f32 r, f32 g, f32 b, f32 a) {
    _sgl_context_t* ctx = _sgl.cur_ctx;
    if ctx != null {
        _sgl_vtx(ctx, x, y, 0.0f, u, v, _sgl_pack_rgbaf(r, g, b, a));
    }
}

void sgl_v2f_t2f_c4b(f32 x, f32 y, f32 u, f32 v, u8 r, u8 g, u8 b, u8 a) {
    _sgl_context_t* ctx = _sgl.cur_ctx;
    if ctx != null {
        _sgl_vtx(ctx, x, y, 0.0f, u, v, _sgl_pack_rgbab(r, g, b, a));
    }
}

void sgl_v2f_t2f_c1i(f32 x, f32 y, f32 u, f32 v, u32 rgba) {
    _sgl_context_t* ctx = _sgl.cur_ctx;
    if ctx != null {
        _sgl_vtx(ctx, x, y, 0.0f, u, v, rgba);
    }
}

void sgl_v3f_t2f_c3f(f32 x, f32 y, f32 z, f32 u, f32 v, f32 r, f32 g, f32 b) {
    _sgl_context_t* ctx = _sgl.cur_ctx;
    if ctx != null {
        _sgl_vtx(ctx, x, y, z, u, v, _sgl_pack_rgbaf(r, g, b, 1.0f));
    }
}

void sgl_v3f_t2f_c3b(f32 x, f32 y, f32 z, f32 u, f32 v, u8 r, u8 g, u8 b) {
    _sgl_context_t* ctx = _sgl.cur_ctx;
    if ctx != null {
        _sgl_vtx(ctx, x, y, z, u, v, _sgl_pack_rgbab(r, g, b, 255));
    }
}

void sgl_v3f_t2f_c4f(f32 x, f32 y, f32 z, f32 u, f32 v, f32 r, f32 g, f32 b, f32 a) {
    _sgl_context_t* ctx = _sgl.cur_ctx;
    if ctx != null {
        _sgl_vtx(ctx, x, y, z, u, v, _sgl_pack_rgbaf(r, g, b, a));
    }
}

void sgl_v3f_t2f_c4b(f32 x, f32 y, f32 z, f32 u, f32 v, u8 r, u8 g, u8 b, u8 a) {
    _sgl_context_t* ctx = _sgl.cur_ctx;
    if ctx != null {
        _sgl_vtx(ctx, x, y, z, u, v, _sgl_pack_rgbab(r, g, b, a));
    }
}

void sgl_v3f_t2f_c1i(f32 x, f32 y, f32 z, f32 u, f32 v, u32 rgba) {
    _sgl_context_t* ctx = _sgl.cur_ctx;
    if ctx != null {
        _sgl_vtx(ctx, x, y, z, u, v, rgba);
    }
}

void sgl_matrix_mode_modelview() {
    assert(0xABCDABCD == _sgl.init_cookie);
    _sgl_context_t* ctx = _sgl.cur_ctx;
    if ctx != null {
        ctx.cur_matrix_mode = SGL_MATRIXMODE_MODELVIEW;
    }
}

void sgl_matrix_mode_projection() {
    assert(0xABCDABCD == _sgl.init_cookie);
    _sgl_context_t* ctx = _sgl.cur_ctx;
    if ctx != null {
        ctx.cur_matrix_mode = SGL_MATRIXMODE_PROJECTION;
    }
}

void sgl_matrix_mode_texture() {
    assert(0xABCDABCD == _sgl.init_cookie);
    _sgl_context_t* ctx = _sgl.cur_ctx;
    if ctx != null {
        ctx.cur_matrix_mode = SGL_MATRIXMODE_TEXTURE;
    }
}

void sgl_load_identity() {
    assert(0xABCDABCD == _sgl.init_cookie);
    _sgl_context_t* ctx = _sgl.cur_ctx;
    if ctx == null {
        return;
    }
    ctx.matrix_dirty = true;
    _sgl_identity(_sgl_matrix(ctx));
}

void sgl_load_matrix(f32* m) {
    assert(0xABCDABCD == _sgl.init_cookie);
    _sgl_context_t* ctx = _sgl.cur_ctx;
    if ctx == null {
        return;
    }
    ctx.matrix_dirty = true;
    memcpy(&_sgl_matrix(ctx).v[0][0], &m[0], cast(u64, 64));
}

void sgl_load_transpose_matrix(f32* m) {
    assert(0xABCDABCD == _sgl.init_cookie);
    _sgl_context_t* ctx = _sgl.cur_ctx;
    if ctx == null {
        return;
    }
    ctx.matrix_dirty = true;
    _sgl_transpose(_sgl_matrix(ctx), cast(_sgl_matrix_t*, &m[0]));
}

void sgl_mult_matrix(f32* m) {
    assert(0xABCDABCD == _sgl.init_cookie);
    _sgl_context_t* ctx = _sgl.cur_ctx;
    if ctx == null {
        return;
    }
    ctx.matrix_dirty = true;
    var m0 = cast(_sgl_matrix_t*, &m[0]);
    _sgl_mul(_sgl_matrix(ctx), m0);
}

void sgl_mult_transpose_matrix(f32* m) {
    assert(0xABCDABCD == _sgl.init_cookie);
    _sgl_context_t* ctx = _sgl.cur_ctx;
    if ctx == null {
        return;
    }
    ctx.matrix_dirty = true;
    noinit _sgl_matrix_t m0;
    _sgl_transpose(&m0, cast(_sgl_matrix_t*, &m[0]));
    _sgl_mul(_sgl_matrix(ctx), &m0);
}

void sgl_rotate(f32 angle_rad, f32 x, f32 y, f32 z) {
    assert(0xABCDABCD == _sgl.init_cookie);
    _sgl_context_t* ctx = _sgl.cur_ctx;
    if ctx == null {
        return;
    }
    ctx.matrix_dirty = true;
    _sgl_rotate(_sgl_matrix(ctx), angle_rad, x, y, z);
}

void sgl_scale(f32 x, f32 y, f32 z) {
    assert(0xABCDABCD == _sgl.init_cookie);
    _sgl_context_t* ctx = _sgl.cur_ctx;
    if ctx == null {
        return;
    }
    ctx.matrix_dirty = true;
    _sgl_scale(_sgl_matrix(ctx), x, y, z);
}

void sgl_translate(f32 x, f32 y, f32 z) {
    assert(0xABCDABCD == _sgl.init_cookie);
    _sgl_context_t* ctx = _sgl.cur_ctx;
    if ctx == null {
        return;
    }
    ctx.matrix_dirty = true;
    _sgl_translate(_sgl_matrix(ctx), x, y, z);
}

void sgl_frustum(f32 l, f32 r, f32 b, f32 t, f32 n, f32 f) {
    assert(0xABCDABCD == _sgl.init_cookie);
    _sgl_context_t* ctx = _sgl.cur_ctx;
    if ctx == null {
        return;
    }
    ctx.matrix_dirty = true;
    _sgl_frustum(_sgl_matrix(ctx), l, r, b, t, n, f);
}

void sgl_ortho(f32 l, f32 r, f32 b, f32 t, f32 n, f32 f) {
    assert(0xABCDABCD == _sgl.init_cookie);
    _sgl_context_t* ctx = _sgl.cur_ctx;
    if ctx == null {
        return;
    }
    ctx.matrix_dirty = true;
    _sgl_ortho(_sgl_matrix(ctx), l, r, b, t, n, f);
}

void sgl_perspective(f32 fov_y, f32 aspect, f32 z_near, f32 z_far) {
    assert(0xABCDABCD == _sgl.init_cookie);
    _sgl_context_t* ctx = _sgl.cur_ctx;
    if ctx == null {
        return;
    }
    ctx.matrix_dirty = true;
    _sgl_perspective(_sgl_matrix(ctx), fov_y, aspect, z_near, z_far);
}

void sgl_lookat(f32 eye_x, f32 eye_y, f32 eye_z, f32 center_x, f32 center_y, f32 center_z, f32 up_x, f32 up_y, f32 up_z) {
    assert(0xABCDABCD == _sgl.init_cookie);
    _sgl_context_t* ctx = _sgl.cur_ctx;
    if ctx == null {
        return;
    }
    ctx.matrix_dirty = true;
    _sgl_lookat(_sgl_matrix(ctx), eye_x, eye_y, eye_z, center_x, center_y, center_z, up_x, up_y, up_z);
}

void sgl_push_matrix() {
    assert(0xABCDABCD == _sgl.init_cookie);
    _sgl_context_t* ctx = _sgl.cur_ctx;
    if ctx == null {
        return;
    }
    assert(ctx.cur_matrix_mode >= 0 && ctx.cur_matrix_mode < SGL_NUM_MATRIXMODES);
    ctx.matrix_dirty = true;
    if ctx.matrix_tos[ctx.cur_matrix_mode] < 64 - 1 {
        _sgl_matrix_t* src = _sgl_matrix(ctx);
        ctx.matrix_tos[ctx.cur_matrix_mode]++;
        _sgl_matrix_t* dst = _sgl_matrix(ctx);
        *dst = *src;
    } else {
        ctx.error.stack_overflow = true;
        ctx.error.any = true;
    }
}

void sgl_pop_matrix() {
    assert(0xABCDABCD == _sgl.init_cookie);
    _sgl_context_t* ctx = _sgl.cur_ctx;
    if ctx == null {
        return;
    }
    assert(ctx.cur_matrix_mode >= 0 && ctx.cur_matrix_mode < SGL_NUM_MATRIXMODES);
    ctx.matrix_dirty = true;
    if ctx.matrix_tos[ctx.cur_matrix_mode] > 0 {
        ctx.matrix_tos[ctx.cur_matrix_mode]--;
    } else {
        ctx.error.stack_underflow = true;
        ctx.error.any = true;
    }
}

void sgl_draw() {
    assert(0xABCDABCD == _sgl.init_cookie);
    _sgl_context_t* ctx = _sgl.cur_ctx;
    if ctx != null {
        _sgl_draw(ctx, 0);
    }
}

void sgl_draw_layer(i32 layer_id) {
    assert(0xABCDABCD == _sgl.init_cookie);
    _sgl_context_t* ctx = _sgl.cur_ctx;
    if ctx != null {
        _sgl_draw(ctx, layer_id);
    }
}

void sgl_context_draw(sgl_context ctx_id) {
    assert(0xABCDABCD == _sgl.init_cookie);
    _sgl_context_t* ctx = _sgl_lookup_context(ctx_id.id);
    if ctx != null {
        _sgl_draw(ctx, 0);
    }
}

void sgl_context_draw_layer(sgl_context ctx_id, i32 layer_id) {
    assert(0xABCDABCD == _sgl.init_cookie);
    _sgl_context_t* ctx = _sgl_lookup_context(ctx_id.id);
    if ctx != null {
        _sgl_draw(ctx, layer_id);
    }
}

