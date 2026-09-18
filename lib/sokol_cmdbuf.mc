// sokol_cmdbuf : transpiled from sokol_cmdbuf.h
import sokol_all;

// transminc: C stdlib constants referenced by source
const u32 UINT32_MAX = 4294967295;

enum __enum_SCB_INVALID_ID {
    SCB_INVALID_ID = 0,
}

/*
    scb_resource_state

    The state of a command buffer object, obtainable via scb_query_cmdbuf_state().
    Publicly visible values are only SCB_RESOURCESTATE_VALID,
    SCB_RESOURCESTATE_FAILED and SCB_RESOURCESTATE_INVALID.
*/
enum scb_resource_state {
    SCB_RESOURCESTATE_INITIAL = 0,
    SCB_RESOURCESTATE_ALLOC = 1,
    SCB_RESOURCESTATE_VALID = 2,
    SCB_RESOURCESTATE_FAILED = 3,
    SCB_RESOURCESTATE_INVALID = 4,
    _SCB_RESOURCESTATE_FORCE_U32 = 2147483647,
}

/*
    scb_log_item

    Log items are defined via X-Macro, expanded into an enum scb_log_item
    and (in debug-mode only also to human readable strings).

    Used as parameter to the logging callback.
*/
enum scb_log_item {
    SCB_LOGITEM_OK = 0,
    SCB_LOGITEM_MALLOC_FAILED = 1,
    SCB_LOGITEM_CMDBUF_POOL_EXHAUSTED = 2,
    SCB_LOGITEM_CMDBUF_OVERFLOW = 3,
    SCB_LOGITEM_CMDBUF_NOT_VALID = 4,
    SCB_LOGITEM_SUBMIT_CMDBUF_OVERFLOWN = 5,
    SCB_LOGITEM_SUBMIT_INVALID_COMMAND = 6,
}

// >>structs
enum _scb_cmd_t {
    _SCB_CMD_NONE = 0,
    _SCB_CMD_APPLY_VIEWPORT = 1,
    _SCB_CMD_APPLY_SCISSOR_RECT = 2,
    _SCB_CMD_APPLY_PIPELINE = 3,
    _SCB_CMD_APPLY_BINDINGS = 4,
    _SCB_CMD_APPLY_UNIFORMS = 5,
    _SCB_CMD_DRAW = 6,
    _SCB_CMD_DRAW_EX = 7,
    _SCB_CMD_DISPATCH = 8,
}

/*
    scb_cmdbuf

    A command buffer handle created with scb_make_cmdbuf().
*/
struct scb_cmdbuf {
    u32 id;
}

/*
    scb_cmdbuf_desc

    Creation parameters of a command buffer object. Used
    in scb_make_cmdbuf().

    See doc section ESTIMATING COMMAND BUFFER SIZES about
    how command buffer size can be estimated.

    When a label is set, sokol_cmdbuf.h will wrap
    submitted commands with `sg_push/pop_debug_group()`.
*/
struct scb_cmdbuf_desc {
    u64 size;
    u8* label;
}

/*
    scb_cmdbuf_info

    Result of scb_query_cmdbuf_info.
*/
struct scb_cmdbuf_info {
    u64 size;
    u64 remaining;
    bool overflown;
}

/*
    scb_logger

    Used in scb_desc to provide a custom logging and error reporting
    callback to sokol_cmdbuf.h
*/
struct scb_logger {
    fn(u8*, u32, u32, u8*, u32, u8*, void*): void func;
    void* user_data;
}

/*
    scb_allocator

    Used in scb_desc to provide custom memory-alloc and -free functions
    to sokol_cmdbuf.h. If memory management should be overridden, both the
    alloc_fn and free_fn function must be provided (e.g. it's not valid to
    override one function but not the other).
*/
struct scb_allocator {
    fn(u64, void*): void* alloc_fn;
    fn(void*, void*): void free_fn;
    void* user_data;
}

/*
    scb_desc

    Initialization options passed into scb_setup.
*/
struct scb_desc {
    i32 cmdbuf_pool_size;
    scb_allocator allocator;
    scb_logger logger;
}

struct _scb_slot_t {
    u32 id;
    scb_resource_state state;
}

struct _scb_pool_t {
    i32 size;
    i32 queue_top;
    u32* gen_ctrs;
    i32* free_queue;
}

struct _scb_str_t {
    u8[32] buf;
}

struct _scb_cmdbuf_t {
    _scb_slot_t slot;
    u8* buf;
    u8* cur;
    u8* end;
    u8* cmd_max_end;
    bool overflown;
    _scb_str_t label;
}

struct _scb_pools_t {
    _scb_pool_t cmdbuf_pool;
    _scb_cmdbuf_t* cmdbufs;
}

struct _scb_t {
    u32 init_tag;
    scb_desc desc;
    _scb_pools_t pools;
}

/*
    sokol_cmdbuf.h  - a software command buffer for sokol_gfx.h

    Project URL: https://github.com/floooh/sokol

    Do this:
        #define SOKOL_IMPL or
        #define SOKOL_CMDBUF_IMPL
    before you include this file in *one* C or C++ file to create the
    implementation.

    ...optionally provide the following macros to override defaults:

    SOKOL_ASSERT(c)     - your own assert macro (default: assert(c))
    SOKOL_CMDBUF_API_DECL   - public function declaration prefix (default: extern)
    SOKOL_API_DECL      - same as SOKOL_CMDBUF_API_DECL
    SOKOL_API_IMPL      - public function implementation prefix (default: -)
    SOKOL_UNREACHABLE() - a guard macro for unreachable code (default: assert(false))

    If sokol_cmdbuf.h is compiled as a DLL, define the following before
    including the declaration or implementation:

    SOKOL_DLL

    On Windows, SOKOL_DLL will define SOKOL_CMDBUF_API_DECL as __declspec(dllexport)
    or __declspec(dllimport) as needed.

    Include the following headers before including sokol_cmdbuf.h:

        sokol_gfx.h


    OVERVIEW
    ========
    Allows to record sokol-gfx apply/draw/dispatch calls into command buffers
    outside of sokol-gfx passes and then submit the recorded calls inside
    sokol-gfx render or compute passes. This is mainly useful in two situations:

    - Interleaving resource updates and draw calls (e.g. append
      data to buffers and then immediately issue a draw/dispatch call which
      uses this data). Such an interleaved update/consume model cannot be
      implemented efficiently in some sokol-gfx backends and is disallowed in
      the 'new' write-transient/persistent update model.
    - Separating the core frame rendering code from code that's normally
      not concerned about rendering (e.g. UI or debug rendering).

    Some 'tier 2' sokol headers already use a similar record/replay
    system internally (e.g. sokol_gl.h, sokol_debugtext.h, sokol_spine.h)
    and will switch to using sokol_cmdbuf.h to reduce redundant code.

    STEP BY STEP:
    =============

    - Initialize sokol_cmdbuf.h, provide at least a logging function
      (for instance slog_func from sokol_log.h), otherwise you won't
      see any logging output:

        scb_setup(&(scb_desc){
            .logger.func = slog_func,
        });

      If you need more than (the default) 16 command buffers to be alive at
      the same time, set the .cmdbuf_pool_size:

        scb_setup(&(scb_desc){
            .cmdbuf_pool_size = 128,
            .logger.func = slog_func,
        });

      To provide your own memory allocation functions:

        void* my_alloc(size_t size, void* user_data) {
            return malloc(size);
        }

        void my_free(void* ptr, void* user_data) {
            free(ptr);
        }

        scb_setup(&(scb_desc){
            .allocator = {
                .alloc_fn = my_alloc,
                .free_fn = my_free,
                .user_data = ...,
            },
            .logger.func = slog_func,
        });

    - Next create command buffer objects, the default command buffer size
      is 256 kbytes:

        scb_cmdbuf cb = scb_make_cmdbuf(&(scb_cmdbuf_desc){0});

      It often makes sense to provide a specific size in bytes:

        scb_cmdbuf cb = scb_make_cmdbuf(&(scb_cmdbuf_desc){
            .size = 128 * 1024,     // 128 kbytes
        });

      For information on how to estimate the required size see the section
      'ESTIMATING COMMAND BUFFER SIZES' below.

      You can provide a label string for the command buffer:

        scb_cmdbuf cb = scb_make_cmdbuf(&(scb_cmdbuf_desc){
            .label = "dbg-physics",
        });

      When a label string exists, sokol_cmdbuf.h will wrap submitted commands
      with `sg_push_debug_group(label)` / `sg_pop_debug_group()`

    - Record apply/draw/dispatch commands into a command buffer object
      (note that these functions directly use sokol_gfx.h types):

        scb_apply_viewport(cb, x, y, width, height, origin_top_left);
        scb_apply_viewportf(cb, x, y, width, height, origin_top_left);

        scb_apply_scissor_rect(cb, x, y, width, height, origin_top_left);
        scb_apply_scissor_rectf(cb, x, y, width, height, origin_top_left);

        scb_apply_pipeline(cb, pip);
        scb_apply_bindings(cb, &(sg_bindings){ ... });
        scb_apply_uniforms(cb, ub_slot, &(sg_range){ ... });
        scb_draw(cb, base_element, num_elements, num_instances);
        scb_draw_ex(cb, base_element, num_elements, num_instances, base_vertex, base_instance);
        scb_dispatch(cb, num_groups_x, num_groups_y, num_groups_z);

      Uniform data will be copied into the command buffer, and with the
      required alignment.

      Trying to record more data than fits into the command buffer will
      result in a logged error message, and the command buffer to
      go into an 'overflown' state. Submitting an overflown command buffer
      will only rewind the command buffer but not issue the partially recorded
      commands to sokol-gfx.

    - Finally, inside a sokol-gfx render- or compute-pass, submit the
      command buffer. This will decode the recorded commands and call
      sokol-gfx functions:

        sg_begin_pass(...);
        // ...
        scb_submit(cb);
        // ...
        sg_end_pass();

      Submitting a command buffer will also automatically rewind, so that the
      command buffer can be reused for recording new commands.

    - To rewind a recorded command buffer without submitting, call:

        scb_reset(cb)

    - To get current information about a command buffer:

        scb_cmdbuf_info info = scb_query_cmdbuf_info(cb);

      The result contains:

        info.size       the command buffer size in bytes
        info.remaining  the currently remaining number of free bytes in the command buffer
        info.overflown  true when the command buffer is currently in overflown state

    - To get a command buffer's 'resource state', call:

        scb_resource_state state = scb_query_cmdbuf_state(cb);

      This returns one of:

        SCB_RESOURCESTATE_VALID:    the command buffer is valid to use
        SCB_RESOURCESTATE_FAILED:   command buffer allocation has failed
                                    (can only happen when memory allocation failed)
        SCB_RESOURCESTATE_INVALID   the handle is invalid or the command buffer
                                    no longer exists

    - To destroy a command buffer object:

        scb_destroy_cmdbuf(cb);

    - ...and finally to shutdown sokol_cmdbuf.h:

        scb_shutdown();

      ...this will also destroy all remaining command buffer objects.


    ESTIMATING COMMAND BUFFER SIZES
    ===============================

    For most commands, the size taken up in the command buffer can be
    estimated by adding the parameter sizes plus one byte for the
    command, e.g.:

    scb_apply_viewport takes 4 integers and one boolean:

        1 byte for the command
        + (4 * 4) bytes for the integers
        + 1 byte for the boolean

    There are two special cases:

    - scb_apply_uniforms copies the actual uniform data with 4-byte
        alignment into the command buffer, the required size is:

        1 byte for the command
        + 4 bytes for ub_slot
        + 4 bytes for the uniform data size (truncated from size_t)
        + up to 3 bytes 'alignment gap'
        + the actual uniform data

    - scb_apply_bindings applies a simple form of compression by
      not writing unoccupied bind slots. Instead a 64-bit bitmask identifies
      occupied slots:

        1 byte for the command
        + 8 bytes for the 64-bit occupation bitmask
        + 4 bytes for each valid sg_buffer, sg_view, sg_sampler
          handle in the sg_bindings struct
        + 4 bytes extra for the buffer offset of each occupied vertex buffer slot
        + 4 bytes extra for the index buffer offset if the index buffer slot is occupied

      ...or just assume around 256 bytes worst case for an scb_apply_bindings call


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
//------------------------------------------------------------------------------
// >>implementation
when !(defined(SOKOL_DEBUG)) {
}
private {
_scb_t _scb;
// >>logging
u8*[7] _scb_log_messages = {
    "OK: Ok", "MALLOC_FAILED: memory allocation failed",
    "CMDBUF_POOL_EXHAUSTED: command buffer pool is exhausted (hint: increase scb_desc.cmdbuf_pool_size)",
    "CMDBUF_OVERFLOW: command buffer has overflown",
    "CMDBUF_NOT_VALID: command buffer no longer exists or invalid handle",
    "SUBMIT_CMDBUF_OVERFLOWN: scb_submit: command buffer was overflown",
    "SUBMIT_INVALID_COMMAND: scb_submit: invalid command (command buffer corrupted?)",
};

void _scb_log(scb_log_item log_item, u32 log_level, u32 line_nr) {
    if _scb.desc.logger.func != null {
        u8* filename = __file__;
        u8* message = _scb_log_messages[log_item];
        _scb.desc.logger.func("scb", log_level, cast(u32, log_item), message, line_nr, filename, _scb.desc.logger.user_data);
    } else {
        if log_level == 0 {
            abort();
        }
    }
}

// >>memory
void _scb_clear(void* ptr, u64 size) {
    assert(ptr && size > 0);
    memset(ptr, 0, size);
}

void* _scb_malloc(u64 size) {
    assert(size > 0);
    void* ptr;
    if _scb.desc.allocator.alloc_fn != null {
        ptr = _scb.desc.allocator.alloc_fn(size, _scb.desc.allocator.user_data);
    } else {
        ptr = alloc(cast(i64, size));
    }
    if null == ptr {
        _scb_log(SCB_LOGITEM_MALLOC_FAILED, 1, __line__);
    }
    return ptr;
}

void* _scb_malloc_clear(u64 size) {
    void* ptr = _scb_malloc(size);
    if ptr != null {
        _scb_clear(ptr, size);
    }
    return ptr;
}

void _scb_free(void* ptr) {
    if _scb.desc.allocator.free_fn != null {
        _scb.desc.allocator.free_fn(ptr, _scb.desc.allocator.user_data);
    } else {
        free(ptr);
    }
}

void _scb_strcpy(_scb_str_t* dst, u8* src) {
    assert(cast(i64, dst));
    if src != null {
        strncpy(dst.buf, src, cast(u64, 32));
        dst.buf[32 - 1] = 0;
    } else {
        _scb_clear(dst.buf, 32);
    }
}

// >>pool
void _scb_pool_init(_scb_pool_t* pool, i32 num) {
    assert(pool && num >= 1);
    pool.size = num + 1;
    pool.queue_top = 0;
    u64 gen_ctrs_size = cast(u64, sizeof(u32)) * cast(u64, pool.size);
    pool.gen_ctrs = cast(u32*, _scb_malloc_clear(gen_ctrs_size));
    assert(cast(i64, pool.gen_ctrs));
    pool.free_queue = cast(i32*, _scb_malloc_clear(cast(u64, sizeof(i32)) * cast(u64, num)));
    assert(cast(i64, pool.free_queue));
    for i32 i = pool.size - 1; i >= 1; i-- {
        pool.free_queue[pool.queue_top++] = i;
    }
}

void _scb_pool_discard(_scb_pool_t* pool) {
    assert(cast(i64, pool));
    assert(cast(i64, pool.free_queue));
    _scb_free(pool.free_queue);
    pool.free_queue = null;
    assert(cast(i64, pool.gen_ctrs));
    _scb_free(pool.gen_ctrs);
    pool.gen_ctrs = null;
    pool.size = 0;
    pool.queue_top = 0;
}

i32 _scb_pool_alloc_index(_scb_pool_t* pool) {
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

void _scb_pool_free_index(_scb_pool_t* pool, i32 slot_index) {
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

void _scb_setup_pools(_scb_pools_t* p, scb_desc* desc) {
    assert(cast(i64, p));
    assert(cast(i64, desc));
    assert(desc.cmdbuf_pool_size > 0 && desc.cmdbuf_pool_size < 1 << 16);
    _scb_pool_init(&p.cmdbuf_pool, desc.cmdbuf_pool_size);
    u64 cb_pool_byte_size = cast(u64, sizeof(_scb_cmdbuf_t)) * cast(u64, p.cmdbuf_pool.size);
    p.cmdbufs = cast(_scb_cmdbuf_t*, _scb_malloc_clear(cb_pool_byte_size));
    assert(cast(i64, p.cmdbufs));
}

void _scb_discard_pools(_scb_pools_t* p) {
    assert(cast(i64, p));
    assert(cast(i64, p.cmdbufs));
    _scb_free(p.cmdbufs);
    p.cmdbufs = null;
    _scb_pool_discard(&p.cmdbuf_pool);
}

/* allocate the slot at slot_index:
    - bump the slot's generation counter
    - create a resource id from the generation counter and slot index
    - set the slot's id to this id
    - set the slot's state to ALLOC
    - return the resource id
*/
u32 _scb_slot_alloc(_scb_pool_t* pool, _scb_slot_t* slot, i32 slot_index) {
    assert(pool && pool.gen_ctrs);
    assert(slot_index > 0 && slot_index < pool.size);
    assert(slot.id == cast(u32, SCB_INVALID_ID));
    assert(slot.state == SCB_RESOURCESTATE_INITIAL);
    u32 ctr = ++pool.gen_ctrs[slot_index];
    slot.id = ctr << 16 | cast(u32, slot_index & (1 << 16) - 1);
    slot.state = SCB_RESOURCESTATE_ALLOC;
    return slot.id;
}

// extract slot index from id
i32 _scb_slot_index(u32 id) {
    var slot_index = cast(i32, id & cast(u32, (1 << 16) - 1));
    assert(0 != slot_index);
    return slot_index;
}

// get cmdbuf pointer without id-check
_scb_cmdbuf_t* _scb_cmdbuf_at(u32 cb_id) {
    assert(cast(u32, SCB_INVALID_ID) != cb_id);
    i32 slot_index = _scb_slot_index(cb_id);
    assert(slot_index > 0 && slot_index < _scb.pools.cmdbuf_pool.size);
    return &_scb.pools.cmdbufs[slot_index];
}

// get cmdbuf pointer with id-check, returns 0 if no match
_scb_cmdbuf_t* _scb_lookup_cmdbuf(u32 cb_id) {
    if cast(u32, SCB_INVALID_ID) != cb_id {
        _scb_cmdbuf_t* cb = _scb_cmdbuf_at(cb_id);
        if cb.slot.id == cb_id {
            return cb;
        }
    }
    return null;
}

// make cmdbuf handle from raw uint32_t id
scb_cmdbuf _scb_make_cmdbuf_id(u32 cb_id) {
    noinit scb_cmdbuf cb;
    cb.id = cb_id;
    return cb;
}

scb_cmdbuf _scb_alloc_cmdbuf() {
    noinit scb_cmdbuf cb_id;
    i32 slot_index = _scb_pool_alloc_index(&_scb.pools.cmdbuf_pool);
    if 0 != slot_index {
        cb_id = _scb_make_cmdbuf_id(_scb_slot_alloc(&_scb.pools.cmdbuf_pool, &_scb.pools.cmdbufs[slot_index].slot, slot_index));
    } else {
        _scb_log(SCB_LOGITEM_CMDBUF_POOL_EXHAUSTED, 1, __line__);
        cb_id = _scb_make_cmdbuf_id(cast(u32, SCB_INVALID_ID));
    }
    return cb_id;
}

void _scb_dealloc_cmdbuf(_scb_cmdbuf_t* cb) {
    assert(cb && cb.slot.state == SCB_RESOURCESTATE_ALLOC && cb.slot.id != cast(u32, SCB_INVALID_ID));
    _scb_pool_free_index(&_scb.pools.cmdbuf_pool, _scb_slot_index(cb.slot.id));
    _scb_clear(cb, cast(u64, sizeof(_scb_cmdbuf_t)));
}

void _scb_init_cmdbuf(_scb_cmdbuf_t* cb, scb_cmdbuf_desc* desc) {
    assert(cb && cb.slot.state == SCB_RESOURCESTATE_ALLOC);
    assert(cast(i64, desc));
    assert(desc.size > 0);
    cb.buf = _scb_malloc(desc.size);
    if null == cb.buf {
        cb.slot.state = SCB_RESOURCESTATE_FAILED;
        return;
    }
    cb.cur = cb.buf;
    cb.end = cb.buf + desc.size;
    _scb_strcpy(&cb.label, desc.label);
    cb.slot.state = SCB_RESOURCESTATE_VALID;
}

void _scb_uninit_cmdbuf(_scb_cmdbuf_t* cb) {
    assert(cb && (cb.slot.state == SCB_RESOURCESTATE_VALID || cb.slot.state == SCB_RESOURCESTATE_FAILED));
    if cb.buf != null {
        _scb_free(cb.buf);
        cb.buf = null;
        cb.cur = null;
        cb.end = null;
    }
    cb.slot.state = SCB_RESOURCESTATE_ALLOC;
}

scb_desc _scb_desc_defaults(scb_desc* desc) {
    assert(cast(i64, desc));
    scb_desc res = *desc;
    res.cmdbuf_pool_size = res.cmdbuf_pool_size == 0 ? 16 : res.cmdbuf_pool_size;
    return res;
}

scb_cmdbuf_desc _scb_cmdbuf_desc_defaults(scb_cmdbuf_desc* desc) {
    assert(cast(i64, desc));
    scb_cmdbuf_desc res = *desc;
    res.size = cast(u64, res.size == 0 ? 262144 : res.size);
    return res;
}

void _scb_discard_all_resources() {
    for i32 i = 1; i < _scb.pools.cmdbuf_pool.size; i++ {
        scb_resource_state state = _scb.pools.cmdbufs[i].slot.state;
        if state == SCB_RESOURCESTATE_VALID || state == SCB_RESOURCESTATE_FAILED {
            _scb_uninit_cmdbuf(&_scb.pools.cmdbufs[i]);
        }
    }
}

bool _scb_cmdbuf_valid(_scb_cmdbuf_t* cb) {
    return cb && cb.slot.state == SCB_RESOURCESTATE_VALID;
}

void _scb_enc_u8(_scb_cmdbuf_t* cb, u8 val) {
    assert(cb.cur + sizeof(u8) <= cb.end);
    *cb.cur++ = val;
}

void _scb_enc_bool(_scb_cmdbuf_t* cb, bool val) {
    assert(cb.cur + sizeof(u8) <= cb.end);
    *cb.cur++ = cast(u8, val);
}

u8* _scb_dec_bool(u8* ptr, bool* out_val) {
    *out_val = cast(bool, *ptr++);
    return ptr;
}

void _scb_enc_i32(_scb_cmdbuf_t* cb, i32 val) {
    assert(cb.cur + sizeof(i32) <= cb.end);
    cb.cur[0] = cast(u8, val);
    cb.cur[1] = cast(u8, val >> 8);
    cb.cur[2] = cast(u8, val >> 16);
    cb.cur[3] = cast(u8, val >> 24);
    cb.cur += sizeof(i32);
}

u8* _scb_dec_i32(u8* ptr, i32* out_val) {
    *out_val = cast(i32, cast(u32, ptr[0]) | cast(u32, ptr[1]) << 8 | cast(u32, ptr[2]) << 16 | cast(u32, ptr[3]) << 24);
    return ptr + sizeof(i32);
}

void _scb_enc_u32(_scb_cmdbuf_t* cb, u32 val) {
    assert(cb.cur + sizeof(u32) <= cb.end);
    cb.cur[0] = cast(u8, val);
    cb.cur[1] = cast(u8, val >> 8);
    cb.cur[2] = cast(u8, val >> 16);
    cb.cur[3] = cast(u8, val >> 24);
    cb.cur += sizeof(u32);
}

u8* _scb_dec_u32(u8* ptr, u32* out_val) {
    *out_val = cast(u32, ptr[0]) | cast(u32, ptr[1]) << 8 | cast(u32, ptr[2]) << 16 | cast(u32, ptr[3]) << 24;
    return ptr + sizeof(u32);
}

void _scb_enc_u64(_scb_cmdbuf_t* cb, u64 val) {
    assert(cb.cur + sizeof(u64) <= cb.end);
    cb.cur[0] = cast(u8, val);
    cb.cur[1] = cast(u8, val >> 8);
    cb.cur[2] = cast(u8, val >> 16);
    cb.cur[3] = cast(u8, val >> 24);
    cb.cur[4] = cast(u8, val >> 32);
    cb.cur[5] = cast(u8, val >> 40);
    cb.cur[6] = cast(u8, val >> 48);
    cb.cur[7] = cast(u8, val >> 56);
    cb.cur += sizeof(u64);
}

u8* _scb_dec_u64(u8* ptr, u64* out_val) {
    *out_val = cast(u64, ptr[0]) | cast(u64, ptr[1]) << 8 | cast(u64, ptr[2]) << 16 | cast(u64, ptr[3]) << 24 | cast(u64, ptr[4]) << 32 | cast(u64, ptr[5]) << 40 | cast(u64, ptr[6]) << 48 | cast(u64, ptr[7]) << 56;
    return ptr + sizeof(u64);
}

void _scb_enc_blob(_scb_cmdbuf_t* cb, void* ptr, u64 size) {
    assert(cb.cur + size <= cb.end);
    memcpy(cb.cur, ptr, size);
    cb.cur += size;
}

u8* _scb_ptr_align4(u8* ptr) {
    var align_minus_one = cast(u64, 4 - 1);
    u64 mask = ~align_minus_one;
    return cast(u8*, cast(u64, ptr) + align_minus_one & mask);
}

void _scb_enc_align4(_scb_cmdbuf_t* cb) {
    var ptr = _scb_ptr_align4(cb.cur);
    assert(ptr >= cb.cur && ptr <= cb.end);
    for ; cb.cur < ptr; cb.cur++ {
        *cb.cur = 0;
    }
}

u8* _scb_dec_align4(u8* ptr) {
    return _scb_ptr_align4(ptr);
}

bool _scb_enc_cmd(_scb_cmdbuf_t* cb, _scb_cmd_t cmd, u64 max_payload_size) {
    assert(cb.cmd_max_end == null);
    if cb.overflown != 0 {
        return false;
    }
    u64 max_cmd_payload_size = max_payload_size + 1;
    if cb.cur + max_cmd_payload_size > cb.end {
        cb.overflown = true;
        _scb_log(SCB_LOGITEM_CMDBUF_OVERFLOW, 1, __line__);
        return false;
    }
    cb.cmd_max_end = cb.cur + max_cmd_payload_size;
    _scb_enc_u8(cb, cast(u8, cmd));
    return true;
}

u8* _scb_dec_cmd(u8* ptr, _scb_cmd_t* out_cmd) {
    *out_cmd = cast(_scb_cmd_t, *ptr++);
    return ptr;
}

void _scb_enc_end(_scb_cmdbuf_t* cb) {
    assert(cb.cmd_max_end && cb.cur <= cb.cmd_max_end);
    cb.cmd_max_end = null;
}

void _scb_enc_apply_viewport(_scb_cmdbuf_t* cb, i32 x, i32 y, i32 width, i32 height, bool origin_top_left) {
    var payload_size = cast(u64, 4 * sizeof(i32) + sizeof(u8));
    if _scb_enc_cmd(cb, _SCB_CMD_APPLY_VIEWPORT, payload_size) != 0 {
        _scb_enc_i32(cb, x);
        _scb_enc_i32(cb, y);
        _scb_enc_i32(cb, width);
        _scb_enc_i32(cb, height);
        _scb_enc_bool(cb, origin_top_left);
        _scb_enc_end(cb);
    }
}

u8* _scb_dec_apply_viewport(u8* ptr) {
    i32 x;
    i32 y;
    i32 width;
    i32 height;
    bool origin_top_left;
    ptr = _scb_dec_i32(ptr, &x);
    ptr = _scb_dec_i32(ptr, &y);
    ptr = _scb_dec_i32(ptr, &width);
    ptr = _scb_dec_i32(ptr, &height);
    ptr = _scb_dec_bool(ptr, &origin_top_left);
    sg_apply_viewport(x, y, width, height, origin_top_left);
    return ptr;
}

void _scb_enc_apply_scissor_rect(_scb_cmdbuf_t* cb, i32 x, i32 y, i32 width, i32 height, bool origin_top_left) {
    var payload_size = cast(u64, 4 * sizeof(i32) + sizeof(u8));
    if _scb_enc_cmd(cb, _SCB_CMD_APPLY_SCISSOR_RECT, payload_size) != 0 {
        _scb_enc_i32(cb, x);
        _scb_enc_i32(cb, y);
        _scb_enc_i32(cb, width);
        _scb_enc_i32(cb, height);
        _scb_enc_bool(cb, origin_top_left);
        _scb_enc_end(cb);
    }
}

u8* _scb_dec_apply_scissor_rect(u8* ptr) {
    i32 x;
    i32 y;
    i32 width;
    i32 height;
    bool origin_top_left;
    ptr = _scb_dec_i32(ptr, &x);
    ptr = _scb_dec_i32(ptr, &y);
    ptr = _scb_dec_i32(ptr, &width);
    ptr = _scb_dec_i32(ptr, &height);
    ptr = _scb_dec_bool(ptr, &origin_top_left);
    sg_apply_scissor_rect(x, y, width, height, origin_top_left);
    return ptr;
}

void _scb_enc_apply_pipeline(_scb_cmdbuf_t* cb, u32 pip_id) {
    var payload_size = cast(u64, sizeof(u32));
    if _scb_enc_cmd(cb, _SCB_CMD_APPLY_PIPELINE, payload_size) != 0 {
        _scb_enc_u32(cb, pip_id);
        _scb_enc_end(cb);
    }
}

u8* _scb_dec_apply_pipeline(u8* ptr) {
    noinit sg_pipeline pip;
    ptr = _scb_dec_u32(ptr, &pip.id);
    sg_apply_pipeline(pip);
    return ptr;
}

void _scb_enc_draw(_scb_cmdbuf_t* cb, i32 base_element, i32 num_elements, i32 num_instances) {
    var payload_size = cast(u64, 3 * sizeof(i32));
    if _scb_enc_cmd(cb, _SCB_CMD_DRAW, payload_size) != 0 {
        _scb_enc_i32(cb, base_element);
        _scb_enc_i32(cb, num_elements);
        _scb_enc_i32(cb, num_instances);
        _scb_enc_end(cb);
    }
}

u8* _scb_dec_draw(u8* ptr) {
    i32 base_element;
    i32 num_elements;
    i32 num_instances;
    ptr = _scb_dec_i32(ptr, &base_element);
    ptr = _scb_dec_i32(ptr, &num_elements);
    ptr = _scb_dec_i32(ptr, &num_instances);
    sg_draw(base_element, num_elements, num_instances);
    return ptr;
}

void _scb_enc_draw_ex(_scb_cmdbuf_t* cb, i32 base_element, i32 num_elements, i32 num_instances, i32 base_vertex, i32 base_instance) {
    var payload_size = cast(u64, 5 * sizeof(i32));
    if _scb_enc_cmd(cb, _SCB_CMD_DRAW_EX, payload_size) != 0 {
        _scb_enc_i32(cb, base_element);
        _scb_enc_i32(cb, num_elements);
        _scb_enc_i32(cb, num_instances);
        _scb_enc_i32(cb, base_vertex);
        _scb_enc_i32(cb, base_instance);
        _scb_enc_end(cb);
    }
}

u8* _scb_dec_draw_ex(u8* ptr) {
    i32 base_element;
    i32 num_elements;
    i32 num_instances;
    i32 base_vertex;
    i32 base_instance;
    ptr = _scb_dec_i32(ptr, &base_element);
    ptr = _scb_dec_i32(ptr, &num_elements);
    ptr = _scb_dec_i32(ptr, &num_instances);
    ptr = _scb_dec_i32(ptr, &base_vertex);
    ptr = _scb_dec_i32(ptr, &base_instance);
    sg_draw_ex(base_element, num_elements, num_instances, base_vertex, base_instance);
    return ptr;
}

void _scb_enc_dispatch(_scb_cmdbuf_t* cb, i32 num_groups_x, i32 num_groups_y, i32 num_groups_z) {
    var payload_size = cast(u64, 3 * sizeof(i32));
    if _scb_enc_cmd(cb, _SCB_CMD_DISPATCH, payload_size) != 0 {
        _scb_enc_i32(cb, num_groups_x);
        _scb_enc_i32(cb, num_groups_y);
        _scb_enc_i32(cb, num_groups_z);
        _scb_enc_end(cb);
    }
}

u8* _scb_dec_dispatch(u8* ptr) {
    i32 num_groups_x;
    i32 num_groups_y;
    i32 num_groups_z;
    ptr = _scb_dec_i32(ptr, &num_groups_x);
    ptr = _scb_dec_i32(ptr, &num_groups_y);
    ptr = _scb_dec_i32(ptr, &num_groups_z);
    sg_dispatch(num_groups_x, num_groups_y, num_groups_z);
    return ptr;
}

void _scb_enc_apply_bindings(_scb_cmdbuf_t* cb, sg_bindings* bindings) {
    u64 payload_size = 0;
    u64 slot_mask = 0;
    i32 vb_start = 0;
    i32 ib_start = vb_start + SG_MAX_VERTEXBUFFER_BINDSLOTS;
    i32 view_start = ib_start + 1;
    i32 smp_start = view_start + SG_MAX_VIEW_BINDSLOTS;
    assert(smp_start + SG_MAX_SAMPLER_BINDSLOTS <= 64);
    for i32 i = 0; i < SG_MAX_VERTEXBUFFER_BINDSLOTS; i++ {
        if bindings.vertex_buffers[i].id != cast(u32, SG_INVALID_ID) {
            slot_mask |= 1 << cast(u64, i + vb_start);
            payload_size += cast(u64, sizeof(u32) + sizeof(i32));
        }
    }
    if bindings.index_buffer.id != cast(u32, SG_INVALID_ID) {
        slot_mask |= 1 << cast(u64, ib_start);
        payload_size += cast(u64, sizeof(u32) + sizeof(i32));
    }
    for i32 i = 0; i < SG_MAX_VIEW_BINDSLOTS; i++ {
        if bindings.views[i].id != cast(u32, SG_INVALID_ID) {
            slot_mask |= 1 << cast(u64, view_start + i);
            payload_size += cast(u64, sizeof(u32));
        }
    }
    for i32 i = 0; i < SG_MAX_SAMPLER_BINDSLOTS; i++ {
        if bindings.samplers[i].id != cast(u32, SG_INVALID_ID) {
            slot_mask |= 1 << cast(u64, smp_start + i);
            payload_size += cast(u64, sizeof(u32));
        }
    }
    payload_size += cast(u64, sizeof(slot_mask));
    if _scb_enc_cmd(cb, _SCB_CMD_APPLY_BINDINGS, payload_size) != 0 {
        _scb_enc_u64(cb, slot_mask);
        for i32 i = 0; i < SG_MAX_VERTEXBUFFER_BINDSLOTS; i++ {
            if bindings.vertex_buffers[i].id != cast(u32, SG_INVALID_ID) {
                _scb_enc_u32(cb, bindings.vertex_buffers[i].id);
                _scb_enc_i32(cb, bindings.vertex_buffer_offsets[i]);
            }
        }
        if bindings.index_buffer.id != cast(u32, SG_INVALID_ID) {
            _scb_enc_u32(cb, bindings.index_buffer.id);
            _scb_enc_i32(cb, bindings.index_buffer_offset);
        }
        for i32 i = 0; i < SG_MAX_VIEW_BINDSLOTS; i++ {
            if bindings.views[i].id != cast(u32, SG_INVALID_ID) {
                _scb_enc_u32(cb, bindings.views[i].id);
            }
        }
        for i32 i = 0; i < SG_MAX_SAMPLER_BINDSLOTS; i++ {
            if bindings.samplers[i].id != cast(u32, SG_INVALID_ID) {
                _scb_enc_u32(cb, bindings.samplers[i].id);
            }
        }
        _scb_enc_end(cb);
    }
}

u8* _scb_dec_apply_bindings(u8* ptr) {
    i32 vb_start = 0;
    i32 ib_start = vb_start + SG_MAX_VERTEXBUFFER_BINDSLOTS;
    i32 view_start = ib_start + 1;
    i32 smp_start = view_start + SG_MAX_VIEW_BINDSLOTS;
    u64 slot_mask;
    ptr = _scb_dec_u64(ptr, &slot_mask);
    noinit sg_bindings bnd;
    _scb_clear(&bnd, cast(u64, sizeof(bnd)));
    for i32 i = 0; i < SG_MAX_VERTEXBUFFER_BINDSLOTS; i++ {
        if (slot_mask & 1 << cast(u64, i + vb_start)) != 0 {
            ptr = _scb_dec_u32(ptr, &bnd.vertex_buffers[i].id);
            ptr = _scb_dec_i32(ptr, &bnd.vertex_buffer_offsets[i]);
        }
    }
    if (slot_mask & 1 << cast(u64, ib_start)) != 0 {
        ptr = _scb_dec_u32(ptr, &bnd.index_buffer.id);
        ptr = _scb_dec_i32(ptr, &bnd.index_buffer_offset);
    }
    for i32 i = 0; i < SG_MAX_VIEW_BINDSLOTS; i++ {
        if (slot_mask & 1 << cast(u64, i + view_start)) != 0 {
            ptr = _scb_dec_u32(ptr, &bnd.views[i].id);
        }
    }
    for i32 i = 0; i < SG_MAX_SAMPLER_BINDSLOTS; i++ {
        if (slot_mask & 1 << cast(u64, i + smp_start)) != 0 {
            ptr = _scb_dec_u32(ptr, &bnd.samplers[i].id);
        }
    }
    sg_apply_bindings(&bnd);
    return ptr;
}

void _scb_enc_apply_uniforms(_scb_cmdbuf_t* cb, i32 ub_slot, sg_range* data) {
    assert(data.size <= UINT32_MAX);
    assert(ub_slot >= 0 && ub_slot < SG_MAX_UNIFORMBLOCK_BINDSLOTS);
    u64 max_payload_size = cast(u64, sizeof(i32) + sizeof(u32)) + data.size + 3;
    if _scb_enc_cmd(cb, _SCB_CMD_APPLY_UNIFORMS, max_payload_size) != 0 {
        _scb_enc_i32(cb, ub_slot);
        _scb_enc_u32(cb, cast(u32, data.size));
        _scb_enc_align4(cb);
        _scb_enc_blob(cb, data.ptr, data.size);
        _scb_enc_end(cb);
    }
}

u8* _scb_dec_apply_uniforms(u8* ptr) {
    i32 ub_slot;
    u32 size_u32;
    ptr = _scb_dec_i32(ptr, &ub_slot);
    assert(ub_slot >= 0 && ub_slot < SG_MAX_UNIFORMBLOCK_BINDSLOTS);
    ptr = _scb_dec_u32(ptr, &size_u32);
    ptr = _scb_dec_align4(ptr);
    noinit sg_range data;
    _scb_clear(&data, cast(u64, sizeof(data)));
    data.ptr = ptr;
    data.size = size_u32;
    sg_apply_uniforms(ub_slot, &data);
    return ptr + size_u32;
}

void _scb_rewind(_scb_cmdbuf_t* cb) {
    assert(cast(i64, cb.cur));
    assert(cast(i64, cb.buf));
    assert(cb.cur >= cb.buf);
    cb.cur = cb.buf;
    cb.overflown = false;
}
}

// >>public
void scb_setup(scb_desc* desc) {
    assert(cast(i64, desc));
    assert(desc.allocator.alloc_fn && desc.allocator.free_fn || !desc.allocator.alloc_fn && !desc.allocator.free_fn);
    _scb_clear(&_scb, cast(u64, sizeof(_scb)));
    _scb.init_tag = 0xACBAABCA;
    _scb.desc = _scb_desc_defaults(desc);
    _scb_setup_pools(&_scb.pools, &_scb.desc);
}

void scb_shutdown() {
    assert(0xACBAABCA == _scb.init_tag);
    _scb_discard_all_resources();
    _scb_discard_pools(&_scb.pools);
    _scb_clear(&_scb, cast(u64, sizeof(_scb)));
}

scb_cmdbuf scb_make_cmdbuf(scb_cmdbuf_desc* desc) {
    assert(0xACBAABCA == _scb.init_tag);
    assert(cast(i64, desc));
    scb_cmdbuf_desc desc_def = _scb_cmdbuf_desc_defaults(desc);
    scb_cmdbuf cb_id = _scb_alloc_cmdbuf();
    if cb_id.id != cast(u32, SCB_INVALID_ID) {
        _scb_cmdbuf_t* cb = _scb_cmdbuf_at(cb_id.id);
        assert(cb && cb.slot.state == SCB_RESOURCESTATE_ALLOC);
        _scb_init_cmdbuf(cb, &desc_def);
        assert(cb.slot.state == SCB_RESOURCESTATE_VALID || cb.slot.state == SCB_RESOURCESTATE_FAILED);
    }
    return cb_id;
}

void scb_destroy_cmdbuf(scb_cmdbuf cb_id) {
    assert(0xACBAABCA == _scb.init_tag);
    _scb_cmdbuf_t* cb = _scb_lookup_cmdbuf(cb_id.id);
    if cb != null {
        if cb.slot.state == SCB_RESOURCESTATE_VALID || cb.slot.state == SCB_RESOURCESTATE_FAILED {
            _scb_uninit_cmdbuf(cb);
            assert(cb.slot.state == SCB_RESOURCESTATE_ALLOC);
        }
        if cb.slot.state == SCB_RESOURCESTATE_ALLOC {
            _scb_dealloc_cmdbuf(cb);
            assert(cb.slot.state == SCB_RESOURCESTATE_INITIAL);
        }
    }
}

scb_resource_state scb_query_cmdbuf_state(scb_cmdbuf cb_id) {
    assert(0xACBAABCA == _scb.init_tag);
    _scb_cmdbuf_t* cb = _scb_lookup_cmdbuf(cb_id.id);
    return cb != null ? cb.slot.state : SCB_RESOURCESTATE_INVALID;
}

scb_cmdbuf_info scb_query_cmdbuf_info(scb_cmdbuf cb_id) {
    assert(0xACBAABCA == _scb.init_tag);
    _scb_cmdbuf_t* cb = _scb_lookup_cmdbuf(cb_id.id);
    noinit scb_cmdbuf_info info;
    _scb_clear(&info, cast(u64, sizeof(info)));
    if _scb_cmdbuf_valid(cb) != 0 {
        assert(cb.buf && cb.cur && cb.end);
        assert(cb.cur >= cb.buf && cb.cur <= cb.end);
        assert(cb.end > cb.buf);
        info.size = cast(u64, cast(i64, cb.end - cb.buf));
        info.remaining = cast(u64, cast(i64, cb.end - cb.cur));
        info.overflown = cb.overflown;
    }
    return info;
}

void scb_apply_viewport(scb_cmdbuf cb_id, i32 x, i32 y, i32 width, i32 height, bool origin_top_left) {
    assert(0xACBAABCA == _scb.init_tag);
    _scb_cmdbuf_t* cb = _scb_lookup_cmdbuf(cb_id.id);
    if _scb_cmdbuf_valid(cb) == 0 {
        _scb_log(SCB_LOGITEM_CMDBUF_NOT_VALID, 1, __line__);
        return;
    }
    _scb_enc_apply_viewport(cb, x, y, width, height, origin_top_left);
}

void scb_apply_viewportf(scb_cmdbuf cb_id, f32 x, f32 y, f32 width, f32 height, bool origin_top_left) {
    assert(0xACBAABCA == _scb.init_tag);
    _scb_cmdbuf_t* cb = _scb_lookup_cmdbuf(cb_id.id);
    if _scb_cmdbuf_valid(cb) == 0 {
        _scb_log(SCB_LOGITEM_CMDBUF_NOT_VALID, 1, __line__);
        return;
    }
    _scb_enc_apply_viewport(cb, cast(i32, x), cast(i32, y), cast(i32, width), cast(i32, height), origin_top_left);
}

void scb_apply_scissor_rect(scb_cmdbuf cb_id, i32 x, i32 y, i32 width, i32 height, bool origin_top_left) {
    assert(0xACBAABCA == _scb.init_tag);
    _scb_cmdbuf_t* cb = _scb_lookup_cmdbuf(cb_id.id);
    if _scb_cmdbuf_valid(cb) == 0 {
        _scb_log(SCB_LOGITEM_CMDBUF_NOT_VALID, 1, __line__);
        return;
    }
    _scb_enc_apply_scissor_rect(cb, x, y, width, height, origin_top_left);
}

void scb_apply_scissor_rectf(scb_cmdbuf cb_id, f32 x, f32 y, f32 width, f32 height, bool origin_top_left) {
    assert(0xACBAABCA == _scb.init_tag);
    _scb_cmdbuf_t* cb = _scb_lookup_cmdbuf(cb_id.id);
    if _scb_cmdbuf_valid(cb) == 0 {
        _scb_log(SCB_LOGITEM_CMDBUF_NOT_VALID, 1, __line__);
        return;
    }
    _scb_enc_apply_scissor_rect(cb, cast(i32, x), cast(i32, y), cast(i32, width), cast(i32, height), origin_top_left);
}

void scb_apply_pipeline(scb_cmdbuf cb_id, sg_pipeline pip) {
    assert(0xACBAABCA == _scb.init_tag);
    _scb_cmdbuf_t* cb = _scb_lookup_cmdbuf(cb_id.id);
    if _scb_cmdbuf_valid(cb) == 0 {
        _scb_log(SCB_LOGITEM_CMDBUF_NOT_VALID, 1, __line__);
        return;
    }
    _scb_enc_apply_pipeline(cb, pip.id);
}

void scb_apply_bindings(scb_cmdbuf cb_id, sg_bindings* bindings) {
    assert(0xACBAABCA == _scb.init_tag);
    assert(cast(i64, bindings));
    _scb_cmdbuf_t* cb = _scb_lookup_cmdbuf(cb_id.id);
    if _scb_cmdbuf_valid(cb) == 0 {
        _scb_log(SCB_LOGITEM_CMDBUF_NOT_VALID, 1, __line__);
        return;
    }
    _scb_enc_apply_bindings(cb, bindings);
}

void scb_apply_uniforms(scb_cmdbuf cb_id, i32 ub_slot, sg_range* data) {
    assert(0xACBAABCA == _scb.init_tag);
    assert(data && data.ptr && data.size > 0);
    _scb_cmdbuf_t* cb = _scb_lookup_cmdbuf(cb_id.id);
    if _scb_cmdbuf_valid(cb) == 0 {
        _scb_log(SCB_LOGITEM_CMDBUF_NOT_VALID, 1, __line__);
        return;
    }
    _scb_enc_apply_uniforms(cb, ub_slot, data);
}

void scb_draw(scb_cmdbuf cb_id, i32 base_element, i32 num_elements, i32 num_instances) {
    assert(0xACBAABCA == _scb.init_tag);
    _scb_cmdbuf_t* cb = _scb_lookup_cmdbuf(cb_id.id);
    if _scb_cmdbuf_valid(cb) == 0 {
        _scb_log(SCB_LOGITEM_CMDBUF_NOT_VALID, 1, __line__);
        return;
    }
    _scb_enc_draw(cb, base_element, num_elements, num_instances);
}

void scb_draw_ex(scb_cmdbuf cb_id, i32 base_element, i32 num_elements, i32 num_instances, i32 base_vertex, i32 base_instance) {
    assert(0xACBAABCA == _scb.init_tag);
    _scb_cmdbuf_t* cb = _scb_lookup_cmdbuf(cb_id.id);
    if _scb_cmdbuf_valid(cb) == 0 {
        _scb_log(SCB_LOGITEM_CMDBUF_NOT_VALID, 1, __line__);
        return;
    }
    _scb_enc_draw_ex(cb, base_element, num_elements, num_instances, base_vertex, base_instance);
}

void scb_dispatch(scb_cmdbuf cb_id, i32 num_groups_x, i32 num_groups_y, i32 num_groups_z) {
    assert(0xACBAABCA == _scb.init_tag);
    _scb_cmdbuf_t* cb = _scb_lookup_cmdbuf(cb_id.id);
    if _scb_cmdbuf_valid(cb) == 0 {
        _scb_log(SCB_LOGITEM_CMDBUF_NOT_VALID, 1, __line__);
        return;
    }
    _scb_enc_dispatch(cb, num_groups_x, num_groups_y, num_groups_z);
}

void scb_submit(scb_cmdbuf cb_id) {
    assert(0xACBAABCA == _scb.init_tag);
    _scb_cmdbuf_t* cb = _scb_lookup_cmdbuf(cb_id.id);
    if _scb_cmdbuf_valid(cb) == 0 {
        _scb_log(SCB_LOGITEM_CMDBUF_NOT_VALID, 1, __line__);
        return;
    }
    if cb.overflown != 0 {
        _scb_log(SCB_LOGITEM_SUBMIT_CMDBUF_OVERFLOWN, 1, __line__);
        _scb_rewind(cb);
        return;
    }
    assert(cast(i64, cb.buf));
    assert(cast(i64, cb.cur));
    assert(cb.buf <= cb.cur);
    u8* ptr = cb.buf;
    bool has_label = cb.label.buf[0] != 0;
    if has_label != 0 {
        sg_push_debug_group(cb.label.buf);
    }
    while ptr < cb.cur {
        _scb_cmd_t cmd = _SCB_CMD_NONE;
        ptr = _scb_dec_cmd(ptr, &cmd);
        switch cmd {
            case _SCB_CMD_APPLY_VIEWPORT: {
                ptr = _scb_dec_apply_viewport(ptr);
            }
            case _SCB_CMD_APPLY_SCISSOR_RECT: {
                ptr = _scb_dec_apply_scissor_rect(ptr);
            }
            case _SCB_CMD_APPLY_PIPELINE: {
                ptr = _scb_dec_apply_pipeline(ptr);
            }
            case _SCB_CMD_APPLY_BINDINGS: {
                ptr = _scb_dec_apply_bindings(ptr);
            }
            case _SCB_CMD_APPLY_UNIFORMS: {
                ptr = _scb_dec_apply_uniforms(ptr);
            }
            case _SCB_CMD_DRAW: {
                ptr = _scb_dec_draw(ptr);
            }
            case _SCB_CMD_DRAW_EX: {
                ptr = _scb_dec_draw_ex(ptr);
            }
            case _SCB_CMD_DISPATCH: {
                ptr = _scb_dec_dispatch(ptr);
            }
            default: {
                _scb_log(SCB_LOGITEM_SUBMIT_INVALID_COMMAND, 1, __line__);
                ptr = cb.cur;
            }
        }
    }
    _scb_rewind(cb);
    if has_label != 0 {
        sg_pop_debug_group();
    }
}

void scb_reset(scb_cmdbuf cb_id) {
    assert(0xACBAABCA == _scb.init_tag);
    _scb_cmdbuf_t* cb = _scb_lookup_cmdbuf(cb_id.id);
    if _scb_cmdbuf_valid(cb) == 0 {
        _scb_log(SCB_LOGITEM_CMDBUF_NOT_VALID, 1, __line__);
        return;
    }
    _scb_rewind(cb);
}

