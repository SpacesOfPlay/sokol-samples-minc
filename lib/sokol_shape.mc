// sokol_shape
import sokol_all;

enum __enum_SSHAPE_MIN_VERTEX_SIZE {
    SSHAPE_MIN_VERTEX_SIZE = 12,
    SSHAPE_MAX_VERTEX_SIZE = 24,
}

type __arr_f32_4 = f32[4];
/*
    sshape_range_t is a pointer-size-pair struct used to pass memory
    blobs into sokol-shape. When initialized from a value type
    (array or struct), use the SSHAPE_RANGE() macro to build
    an sshape_range struct.
*/
struct sshape_range_t {
    void* ptr;
    u64 size;
}

// a 4x4 matrix wrapper struct
struct sshape_mat4_t {
    __arr_f32_4[4] m;
}

// a struct for configuring optional vertex components
struct sshape_optional_components_t {
    bool normals;
    bool texcoords;
    bool colors;
}

// a range of draw-elements (sg_draw(int base_element, int num_element, ...))
struct sshape_element_range_t {
    i32 base_element;
    i32 num_elements;
}

// number of elements and byte size of build actions
struct sshape_sizes_item_t {
    u32 num;
    u32 size;
}

struct sshape_sizes_t {
    sshape_sizes_item_t vertices;
    sshape_sizes_item_t indices;
}

// in/out struct to keep track of mesh-build state
struct sshape_buffer_state_t {
    sshape_range_t buffer;
    u64 data_size;
    u64 shape_offset;
}

struct sshape_state_t {
    bool valid;
    sshape_optional_components_t disable;
    sshape_buffer_state_t vertices;
    sshape_buffer_state_t indices;
}

// creation parameters for the different shape types
struct sshape_plane_t {
    f32 width;
    f32 depth;
    u16 tiles;
    u32 color;
    bool random_colors;
    bool merge;
    sshape_mat4_t transform;
}

struct sshape_box_t {
    f32 width;
    f32 height;
    f32 depth;
    u16 tiles;
    u32 color;
    bool random_colors;
    bool merge;
    sshape_mat4_t transform;
}

struct sshape_sphere_t {
    f32 radius;
    u16 slices;
    u16 stacks;
    u32 color;
    bool random_colors;
    bool merge;
    sshape_mat4_t transform;
}

struct sshape_cylinder_t {
    f32 radius;
    f32 height;
    u16 slices;
    u16 stacks;
    u32 color;
    bool random_colors;
    bool merge;
    sshape_mat4_t transform;
}

struct sshape_torus_t {
    f32 radius;
    f32 ring_radius;
    u16 sides;
    u16 rings;
    u32 color;
    bool random_colors;
    bool merge;
    sshape_mat4_t transform;
}

/*-- IMPLEMENTATION ----------------------------------------------------------*/
struct _sshape_vec4_t {
    f32 x;
    f32 y;
    f32 z;
    f32 w;
}

struct _sshape_vec2_t {
    f32 x;
    f32 y;
}

/*
    sokol_shape.h -- create simple primitive shapes for sokol_gfx.h

    Project URL: https://github.com/floooh/sokol

    Do this:
        #define SOKOL_IMPL or
        #define SOKOL_SHAPE_IMPL
    before you include this file in *one* C or C++ file to create the
    implementation.

    Include the following headers before including sokol_shape.h:

        sokol_gfx.h

    ...optionally provide the following macros to override defaults:

    SOKOL_ASSERT(c)     - your own assert macro (default: assert(c))
    SOKOL_SHAPE_API_DECL- public function declaration prefix (default: extern)
    SOKOL_API_DECL      - same as SOKOL_SHAPE_API_DECL
    SOKOL_API_IMPL      - public function implementation prefix (default: -)

    If sokol_shape.h is compiled as a DLL, define the following before
    including the declaration or implementation:

    SOKOL_DLL

    On Windows, SOKOL_DLL will define SOKOL_SHAPE_API_DECL as __declspec(dllexport)
    or __declspec(dllimport) as needed.

    FEATURE OVERVIEW
    ================
    sokol_shape.h creates vertices and indices for simple shapes and
    builds structs which can be plugged into sokol-gfx resource
    creation functions:

    The following shape types are supported:

        - plane
        - cube
        - sphere (with poles, not geodesic)
        - cylinder
        - torus (donut)

    Generated vertex components have the following format (all components
    except position are optional):

    - position: SG_VERTEXFORMAT_FLOAT3
    - normal: SG_VERTEXFORMAT_BYTE4N
    - texcoord: SG_VERTEXFORMAT_USHORT2N
    - color: SG_VERTEXFORMAT_UBYTE4N

    Indices are generally 16-bits wide (SG_INDEXTYPE_UINT16) and the indices
    are written as triangle-lists (SG_PRIMITIVETYPE_TRIANGLES).

    EXAMPLES:
    =========

    Create multiple shapes into the same vertex- and index-buffer and
    render with separate draw calls:

    https://github.com/floooh/sokol-samples/blob/master/sapp/shapes-sapp.c

    Same as the above, but pre-transform shapes and merge them into a single
    shape that's rendered with a single draw call.

    https://github.com/floooh/sokol-samples/blob/master/sapp/shapes-transform-sapp.c

    STEP-BY-STEP:
    =============

    Setup an sshape_state_t struct with pointers to memory buffers where
    generated vertices and indices will be written to:

    ```c
    uint8_t vertices[512 * SSHAPE_MAX_VERTEX_SIZE];
    uint16_t indices[4096];

    sshape_state_t state = {
        .vertices = { .buffer = SSHAPE_RANGE(vertices) },
        .indices = { .buffer = SSHAPE_RANGE(indices) }
    };
    ```
    This generates all vertex components. Optionally you can disable
    vertex components to be generates:

    ```c
    sshape_state_t state = {
        .disable {
            .normals = false,
            .texcoords = false,
            .colors = false,
        },
        .vertices = { .buffer = SSHAPE_RANGE(vertices) },
        .indices = { .buffer = SSHAPE_RANGE(indices) }
    };
    ```

    Compute the per-vertex size in bytes via (note that the arguments
    have inverted meaning from `sshape_state_t.disabled`, here you define
    what components are enabled:

    ```c
    size_t vertex_size = sshape_vertex_size(&(sshape_optional_components_t){
        .normals = true,
        .texcoords = true,
        .colors = true,
    });
    ```
    This returns a value between SSHAPE_MIN_VERTEX_SIZE (12) and
    SSHAPE_MAX_VERTEX_SIZE (24).

    To find out how big the vertex and index memory buffers must be (in case you want
    to allocate dynamically) call the following functions. For `vertex_size`
    pass in the result of the `sshape_vertex_size` function:
    ```c
    sshape_sizes_t sshape_plane_sizes(uint32_t tiles, size_t vertex_size);
    sshape_sizes_t sshape_box_sizes(uint32_t tiles, size_t vertex_size);
    sshape_sizes_t sshape_sphere_sizes(uint32_t slices, uint32_t stacks, size_t vertex_size);
    sshape_sizes_t sshape_cylinder_sizes(uint32_t slices, uint32_t stacks, size_t vertex_size);
    sshape_sizes_t sshape_torus_sizes(uint32_t sides, uint32_t rings, size_t vertex_size);
    ```

    The returned sshape_sizes_t struct contains vertex- and index-counts
    as well as the equivalent buffer sizes in bytes. For instance:

    ```c
    const vtx_size = sshape_vertex_size(&(sshape_optional_components){0});
    sshape_sizes_t sizes = sshape_sphere_sizes(36, 12, vtx_size);
    uint32_t num_vertices = sizes.vertices.num;
    uint32_t num_indices = sizes.indices.num;
    uint32_t vertex_buffer_size = sizes.vertices.size;
    uint32_t index_buffer_size = sizes.indices.size;
    ```

    With the sshape_state_t struct that was setup earlier, call any
    of the shape-builder functions:

    ```c
    void sshape_build_plane(sshape_state_t* state, const sshape_plane_t* params);
    void sshape_build_box(sshape_state_t* state, const sshape_box_t* params);
    void sshape_build_sphere(sshape_state_t* state, const sshape_sphere_t* params);
    void sshape_build_cylinder(sshape_state_t* state, const sshape_cylinder_t* params);
    void sshape_build_torus(sshape_state_t* state, const sshape_torus_t* params);
    ```

    Note that the `state` arg is a non-const pointer, this indicates
    that the `sshape_state_t` struct will be mutated.

    The second argument is a struct which holds creation parameters.

    For instance to build a sphere with radius 2, 36 "cake slices" and 12 stacks:

    ```c
    sshape_state_t state = ...;
    sshape_build_sphere(&state, &(sshape_sphere_t){
        .radius = 2.0f,
        .slices = 36,
        .stacks = 12,
    });
    ```

    If the provided buffers are big enough to hold all generated vertices and
    indices, the "valid" field in the result will be true:

    ```c
    assert(state.valid);
    ```

    The shape creation parameters have "useful defaults", refer to the
    actual C struct declarations below to look up those defaults.

    You can also provide additional creation parameters, like a common vertex
    color, a debug-helper to randomize colors, tell the shape builder function
    to merge the new shape with the previous shape into the same draw-element-range,
    or a 4x4 transform matrix to move, rotate and scale the generated vertices:

    ```c
    sshape_state_t state = ...;
    sshape_build_sphere(&state, &(sshape_sphere_t){
        .radius = 2.0f,
        .slices = 36,
        .stacks = 12,
        // merge with previous shape into a single element-range
        .merge = true,
        // set vertex color to red+opaque
        .color = sshape_color_4f(1.0f, 0.0f, 0.0f, 1.0f),
        // set position to y = 2.0
        .transform = {
            .m = {
                { 1.0f, 0.0f, 0.0f, 0.0f },
                { 0.0f, 1.0f, 0.0f, 0.0f },
                { 0.0f, 0.0f, 1.0f, 0.0f },
                { 0.0f, 2.0f, 0.0f, 1.0f },
            }
        }
    });
    assert(state.valid);
    ```

    The following helper functions can be used to build a packed
    color value or to convert from external matrix types:

    ```c
    uint32_t sshape_color_4f(float r, float g, float b, float a);
    uint32_t sshape_color_3f(float r, float g, float b);
    uint32_t sshape_color_4b(uint8_t r, uint8_t g, uint8_t b, uint8_t a);
    uint32_t sshape_color_3b(uint8_t r, uint8_t g, uint8_t b);
    sshape_mat4_t sshape_mat4(const float m[16]);
    sshape_mat4_t sshape_mat4_transpose(const float m[16]);
    ```

    After the shape builder function has been called, the following functions
    are used to extract the build result for plugging into sokol_gfx.h:

    ```c
    sshape_element_range_t sshape_element_range(const sshape_state_t* state);
    sg_buffer_desc sshape_vertex_buffer_desc(const sshape_state_t* state);
    sg_buffer_desc sshape_index_buffer_desc(const sshape_state_t* state);
    sg_vertex_buffer_layout_state sshape_vertex_buffer_layout_state(const sshape_state_t* state);
    sg_vertex_attr_state sshape_position_vertex_attr_state(const sshape_state_t* state);
    sg_vertex_attr_state sshape_normal_vertex_attr_state(consts sshape_state_t* state);
    sg_vertex_attr_state sshape_texcoord_vertex_attr_state(const sshape_state_t* state);
    sg_vertex_attr_state sshape_color_vertex_attr_state(const sshape_state_t* state);
    ```

    The sshape_element_range_t struct contains the base-index and number of
    indices which can be plugged into the sg_draw() call:

    ```c
    sshape_element_range_t elms = sshape_element_range(&state);
    ...
    sg_draw(elms.base_element, elms.num_elements, 1);
    ```

    To create sokol-gfx vertex- and index-buffers from the generated
    shape data:

    ```c
    // create sokol-gfx vertex buffer
    sg_buffer_desc vbuf_desc = sshape_vertex_buffer_desc(&state);
    sg_buffer vbuf = sg_make_buffer(&vbuf_desc);

    // create sokol-gfx index buffer
    sg_buffer_desc ibuf_desc = sshape_index_buffer_desc(&state);
    sg_buffer ibuf = sg_make_buffer(&ibuf_desc);
    ```

    The remaining functions are used to populate the vertex-layout item
    in sg_pipeline_desc:

    ```c
    sg_pipeline pip = sg_make_pipeline(&(sg_pipeline_desc){
        .layout = {
            .buffers[0] = sshape_vertex_buffer_layout_state(&state),
            .attrs = {
                [0] = sshape_position_vertex_attr_state(&state),
                [1] = sshape_normal_vertex_attr_state(&state),
                [2] = sshape_texcoord_vertex_attr_state(&state),
                [3] = sshape_color_vertex_attr_state(&state)
            }
        },
        ...
    });
    ```
    Note that you don't have to use all generated vertex attributes in the
    pipeline's vertex layout, the sg_vertex_buffer_layout_state struct returned
    by sshape_vertex_buffer_layout_state() contains the correct vertex stride
    to skip vertex components.

    WRITING MULTIPLE SHAPES INTO THE SAME BUFFER
    ============================================
    You can merge multiple shapes into the same vertex- and
    index-buffers and either render them as a single shape, or
    in separate draw calls.

    To build a single shape made of two cubes which can be rendered
    in a single draw-call:

    ```
    uint8_t vertices[128 * SSHAPE_MAX_VERTEX_SIZE];
    uint16_t indices[16];

    sshape_state_t state = {
        .vertices.buffer = SSHAPE_RANGE(vertices),
        .indices.buffer  = SSHAPE_RANGE(indices)
    };

    // first cube at pos x=-2.0 (with default size of 1x1x1)
    sshape_build_cube(&state, &(sshape_box_t){
        .transform = {
            .m = {
                { 1.0f, 0.0f, 0.0f, 0.0f },
                { 0.0f, 1.0f, 0.0f, 0.0f },
                { 0.0f, 0.0f, 1.0f, 0.0f },
                {-2.0f, 0.0f, 0.0f, 1.0f },
            }
        }
    });
    // ...and append another cube at pos pos=+1.0
    // NOTE the .merge = true, this tells the shape builder
    // function to not advance the current shape start offset
    sshape_build_cube(&state, &(sshape_box_t){
        .merge = true,
        .transform = {
            .m = {
                { 1.0f, 0.0f, 0.0f, 0.0f },
                { 0.0f, 1.0f, 0.0f, 0.0f },
                { 0.0f, 0.0f, 1.0f, 0.0f },
                {-2.0f, 0.0f, 0.0f, 1.0f },
            }
        }
    });
    assert(state.valid);

    // skipping buffer- and pipeline-creation...

    sshape_element_range_t elms = sshape_element_range(&state);
    sg_draw(elms.base_element, elms.num_elements, 1);
    ```

    To render the two cubes in separate draw-calls, the element-ranges used
    in the sg_draw() calls must be captured right after calling the
    builder-functions:

    ```c
    uint8_t vertices[128 * SSHAPE_MAX_VERTEX_SIZE];
    uint16_t indices[16];
    sshape_state_t state = {
        .vertices.buffer = SSHAPE_RANGE(vertices),
        .indices.buffer = SSHAPE_RANGE(indices)
    };

    // build a red cube...
    sshape_build_cube(&state, &(sshape_box_t){
        .color = sshape_color_3b(255, 0, 0)
    });
    sshape_element_range_t red_cube = sshape_element_range(&state);

    // append a green cube to the same vertex-/index-buffer:
    sshape_build_cube(&state, &sshape_box_t){
        .color = sshape_color_3b(0, 255, 0);
    });
    sshape_element_range_t green_cube = sshape_element_range(&state);

    // skipping buffer- and pipeline-creation...

    sg_draw(red_cube.base_element, red_cube.num_elements, 1);
    sg_draw(green_cube.base_element, green_cube.num_elements, 1);
    ```

    ...that's about all :)

    LICENSE
    =======
    zlib/libpng license

    Copyright (c) 2020 Andre Weissflog

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

private {
f32 _sshape_clamp(f32 v) {
    if v < 0.0f {
        return 0.0f;
    } else if v > 1.0f {
        return 1.0f;
    } else {
        return v;
    }
}

u32 _sshape_pack_ub4_ubyte4n(u8 x, u8 y, u8 z, u8 w) {
    return cast(u32, w) << 24 | cast(u32, z) << 16 | cast(u32, y) << 8 | x;
}

u32 _sshape_pack_f4_ubyte4n(f32 x, f32 y, f32 z, f32 w) {
    var x8 = cast(u8, x * 255.0f);
    var y8 = cast(u8, y * 255.0f);
    var z8 = cast(u8, z * 255.0f);
    var w8 = cast(u8, w * 255.0f);
    return _sshape_pack_ub4_ubyte4n(x8, y8, z8, w8);
}

u32 _sshape_pack_f4_byte4n(f32 x, f32 y, f32 z, f32 w) {
    var x8 = cast(i8, x * 127.0f);
    var y8 = cast(i8, y * 127.0f);
    var z8 = cast(i8, z * 127.0f);
    var w8 = cast(i8, w * 127.0f);
    return _sshape_pack_ub4_ubyte4n(cast(u8, x8), cast(u8, y8), cast(u8, z8), cast(u8, w8));
}

u16 _sshape_pack_f_ushortn(f32 x) {
    return cast(u16, x * 65535.0f);
}

_sshape_vec4_t _sshape_vec4(f32 x, f32 y, f32 z, f32 w) {
    var v = _sshape_vec4_t{x, y, z, w};
    return v;
}

_sshape_vec4_t _sshape_vec4_norm(_sshape_vec4_t v) {
    f32 l = sqrtf(v.x * v.x + v.y * v.y + v.z * v.z + v.w * v.w);
    if l != 0.0f {
        return _sshape_vec4(v.x / l, v.y / l, v.z / l, v.w / l);
    } else {
        return _sshape_vec4(0.0f, 1.0f, 0.0f, 0.0f);
    }
}

_sshape_vec2_t _sshape_vec2(f32 x, f32 y) {
    var v = _sshape_vec2_t{x, y};
    return v;
}

bool _sshape_mat4_isnull(sshape_mat4_t* m) {
    for i32 y = 0; y < 4; y++ {
        for i32 x = 0; x < 4; x++ {
            if 0.0f != m.m[y][x] {
                return false;
            }
        }
    }
    return true;
}

sshape_mat4_t _sshape_mat4_identity() {
    var m = sshape_mat4_t{
        {
            {1.0f, 0.0f, 0.0f, 0.0f},
            {0.0f, 1.0f, 0.0f, 0.0f},
            {0.0f, 0.0f, 1.0f, 0.0f},
            {0.0f, 0.0f, 0.0f, 1.0f},
        },
    };
    return m;
}

_sshape_vec4_t _sshape_mat4_mul(sshape_mat4_t* m, _sshape_vec4_t v) {
    var res = _sshape_vec4_t{
        m.m[0][0] * v.x + m.m[1][0] * v.y + m.m[2][0] * v.z + m.m[3][0] * v.w,
        m.m[0][1] * v.x + m.m[1][1] * v.y + m.m[2][1] * v.z + m.m[3][1] * v.w,
        m.m[0][2] * v.x + m.m[1][2] * v.y + m.m[2][2] * v.z + m.m[3][2] * v.w,
        m.m[0][3] * v.x + m.m[1][3] * v.y + m.m[2][3] * v.z + m.m[3][3] * v.w,
    };
    return res;
}

u32 _sshape_plane_num_vertices(u32 tiles) {
    return (tiles + 1) * (tiles + 1);
}

u32 _sshape_plane_num_indices(u32 tiles) {
    return tiles * tiles * 2 * 3;
}

u32 _sshape_box_num_vertices(u32 tiles) {
    return (tiles + 1) * (tiles + 1) * 6;
}

u32 _sshape_box_num_indices(u32 tiles) {
    return tiles * tiles * 2 * 6 * 3;
}

u32 _sshape_sphere_num_vertices(u32 slices, u32 stacks) {
    return (slices + 1) * (stacks + 1);
}

u32 _sshape_sphere_num_indices(u32 slices, u32 stacks) {
    return (2 * slices * stacks - 2 * slices) * 3;
}

u32 _sshape_cylinder_num_vertices(u32 slices, u32 stacks) {
    return (slices + 1) * (stacks + 5);
}

u32 _sshape_cylinder_num_indices(u32 slices, u32 stacks) {
    return (2 * slices * stacks + 2 * slices) * 3;
}

u32 _sshape_torus_num_vertices(u32 sides, u32 rings) {
    return (sides + 1) * (rings + 1);
}

u32 _sshape_torus_num_indices(u32 sides, u32 rings) {
    return sides * rings * 2 * 3;
}

bool _sshape_validate_buffer_state(sshape_buffer_state_t* state, u32 build_size) {
    if null == state.buffer.ptr {
        return false;
    }
    if 0 == state.buffer.size {
        return false;
    }
    if state.data_size + build_size > state.buffer.size {
        return false;
    }
    if state.shape_offset > state.data_size {
        return false;
    }
    return true;
}

u32 _sshape_vertex_size(bool has_normals, bool has_texcoords, bool has_colors) {
    u32 s = 3 * cast(u32, sizeof(f32));
    if has_normals != 0 {
        s += cast(u32, sizeof(u32));
    }
    if has_texcoords != 0 {
        s += 2 * cast(u32, sizeof(u16));
    }
    if has_colors != 0 {
        s += cast(u32, sizeof(u32));
    }
    return s;
}

i32 _sshape_vertex_position_offset(sshape_state_t* state) {
    ignore state;
    return 0;
}

i32 _sshape_vertex_normal_offset(sshape_state_t* state) {
    assert(cast(i64, !state.disable.normals));
    ignore state;
    return cast(i32, 3 * sizeof(f32));
}

i32 _sshape_vertex_texcoord_offset(sshape_state_t* state) {
    assert(cast(i64, !state.disable.texcoords));
    var offset = cast(i32, 3 * sizeof(f32));
    if state.disable.normals == 0 {
        offset += cast(i32, sizeof(u32));
    }
    return offset;
}

i32 _sshape_vertex_color_offset(sshape_state_t* state) {
    assert(cast(i64, !state.disable.colors));
    var offset = cast(i32, 3 * sizeof(f32));
    if state.disable.normals == 0 {
        offset += cast(i32, sizeof(u32));
    }
    if state.disable.texcoords == 0 {
        offset += cast(i32, 2 * sizeof(u16));
    }
    return offset;
}

u32 _sshape_vertex_size_from_state(sshape_state_t* state) {
    bool has_normals = !state.disable.normals;
    bool has_texcoords = !state.disable.texcoords;
    bool has_colors = !state.disable.colors;
    return _sshape_vertex_size(has_normals, has_texcoords, has_colors);
}

bool _sshape_validate_state(sshape_state_t* state, u32 num_vertices, u32 num_indices) {
    var vertex_size = _sshape_vertex_size_from_state(state);
    if _sshape_validate_buffer_state(&state.vertices, num_vertices * vertex_size) == 0 {
        return false;
    }
    if _sshape_validate_buffer_state(&state.indices, cast(u32, num_indices * sizeof(u16))) == 0 {
        return false;
    }
    return true;
}

void _sshape_advance_offset(sshape_buffer_state_t* state) {
    state.shape_offset = state.data_size;
}

u16 _sshape_base_index(sshape_state_t* state) {
    u64 vertex_size = _sshape_vertex_size_from_state(state);
    u64 base_index = state.vertices.data_size / vertex_size;
    assert(base_index <= 0xFFFF);
    return cast(u16, base_index);
}

sshape_plane_t _sshape_plane_defaults(sshape_plane_t* params) {
    sshape_plane_t res = *params;
    res.width = res.width == 0.0f ? 1.0f : res.width;
    res.depth = res.depth == 0.0f ? 1.0f : res.depth;
    res.tiles = cast(u16, res.tiles == 0 ? 1 : res.tiles);
    res.color = cast(u32, res.color == 0 ? 0xFFFFFFFF : res.color);
    res.transform = _sshape_mat4_isnull(&res.transform) != 0 ? _sshape_mat4_identity() : res.transform;
    return res;
}

sshape_box_t _sshape_box_defaults(sshape_box_t* params) {
    sshape_box_t res = *params;
    res.width = res.width == 0.0f ? 1.0f : res.width;
    res.height = res.height == 0.0f ? 1.0f : res.height;
    res.depth = res.depth == 0.0f ? 1.0f : res.depth;
    res.tiles = cast(u16, res.tiles == 0 ? 1 : res.tiles);
    res.color = cast(u32, res.color == 0 ? 0xFFFFFFFF : res.color);
    res.transform = _sshape_mat4_isnull(&res.transform) != 0 ? _sshape_mat4_identity() : res.transform;
    return res;
}

sshape_sphere_t _sshape_sphere_defaults(sshape_sphere_t* params) {
    sshape_sphere_t res = *params;
    res.radius = res.radius == 0.0f ? 0.5f : res.radius;
    res.slices = cast(u16, res.slices == 0 ? 5 : res.slices);
    res.stacks = cast(u16, res.stacks == 0 ? 4 : res.stacks);
    res.color = cast(u32, res.color == 0 ? 0xFFFFFFFF : res.color);
    res.transform = _sshape_mat4_isnull(&res.transform) != 0 ? _sshape_mat4_identity() : res.transform;
    return res;
}

sshape_cylinder_t _sshape_cylinder_defaults(sshape_cylinder_t* params) {
    sshape_cylinder_t res = *params;
    res.radius = res.radius == 0.0f ? 0.5f : res.radius;
    res.height = res.height == 0.0f ? 1.0f : res.height;
    res.slices = cast(u16, res.slices == 0 ? 5 : res.slices);
    res.stacks = cast(u16, res.stacks == 0 ? 1 : res.stacks);
    res.color = cast(u32, res.color == 0 ? 0xFFFFFFFF : res.color);
    res.transform = _sshape_mat4_isnull(&res.transform) != 0 ? _sshape_mat4_identity() : res.transform;
    return res;
}

sshape_torus_t _sshape_torus_defaults(sshape_torus_t* params) {
    sshape_torus_t res = *params;
    res.radius = res.radius == 0.0f ? 0.5f : res.radius;
    res.ring_radius = res.ring_radius == 0.0f ? 0.2f : res.ring_radius;
    res.sides = cast(u16, res.sides == 0 ? 5 : res.sides);
    res.rings = cast(u16, res.rings == 0 ? 5 : res.rings);
    res.color = cast(u32, res.color == 0 ? 0xFFFFFFFF : res.color);
    res.transform = _sshape_mat4_isnull(&res.transform) != 0 ? _sshape_mat4_identity() : res.transform;
    return res;
}

void _sshape_add_vertex(sshape_state_t* state, _sshape_vec4_t pos, _sshape_vec4_t norm, _sshape_vec2_t uv, u32 color) {
    u64 offset = state.vertices.data_size;
    u64 vertex_size = _sshape_vertex_size_from_state(state);
    assert(offset + vertex_size <= state.vertices.buffer.size);
    state.vertices.data_size += vertex_size;
    u8* dst_ptr = cast(u8*, state.vertices.buffer.ptr) + offset;
    *cast(f32*, dst_ptr) = pos.x;
    dst_ptr += sizeof(f32);
    *cast(f32*, dst_ptr) = pos.y;
    dst_ptr += sizeof(f32);
    *cast(f32*, dst_ptr) = pos.z;
    dst_ptr += sizeof(f32);
    if state.disable.normals == 0 {
        *cast(u32*, dst_ptr) = _sshape_pack_f4_byte4n(norm.x, norm.y, norm.z, norm.w);
        dst_ptr += sizeof(u32);
    }
    if state.disable.texcoords == 0 {
        *cast(u16*, dst_ptr) = _sshape_pack_f_ushortn(uv.x);
        dst_ptr += sizeof(u16);
        *cast(u16*, dst_ptr) = _sshape_pack_f_ushortn(uv.y);
        dst_ptr += sizeof(u16);
    }
    if state.disable.colors == 0 {
        *cast(u32*, dst_ptr) = color;
        dst_ptr += sizeof(u32);
    }
}

void _sshape_add_triangle(sshape_state_t* state, u16 i0, u16 i1, u16 i2) {
    u64 offset = state.indices.data_size;
    assert(offset + cast(u64, 3 * sizeof(u16)) <= state.indices.buffer.size);
    state.indices.data_size += cast(u64, 3 * sizeof(u16));
    var i_ptr = cast(u16*, cast(u8*, state.indices.buffer.ptr) + offset);
    i_ptr[0] = i0;
    i_ptr[1] = i1;
    i_ptr[2] = i2;
}

u32 _sshape_rand_color(u32* xorshift_state) {
    u32 x = *xorshift_state;
    x ^= x << 13;
    x ^= x >> 17;
    x ^= x << 5;
    *xorshift_state = x;
    x |= 0xFF000000;
    return x;
}
}

/*=== PUBLIC API FUNCTIONS ===================================================*/
u32 sshape_color_4f(f32 r, f32 g, f32 b, f32 a) {
    return _sshape_pack_f4_ubyte4n(_sshape_clamp(r), _sshape_clamp(g), _sshape_clamp(b), _sshape_clamp(a));
}

u32 sshape_color_3f(f32 r, f32 g, f32 b) {
    return _sshape_pack_f4_ubyte4n(_sshape_clamp(r), _sshape_clamp(g), _sshape_clamp(b), 1.0f);
}

u32 sshape_color_4b(u8 r, u8 g, u8 b, u8 a) {
    return _sshape_pack_ub4_ubyte4n(r, g, b, a);
}

u32 sshape_color_3b(u8 r, u8 g, u8 b) {
    return _sshape_pack_ub4_ubyte4n(r, g, b, 255);
}

sshape_mat4_t sshape_mat4(f32* m) {
    noinit sshape_mat4_t res;
    memcpy(&res.m[0][0], &m[0], cast(u64, 64));
    return res;
}

sshape_mat4_t sshape_mat4_transpose(f32* m) {
    noinit sshape_mat4_t res;
    for i32 c = 0; c < 4; c++ {
        for i32 r = 0; r < 4; r++ {
            res.m[r][c] = m[c * 4 + r];
        }
    }
    return res;
}

u64 sshape_vertex_size(sshape_optional_components_t* comps) {
    assert(cast(i64, comps));
    return _sshape_vertex_size(comps.normals, comps.texcoords, comps.colors);
}

sshape_sizes_t sshape_plane_sizes(u32 tiles, u64 vertex_size) {
    assert(tiles >= 1);
    assert(vertex_size >= cast(u64, SSHAPE_MIN_VERTEX_SIZE) && vertex_size <= cast(u64, SSHAPE_MAX_VERTEX_SIZE));
    sshape_sizes_t res;
    res.vertices.num = _sshape_plane_num_vertices(tiles);
    res.indices.num = _sshape_plane_num_indices(tiles);
    res.vertices.size = res.vertices.num * cast(u32, vertex_size);
    res.indices.size = cast(u32, res.indices.num * sizeof(u16));
    return res;
}

sshape_sizes_t sshape_box_sizes(u32 tiles, u64 vertex_size) {
    assert(tiles >= 1);
    assert(vertex_size >= cast(u64, SSHAPE_MIN_VERTEX_SIZE) && vertex_size <= cast(u64, SSHAPE_MAX_VERTEX_SIZE));
    sshape_sizes_t res;
    res.vertices.num = _sshape_box_num_vertices(tiles);
    res.indices.num = _sshape_box_num_indices(tiles);
    res.vertices.size = res.vertices.num * cast(u32, vertex_size);
    res.indices.size = cast(u32, res.indices.num * sizeof(u16));
    return res;
}

sshape_sizes_t sshape_sphere_sizes(u32 slices, u32 stacks, u64 vertex_size) {
    assert(slices >= 3 && stacks >= 2);
    assert(vertex_size >= cast(u64, SSHAPE_MIN_VERTEX_SIZE) && vertex_size <= cast(u64, SSHAPE_MAX_VERTEX_SIZE));
    sshape_sizes_t res;
    res.vertices.num = _sshape_sphere_num_vertices(slices, stacks);
    res.indices.num = _sshape_sphere_num_indices(slices, stacks);
    res.vertices.size = res.vertices.num * cast(u32, vertex_size);
    res.indices.size = cast(u32, res.indices.num * sizeof(u16));
    return res;
}

sshape_sizes_t sshape_cylinder_sizes(u32 slices, u32 stacks, u64 vertex_size) {
    assert(slices >= 3 && stacks >= 1);
    assert(vertex_size >= cast(u64, SSHAPE_MIN_VERTEX_SIZE) && vertex_size <= cast(u64, SSHAPE_MAX_VERTEX_SIZE));
    sshape_sizes_t res;
    res.vertices.num = _sshape_cylinder_num_vertices(slices, stacks);
    res.indices.num = _sshape_cylinder_num_indices(slices, stacks);
    res.vertices.size = res.vertices.num * cast(u32, vertex_size);
    res.indices.size = cast(u32, res.indices.num * sizeof(u16));
    return res;
}

sshape_sizes_t sshape_torus_sizes(u32 sides, u32 rings, u64 vertex_size) {
    assert(sides >= 3 && rings >= 3);
    assert(vertex_size >= cast(u64, SSHAPE_MIN_VERTEX_SIZE) && vertex_size <= cast(u64, SSHAPE_MAX_VERTEX_SIZE));
    sshape_sizes_t res;
    res.vertices.num = _sshape_torus_num_vertices(sides, rings);
    res.indices.num = _sshape_torus_num_indices(sides, rings);
    res.vertices.size = res.vertices.num * cast(u32, vertex_size);
    res.indices.size = cast(u32, res.indices.num * sizeof(u16));
    return res;
}

/*
    Geometry layout for plane (4 tiles):
    +--+--+--+--+
    |\ |\ |\ |\ |
    | \| \| \| \|
    +--+--+--+--+    25 vertices (tiles + 1) * (tiles + 1)
    |\ |\ |\ |\ |    32 triangles (tiles + 1) * (tiles + 1) * 2
    | \| \| \| \|
    +--+--+--+--+
    |\ |\ |\ |\ |
    | \| \| \| \|
    +--+--+--+--+
    |\ |\ |\ |\ |
    | \| \| \| \|
    +--+--+--+--+
*/
void sshape_build_plane(sshape_state_t* state, sshape_plane_t* in_params) {
    assert(state && in_params);
    sshape_plane_t params = _sshape_plane_defaults(in_params);
    u32 num_vertices = _sshape_plane_num_vertices(params.tiles);
    u32 num_indices = _sshape_plane_num_indices(params.tiles);
    if _sshape_validate_state(state, num_vertices, num_indices) == 0 {
        state.valid = false;
        return;
    }
    state.valid = true;
    u16 start_index = _sshape_base_index(state);
    if params.merge == 0 {
        _sshape_advance_offset(&state.vertices);
        _sshape_advance_offset(&state.indices);
    }
    u32 rand_seed = 0x12345678;
    f32 x0 = -params.width * 0.5f;
    f32 z0 = params.depth * 0.5f;
    f32 dx = params.width / cast(f32, params.tiles);
    f32 dz = -params.depth / cast(f32, params.tiles);
    f32 duv = 1.0f / cast(f32, params.tiles);
    _sshape_vec4_t tnorm = _sshape_vec4_norm(_sshape_mat4_mul(&params.transform, _sshape_vec4(0.0f, 1.0f, 0.0f, 0.0f)));
    for u32 ix = 0; ix <= params.tiles; ix++ {
        for u32 iz = 0; iz <= params.tiles; iz++ {
            _sshape_vec4_t pos = _sshape_vec4(x0 + dx * cast(f32, ix), 0.0f, z0 + dz * cast(f32, iz), 1.0f);
            _sshape_vec4_t tpos = _sshape_mat4_mul(&params.transform, pos);
            _sshape_vec2_t uv = _sshape_vec2(duv * cast(f32, ix), duv * cast(f32, iz));
            u32 color = params.random_colors != 0 ? _sshape_rand_color(&rand_seed) : params.color;
            _sshape_add_vertex(state, tpos, tnorm, uv, color);
        }
    }
    for u16 j = 0; j < params.tiles; j++ {
        for u16 i = 0; i < params.tiles; i++ {
            var i0 = cast(u16, start_index + j * (params.tiles + 1) + i);
            var i1 = cast(u16, i0 + 1);
            var i2 = cast(u16, i0 + params.tiles + 1);
            var i3 = cast(u16, i2 + 1);
            _sshape_add_triangle(state, i0, i1, i3);
            _sshape_add_triangle(state, i0, i3, i2);
        }
    }
}

void sshape_build_box(sshape_state_t* state, sshape_box_t* in_params) {
    assert(state && in_params);
    sshape_box_t params = _sshape_box_defaults(in_params);
    u32 num_vertices = _sshape_box_num_vertices(params.tiles);
    u32 num_indices = _sshape_box_num_indices(params.tiles);
    if _sshape_validate_state(state, num_vertices, num_indices) == 0 {
        state.valid = false;
        return;
    }
    state.valid = true;
    u16 start_index = _sshape_base_index(state);
    if params.merge == 0 {
        _sshape_advance_offset(&state.vertices);
        _sshape_advance_offset(&state.indices);
    }
    u32 rand_seed = 0x12345678;
    f32 x0 = -params.width * 0.5f;
    f32 x1 = params.width * 0.5f;
    f32 y0 = -params.height * 0.5f;
    f32 y1 = params.height * 0.5f;
    f32 z0 = -params.depth * 0.5f;
    f32 z1 = params.depth * 0.5f;
    f32 dx = params.width / cast(f32, params.tiles);
    f32 dy = params.height / cast(f32, params.tiles);
    f32 dz = params.depth / cast(f32, params.tiles);
    f32 duv = 1.0f / cast(f32, params.tiles);
    for u32 top_bottom = 0; top_bottom < 2; top_bottom++ {
        _sshape_vec4_t pos = _sshape_vec4(0.0f, 0 == top_bottom ? y0 : y1, 0.0f, 1.0f);
        _sshape_vec4_t norm = _sshape_vec4(0.0f, 0 == top_bottom ? -1.0f : 1.0f, 0.0f, 0.0f);
        _sshape_vec4_t tnorm = _sshape_vec4_norm(_sshape_mat4_mul(&params.transform, norm));
        for u32 ix = 0; ix <= params.tiles; ix++ {
            pos.x = 0 == top_bottom ? x0 + dx * cast(f32, ix) : x1 - dx * cast(f32, ix);
            for u32 iz = 0; iz <= params.tiles; iz++ {
                pos.z = z0 + dz * cast(f32, iz);
                _sshape_vec4_t tpos = _sshape_mat4_mul(&params.transform, pos);
                _sshape_vec2_t uv = _sshape_vec2(cast(f32, ix) * duv, cast(f32, iz) * duv);
                u32 color = params.random_colors != 0 ? _sshape_rand_color(&rand_seed) : params.color;
                _sshape_add_vertex(state, tpos, tnorm, uv, color);
            }
        }
    }
    for u32 left_right = 0; left_right < 2; left_right++ {
        _sshape_vec4_t pos = _sshape_vec4(0 == left_right ? x0 : x1, 0.0f, 0.0f, 1.0f);
        _sshape_vec4_t norm = _sshape_vec4(0 == left_right ? -1.0f : 1.0f, 0.0f, 0.0f, 0.0f);
        _sshape_vec4_t tnorm = _sshape_vec4_norm(_sshape_mat4_mul(&params.transform, norm));
        for u32 iy = 0; iy <= params.tiles; iy++ {
            pos.y = 0 == left_right ? y1 - dy * cast(f32, iy) : y0 + dy * cast(f32, iy);
            for u32 iz = 0; iz <= params.tiles; iz++ {
                pos.z = z0 + dz * cast(f32, iz);
                _sshape_vec4_t tpos = _sshape_mat4_mul(&params.transform, pos);
                _sshape_vec2_t uv = _sshape_vec2(cast(f32, iy) * duv, cast(f32, iz) * duv);
                u32 color = params.random_colors != 0 ? _sshape_rand_color(&rand_seed) : params.color;
                _sshape_add_vertex(state, tpos, tnorm, uv, color);
            }
        }
    }
    for u32 front_back = 0; front_back < 2; front_back++ {
        _sshape_vec4_t pos = _sshape_vec4(0.0f, 0.0f, 0 == front_back ? z0 : z1, 1.0f);
        _sshape_vec4_t norm = _sshape_vec4(0.0f, 0.0f, 0 == front_back ? -1.0f : 1.0f, 0.0f);
        _sshape_vec4_t tnorm = _sshape_vec4_norm(_sshape_mat4_mul(&params.transform, norm));
        for u32 ix = 0; ix <= params.tiles; ix++ {
            pos.x = 0 == front_back ? x1 - dx * cast(f32, ix) : x0 + dx * cast(f32, ix);
            for u32 iy = 0; iy <= params.tiles; iy++ {
                pos.y = y0 + dy * cast(f32, iy);
                _sshape_vec4_t tpos = _sshape_mat4_mul(&params.transform, pos);
                _sshape_vec2_t uv = _sshape_vec2(cast(f32, ix) * duv, cast(f32, iy) * duv);
                u32 color = params.random_colors != 0 ? _sshape_rand_color(&rand_seed) : params.color;
                _sshape_add_vertex(state, tpos, tnorm, uv, color);
            }
        }
    }
    var verts_per_face = cast(u16, (params.tiles + 1) * (params.tiles + 1));
    for u16 face = 0; face < 6; face++ {
        var face_start_index = cast(u16, start_index + face * verts_per_face);
        for u16 j = 0; j < params.tiles; j++ {
            for u16 i = 0; i < params.tiles; i++ {
                var i0 = cast(u16, face_start_index + j * (params.tiles + 1) + i);
                var i1 = cast(u16, i0 + 1);
                var i2 = cast(u16, i0 + params.tiles + 1);
                var i3 = cast(u16, i2 + 1);
                _sshape_add_triangle(state, i0, i1, i3);
                _sshape_add_triangle(state, i0, i3, i2);
            }
        }
    }
}

/*
    Geometry layout for spheres is as follows (for 5 slices, 4 stacks):

    +  +  +  +  +  +        north pole
    |\ |\ |\ |\ |\
    | \| \| \| \| \
    +--+--+--+--+--+        30 vertices (slices + 1) * (stacks + 1)
    |\ |\ |\ |\ |\ |        30 triangles (2 * slices * stacks) - (2 * slices)
    | \| \| \| \| \|        2 orphaned vertices
    +--+--+--+--+--+
    |\ |\ |\ |\ |\ |
    | \| \| \| \| \|
    +--+--+--+--+--+
     \ |\ |\ |\ |\ |
      \| \| \| \| \|
    +  +  +  +  +  +        south pole
*/
void sshape_build_sphere(sshape_state_t* state, sshape_sphere_t* in_params) {
    assert(state && in_params);
    sshape_sphere_t params = _sshape_sphere_defaults(in_params);
    u32 num_vertices = _sshape_sphere_num_vertices(params.slices, params.stacks);
    u32 num_indices = _sshape_sphere_num_indices(params.slices, params.stacks);
    if _sshape_validate_state(state, num_vertices, num_indices) == 0 {
        state.valid = false;
        return;
    }
    state.valid = true;
    u16 start_index = _sshape_base_index(state);
    if params.merge == 0 {
        _sshape_advance_offset(&state.vertices);
        _sshape_advance_offset(&state.indices);
    }
    u32 rand_seed = 0x12345678;
    f32 pi = 3.141592653589793f;
    f32 two_pi = 2.0f * pi;
    f32 du = 1.0f / cast(f32, params.slices);
    f32 dv = 1.0f / cast(f32, params.stacks);
    for u32 stack = 0; stack <= params.stacks; stack++ {
        f32 stack_angle = pi * cast(f32, stack) / cast(f32, params.stacks);
        f32 sin_stack = sinf(stack_angle);
        f32 cos_stack = cosf(stack_angle);
        for u32 slice = 0; slice <= params.slices; slice++ {
            f32 slice_angle = two_pi * cast(f32, slice) / cast(f32, params.slices);
            f32 sin_slice = sinf(slice_angle);
            f32 cos_slice = cosf(slice_angle);
            _sshape_vec4_t norm = _sshape_vec4(-sin_slice * sin_stack, cos_stack, cos_slice * sin_stack, 0.0f);
            _sshape_vec4_t pos = _sshape_vec4(norm.x * params.radius, norm.y * params.radius, norm.z * params.radius, 1.0f);
            _sshape_vec4_t tnorm = _sshape_vec4_norm(_sshape_mat4_mul(&params.transform, norm));
            _sshape_vec4_t tpos = _sshape_mat4_mul(&params.transform, pos);
            _sshape_vec2_t uv = _sshape_vec2(1.0f - cast(f32, slice) * du, 1.0f - cast(f32, stack) * dv);
            u32 color = params.random_colors != 0 ? _sshape_rand_color(&rand_seed) : params.color;
            _sshape_add_vertex(state, tpos, tnorm, uv, color);
        }
    }
    {
        u16 row_a = start_index;
        var row_b = cast(u16, row_a + params.slices + 1);
        for u16 slice = 0; slice < params.slices; slice++ {
            _sshape_add_triangle(state, cast(u16, row_a + slice), cast(u16, row_b + slice), cast(u16, row_b + slice + 1));
        }
    }
    for u16 stack = 1; stack < params.stacks - 1; stack++ {
        var row_a = cast(u16, start_index + stack * (params.slices + 1));
        var row_b = cast(u16, row_a + params.slices + 1);
        for u16 slice = 0; slice < params.slices; slice++ {
            _sshape_add_triangle(state, cast(u16, row_a + slice), cast(u16, row_b + slice + 1), cast(u16, row_a + slice + 1));
            _sshape_add_triangle(state, cast(u16, row_a + slice), cast(u16, row_b + slice), cast(u16, row_b + slice + 1));
        }
    }
    {
        var row_a = cast(u16, start_index + (params.stacks - 1) * (params.slices + 1));
        var row_b = cast(u16, row_a + params.slices + 1);
        for u16 slice = 0; slice < params.slices; slice++ {
            _sshape_add_triangle(state, cast(u16, row_a + slice), cast(u16, row_b + slice + 1), cast(u16, row_a + slice + 1));
        }
    }
}

/*
    Geometry for cylinders is as follows (2 stacks, 5 slices):

    +  +  +  +  +  +
    |\ |\ |\ |\ |\
    | \| \| \| \| \
    +--+--+--+--+--+
    +--+--+--+--+--+    42 vertices (2 wasted) (slices + 1) * (stacks + 5)
    |\ |\ |\ |\ |\ |    30 triangles (2 * slices * stacks) + (2 * slices)
    | \| \| \| \| \|
    +--+--+--+--+--+
    |\ |\ |\ |\ |\ |
    | \| \| \| \| \|
    +--+--+--+--+--+
    +--+--+--+--+--+
     \ |\ |\ |\ |\ |
      \| \| \| \| \|
    +  +  +  +  +  +
*/
private {
void _sshape_build_cylinder_cap_pole(sshape_state_t* state, sshape_cylinder_t* params, f32 pos_y, f32 norm_y, f32 du, f32 v, u32* rand_seed) {
    _sshape_vec4_t tnorm = _sshape_vec4_norm(_sshape_mat4_mul(&params.transform, _sshape_vec4(0.0f, norm_y, 0.0f, 0.0f)));
    _sshape_vec4_t tpos = _sshape_mat4_mul(&params.transform, _sshape_vec4(0.0f, pos_y, 0.0f, 1.0f));
    for u32 slice = 0; slice <= params.slices; slice++ {
        _sshape_vec2_t uv = _sshape_vec2(cast(f32, slice) * du, 1.0f - v);
        u32 color = params.random_colors != 0 ? _sshape_rand_color(rand_seed) : params.color;
        _sshape_add_vertex(state, tpos, tnorm, uv, color);
    }
}

void _sshape_build_cylinder_cap_ring(sshape_state_t* state, sshape_cylinder_t* params, f32 pos_y, f32 norm_y, f32 du, f32 v, u32* rand_seed) {
    f32 two_pi = 2.0f * 3.141592653589793f;
    _sshape_vec4_t tnorm = _sshape_vec4_norm(_sshape_mat4_mul(&params.transform, _sshape_vec4(0.0f, norm_y, 0.0f, 0.0f)));
    for u32 slice = 0; slice <= params.slices; slice++ {
        f32 slice_angle = two_pi * cast(f32, slice) / cast(f32, params.slices);
        f32 sin_slice = sinf(slice_angle);
        f32 cos_slice = cosf(slice_angle);
        _sshape_vec4_t pos = _sshape_vec4(sin_slice * params.radius, pos_y, cos_slice * params.radius, 1.0f);
        _sshape_vec4_t tpos = _sshape_mat4_mul(&params.transform, pos);
        _sshape_vec2_t uv = _sshape_vec2(cast(f32, slice) * du, 1.0f - v);
        u32 color = params.random_colors != 0 ? _sshape_rand_color(rand_seed) : params.color;
        _sshape_add_vertex(state, tpos, tnorm, uv, color);
    }
}
}

void sshape_build_cylinder(sshape_state_t* state, sshape_cylinder_t* in_params) {
    assert(state && in_params);
    sshape_cylinder_t params = _sshape_cylinder_defaults(in_params);
    u32 num_vertices = _sshape_cylinder_num_vertices(params.slices, params.stacks);
    u32 num_indices = _sshape_cylinder_num_indices(params.slices, params.stacks);
    if _sshape_validate_state(state, num_vertices, num_indices) == 0 {
        state.valid = false;
        return;
    }
    state.valid = true;
    u16 start_index = _sshape_base_index(state);
    if params.merge == 0 {
        _sshape_advance_offset(&state.vertices);
        _sshape_advance_offset(&state.indices);
    }
    u32 rand_seed = 0x12345678;
    f32 two_pi = 2.0f * 3.141592653589793f;
    f32 du = 1.0f / cast(f32, params.slices);
    f32 dv = 1.0f / cast(f32, params.stacks + 2);
    f32 y0 = params.height * 0.5f;
    f32 y1 = -params.height * 0.5f;
    f32 dy = params.height / cast(f32, params.stacks);
    _sshape_build_cylinder_cap_pole(state, &params, y0, 1.0f, du, 0.0f, &rand_seed);
    _sshape_build_cylinder_cap_ring(state, &params, y0, 1.0f, du, dv, &rand_seed);
    for u32 stack = 0; stack <= params.stacks; stack++ {
        f32 y = y0 - dy * cast(f32, stack);
        f32 v = dv * cast(f32, stack) + dv;
        for u32 slice = 0; slice <= params.slices; slice++ {
            f32 slice_angle = two_pi * cast(f32, slice) / cast(f32, params.slices);
            f32 sin_slice = sinf(slice_angle);
            f32 cos_slice = cosf(slice_angle);
            _sshape_vec4_t pos = _sshape_vec4(sin_slice * params.radius, y, cos_slice * params.radius, 1.0f);
            _sshape_vec4_t tpos = _sshape_mat4_mul(&params.transform, pos);
            _sshape_vec4_t norm = _sshape_vec4(sin_slice, 0.0f, cos_slice, 0.0f);
            _sshape_vec4_t tnorm = _sshape_vec4_norm(_sshape_mat4_mul(&params.transform, norm));
            _sshape_vec2_t uv = _sshape_vec2(cast(f32, slice) * du, 1.0f - v);
            u32 color = params.random_colors != 0 ? _sshape_rand_color(&rand_seed) : params.color;
            _sshape_add_vertex(state, tpos, tnorm, uv, color);
        }
    }
    _sshape_build_cylinder_cap_ring(state, &params, y1, -1.0f, du, 1.0f - dv, &rand_seed);
    _sshape_build_cylinder_cap_pole(state, &params, y1, -1.0f, du, 1.0f, &rand_seed);
    {
        u16 row_a = start_index;
        var row_b = cast(u16, row_a + params.slices + 1);
        for u16 slice = 0; slice < params.slices; slice++ {
            _sshape_add_triangle(state, cast(u16, row_a + slice), cast(u16, row_b + slice + 1), cast(u16, row_b + slice));
        }
    }
    for u16 stack = 0; stack < params.stacks; stack++ {
        var row_a = cast(u16, start_index + (stack + 2) * (params.slices + 1));
        var row_b = cast(u16, row_a + params.slices + 1);
        for u16 slice = 0; slice < params.slices; slice++ {
            _sshape_add_triangle(state, cast(u16, row_a + slice), cast(u16, row_a + slice + 1), cast(u16, row_b + slice + 1));
            _sshape_add_triangle(state, cast(u16, row_a + slice), cast(u16, row_b + slice + 1), cast(u16, row_b + slice));
        }
    }
    {
        var row_a = cast(u16, start_index + (params.stacks + 3) * (params.slices + 1));
        var row_b = cast(u16, row_a + params.slices + 1);
        for u16 slice = 0; slice < params.slices; slice++ {
            _sshape_add_triangle(state, cast(u16, row_a + slice), cast(u16, row_a + slice + 1), cast(u16, row_b + slice + 1));
        }
    }
}

/*
    Geometry layout for torus (sides = 4, rings = 5):

    +--+--+--+--+--+
    |\ |\ |\ |\ |\ |
    | \| \| \| \| \|
    +--+--+--+--+--+    30 vertices (sides + 1) * (rings + 1)
    |\ |\ |\ |\ |\ |    40 triangles (2 * sides * rings)
    | \| \| \| \| \|
    +--+--+--+--+--+
    |\ |\ |\ |\ |\ |
    | \| \| \| \| \|
    +--+--+--+--+--+
    |\ |\ |\ |\ |\ |
    | \| \| \| \| \|
    +--+--+--+--+--+
*/
void sshape_build_torus(sshape_state_t* state, sshape_torus_t* in_params) {
    assert(state && in_params);
    sshape_torus_t params = _sshape_torus_defaults(in_params);
    u32 num_vertices = _sshape_torus_num_vertices(params.sides, params.rings);
    u32 num_indices = _sshape_torus_num_indices(params.sides, params.rings);
    if _sshape_validate_state(state, num_vertices, num_indices) == 0 {
        state.valid = false;
        return;
    }
    state.valid = true;
    u16 start_index = _sshape_base_index(state);
    if params.merge == 0 {
        _sshape_advance_offset(&state.vertices);
        _sshape_advance_offset(&state.indices);
    }
    u32 rand_seed = 0x12345678;
    f32 two_pi = 2.0f * 3.141592653589793f;
    f32 dv = 1.0f / cast(f32, params.sides);
    f32 du = 1.0f / cast(f32, params.rings);
    for u32 side = 0; side <= params.sides; side++ {
        f32 phi = cast(f32, side) * two_pi / cast(f32, params.sides);
        f32 sin_phi = sinf(phi);
        f32 cos_phi = cosf(phi);
        for u32 ring = 0; ring <= params.rings; ring++ {
            f32 theta = cast(f32, ring) * two_pi / cast(f32, params.rings);
            f32 sin_theta = sinf(theta);
            f32 cos_theta = cosf(theta);
            f32 spx = sin_theta * (params.radius - params.ring_radius * cos_phi);
            f32 spy = sin_phi * params.ring_radius;
            f32 spz = cos_theta * (params.radius - params.ring_radius * cos_phi);
            f32 ipx = sin_theta * params.radius;
            f32 ipy = 0.0f;
            f32 ipz = cos_theta * params.radius;
            _sshape_vec4_t pos = _sshape_vec4(spx, spy, spz, 1.0f);
            _sshape_vec4_t norm = _sshape_vec4(spx - ipx, spy - ipy, spz - ipz, 0.0f);
            _sshape_vec4_t tpos = _sshape_mat4_mul(&params.transform, pos);
            _sshape_vec4_t tnorm = _sshape_vec4_norm(_sshape_mat4_mul(&params.transform, norm));
            _sshape_vec2_t uv = _sshape_vec2(cast(f32, ring) * du, 1.0f - cast(f32, side) * dv);
            u32 color = params.random_colors != 0 ? _sshape_rand_color(&rand_seed) : params.color;
            _sshape_add_vertex(state, tpos, tnorm, uv, color);
        }
    }
    for u16 side = 0; side < params.sides; side++ {
        var row_a = cast(u16, start_index + side * (params.rings + 1));
        var row_b = cast(u16, row_a + params.rings + 1);
        for u16 ring = 0; ring < params.rings; ring++ {
            _sshape_add_triangle(state, cast(u16, row_a + ring), cast(u16, row_a + ring + 1), cast(u16, row_b + ring + 1));
            _sshape_add_triangle(state, cast(u16, row_a + ring), cast(u16, row_b + ring + 1), cast(u16, row_b + ring));
        }
    }
}

sg_buffer_desc sshape_vertex_buffer_desc(sshape_state_t* state) {
    assert(state && state.valid);
    sg_buffer_desc desc;
    if state.valid != 0 {
        desc.usage.vertex_buffer = true;
        desc.usage.immutable = true;
        desc.data.ptr = state.vertices.buffer.ptr;
        desc.data.size = state.vertices.data_size;
    }
    return desc;
}

sg_buffer_desc sshape_index_buffer_desc(sshape_state_t* state) {
    assert(state && state.valid);
    sg_buffer_desc desc;
    if state.valid != 0 {
        desc.usage.index_buffer = true;
        desc.usage.immutable = true;
        desc.data.ptr = state.indices.buffer.ptr;
        desc.data.size = state.indices.data_size;
    }
    return desc;
}

sshape_element_range_t sshape_element_range(sshape_state_t* state) {
    assert(cast(i64, state));
    sshape_element_range_t range;
    if state.valid != 0 {
        assert(state.indices.shape_offset < state.indices.data_size);
        assert(0 == (state.indices.shape_offset & cast(u64, sizeof(u16) - 1)));
        assert(0 == (state.indices.data_size & cast(u64, sizeof(u16) - 1)));
        range.base_element = cast(i32, state.indices.shape_offset / cast(u64, sizeof(u16)));
        range.num_elements = cast(i32, (state.indices.data_size - state.indices.shape_offset) / cast(u64, sizeof(u16)));
    }
    return range;
}

sg_vertex_buffer_layout_state sshape_vertex_buffer_layout_state(sshape_state_t* state) {
    assert(state && state.valid);
    sg_vertex_buffer_layout_state layout_state;
    layout_state.stride = cast(i32, _sshape_vertex_size_from_state(state));
    return layout_state;
}

sg_vertex_attr_state sshape_position_vertex_attr_state(sshape_state_t* state) {
    assert(state && state.valid);
    sg_vertex_attr_state attr_state;
    attr_state.offset = _sshape_vertex_position_offset(state);
    attr_state.format = SG_VERTEXFORMAT_FLOAT3;
    return attr_state;
}

sg_vertex_attr_state sshape_normal_vertex_attr_state(sshape_state_t* state) {
    assert(state && state.valid);
    sg_vertex_attr_state attr_state;
    if state.disable.normals == 0 {
        attr_state.offset = _sshape_vertex_normal_offset(state);
        attr_state.format = SG_VERTEXFORMAT_BYTE4N;
    }
    return attr_state;
}

sg_vertex_attr_state sshape_texcoord_vertex_attr_state(sshape_state_t* state) {
    assert(state && state.valid);
    sg_vertex_attr_state attr_state;
    if state.disable.texcoords == 0 {
        attr_state.offset = _sshape_vertex_texcoord_offset(state);
        attr_state.format = SG_VERTEXFORMAT_USHORT2N;
    }
    return attr_state;
}

sg_vertex_attr_state sshape_color_vertex_attr_state(sshape_state_t* state) {
    assert(state && state.valid);
    sg_vertex_attr_state attr_state;
    if state.disable.colors == 0 {
        attr_state.offset = _sshape_vertex_color_offset(state);
        attr_state.format = SG_VERTEXFORMAT_UBYTE4N;
    }
    return attr_state;
}

