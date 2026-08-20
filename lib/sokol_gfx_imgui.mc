// sokol_gfx_imgui
import sokol_all;
import imgui;

enum _sgimgui_cmd_t {
    _SGIMGUI_CMD_INVALID = 0,
    _SGIMGUI_CMD_RESET_STATE_CACHE = 1,
    _SGIMGUI_CMD_MAKE_BUFFER = 2,
    _SGIMGUI_CMD_MAKE_IMAGE = 3,
    _SGIMGUI_CMD_MAKE_SAMPLER = 4,
    _SGIMGUI_CMD_MAKE_SHADER = 5,
    _SGIMGUI_CMD_MAKE_PIPELINE = 6,
    _SGIMGUI_CMD_MAKE_VIEW = 7,
    _SGIMGUI_CMD_DESTROY_BUFFER = 8,
    _SGIMGUI_CMD_DESTROY_IMAGE = 9,
    _SGIMGUI_CMD_DESTROY_SAMPLER = 10,
    _SGIMGUI_CMD_DESTROY_SHADER = 11,
    _SGIMGUI_CMD_DESTROY_PIPELINE = 12,
    _SGIMGUI_CMD_DESTROY_VIEW = 13,
    _SGIMGUI_CMD_UPDATE_BUFFER = 14,
    _SGIMGUI_CMD_UPDATE_IMAGE = 15,
    _SGIMGUI_CMD_APPEND_BUFFER = 16,
    _SGIMGUI_CMD_WRITE_BUFFER_UNSEALED = 17,
    _SGIMGUI_CMD_WRITE_IMAGE_UNSEALED = 18,
    _SGIMGUI_CMD_SEAL_BUFFER = 19,
    _SGIMGUI_CMD_SEAL_IMAGE = 20,
    _SGIMGUI_CMD_BEGIN_PASS = 21,
    _SGIMGUI_CMD_APPLY_VIEWPORT = 22,
    _SGIMGUI_CMD_APPLY_SCISSOR_RECT = 23,
    _SGIMGUI_CMD_APPLY_PIPELINE = 24,
    _SGIMGUI_CMD_APPLY_BINDINGS = 25,
    _SGIMGUI_CMD_APPLY_UNIFORMS = 26,
    _SGIMGUI_CMD_DRAW = 27,
    _SGIMGUI_CMD_DRAW_EX = 28,
    _SGIMGUI_CMD_DISPATCH = 29,
    _SGIMGUI_CMD_END_PASS = 30,
    _SGIMGUI_CMD_COMMIT = 31,
    _SGIMGUI_CMD_ALLOC_BUFFER = 32,
    _SGIMGUI_CMD_ALLOC_IMAGE = 33,
    _SGIMGUI_CMD_ALLOC_SAMPLER = 34,
    _SGIMGUI_CMD_ALLOC_SHADER = 35,
    _SGIMGUI_CMD_ALLOC_PIPELINE = 36,
    _SGIMGUI_CMD_ALLOC_VIEW = 37,
    _SGIMGUI_CMD_DEALLOC_BUFFER = 38,
    _SGIMGUI_CMD_DEALLOC_IMAGE = 39,
    _SGIMGUI_CMD_DEALLOC_SAMPLER = 40,
    _SGIMGUI_CMD_DEALLOC_SHADER = 41,
    _SGIMGUI_CMD_DEALLOC_PIPELINE = 42,
    _SGIMGUI_CMD_DEALLOC_VIEW = 43,
    _SGIMGUI_CMD_INIT_BUFFER = 44,
    _SGIMGUI_CMD_INIT_IMAGE = 45,
    _SGIMGUI_CMD_INIT_SAMPLER = 46,
    _SGIMGUI_CMD_INIT_SHADER = 47,
    _SGIMGUI_CMD_INIT_PIPELINE = 48,
    _SGIMGUI_CMD_INIT_VIEW = 49,
    _SGIMGUI_CMD_UNINIT_BUFFER = 50,
    _SGIMGUI_CMD_UNINIT_IMAGE = 51,
    _SGIMGUI_CMD_UNINIT_SAMPLER = 52,
    _SGIMGUI_CMD_UNINIT_SHADER = 53,
    _SGIMGUI_CMD_UNINIT_PIPELINE = 54,
    _SGIMGUI_CMD_UNINIT_VIEW = 55,
    _SGIMGUI_CMD_FAIL_BUFFER = 56,
    _SGIMGUI_CMD_FAIL_IMAGE = 57,
    _SGIMGUI_CMD_FAIL_SAMPLER = 58,
    _SGIMGUI_CMD_FAIL_SHADER = 59,
    _SGIMGUI_CMD_FAIL_PIPELINE = 60,
    _SGIMGUI_CMD_FAIL_VIEW = 61,
    _SGIMGUI_CMD_PUSH_DEBUG_GROUP = 62,
    _SGIMGUI_CMD_POP_DEBUG_GROUP = 63,
}

type __arr__sgimgui_str_t_16 = _sgimgui_str_t[16];
/*
    sgimgui_allocator_t

    Used in sgimgui_desc_t to provide custom memory-alloc and -free functions
    to sokol_gfx_imgui.h. If memory management should be overridden, both the
    alloc and free function must be provided (e.g. it's not valid to
    override one function but not the other).
*/
struct sgimgui_allocator_t {
    fn(u64, void*): void* alloc_fn;
    fn(void*, void*): void free_fn;
    void* user_data;
}

/*
    sgimgui_desc_t

    Initialization options for sgimgui_init().
*/
struct sgimgui_desc_t {
    sgimgui_allocator_t allocator;
}

/* max number of captured calls per frame */
struct _sgimgui_str_t {
    u8[96] buf;
}

struct _sgimgui_buffer_t {
    sg_buffer res_id;
    _sgimgui_str_t label;
    sg_buffer_desc desc;
}

struct _sgimgui_image_t {
    sg_image res_id;
    f32 ui_scale;
    _sgimgui_str_t label;
    sg_image_desc desc;
}

struct _sgimgui_sampler_t {
    sg_sampler res_id;
    _sgimgui_str_t label;
    sg_sampler_desc desc;
}

struct _sgimgui_shader_t {
    sg_shader res_id;
    _sgimgui_str_t label;
    _sgimgui_str_t vs_entry;
    _sgimgui_str_t vs_d3d11_target;
    _sgimgui_str_t fs_entry;
    _sgimgui_str_t fs_d3d11_target;
    _sgimgui_str_t cs_entry;
    _sgimgui_str_t cs_d3d11_target;
    _sgimgui_str_t[32] glsl_texture_sampler_name;
    __arr__sgimgui_str_t_16[8] glsl_uniform_name;
    _sgimgui_str_t[16] attr_glsl_name;
    _sgimgui_str_t[16] attr_hlsl_sem_name;
    sg_shader_desc desc;
}

struct _sgimgui_pipeline_t {
    sg_pipeline res_id;
    _sgimgui_str_t label;
    sg_pipeline_desc desc;
}

struct _sgimgui_view_t {
    sg_view res_id;
    f32 ui_scale;
    _sgimgui_str_t label;
    sg_view_desc desc;
}

struct _sgimgui_buffer_window_t {
    bool open;
    sg_buffer sel_buf;
    i32 num_slots;
    _sgimgui_buffer_t* slots;
}

struct _sgimgui_image_window_t {
    bool open;
    sg_image sel_img;
    i32 num_slots;
    _sgimgui_image_t* slots;
}

struct _sgimgui_sampler_window_t {
    bool open;
    sg_sampler sel_smp;
    i32 num_slots;
    _sgimgui_sampler_t* slots;
}

struct _sgimgui_shader_window_t {
    bool open;
    sg_shader sel_shd;
    i32 num_slots;
    _sgimgui_shader_t* slots;
}

struct _sgimgui_pipeline_window_t {
    bool open;
    sg_pipeline sel_pip;
    i32 num_slots;
    _sgimgui_pipeline_t* slots;
}

struct _sgimgui_view_window_t {
    bool open;
    sg_view sel_view;
    i32 num_slots;
    _sgimgui_view_t* slots;
}

struct _sgimgui_args_make_buffer_t {
    sg_buffer result;
}

struct _sgimgui_args_make_image_t {
    sg_image result;
}

struct _sgimgui_args_make_sampler_t {
    sg_sampler result;
}

struct _sgimgui_args_make_shader_t {
    sg_shader result;
}

struct _sgimgui_args_make_pipeline_t {
    sg_pipeline result;
}

struct _sgimgui_args_make_view_t {
    sg_view result;
}

struct _sgimgui_args_destroy_buffer_t {
    sg_buffer buffer;
}

struct _sgimgui_args_destroy_image_t {
    sg_image image;
}

struct _sgimgui_args_destroy_sampler_t {
    sg_sampler sampler;
}

struct _sgimgui_args_destroy_shader_t {
    sg_shader shader;
}

struct _sgimgui_args_destroy_pipeline_t {
    sg_pipeline pipeline;
}

struct _sgimgui_args_destroy_view_t {
    sg_view view;
}

struct _sgimgui_args_update_buffer_t {
    sg_buffer buffer;
    u64 data_size;
}

struct _sgimgui_args_update_image_t {
    sg_image image;
}

struct _sgimgui_args_append_buffer_t {
    sg_buffer buffer;
    u64 data_size;
    i32 result;
}

struct _sgimgui_args_write_buffer_unsealed_t {
    u64 src_data_size;
    u64 src_data_offset;
    sg_buffer_location dst;
    u64 write_size;
}

struct _sgimgui_args_write_image_unsealed_t {
    u64 src_data_size;
    u64 src_data_offset;
    i32 src_bytes_per_row;
    i32 src_bytes_per_slice;
    sg_image_location dst;
    sg_image_extent write_size;
}

struct _sgimgui_args_seal_buffer_t {
    sg_buffer buffer;
}

struct _sgimgui_args_seal_image_t {
    sg_image image;
}

struct _sgimgui_args_begin_pass_t {
    sg_pass pass;
}

struct _sgimgui_args_apply_viewport_t {
    i32 x;
    i32 y;
    i32 width;
    i32 height;
    bool origin_top_left;
}

struct _sgimgui_args_apply_scissor_rect_t {
    i32 x;
    i32 y;
    i32 width;
    i32 height;
    bool origin_top_left;
}

struct _sgimgui_args_apply_pipeline_t {
    sg_pipeline pipeline;
}

struct _sgimgui_args_apply_bindings_t {
    sg_bindings bindings;
}

struct _sgimgui_args_apply_uniforms_t {
    i32 ub_slot;
    u64 data_size;
    sg_pipeline pipeline;
    u64 ubuf_pos;
}

struct _sgimgui_args_draw_t {
    i32 base_element;
    i32 num_elements;
    i32 num_instances;
}

struct _sgimgui_args_draw_ex_t {
    i32 base_element;
    i32 num_elements;
    i32 num_instances;
    i32 base_vertex;
    i32 base_instance;
}

struct _sgimgui_args_dispatch_t {
    i32 num_groups_x;
    i32 num_groups_y;
    i32 num_groups_z;
}

struct _sgimgui_args_alloc_buffer_t {
    sg_buffer result;
}

struct _sgimgui_args_alloc_image_t {
    sg_image result;
}

struct _sgimgui_args_alloc_sampler_t {
    sg_sampler result;
}

struct _sgimgui_args_alloc_shader_t {
    sg_shader result;
}

struct _sgimgui_args_alloc_pipeline_t {
    sg_pipeline result;
}

struct _sgimgui_args_alloc_view_t {
    sg_view result;
}

struct _sgimgui_args_dealloc_buffer_t {
    sg_buffer buffer;
}

struct _sgimgui_args_dealloc_image_t {
    sg_image image;
}

struct _sgimgui_args_dealloc_sampler_t {
    sg_sampler sampler;
}

struct _sgimgui_args_dealloc_shader_t {
    sg_shader shader;
}

struct _sgimgui_args_dealloc_pipeline_t {
    sg_pipeline pipeline;
}

struct _sgimgui_args_dealloc_view_t {
    sg_view view;
}

struct _sgimgui_args_init_buffer_t {
    sg_buffer buffer;
}

struct _sgimgui_args_init_image_t {
    sg_image image;
}

struct _sgimgui_args_init_sampler_t {
    sg_sampler sampler;
}

struct _sgimgui_args_init_shader_t {
    sg_shader shader;
}

struct _sgimgui_args_init_pipeline_t {
    sg_pipeline pipeline;
}

struct _sgimgui_args_init_view_t {
    sg_view view;
}

struct _sgimgui_args_uninit_buffer_t {
    sg_buffer buffer;
}

struct _sgimgui_args_uninit_image_t {
    sg_image image;
}

struct _sgimgui_args_uninit_sampler_t {
    sg_sampler sampler;
}

struct _sgimgui_args_uninit_shader_t {
    sg_shader shader;
}

struct _sgimgui_args_uninit_pipeline_t {
    sg_pipeline pipeline;
}

struct _sgimgui_args_uninit_view_t {
    sg_view view;
}

struct _sgimgui_args_fail_buffer_t {
    sg_buffer buffer;
}

struct _sgimgui_args_fail_image_t {
    sg_image image;
}

struct _sgimgui_args_fail_sampler_t {
    sg_sampler sampler;
}

struct _sgimgui_args_fail_shader_t {
    sg_shader shader;
}

struct _sgimgui_args_fail_pipeline_t {
    sg_pipeline pipeline;
}

struct _sgimgui_args_fail_view_t {
    sg_view view;
}

struct _sgimgui_args_push_debug_group_t {
    _sgimgui_str_t name;
}

unsafe_union _sgimgui_args_t {
    _sgimgui_args_make_buffer_t make_buffer;
    _sgimgui_args_make_image_t make_image;
    _sgimgui_args_make_sampler_t make_sampler;
    _sgimgui_args_make_shader_t make_shader;
    _sgimgui_args_make_pipeline_t make_pipeline;
    _sgimgui_args_make_view_t make_view;
    _sgimgui_args_destroy_buffer_t destroy_buffer;
    _sgimgui_args_destroy_image_t destroy_image;
    _sgimgui_args_destroy_sampler_t destroy_sampler;
    _sgimgui_args_destroy_shader_t destroy_shader;
    _sgimgui_args_destroy_pipeline_t destroy_pipeline;
    _sgimgui_args_destroy_view_t destroy_view;
    _sgimgui_args_update_buffer_t update_buffer;
    _sgimgui_args_update_image_t update_image;
    _sgimgui_args_append_buffer_t append_buffer;
    _sgimgui_args_write_buffer_unsealed_t write_buffer_unsealed;
    _sgimgui_args_write_image_unsealed_t write_image_unsealed;
    _sgimgui_args_seal_buffer_t seal_buffer;
    _sgimgui_args_seal_image_t seal_image;
    _sgimgui_args_begin_pass_t begin_pass;
    _sgimgui_args_apply_viewport_t apply_viewport;
    _sgimgui_args_apply_scissor_rect_t apply_scissor_rect;
    _sgimgui_args_apply_pipeline_t apply_pipeline;
    _sgimgui_args_apply_bindings_t apply_bindings;
    _sgimgui_args_apply_uniforms_t apply_uniforms;
    _sgimgui_args_draw_t draw;
    _sgimgui_args_draw_ex_t draw_ex;
    _sgimgui_args_dispatch_t dispatch;
    _sgimgui_args_alloc_buffer_t alloc_buffer;
    _sgimgui_args_alloc_image_t alloc_image;
    _sgimgui_args_alloc_sampler_t alloc_sampler;
    _sgimgui_args_alloc_shader_t alloc_shader;
    _sgimgui_args_alloc_pipeline_t alloc_pipeline;
    _sgimgui_args_alloc_view_t alloc_view;
    _sgimgui_args_dealloc_buffer_t dealloc_buffer;
    _sgimgui_args_dealloc_image_t dealloc_image;
    _sgimgui_args_dealloc_sampler_t dealloc_sampler;
    _sgimgui_args_dealloc_shader_t dealloc_shader;
    _sgimgui_args_dealloc_pipeline_t dealloc_pipeline;
    _sgimgui_args_dealloc_view_t dealloc_view;
    _sgimgui_args_init_buffer_t init_buffer;
    _sgimgui_args_init_image_t init_image;
    _sgimgui_args_init_sampler_t init_sampler;
    _sgimgui_args_init_shader_t init_shader;
    _sgimgui_args_init_pipeline_t init_pipeline;
    _sgimgui_args_init_view_t init_view;
    _sgimgui_args_uninit_buffer_t uninit_buffer;
    _sgimgui_args_uninit_image_t uninit_image;
    _sgimgui_args_uninit_sampler_t uninit_sampler;
    _sgimgui_args_uninit_shader_t uninit_shader;
    _sgimgui_args_uninit_pipeline_t uninit_pipeline;
    _sgimgui_args_uninit_view_t uninit_view;
    _sgimgui_args_fail_buffer_t fail_buffer;
    _sgimgui_args_fail_image_t fail_image;
    _sgimgui_args_fail_sampler_t fail_sampler;
    _sgimgui_args_fail_shader_t fail_shader;
    _sgimgui_args_fail_pipeline_t fail_pipeline;
    _sgimgui_args_fail_view_t fail_view;
    _sgimgui_args_push_debug_group_t push_debug_group;
}

struct _sgimgui_capture_item_t {
    _sgimgui_cmd_t cmd;
    u32 color;
    _sgimgui_args_t args;
}

struct _sgimgui_capture_bucket_t {
    u64 ubuf_size;
    u64 ubuf_pos;
    u8* ubuf;
    i32 num_items;
    _sgimgui_capture_item_t[4096] items;
}

/* double-buffered call-capture buckets, one bucket is currently recorded,
   the previous bucket is displayed
*/
struct _sgimgui_capture_window_t {
    bool open;
    i32 bucket_index;
    i32 sel_item;
    _sgimgui_capture_bucket_t[2] bucket;
}

struct _sgimgui_caps_window_t {
    bool open;
}

struct _sgimgui_frame_stats_window_t {
    bool open;
    bool disable_sokol_imgui_stats;
    bool in_sokol_imgui;
    sg_stats stats;
}

struct _sgimgui_t {
    u32 init_tag;
    sgimgui_desc_t desc;
    _sgimgui_buffer_window_t buffer_window;
    _sgimgui_image_window_t image_window;
    _sgimgui_sampler_window_t sampler_window;
    _sgimgui_shader_window_t shader_window;
    _sgimgui_pipeline_window_t pipeline_window;
    _sgimgui_view_window_t view_window;
    _sgimgui_capture_window_t capture_window;
    _sgimgui_caps_window_t caps_window;
    _sgimgui_frame_stats_window_t frame_stats_window;
    sg_pipeline cur_pipeline;
    sg_trace_hooks hooks;
}

/*
    sokol_gfx_imgui.h -- debug-inspection UI for sokol_gfx.h using Dear ImGui

    Project URL: https://github.com/floooh/sokol

    Do this:
        #define SOKOL_IMPL or
        #define SOKOL_GFX_IMGUI_IMPL

    before you include this file in *one* C or C++ file to create the
    implementation.

    NOTE that the implementation can be compiled either as C++ or as C.
    When compiled as C++, sokol_gfx_imgui.h will directly call into the
    Dear ImGui C++ API. When compiled as C, sokol_gfx_imgui.h will call
    cimgui.h functions instead.

    Include the following file(s) before including sokol_gfx_imgui.h:

        sokol_gfx.h

    Additionally, include the following headers before including the
    implementation:

    If the implementation is compiled as C++:
        imgui.h

    If the implementation is compiled as C:
        cimgui.h

    The sokol_gfx.h implementation must be compiled with debug trace hooks
    enabled by defining:

        SOKOL_TRACE_HOOKS

    ...before including the sokol_gfx.h implementation.

    Before including the sokol_gfx_imgui.h implementation, optionally
    override the following macros:

        SOKOL_ASSERT(c)     -- your own assert macro, default: assert(c)
        SOKOL_UNREACHABLE   -- your own macro to annotate unreachable code,
                               default: SOKOL_ASSERT(false)
        SOKOL_GFX_IMGUI_API_DECL    - public function declaration prefix (default: extern)
        SOKOL_GFX_IMGUI_CPREFIX     - defines the function prefix for the Dear ImGui C bindings (default: ig)
        SOKOL_API_DECL      - same as SOKOL_GFX_IMGUI_API_DECL
        SOKOL_API_IMPL      - public function implementation prefix (default: -)

    If sokol_gfx_imgui.h is compiled as a DLL, define the following before
    including the declaration or implementation:

    SOKOL_DLL

    On Windows, SOKOL_DLL will define SOKOL_GFX_IMGUI_API_DECL as __declspec(dllexport)
    or __declspec(dllimport) as needed.

    STEP BY STEP:
    =============
    --- call sgimgui_setup() with optional allocator overrides:

            sgimgui_setup(&(sgimgui_desc_t){
                .allocator = {
                    .alloc_fn = my_malloc,
                    .free_fn = my_free,
                }
            });

    --- somewhere in the per-frame code call:

            sgimgui_draw()

        this won't draw anything yet, since no windows are open.

    --- call the convenience function sgimgui_draw_menu(ctx, title)
        to render a menu which allows to open/close the provided debug windows

            sgimgui_draw_menu("sokol-gfx");

    --- alternatively the individual single menu items via:

        if (ImGui::BeginMainMenuBar()) {
            if (ImGui::BeginMenu("sokol-gfx")) {
                sgimgui_draw_buffer_window_menu_item("Buffers");
                sgimgui_draw_image_window_menu_item("Images");
                sgimgui_draw_sampler_window_menu_item("Samplers");
                sgimgui_draw_shader_window_menu_item("Shaders");
                sgimgui_draw_pipeline_window_menu_item("Pipelines");
                sgimgui_draw_view_window_menu_item("Views");
                sgimgui_draw_capture_window_menu_item("Calls");
                sgimgui_draw_capabilities_window_menu_item("Capabilities");
                sgimgui_draw_frame_stats_window_menu_item("Frame Stats");
                ImGui::EndMenu();
            }
            ImGui::EndMainMenuBar();
        }

    --- before application shutdown, call:

            sgimgui_shutdown();

        ...this is not strictly necessary because the application exits
        anyway, but not doing this may trigger memory leak detection tools.

    --- finally, your application needs an ImGui renderer, you can either
        provide your own, or drop in the sokol_imgui.h utility header

    ALTERNATIVE DRAWING FUNCTIONS:
    ==============================
    Instead of the convenient but all-in-one sgimgui_draw() function,
    you can also use the following granular functions which might allow
    better integration with your existing UI:

    The following functions only render the window *content* (so you
    can integrate the UI into you own windows):

        void sgimgui_draw_buffer_window_content(void);
        void sgimgui_draw_image_window_content(void);
        void sgimgui_draw_sampler_window_content(void);
        void sgimgui_draw_shader_window_content(void);
        void sgimgui_draw_pipeline_window_content(void);
        void sgimgui_draw_view_window_content(void);
        void sgimgui_draw_capture_window_content(void);
        void sgimgui_draw_capabilities_window_content(void);
        void sgimgui_draw_frame_stats_window_content(void);

    And these are the 'full window' drawing functions:

        void sgimgui_draw_buffer_window(const char* title);
        void sgimgui_draw_image_window(const char* title);
        void sgimgui_draw_sampler_window(const char* title);
        void sgimgui_draw_shader_window(const char* title);
        void sgimgui_draw_pipeline_window(const char* title);
        void sgimgui_draw_view_window(const char* title);
        void sgimgui_draw_capture_window(const char* title);
        void sgimgui_draw_capabilities_window(const char* title);
        void sgimgui_draw_frame_stats_window(const char* title);

    To draw the individual menu items:

        void sgimgui_draw_buffer_menu_item(const char* label);
        void sgimgui_draw_image_menu_item(const char* label);
        void sgimgui_draw_sampler_menu_item(const char* label);
        void sgimgui_draw_shader_menu_item(const char* label);
        void sgimgui_draw_pipeline_menu_item(const char* label);
        void sgimgui_draw_view_menu_item(const char* label);
        void sgimgui_draw_capture_menu_item(const char* label);
        void sgimgui_draw_capabilities_menu_item(const char* label);
        void sgimgui_draw_frame_stats_menu_item(const char* label);

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
/*=== IMPLEMENTATION =========================================================*/
private {
_sgimgui_t _sgimgui;

/*--- C => C++ layer ---------------------------------------------------------*/
void _sgimgui_igtext(u8* fmt, ...) {
    ImGui_TextV(fmt, cast(void*, &...));
}

void _sgimgui_igseparator() {
    ImGui_Separator();
}

void _sgimgui_igsameline() {
    ImGui_SameLine();
}

void _sgimgui_igpushidint(i32 int_id) {
    ImGui_PushID(int_id);
}

void _sgimgui_igpushid(u8* str_id) {
    ImGui_PushID(str_id);
}

void _sgimgui_igpopid() {
    ImGui_PopID();
}

bool _sgimgui_igselectableex(u8* label, bool selected, ImGuiSelectableFlags flags, ImVec2 size) {
    return ImGui_Selectable(label, selected, flags, size);
}

bool _sgimgui_igsmallbutton(u8* label) {
    return ImGui_SmallButton(label);
}

bool _sgimgui_igbeginchild(u8* str_id, ImVec2 size, ImGuiChildFlags cflags, ImGuiWindowFlags wflags) {
    return ImGui_BeginChild(str_id, size, cflags, wflags);
}

void _sgimgui_igendchild() {
    ImGui_EndChild();
}

void _sgimgui_igpushstylecolor(ImGuiCol idx, ImU32 col) {
    ImGui_PushStyleColor(idx, col);
}

void _sgimgui_igpopstylecolor() {
    ImGui_PopStyleColor();
}

bool _sgimgui_igtreenodestr(u8* str_id, u8* fmt, ...) {
    bool ret = ImGui_TreeNodeV(str_id, fmt, cast(void*, &...));
    return ret;
}

bool _sgimgui_igtreenode(u8* label) {
    return ImGui_TreeNode(label);
}

void _sgimgui_igtreepop() {
    ImGui_TreePop();
}

bool _sgimgui_igisitemhovered(ImGuiHoveredFlags flags) {
    return ImGui_IsItemHovered(flags);
}

void _sgimgui_igsettooltip(u8* fmt, ...) {
    ImGui_SetTooltipV(fmt, cast(void*, &...));
}

bool _sgimgui_igbegintooltip() {
    return ImGui_BeginTooltip();
}

void _sgimgui_igendtooltip() {
    ImGui_EndTooltip();
}

bool _sgimgui_igsliderfloatex(u8* label, f32* v, f32 v_min, f32 v_max, u8* format_var, ImGuiSliderFlags flags) {
    return ImGui_SliderFloat(label, v, v_min, v_max, format_var, flags);
}

void _sgimgui_igsetnextwindowsize(ImVec2 size, ImGuiCond cond) {
    ImGui_SetNextWindowSize(size, cond);
}

bool _sgimgui_igbegin(u8* name, bool* p_open, ImGuiWindowFlags flags) {
    return ImGui_Begin(name, p_open, flags);
}

void _sgimgui_igend() {
    ImGui_End();
}

bool _sgimgui_igbeginmenu(u8* label) {
    return ImGui_BeginMenu(label);
}

void _sgimgui_igendmenu() {
    ImGui_EndMenu();
}

bool _sgimgui_igmenuitemboolptr(u8* label, u8* shortcut, bool* p_selected, bool enabled) {
    return ImGui_MenuItem(label, shortcut, p_selected, enabled);
}

bool _sgimgui_igbegintable(u8* str_id, i32 column, ImGuiTableFlags flags) {
    return ImGui_BeginTable(str_id, column, flags);
}

void _sgimgui_igendtable() {
    ImGui_EndTable();
}

void _sgimgui_igtablesetupscrollfreeze(i32 cols, i32 rows) {
    ImGui_TableSetupScrollFreeze(cols, rows);
}

void _sgimgui_igtablesetupcolumn(u8* label, ImGuiTableColumnFlags flags) {
    ImGui_TableSetupColumn(label, flags);
}

void _sgimgui_igtableheadersrow() {
    ImGui_TableHeadersRow();
}

void _sgimgui_igtablenextrow() {
    ImGui_TableNextRow();
}

bool _sgimgui_igtablesetcolumnindex(i32 column_n) {
    return ImGui_TableSetColumnIndex(column_n);
}

bool _sgimgui_igcheckbox(u8* label, bool* v) {
    return ImGui_Checkbox(label, v);
}

void _sgimgui_igimage(ImTextureID user_texture_id, ImVec2 size) {
    ImTextureRef tex_ref;
    tex_ref._TexID = user_texture_id;
    ImGui_Image(tex_ref, size);
}

/*--- UTILS ------------------------------------------------------------------*/
void _sgimgui_clear(void* ptr, u64 size) {
    memset(ptr, 0, size);
}

void* _sgimgui_malloc(sgimgui_allocator_t* allocator, u64 size) {
    void* ptr;
    if allocator.alloc_fn != null {
        ptr = allocator.alloc_fn(size, allocator.user_data);
    } else {
        ptr = alloc(cast(i64, size));
    }
    return ptr;
}

void* _sgimgui_malloc_clear(sgimgui_allocator_t* allocator, u64 size) {
    void* ptr = _sgimgui_malloc(allocator, size);
    _sgimgui_clear(ptr, size);
    return ptr;
}

void _sgimgui_free(sgimgui_allocator_t* allocator, void* ptr) {
    if allocator.free_fn != null {
        allocator.free_fn(ptr, allocator.user_data);
    } else {
        free(ptr);
    }
}

void* _sgimgui_realloc(sgimgui_allocator_t* allocator, void* old_ptr, u64 old_size, u64 new_size) {
    void* new_ptr = _sgimgui_malloc(allocator, new_size);
    if old_ptr != null {
        if old_size > 0 {
            memcpy(new_ptr, old_ptr, old_size);
        }
        _sgimgui_free(allocator, old_ptr);
    }
    return new_ptr;
}

i32 _sgimgui_slot_index(u32 id) {
    var slot_index = cast(i32, id & 0xFFFF);
    return slot_index;
}

u32 _sgimgui_align_u32(u32 val, u32 align) {
    return val + (align - 1) & ~(align - 1);
}

u32 _sgimgui_std140_uniform_alignment(sg_uniform_type type, i32 array_count) {
    if array_count == 1 {
        switch type {
            case SG_UNIFORMTYPE_FLOAT, SG_UNIFORMTYPE_INT: {
                return 4;
            }
            case SG_UNIFORMTYPE_FLOAT2, SG_UNIFORMTYPE_INT2: {
                return 8;
            }
            case SG_UNIFORMTYPE_FLOAT3, SG_UNIFORMTYPE_FLOAT4, SG_UNIFORMTYPE_INT3, SG_UNIFORMTYPE_INT4: {
                return 16;
            }
            case SG_UNIFORMTYPE_MAT4: {
                return 16;
            }
            default: {
                return 1;
            }
        }
    } else {
        return 16;
    }
}

u32 _sgimgui_std140_uniform_size(sg_uniform_type type, i32 array_count) {
    if array_count == 1 {
        switch type {
            case SG_UNIFORMTYPE_FLOAT, SG_UNIFORMTYPE_INT: {
                return 4;
            }
            case SG_UNIFORMTYPE_FLOAT2, SG_UNIFORMTYPE_INT2: {
                return 8;
            }
            case SG_UNIFORMTYPE_FLOAT3, SG_UNIFORMTYPE_INT3: {
                return 12;
            }
            case SG_UNIFORMTYPE_FLOAT4, SG_UNIFORMTYPE_INT4: {
                return 16;
            }
            case SG_UNIFORMTYPE_MAT4: {
                return 64;
            }
            default: {
                return 0;
            }
        }
    } else {
        switch type {
            case SG_UNIFORMTYPE_FLOAT, SG_UNIFORMTYPE_FLOAT2, SG_UNIFORMTYPE_FLOAT3, SG_UNIFORMTYPE_FLOAT4, SG_UNIFORMTYPE_INT, SG_UNIFORMTYPE_INT2, SG_UNIFORMTYPE_INT3, SG_UNIFORMTYPE_INT4: {
                return 16 * cast(u32, array_count);
            }
            case SG_UNIFORMTYPE_MAT4: {
                return 64 * cast(u32, array_count);
            }
            default: {
                return 0;
            }
        }
    }
}

void _sgimgui_strcpy(_sgimgui_str_t* dst, u8* src) {
    if src != null {
        strncpy(dst.buf, src, cast(u64, 96));
        dst.buf[96 - 1] = 0;
    } else {
        _sgimgui_clear(dst.buf, 96);
    }
}

_sgimgui_str_t _sgimgui_make_str(u8* str_var) {
    noinit _sgimgui_str_t res;
    _sgimgui_strcpy(&res, str_var);
    return res;
}

u8* _sgimgui_str_dup(sgimgui_allocator_t* allocator, u8* src) {
    u64 len = strlen(src) + 1;
    var dst = cast(u8*, _sgimgui_malloc(allocator, len));
    memcpy(dst, src, len);
    return dst;
}

void* _sgimgui_bin_dup(sgimgui_allocator_t* allocator, void* src, u64 num_bytes) {
    void* dst = _sgimgui_malloc(allocator, num_bytes);
    memcpy(dst, src, num_bytes);
    return dst;
}

void _sgimgui_snprintf(_sgimgui_str_t* dst, u8* fmt, ...) {
    vsnprintf(dst.buf, sizeof(dst.buf), fmt, &...);
    dst.buf[sizeof(dst.buf) - 1] = 0;
}

/*--- STRING CONVERSION ------------------------------------------------------*/
u8* _sgimgui_resourcestate_string(sg_resource_state s) {
    switch s {
        case SG_RESOURCESTATE_INITIAL: {
            return "INITIAL";
        }
        case SG_RESOURCESTATE_ALLOC: {
            return "ALLOC";
        }
        case SG_RESOURCESTATE_UNSEALED: {
            return "UNSEALED";
        }
        case SG_RESOURCESTATE_VALID: {
            return "VALID";
        }
        case SG_RESOURCESTATE_FAILED: {
            return "FAILED";
        }
        default: {
            return "INVALID";
        }
    }
}

void _sgimgui_draw_resource_slot(sg_slot_info* slot) {
    _sgimgui_igtext("ResId: %08X", slot.res_id);
    _sgimgui_igtext("State: %s", _sgimgui_resourcestate_string(slot.state));
    _sgimgui_igtext("Uninit Count: %d", slot.uninit_count);
}

u8* _sgimgui_backend_string(sg_backend b) {
    switch b {
        case SG_BACKEND_GLCORE: {
            return "GLCORE";
        }
        case SG_BACKEND_GLES3: {
            return "GLES3";
        }
        case SG_BACKEND_D3D11: {
            return "D3D11";
        }
        case SG_BACKEND_METAL_IOS: {
            return "METAL_IOS";
        }
        case SG_BACKEND_METAL_MACOS: {
            return "METAL_MACOS";
        }
        case SG_BACKEND_METAL_SIMULATOR: {
            return "METAL_SIMULATOR";
        }
        case SG_BACKEND_WGPU: {
            return "WGPU";
        }
        case SG_BACKEND_VULKAN: {
            return "VULKAN";
        }
        case SG_BACKEND_DUMMY: {
            return "DUMMY";
        }
        default: {
            return "???";
        }
    }
}

u8* _sgimgui_imagetype_string(sg_image_type t) {
    switch t {
        case SG_IMAGETYPE_2D: {
            return "2D";
        }
        case SG_IMAGETYPE_CUBE: {
            return "CUBE";
        }
        case SG_IMAGETYPE_3D: {
            return "3D";
        }
        case SG_IMAGETYPE_ARRAY: {
            return "ARRAY";
        }
        default: {
            return "???";
        }
    }
}

u8* _sgimgui_imagesampletype_string(sg_image_sample_type t) {
    switch t {
        case SG_IMAGESAMPLETYPE_FLOAT: {
            return "FLOAT";
        }
        case SG_IMAGESAMPLETYPE_DEPTH: {
            return "DEPTH";
        }
        case SG_IMAGESAMPLETYPE_SINT: {
            return "SINT";
        }
        case SG_IMAGESAMPLETYPE_UINT: {
            return "UINT";
        }
        case SG_IMAGESAMPLETYPE_UNFILTERABLE_FLOAT: {
            return "UNFILTERABLE_FLOAT";
        }
        default: {
            return "???";
        }
    }
}

u8* _sgimgui_samplertype_string(sg_sampler_type t) {
    switch t {
        case SG_SAMPLERTYPE_FILTERING: {
            return "FILTERING";
        }
        case SG_SAMPLERTYPE_COMPARISON: {
            return "COMPARISON";
        }
        case SG_SAMPLERTYPE_NONFILTERING: {
            return "NONFILTERING";
        }
        default: {
            return "???";
        }
    }
}

u8* _sgimgui_uniformlayout_string(sg_uniform_layout l) {
    switch l {
        case SG_UNIFORMLAYOUT_NATIVE: {
            return "NATIVE";
        }
        case SG_UNIFORMLAYOUT_STD140: {
            return "STD140";
        }
        default: {
            return "???";
        }
    }
}

u8* _sgimgui_pixelformat_string(sg_pixel_format fmt) {
    switch fmt {
        case SG_PIXELFORMAT_NONE: {
            return "NONE";
        }
        case SG_PIXELFORMAT_R8: {
            return "R8";
        }
        case SG_PIXELFORMAT_R8SN: {
            return "R8SN";
        }
        case SG_PIXELFORMAT_R8UI: {
            return "R8UI";
        }
        case SG_PIXELFORMAT_R8SI: {
            return "R8SI";
        }
        case SG_PIXELFORMAT_R16: {
            return "R16";
        }
        case SG_PIXELFORMAT_R16SN: {
            return "R16SN";
        }
        case SG_PIXELFORMAT_R16UI: {
            return "R16UI";
        }
        case SG_PIXELFORMAT_R16SI: {
            return "R16SI";
        }
        case SG_PIXELFORMAT_R16F: {
            return "R16F";
        }
        case SG_PIXELFORMAT_RG8: {
            return "RG8";
        }
        case SG_PIXELFORMAT_RG8SN: {
            return "RG8SN";
        }
        case SG_PIXELFORMAT_RG8UI: {
            return "RG8UI";
        }
        case SG_PIXELFORMAT_RG8SI: {
            return "RG8SI";
        }
        case SG_PIXELFORMAT_R32UI: {
            return "R32UI";
        }
        case SG_PIXELFORMAT_R32SI: {
            return "R32SI";
        }
        case SG_PIXELFORMAT_R32F: {
            return "R32F";
        }
        case SG_PIXELFORMAT_RG16: {
            return "RG16";
        }
        case SG_PIXELFORMAT_RG16SN: {
            return "RG16SN";
        }
        case SG_PIXELFORMAT_RG16UI: {
            return "RG16UI";
        }
        case SG_PIXELFORMAT_RG16SI: {
            return "RG16SI";
        }
        case SG_PIXELFORMAT_RG16F: {
            return "RG16F";
        }
        case SG_PIXELFORMAT_RGBA8: {
            return "RGBA8";
        }
        case SG_PIXELFORMAT_SRGB8A8: {
            return "SRGB8A8";
        }
        case SG_PIXELFORMAT_RGBA8SN: {
            return "RGBA8SN";
        }
        case SG_PIXELFORMAT_RGBA8UI: {
            return "RGBA8UI";
        }
        case SG_PIXELFORMAT_RGBA8SI: {
            return "RGBA8SI";
        }
        case SG_PIXELFORMAT_BGRA8: {
            return "BGRA8";
        }
        case SG_PIXELFORMAT_SBGR8A8: {
            return "SBGR8A8";
        }
        case SG_PIXELFORMAT_RGB10A2: {
            return "RGB10A2";
        }
        case SG_PIXELFORMAT_RG11B10F: {
            return "RG11B10F";
        }
        case SG_PIXELFORMAT_RG32UI: {
            return "RG32UI";
        }
        case SG_PIXELFORMAT_RG32SI: {
            return "RG32SI";
        }
        case SG_PIXELFORMAT_RG32F: {
            return "RG32F";
        }
        case SG_PIXELFORMAT_RGBA16: {
            return "RGBA16";
        }
        case SG_PIXELFORMAT_RGBA16SN: {
            return "RGBA16SN";
        }
        case SG_PIXELFORMAT_RGBA16UI: {
            return "RGBA16UI";
        }
        case SG_PIXELFORMAT_RGBA16SI: {
            return "RGBA16SI";
        }
        case SG_PIXELFORMAT_RGBA16F: {
            return "RGBA16F";
        }
        case SG_PIXELFORMAT_RGBA32UI: {
            return "RGBA32UI";
        }
        case SG_PIXELFORMAT_RGBA32SI: {
            return "RGBA32SI";
        }
        case SG_PIXELFORMAT_RGBA32F: {
            return "RGBA32F";
        }
        case SG_PIXELFORMAT_DEPTH: {
            return "DEPTH";
        }
        case SG_PIXELFORMAT_DEPTH_STENCIL: {
            return "DEPTH_STENCIL";
        }
        case SG_PIXELFORMAT_BC1_RGBA: {
            return "BC1_RGBA";
        }
        case SG_PIXELFORMAT_BC2_RGBA: {
            return "BC2_RGBA";
        }
        case SG_PIXELFORMAT_BC3_RGBA: {
            return "BC3_RGBA";
        }
        case SG_PIXELFORMAT_BC4_R: {
            return "BC4_R";
        }
        case SG_PIXELFORMAT_BC4_RSN: {
            return "BC4_RSN";
        }
        case SG_PIXELFORMAT_BC5_RG: {
            return "BC5_RG";
        }
        case SG_PIXELFORMAT_BC5_RGSN: {
            return "BC5_RGSN";
        }
        case SG_PIXELFORMAT_BC6H_RGBF: {
            return "BC6H_RGBF";
        }
        case SG_PIXELFORMAT_BC6H_RGBUF: {
            return "BC6H_RGBUF";
        }
        case SG_PIXELFORMAT_BC7_RGBA: {
            return "BC7_RGBA";
        }
        case SG_PIXELFORMAT_ETC2_RGB8: {
            return "ETC2_RGB8";
        }
        case SG_PIXELFORMAT_ETC2_RGB8A1: {
            return "ETC2_RGB8A1";
        }
        case SG_PIXELFORMAT_ETC2_RGBA8: {
            return "ETC2_RGBA8";
        }
        case SG_PIXELFORMAT_EAC_R11: {
            return "EAC_R11";
        }
        case SG_PIXELFORMAT_EAC_R11SN: {
            return "EAC_R11SN";
        }
        case SG_PIXELFORMAT_EAC_RG11: {
            return "EAC_RG11";
        }
        case SG_PIXELFORMAT_EAC_RG11SN: {
            return "EAC_RG11SN";
        }
        case SG_PIXELFORMAT_RGB9E5: {
            return "RGB9E5";
        }
        case SG_PIXELFORMAT_BC3_SRGBA: {
            return "BC3_SRGBA";
        }
        case SG_PIXELFORMAT_BC7_SRGBA: {
            return "BC7_SRGBA";
        }
        case SG_PIXELFORMAT_ETC2_SRGB8: {
            return "ETC2_SRGB8";
        }
        case SG_PIXELFORMAT_ETC2_SRGB8A8: {
            return "ETC2_SRGB8A8";
        }
        case SG_PIXELFORMAT_ASTC_4x4_RGBA: {
            return "ASTC_4x4_RGBA";
        }
        case SG_PIXELFORMAT_ASTC_4x4_SRGBA: {
            return "ASTC_4x4_SRGBA";
        }
        default: {
            return "???";
        }
    }
}

u8* _sgimgui_filter_string(sg_filter f) {
    switch f {
        case SG_FILTER_NEAREST: {
            return "NEAREST";
        }
        case SG_FILTER_LINEAR: {
            return "LINEAR";
        }
        default: {
            return "???";
        }
    }
}

u8* _sgimgui_wrap_string(sg_wrap w) {
    switch w {
        case SG_WRAP_REPEAT: {
            return "REPEAT";
        }
        case SG_WRAP_CLAMP_TO_EDGE: {
            return "CLAMP_TO_EDGE";
        }
        case SG_WRAP_CLAMP_TO_BORDER: {
            return "CLAMP_TO_BORDER";
        }
        case SG_WRAP_MIRRORED_REPEAT: {
            return "MIRRORED_REPEAT";
        }
        default: {
            return "???";
        }
    }
}

u8* _sgimgui_bordercolor_string(sg_border_color bc) {
    switch bc {
        case SG_BORDERCOLOR_TRANSPARENT_BLACK: {
            return "TRANSPARENT_BLACK";
        }
        case SG_BORDERCOLOR_OPAQUE_BLACK: {
            return "OPAQUE_BLACK";
        }
        case SG_BORDERCOLOR_OPAQUE_WHITE: {
            return "OPAQUE_WHITE";
        }
        default: {
            return "???";
        }
    }
}

u8* _sgimgui_uniformtype_string(sg_uniform_type t) {
    switch t {
        case SG_UNIFORMTYPE_FLOAT: {
            return "FLOAT";
        }
        case SG_UNIFORMTYPE_FLOAT2: {
            return "FLOAT2";
        }
        case SG_UNIFORMTYPE_FLOAT3: {
            return "FLOAT3";
        }
        case SG_UNIFORMTYPE_FLOAT4: {
            return "FLOAT4";
        }
        case SG_UNIFORMTYPE_INT: {
            return "INT";
        }
        case SG_UNIFORMTYPE_INT2: {
            return "INT2";
        }
        case SG_UNIFORMTYPE_INT3: {
            return "INT3";
        }
        case SG_UNIFORMTYPE_INT4: {
            return "INT4";
        }
        case SG_UNIFORMTYPE_MAT4: {
            return "MAT4";
        }
        default: {
            return "???";
        }
    }
}

u8* _sgimgui_vertexstep_string(sg_vertex_step s) {
    switch s {
        case SG_VERTEXSTEP_PER_VERTEX: {
            return "PER_VERTEX";
        }
        case SG_VERTEXSTEP_PER_INSTANCE: {
            return "PER_INSTANCE";
        }
        default: {
            return "???";
        }
    }
}

u8* _sgimgui_vertexformat_string(sg_vertex_format f) {
    switch f {
        case SG_VERTEXFORMAT_FLOAT: {
            return "FLOAT";
        }
        case SG_VERTEXFORMAT_FLOAT2: {
            return "FLOAT2";
        }
        case SG_VERTEXFORMAT_FLOAT3: {
            return "FLOAT3";
        }
        case SG_VERTEXFORMAT_FLOAT4: {
            return "FLOAT4";
        }
        case SG_VERTEXFORMAT_INT: {
            return "INT";
        }
        case SG_VERTEXFORMAT_INT2: {
            return "INT2";
        }
        case SG_VERTEXFORMAT_INT3: {
            return "INT3";
        }
        case SG_VERTEXFORMAT_INT4: {
            return "INT4";
        }
        case SG_VERTEXFORMAT_UINT: {
            return "UINT";
        }
        case SG_VERTEXFORMAT_UINT2: {
            return "UINT2";
        }
        case SG_VERTEXFORMAT_UINT3: {
            return "UINT3";
        }
        case SG_VERTEXFORMAT_UINT4: {
            return "UINT4";
        }
        case SG_VERTEXFORMAT_BYTE4: {
            return "BYTE4";
        }
        case SG_VERTEXFORMAT_BYTE4N: {
            return "BYTE4N";
        }
        case SG_VERTEXFORMAT_UBYTE4: {
            return "UBYTE4";
        }
        case SG_VERTEXFORMAT_UBYTE4N: {
            return "UBYTE4N";
        }
        case SG_VERTEXFORMAT_SHORT2: {
            return "SHORT2";
        }
        case SG_VERTEXFORMAT_SHORT2N: {
            return "SHORT2N";
        }
        case SG_VERTEXFORMAT_USHORT2: {
            return "USHORT2";
        }
        case SG_VERTEXFORMAT_USHORT2N: {
            return "USHORT2N";
        }
        case SG_VERTEXFORMAT_SHORT4: {
            return "SHORT4";
        }
        case SG_VERTEXFORMAT_SHORT4N: {
            return "SHORT4N";
        }
        case SG_VERTEXFORMAT_USHORT4: {
            return "USHORT4";
        }
        case SG_VERTEXFORMAT_USHORT4N: {
            return "USHORT4N";
        }
        case SG_VERTEXFORMAT_INT10_N2: {
            return "INT10_N2";
        }
        case SG_VERTEXFORMAT_UINT10_N2: {
            return "UINT10_N2";
        }
        case SG_VERTEXFORMAT_HALF2: {
            return "HALF2";
        }
        case SG_VERTEXFORMAT_HALF4: {
            return "HALF4";
        }
        default: {
            return "???";
        }
    }
}

u8* _sgimgui_primitivetype_string(sg_primitive_type t) {
    switch t {
        case SG_PRIMITIVETYPE_POINTS: {
            return "POINTS";
        }
        case SG_PRIMITIVETYPE_LINES: {
            return "LINES";
        }
        case SG_PRIMITIVETYPE_LINE_STRIP: {
            return "LINE_STRIP";
        }
        case SG_PRIMITIVETYPE_TRIANGLES: {
            return "TRIANGLES";
        }
        case SG_PRIMITIVETYPE_TRIANGLE_STRIP: {
            return "TRIANGLE_STRIP";
        }
        default: {
            return "???";
        }
    }
}

u8* _sgimgui_indextype_string(sg_index_type t) {
    switch t {
        case SG_INDEXTYPE_NONE: {
            return "NONE";
        }
        case SG_INDEXTYPE_UINT16: {
            return "UINT16";
        }
        case SG_INDEXTYPE_UINT32: {
            return "UINT32";
        }
        default: {
            return "???";
        }
    }
}

u8* _sgimgui_stencilop_string(sg_stencil_op op) {
    switch op {
        case SG_STENCILOP_KEEP: {
            return "KEEP";
        }
        case SG_STENCILOP_ZERO: {
            return "ZERO";
        }
        case SG_STENCILOP_REPLACE: {
            return "REPLACE";
        }
        case SG_STENCILOP_INCR_CLAMP: {
            return "INCR_CLAMP";
        }
        case SG_STENCILOP_DECR_CLAMP: {
            return "DECR_CLAMP";
        }
        case SG_STENCILOP_INVERT: {
            return "INVERT";
        }
        case SG_STENCILOP_INCR_WRAP: {
            return "INCR_WRAP";
        }
        case SG_STENCILOP_DECR_WRAP: {
            return "DECR_WRAP";
        }
        default: {
            return "???";
        }
    }
}

u8* _sgimgui_comparefunc_string(sg_compare_func f) {
    switch f {
        case SG_COMPAREFUNC_NEVER: {
            return "NEVER";
        }
        case SG_COMPAREFUNC_LESS: {
            return "LESS";
        }
        case SG_COMPAREFUNC_EQUAL: {
            return "EQUAL";
        }
        case SG_COMPAREFUNC_LESS_EQUAL: {
            return "LESS_EQUAL";
        }
        case SG_COMPAREFUNC_GREATER: {
            return "GREATER";
        }
        case SG_COMPAREFUNC_NOT_EQUAL: {
            return "NOT_EQUAL";
        }
        case SG_COMPAREFUNC_GREATER_EQUAL: {
            return "GREATER_EQUAL";
        }
        case SG_COMPAREFUNC_ALWAYS: {
            return "ALWAYS";
        }
        default: {
            return "???";
        }
    }
}

u8* _sgimgui_blendfactor_string(sg_blend_factor f) {
    switch f {
        case SG_BLENDFACTOR_ZERO: {
            return "ZERO";
        }
        case SG_BLENDFACTOR_ONE: {
            return "ONE";
        }
        case SG_BLENDFACTOR_SRC_COLOR: {
            return "SRC_COLOR";
        }
        case SG_BLENDFACTOR_ONE_MINUS_SRC_COLOR: {
            return "ONE_MINUS_SRC_COLOR";
        }
        case SG_BLENDFACTOR_SRC_ALPHA: {
            return "SRC_ALPHA";
        }
        case SG_BLENDFACTOR_ONE_MINUS_SRC_ALPHA: {
            return "ONE_MINUS_SRC_ALPHA";
        }
        case SG_BLENDFACTOR_DST_COLOR: {
            return "DST_COLOR";
        }
        case SG_BLENDFACTOR_ONE_MINUS_DST_COLOR: {
            return "ONE_MINUS_DST_COLOR";
        }
        case SG_BLENDFACTOR_DST_ALPHA: {
            return "DST_ALPHA";
        }
        case SG_BLENDFACTOR_ONE_MINUS_DST_ALPHA: {
            return "ONE_MINUS_DST_ALPHA";
        }
        case SG_BLENDFACTOR_SRC_ALPHA_SATURATED: {
            return "SRC_ALPHA_SATURATED";
        }
        case SG_BLENDFACTOR_BLEND_COLOR: {
            return "BLEND_COLOR";
        }
        case SG_BLENDFACTOR_ONE_MINUS_BLEND_COLOR: {
            return "ONE_MINUS_BLEND_COLOR";
        }
        case SG_BLENDFACTOR_BLEND_ALPHA: {
            return "BLEND_ALPHA";
        }
        case SG_BLENDFACTOR_ONE_MINUS_BLEND_ALPHA: {
            return "ONE_MINUS_BLEND_ALPHA";
        }
        case SG_BLENDFACTOR_SRC1_COLOR: {
            return "SRC1_COLOR";
        }
        case SG_BLENDFACTOR_ONE_MINUS_SRC1_COLOR: {
            return "ONE_MINUS_SRC1_COLOR";
        }
        case SG_BLENDFACTOR_SRC1_ALPHA: {
            return "SRC1_ALPHA";
        }
        case SG_BLENDFACTOR_ONE_MINUS_SRC1_ALPHA: {
            return "ONE_MINUS_SRC1_ALPHA";
        }
        default: {
            return "???";
        }
    }
}

u8* _sgimgui_blendop_string(sg_blend_op op) {
    switch op {
        case SG_BLENDOP_ADD: {
            return "ADD";
        }
        case SG_BLENDOP_SUBTRACT: {
            return "SUBTRACT";
        }
        case SG_BLENDOP_REVERSE_SUBTRACT: {
            return "REVERSE_SUBTRACT";
        }
        case SG_BLENDOP_MIN: {
            return "MIN";
        }
        case SG_BLENDOP_MAX: {
            return "MAX";
        }
        default: {
            return "???";
        }
    }
}

u8* _sgimgui_colormask_string(sg_color_mask m) {
    return _sgimgui_colormask_string__str_var[m & 0xF];
}

u8* _sgimgui_cullmode_string(sg_cull_mode cm) {
    switch cm {
        case SG_CULLMODE_NONE: {
            return "NONE";
        }
        case SG_CULLMODE_FRONT: {
            return "FRONT";
        }
        case SG_CULLMODE_BACK: {
            return "BACK";
        }
        default: {
            return "???";
        }
    }
}

u8* _sgimgui_facewinding_string(sg_face_winding fw) {
    switch fw {
        case SG_FACEWINDING_CCW: {
            return "CCW";
        }
        case SG_FACEWINDING_CW: {
            return "CW";
        }
        default: {
            return "???";
        }
    }
}

u8* _sgimgui_shaderstage_string(sg_shader_stage stage) {
    switch stage {
        case SG_SHADERSTAGE_VERTEX: {
            return "VERTEX";
        }
        case SG_SHADERSTAGE_FRAGMENT: {
            return "FRAGMENT";
        }
        case SG_SHADERSTAGE_COMPUTE: {
            return "COMPUTE";
        }
        default: {
            return "???";
        }
    }
}

u8* _sgimgui_shaderattrbasetype_string(sg_shader_attr_base_type b) {
    switch b {
        case SG_SHADERATTRBASETYPE_UNDEFINED: {
            return "UNDEFINED";
        }
        case SG_SHADERATTRBASETYPE_FLOAT: {
            return "FLOAT";
        }
        case SG_SHADERATTRBASETYPE_SINT: {
            return "SINT";
        }
        case SG_SHADERATTRBASETYPE_UINT: {
            return "UINT";
        }
        default: {
            return "???";
        }
    }
}

u8* _sgimgui_bool_string(bool b) {
    return b != 0 ? "true" : "false";
}

u8* _sgimgui_color_string(_sgimgui_str_t* dst_str, sg_color color) {
    _sgimgui_snprintf(dst_str, "%.3f %.3f %.3f %.3f", color.r, color.g, color.b, color.a);
    return dst_str.buf;
}

_sgimgui_str_t _sgimgui_res_id_string(u32 res_id, u8* label) {
    noinit _sgimgui_str_t res;
    if label[0] != 0 {
        _sgimgui_snprintf(&res, "'%s'", label);
    } else {
        _sgimgui_snprintf(&res, "0x%08X", res_id);
    }
    return res;
}

_sgimgui_str_t _sgimgui_buffer_id_string(_sgimgui_t* ctx, sg_buffer buf_id) {
    if buf_id.id != cast(u32, SG_INVALID_ID) {
        _sgimgui_buffer_t* buf_ui = &ctx.buffer_window.slots[_sgimgui_slot_index(buf_id.id)];
        return _sgimgui_res_id_string(buf_id.id, buf_ui.label.buf);
    } else {
        return _sgimgui_make_str("<invalid>");
    }
}

_sgimgui_str_t _sgimgui_image_id_string(_sgimgui_t* ctx, sg_image img_id) {
    if img_id.id != cast(u32, SG_INVALID_ID) {
        _sgimgui_image_t* img_ui = &ctx.image_window.slots[_sgimgui_slot_index(img_id.id)];
        return _sgimgui_res_id_string(img_id.id, img_ui.label.buf);
    } else {
        return _sgimgui_make_str("<invalid>");
    }
}

_sgimgui_str_t _sgimgui_sampler_id_string(_sgimgui_t* ctx, sg_sampler smp_id) {
    if smp_id.id != cast(u32, SG_INVALID_ID) {
        _sgimgui_sampler_t* smp_ui = &ctx.sampler_window.slots[_sgimgui_slot_index(smp_id.id)];
        return _sgimgui_res_id_string(smp_id.id, smp_ui.label.buf);
    } else {
        return _sgimgui_make_str("<invalid>");
    }
}

_sgimgui_str_t _sgimgui_shader_id_string(_sgimgui_t* ctx, sg_shader shd_id) {
    if shd_id.id != cast(u32, SG_INVALID_ID) {
        _sgimgui_shader_t* shd_ui = &ctx.shader_window.slots[_sgimgui_slot_index(shd_id.id)];
        return _sgimgui_res_id_string(shd_id.id, shd_ui.label.buf);
    } else {
        return _sgimgui_make_str("<invalid>");
    }
}

_sgimgui_str_t _sgimgui_pipeline_id_string(_sgimgui_t* ctx, sg_pipeline pip_id) {
    if pip_id.id != cast(u32, SG_INVALID_ID) {
        _sgimgui_pipeline_t* pip_ui = &ctx.pipeline_window.slots[_sgimgui_slot_index(pip_id.id)];
        return _sgimgui_res_id_string(pip_id.id, pip_ui.label.buf);
    } else {
        return _sgimgui_make_str("<invalid>");
    }
}

_sgimgui_str_t _sgimgui_view_id_string(_sgimgui_t* ctx, sg_view view_id) {
    if view_id.id != cast(u32, SG_INVALID_ID) {
        _sgimgui_view_t* view_ui = &ctx.view_window.slots[_sgimgui_slot_index(view_id.id)];
        return _sgimgui_res_id_string(view_id.id, view_ui.label.buf);
    } else {
        return _sgimgui_make_str("<invalid>");
    }
}

/*--- RESOURCE HELPERS -------------------------------------------------------*/
void _sgimgui_buffer_created(_sgimgui_t* ctx, sg_buffer res_id, i32 slot_index, sg_buffer_desc* desc) {
    _sgimgui_buffer_t* buf = &ctx.buffer_window.slots[slot_index];
    buf.res_id = res_id;
    buf.desc = *desc;
    buf.label = _sgimgui_make_str(desc.label);
}

void _sgimgui_buffer_destroyed(_sgimgui_t* ctx, i32 slot_index) {
    _sgimgui_buffer_t* buf = &ctx.buffer_window.slots[slot_index];
    buf.res_id.id = cast(u32, SG_INVALID_ID);
}

void _sgimgui_image_created(_sgimgui_t* ctx, sg_image res_id, i32 slot_index, sg_image_desc* desc) {
    _sgimgui_image_t* img = &ctx.image_window.slots[slot_index];
    img.res_id = res_id;
    img.desc = *desc;
    img.ui_scale = 1.0f;
    img.label = _sgimgui_make_str(desc.label);
}

void _sgimgui_image_destroyed(_sgimgui_t* ctx, i32 slot_index) {
    _sgimgui_image_t* img = &ctx.image_window.slots[slot_index];
    img.res_id.id = cast(u32, SG_INVALID_ID);
}

void _sgimgui_sampler_created(_sgimgui_t* ctx, sg_sampler res_id, i32 slot_index, sg_sampler_desc* desc) {
    _sgimgui_sampler_t* smp = &ctx.sampler_window.slots[slot_index];
    smp.res_id = res_id;
    smp.desc = *desc;
    smp.label = _sgimgui_make_str(desc.label);
}

void _sgimgui_sampler_destroyed(_sgimgui_t* ctx, i32 slot_index) {
    _sgimgui_sampler_t* smp = &ctx.sampler_window.slots[slot_index];
    smp.res_id.id = cast(u32, SG_INVALID_ID);
}

void _sgimgui_shader_created(_sgimgui_t* ctx, sg_shader res_id, i32 slot_index, sg_shader_desc* desc) {
    _sgimgui_shader_t* shd = &ctx.shader_window.slots[slot_index];
    shd.res_id = res_id;
    shd.desc = *desc;
    shd.label = _sgimgui_make_str(desc.label);
    if shd.desc.vertex_func.entry != null {
        shd.vs_entry = _sgimgui_make_str(shd.desc.vertex_func.entry);
        shd.desc.vertex_func.entry = shd.vs_entry.buf;
    }
    if shd.desc.fragment_func.entry != null {
        shd.fs_entry = _sgimgui_make_str(shd.desc.fragment_func.entry);
        shd.desc.fragment_func.entry = shd.fs_entry.buf;
    }
    if shd.desc.compute_func.entry != null {
        shd.cs_entry = _sgimgui_make_str(shd.desc.compute_func.entry);
        shd.desc.compute_func.entry = shd.cs_entry.buf;
    }
    if shd.desc.vertex_func.d3d11_target != null {
        shd.vs_d3d11_target = _sgimgui_make_str(shd.desc.vertex_func.d3d11_target);
        shd.desc.vertex_func.d3d11_target = shd.vs_d3d11_target.buf;
    }
    if shd.desc.fragment_func.d3d11_target != null {
        shd.fs_d3d11_target = _sgimgui_make_str(shd.desc.fragment_func.d3d11_target);
        shd.desc.fragment_func.d3d11_target = shd.fs_d3d11_target.buf;
    }
    if shd.desc.compute_func.d3d11_target != null {
        shd.cs_d3d11_target = _sgimgui_make_str(shd.desc.compute_func.d3d11_target);
        shd.desc.compute_func.d3d11_target = shd.cs_d3d11_target.buf;
    }
    for i32 i = 0; i < SG_MAX_UNIFORMBLOCK_BINDSLOTS; i++ {
        for i32 j = 0; j < SG_MAX_UNIFORMBLOCK_MEMBERS; j++ {
            sg_glsl_shader_uniform* su = &shd.desc.uniform_blocks[i].glsl_uniforms[j];
            if su.glsl_name != null {
                shd.glsl_uniform_name[i][j] = _sgimgui_make_str(su.glsl_name);
                su.glsl_name = shd.glsl_uniform_name[i][j].buf;
            }
        }
    }
    for i32 i = 0; i < SG_MAX_TEXTURE_SAMPLER_PAIRS; i++ {
        if shd.desc.texture_sampler_pairs[i].glsl_name != null {
            shd.glsl_texture_sampler_name[i] = _sgimgui_make_str(shd.desc.texture_sampler_pairs[i].glsl_name);
            shd.desc.texture_sampler_pairs[i].glsl_name = shd.glsl_texture_sampler_name[i].buf;
        }
    }
    if shd.desc.vertex_func.source != null {
        shd.desc.vertex_func.source = _sgimgui_str_dup(&ctx.desc.allocator, shd.desc.vertex_func.source);
    }
    if shd.desc.vertex_func.bytecode.ptr != null {
        shd.desc.vertex_func.bytecode.ptr = _sgimgui_bin_dup(&ctx.desc.allocator, shd.desc.vertex_func.bytecode.ptr, shd.desc.vertex_func.bytecode.size);
    }
    if shd.desc.fragment_func.source != null {
        shd.desc.fragment_func.source = _sgimgui_str_dup(&ctx.desc.allocator, shd.desc.fragment_func.source);
    }
    if shd.desc.fragment_func.bytecode.ptr != null {
        shd.desc.fragment_func.bytecode.ptr = _sgimgui_bin_dup(&ctx.desc.allocator, shd.desc.fragment_func.bytecode.ptr, shd.desc.fragment_func.bytecode.size);
    }
    if shd.desc.compute_func.source != null {
        shd.desc.compute_func.source = _sgimgui_str_dup(&ctx.desc.allocator, shd.desc.compute_func.source);
    }
    if shd.desc.compute_func.bytecode.ptr != null {
        shd.desc.compute_func.bytecode.ptr = _sgimgui_bin_dup(&ctx.desc.allocator, shd.desc.compute_func.bytecode.ptr, shd.desc.compute_func.bytecode.size);
    }
    for i32 i = 0; i < SG_MAX_VERTEX_ATTRIBUTES; i++ {
        sg_shader_vertex_attr* va = &shd.desc.attrs[i];
        if va.glsl_name != null {
            shd.attr_glsl_name[i] = _sgimgui_make_str(va.glsl_name);
            va.glsl_name = shd.attr_glsl_name[i].buf;
        }
        if va.hlsl_sem_name != null {
            shd.attr_hlsl_sem_name[i] = _sgimgui_make_str(va.hlsl_sem_name);
            va.hlsl_sem_name = shd.attr_hlsl_sem_name[i].buf;
        }
    }
}

void _sgimgui_shader_destroyed(_sgimgui_t* ctx, i32 slot_index) {
    _sgimgui_shader_t* shd = &ctx.shader_window.slots[slot_index];
    shd.res_id.id = cast(u32, SG_INVALID_ID);
    if shd.desc.vertex_func.source != null {
        _sgimgui_free(&ctx.desc.allocator, cast(void*, shd.desc.vertex_func.source));
        shd.desc.vertex_func.source = null;
    }
    if shd.desc.vertex_func.bytecode.ptr != null {
        _sgimgui_free(&ctx.desc.allocator, shd.desc.vertex_func.bytecode.ptr);
        shd.desc.vertex_func.bytecode.ptr = null;
    }
    if shd.desc.fragment_func.source != null {
        _sgimgui_free(&ctx.desc.allocator, cast(void*, shd.desc.fragment_func.source));
        shd.desc.fragment_func.source = null;
    }
    if shd.desc.fragment_func.bytecode.ptr != null {
        _sgimgui_free(&ctx.desc.allocator, shd.desc.fragment_func.bytecode.ptr);
        shd.desc.fragment_func.bytecode.ptr = null;
    }
    if shd.desc.compute_func.source != null {
        _sgimgui_free(&ctx.desc.allocator, cast(void*, shd.desc.compute_func.source));
        shd.desc.compute_func.source = null;
    }
    if shd.desc.compute_func.bytecode.ptr != null {
        _sgimgui_free(&ctx.desc.allocator, shd.desc.compute_func.bytecode.ptr);
        shd.desc.compute_func.bytecode.ptr = null;
    }
}

void _sgimgui_pipeline_created(_sgimgui_t* ctx, sg_pipeline res_id, i32 slot_index, sg_pipeline_desc* desc) {
    _sgimgui_pipeline_t* pip = &ctx.pipeline_window.slots[slot_index];
    pip.res_id = res_id;
    pip.label = _sgimgui_make_str(desc.label);
    pip.desc = *desc;
}

void _sgimgui_pipeline_destroyed(_sgimgui_t* ctx, i32 slot_index) {
    _sgimgui_pipeline_t* pip = &ctx.pipeline_window.slots[slot_index];
    pip.res_id.id = cast(u32, SG_INVALID_ID);
}

void _sgimgui_view_created(_sgimgui_t* ctx, sg_view res_id, i32 slot_index, sg_view_desc* desc) {
    _sgimgui_view_t* view = &ctx.view_window.slots[slot_index];
    view.res_id = res_id;
    view.ui_scale = 1.0f;
    view.label = _sgimgui_make_str(desc.label);
    view.desc = *desc;
}

void _sgimgui_view_destroyed(_sgimgui_t* ctx, i32 slot_index) {
    _sgimgui_view_t* view = &ctx.view_window.slots[slot_index];
    view.res_id.id = cast(u32, SG_INVALID_ID);
}

/*--- COMMAND CAPTURING ------------------------------------------------------*/
void _sgimgui_capture_init(_sgimgui_t* ctx) {
    var ubuf_initial_size = cast(u64, 256 * 1024);
    for i32 i = 0; i < 2; i++ {
        _sgimgui_capture_bucket_t* bucket = &ctx.capture_window.bucket[i];
        bucket.ubuf_size = ubuf_initial_size;
        bucket.ubuf = cast(u8*, _sgimgui_malloc(&ctx.desc.allocator, bucket.ubuf_size));
    }
}

void _sgimgui_capture_discard(_sgimgui_t* ctx) {
    for i32 i = 0; i < 2; i++ {
        _sgimgui_capture_bucket_t* bucket = &ctx.capture_window.bucket[i];
        _sgimgui_free(&ctx.desc.allocator, bucket.ubuf);
        bucket.ubuf = null;
    }
}

_sgimgui_capture_bucket_t* _sgimgui_capture_get_write_bucket(_sgimgui_t* ctx) {
    return &ctx.capture_window.bucket[ctx.capture_window.bucket_index & 1];
}

_sgimgui_capture_bucket_t* _sgimgui_capture_get_read_bucket(_sgimgui_t* ctx) {
    return &ctx.capture_window.bucket[ctx.capture_window.bucket_index + 1 & 1];
}

void _sgimgui_capture_next_frame(_sgimgui_t* ctx) {
    ctx.capture_window.bucket_index = ctx.capture_window.bucket_index + 1 & 1;
    _sgimgui_capture_bucket_t* bucket = &ctx.capture_window.bucket[ctx.capture_window.bucket_index];
    bucket.num_items = 0;
    bucket.ubuf_pos = 0;
}

void _sgimgui_capture_grow_ubuf(_sgimgui_t* ctx, u64 required_size) {
    _sgimgui_capture_bucket_t* bucket = _sgimgui_capture_get_write_bucket(ctx);
    u64 old_size = bucket.ubuf_size;
    u64 new_size = required_size + (required_size >> 1);
    bucket.ubuf_size = new_size;
    bucket.ubuf = cast(u8*, _sgimgui_realloc(&ctx.desc.allocator, bucket.ubuf, old_size, new_size));
}

_sgimgui_capture_item_t* _sgimgui_capture_next_write_item(_sgimgui_t* ctx) {
    _sgimgui_capture_bucket_t* bucket = _sgimgui_capture_get_write_bucket(ctx);
    if bucket.num_items < 4096 {
        _sgimgui_capture_item_t* item = &bucket.items[bucket.num_items++];
        return item;
    } else {
        return null;
    }
}

i32 _sgimgui_capture_num_read_items(_sgimgui_t* ctx) {
    _sgimgui_capture_bucket_t* bucket = _sgimgui_capture_get_read_bucket(ctx);
    return bucket.num_items;
}

_sgimgui_capture_item_t* _sgimgui_capture_read_item_at(_sgimgui_t* ctx, i32 index) {
    _sgimgui_capture_bucket_t* bucket = _sgimgui_capture_get_read_bucket(ctx);
    return &bucket.items[index];
}

u64 _sgimgui_capture_uniforms(_sgimgui_t* ctx, sg_range* data) {
    _sgimgui_capture_bucket_t* bucket = _sgimgui_capture_get_write_bucket(ctx);
    u64 required_size = bucket.ubuf_pos + data.size;
    if required_size > bucket.ubuf_size {
        _sgimgui_capture_grow_ubuf(ctx, required_size);
    }
    memcpy(bucket.ubuf + bucket.ubuf_pos, data.ptr, data.size);
    u64 pos = bucket.ubuf_pos;
    bucket.ubuf_pos += data.size;
    return pos;
}

_sgimgui_str_t _sgimgui_capture_item_string(_sgimgui_t* ctx, i32 index, _sgimgui_capture_item_t* item) {
    _sgimgui_str_t str_var = _sgimgui_make_str(null);  // renamed from: str
    switch item.cmd {
        case _SGIMGUI_CMD_RESET_STATE_CACHE: {
            _sgimgui_snprintf(&str_var, "%d: sg_reset_state_cache()", index);
        }
        case _SGIMGUI_CMD_MAKE_BUFFER: {
            {
                _sgimgui_str_t res_id = _sgimgui_buffer_id_string(ctx, item.args.make_buffer.result);
                _sgimgui_snprintf(&str_var, "%d: sg_make_buffer(desc=..) => %s", index, res_id.buf);
            }
        }
        case _SGIMGUI_CMD_MAKE_IMAGE: {
            {
                _sgimgui_str_t res_id = _sgimgui_image_id_string(ctx, item.args.make_image.result);
                _sgimgui_snprintf(&str_var, "%d: sg_make_image(desc=..) => %s", index, res_id.buf);
            }
        }
        case _SGIMGUI_CMD_MAKE_SAMPLER: {
            {
                _sgimgui_str_t res_id = _sgimgui_sampler_id_string(ctx, item.args.make_sampler.result);
                _sgimgui_snprintf(&str_var, "%d: sg_make_sampler(desc=..) => %s", index, res_id.buf);
            }
        }
        case _SGIMGUI_CMD_MAKE_SHADER: {
            {
                _sgimgui_str_t res_id = _sgimgui_shader_id_string(ctx, item.args.make_shader.result);
                _sgimgui_snprintf(&str_var, "%d: sg_make_shader(desc=..) => %s", index, res_id.buf);
            }
        }
        case _SGIMGUI_CMD_MAKE_PIPELINE: {
            {
                _sgimgui_str_t res_id = _sgimgui_pipeline_id_string(ctx, item.args.make_pipeline.result);
                _sgimgui_snprintf(&str_var, "%d: sg_make_pipeline(desc=..) => %s", index, res_id.buf);
            }
        }
        case _SGIMGUI_CMD_MAKE_VIEW: {
            {
                _sgimgui_str_t res_id = _sgimgui_view_id_string(ctx, item.args.make_view.result);
                _sgimgui_snprintf(&str_var, "%d: sg_make_view(desc=..) => %s", index, res_id.buf);
            }
        }
        case _SGIMGUI_CMD_DESTROY_BUFFER: {
            {
                _sgimgui_str_t res_id = _sgimgui_buffer_id_string(ctx, item.args.destroy_buffer.buffer);
                _sgimgui_snprintf(&str_var, "%d: sg_destroy_buffer(buf=%s)", index, res_id.buf);
            }
        }
        case _SGIMGUI_CMD_DESTROY_IMAGE: {
            {
                _sgimgui_str_t res_id = _sgimgui_image_id_string(ctx, item.args.destroy_image.image);
                _sgimgui_snprintf(&str_var, "%d: sg_destroy_image(img=%s)", index, res_id.buf);
            }
        }
        case _SGIMGUI_CMD_DESTROY_SAMPLER: {
            {
                _sgimgui_str_t res_id = _sgimgui_sampler_id_string(ctx, item.args.destroy_sampler.sampler);
                _sgimgui_snprintf(&str_var, "%d: sg_destroy_sampler(smp=%s)", index, res_id.buf);
            }
        }
        case _SGIMGUI_CMD_DESTROY_SHADER: {
            {
                _sgimgui_str_t res_id = _sgimgui_shader_id_string(ctx, item.args.destroy_shader.shader);
                _sgimgui_snprintf(&str_var, "%d: sg_destroy_shader(shd=%s)", index, res_id.buf);
            }
        }
        case _SGIMGUI_CMD_DESTROY_PIPELINE: {
            {
                _sgimgui_str_t res_id = _sgimgui_pipeline_id_string(ctx, item.args.destroy_pipeline.pipeline);
                _sgimgui_snprintf(&str_var, "%d: sg_destroy_pipeline(pip=%s)", index, res_id.buf);
            }
        }
        case _SGIMGUI_CMD_DESTROY_VIEW: {
            {
                _sgimgui_str_t res_id = _sgimgui_view_id_string(ctx, item.args.destroy_view.view);
                _sgimgui_snprintf(&str_var, "%d: sg_destroy_view(view=%s)", index, res_id.buf);
            }
        }
        case _SGIMGUI_CMD_UPDATE_BUFFER: {
            {
                _sgimgui_str_t res_id = _sgimgui_buffer_id_string(ctx, item.args.update_buffer.buffer);
                _sgimgui_snprintf(&str_var, "%d: sg_update_buffer(buf=%s, data.size=%d)", index, res_id.buf, item.args.update_buffer.data_size);
            }
        }
        case _SGIMGUI_CMD_UPDATE_IMAGE: {
            {
                _sgimgui_str_t res_id = _sgimgui_image_id_string(ctx, item.args.update_image.image);
                _sgimgui_snprintf(&str_var, "%d: sg_update_image(img=%s, data=..)", index, res_id.buf);
            }
        }
        case _SGIMGUI_CMD_APPEND_BUFFER: {
            {
                _sgimgui_str_t res_id = _sgimgui_buffer_id_string(ctx, item.args.append_buffer.buffer);
                _sgimgui_snprintf(&str_var, "%d: sg_append_buffer(buf=%s, data.size=%d) => %d", index, res_id.buf, item.args.append_buffer.data_size, item.args.append_buffer.result);
            }
        }
        case _SGIMGUI_CMD_WRITE_BUFFER_UNSEALED: {
            _sgimgui_snprintf(&str_var, "%d: sg_write_buffer_unsealed(desc=...)", index);
        }
        case _SGIMGUI_CMD_WRITE_IMAGE_UNSEALED: {
            _sgimgui_snprintf(&str_var, "%d: sg_write_image_unsealed(desc=...)", index);
        }
        case _SGIMGUI_CMD_SEAL_BUFFER: {
            {
                _sgimgui_str_t res_id = _sgimgui_buffer_id_string(ctx, item.args.seal_buffer.buffer);
                _sgimgui_snprintf(&str_var, "%d: sg_seal_buffer(buf=%s)", index, res_id.buf);
            }
        }
        case _SGIMGUI_CMD_SEAL_IMAGE: {
            {
                _sgimgui_str_t res_id = _sgimgui_image_id_string(ctx, item.args.seal_image.image);
                _sgimgui_snprintf(&str_var, "%d: sg_seal_image(img=%s)", index, res_id.buf);
            }
        }
        case _SGIMGUI_CMD_BEGIN_PASS: {
            {
                _sgimgui_snprintf(&str_var, "%d: sg_begin_pass(pass=...)", index);
            }
        }
        case _SGIMGUI_CMD_APPLY_VIEWPORT: {
            _sgimgui_snprintf(&str_var, "%d: sg_apply_viewport(x=%d, y=%d, width=%d, height=%d, origin_top_left=%s)", index, item.args.apply_viewport.x, item.args.apply_viewport.y, item.args.apply_viewport.width, item.args.apply_viewport.height, _sgimgui_bool_string(item.args.apply_viewport.origin_top_left));
        }
        case _SGIMGUI_CMD_APPLY_SCISSOR_RECT: {
            _sgimgui_snprintf(&str_var, "%d: sg_apply_scissor_rect(x=%d, y=%d, width=%d, height=%d, origin_top_left=%s)", index, item.args.apply_scissor_rect.x, item.args.apply_scissor_rect.y, item.args.apply_scissor_rect.width, item.args.apply_scissor_rect.height, _sgimgui_bool_string(item.args.apply_scissor_rect.origin_top_left));
        }
        case _SGIMGUI_CMD_APPLY_PIPELINE: {
            {
                _sgimgui_str_t res_id = _sgimgui_pipeline_id_string(ctx, item.args.apply_pipeline.pipeline);
                _sgimgui_snprintf(&str_var, "%d: sg_apply_pipeline(pip=%s)", index, res_id.buf);
            }
        }
        case _SGIMGUI_CMD_APPLY_BINDINGS: {
            _sgimgui_snprintf(&str_var, "%d: sg_apply_bindings(bindings=..)", index);
        }
        case _SGIMGUI_CMD_APPLY_UNIFORMS: {
            _sgimgui_snprintf(&str_var, "%d: sg_apply_uniforms(ub_slot=%d, data.size=%d)", index, item.args.apply_uniforms.ub_slot, item.args.apply_uniforms.data_size);
        }
        case _SGIMGUI_CMD_DRAW: {
            _sgimgui_snprintf(&str_var, "%d: sg_draw(base_element=%d, num_elements=%d, num_instances=%d)", index, item.args.draw.base_element, item.args.draw.num_elements, item.args.draw.num_instances);
        }
        case _SGIMGUI_CMD_DRAW_EX: {
            _sgimgui_snprintf(&str_var, "%d: sg_draw_ex(base_element=%d, num_elements=%d, num_instances=%d, base_vertex=%d, base_instance=%d)", index, item.args.draw_ex.base_element, item.args.draw_ex.num_elements, item.args.draw_ex.num_instances, item.args.draw_ex.base_vertex, item.args.draw_ex.base_instance);
        }
        case _SGIMGUI_CMD_DISPATCH: {
            _sgimgui_snprintf(&str_var, "%d: sg_dispatch(num_groups_x=%d, num_groups_y=%d, num_groups_z=%d)", index, item.args.dispatch.num_groups_x, item.args.dispatch.num_groups_y, item.args.dispatch.num_groups_z);
        }
        case _SGIMGUI_CMD_END_PASS: {
            _sgimgui_snprintf(&str_var, "%d: sg_end_pass()", index);
        }
        case _SGIMGUI_CMD_COMMIT: {
            _sgimgui_snprintf(&str_var, "%d: sg_commit()", index);
        }
        case _SGIMGUI_CMD_ALLOC_BUFFER: {
            {
                _sgimgui_str_t res_id = _sgimgui_buffer_id_string(ctx, item.args.alloc_buffer.result);
                _sgimgui_snprintf(&str_var, "%d: sg_alloc_buffer() => %s", index, res_id.buf);
            }
        }
        case _SGIMGUI_CMD_ALLOC_IMAGE: {
            {
                _sgimgui_str_t res_id = _sgimgui_image_id_string(ctx, item.args.alloc_image.result);
                _sgimgui_snprintf(&str_var, "%d: sg_alloc_image() => %s", index, res_id.buf);
            }
        }
        case _SGIMGUI_CMD_ALLOC_SAMPLER: {
            {
                _sgimgui_str_t res_id = _sgimgui_sampler_id_string(ctx, item.args.alloc_sampler.result);
                _sgimgui_snprintf(&str_var, "%d: sg_alloc_sampler() => %s", index, res_id.buf);
            }
        }
        case _SGIMGUI_CMD_ALLOC_SHADER: {
            {
                _sgimgui_str_t res_id = _sgimgui_shader_id_string(ctx, item.args.alloc_shader.result);
                _sgimgui_snprintf(&str_var, "%d: sg_alloc_shader() => %s", index, res_id.buf);
            }
        }
        case _SGIMGUI_CMD_ALLOC_PIPELINE: {
            {
                _sgimgui_str_t res_id = _sgimgui_pipeline_id_string(ctx, item.args.alloc_pipeline.result);
                _sgimgui_snprintf(&str_var, "%d: sg_alloc_pipeline() => %s", index, res_id.buf);
            }
        }
        case _SGIMGUI_CMD_ALLOC_VIEW: {
            {
                _sgimgui_str_t res_id = _sgimgui_view_id_string(ctx, item.args.alloc_view.result);
                _sgimgui_snprintf(&str_var, "%d: sg_alloc_view() => %s", index, res_id.buf);
            }
        }
        case _SGIMGUI_CMD_DEALLOC_BUFFER: {
            {
                _sgimgui_str_t res_id = _sgimgui_buffer_id_string(ctx, item.args.dealloc_buffer.buffer);
                _sgimgui_snprintf(&str_var, "%d: sg_dealloc_buffer(buf=%s)", index, res_id.buf);
            }
        }
        case _SGIMGUI_CMD_DEALLOC_IMAGE: {
            {
                _sgimgui_str_t res_id = _sgimgui_image_id_string(ctx, item.args.dealloc_image.image);
                _sgimgui_snprintf(&str_var, "%d: sg_dealloc_image(img=%s)", index, res_id.buf);
            }
        }
        case _SGIMGUI_CMD_DEALLOC_SAMPLER: {
            {
                _sgimgui_str_t res_id = _sgimgui_sampler_id_string(ctx, item.args.dealloc_sampler.sampler);
                _sgimgui_snprintf(&str_var, "%d: sg_dealloc_sampler(smp=%s)", index, res_id.buf);
            }
        }
        case _SGIMGUI_CMD_DEALLOC_SHADER: {
            {
                _sgimgui_str_t res_id = _sgimgui_shader_id_string(ctx, item.args.dealloc_shader.shader);
                _sgimgui_snprintf(&str_var, "%d: sg_dealloc_shader(shd=%s)", index, res_id.buf);
            }
        }
        case _SGIMGUI_CMD_DEALLOC_PIPELINE: {
            {
                _sgimgui_str_t res_id = _sgimgui_pipeline_id_string(ctx, item.args.dealloc_pipeline.pipeline);
                _sgimgui_snprintf(&str_var, "%d: sg_dealloc_pipeline(pip=%s)", index, res_id.buf);
            }
        }
        case _SGIMGUI_CMD_DEALLOC_VIEW: {
            {
                _sgimgui_str_t res_id = _sgimgui_view_id_string(ctx, item.args.dealloc_view.view);
                _sgimgui_snprintf(&str_var, "%d: sg_dealloc_view(view=%s)", index, res_id.buf);
            }
        }
        case _SGIMGUI_CMD_INIT_BUFFER: {
            {
                _sgimgui_str_t res_id = _sgimgui_buffer_id_string(ctx, item.args.init_buffer.buffer);
                _sgimgui_snprintf(&str_var, "%d: sg_init_buffer(buf=%s, desc=..)", index, res_id.buf);
            }
        }
        case _SGIMGUI_CMD_INIT_IMAGE: {
            {
                _sgimgui_str_t res_id = _sgimgui_image_id_string(ctx, item.args.init_image.image);
                _sgimgui_snprintf(&str_var, "%d: sg_init_image(img=%s, desc=..)", index, res_id.buf);
            }
        }
        case _SGIMGUI_CMD_INIT_SAMPLER: {
            {
                _sgimgui_str_t res_id = _sgimgui_sampler_id_string(ctx, item.args.init_sampler.sampler);
                _sgimgui_snprintf(&str_var, "%d: sg_init_sampler(smp=%s, desc=..)", index, res_id.buf);
            }
        }
        case _SGIMGUI_CMD_INIT_SHADER: {
            {
                _sgimgui_str_t res_id = _sgimgui_shader_id_string(ctx, item.args.init_shader.shader);
                _sgimgui_snprintf(&str_var, "%d: sg_init_shader(shd=%s, desc=..)", index, res_id.buf);
            }
        }
        case _SGIMGUI_CMD_INIT_PIPELINE: {
            {
                _sgimgui_str_t res_id = _sgimgui_pipeline_id_string(ctx, item.args.init_pipeline.pipeline);
                _sgimgui_snprintf(&str_var, "%d: sg_init_pipeline(pip=%s, desc=..)", index, res_id.buf);
            }
        }
        case _SGIMGUI_CMD_INIT_VIEW: {
            {
                _sgimgui_str_t res_id = _sgimgui_view_id_string(ctx, item.args.init_view.view);
                _sgimgui_snprintf(&str_var, "%d: sg_init_view(view=%s, desc=..)", index, res_id.buf);
            }
        }
        case _SGIMGUI_CMD_UNINIT_BUFFER: {
            {
                _sgimgui_str_t res_id = _sgimgui_buffer_id_string(ctx, item.args.uninit_buffer.buffer);
                _sgimgui_snprintf(&str_var, "%d: sg_uninit_buffer(buf=%s)", index, res_id.buf);
            }
        }
        case _SGIMGUI_CMD_UNINIT_IMAGE: {
            {
                _sgimgui_str_t res_id = _sgimgui_image_id_string(ctx, item.args.uninit_image.image);
                _sgimgui_snprintf(&str_var, "%d: sg_uninit_image(img=%s)", index, res_id.buf);
            }
        }
        case _SGIMGUI_CMD_UNINIT_SAMPLER: {
            {
                _sgimgui_str_t res_id = _sgimgui_sampler_id_string(ctx, item.args.uninit_sampler.sampler);
                _sgimgui_snprintf(&str_var, "%d: sg_uninit_sampler(smp=%s)", index, res_id.buf);
            }
        }
        case _SGIMGUI_CMD_UNINIT_SHADER: {
            {
                _sgimgui_str_t res_id = _sgimgui_shader_id_string(ctx, item.args.uninit_shader.shader);
                _sgimgui_snprintf(&str_var, "%d: sg_uninit_shader(shd=%s)", index, res_id.buf);
            }
        }
        case _SGIMGUI_CMD_UNINIT_PIPELINE: {
            {
                _sgimgui_str_t res_id = _sgimgui_pipeline_id_string(ctx, item.args.uninit_pipeline.pipeline);
                _sgimgui_snprintf(&str_var, "%d: sg_uninit_pipeline(pip=%s)", index, res_id.buf);
            }
        }
        case _SGIMGUI_CMD_UNINIT_VIEW: {
            {
                _sgimgui_str_t res_id = _sgimgui_view_id_string(ctx, item.args.uninit_view.view);
                _sgimgui_snprintf(&str_var, "%d: sg_uninit_view(view=%s)", index, res_id.buf);
            }
        }
        case _SGIMGUI_CMD_FAIL_BUFFER: {
            {
                _sgimgui_str_t res_id = _sgimgui_buffer_id_string(ctx, item.args.fail_buffer.buffer);
                _sgimgui_snprintf(&str_var, "%d: sg_fail_buffer(buf=%s)", index, res_id.buf);
            }
        }
        case _SGIMGUI_CMD_FAIL_IMAGE: {
            {
                _sgimgui_str_t res_id = _sgimgui_image_id_string(ctx, item.args.fail_image.image);
                _sgimgui_snprintf(&str_var, "%d: sg_fail_image(img=%s)", index, res_id.buf);
            }
        }
        case _SGIMGUI_CMD_FAIL_SAMPLER: {
            {
                _sgimgui_str_t res_id = _sgimgui_sampler_id_string(ctx, item.args.fail_sampler.sampler);
                _sgimgui_snprintf(&str_var, "%d: sg_fail_sampler(smp=%s)", index, res_id.buf);
            }
        }
        case _SGIMGUI_CMD_FAIL_SHADER: {
            {
                _sgimgui_str_t res_id = _sgimgui_shader_id_string(ctx, item.args.fail_shader.shader);
                _sgimgui_snprintf(&str_var, "%d: sg_fail_shader(shd=%s)", index, res_id.buf);
            }
        }
        case _SGIMGUI_CMD_FAIL_PIPELINE: {
            {
                _sgimgui_str_t res_id = _sgimgui_pipeline_id_string(ctx, item.args.fail_pipeline.pipeline);
                _sgimgui_snprintf(&str_var, "%d: sg_fail_pipeline(pip=%s)", index, res_id.buf);
            }
        }
        case _SGIMGUI_CMD_FAIL_VIEW: {
            {
                _sgimgui_str_t res_id = _sgimgui_view_id_string(ctx, item.args.fail_view.view);
                _sgimgui_snprintf(&str_var, "%d: sg_fail_view(view=%s)", index, res_id.buf);
            }
        }
        case _SGIMGUI_CMD_PUSH_DEBUG_GROUP: {
            _sgimgui_snprintf(&str_var, "%d: sg_push_debug_group(name=%s)", index, item.args.push_debug_group.name.buf);
        }
        case _SGIMGUI_CMD_POP_DEBUG_GROUP: {
            _sgimgui_snprintf(&str_var, "%d: sg_pop_debug_group()", index);
        }
        default: {
            _sgimgui_snprintf(&str_var, "%d: ???", index);
        }
    }
    return str_var;
}

/*--- CAPTURE CALLBACKS ------------------------------------------------------*/
void _sgimgui_reset_state_cache(void* user_data) {
    var ctx = cast(_sgimgui_t*, user_data);
    _sgimgui_capture_item_t* item = _sgimgui_capture_next_write_item(ctx);
    if item != null {
        item.cmd = _SGIMGUI_CMD_RESET_STATE_CACHE;
        item.color = 0xFFCCCCCC;
    }
    if ctx.hooks.reset_state_cache != null {
        ctx.hooks.reset_state_cache(ctx.hooks.user_data);
    }
}

void _sgimgui_make_buffer(sg_buffer_desc* desc, sg_buffer buf_id, void* user_data) {
    var ctx = cast(_sgimgui_t*, user_data);
    _sgimgui_capture_item_t* item = _sgimgui_capture_next_write_item(ctx);
    if item != null {
        item.cmd = _SGIMGUI_CMD_MAKE_BUFFER;
        item.color = 0xFF00FFFF;
        item.args.make_buffer.result = buf_id;
    }
    if ctx.hooks.make_buffer != null {
        ctx.hooks.make_buffer(desc, buf_id, ctx.hooks.user_data);
    }
    if buf_id.id != cast(u32, SG_INVALID_ID) {
        _sgimgui_buffer_created(ctx, buf_id, _sgimgui_slot_index(buf_id.id), desc);
    }
}

void _sgimgui_make_image(sg_image_desc* desc, sg_image img_id, void* user_data) {
    var ctx = cast(_sgimgui_t*, user_data);
    _sgimgui_capture_item_t* item = _sgimgui_capture_next_write_item(ctx);
    if item != null {
        item.cmd = _SGIMGUI_CMD_MAKE_IMAGE;
        item.color = 0xFF00FFFF;
        item.args.make_image.result = img_id;
    }
    if ctx.hooks.make_image != null {
        ctx.hooks.make_image(desc, img_id, ctx.hooks.user_data);
    }
    if img_id.id != cast(u32, SG_INVALID_ID) {
        _sgimgui_image_created(ctx, img_id, _sgimgui_slot_index(img_id.id), desc);
    }
}

void _sgimgui_make_sampler(sg_sampler_desc* desc, sg_sampler smp_id, void* user_data) {
    var ctx = cast(_sgimgui_t*, user_data);
    _sgimgui_capture_item_t* item = _sgimgui_capture_next_write_item(ctx);
    if item != null {
        item.cmd = _SGIMGUI_CMD_MAKE_SAMPLER;
        item.color = 0xFF00FFFF;
        item.args.make_sampler.result = smp_id;
    }
    if ctx.hooks.make_sampler != null {
        ctx.hooks.make_sampler(desc, smp_id, ctx.hooks.user_data);
    }
    if smp_id.id != cast(u32, SG_INVALID_ID) {
        _sgimgui_sampler_created(ctx, smp_id, _sgimgui_slot_index(smp_id.id), desc);
    }
}

void _sgimgui_make_shader(sg_shader_desc* desc, sg_shader shd_id, void* user_data) {
    var ctx = cast(_sgimgui_t*, user_data);
    _sgimgui_capture_item_t* item = _sgimgui_capture_next_write_item(ctx);
    if item != null {
        item.cmd = _SGIMGUI_CMD_MAKE_SHADER;
        item.color = 0xFF00FFFF;
        item.args.make_shader.result = shd_id;
    }
    if ctx.hooks.make_shader != null {
        ctx.hooks.make_shader(desc, shd_id, ctx.hooks.user_data);
    }
    if shd_id.id != cast(u32, SG_INVALID_ID) {
        _sgimgui_shader_created(ctx, shd_id, _sgimgui_slot_index(shd_id.id), desc);
    }
}

void _sgimgui_make_pipeline(sg_pipeline_desc* desc, sg_pipeline pip_id, void* user_data) {
    var ctx = cast(_sgimgui_t*, user_data);
    _sgimgui_capture_item_t* item = _sgimgui_capture_next_write_item(ctx);
    if item != null {
        item.cmd = _SGIMGUI_CMD_MAKE_PIPELINE;
        item.color = 0xFF00FFFF;
        item.args.make_pipeline.result = pip_id;
    }
    if ctx.hooks.make_pipeline != null {
        ctx.hooks.make_pipeline(desc, pip_id, ctx.hooks.user_data);
    }
    if pip_id.id != cast(u32, SG_INVALID_ID) {
        _sgimgui_pipeline_created(ctx, pip_id, _sgimgui_slot_index(pip_id.id), desc);
    }
}

void _sgimgui_make_view(sg_view_desc* desc, sg_view view_id, void* user_data) {
    var ctx = cast(_sgimgui_t*, user_data);
    _sgimgui_capture_item_t* item = _sgimgui_capture_next_write_item(ctx);
    if item != null {
        item.cmd = _SGIMGUI_CMD_MAKE_VIEW;
        item.color = 0xFF00FFFF;
        item.args.make_view.result = view_id;
    }
    if ctx.hooks.make_view != null {
        ctx.hooks.make_view(desc, view_id, ctx.hooks.user_data);
    }
    if view_id.id != cast(u32, SG_INVALID_ID) {
        _sgimgui_view_created(ctx, view_id, _sgimgui_slot_index(view_id.id), desc);
    }
}

void _sgimgui_destroy_buffer(sg_buffer buf, void* user_data) {
    var ctx = cast(_sgimgui_t*, user_data);
    _sgimgui_capture_item_t* item = _sgimgui_capture_next_write_item(ctx);
    if item != null {
        item.cmd = _SGIMGUI_CMD_DESTROY_BUFFER;
        item.color = 0xFF00FFFF;
        item.args.destroy_buffer.buffer = buf;
    }
    if ctx.hooks.destroy_buffer != null {
        ctx.hooks.destroy_buffer(buf, ctx.hooks.user_data);
    }
    if buf.id != cast(u32, SG_INVALID_ID) {
        _sgimgui_buffer_destroyed(ctx, _sgimgui_slot_index(buf.id));
    }
}

void _sgimgui_destroy_image(sg_image img, void* user_data) {
    var ctx = cast(_sgimgui_t*, user_data);
    _sgimgui_capture_item_t* item = _sgimgui_capture_next_write_item(ctx);
    if item != null {
        item.cmd = _SGIMGUI_CMD_DESTROY_IMAGE;
        item.color = 0xFF00FFFF;
        item.args.destroy_image.image = img;
    }
    if ctx.hooks.destroy_image != null {
        ctx.hooks.destroy_image(img, ctx.hooks.user_data);
    }
    if img.id != cast(u32, SG_INVALID_ID) {
        _sgimgui_image_destroyed(ctx, _sgimgui_slot_index(img.id));
    }
}

void _sgimgui_destroy_sampler(sg_sampler smp, void* user_data) {
    var ctx = cast(_sgimgui_t*, user_data);
    _sgimgui_capture_item_t* item = _sgimgui_capture_next_write_item(ctx);
    if item != null {
        item.cmd = _SGIMGUI_CMD_DESTROY_SAMPLER;
        item.color = 0xFF00FFFF;
        item.args.destroy_sampler.sampler = smp;
    }
    if ctx.hooks.destroy_sampler != null {
        ctx.hooks.destroy_sampler(smp, ctx.hooks.user_data);
    }
    if smp.id != cast(u32, SG_INVALID_ID) {
        _sgimgui_sampler_destroyed(ctx, _sgimgui_slot_index(smp.id));
    }
}

void _sgimgui_destroy_shader(sg_shader shd, void* user_data) {
    var ctx = cast(_sgimgui_t*, user_data);
    _sgimgui_capture_item_t* item = _sgimgui_capture_next_write_item(ctx);
    if item != null {
        item.cmd = _SGIMGUI_CMD_DESTROY_SHADER;
        item.color = 0xFF00FFFF;
        item.args.destroy_shader.shader = shd;
    }
    if ctx.hooks.destroy_shader != null {
        ctx.hooks.destroy_shader(shd, ctx.hooks.user_data);
    }
    if shd.id != cast(u32, SG_INVALID_ID) {
        _sgimgui_shader_destroyed(ctx, _sgimgui_slot_index(shd.id));
    }
}

void _sgimgui_destroy_pipeline(sg_pipeline pip, void* user_data) {
    var ctx = cast(_sgimgui_t*, user_data);
    _sgimgui_capture_item_t* item = _sgimgui_capture_next_write_item(ctx);
    if item != null {
        item.cmd = _SGIMGUI_CMD_DESTROY_PIPELINE;
        item.color = 0xFF00FFFF;
        item.args.destroy_pipeline.pipeline = pip;
    }
    if ctx.hooks.destroy_pipeline != null {
        ctx.hooks.destroy_pipeline(pip, ctx.hooks.user_data);
    }
    if pip.id != cast(u32, SG_INVALID_ID) {
        _sgimgui_pipeline_destroyed(ctx, _sgimgui_slot_index(pip.id));
    }
}

void _sgimgui_destroy_view(sg_view view, void* user_data) {
    var ctx = cast(_sgimgui_t*, user_data);
    _sgimgui_capture_item_t* item = _sgimgui_capture_next_write_item(ctx);
    if item != null {
        item.cmd = _SGIMGUI_CMD_DESTROY_VIEW;
        item.color = 0xFF00FFFF;
        item.args.destroy_view.view = view;
    }
    if ctx.hooks.destroy_view != null {
        ctx.hooks.destroy_view(view, ctx.hooks.user_data);
    }
    if view.id != cast(u32, SG_INVALID_ID) {
        _sgimgui_view_destroyed(ctx, _sgimgui_slot_index(view.id));
    }
}

void _sgimgui_update_buffer(sg_buffer buf, sg_range* data, void* user_data) {
    var ctx = cast(_sgimgui_t*, user_data);
    _sgimgui_capture_item_t* item = _sgimgui_capture_next_write_item(ctx);
    if item != null {
        item.cmd = _SGIMGUI_CMD_UPDATE_BUFFER;
        item.color = 0xFF00FFFF;
        item.args.update_buffer.buffer = buf;
        item.args.update_buffer.data_size = data.size;
    }
    if ctx.hooks.update_buffer != null {
        ctx.hooks.update_buffer(buf, data, ctx.hooks.user_data);
    }
}

void _sgimgui_update_image(sg_image img, sg_image_data* data, void* user_data) {
    var ctx = cast(_sgimgui_t*, user_data);
    _sgimgui_capture_item_t* item = _sgimgui_capture_next_write_item(ctx);
    if item != null {
        item.cmd = _SGIMGUI_CMD_UPDATE_IMAGE;
        item.color = 0xFF00FFFF;
        item.args.update_image.image = img;
    }
    if ctx.hooks.update_image != null {
        ctx.hooks.update_image(img, data, ctx.hooks.user_data);
    }
}

void _sgimgui_append_buffer(sg_buffer buf, sg_range* data, i32 result, void* user_data) {
    var ctx = cast(_sgimgui_t*, user_data);
    _sgimgui_capture_item_t* item = _sgimgui_capture_next_write_item(ctx);
    if item != null {
        item.cmd = _SGIMGUI_CMD_APPEND_BUFFER;
        item.color = 0xFF00FFFF;
        item.args.append_buffer.buffer = buf;
        item.args.append_buffer.data_size = data.size;
        item.args.append_buffer.result = result;
    }
    if ctx.hooks.append_buffer != null {
        ctx.hooks.append_buffer(buf, data, result, ctx.hooks.user_data);
    }
}

void _sgimgui_write_buffer_unsealed(sg_write_buffer_desc* desc, void* user_data) {
    var ctx = cast(_sgimgui_t*, user_data);
    _sgimgui_capture_item_t* item = _sgimgui_capture_next_write_item(ctx);
    if item != null {
        item.cmd = _SGIMGUI_CMD_WRITE_BUFFER_UNSEALED;
        item.color = 0xFF00FFFF;
        item.args.write_buffer_unsealed.src_data_size = desc.src.data.size;
        item.args.write_buffer_unsealed.src_data_offset = desc.src.offset;
        item.args.write_buffer_unsealed.dst = desc.dst;
        item.args.write_buffer_unsealed.write_size = desc.size;
    }
    if ctx.hooks.write_buffer_unsealed != null {
        ctx.hooks.write_buffer_unsealed(desc, ctx.hooks.user_data);
    }
}

void _sgimgui_write_image_unsealed(sg_write_image_desc* desc, void* user_data) {
    var ctx = cast(_sgimgui_t*, user_data);
    _sgimgui_capture_item_t* item = _sgimgui_capture_next_write_item(ctx);
    if item != null {
        item.cmd = _SGIMGUI_CMD_WRITE_IMAGE_UNSEALED;
        item.color = 0xFF00FFFF;
        item.args.write_image_unsealed.src_data_size = desc.src.data.size;
        item.args.write_image_unsealed.src_data_offset = desc.src.offset;
        item.args.write_image_unsealed.src_bytes_per_row = desc.src.bytes_per_row;
        item.args.write_image_unsealed.src_bytes_per_slice = desc.src.bytes_per_slice;
        item.args.write_image_unsealed.dst = desc.dst;
        item.args.write_image_unsealed.write_size = desc.size;
    }
    if ctx.hooks.write_image_unsealed != null {
        ctx.hooks.write_image_unsealed(desc, ctx.hooks.user_data);
    }
}

void _sgimgui_seal_buffer(sg_buffer buf, void* user_data) {
    var ctx = cast(_sgimgui_t*, user_data);
    _sgimgui_capture_item_t* item = _sgimgui_capture_next_write_item(ctx);
    if item != null {
        item.cmd = _SGIMGUI_CMD_SEAL_BUFFER;
        item.color = 0xFF00FFFF;
        item.args.seal_buffer.buffer = buf;
    }
    if ctx.hooks.seal_buffer != null {
        ctx.hooks.seal_buffer(buf, ctx.hooks.user_data);
    }
}

void _sgimgui_seal_image(sg_image img, void* user_data) {
    var ctx = cast(_sgimgui_t*, user_data);
    _sgimgui_capture_item_t* item = _sgimgui_capture_next_write_item(ctx);
    if item != null {
        item.cmd = _SGIMGUI_CMD_SEAL_IMAGE;
        item.color = 0xFF00FFFF;
        item.args.seal_image.image = img;
    }
    if ctx.hooks.seal_image != null {
        ctx.hooks.seal_image(img, ctx.hooks.user_data);
    }
}

void _sgimgui_begin_pass(sg_pass* pass, void* user_data) {
    var ctx = cast(_sgimgui_t*, user_data);
    _sgimgui_capture_item_t* item = _sgimgui_capture_next_write_item(ctx);
    if item != null {
        item.cmd = _SGIMGUI_CMD_BEGIN_PASS;
        item.color = 0xFFFFFF00;
        item.args.begin_pass.pass = *pass;
    }
    if ctx.hooks.begin_pass != null {
        ctx.hooks.begin_pass(pass, ctx.hooks.user_data);
    }
}

void _sgimgui_apply_viewport(i32 x, i32 y, i32 width, i32 height, bool origin_top_left, void* user_data) {
    var ctx = cast(_sgimgui_t*, user_data);
    _sgimgui_capture_item_t* item = _sgimgui_capture_next_write_item(ctx);
    if item != null {
        item.cmd = _SGIMGUI_CMD_APPLY_VIEWPORT;
        item.color = 0xFFCCCC00;
        item.args.apply_viewport.x = x;
        item.args.apply_viewport.y = y;
        item.args.apply_viewport.width = width;
        item.args.apply_viewport.height = height;
        item.args.apply_viewport.origin_top_left = origin_top_left;
    }
    if ctx.hooks.apply_viewport != null {
        ctx.hooks.apply_viewport(x, y, width, height, origin_top_left, ctx.hooks.user_data);
    }
}

void _sgimgui_apply_scissor_rect(i32 x, i32 y, i32 width, i32 height, bool origin_top_left, void* user_data) {
    var ctx = cast(_sgimgui_t*, user_data);
    _sgimgui_capture_item_t* item = _sgimgui_capture_next_write_item(ctx);
    if item != null {
        item.cmd = _SGIMGUI_CMD_APPLY_SCISSOR_RECT;
        item.color = 0xFFCCCC00;
        item.args.apply_scissor_rect.x = x;
        item.args.apply_scissor_rect.y = y;
        item.args.apply_scissor_rect.width = width;
        item.args.apply_scissor_rect.height = height;
        item.args.apply_scissor_rect.origin_top_left = origin_top_left;
    }
    if ctx.hooks.apply_scissor_rect != null {
        ctx.hooks.apply_scissor_rect(x, y, width, height, origin_top_left, ctx.hooks.user_data);
    }
}

void _sgimgui_apply_pipeline(sg_pipeline pip, void* user_data) {
    var ctx = cast(_sgimgui_t*, user_data);
    ctx.cur_pipeline = pip;
    _sgimgui_capture_item_t* item = _sgimgui_capture_next_write_item(ctx);
    if item != null {
        item.cmd = _SGIMGUI_CMD_APPLY_PIPELINE;
        item.color = 0xFFCCCC00;
        item.args.apply_pipeline.pipeline = pip;
    }
    if ctx.hooks.apply_pipeline != null {
        ctx.hooks.apply_pipeline(pip, ctx.hooks.user_data);
    }
}

void _sgimgui_apply_bindings(sg_bindings* bindings, void* user_data) {
    var ctx = cast(_sgimgui_t*, user_data);
    _sgimgui_capture_item_t* item = _sgimgui_capture_next_write_item(ctx);
    if item != null {
        item.cmd = _SGIMGUI_CMD_APPLY_BINDINGS;
        item.color = 0xFFCCCC00;
        item.args.apply_bindings.bindings = *bindings;
    }
    if ctx.hooks.apply_bindings != null {
        ctx.hooks.apply_bindings(bindings, ctx.hooks.user_data);
    }
}

void _sgimgui_apply_uniforms(i32 ub_slot, sg_range* data, void* user_data) {
    var ctx = cast(_sgimgui_t*, user_data);
    _sgimgui_capture_item_t* item = _sgimgui_capture_next_write_item(ctx);
    if item != null {
        item.cmd = _SGIMGUI_CMD_APPLY_UNIFORMS;
        item.color = 0xFFCCCC00;
        _sgimgui_args_apply_uniforms_t* args = &item.args.apply_uniforms;
        args.ub_slot = ub_slot;
        args.data_size = data.size;
        args.pipeline = ctx.cur_pipeline;
        args.ubuf_pos = _sgimgui_capture_uniforms(ctx, data);
    }
    if ctx.hooks.apply_uniforms != null {
        ctx.hooks.apply_uniforms(ub_slot, data, ctx.hooks.user_data);
    }
}

void _sgimgui_draw(i32 base_element, i32 num_elements, i32 num_instances, void* user_data) {
    var ctx = cast(_sgimgui_t*, user_data);
    _sgimgui_capture_item_t* item = _sgimgui_capture_next_write_item(ctx);
    if item != null {
        item.cmd = _SGIMGUI_CMD_DRAW;
        item.color = 0xFF00FF00;
        item.args.draw.base_element = base_element;
        item.args.draw.num_elements = num_elements;
        item.args.draw.num_instances = num_instances;
    }
    if ctx.hooks.draw != null {
        ctx.hooks.draw(base_element, num_elements, num_instances, ctx.hooks.user_data);
    }
}

void _sgimgui_draw_ex(i32 base_element, i32 num_elements, i32 num_instances, i32 base_vertex, i32 base_instance, void* user_data) {
    var ctx = cast(_sgimgui_t*, user_data);
    _sgimgui_capture_item_t* item = _sgimgui_capture_next_write_item(ctx);
    if item != null {
        item.cmd = _SGIMGUI_CMD_DRAW_EX;
        item.color = 0xFF00FF00;
        item.args.draw_ex.base_element = base_element;
        item.args.draw_ex.num_elements = num_elements;
        item.args.draw_ex.num_instances = num_instances;
        item.args.draw_ex.base_vertex = base_vertex;
        item.args.draw_ex.base_instance = base_instance;
    }
    if ctx.hooks.draw_ex != null {
        ctx.hooks.draw_ex(base_element, num_elements, num_instances, base_vertex, base_instance, ctx.hooks.user_data);
    }
}

void _sgimgui_dispatch(i32 num_groups_x, i32 num_groups_y, i32 num_groups_z, void* user_data) {
    var ctx = cast(_sgimgui_t*, user_data);
    _sgimgui_capture_item_t* item = _sgimgui_capture_next_write_item(ctx);
    if item != null {
        item.cmd = _SGIMGUI_CMD_DISPATCH;
        item.color = 0xFF00FF00;
        item.args.dispatch.num_groups_x = num_groups_x;
        item.args.dispatch.num_groups_y = num_groups_y;
        item.args.dispatch.num_groups_z = num_groups_z;
    }
    if ctx.hooks.dispatch != null {
        ctx.hooks.dispatch(num_groups_x, num_groups_y, num_groups_z, ctx.hooks.user_data);
    }
}

void _sgimgui_end_pass(void* user_data) {
    var ctx = cast(_sgimgui_t*, user_data);
    ctx.cur_pipeline.id = cast(u32, SG_INVALID_ID);
    _sgimgui_capture_item_t* item = _sgimgui_capture_next_write_item(ctx);
    if item != null {
        item.cmd = _SGIMGUI_CMD_END_PASS;
        item.color = 0xFFFFFF00;
    }
    if ctx.hooks.end_pass != null {
        ctx.hooks.end_pass(ctx.hooks.user_data);
    }
}

void _sgimgui_commit(void* user_data) {
    var ctx = cast(_sgimgui_t*, user_data);
    _sgimgui_capture_item_t* item = _sgimgui_capture_next_write_item(ctx);
    if item != null {
        item.cmd = _SGIMGUI_CMD_COMMIT;
        item.color = 0xFFCCCCCC;
    }
    _sgimgui_capture_next_frame(ctx);
    if ctx.hooks.commit != null {
        ctx.hooks.commit(ctx.hooks.user_data);
    }
}

void _sgimgui_alloc_buffer(sg_buffer result, void* user_data) {
    var ctx = cast(_sgimgui_t*, user_data);
    _sgimgui_capture_item_t* item = _sgimgui_capture_next_write_item(ctx);
    if item != null {
        item.cmd = _SGIMGUI_CMD_ALLOC_BUFFER;
        item.color = 0xFF00FFFF;
        item.args.alloc_buffer.result = result;
    }
    if ctx.hooks.alloc_buffer != null {
        ctx.hooks.alloc_buffer(result, ctx.hooks.user_data);
    }
}

void _sgimgui_alloc_image(sg_image result, void* user_data) {
    var ctx = cast(_sgimgui_t*, user_data);
    _sgimgui_capture_item_t* item = _sgimgui_capture_next_write_item(ctx);
    if item != null {
        item.cmd = _SGIMGUI_CMD_ALLOC_IMAGE;
        item.color = 0xFF00FFFF;
        item.args.alloc_image.result = result;
    }
    if ctx.hooks.alloc_image != null {
        ctx.hooks.alloc_image(result, ctx.hooks.user_data);
    }
}

void _sgimgui_alloc_sampler(sg_sampler result, void* user_data) {
    var ctx = cast(_sgimgui_t*, user_data);
    _sgimgui_capture_item_t* item = _sgimgui_capture_next_write_item(ctx);
    if item != null {
        item.cmd = _SGIMGUI_CMD_ALLOC_SAMPLER;
        item.color = 0xFF00FFFF;
        item.args.alloc_sampler.result = result;
    }
    if ctx.hooks.alloc_sampler != null {
        ctx.hooks.alloc_sampler(result, ctx.hooks.user_data);
    }
}

void _sgimgui_alloc_shader(sg_shader result, void* user_data) {
    var ctx = cast(_sgimgui_t*, user_data);
    _sgimgui_capture_item_t* item = _sgimgui_capture_next_write_item(ctx);
    if item != null {
        item.cmd = _SGIMGUI_CMD_ALLOC_SHADER;
        item.color = 0xFF00FFFF;
        item.args.alloc_shader.result = result;
    }
    if ctx.hooks.alloc_shader != null {
        ctx.hooks.alloc_shader(result, ctx.hooks.user_data);
    }
}

void _sgimgui_alloc_pipeline(sg_pipeline result, void* user_data) {
    var ctx = cast(_sgimgui_t*, user_data);
    _sgimgui_capture_item_t* item = _sgimgui_capture_next_write_item(ctx);
    if item != null {
        item.cmd = _SGIMGUI_CMD_ALLOC_PIPELINE;
        item.color = 0xFF00FFFF;
        item.args.alloc_pipeline.result = result;
    }
    if ctx.hooks.alloc_pipeline != null {
        ctx.hooks.alloc_pipeline(result, ctx.hooks.user_data);
    }
}

void _sgimgui_alloc_view(sg_view result, void* user_data) {
    var ctx = cast(_sgimgui_t*, user_data);
    _sgimgui_capture_item_t* item = _sgimgui_capture_next_write_item(ctx);
    if item != null {
        item.cmd = _SGIMGUI_CMD_ALLOC_VIEW;
        item.color = 0xFF00FFFF;
        item.args.alloc_view.result = result;
    }
    if ctx.hooks.alloc_view != null {
        ctx.hooks.alloc_view(result, ctx.hooks.user_data);
    }
}

void _sgimgui_dealloc_buffer(sg_buffer buf_id, void* user_data) {
    var ctx = cast(_sgimgui_t*, user_data);
    _sgimgui_capture_item_t* item = _sgimgui_capture_next_write_item(ctx);
    if item != null {
        item.cmd = _SGIMGUI_CMD_DEALLOC_BUFFER;
        item.color = 0xFF00FFFF;
        item.args.dealloc_buffer.buffer = buf_id;
    }
    if ctx.hooks.dealloc_buffer != null {
        ctx.hooks.dealloc_buffer(buf_id, ctx.hooks.user_data);
    }
}

void _sgimgui_dealloc_image(sg_image img_id, void* user_data) {
    var ctx = cast(_sgimgui_t*, user_data);
    _sgimgui_capture_item_t* item = _sgimgui_capture_next_write_item(ctx);
    if item != null {
        item.cmd = _SGIMGUI_CMD_DEALLOC_IMAGE;
        item.color = 0xFF00FFFF;
        item.args.dealloc_image.image = img_id;
    }
    if ctx.hooks.dealloc_image != null {
        ctx.hooks.dealloc_image(img_id, ctx.hooks.user_data);
    }
}

void _sgimgui_dealloc_sampler(sg_sampler smp_id, void* user_data) {
    var ctx = cast(_sgimgui_t*, user_data);
    _sgimgui_capture_item_t* item = _sgimgui_capture_next_write_item(ctx);
    if item != null {
        item.cmd = _SGIMGUI_CMD_DEALLOC_SAMPLER;
        item.color = 0xFF00FFFF;
        item.args.dealloc_sampler.sampler = smp_id;
    }
    if ctx.hooks.dealloc_sampler != null {
        ctx.hooks.dealloc_sampler(smp_id, ctx.hooks.user_data);
    }
}

void _sgimgui_dealloc_shader(sg_shader shd_id, void* user_data) {
    var ctx = cast(_sgimgui_t*, user_data);
    _sgimgui_capture_item_t* item = _sgimgui_capture_next_write_item(ctx);
    if item != null {
        item.cmd = _SGIMGUI_CMD_DEALLOC_SHADER;
        item.color = 0xFF00FFFF;
        item.args.dealloc_shader.shader = shd_id;
    }
    if ctx.hooks.dealloc_shader != null {
        ctx.hooks.dealloc_shader(shd_id, ctx.hooks.user_data);
    }
}

void _sgimgui_dealloc_pipeline(sg_pipeline pip_id, void* user_data) {
    var ctx = cast(_sgimgui_t*, user_data);
    _sgimgui_capture_item_t* item = _sgimgui_capture_next_write_item(ctx);
    if item != null {
        item.cmd = _SGIMGUI_CMD_DEALLOC_PIPELINE;
        item.color = 0xFF00FFFF;
        item.args.dealloc_pipeline.pipeline = pip_id;
    }
    if ctx.hooks.dealloc_pipeline != null {
        ctx.hooks.dealloc_pipeline(pip_id, ctx.hooks.user_data);
    }
}

void _sgimgui_dealloc_view(sg_view view_id, void* user_data) {
    var ctx = cast(_sgimgui_t*, user_data);
    _sgimgui_capture_item_t* item = _sgimgui_capture_next_write_item(ctx);
    if item != null {
        item.cmd = _SGIMGUI_CMD_DEALLOC_VIEW;
        item.color = 0xFF00FFFF;
        item.args.dealloc_view.view = view_id;
    }
    if ctx.hooks.dealloc_view != null {
        ctx.hooks.dealloc_view(view_id, ctx.hooks.user_data);
    }
}

void _sgimgui_init_buffer(sg_buffer buf_id, sg_buffer_desc* desc, void* user_data) {
    var ctx = cast(_sgimgui_t*, user_data);
    _sgimgui_capture_item_t* item = _sgimgui_capture_next_write_item(ctx);
    if item != null {
        item.cmd = _SGIMGUI_CMD_INIT_BUFFER;
        item.color = 0xFF00FFFF;
        item.args.init_buffer.buffer = buf_id;
    }
    if ctx.hooks.init_buffer != null {
        ctx.hooks.init_buffer(buf_id, desc, ctx.hooks.user_data);
    }
    if buf_id.id != cast(u32, SG_INVALID_ID) {
        _sgimgui_buffer_created(ctx, buf_id, _sgimgui_slot_index(buf_id.id), desc);
    }
}

void _sgimgui_init_image(sg_image img_id, sg_image_desc* desc, void* user_data) {
    var ctx = cast(_sgimgui_t*, user_data);
    _sgimgui_capture_item_t* item = _sgimgui_capture_next_write_item(ctx);
    if item != null {
        item.cmd = _SGIMGUI_CMD_INIT_IMAGE;
        item.color = 0xFF00FFFF;
        item.args.init_image.image = img_id;
    }
    if ctx.hooks.init_image != null {
        ctx.hooks.init_image(img_id, desc, ctx.hooks.user_data);
    }
    if img_id.id != cast(u32, SG_INVALID_ID) {
        _sgimgui_image_created(ctx, img_id, _sgimgui_slot_index(img_id.id), desc);
    }
}

void _sgimgui_init_sampler(sg_sampler smp_id, sg_sampler_desc* desc, void* user_data) {
    var ctx = cast(_sgimgui_t*, user_data);
    _sgimgui_capture_item_t* item = _sgimgui_capture_next_write_item(ctx);
    if item != null {
        item.cmd = _SGIMGUI_CMD_INIT_SAMPLER;
        item.color = 0xFF00FFFF;
        item.args.init_sampler.sampler = smp_id;
    }
    if ctx.hooks.init_sampler != null {
        ctx.hooks.init_sampler(smp_id, desc, ctx.hooks.user_data);
    }
    if smp_id.id != cast(u32, SG_INVALID_ID) {
        _sgimgui_sampler_created(ctx, smp_id, _sgimgui_slot_index(smp_id.id), desc);
    }
}

void _sgimgui_init_shader(sg_shader shd_id, sg_shader_desc* desc, void* user_data) {
    var ctx = cast(_sgimgui_t*, user_data);
    _sgimgui_capture_item_t* item = _sgimgui_capture_next_write_item(ctx);
    if item != null {
        item.cmd = _SGIMGUI_CMD_INIT_SHADER;
        item.color = 0xFF00FFFF;
        item.args.init_shader.shader = shd_id;
    }
    if ctx.hooks.init_shader != null {
        ctx.hooks.init_shader(shd_id, desc, ctx.hooks.user_data);
    }
    if shd_id.id != cast(u32, SG_INVALID_ID) {
        _sgimgui_shader_created(ctx, shd_id, _sgimgui_slot_index(shd_id.id), desc);
    }
}

void _sgimgui_init_pipeline(sg_pipeline pip_id, sg_pipeline_desc* desc, void* user_data) {
    var ctx = cast(_sgimgui_t*, user_data);
    _sgimgui_capture_item_t* item = _sgimgui_capture_next_write_item(ctx);
    if item != null {
        item.cmd = _SGIMGUI_CMD_INIT_PIPELINE;
        item.color = 0xFF00FFFF;
        item.args.init_pipeline.pipeline = pip_id;
    }
    if ctx.hooks.init_pipeline != null {
        ctx.hooks.init_pipeline(pip_id, desc, ctx.hooks.user_data);
    }
    if pip_id.id != cast(u32, SG_INVALID_ID) {
        _sgimgui_pipeline_created(ctx, pip_id, _sgimgui_slot_index(pip_id.id), desc);
    }
}

void _sgimgui_init_view(sg_view view_id, sg_view_desc* desc, void* user_data) {
    var ctx = cast(_sgimgui_t*, user_data);
    _sgimgui_capture_item_t* item = _sgimgui_capture_next_write_item(ctx);
    if item != null {
        item.cmd = _SGIMGUI_CMD_INIT_VIEW;
        item.color = 0xFF00FFFF;
        item.args.init_view.view = view_id;
    }
    if ctx.hooks.init_view != null {
        ctx.hooks.init_view(view_id, desc, ctx.hooks.user_data);
    }
    if view_id.id != cast(u32, SG_INVALID_ID) {
        _sgimgui_view_created(ctx, view_id, _sgimgui_slot_index(view_id.id), desc);
    }
}

void _sgimgui_uninit_buffer(sg_buffer buf, void* user_data) {
    var ctx = cast(_sgimgui_t*, user_data);
    _sgimgui_capture_item_t* item = _sgimgui_capture_next_write_item(ctx);
    if item != null {
        item.cmd = _SGIMGUI_CMD_UNINIT_BUFFER;
        item.color = 0xFF00FFFF;
        item.args.uninit_buffer.buffer = buf;
    }
    if ctx.hooks.uninit_buffer != null {
        ctx.hooks.uninit_buffer(buf, ctx.hooks.user_data);
    }
    if buf.id != cast(u32, SG_INVALID_ID) {
        _sgimgui_buffer_destroyed(ctx, _sgimgui_slot_index(buf.id));
    }
}

void _sgimgui_uninit_image(sg_image img, void* user_data) {
    var ctx = cast(_sgimgui_t*, user_data);
    _sgimgui_capture_item_t* item = _sgimgui_capture_next_write_item(ctx);
    if item != null {
        item.cmd = _SGIMGUI_CMD_UNINIT_IMAGE;
        item.color = 0xFF00FFFF;
        item.args.uninit_image.image = img;
    }
    if ctx.hooks.uninit_image != null {
        ctx.hooks.uninit_image(img, ctx.hooks.user_data);
    }
    if img.id != cast(u32, SG_INVALID_ID) {
        _sgimgui_image_destroyed(ctx, _sgimgui_slot_index(img.id));
    }
}

void _sgimgui_uninit_sampler(sg_sampler smp, void* user_data) {
    var ctx = cast(_sgimgui_t*, user_data);
    _sgimgui_capture_item_t* item = _sgimgui_capture_next_write_item(ctx);
    if item != null {
        item.cmd = _SGIMGUI_CMD_UNINIT_SAMPLER;
        item.color = 0xFF00FFFF;
        item.args.uninit_sampler.sampler = smp;
    }
    if ctx.hooks.uninit_sampler != null {
        ctx.hooks.uninit_sampler(smp, ctx.hooks.user_data);
    }
    if smp.id != cast(u32, SG_INVALID_ID) {
        _sgimgui_sampler_destroyed(ctx, _sgimgui_slot_index(smp.id));
    }
}

void _sgimgui_uninit_shader(sg_shader shd, void* user_data) {
    var ctx = cast(_sgimgui_t*, user_data);
    _sgimgui_capture_item_t* item = _sgimgui_capture_next_write_item(ctx);
    if item != null {
        item.cmd = _SGIMGUI_CMD_UNINIT_SHADER;
        item.color = 0xFF00FFFF;
        item.args.uninit_shader.shader = shd;
    }
    if ctx.hooks.uninit_shader != null {
        ctx.hooks.uninit_shader(shd, ctx.hooks.user_data);
    }
    if shd.id != cast(u32, SG_INVALID_ID) {
        _sgimgui_shader_destroyed(ctx, _sgimgui_slot_index(shd.id));
    }
}

void _sgimgui_uninit_pipeline(sg_pipeline pip, void* user_data) {
    var ctx = cast(_sgimgui_t*, user_data);
    _sgimgui_capture_item_t* item = _sgimgui_capture_next_write_item(ctx);
    if item != null {
        item.cmd = _SGIMGUI_CMD_UNINIT_PIPELINE;
        item.color = 0xFF00FFFF;
        item.args.uninit_pipeline.pipeline = pip;
    }
    if ctx.hooks.uninit_pipeline != null {
        ctx.hooks.uninit_pipeline(pip, ctx.hooks.user_data);
    }
    if pip.id != cast(u32, SG_INVALID_ID) {
        _sgimgui_pipeline_destroyed(ctx, _sgimgui_slot_index(pip.id));
    }
}

void _sgimgui_uninit_view(sg_view view, void* user_data) {
    var ctx = cast(_sgimgui_t*, user_data);
    _sgimgui_capture_item_t* item = _sgimgui_capture_next_write_item(ctx);
    if item != null {
        item.cmd = _SGIMGUI_CMD_UNINIT_VIEW;
        item.color = 0xFF00FFFF;
        item.args.uninit_view.view = view;
    }
    if ctx.hooks.uninit_view != null {
        ctx.hooks.uninit_view(view, ctx.hooks.user_data);
    }
    if view.id != cast(u32, SG_INVALID_ID) {
        _sgimgui_view_destroyed(ctx, _sgimgui_slot_index(view.id));
    }
}

void _sgimgui_fail_buffer(sg_buffer buf_id, void* user_data) {
    var ctx = cast(_sgimgui_t*, user_data);
    _sgimgui_capture_item_t* item = _sgimgui_capture_next_write_item(ctx);
    if item != null {
        item.cmd = _SGIMGUI_CMD_FAIL_BUFFER;
        item.color = 0xFF00FFFF;
        item.args.fail_buffer.buffer = buf_id;
    }
    if ctx.hooks.fail_buffer != null {
        ctx.hooks.fail_buffer(buf_id, ctx.hooks.user_data);
    }
}

void _sgimgui_fail_image(sg_image img_id, void* user_data) {
    var ctx = cast(_sgimgui_t*, user_data);
    _sgimgui_capture_item_t* item = _sgimgui_capture_next_write_item(ctx);
    if item != null {
        item.cmd = _SGIMGUI_CMD_FAIL_IMAGE;
        item.color = 0xFF00FFFF;
        item.args.fail_image.image = img_id;
    }
    if ctx.hooks.fail_image != null {
        ctx.hooks.fail_image(img_id, ctx.hooks.user_data);
    }
}

void _sgimgui_fail_sampler(sg_sampler smp_id, void* user_data) {
    var ctx = cast(_sgimgui_t*, user_data);
    _sgimgui_capture_item_t* item = _sgimgui_capture_next_write_item(ctx);
    if item != null {
        item.cmd = _SGIMGUI_CMD_FAIL_SAMPLER;
        item.color = 0xFF00FFFF;
        item.args.fail_sampler.sampler = smp_id;
    }
    if ctx.hooks.fail_sampler != null {
        ctx.hooks.fail_sampler(smp_id, ctx.hooks.user_data);
    }
}

void _sgimgui_fail_shader(sg_shader shd_id, void* user_data) {
    var ctx = cast(_sgimgui_t*, user_data);
    _sgimgui_capture_item_t* item = _sgimgui_capture_next_write_item(ctx);
    if item != null {
        item.cmd = _SGIMGUI_CMD_FAIL_SHADER;
        item.color = 0xFF00FFFF;
        item.args.fail_shader.shader = shd_id;
    }
    if ctx.hooks.fail_shader != null {
        ctx.hooks.fail_shader(shd_id, ctx.hooks.user_data);
    }
}

void _sgimgui_fail_pipeline(sg_pipeline pip_id, void* user_data) {
    var ctx = cast(_sgimgui_t*, user_data);
    _sgimgui_capture_item_t* item = _sgimgui_capture_next_write_item(ctx);
    if item != null {
        item.cmd = _SGIMGUI_CMD_FAIL_PIPELINE;
        item.color = 0xFF00FFFF;
        item.args.fail_pipeline.pipeline = pip_id;
    }
    if ctx.hooks.fail_pipeline != null {
        ctx.hooks.fail_pipeline(pip_id, ctx.hooks.user_data);
    }
}

void _sgimgui_fail_view(sg_view view_id, void* user_data) {
    var ctx = cast(_sgimgui_t*, user_data);
    _sgimgui_capture_item_t* item = _sgimgui_capture_next_write_item(ctx);
    if item != null {
        item.cmd = _SGIMGUI_CMD_FAIL_VIEW;
        item.color = 0xFF00FFFF;
        item.args.fail_view.view = view_id;
    }
    if ctx.hooks.fail_view != null {
        ctx.hooks.fail_view(view_id, ctx.hooks.user_data);
    }
}

void _sgimgui_push_debug_group(u8* name, void* user_data) {
    var ctx = cast(_sgimgui_t*, user_data);
    if 0 == strcmp(name, "sokol-imgui") {
        ctx.frame_stats_window.in_sokol_imgui = true;
        if ctx.frame_stats_window.disable_sokol_imgui_stats != 0 {
            sg_disable_stats();
        }
    }
    _sgimgui_capture_item_t* item = _sgimgui_capture_next_write_item(ctx);
    if item != null {
        item.cmd = _SGIMGUI_CMD_PUSH_DEBUG_GROUP;
        item.color = 0xFFCCCCCC;
        item.args.push_debug_group.name = _sgimgui_make_str(name);
    }
    if ctx.hooks.push_debug_group != null {
        ctx.hooks.push_debug_group(name, ctx.hooks.user_data);
    }
}

void _sgimgui_pop_debug_group(void* user_data) {
    var ctx = cast(_sgimgui_t*, user_data);
    if ctx.frame_stats_window.in_sokol_imgui != 0 {
        ctx.frame_stats_window.in_sokol_imgui = false;
        if ctx.frame_stats_window.disable_sokol_imgui_stats != 0 {
            sg_enable_stats();
        }
    }
    _sgimgui_capture_item_t* item = _sgimgui_capture_next_write_item(ctx);
    if item != null {
        item.cmd = _SGIMGUI_CMD_POP_DEBUG_GROUP;
        item.color = 0xFFCCCCCC;
    }
    if ctx.hooks.pop_debug_group != null {
        ctx.hooks.pop_debug_group(ctx.hooks.user_data);
    }
}

/*--- IMGUI HELPERS ----------------------------------------------------------*/
void _sgimgui_draw_image(_sgimgui_t* ctx, sg_image img, f32* opt_scale_ptr, f32 max_width) {
    if sg_query_image_state(img) != SG_RESOURCESTATE_VALID {
        _sgimgui_igtext("Image not in valid state.");
        return;
    }
    var view = sg_view{SG_INVALID_ID};
    for i32 i = 0; i < ctx.view_window.num_slots; i++ {
        _sgimgui_view_t* view_ui = &ctx.view_window.slots[i];
        if sg_query_view_type(view_ui.res_id) == SG_VIEWTYPE_TEXTURE {
            sg_image view_img = sg_query_view_image(view_ui.res_id);
            if view_img.id == img.id {
                bool image_renderable = sg_query_image_type(view_img) == SG_IMAGETYPE_2D && sg_query_image_sample_count(view_img) == 1 && sg_query_pixelformat(sg_query_image_pixelformat(view_img)).filter;
                if image_renderable != 0 {
                    view = view_ui.res_id;
                    break;
                }
            }
        }
    }
    if view.id != cast(u32, SG_INVALID_ID) {
        _sgimgui_igpushidint(cast(i32, view.id));
        f32 scale = 1.0f;
        if opt_scale_ptr != null {
            _sgimgui_igsliderfloatex("Scale", opt_scale_ptr, 0.125f, 8.0f, "%.3f", ImGuiSliderFlags_Logarithmic);
            scale = *opt_scale_ptr;
        }
        f32 w = cast(f32, sg_query_image_width(img)) * scale;
        f32 h = cast(f32, sg_query_image_height(img)) * scale;
        if max_width > 1.0f && w > max_width {
            h *= max_width / w;
            w = max_width;
        }
        _sgimgui_igimage(simgui_imtextureid(view), ImVec2{w, h});
        _sgimgui_igpopid();
    } else {
        _sgimgui_igtext("Image has no renderable texture view.");
    }
}

bool _sgimgui_draw_resid_list_item(u32 res_id, u8* label, bool selected) {
    _sgimgui_igpushidint(cast(i32, res_id));
    bool res;
    if label[0] != 0 {
        res = _sgimgui_igselectableex(label, selected, 0, ImVec2{0.0f, 0.0f});
    } else {
        noinit _sgimgui_str_t str_var;  // renamed from: str
        _sgimgui_snprintf(&str_var, "0x%08X", res_id);
        res = _sgimgui_igselectableex(str_var.buf, selected, 0, ImVec2{0.0f, 0.0f});
    }
    _sgimgui_igpopid();
    return res;
}

bool _sgimgui_draw_resid_link(u32 res_type, u32 res_id, u8* label) {
    noinit _sgimgui_str_t str_buf;
    u8* str_var;  // renamed from: str
    if label[0] != 0 {
        str_var = label;
    } else {
        _sgimgui_snprintf(&str_buf, "0x%08X", res_id);
        str_var = str_buf.buf;
    }
    _sgimgui_igpushidint(cast(i32, res_type << 24 | res_id));
    bool res = _sgimgui_igsmallbutton(str_var);
    _sgimgui_igpopid();
    return res;
}

bool _sgimgui_draw_buffer_link(_sgimgui_t* ctx, sg_buffer buf) {
    bool retval = false;
    if buf.id != cast(u32, SG_INVALID_ID) {
        _sgimgui_buffer_t* buf_ui = &ctx.buffer_window.slots[_sgimgui_slot_index(buf.id)];
        retval = _sgimgui_draw_resid_link(1, buf.id, buf_ui.label.buf);
    }
    return retval;
}

bool _sgimgui_draw_image_link(_sgimgui_t* ctx, sg_image img) {
    bool retval = false;
    if img.id != cast(u32, SG_INVALID_ID) {
        _sgimgui_image_t* img_ui = &ctx.image_window.slots[_sgimgui_slot_index(img.id)];
        retval = _sgimgui_draw_resid_link(2, img.id, img_ui.label.buf);
    }
    return retval;
}

bool _sgimgui_draw_sampler_link(_sgimgui_t* ctx, sg_sampler smp) {
    bool retval = false;
    if smp.id != cast(u32, SG_INVALID_ID) {
        _sgimgui_sampler_t* smp_ui = &ctx.sampler_window.slots[_sgimgui_slot_index(smp.id)];
        retval = _sgimgui_draw_resid_link(3, smp.id, smp_ui.label.buf);
    }
    return retval;
}

bool _sgimgui_draw_shader_link(_sgimgui_t* ctx, sg_shader shd) {
    bool retval = false;
    if shd.id != cast(u32, SG_INVALID_ID) {
        _sgimgui_shader_t* shd_ui = &ctx.shader_window.slots[_sgimgui_slot_index(shd.id)];
        retval = _sgimgui_draw_resid_link(4, shd.id, shd_ui.label.buf);
    }
    return retval;
}

bool _sgimgui_draw_view_link(_sgimgui_t* ctx, sg_view view) {
    bool retval = false;
    if view.id != cast(u32, SG_INVALID_ID) {
        _sgimgui_view_t* view_ui = &ctx.view_window.slots[_sgimgui_slot_index(view.id)];
        retval = _sgimgui_draw_resid_link(5, view.id, view_ui.label.buf);
        if _sgimgui_igisitemhovered(0) != 0 {
            sg_image img = sg_query_view_image(view);
            if img.id != cast(u32, SG_INVALID_ID) {
                if _sgimgui_igbegintooltip() != 0 {
                    _sgimgui_draw_image(ctx, img, null, 128.0f);
                    _sgimgui_igendtooltip();
                }
            }
        }
    }
    return retval;
}

void _sgimgui_show_buffer(_sgimgui_t* ctx, sg_buffer buf) {
    ctx.buffer_window.open = true;
    ctx.buffer_window.sel_buf = buf;
}

void _sgimgui_show_image(_sgimgui_t* ctx, sg_image img) {
    ctx.image_window.open = true;
    ctx.image_window.sel_img = img;
}

void _sgimgui_show_sampler(_sgimgui_t* ctx, sg_sampler smp) {
    ctx.sampler_window.open = true;
    ctx.sampler_window.sel_smp = smp;
}

void _sgimgui_show_shader(_sgimgui_t* ctx, sg_shader shd) {
    ctx.shader_window.open = true;
    ctx.shader_window.sel_shd = shd;
}

void _sgimgui_show_view(_sgimgui_t* ctx, sg_view view) {
    ctx.view_window.open = true;
    ctx.view_window.sel_view = view;
}

void _sgimgui_draw_buffer_list(_sgimgui_t* ctx) {
    _sgimgui_igbeginchild("buffer_list", ImVec2{192.0f, 0.0f}, ImGuiChildFlags_Borders, ImGuiWindowFlags_None);
    for i32 i = 0; i < ctx.buffer_window.num_slots; i++ {
        sg_buffer buf = ctx.buffer_window.slots[i].res_id;
        sg_resource_state state = sg_query_buffer_state(buf);
        if state != SG_RESOURCESTATE_INVALID && state != SG_RESOURCESTATE_INITIAL {
            bool selected = ctx.buffer_window.sel_buf.id == buf.id;
            if _sgimgui_draw_resid_list_item(buf.id, ctx.buffer_window.slots[i].label.buf, selected) != 0 {
                ctx.buffer_window.sel_buf.id = buf.id;
            }
        }
    }
    _sgimgui_igendchild();
}

void _sgimgui_draw_image_list(_sgimgui_t* ctx) {
    _sgimgui_igbeginchild("image_list", ImVec2{192.0f, 0.0f}, ImGuiChildFlags_Borders, ImGuiWindowFlags_None);
    for i32 i = 0; i < ctx.image_window.num_slots; i++ {
        sg_image img = ctx.image_window.slots[i].res_id;
        sg_resource_state state = sg_query_image_state(img);
        if state != SG_RESOURCESTATE_INVALID && state != SG_RESOURCESTATE_INITIAL {
            bool selected = ctx.image_window.sel_img.id == img.id;
            if _sgimgui_draw_resid_list_item(img.id, ctx.image_window.slots[i].label.buf, selected) != 0 {
                ctx.image_window.sel_img.id = img.id;
            }
        }
    }
    _sgimgui_igendchild();
}

void _sgimgui_draw_sampler_list(_sgimgui_t* ctx) {
    _sgimgui_igbeginchild("sampler_list", ImVec2{192.0f, 0.0f}, ImGuiChildFlags_Borders, ImGuiWindowFlags_None);
    for i32 i = 0; i < ctx.sampler_window.num_slots; i++ {
        sg_sampler smp = ctx.sampler_window.slots[i].res_id;
        sg_resource_state state = sg_query_sampler_state(smp);
        if state != SG_RESOURCESTATE_INVALID && state != SG_RESOURCESTATE_INITIAL {
            bool selected = ctx.sampler_window.sel_smp.id == smp.id;
            if _sgimgui_draw_resid_list_item(smp.id, ctx.sampler_window.slots[i].label.buf, selected) != 0 {
                ctx.sampler_window.sel_smp.id = smp.id;
            }
        }
    }
    _sgimgui_igendchild();
}

void _sgimgui_draw_shader_list(_sgimgui_t* ctx) {
    _sgimgui_igbeginchild("shader_list", ImVec2{192.0f, 0.0f}, ImGuiChildFlags_Borders, ImGuiWindowFlags_None);
    for i32 i = 0; i < ctx.shader_window.num_slots; i++ {
        sg_shader shd = ctx.shader_window.slots[i].res_id;
        sg_resource_state state = sg_query_shader_state(shd);
        if state != SG_RESOURCESTATE_INVALID && state != SG_RESOURCESTATE_INITIAL {
            bool selected = ctx.shader_window.sel_shd.id == shd.id;
            if _sgimgui_draw_resid_list_item(shd.id, ctx.shader_window.slots[i].label.buf, selected) != 0 {
                ctx.shader_window.sel_shd.id = shd.id;
            }
        }
    }
    _sgimgui_igendchild();
}

void _sgimgui_draw_pipeline_list(_sgimgui_t* ctx) {
    _sgimgui_igbeginchild("pipeline_list", ImVec2{192.0f, 0.0f}, ImGuiChildFlags_Borders, ImGuiWindowFlags_None);
    for i32 i = 0; i < ctx.pipeline_window.num_slots; i++ {
        sg_pipeline pip = ctx.pipeline_window.slots[i].res_id;
        sg_resource_state state = sg_query_pipeline_state(pip);
        if state != SG_RESOURCESTATE_INVALID && state != SG_RESOURCESTATE_INITIAL {
            bool selected = ctx.pipeline_window.sel_pip.id == pip.id;
            if _sgimgui_draw_resid_list_item(pip.id, ctx.pipeline_window.slots[i].label.buf, selected) != 0 {
                ctx.pipeline_window.sel_pip.id = pip.id;
            }
        }
    }
    _sgimgui_igendchild();
}

void _sgimgui_draw_view_list(_sgimgui_t* ctx) {
    _sgimgui_igbeginchild("view_list", ImVec2{192.0f, 0.0f}, ImGuiChildFlags_Borders, ImGuiWindowFlags_None);
    for i32 i = 0; i < ctx.view_window.num_slots; i++ {
        sg_view view = ctx.view_window.slots[i].res_id;
        sg_resource_state state = sg_query_view_state(view);
        if state != SG_RESOURCESTATE_INVALID && state != SG_RESOURCESTATE_INITIAL {
            bool selected = ctx.view_window.sel_view.id == view.id;
            if _sgimgui_draw_resid_list_item(view.id, ctx.view_window.slots[i].label.buf, selected) != 0 {
                ctx.view_window.sel_view.id = view.id;
            }
        }
    }
    _sgimgui_igendchild();
}

void _sgimgui_draw_capture_list(_sgimgui_t* ctx) {
    _sgimgui_igbeginchild("capture_list", ImVec2{192.0f, 0.0f}, ImGuiChildFlags_Borders, ImGuiWindowFlags_None);
    i32 num_items = _sgimgui_capture_num_read_items(ctx);
    u64 group_stack = 1;
    for i32 i = 0; i < num_items; i++ {
        _sgimgui_capture_item_t* item = _sgimgui_capture_read_item_at(ctx, i);
        _sgimgui_str_t item_string = _sgimgui_capture_item_string(ctx, i, item);
        _sgimgui_igpushstylecolor(ImGuiCol_Text, item.color);
        _sgimgui_igpushidint(i);
        if item.cmd == _SGIMGUI_CMD_PUSH_DEBUG_GROUP {
            if (group_stack & 1) != 0 {
                group_stack <<= 1;
                u8* group_name = item.args.push_debug_group.name.buf;
                if _sgimgui_igtreenodestr(group_name, "Group: %s", group_name) != 0 {
                    group_stack |= 1;
                }
            } else {
                group_stack <<= 1;
            }
        } else if item.cmd == _SGIMGUI_CMD_POP_DEBUG_GROUP {
            if (group_stack & 1) != 0 {
                _sgimgui_igtreepop();
            }
            group_stack >>= 1;
        } else if (group_stack & 1) != 0 {
            if _sgimgui_igselectableex(item_string.buf, ctx.capture_window.sel_item == i, 0, ImVec2{0.0f, 0.0f}) != 0 {
                ctx.capture_window.sel_item = i;
            }
            if _sgimgui_igisitemhovered(0) != 0 {
                _sgimgui_igsettooltip("%s", item_string.buf);
            }
        }
        _sgimgui_igpopid();
        _sgimgui_igpopstylecolor();
    }
    _sgimgui_igendchild();
}

void _sgimgui_draw_buffer_panel(_sgimgui_t* ctx, sg_buffer buf) {
    if buf.id != cast(u32, SG_INVALID_ID) {
        _sgimgui_igbeginchild("buffer", ImVec2{0.0f, 0.0f}, ImGuiChildFlags_None, ImGuiWindowFlags_None);
        sg_buffer_info info = sg_query_buffer_info(buf);
        if info.slot.state == SG_RESOURCESTATE_VALID {
            _sgimgui_buffer_t* buf_ui = &ctx.buffer_window.slots[_sgimgui_slot_index(buf.id)];
            _sgimgui_igtext("Label: %s", buf_ui.label.buf[0] != 0 ? buf_ui.label.buf : "---");
            _sgimgui_draw_resource_slot(&info.slot);
            _sgimgui_igseparator();
            _sgimgui_igtext("Usage:\n");
            _sgimgui_igtext("  vertex_buffer: %s", _sgimgui_bool_string(buf_ui.desc.usage.vertex_buffer));
            _sgimgui_igtext("  index_buffer: %s", _sgimgui_bool_string(buf_ui.desc.usage.index_buffer));
            _sgimgui_igtext("  storage_buffer: %s", _sgimgui_bool_string(buf_ui.desc.usage.storage_buffer));
            _sgimgui_igtext("  immutable: %s", _sgimgui_bool_string(buf_ui.desc.usage.immutable));
            _sgimgui_igtext("  dynamic_update: %s", _sgimgui_bool_string(buf_ui.desc.usage.dynamic_update));
            _sgimgui_igtext("  stream_update: %s", _sgimgui_bool_string(buf_ui.desc.usage.stream_update));
            _sgimgui_igtext("  write_unsealed: %s", _sgimgui_bool_string(buf_ui.desc.usage.write_unsealed));
            _sgimgui_igtext("Size:  %d", cast(i32, buf_ui.desc.size));
            if buf_ui.desc.usage.immutable == 0 {
                _sgimgui_igseparator();
                _sgimgui_igtext("Num Slots:     %d", info.num_slots);
                _sgimgui_igtext("Active Slot:   %d", info.active_slot);
                _sgimgui_igtext("Update Frame Index: %d", info.update_frame_index);
                _sgimgui_igtext("Append Frame Index: %d", info.append_frame_index);
                _sgimgui_igtext("Append Pos:         %d", info.append_pos);
                _sgimgui_igtext("Append Overflow:    %s", _sgimgui_bool_string(info.append_overflow));
            }
        } else {
            _sgimgui_igtext("Buffer 0x%08X not valid.", buf.id);
        }
        _sgimgui_igendchild();
    }
}

void _sgimgui_draw_image_panel(_sgimgui_t* ctx, sg_image img) {
    if img.id != cast(u32, SG_INVALID_ID) {
        _sgimgui_igbeginchild("image", ImVec2{0.0f, 0.0f}, ImGuiChildFlags_None, ImGuiWindowFlags_None);
        sg_image_info info = sg_query_image_info(img);
        if info.slot.state == SG_RESOURCESTATE_VALID {
            _sgimgui_image_t* img_ui = &ctx.image_window.slots[_sgimgui_slot_index(img.id)];
            sg_image_desc* desc = &img_ui.desc;
            _sgimgui_igtext("Label: %s", img_ui.label.buf[0] != 0 ? img_ui.label.buf : "---");
            _sgimgui_draw_resource_slot(&info.slot);
            _sgimgui_igseparator();
            _sgimgui_draw_image(ctx, img, &img_ui.ui_scale, 4096.0f);
            _sgimgui_igseparator();
            _sgimgui_igtext("Type:           %s", _sgimgui_imagetype_string(desc.type));
            _sgimgui_igtext("Usage:\n");
            _sgimgui_igtext("  storage_image: %s", _sgimgui_bool_string(desc.usage.storage_image));
            _sgimgui_igtext("  color_attachment: %s", _sgimgui_bool_string(desc.usage.color_attachment));
            _sgimgui_igtext("  resolve_attachment: %s", _sgimgui_bool_string(desc.usage.resolve_attachment));
            _sgimgui_igtext("  depth_stencil_attachment: %s", _sgimgui_bool_string(desc.usage.depth_stencil_attachment));
            _sgimgui_igtext("  immutable: %s", _sgimgui_bool_string(desc.usage.immutable));
            _sgimgui_igtext("  dynamic_update: %s", _sgimgui_bool_string(desc.usage.dynamic_update));
            _sgimgui_igtext("  stream_update: %s", _sgimgui_bool_string(desc.usage.stream_update));
            _sgimgui_igtext("  write_unsealed: %s", _sgimgui_bool_string(desc.usage.write_unsealed));
            _sgimgui_igtext("Width:          %d", desc.width);
            _sgimgui_igtext("Height:         %d", desc.height);
            _sgimgui_igtext("Num Slices:     %d", desc.num_slices);
            _sgimgui_igtext("Num Mipmaps:    %d", desc.num_mipmaps);
            _sgimgui_igtext("Pixel Format:   %s", _sgimgui_pixelformat_string(desc.pixel_format));
            _sgimgui_igtext("Sample Count:   %d", desc.sample_count);
            if desc.usage.immutable == 0 {
                _sgimgui_igseparator();
                _sgimgui_igtext("Num Slots:     %d", info.num_slots);
                _sgimgui_igtext("Active Slot:   %d", info.active_slot);
                _sgimgui_igtext("Update Frame Index: %d", info.upd_frame_index);
            }
        } else {
            _sgimgui_igtext("Image 0x%08X not valid.", img.id);
        }
        _sgimgui_igendchild();
    }
}

void _sgimgui_draw_sampler_panel(_sgimgui_t* ctx, sg_sampler smp) {
    if smp.id != cast(u32, SG_INVALID_ID) {
        _sgimgui_igbeginchild("sampler", ImVec2{0.0f, 0.0f}, ImGuiChildFlags_None, ImGuiWindowFlags_None);
        sg_sampler_info info = sg_query_sampler_info(smp);
        if info.slot.state == SG_RESOURCESTATE_VALID {
            _sgimgui_sampler_t* smp_ui = &ctx.sampler_window.slots[_sgimgui_slot_index(smp.id)];
            sg_sampler_desc* desc = &smp_ui.desc;
            _sgimgui_igtext("Label: %s", smp_ui.label.buf[0] != 0 ? smp_ui.label.buf : "---");
            _sgimgui_draw_resource_slot(&info.slot);
            _sgimgui_igseparator();
            _sgimgui_igtext("Min Filter:     %s", _sgimgui_filter_string(desc.min_filter));
            _sgimgui_igtext("Mag Filter:     %s", _sgimgui_filter_string(desc.mag_filter));
            _sgimgui_igtext("Mipmap Filter:  %s", _sgimgui_filter_string(desc.mipmap_filter));
            _sgimgui_igtext("Wrap U:         %s", _sgimgui_wrap_string(desc.wrap_u));
            _sgimgui_igtext("Wrap V:         %s", _sgimgui_wrap_string(desc.wrap_v));
            _sgimgui_igtext("Wrap W:         %s", _sgimgui_wrap_string(desc.wrap_w));
            _sgimgui_igtext("Min LOD:        %.3f", desc.min_lod);
            _sgimgui_igtext("Max LOD:        %.3f", desc.max_lod);
            _sgimgui_igtext("Border Color:   %s", _sgimgui_bordercolor_string(desc.border_color));
            _sgimgui_igtext("Compare:        %s", _sgimgui_comparefunc_string(desc.compare));
            _sgimgui_igtext("Max Anisotropy: %d", desc.max_anisotropy);
        } else {
            _sgimgui_igtext("Sampler 0x%08X not valid.", smp.id);
        }
        _sgimgui_igendchild();
    }
}

void _sgimgui_draw_shader_func(u8* title, sg_shader_function* func) {
    if func.source == null && func.bytecode.ptr == null {
        return;
    }
    _sgimgui_igpushid(title);
    _sgimgui_igtext("%s", title);
    if func.entry != null {
        _sgimgui_igtext("  entry: %s", func.entry);
    }
    if func.d3d11_target != null {
        _sgimgui_igtext("  d3d11_target: %s", func.d3d11_target);
    }
    if func.source != null {
        if _sgimgui_igtreenode("source:") != 0 {
            _sgimgui_igtext("%s", func.source);
            _sgimgui_igtreepop();
        }
    } else if func.bytecode.ptr != null {
        if _sgimgui_igtreenode("bytecode") != 0 {
            _sgimgui_igtext("Byte-code display currently not supported.");
            _sgimgui_igtreepop();
        }
    }
    _sgimgui_igpopid();
}

void _sgimgui_draw_shader_panel(_sgimgui_t* ctx, sg_shader shd) {
    if shd.id != cast(u32, SG_INVALID_ID) {
        _sgimgui_igbeginchild("shader", ImVec2{0.0f, 0.0f}, ImGuiChildFlags_None, ImGuiWindowFlags_HorizontalScrollbar);
        sg_shader_info info = sg_query_shader_info(shd);
        if info.slot.state == SG_RESOURCESTATE_VALID {
            _sgimgui_shader_t* shd_ui = &ctx.shader_window.slots[_sgimgui_slot_index(shd.id)];
            _sgimgui_igtext("Label: %s", shd_ui.label.buf[0] != 0 ? shd_ui.label.buf : "---");
            _sgimgui_draw_resource_slot(&info.slot);
            _sgimgui_igseparator();
            if _sgimgui_igtreenode("Attrs") != 0 {
                for i32 i = 0; i < SG_MAX_VERTEX_ATTRIBUTES; i++ {
                    sg_shader_vertex_attr* a_desc = &shd_ui.desc.attrs[i];
                    if a_desc.base_type != SG_SHADERATTRBASETYPE_UNDEFINED || a_desc.glsl_name || a_desc.hlsl_sem_name {
                        _sgimgui_igtext("#%d:", i);
                        if a_desc.base_type != SG_SHADERATTRBASETYPE_UNDEFINED {
                            _sgimgui_igtext("  Base Type: %s", _sgimgui_shaderattrbasetype_string(a_desc.base_type));
                        }
                        if a_desc.glsl_name != null {
                            _sgimgui_igtext("  GLSL Name: %s", a_desc.glsl_name);
                        }
                        if a_desc.hlsl_sem_name != null {
                            _sgimgui_igtext("  HLSL Sem Name:  %s", a_desc.hlsl_sem_name);
                            _sgimgui_igtext("  HLSL Sem Index: %d", a_desc.hlsl_sem_index);
                        }
                    }
                }
                _sgimgui_igtreepop();
            }
            i32 num_valid_ubs = 0;
            for i32 i = 0; i < SG_MAX_UNIFORMBLOCK_BINDSLOTS; i++ {
                sg_shader_uniform_block* ub = &shd_ui.desc.uniform_blocks[i];
                if ub.stage != SG_SHADERSTAGE_NONE {
                    num_valid_ubs++;
                }
            }
            i32 num_valid_views = 0;
            for i32 i = 0; i < SG_MAX_VIEW_BINDSLOTS; i++ {
                sg_shader_view* view = &shd_ui.desc.views[i];
                if view.texture.stage != SG_SHADERSTAGE_NONE || view.storage_buffer.stage != SG_SHADERSTAGE_NONE || view.storage_image.stage != SG_SHADERSTAGE_NONE {
                    num_valid_views++;
                }
            }
            i32 num_valid_samplers = 0;
            for i32 i = 0; i < SG_MAX_SAMPLER_BINDSLOTS; i++ {
                if shd_ui.desc.samplers[i].stage != SG_SHADERSTAGE_NONE {
                    num_valid_samplers++;
                }
            }
            i32 num_valid_texture_sampler_pairs = 0;
            for i32 i = 0; i < SG_MAX_TEXTURE_SAMPLER_PAIRS; i++ {
                if shd_ui.desc.texture_sampler_pairs[i].stage != SG_SHADERSTAGE_NONE {
                    num_valid_texture_sampler_pairs++;
                }
            }
            if num_valid_ubs > 0 {
                if _sgimgui_igtreenode("Uniform Blocks") != 0 {
                    for i32 i = 0; i < SG_MAX_UNIFORMBLOCK_BINDSLOTS; i++ {
                        sg_shader_uniform_block* ub = &shd_ui.desc.uniform_blocks[i];
                        if ub.stage == SG_SHADERSTAGE_NONE {
                            continue;
                        }
                        _sgimgui_igtext("- slot: %d", i);
                        _sgimgui_igtext("  stage: %s", _sgimgui_shaderstage_string(ub.stage));
                        _sgimgui_igtext("  size: %d", ub.size);
                        _sgimgui_igtext("  layout: %s", _sgimgui_uniformlayout_string(ub.layout));
                        _sgimgui_igtext("  hlsl_register_b_n: %d", ub.hlsl_register_b_n);
                        _sgimgui_igtext("  msl_buffer_n: %d", ub.msl_buffer_n);
                        _sgimgui_igtext("  wgsl_group0_binding_n: %d", ub.wgsl_group0_binding_n);
                        _sgimgui_igtext("  spirv_set0_binding_n: %d", ub.spirv_set0_binding_n);
                        _sgimgui_igtext("  glsl_uniforms:");
                        for i32 j = 0; j < SG_MAX_UNIFORMBLOCK_MEMBERS; j++ {
                            sg_glsl_shader_uniform* u = &ub.glsl_uniforms[j];
                            if SG_UNIFORMTYPE_INVALID != u.type {
                                if u.array_count <= 1 {
                                    _sgimgui_igtext("    %s %s", _sgimgui_uniformtype_string(u.type), u.glsl_name != null ? u.glsl_name : "");
                                } else {
                                    _sgimgui_igtext("    %s[%d] %s", _sgimgui_uniformtype_string(u.type), u.array_count, u.glsl_name != null ? u.glsl_name : "");
                                }
                            }
                        }
                    }
                    _sgimgui_igtreepop();
                }
            }
            if num_valid_views > 0 {
                if _sgimgui_igtreenode("Views") != 0 {
                    for i32 i = 0; i < SG_MAX_VIEW_BINDSLOTS; i++ {
                        sg_shader_view* view = &shd_ui.desc.views[i];
                        if view.texture.stage != SG_SHADERSTAGE_NONE {
                            sg_shader_texture_view* tex = &view.texture;
                            _sgimgui_igtext("- slot: %d", i);
                            _sgimgui_igtext("  stage: %s", _sgimgui_shaderstage_string(tex.stage));
                            _sgimgui_igtext("  type: SG_VIEWTYPE_TEXTURE");
                            _sgimgui_igtext("  image_type: %s", _sgimgui_imagetype_string(tex.image_type));
                            _sgimgui_igtext("  sample_type: %s", _sgimgui_imagesampletype_string(tex.sample_type));
                            _sgimgui_igtext("  multisampled: %s", _sgimgui_bool_string(tex.multisampled));
                            _sgimgui_igtext("  hlsl_register_t_n: %d", tex.hlsl_register_t_n);
                            _sgimgui_igtext("  msl_texture_n: %d", tex.msl_texture_n);
                            _sgimgui_igtext("  wgsl_group1_binding_n: %d", tex.wgsl_group1_binding_n);
                            _sgimgui_igtext("  spirv_set1_binding_n: %d", tex.spirv_set1_binding_n);
                        } else if view.storage_buffer.stage != SG_SHADERSTAGE_NONE {
                            sg_shader_storage_buffer_view* sbuf = &view.storage_buffer;
                            _sgimgui_igtext("- slot: %d", i);
                            _sgimgui_igtext("  stage: %s", _sgimgui_shaderstage_string(sbuf.stage));
                            _sgimgui_igtext("  type: SG_VIEWTYPE_STORAGEBUFFER");
                            _sgimgui_igtext("  readonly: %s", _sgimgui_bool_string(sbuf.readonly));
                            if sbuf.readonly != 0 {
                                _sgimgui_igtext("  hlsl_register_t_n: %d", sbuf.hlsl_register_t_n);
                            } else {
                                _sgimgui_igtext("  hlsl_register_u_n: %d", sbuf.hlsl_register_u_n);
                            }
                            _sgimgui_igtext("  msl_buffer_n: %d", sbuf.msl_buffer_n);
                            _sgimgui_igtext("  wgsl_group1_binding_n: %d", sbuf.wgsl_group1_binding_n);
                            _sgimgui_igtext("  spirv_group1_binding_n: %d\n", sbuf.spirv_set1_binding_n);
                            _sgimgui_igtext("  glsl_binding_n: %d", sbuf.glsl_binding_n);
                        } else if view.storage_image.stage != SG_SHADERSTAGE_NONE {
                            sg_shader_storage_image_view* simg = &view.storage_image;
                            _sgimgui_igtext("- slot: %d", i);
                            _sgimgui_igtext("  stage: %s", _sgimgui_shaderstage_string(simg.stage));
                            _sgimgui_igtext("  type: SG_VIEWTYPE_STORAGEIMAGE");
                            _sgimgui_igtext("  image_type: %s", _sgimgui_imagetype_string(simg.image_type));
                            _sgimgui_igtext("  access_format: %s", _sgimgui_pixelformat_string(simg.access_format));
                            _sgimgui_igtext("  writeonly: %s", _sgimgui_bool_string(simg.writeonly));
                            _sgimgui_igtext("  hlsl_register_u_n: %d", simg.hlsl_register_u_n);
                            _sgimgui_igtext("  msl_texture_n: %d", simg.msl_texture_n);
                            _sgimgui_igtext("  wgsl_group1_binding_n: %d", simg.wgsl_group1_binding_n);
                            _sgimgui_igtext("  spirv_set1_binding_n: %d", simg.spirv_set1_binding_n);
                            _sgimgui_igtext("  glsl_binding_n: %d", simg.glsl_binding_n);
                        }
                    }
                    _sgimgui_igtreepop();
                }
            }
            if num_valid_samplers > 0 {
                if _sgimgui_igtreenode("Samplers") != 0 {
                    for i32 i = 0; i < SG_MAX_SAMPLER_BINDSLOTS; i++ {
                        sg_shader_sampler* ssd = &shd_ui.desc.samplers[i];
                        if ssd.stage == SG_SHADERSTAGE_NONE {
                            continue;
                        }
                        _sgimgui_igtext("- slot: %d", i);
                        _sgimgui_igtext("  stage: %s", _sgimgui_shaderstage_string(ssd.stage));
                        _sgimgui_igtext("  sampler_type: %s", _sgimgui_samplertype_string(ssd.sampler_type));
                        _sgimgui_igtext("  hlsl_register_s_n: %d", ssd.hlsl_register_s_n);
                        _sgimgui_igtext("  msl_sampler_n: %d", ssd.msl_sampler_n);
                        _sgimgui_igtext("  wgsl_group1_binding_n: %d", ssd.wgsl_group1_binding_n);
                        _sgimgui_igtext("  spirv_set1_binding_1: %d", ssd.spirv_set1_binding_n);
                    }
                    _sgimgui_igtreepop();
                }
            }
            if num_valid_texture_sampler_pairs > 0 {
                if _sgimgui_igtreenode("Texture Sampler Pairs") != 0 {
                    for i32 i = 0; i < SG_MAX_TEXTURE_SAMPLER_PAIRS; i++ {
                        sg_shader_texture_sampler_pair* stspd = &shd_ui.desc.texture_sampler_pairs[i];
                        if stspd.stage == SG_SHADERSTAGE_NONE {
                            continue;
                        }
                        _sgimgui_igtext("- slot: %d", i);
                        _sgimgui_igtext("  stage: %s", _sgimgui_shaderstage_string(stspd.stage));
                        _sgimgui_igtext("  view_slot: %d", stspd.view_slot);
                        _sgimgui_igtext("  sampler_slot: %d", stspd.sampler_slot);
                        _sgimgui_igtext("  glsl_name: %s", stspd.glsl_name != null ? stspd.glsl_name : "---");
                    }
                    _sgimgui_igtreepop();
                }
            }
            _sgimgui_draw_shader_func("Vertex Function", &shd_ui.desc.vertex_func);
            _sgimgui_draw_shader_func("Fragment Function", &shd_ui.desc.fragment_func);
            _sgimgui_draw_shader_func("Compute Function", &shd_ui.desc.compute_func);
        } else {
            _sgimgui_igtext("Shader 0x%08X not valid!", shd.id);
        }
        _sgimgui_igendchild();
    }
}

void _sgimgui_draw_vertex_layout_state(sg_vertex_layout_state* layout) {
    if _sgimgui_igtreenode("Buffers") != 0 {
        for i32 i = 0; i < SG_MAX_VERTEXBUFFER_BINDSLOTS; i++ {
            sg_vertex_buffer_layout_state* l_state = &layout.buffers[i];
            if l_state.stride > 0 {
                _sgimgui_igtext("#%d:", i);
                _sgimgui_igtext("  Stride:    %d", l_state.stride);
                _sgimgui_igtext("  Step Func: %s", _sgimgui_vertexstep_string(l_state.step_func));
                _sgimgui_igtext("  Step Rate: %d", l_state.step_rate);
            }
        }
        _sgimgui_igtreepop();
    }
    if _sgimgui_igtreenode("Attrs") != 0 {
        for i32 i = 0; i < SG_MAX_VERTEX_ATTRIBUTES; i++ {
            sg_vertex_attr_state* a_state = &layout.attrs[i];
            if a_state.format != SG_VERTEXFORMAT_INVALID {
                _sgimgui_igtext("#%d:", i);
                _sgimgui_igtext("  Format:       %s", _sgimgui_vertexformat_string(a_state.format));
                _sgimgui_igtext("  Offset:       %d", a_state.offset);
                _sgimgui_igtext("  Buffer Index: %d", a_state.buffer_index);
            }
        }
        _sgimgui_igtreepop();
    }
}

void _sgimgui_draw_stencil_face_state(sg_stencil_face_state* sfs) {
    _sgimgui_igtext("Fail Op:       %s", _sgimgui_stencilop_string(sfs.fail_op));
    _sgimgui_igtext("Depth Fail Op: %s", _sgimgui_stencilop_string(sfs.depth_fail_op));
    _sgimgui_igtext("Pass Op:       %s", _sgimgui_stencilop_string(sfs.pass_op));
    _sgimgui_igtext("Compare:       %s", _sgimgui_comparefunc_string(sfs.compare));
}

void _sgimgui_draw_stencil_state(sg_stencil_state* ss) {
    _sgimgui_igtext("Enabled:    %s", _sgimgui_bool_string(ss.enabled));
    _sgimgui_igtext("Read Mask:  0x%02X", ss.read_mask);
    _sgimgui_igtext("Write Mask: 0x%02X", ss.write_mask);
    _sgimgui_igtext("Ref:        0x%02X", ss.ref);
    if _sgimgui_igtreenode("Front") != 0 {
        _sgimgui_draw_stencil_face_state(&ss.front);
        _sgimgui_igtreepop();
    }
    if _sgimgui_igtreenode("Back") != 0 {
        _sgimgui_draw_stencil_face_state(&ss.back);
        _sgimgui_igtreepop();
    }
}

void _sgimgui_draw_depth_state(sg_depth_state* ds) {
    _sgimgui_igtext("Pixel Format:  %s", _sgimgui_pixelformat_string(ds.pixel_format));
    _sgimgui_igtext("Compare:       %s", _sgimgui_comparefunc_string(ds.compare));
    _sgimgui_igtext("Write Enabled: %s", _sgimgui_bool_string(ds.write_enabled));
    _sgimgui_igtext("Bias:          %f", ds.bias);
    _sgimgui_igtext("Bias Slope:    %f", ds.bias_slope_scale);
    _sgimgui_igtext("Bias Clamp:    %f", ds.bias_clamp);
}

void _sgimgui_draw_blend_state(sg_blend_state* bs) {
    _sgimgui_igtext("Blend Enabled:    %s", _sgimgui_bool_string(bs.enabled));
    _sgimgui_igtext("Src Factor RGB:   %s", _sgimgui_blendfactor_string(bs.src_factor_rgb));
    _sgimgui_igtext("Dst Factor RGB:   %s", _sgimgui_blendfactor_string(bs.dst_factor_rgb));
    _sgimgui_igtext("Op RGB:           %s", _sgimgui_blendop_string(bs.op_rgb));
    _sgimgui_igtext("Src Factor Alpha: %s", _sgimgui_blendfactor_string(bs.src_factor_alpha));
    _sgimgui_igtext("Dst Factor Alpha: %s", _sgimgui_blendfactor_string(bs.dst_factor_alpha));
    _sgimgui_igtext("Op Alpha:         %s", _sgimgui_blendop_string(bs.op_alpha));
}

void _sgimgui_draw_color_target_state(sg_color_target_state* cs) {
    _sgimgui_igtext("Pixel Format:     %s", _sgimgui_pixelformat_string(cs.pixel_format));
    _sgimgui_igtext("Write Mask:       %s", _sgimgui_colormask_string(cs.write_mask));
    if _sgimgui_igtreenode("Blend State:") != 0 {
        _sgimgui_draw_blend_state(&cs.blend);
        _sgimgui_igtreepop();
    }
}

void _sgimgui_draw_pipeline_panel(_sgimgui_t* ctx, sg_pipeline pip) {
    if pip.id != cast(u32, SG_INVALID_ID) {
        _sgimgui_igbeginchild("pipeline", ImVec2{0.0f, 0.0f}, ImGuiChildFlags_None, ImGuiWindowFlags_None);
        sg_pipeline_info info = sg_query_pipeline_info(pip);
        if info.slot.state == SG_RESOURCESTATE_VALID {
            _sgimgui_pipeline_t* pip_ui = &ctx.pipeline_window.slots[_sgimgui_slot_index(pip.id)];
            _sgimgui_igtext("Label: %s", pip_ui.label.buf[0] != 0 ? pip_ui.label.buf : "---");
            _sgimgui_draw_resource_slot(&info.slot);
            _sgimgui_igseparator();
            _sgimgui_igtext("Compute: %s", _sgimgui_bool_string(pip_ui.desc.compute));
            _sgimgui_igtext("Shader: ");
            _sgimgui_igsameline();
            if _sgimgui_draw_shader_link(ctx, pip_ui.desc.shader) != 0 {
                _sgimgui_show_shader(ctx, pip_ui.desc.shader);
            }
            if pip_ui.desc.compute == 0 {
                if _sgimgui_igtreenode("Vertex Layout State") != 0 {
                    _sgimgui_draw_vertex_layout_state(&pip_ui.desc.layout);
                    _sgimgui_igtreepop();
                }
                if _sgimgui_igtreenode("Depth State") != 0 {
                    _sgimgui_draw_depth_state(&pip_ui.desc.depth);
                    _sgimgui_igtreepop();
                }
                if _sgimgui_igtreenode("Stencil State") != 0 {
                    _sgimgui_draw_stencil_state(&pip_ui.desc.stencil);
                    _sgimgui_igtreepop();
                }
                _sgimgui_igtext("Color Count: %d", pip_ui.desc.color_count);
                for i32 i = 0; i < pip_ui.desc.color_count; i++ {
                    noinit _sgimgui_str_t str_var;  // renamed from: str
                    _sgimgui_snprintf(&str_var, "Color Target %d", i);
                    if _sgimgui_igtreenode(str_var.buf) != 0 {
                        _sgimgui_draw_color_target_state(&pip_ui.desc.colors[i]);
                        _sgimgui_igtreepop();
                    }
                }
                _sgimgui_igtext("Prim Type:      %s", _sgimgui_primitivetype_string(pip_ui.desc.primitive_type));
                _sgimgui_igtext("Index Type:     %s", _sgimgui_indextype_string(pip_ui.desc.index_type));
                _sgimgui_igtext("Cull Mode:      %s", _sgimgui_cullmode_string(pip_ui.desc.cull_mode));
                _sgimgui_igtext("Face Winding:   %s", _sgimgui_facewinding_string(pip_ui.desc.face_winding));
                _sgimgui_igtext("Sample Count:   %d", pip_ui.desc.sample_count);
                noinit _sgimgui_str_t blend_color_str;
                _sgimgui_igtext("Blend Color:    %s", _sgimgui_color_string(&blend_color_str, pip_ui.desc.blend_color));
                _sgimgui_igtext("Alpha To Coverage: %s", _sgimgui_bool_string(pip_ui.desc.alpha_to_coverage_enabled));
            }
        } else {
            _sgimgui_igtext("Pipeline 0x%08X not valid.", pip.id);
        }
        _sgimgui_igendchild();
    }
}

void _sgimgui_draw_buffer_view(_sgimgui_t* ctx, u8* title, sg_buffer_view_desc* desc) {
    _sgimgui_igtext("%s: ", title);
    _sgimgui_igtext("  Buffer: ");
    _sgimgui_igsameline();
    if _sgimgui_draw_buffer_link(ctx, desc.buffer) != 0 {
        _sgimgui_show_buffer(ctx, desc.buffer);
    }
    _sgimgui_igtext("  Offset: %d", desc.offset);
}

void _sgimgui_draw_image_view(_sgimgui_t* ctx, u8* title, sg_view view, sg_image_view_desc* desc) {
    _sgimgui_igtext("%s: ", title);
    _sgimgui_igtext("  Image: ");
    _sgimgui_igsameline();
    if _sgimgui_draw_image_link(ctx, desc.image) != 0 {
        _sgimgui_show_image(ctx, desc.image);
    }
    _sgimgui_igtext("  Mip Level: %d", desc.mip_level);
    _sgimgui_igtext("  Slice: %d", desc.slice);
    _sgimgui_igseparator();
    _sgimgui_view_t* view_ui = &ctx.view_window.slots[_sgimgui_slot_index(view.id)];
    _sgimgui_draw_image(ctx, desc.image, &view_ui.ui_scale, 4096.0f);
}

void _sgimgui_draw_texture_view(_sgimgui_t* ctx, u8* title, sg_view view, sg_texture_view_desc* desc) {
    _sgimgui_igtext("%s: ", title);
    _sgimgui_igtext("  Image: ");
    _sgimgui_igsameline();
    if _sgimgui_draw_image_link(ctx, desc.image) != 0 {
        _sgimgui_show_image(ctx, desc.image);
    }
    _sgimgui_igtext("  Mip Levels Base:  %d", desc.mip_levels.base);
    _sgimgui_igtext("  Mip Levels Count: %d", desc.mip_levels.count);
    _sgimgui_igtext("  Slices Base: %d", desc.slices.base);
    _sgimgui_igtext("  Slices Count: %d", desc.slices.count);
    _sgimgui_igseparator();
    _sgimgui_view_t* view_ui = &ctx.view_window.slots[_sgimgui_slot_index(view.id)];
    _sgimgui_draw_image(ctx, desc.image, &view_ui.ui_scale, 4096.0f);
}

void _sgimgui_draw_view_panel(_sgimgui_t* ctx, sg_view view) {
    if view.id != cast(u32, SG_INVALID_ID) {
        _sgimgui_igbeginchild("view", ImVec2{0.0f, 0.0f}, ImGuiChildFlags_None, ImGuiWindowFlags_None);
        sg_view_info info = sg_query_view_info(view);
        if info.slot.state == SG_RESOURCESTATE_VALID {
            _sgimgui_view_t* view_ui = &ctx.view_window.slots[_sgimgui_slot_index(view.id)];
            _sgimgui_igtext("Label: %s", view_ui.label.buf[0] != 0 ? view_ui.label.buf : "---");
            _sgimgui_draw_resource_slot(&info.slot);
            _sgimgui_igseparator();
            sg_view_desc desc = sg_query_view_desc(view);
            sg_view_type type = sg_query_view_type(view);
            switch type {
                case SG_VIEWTYPE_STORAGEBUFFER: {
                    _sgimgui_draw_buffer_view(ctx, "Storage Buffer", &desc.storage_buffer);
                }
                case SG_VIEWTYPE_STORAGEIMAGE: {
                    _sgimgui_draw_image_view(ctx, "Storage Image", view, &desc.storage_image);
                }
                case SG_VIEWTYPE_TEXTURE: {
                    _sgimgui_draw_texture_view(ctx, "Texture", view, &desc.texture);
                }
                case SG_VIEWTYPE_COLORATTACHMENT: {
                    _sgimgui_draw_image_view(ctx, "Color Attachment", view, &desc.color_attachment);
                }
                case SG_VIEWTYPE_RESOLVEATTACHMENT: {
                    _sgimgui_draw_image_view(ctx, "Resolve Attachment", view, &desc.resolve_attachment);
                }
                case SG_VIEWTYPE_DEPTHSTENCILATTACHMENT: {
                    _sgimgui_draw_image_view(ctx, "Depth Stencil Attachment", view, &desc.depth_stencil_attachment);
                }
                default: {
                }
            }
        } else {
            _sgimgui_igtext("View 0x%08X not valid.", view.id);
        }
        _sgimgui_igendchild();
    }
}

void _sgimgui_draw_bindings_panel(_sgimgui_t* ctx, sg_bindings* bnd) {
    _sgimgui_igpushid("bnd_vbufs");
    for i32 i = 0; i < SG_MAX_VERTEXBUFFER_BINDSLOTS; i++ {
        sg_buffer buf = bnd.vertex_buffers[i];
        if buf.id != cast(u32, SG_INVALID_ID) {
            _sgimgui_igtext("Vertex Buffer #%d:", i);
            _sgimgui_igsameline();
            if _sgimgui_draw_buffer_link(ctx, buf) != 0 {
                _sgimgui_show_buffer(ctx, buf);
            }
            _sgimgui_igsameline();
            _sgimgui_igtext("offset: %d", bnd.vertex_buffer_offsets[i]);
        }
    }
    _sgimgui_igpopid();
    _sgimgui_igpushid("bnd_ibuf");
    if bnd.index_buffer.id != cast(u32, SG_INVALID_ID) {
        sg_buffer buf = bnd.index_buffer;
        if buf.id != cast(u32, SG_INVALID_ID) {
            _sgimgui_igtext("Index Buffer:");
            _sgimgui_igsameline();
            if _sgimgui_draw_buffer_link(ctx, buf) != 0 {
                _sgimgui_show_buffer(ctx, buf);
            }
            _sgimgui_igsameline();
            _sgimgui_igtext("offset: %d", bnd.index_buffer_offset);
        }
    }
    _sgimgui_igpopid();
    _sgimgui_igpushid("bnd_views");
    for i32 i = 0; i < SG_MAX_VIEW_BINDSLOTS; i++ {
        sg_view view = bnd.views[i];
        if view.id != cast(u32, SG_INVALID_ID) {
            _sgimgui_igtext("View #%d:", i);
            _sgimgui_igsameline();
            if _sgimgui_draw_view_link(ctx, view) != 0 {
                _sgimgui_show_view(ctx, view);
            }
        }
    }
    _sgimgui_igpopid();
    _sgimgui_igpushid("bnd_smps");
    for i32 i = 0; i < SG_MAX_SAMPLER_BINDSLOTS; i++ {
        sg_sampler smp = bnd.samplers[i];
        if smp.id != cast(u32, SG_INVALID_ID) {
            _sgimgui_igtext("Sampler Slot #%d:", i);
            _sgimgui_igsameline();
            if _sgimgui_draw_sampler_link(ctx, smp) != 0 {
                _sgimgui_show_sampler(ctx, smp);
            }
        }
    }
    _sgimgui_igpopid();
}

void _sgimgui_draw_uniforms_panel(_sgimgui_t* ctx, _sgimgui_args_apply_uniforms_t* args) {
    if sg_query_pipeline_state(args.pipeline) != SG_RESOURCESTATE_VALID {
        _sgimgui_igtext("Pipeline object not valid!");
        return;
    }
    _sgimgui_pipeline_t* pip_ui = &ctx.pipeline_window.slots[_sgimgui_slot_index(args.pipeline.id)];
    if sg_query_shader_state(pip_ui.desc.shader) != SG_RESOURCESTATE_VALID {
        _sgimgui_igtext("Shader object not valid!");
        return;
    }
    _sgimgui_shader_t* shd_ui = &ctx.shader_window.slots[_sgimgui_slot_index(pip_ui.desc.shader.id)];
    sg_shader_uniform_block* ub_desc = &shd_ui.desc.uniform_blocks[args.ub_slot];
    bool draw_dump = false;
    if ub_desc.glsl_uniforms[0].type == SG_UNIFORMTYPE_INVALID {
        draw_dump = true;
    }
    _sgimgui_capture_bucket_t* bucket = _sgimgui_capture_get_read_bucket(ctx);
    var uptrf = cast(f32*, bucket.ubuf + args.ubuf_pos);
    var uptri32 = cast(i32*, uptrf);
    if draw_dump == 0 {
        u32 u_off = 0;
        for i32 i = 0; i < SG_MAX_UNIFORMBLOCK_MEMBERS; i++ {
            sg_glsl_shader_uniform* ud = &ub_desc.glsl_uniforms[i];
            if ud.type == SG_UNIFORMTYPE_INVALID {
                break;
            }
            var num_items = cast(i32, ud.array_count > 1 ? ud.array_count : 1);
            if num_items > 1 {
                _sgimgui_igtext("%d: %s %s[%d] =", i, _sgimgui_uniformtype_string(ud.type), ud.glsl_name != null ? ud.glsl_name : "", ud.array_count);
            } else {
                _sgimgui_igtext("%d: %s %s =", i, _sgimgui_uniformtype_string(ud.type), ud.glsl_name != null ? ud.glsl_name : "");
            }
            for i32 item_index = 0; item_index < num_items; item_index++ {
                u32 u_size = _sgimgui_std140_uniform_size(ud.type, cast(i32, ud.array_count)) / 4;
                u32 u_align = _sgimgui_std140_uniform_alignment(ud.type, cast(i32, ud.array_count)) / 4;
                u_off = _sgimgui_align_u32(u_off, u_align);
                switch ud.type {
                    case SG_UNIFORMTYPE_FLOAT: {
                        _sgimgui_igtext("    %.3f", uptrf[u_off]);
                    }
                    case SG_UNIFORMTYPE_INT: {
                        _sgimgui_igtext("    %d", uptri32[u_off]);
                    }
                    case SG_UNIFORMTYPE_FLOAT2: {
                        _sgimgui_igtext("    %.3f, %.3f", uptrf[u_off], uptrf[u_off + 1]);
                    }
                    case SG_UNIFORMTYPE_INT2: {
                        _sgimgui_igtext("    %d, %d", uptri32[u_off], uptri32[u_off + 1]);
                    }
                    case SG_UNIFORMTYPE_FLOAT3: {
                        _sgimgui_igtext("    %.3f, %.3f, %.3f", uptrf[u_off], uptrf[u_off + 1], uptrf[u_off + 2]);
                    }
                    case SG_UNIFORMTYPE_INT3: {
                        _sgimgui_igtext("    %d, %d, %d", uptri32[u_off], uptri32[u_off + 1], uptri32[u_off + 2]);
                    }
                    case SG_UNIFORMTYPE_FLOAT4: {
                        _sgimgui_igtext("    %.3f, %.3f, %.3f, %.3f", uptrf[u_off], uptrf[u_off + 1], uptrf[u_off + 2], uptrf[u_off + 3]);
                    }
                    case SG_UNIFORMTYPE_INT4: {
                        _sgimgui_igtext("    %d, %d, %d, %d", uptri32[u_off], uptri32[u_off + 1], uptri32[u_off + 2], uptri32[u_off + 3]);
                    }
                    case SG_UNIFORMTYPE_MAT4: {
                        _sgimgui_igtext("    %.3f, %.3f, %.3f, %.3f\n    %.3f, %.3f, %.3f, %.3f\n    %.3f, %.3f, %.3f, %.3f\n    %.3f, %.3f, %.3f, %.3f", uptrf[u_off + 0], uptrf[u_off + 1], uptrf[u_off + 2], uptrf[u_off + 3], uptrf[u_off + 4], uptrf[u_off + 5], uptrf[u_off + 6], uptrf[u_off + 7], uptrf[u_off + 8], uptrf[u_off + 9], uptrf[u_off + 10], uptrf[u_off + 11], uptrf[u_off + 12], uptrf[u_off + 13], uptrf[u_off + 14], uptrf[u_off + 15]);
                    }
                    default: {
                        _sgimgui_igtext("???");
                    }
                }
                u_off += u_size;
            }
        }
    } else {
        var num_floats = cast(u64, ub_desc.size / sizeof(f32));
        for u32 i = 0; i < num_floats; i++ {
            _sgimgui_igtext("%.3f, ", uptrf[i]);
            if (i + 1) % 4 != 0 {
                _sgimgui_igsameline();
            }
        }
    }
}

void _sgimgui_draw_passaction_panel(sg_pass_action* action, i32 num_color_atts) {
    _sgimgui_igtext("Pass Action:");
    for i32 i = 0; i < num_color_atts; i++ {
        sg_color_attachment_action* c_att = &action.colors[i];
        _sgimgui_igtext("  Color Attachment %d:", i);
        noinit _sgimgui_str_t color_str;
        switch c_att.load_action {
            case SG_LOADACTION_LOAD: {
                _sgimgui_igtext("    load action: LOAD");
            }
            case SG_LOADACTION_DONTCARE: {
                _sgimgui_igtext("    load action: DONTCARE");
            }
            case SG_LOADACTION_CLEAR: {
                _sgimgui_igtext("    load action: CLEAR %s", _sgimgui_color_string(&color_str, c_att.clear_value));
            }
            default: {
                _sgimgui_igtext("    ???");
            }
        }
        switch c_att.store_action {
            case SG_STOREACTION_STORE: {
                _sgimgui_igtext("    store action: STORE");
            }
            case SG_STOREACTION_DONTCARE: {
                _sgimgui_igtext("    store action: DONTCARE");
            }
            default: {
                _sgimgui_igtext("    ???");
            }
        }
    }
    sg_depth_attachment_action* d_att = &action.depth;
    _sgimgui_igtext("  Depth Attachment:");
    switch d_att.load_action {
        case SG_LOADACTION_LOAD: {
            _sgimgui_igtext("    load action: LOAD");
        }
        case SG_LOADACTION_DONTCARE: {
            _sgimgui_igtext("    load action: DONTCARE");
        }
        case SG_LOADACTION_CLEAR: {
            _sgimgui_igtext("    load action: CLEAR %.3f", d_att.clear_value);
        }
        default: {
            _sgimgui_igtext("    ???");
        }
    }
    switch d_att.store_action {
        case SG_STOREACTION_STORE: {
            _sgimgui_igtext("    store action: STORE");
        }
        case SG_STOREACTION_DONTCARE: {
            _sgimgui_igtext("    store action: DONTCARE");
        }
        default: {
            _sgimgui_igtext("    ???");
        }
    }
    sg_stencil_attachment_action* s_att = &action.stencil;
    _sgimgui_igtext("  Stencil Attachment");
    switch s_att.load_action {
        case SG_LOADACTION_LOAD: {
            _sgimgui_igtext("    load action: LOAD");
        }
        case SG_LOADACTION_DONTCARE: {
            _sgimgui_igtext("    load action: DONTCARE");
        }
        case SG_LOADACTION_CLEAR: {
            _sgimgui_igtext("    load action: CLEAR 0x%02X", s_att.clear_value);
        }
        default: {
            _sgimgui_igtext("    ???");
        }
    }
    switch s_att.store_action {
        case SG_STOREACTION_STORE: {
            _sgimgui_igtext("    store action: STORE");
        }
        case SG_STOREACTION_DONTCARE: {
            _sgimgui_igtext("    store action: DONTCARE");
        }
        default: {
            _sgimgui_igtext("    ???");
        }
    }
}

void _sgimgui_draw_attachments_panel(_sgimgui_t* ctx, sg_attachments* atts, i32 num_color_atts) {
    _sgimgui_igtext("Attachments:");
    for i32 i = 0; i < num_color_atts; i++ {
        if atts.colors[i].id != cast(u32, SG_INVALID_ID) {
            sg_view view = atts.colors[i];
            _sgimgui_igtext("  Color Attachment #%d:", i);
            _sgimgui_igsameline();
            if _sgimgui_draw_view_link(ctx, view) != 0 {
                _sgimgui_show_view(ctx, view);
            }
        }
    }
    for i32 i = 0; i < num_color_atts; i++ {
        if atts.resolves[i].id != cast(u32, SG_INVALID_ID) {
            sg_view view = atts.resolves[i];
            _sgimgui_igtext("  Resolve Attachment #%d:", i);
            _sgimgui_igsameline();
            if _sgimgui_draw_view_link(ctx, view) != 0 {
                _sgimgui_show_view(ctx, view);
            }
        }
    }
    if atts.depth_stencil.id != cast(u32, SG_INVALID_ID) {
        sg_view view = atts.depth_stencil;
        _sgimgui_igtext("  Depth Stencil Attachment:");
        _sgimgui_igsameline();
        if _sgimgui_draw_view_link(ctx, view) != 0 {
            _sgimgui_show_view(ctx, view);
        }
    }
}

void _sgimgui_draw_swapchain_panel(sg_swapchain* swapchain) {
    _sgimgui_igtext("Swapchain:");
    _sgimgui_igtext("  Width: %d", swapchain.width);
    _sgimgui_igtext("  Height: %d", swapchain.height);
    _sgimgui_igtext("  Sample Count: %d", swapchain.sample_count);
    _sgimgui_igtext("  Color Format: %s", _sgimgui_pixelformat_string(swapchain.color_format));
    _sgimgui_igtext("  Depth Format: %s", _sgimgui_pixelformat_string(swapchain.depth_format));
    _sgimgui_igseparator();
    switch sg_query_backend() {
        case SG_BACKEND_D3D11: {
            _sgimgui_igtext("D3D11 Objects:");
            _sgimgui_igtext("  Render View: %p", swapchain.d3d11.render_view);
            _sgimgui_igtext("  Resolve View: %p", swapchain.d3d11.resolve_view);
            _sgimgui_igtext("  Depth Stencil View: %p", swapchain.d3d11.depth_stencil_view);
        }
        case SG_BACKEND_WGPU: {
            _sgimgui_igtext("WGPU Objects:");
            _sgimgui_igtext("  Render View: %p", swapchain.wgpu.render_view);
            _sgimgui_igtext("  Resolve View: %p", swapchain.wgpu.resolve_view);
            _sgimgui_igtext("  Depth Stencil View: %p", swapchain.wgpu.depth_stencil_view);
        }
        case SG_BACKEND_METAL_MACOS, SG_BACKEND_METAL_IOS, SG_BACKEND_METAL_SIMULATOR: {
            _sgimgui_igtext("Metal Objects:");
            _sgimgui_igtext("  Current Drawable: %p", swapchain.metal.current_drawable);
            _sgimgui_igtext("  Depth Stencil Texture: %p", swapchain.metal.depth_stencil_texture);
            _sgimgui_igtext("  MSAA Color Texture: %p", swapchain.metal.msaa_color_texture);
        }
        case SG_BACKEND_GLCORE, SG_BACKEND_GLES3: {
            _sgimgui_igtext("GL Objects:");
            _sgimgui_igtext("  Framebuffer: %d", swapchain.gl.framebuffer);
        }
        case SG_BACKEND_VULKAN: {
            _sgimgui_igtext("Vulkan Objects:");
            _sgimgui_igtext("  Render Image: %p", swapchain.vulkan.render_image);
            _sgimgui_igtext("  Render View: %p", swapchain.vulkan.render_view);
            _sgimgui_igtext("  Resolve Image: %p", swapchain.vulkan.resolve_image);
            _sgimgui_igtext("  Resolve View: %p", swapchain.vulkan.resolve_view);
            _sgimgui_igtext("  Depth Stencil Image: %p", swapchain.vulkan.depth_stencil_image);
            _sgimgui_igtext("  Depth Stencil View: %p", swapchain.vulkan.depth_stencil_view);
            _sgimgui_igtext("  Render Finished Semaphore: %p", swapchain.vulkan.render_finished_semaphore);
            _sgimgui_igtext("  Present Complete Semaphore: %p", swapchain.vulkan.present_complete_semaphore);
        }
        default: {
            _sgimgui_igtext("  UNKNOWN BACKEND!");
        }
    }
}

void _sgimgui_draw_pass_panel(_sgimgui_t* ctx, sg_pass* pass) {
    bool is_compute_pass = pass.compute;
    bool is_attachments_pass = false;
    bool is_swapchain_pass = false;
    i32 num_color_atts = 0;
    if is_compute_pass == 0 {
        for i32 i = 0; i < SG_MAX_COLOR_ATTACHMENTS; i++ {
            if pass.attachments.colors[i].id != cast(u32, SG_INVALID_ID) {
                num_color_atts++;
                is_attachments_pass = true;
            }
        }
        if pass.attachments.depth_stencil.id != cast(u32, SG_INVALID_ID) {
            is_attachments_pass = true;
        }
        if is_attachments_pass == 0 {
            num_color_atts = 1;
            is_swapchain_pass = true;
        }
    }
    _sgimgui_igtext("Compute: %s", _sgimgui_bool_string(is_compute_pass));
    _sgimgui_igseparator();
    if is_compute_pass == 0 {
        _sgimgui_draw_passaction_panel(&pass.action, num_color_atts);
        _sgimgui_igseparator();
        if is_attachments_pass != 0 {
            _sgimgui_draw_attachments_panel(ctx, &pass.attachments, num_color_atts);
        } else if is_swapchain_pass != 0 {
            _sgimgui_draw_swapchain_panel(&pass.swapchain);
        }
    }
}

void _sgimgui_draw_capture_panel(_sgimgui_t* ctx) {
    i32 sel_item_index = ctx.capture_window.sel_item;
    if sel_item_index >= _sgimgui_capture_num_read_items(ctx) {
        return;
    }
    _sgimgui_capture_item_t* item = _sgimgui_capture_read_item_at(ctx, sel_item_index);
    _sgimgui_igbeginchild("capture_item", ImVec2{0.0f, 0.0f}, ImGuiChildFlags_None, ImGuiWindowFlags_None);
    _sgimgui_igpushstylecolor(ImGuiCol_Text, item.color);
    _sgimgui_igtext("%s", _sgimgui_capture_item_string(ctx, sel_item_index, item).buf);
    _sgimgui_igpopstylecolor();
    _sgimgui_igseparator();
    switch item.cmd {
        case _SGIMGUI_CMD_RESET_STATE_CACHE: {
        }
        case _SGIMGUI_CMD_MAKE_BUFFER: {
            _sgimgui_draw_buffer_panel(ctx, item.args.make_buffer.result);
        }
        case _SGIMGUI_CMD_MAKE_IMAGE: {
            _sgimgui_draw_image_panel(ctx, item.args.make_image.result);
        }
        case _SGIMGUI_CMD_MAKE_SAMPLER: {
            _sgimgui_draw_sampler_panel(ctx, item.args.make_sampler.result);
        }
        case _SGIMGUI_CMD_MAKE_SHADER: {
            _sgimgui_draw_shader_panel(ctx, item.args.make_shader.result);
        }
        case _SGIMGUI_CMD_MAKE_PIPELINE: {
            _sgimgui_draw_pipeline_panel(ctx, item.args.make_pipeline.result);
        }
        case _SGIMGUI_CMD_MAKE_VIEW: {
            _sgimgui_draw_view_panel(ctx, item.args.make_view.result);
        }
        case _SGIMGUI_CMD_DESTROY_BUFFER: {
            _sgimgui_draw_buffer_panel(ctx, item.args.destroy_buffer.buffer);
        }
        case _SGIMGUI_CMD_DESTROY_IMAGE: {
            _sgimgui_draw_image_panel(ctx, item.args.destroy_image.image);
        }
        case _SGIMGUI_CMD_DESTROY_SAMPLER: {
            _sgimgui_draw_sampler_panel(ctx, item.args.destroy_sampler.sampler);
        }
        case _SGIMGUI_CMD_DESTROY_SHADER: {
            _sgimgui_draw_shader_panel(ctx, item.args.destroy_shader.shader);
        }
        case _SGIMGUI_CMD_DESTROY_PIPELINE: {
            _sgimgui_draw_pipeline_panel(ctx, item.args.destroy_pipeline.pipeline);
        }
        case _SGIMGUI_CMD_DESTROY_VIEW: {
            _sgimgui_draw_view_panel(ctx, item.args.destroy_view.view);
        }
        case _SGIMGUI_CMD_UPDATE_BUFFER: {
            _sgimgui_draw_buffer_panel(ctx, item.args.update_buffer.buffer);
        }
        case _SGIMGUI_CMD_UPDATE_IMAGE: {
            _sgimgui_draw_image_panel(ctx, item.args.update_image.image);
        }
        case _SGIMGUI_CMD_APPEND_BUFFER: {
            _sgimgui_draw_buffer_panel(ctx, item.args.append_buffer.buffer);
        }
        case _SGIMGUI_CMD_WRITE_BUFFER_UNSEALED: {
            _sgimgui_draw_buffer_panel(ctx, item.args.write_buffer_unsealed.dst.buffer);
        }
        case _SGIMGUI_CMD_WRITE_IMAGE_UNSEALED: {
            _sgimgui_draw_image_panel(ctx, item.args.write_image_unsealed.dst.image);
        }
        case _SGIMGUI_CMD_SEAL_BUFFER: {
            _sgimgui_draw_buffer_panel(ctx, item.args.seal_buffer.buffer);
        }
        case _SGIMGUI_CMD_SEAL_IMAGE: {
            _sgimgui_draw_image_panel(ctx, item.args.seal_image.image);
        }
        case _SGIMGUI_CMD_BEGIN_PASS: {
            _sgimgui_draw_pass_panel(ctx, &item.args.begin_pass.pass);
        }
        case _SGIMGUI_CMD_APPLY_VIEWPORT, _SGIMGUI_CMD_APPLY_SCISSOR_RECT: {
        }
        case _SGIMGUI_CMD_APPLY_PIPELINE: {
            _sgimgui_draw_pipeline_panel(ctx, item.args.apply_pipeline.pipeline);
        }
        case _SGIMGUI_CMD_APPLY_BINDINGS: {
            _sgimgui_draw_bindings_panel(ctx, &item.args.apply_bindings.bindings);
        }
        case _SGIMGUI_CMD_APPLY_UNIFORMS: {
            _sgimgui_draw_uniforms_panel(ctx, &item.args.apply_uniforms);
        }
        case _SGIMGUI_CMD_DRAW, _SGIMGUI_CMD_DRAW_EX, _SGIMGUI_CMD_DISPATCH, _SGIMGUI_CMD_END_PASS, _SGIMGUI_CMD_COMMIT: {
        }
        case _SGIMGUI_CMD_ALLOC_BUFFER: {
            _sgimgui_draw_buffer_panel(ctx, item.args.alloc_buffer.result);
        }
        case _SGIMGUI_CMD_ALLOC_IMAGE: {
            _sgimgui_draw_image_panel(ctx, item.args.alloc_image.result);
        }
        case _SGIMGUI_CMD_ALLOC_SAMPLER: {
            _sgimgui_draw_sampler_panel(ctx, item.args.alloc_sampler.result);
        }
        case _SGIMGUI_CMD_ALLOC_SHADER: {
            _sgimgui_draw_shader_panel(ctx, item.args.alloc_shader.result);
        }
        case _SGIMGUI_CMD_ALLOC_PIPELINE: {
            _sgimgui_draw_pipeline_panel(ctx, item.args.alloc_pipeline.result);
        }
        case _SGIMGUI_CMD_ALLOC_VIEW: {
            _sgimgui_draw_view_panel(ctx, item.args.alloc_view.result);
        }
        case _SGIMGUI_CMD_DEALLOC_BUFFER: {
            _sgimgui_draw_buffer_panel(ctx, item.args.dealloc_buffer.buffer);
        }
        case _SGIMGUI_CMD_DEALLOC_IMAGE: {
            _sgimgui_draw_image_panel(ctx, item.args.dealloc_image.image);
        }
        case _SGIMGUI_CMD_DEALLOC_SAMPLER: {
            _sgimgui_draw_sampler_panel(ctx, item.args.dealloc_sampler.sampler);
        }
        case _SGIMGUI_CMD_DEALLOC_SHADER: {
            _sgimgui_draw_shader_panel(ctx, item.args.dealloc_shader.shader);
        }
        case _SGIMGUI_CMD_DEALLOC_PIPELINE: {
            _sgimgui_draw_pipeline_panel(ctx, item.args.dealloc_pipeline.pipeline);
        }
        case _SGIMGUI_CMD_DEALLOC_VIEW: {
            _sgimgui_draw_view_panel(ctx, item.args.dealloc_view.view);
        }
        case _SGIMGUI_CMD_INIT_BUFFER: {
            _sgimgui_draw_buffer_panel(ctx, item.args.init_buffer.buffer);
        }
        case _SGIMGUI_CMD_INIT_IMAGE: {
            _sgimgui_draw_image_panel(ctx, item.args.init_image.image);
        }
        case _SGIMGUI_CMD_INIT_SAMPLER: {
            _sgimgui_draw_sampler_panel(ctx, item.args.init_sampler.sampler);
        }
        case _SGIMGUI_CMD_INIT_SHADER: {
            _sgimgui_draw_shader_panel(ctx, item.args.init_shader.shader);
        }
        case _SGIMGUI_CMD_INIT_PIPELINE: {
            _sgimgui_draw_pipeline_panel(ctx, item.args.init_pipeline.pipeline);
        }
        case _SGIMGUI_CMD_INIT_VIEW: {
            _sgimgui_draw_view_panel(ctx, item.args.init_view.view);
        }
        case _SGIMGUI_CMD_UNINIT_BUFFER: {
            _sgimgui_draw_buffer_panel(ctx, item.args.uninit_buffer.buffer);
        }
        case _SGIMGUI_CMD_UNINIT_IMAGE: {
            _sgimgui_draw_image_panel(ctx, item.args.uninit_image.image);
        }
        case _SGIMGUI_CMD_UNINIT_SAMPLER: {
            _sgimgui_draw_sampler_panel(ctx, item.args.uninit_sampler.sampler);
        }
        case _SGIMGUI_CMD_UNINIT_SHADER: {
            _sgimgui_draw_shader_panel(ctx, item.args.uninit_shader.shader);
        }
        case _SGIMGUI_CMD_UNINIT_PIPELINE: {
            _sgimgui_draw_pipeline_panel(ctx, item.args.uninit_pipeline.pipeline);
        }
        case _SGIMGUI_CMD_UNINIT_VIEW: {
            _sgimgui_draw_view_panel(ctx, item.args.uninit_view.view);
        }
        case _SGIMGUI_CMD_FAIL_BUFFER: {
            _sgimgui_draw_buffer_panel(ctx, item.args.fail_buffer.buffer);
        }
        case _SGIMGUI_CMD_FAIL_IMAGE: {
            _sgimgui_draw_image_panel(ctx, item.args.fail_image.image);
        }
        case _SGIMGUI_CMD_FAIL_SAMPLER: {
            _sgimgui_draw_sampler_panel(ctx, item.args.fail_sampler.sampler);
        }
        case _SGIMGUI_CMD_FAIL_SHADER: {
            _sgimgui_draw_shader_panel(ctx, item.args.fail_shader.shader);
        }
        case _SGIMGUI_CMD_FAIL_PIPELINE: {
            _sgimgui_draw_pipeline_panel(ctx, item.args.fail_pipeline.pipeline);
        }
        case _SGIMGUI_CMD_FAIL_VIEW: {
            _sgimgui_draw_view_panel(ctx, item.args.fail_view.view);
        }
        default: {
        }
    }
    _sgimgui_igendchild();
}

void _sgimgui_draw_caps_panel() {
    _sgimgui_igtext("Backend: %s\n", _sgimgui_backend_string(sg_query_backend()));
    _sgimgui_igtext("Dear ImGui Version: %s\n\n", "1.92.9b");
    sg_features f = sg_query_features();
    _sgimgui_igtext("Features:");
    _sgimgui_igtext("    origin_top_left: %s", _sgimgui_bool_string(f.origin_top_left));
    _sgimgui_igtext("    image_clamp_to_border: %s", _sgimgui_bool_string(f.image_clamp_to_border));
    _sgimgui_igtext("    mrt_independent_blend_state: %s", _sgimgui_bool_string(f.mrt_independent_blend_state));
    _sgimgui_igtext("    mrt_independent_write_mask: %s", _sgimgui_bool_string(f.mrt_independent_write_mask));
    _sgimgui_igtext("    compute: %s", _sgimgui_bool_string(f.compute));
    _sgimgui_igtext("    msaa_texture_bindings: %s", _sgimgui_bool_string(f.msaa_texture_bindings));
    _sgimgui_igtext("    separate_buffer_types: %s", _sgimgui_bool_string(f.separate_buffer_types));
    _sgimgui_igtext("    draw_base_vertex: %s", _sgimgui_bool_string(f.draw_base_vertex));
    _sgimgui_igtext("    draw_base_instance: %s", _sgimgui_bool_string(f.draw_base_instance));
    _sgimgui_igtext("    dual_source_blending: %s", _sgimgui_bool_string(f.dual_source_blending));
    _sgimgui_igtext("    vertexformat_int10_n2: %s", _sgimgui_bool_string(f.vertexformat_int10_n2));
    _sgimgui_igtext("    gl_texture_views: %s", _sgimgui_bool_string(f.gl_texture_views));
    sg_limits l = sg_query_limits();
    _sgimgui_igtext("\nLimits:\n");
    _sgimgui_igtext("    max_image_size_2d: %d", l.max_image_size_2d);
    _sgimgui_igtext("    max_image_size_cube: %d", l.max_image_size_cube);
    _sgimgui_igtext("    max_image_size_3d: %d", l.max_image_size_3d);
    _sgimgui_igtext("    max_image_size_array: %d", l.max_image_size_array);
    _sgimgui_igtext("    max_image_array_layers: %d", l.max_image_array_layers);
    _sgimgui_igtext("    max_vertex_attrs: %d", l.max_vertex_attrs);
    _sgimgui_igtext("    max_color_attachments: %d", l.max_color_attachments);
    _sgimgui_igtext("    max_texture_bindings_per_stage: %d", l.max_texture_bindings_per_stage);
    _sgimgui_igtext("    max_storage_buffer_bindings_per_stage: %d", l.max_storage_buffer_bindings_per_stage);
    _sgimgui_igtext("    max_storage_image_bindings_per_stage: %d", l.max_storage_image_bindings_per_stage);
    _sgimgui_igtext("    gl_max_vertex_uniform_components: %d", l.gl_max_vertex_uniform_components);
    _sgimgui_igtext("    gl_max_combined_texture_image_units: %d", l.gl_max_combined_texture_image_units);
    _sgimgui_igtext("    d3d11_max_unordered_access_views: %d", l.d3d11_max_unordered_access_views);
    _sgimgui_igtext("    vk_min_uniform_buffer_offset_alignment: %d", l.vk_min_uniform_buffer_offset_alignment);
    _sgimgui_igtext("\nStruct Sizes:\n");
    _sgimgui_igtext("    sg_desc:           %d bytes\n", cast(i32, sizeof(sg_desc)));
    _sgimgui_igtext("    sg_buffer_desc:    %d bytes\n", cast(i32, sizeof(sg_buffer_desc)));
    _sgimgui_igtext("    sg_image_desc:     %d bytes\n", cast(i32, sizeof(sg_image_desc)));
    _sgimgui_igtext("    sg_view_desc:      %d bytes\n", cast(i32, sizeof(sg_view_desc)));
    _sgimgui_igtext("    sg_sampler_desc:   %d bytes\n", cast(i32, sizeof(sg_sampler_desc)));
    _sgimgui_igtext("    sg_shader_desc:    %d bytes\n", cast(i32, sizeof(sg_shader_desc)));
    _sgimgui_igtext("    sg_pipeline_desc:  %d bytes\n", cast(i32, sizeof(sg_pipeline_desc)));
    _sgimgui_igtext("    sg_pass:           %d bytes\n", cast(i32, sizeof(sg_pass)));
    _sgimgui_igtext("    sg_bindings:       %d bytes\n", cast(i32, sizeof(sg_bindings)));
    _sgimgui_igtext("\nUsable Pixelformats:");
    for i32 i = SG_PIXELFORMAT_NONE + 1; i < _SG_PIXELFORMAT_NUM; i++ {
        var fmt = cast(sg_pixel_format, i);
        sg_pixelformat_info info = sg_query_pixelformat(fmt);
        if info.sample != 0 {
            _sgimgui_igtext("  %s: %s%s%s%s%s%s%s%s%s", _sgimgui_pixelformat_string(fmt), info.sample != 0 ? "SAMPLE " : "", info.filter != 0 ? "FILTER " : "", info.blend != 0 ? "BLEND " : "", info.render != 0 ? "RENDER " : "", info.msaa != 0 ? "MSAA " : "", info.depth != 0 ? "DEPTH " : "", info.compressed != 0 ? "COMPRESSED " : "", info.read != 0 ? "READ " : "", info.write != 0 ? "WRITE " : "");
        }
    }
}

void _sgimgui_frame_add_stats_row(u8* key, u32 value) {
    _sgimgui_igtablenextrow();
    _sgimgui_igtablesetcolumnindex(0);
    _sgimgui_igtext("%s", key);
    _sgimgui_igtablesetcolumnindex(1);
    _sgimgui_igtext("%d", value);
}

void _sgimgui_draw_frame_stats_panel(_sgimgui_t* ctx) {
    ignore ctx;
    _sgimgui_igcheckbox("Ignore sokol_imgui.h", &ctx.frame_stats_window.disable_sokol_imgui_stats);
    sg_stats* stats = &ctx.frame_stats_window.stats;
    ImGuiTableFlags flags = ImGuiTableFlags_Resizable | ImGuiTableFlags_ScrollY | ImGuiTableFlags_SizingFixedFit | ImGuiTableFlags_Borders;
    if _sgimgui_igbegintable("#frame_stats_table", 2, flags) != 0 {
        _sgimgui_igtablesetupscrollfreeze(0, 1);
        _sgimgui_igtablesetupcolumn("key", ImGuiTableColumnFlags_None);
        _sgimgui_igtablesetupcolumn("value", ImGuiTableColumnFlags_None);
        _sgimgui_igtableheadersrow();
        _sgimgui_frame_add_stats_row("prev_frame . frame_index", stats.prev_frame.frame_index);
        _sgimgui_frame_add_stats_row("prev_frame . num_passes", stats.prev_frame.num_passes);
        _sgimgui_frame_add_stats_row("prev_frame . num_apply_viewport", stats.prev_frame.num_apply_viewport);
        _sgimgui_frame_add_stats_row("prev_frame . num_apply_scissor_rect", stats.prev_frame.num_apply_scissor_rect);
        _sgimgui_frame_add_stats_row("prev_frame . num_apply_pipeline", stats.prev_frame.num_apply_pipeline);
        _sgimgui_frame_add_stats_row("prev_frame . num_apply_bindings", stats.prev_frame.num_apply_bindings);
        _sgimgui_frame_add_stats_row("prev_frame . num_apply_uniforms", stats.prev_frame.num_apply_uniforms);
        _sgimgui_frame_add_stats_row("prev_frame . num_draw", stats.prev_frame.num_draw);
        _sgimgui_frame_add_stats_row("prev_frame . num_draw_ex", stats.prev_frame.num_draw_ex);
        _sgimgui_frame_add_stats_row("prev_frame . num_dispatch", stats.prev_frame.num_dispatch);
        _sgimgui_frame_add_stats_row("prev_frame . num_update_buffer", stats.prev_frame.num_update_buffer);
        _sgimgui_frame_add_stats_row("prev_frame . num_append_buffer", stats.prev_frame.num_append_buffer);
        _sgimgui_frame_add_stats_row("prev_frame . num_update_image", stats.prev_frame.num_update_image);
        _sgimgui_frame_add_stats_row("prev_frame . size_apply_uniforms", stats.prev_frame.size_apply_uniforms);
        _sgimgui_frame_add_stats_row("prev_frame . size_update_buffer", stats.prev_frame.size_update_buffer);
        _sgimgui_frame_add_stats_row("prev_frame . size_append_buffer", stats.prev_frame.size_append_buffer);
        _sgimgui_frame_add_stats_row("prev_frame . size_update_image", stats.prev_frame.size_update_image);
        _sgimgui_frame_add_stats_row("prev_frame . buffers . allocated", stats.prev_frame.buffers.allocated);
        _sgimgui_frame_add_stats_row("prev_frame . buffers . deallocated", stats.prev_frame.buffers.deallocated);
        _sgimgui_frame_add_stats_row("prev_frame . buffers . inited", stats.prev_frame.buffers.inited);
        _sgimgui_frame_add_stats_row("prev_frame . buffers . uninited", stats.prev_frame.buffers.uninited);
        _sgimgui_frame_add_stats_row("prev_frame . images . allocated", stats.prev_frame.images.allocated);
        _sgimgui_frame_add_stats_row("prev_frame . images . deallocated", stats.prev_frame.images.deallocated);
        _sgimgui_frame_add_stats_row("prev_frame . images . inited", stats.prev_frame.images.inited);
        _sgimgui_frame_add_stats_row("prev_frame . images . uninited", stats.prev_frame.images.uninited);
        _sgimgui_frame_add_stats_row("prev_frame . views . allocated", stats.prev_frame.views.allocated);
        _sgimgui_frame_add_stats_row("prev_frame . views . deallocated", stats.prev_frame.views.deallocated);
        _sgimgui_frame_add_stats_row("prev_frame . views . inited", stats.prev_frame.views.inited);
        _sgimgui_frame_add_stats_row("prev_frame . views . uninited", stats.prev_frame.views.uninited);
        _sgimgui_frame_add_stats_row("prev_frame . shaders . allocated", stats.prev_frame.shaders.allocated);
        _sgimgui_frame_add_stats_row("prev_frame . shaders . deallocated", stats.prev_frame.shaders.deallocated);
        _sgimgui_frame_add_stats_row("prev_frame . shaders . inited", stats.prev_frame.shaders.inited);
        _sgimgui_frame_add_stats_row("prev_frame . shaders . uninited", stats.prev_frame.shaders.uninited);
        _sgimgui_frame_add_stats_row("prev_frame . pipelines . allocated", stats.prev_frame.pipelines.allocated);
        _sgimgui_frame_add_stats_row("prev_frame . pipelines . deallocated", stats.prev_frame.pipelines.deallocated);
        _sgimgui_frame_add_stats_row("prev_frame . pipelines . inited", stats.prev_frame.pipelines.inited);
        _sgimgui_frame_add_stats_row("prev_frame . pipelines . uninited", stats.prev_frame.pipelines.uninited);
        switch sg_query_backend() {
            case SG_BACKEND_GLCORE, SG_BACKEND_GLES3: {
                _sgimgui_frame_add_stats_row("prev_frame . gl . num_bind_buffer", stats.prev_frame.gl.num_bind_buffer);
                _sgimgui_frame_add_stats_row("prev_frame . gl . num_active_texture", stats.prev_frame.gl.num_active_texture);
                _sgimgui_frame_add_stats_row("prev_frame . gl . num_bind_texture", stats.prev_frame.gl.num_bind_texture);
                _sgimgui_frame_add_stats_row("prev_frame . gl . num_bind_image_texture", stats.prev_frame.gl.num_bind_image_texture);
                _sgimgui_frame_add_stats_row("prev_frame . gl . num_bind_sampler", stats.prev_frame.gl.num_bind_sampler);
                _sgimgui_frame_add_stats_row("prev_frame . gl . num_use_program", stats.prev_frame.gl.num_use_program);
                _sgimgui_frame_add_stats_row("prev_frame . gl . num_render_state", stats.prev_frame.gl.num_render_state);
                _sgimgui_frame_add_stats_row("prev_frame . gl . num_vertex_attrib_pointer", stats.prev_frame.gl.num_vertex_attrib_pointer);
                _sgimgui_frame_add_stats_row("prev_frame . gl . num_vertex_attrib_divisor", stats.prev_frame.gl.num_vertex_attrib_divisor);
                _sgimgui_frame_add_stats_row("prev_frame . gl . num_enable_vertex_attrib_array", stats.prev_frame.gl.num_enable_vertex_attrib_array);
                _sgimgui_frame_add_stats_row("prev_frame . gl . num_disable_vertex_attrib_array", stats.prev_frame.gl.num_disable_vertex_attrib_array);
                _sgimgui_frame_add_stats_row("prev_frame . gl . num_uniform", stats.prev_frame.gl.num_uniform);
                _sgimgui_frame_add_stats_row("prev_frame . gl . num_memory_barriers", stats.prev_frame.gl.num_memory_barriers);
            }
            case SG_BACKEND_WGPU: {
                _sgimgui_frame_add_stats_row("prev_frame . wgpu . uniforms . num_set_bindgroup", stats.prev_frame.wgpu.uniforms.num_set_bindgroup);
                _sgimgui_frame_add_stats_row("prev_frame . wgpu . uniforms . size_write_buffer", stats.prev_frame.wgpu.uniforms.size_write_buffer);
                _sgimgui_frame_add_stats_row("prev_frame . wgpu . bindings . num_set_vertex_buffer", stats.prev_frame.wgpu.bindings.num_set_vertex_buffer);
                _sgimgui_frame_add_stats_row("prev_frame . wgpu . bindings . num_skip_redundant_vertex_buffer", stats.prev_frame.wgpu.bindings.num_skip_redundant_vertex_buffer);
                _sgimgui_frame_add_stats_row("prev_frame . wgpu . bindings . num_set_index_buffer", stats.prev_frame.wgpu.bindings.num_set_index_buffer);
                _sgimgui_frame_add_stats_row("prev_frame . wgpu . bindings . num_skip_redundant_index_buffer", stats.prev_frame.wgpu.bindings.num_skip_redundant_index_buffer);
                _sgimgui_frame_add_stats_row("prev_frame . wgpu . bindings . num_create_bindgroup", stats.prev_frame.wgpu.bindings.num_create_bindgroup);
                _sgimgui_frame_add_stats_row("prev_frame . wgpu . bindings . num_discard_bindgroup", stats.prev_frame.wgpu.bindings.num_discard_bindgroup);
                _sgimgui_frame_add_stats_row("prev_frame . wgpu . bindings . num_set_bindgroup", stats.prev_frame.wgpu.bindings.num_set_bindgroup);
                _sgimgui_frame_add_stats_row("prev_frame . wgpu . bindings . num_skip_redundant_bindgroup", stats.prev_frame.wgpu.bindings.num_skip_redundant_bindgroup);
                _sgimgui_frame_add_stats_row("prev_frame . wgpu . bindings . num_bindgroup_cache_hits", stats.prev_frame.wgpu.bindings.num_bindgroup_cache_hits);
                _sgimgui_frame_add_stats_row("prev_frame . wgpu . bindings . num_bindgroup_cache_misses", stats.prev_frame.wgpu.bindings.num_bindgroup_cache_misses);
                _sgimgui_frame_add_stats_row("prev_frame . wgpu . bindings . num_bindgroup_cache_collisions", stats.prev_frame.wgpu.bindings.num_bindgroup_cache_collisions);
                _sgimgui_frame_add_stats_row("prev_frame . wgpu . bindings . num_bindgroup_cache_invalidates", stats.prev_frame.wgpu.bindings.num_bindgroup_cache_invalidates);
                _sgimgui_frame_add_stats_row("prev_frame . wgpu . bindings . num_bindgroup_cache_hash_vs_key_mismatch", stats.prev_frame.wgpu.bindings.num_bindgroup_cache_hash_vs_key_mismatch);
            }
            case SG_BACKEND_METAL_MACOS, SG_BACKEND_METAL_IOS, SG_BACKEND_METAL_SIMULATOR: {
                _sgimgui_frame_add_stats_row("prev_frame . metal . idpool . num_added", stats.prev_frame.metal.idpool.num_added);
                _sgimgui_frame_add_stats_row("prev_frame . metal . idpool . num_released", stats.prev_frame.metal.idpool.num_released);
                _sgimgui_frame_add_stats_row("prev_frame . metal . idpool . num_garbage_collected", stats.prev_frame.metal.idpool.num_garbage_collected);
                _sgimgui_frame_add_stats_row("prev_frame . metal . pipeline . num_set_blend_color", stats.prev_frame.metal.pipeline.num_set_blend_color);
                _sgimgui_frame_add_stats_row("prev_frame . metal . pipeline . num_set_cull_mode", stats.prev_frame.metal.pipeline.num_set_cull_mode);
                _sgimgui_frame_add_stats_row("prev_frame . metal . pipeline . num_set_front_facing_winding", stats.prev_frame.metal.pipeline.num_set_front_facing_winding);
                _sgimgui_frame_add_stats_row("prev_frame . metal . pipeline . num_set_stencil_reference_value", stats.prev_frame.metal.pipeline.num_set_stencil_reference_value);
                _sgimgui_frame_add_stats_row("prev_frame . metal . pipeline . num_set_depth_bias", stats.prev_frame.metal.pipeline.num_set_depth_bias);
                _sgimgui_frame_add_stats_row("prev_frame . metal . pipeline . num_set_render_pipeline_state", stats.prev_frame.metal.pipeline.num_set_render_pipeline_state);
                _sgimgui_frame_add_stats_row("prev_frame . metal . pipeline . num_set_depth_stencil_state", stats.prev_frame.metal.pipeline.num_set_depth_stencil_state);
                _sgimgui_frame_add_stats_row("prev_frame . metal . bindings . num_set_vertex_buffer", stats.prev_frame.metal.bindings.num_set_vertex_buffer);
                _sgimgui_frame_add_stats_row("prev_frame . metal . bindings . num_set_fragment_buffer", stats.prev_frame.metal.bindings.num_set_fragment_buffer);
                _sgimgui_frame_add_stats_row("prev_frame . metal . bindings . num_set_compute_buffer", stats.prev_frame.metal.bindings.num_set_compute_buffer);
                _sgimgui_frame_add_stats_row("prev_frame . metal . bindings . num_set_vertex_buffer_offset", stats.prev_frame.metal.bindings.num_set_vertex_buffer_offset);
                _sgimgui_frame_add_stats_row("prev_frame . metal . bindings . num_set_fragment_buffer_offset", stats.prev_frame.metal.bindings.num_set_fragment_buffer_offset);
                _sgimgui_frame_add_stats_row("prev_frame . metal . bindings . num_set_compute_buffer_offset", stats.prev_frame.metal.bindings.num_set_compute_buffer_offset);
                _sgimgui_frame_add_stats_row("prev_frame . metal . bindings . num_set_vertex_texture", stats.prev_frame.metal.bindings.num_set_vertex_texture);
                _sgimgui_frame_add_stats_row("prev_frame . metal . bindings . num_set_fragment_texture", stats.prev_frame.metal.bindings.num_set_fragment_texture);
                _sgimgui_frame_add_stats_row("prev_frame . metal . bindings . num_set_compute_texture", stats.prev_frame.metal.bindings.num_set_compute_texture);
                _sgimgui_frame_add_stats_row("prev_frame . metal . bindings . num_set_vertex_sampler_state", stats.prev_frame.metal.bindings.num_set_vertex_sampler_state);
                _sgimgui_frame_add_stats_row("prev_frame . metal . bindings . num_set_fragment_sampler_state", stats.prev_frame.metal.bindings.num_set_fragment_sampler_state);
                _sgimgui_frame_add_stats_row("prev_frame . metal . bindings . num_set_compute_sampler_state", stats.prev_frame.metal.bindings.num_set_compute_sampler_state);
                _sgimgui_frame_add_stats_row("prev_frame . metal . bindings . num_skip_redundant_vertex_buffer", stats.prev_frame.metal.bindings.num_skip_redundant_vertex_buffer);
                _sgimgui_frame_add_stats_row("prev_frame . metal . bindings . num_skip_redundant_fragment_buffer", stats.prev_frame.metal.bindings.num_skip_redundant_fragment_buffer);
                _sgimgui_frame_add_stats_row("prev_frame . metal . bindings . num_skip_redundant_compute_buffer", stats.prev_frame.metal.bindings.num_skip_redundant_compute_buffer);
                _sgimgui_frame_add_stats_row("prev_frame . metal . bindings . num_skip_redundant_vertex_texture", stats.prev_frame.metal.bindings.num_skip_redundant_vertex_texture);
                _sgimgui_frame_add_stats_row("prev_frame . metal . bindings . num_skip_redundant_fragment_texture", stats.prev_frame.metal.bindings.num_skip_redundant_fragment_texture);
                _sgimgui_frame_add_stats_row("prev_frame . metal . bindings . num_skip_redundant_compute_texture", stats.prev_frame.metal.bindings.num_skip_redundant_compute_texture);
                _sgimgui_frame_add_stats_row("prev_frame . metal . bindings . num_skip_redundant_vertex_sampler_state", stats.prev_frame.metal.bindings.num_skip_redundant_vertex_sampler_state);
                _sgimgui_frame_add_stats_row("prev_frame . metal . bindings . num_skip_redundant_fragment_sampler_state", stats.prev_frame.metal.bindings.num_skip_redundant_fragment_sampler_state);
                _sgimgui_frame_add_stats_row("prev_frame . metal . bindings . num_skip_redundant_compute_sampler_state", stats.prev_frame.metal.bindings.num_skip_redundant_compute_sampler_state);
                _sgimgui_frame_add_stats_row("prev_frame . metal . uniforms . num_set_vertex_buffer_offset", stats.prev_frame.metal.uniforms.num_set_vertex_buffer_offset);
                _sgimgui_frame_add_stats_row("prev_frame . metal . uniforms . num_set_fragment_buffer_offset", stats.prev_frame.metal.uniforms.num_set_fragment_buffer_offset);
                _sgimgui_frame_add_stats_row("prev_frame . metal . uniforms . num_set_compute_buffer_offset", stats.prev_frame.metal.uniforms.num_set_compute_buffer_offset);
            }
            case SG_BACKEND_D3D11: {
                _sgimgui_frame_add_stats_row("prev_frame . d3d11 . pass . num_om_set_render_targets", stats.prev_frame.d3d11.pass.num_om_set_render_targets);
                _sgimgui_frame_add_stats_row("prev_frame . d3d11 . pass . num_clear_render_target_view", stats.prev_frame.d3d11.pass.num_clear_render_target_view);
                _sgimgui_frame_add_stats_row("prev_frame . d3d11 . pass . num_clear_depth_stencil_view", stats.prev_frame.d3d11.pass.num_clear_depth_stencil_view);
                _sgimgui_frame_add_stats_row("prev_frame . d3d11 . pass . num_resolve_subresource", stats.prev_frame.d3d11.pass.num_resolve_subresource);
                _sgimgui_frame_add_stats_row("prev_frame . d3d11 . pipeline . num_rs_set_state", stats.prev_frame.d3d11.pipeline.num_rs_set_state);
                _sgimgui_frame_add_stats_row("prev_frame . d3d11 . pipeline . num_om_set_depth_stencil_state", stats.prev_frame.d3d11.pipeline.num_om_set_depth_stencil_state);
                _sgimgui_frame_add_stats_row("prev_frame . d3d11 . pipeline . num_om_set_blend_state", stats.prev_frame.d3d11.pipeline.num_om_set_blend_state);
                _sgimgui_frame_add_stats_row("prev_frame . d3d11 . pipeline . num_ia_set_primitive_topology", stats.prev_frame.d3d11.pipeline.num_ia_set_primitive_topology);
                _sgimgui_frame_add_stats_row("prev_frame . d3d11 . pipeline . num_ia_set_input_layout", stats.prev_frame.d3d11.pipeline.num_ia_set_input_layout);
                _sgimgui_frame_add_stats_row("prev_frame . d3d11 . pipeline . num_vs_set_shader", stats.prev_frame.d3d11.pipeline.num_vs_set_shader);
                _sgimgui_frame_add_stats_row("prev_frame . d3d11 . pipeline . num_vs_set_constant_buffers", stats.prev_frame.d3d11.pipeline.num_vs_set_constant_buffers);
                _sgimgui_frame_add_stats_row("prev_frame . d3d11 . pipeline . num_ps_set_shader", stats.prev_frame.d3d11.pipeline.num_ps_set_shader);
                _sgimgui_frame_add_stats_row("prev_frame . d3d11 . pipeline . num_ps_set_constant_buffers", stats.prev_frame.d3d11.pipeline.num_ps_set_constant_buffers);
                _sgimgui_frame_add_stats_row("prev_frame . d3d11 . pipeline . num_cs_set_shader", stats.prev_frame.d3d11.pipeline.num_cs_set_shader);
                _sgimgui_frame_add_stats_row("prev_frame . d3d11 . pipeline . num_cs_set_constant_buffers", stats.prev_frame.d3d11.pipeline.num_cs_set_constant_buffers);
                _sgimgui_frame_add_stats_row("prev_frame . d3d11 . bindings . num_ia_set_vertex_buffers", stats.prev_frame.d3d11.bindings.num_ia_set_vertex_buffers);
                _sgimgui_frame_add_stats_row("prev_frame . d3d11 . bindings . num_ia_set_index_buffer", stats.prev_frame.d3d11.bindings.num_ia_set_index_buffer);
                _sgimgui_frame_add_stats_row("prev_frame . d3d11 . bindings . num_vs_set_shader_resources", stats.prev_frame.d3d11.bindings.num_vs_set_shader_resources);
                _sgimgui_frame_add_stats_row("prev_frame . d3d11 . bindings . num_ps_set_shader_resources", stats.prev_frame.d3d11.bindings.num_ps_set_shader_resources);
                _sgimgui_frame_add_stats_row("prev_frame . d3d11 . bindings . num_cs_set_shader_resources", stats.prev_frame.d3d11.bindings.num_cs_set_shader_resources);
                _sgimgui_frame_add_stats_row("prev_frame . d3d11 . bindings . num_vs_set_samplers", stats.prev_frame.d3d11.bindings.num_vs_set_samplers);
                _sgimgui_frame_add_stats_row("prev_frame . d3d11 . bindings . num_ps_set_samplers", stats.prev_frame.d3d11.bindings.num_ps_set_samplers);
                _sgimgui_frame_add_stats_row("prev_frame . d3d11 . bindings . num_cs_set_samplers", stats.prev_frame.d3d11.bindings.num_cs_set_samplers);
                _sgimgui_frame_add_stats_row("prev_frame . d3d11 . bindings . num_cs_set_unordered_access_views", stats.prev_frame.d3d11.bindings.num_cs_set_unordered_access_views);
                _sgimgui_frame_add_stats_row("prev_frame . d3d11 . uniforms . num_update_subresource", stats.prev_frame.d3d11.uniforms.num_update_subresource);
                _sgimgui_frame_add_stats_row("prev_frame . d3d11 . draw . num_draw_indexed_instanced", stats.prev_frame.d3d11.draw.num_draw_indexed_instanced);
                _sgimgui_frame_add_stats_row("prev_frame . d3d11 . draw . num_draw_indexed", stats.prev_frame.d3d11.draw.num_draw_indexed);
                _sgimgui_frame_add_stats_row("prev_frame . d3d11 . draw . num_draw_instanced", stats.prev_frame.d3d11.draw.num_draw_instanced);
                _sgimgui_frame_add_stats_row("prev_frame . d3d11 . draw . num_draw", stats.prev_frame.d3d11.draw.num_draw);
                _sgimgui_frame_add_stats_row("prev_frame . d3d11 . num_map", stats.prev_frame.d3d11.num_map);
                _sgimgui_frame_add_stats_row("prev_frame . d3d11 . num_unmap", stats.prev_frame.d3d11.num_unmap);
            }
            case SG_BACKEND_VULKAN: {
                _sgimgui_frame_add_stats_row("prev_frame . vk . num_cmd_pipeline_barrier", stats.prev_frame.vk.num_cmd_pipeline_barrier);
                _sgimgui_frame_add_stats_row("prev_frame . vk . num_allocate_memory", stats.prev_frame.vk.num_allocate_memory);
                _sgimgui_frame_add_stats_row("prev_frame . vk . num_free_memory", stats.prev_frame.vk.num_free_memory);
                _sgimgui_frame_add_stats_row("prev_frame . vk . size_allocate_memory", stats.prev_frame.vk.size_allocate_memory);
                _sgimgui_frame_add_stats_row("prev_frame . vk . num_delete_queue_added", stats.prev_frame.vk.num_delete_queue_added);
                _sgimgui_frame_add_stats_row("prev_frame . vk . num_delete_queue_collected", stats.prev_frame.vk.num_delete_queue_collected);
                _sgimgui_frame_add_stats_row("prev_frame . vk . num_cmd_copy_buffer", stats.prev_frame.vk.num_cmd_copy_buffer);
                _sgimgui_frame_add_stats_row("prev_frame . vk . num_cmd_copy_buffer_to_image", stats.prev_frame.vk.num_cmd_copy_buffer_to_image);
                _sgimgui_frame_add_stats_row("prev_frame . vk . num_cmd_set_descriptor_buffer_offsets", stats.prev_frame.vk.num_cmd_set_descriptor_buffer_offsets);
                _sgimgui_frame_add_stats_row("prev_frame . vk . size_descriptor_buffer_writes", stats.prev_frame.vk.size_descriptor_buffer_writes);
            }
            default: {
            }
        }
        _sgimgui_frame_add_stats_row("total . buffers . alive", stats.total.buffers.alive);
        _sgimgui_frame_add_stats_row("total . buffers . free", stats.total.buffers.free);
        _sgimgui_frame_add_stats_row("total . buffers . allocated", stats.total.buffers.allocated);
        _sgimgui_frame_add_stats_row("total . buffers . deallocated", stats.total.buffers.deallocated);
        _sgimgui_frame_add_stats_row("total . buffers . inited", stats.total.buffers.inited);
        _sgimgui_frame_add_stats_row("total . buffers . uninited", stats.total.buffers.uninited);
        _sgimgui_frame_add_stats_row("total . images . alive", stats.total.images.alive);
        _sgimgui_frame_add_stats_row("total . images . free", stats.total.images.free);
        _sgimgui_frame_add_stats_row("total . images . allocated", stats.total.images.allocated);
        _sgimgui_frame_add_stats_row("total . images . deallocated", stats.total.images.deallocated);
        _sgimgui_frame_add_stats_row("total . images . inited", stats.total.images.inited);
        _sgimgui_frame_add_stats_row("total . images . uninited", stats.total.images.uninited);
        _sgimgui_frame_add_stats_row("total . samplers . alive", stats.total.samplers.alive);
        _sgimgui_frame_add_stats_row("total . samplers . free", stats.total.samplers.free);
        _sgimgui_frame_add_stats_row("total . samplers . allocated", stats.total.samplers.allocated);
        _sgimgui_frame_add_stats_row("total . samplers . deallocated", stats.total.samplers.deallocated);
        _sgimgui_frame_add_stats_row("total . samplers . inited", stats.total.samplers.inited);
        _sgimgui_frame_add_stats_row("total . samplers . uninited", stats.total.samplers.uninited);
        _sgimgui_frame_add_stats_row("total . views . alive", stats.total.views.alive);
        _sgimgui_frame_add_stats_row("total . views . free", stats.total.views.free);
        _sgimgui_frame_add_stats_row("total . views . allocated", stats.total.views.allocated);
        _sgimgui_frame_add_stats_row("total . views . deallocated", stats.total.views.deallocated);
        _sgimgui_frame_add_stats_row("total . views . inited", stats.total.views.inited);
        _sgimgui_frame_add_stats_row("total . views . uninited", stats.total.views.uninited);
        _sgimgui_frame_add_stats_row("total . pipelines . alive", stats.total.pipelines.alive);
        _sgimgui_frame_add_stats_row("total . pipelines . free", stats.total.pipelines.free);
        _sgimgui_frame_add_stats_row("total . pipelines . allocated", stats.total.pipelines.allocated);
        _sgimgui_frame_add_stats_row("total . pipelines . deallocated", stats.total.pipelines.deallocated);
        _sgimgui_frame_add_stats_row("total . pipelines . inited", stats.total.pipelines.inited);
        _sgimgui_frame_add_stats_row("total . pipelines . uninited", stats.total.pipelines.uninited);
        _sgimgui_igendtable();
    }
}

sgimgui_desc_t _sgimgui_desc_defaults(sgimgui_desc_t* desc) {
    sgimgui_desc_t res = *desc;
    return res;
}
}

/*--- PUBLIC FUNCTIONS -------------------------------------------------------*/
void sgimgui_setup(sgimgui_desc_t* desc) {
    _sgimgui_clear(&_sgimgui, cast(u64, sizeof(_sgimgui_t)));
    _sgimgui.init_tag = 0xABCDABCD;
    _sgimgui.desc = _sgimgui_desc_defaults(desc);
    _sgimgui_capture_init(&_sgimgui);
    noinit sg_trace_hooks hooks;
    _sgimgui_clear(&hooks, cast(u64, sizeof(hooks)));
    hooks.user_data = cast(void*, &_sgimgui);
    hooks.reset_state_cache = _sgimgui_reset_state_cache;
    hooks.make_buffer = _sgimgui_make_buffer;
    hooks.make_image = _sgimgui_make_image;
    hooks.make_sampler = _sgimgui_make_sampler;
    hooks.make_shader = _sgimgui_make_shader;
    hooks.make_pipeline = _sgimgui_make_pipeline;
    hooks.make_view = _sgimgui_make_view;
    hooks.destroy_buffer = _sgimgui_destroy_buffer;
    hooks.destroy_image = _sgimgui_destroy_image;
    hooks.destroy_sampler = _sgimgui_destroy_sampler;
    hooks.destroy_shader = _sgimgui_destroy_shader;
    hooks.destroy_pipeline = _sgimgui_destroy_pipeline;
    hooks.destroy_view = _sgimgui_destroy_view;
    hooks.update_buffer = _sgimgui_update_buffer;
    hooks.update_image = _sgimgui_update_image;
    hooks.append_buffer = _sgimgui_append_buffer;
    hooks.write_buffer_unsealed = _sgimgui_write_buffer_unsealed;
    hooks.write_image_unsealed = _sgimgui_write_image_unsealed;
    hooks.seal_buffer = _sgimgui_seal_buffer;
    hooks.seal_image = _sgimgui_seal_image;
    hooks.begin_pass = _sgimgui_begin_pass;
    hooks.apply_viewport = _sgimgui_apply_viewport;
    hooks.apply_scissor_rect = _sgimgui_apply_scissor_rect;
    hooks.apply_pipeline = _sgimgui_apply_pipeline;
    hooks.apply_bindings = _sgimgui_apply_bindings;
    hooks.apply_uniforms = _sgimgui_apply_uniforms;
    hooks.draw = _sgimgui_draw;
    hooks.draw_ex = _sgimgui_draw_ex;
    hooks.dispatch = _sgimgui_dispatch;
    hooks.end_pass = _sgimgui_end_pass;
    hooks.commit = _sgimgui_commit;
    hooks.alloc_buffer = _sgimgui_alloc_buffer;
    hooks.alloc_image = _sgimgui_alloc_image;
    hooks.alloc_sampler = _sgimgui_alloc_sampler;
    hooks.alloc_shader = _sgimgui_alloc_shader;
    hooks.alloc_pipeline = _sgimgui_alloc_pipeline;
    hooks.alloc_view = _sgimgui_alloc_view;
    hooks.dealloc_buffer = _sgimgui_dealloc_buffer;
    hooks.dealloc_image = _sgimgui_dealloc_image;
    hooks.dealloc_sampler = _sgimgui_dealloc_sampler;
    hooks.dealloc_shader = _sgimgui_dealloc_shader;
    hooks.dealloc_pipeline = _sgimgui_dealloc_pipeline;
    hooks.dealloc_view = _sgimgui_dealloc_view;
    hooks.init_buffer = _sgimgui_init_buffer;
    hooks.init_image = _sgimgui_init_image;
    hooks.init_sampler = _sgimgui_init_sampler;
    hooks.init_shader = _sgimgui_init_shader;
    hooks.init_pipeline = _sgimgui_init_pipeline;
    hooks.init_view = _sgimgui_init_view;
    hooks.uninit_buffer = _sgimgui_uninit_buffer;
    hooks.uninit_image = _sgimgui_uninit_image;
    hooks.uninit_sampler = _sgimgui_uninit_sampler;
    hooks.uninit_shader = _sgimgui_uninit_shader;
    hooks.uninit_pipeline = _sgimgui_uninit_pipeline;
    hooks.uninit_view = _sgimgui_uninit_view;
    hooks.fail_buffer = _sgimgui_fail_buffer;
    hooks.fail_image = _sgimgui_fail_image;
    hooks.fail_sampler = _sgimgui_fail_sampler;
    hooks.fail_shader = _sgimgui_fail_shader;
    hooks.fail_pipeline = _sgimgui_fail_pipeline;
    hooks.fail_view = _sgimgui_fail_view;
    hooks.push_debug_group = _sgimgui_push_debug_group;
    hooks.pop_debug_group = _sgimgui_pop_debug_group;
    _sgimgui.hooks = sg_install_trace_hooks(&hooks);
    sg_desc sgdesc = sg_query_desc();
    _sgimgui.buffer_window.num_slots = sgdesc.buffer_pool_size;
    _sgimgui.image_window.num_slots = sgdesc.image_pool_size;
    _sgimgui.sampler_window.num_slots = sgdesc.sampler_pool_size;
    _sgimgui.shader_window.num_slots = sgdesc.shader_pool_size;
    _sgimgui.pipeline_window.num_slots = sgdesc.pipeline_pool_size;
    _sgimgui.view_window.num_slots = sgdesc.view_pool_size;
    u64 buffer_pool_size = cast(u64, _sgimgui.buffer_window.num_slots) * cast(u64, sizeof(_sgimgui_buffer_t));
    _sgimgui.buffer_window.slots = cast(_sgimgui_buffer_t*, _sgimgui_malloc_clear(&_sgimgui.desc.allocator, buffer_pool_size));
    u64 image_pool_size = cast(u64, _sgimgui.image_window.num_slots) * cast(u64, sizeof(_sgimgui_image_t));
    _sgimgui.image_window.slots = cast(_sgimgui_image_t*, _sgimgui_malloc_clear(&_sgimgui.desc.allocator, image_pool_size));
    u64 sampler_pool_size = cast(u64, _sgimgui.sampler_window.num_slots) * cast(u64, sizeof(_sgimgui_sampler_t));
    _sgimgui.sampler_window.slots = cast(_sgimgui_sampler_t*, _sgimgui_malloc_clear(&_sgimgui.desc.allocator, sampler_pool_size));
    u64 shader_pool_size = cast(u64, _sgimgui.shader_window.num_slots) * cast(u64, sizeof(_sgimgui_shader_t));
    _sgimgui.shader_window.slots = cast(_sgimgui_shader_t*, _sgimgui_malloc_clear(&_sgimgui.desc.allocator, shader_pool_size));
    u64 pipeline_pool_size = cast(u64, _sgimgui.pipeline_window.num_slots) * cast(u64, sizeof(_sgimgui_pipeline_t));
    _sgimgui.pipeline_window.slots = cast(_sgimgui_pipeline_t*, _sgimgui_malloc_clear(&_sgimgui.desc.allocator, pipeline_pool_size));
    u64 view_pool_size = cast(u64, _sgimgui.view_window.num_slots) * cast(u64, sizeof(_sgimgui_view_t));
    _sgimgui.view_window.slots = cast(_sgimgui_view_t*, _sgimgui_malloc_clear(&_sgimgui.desc.allocator, view_pool_size));
}

void sgimgui_shutdown() {
    sg_install_trace_hooks(&_sgimgui.hooks);
    _sgimgui.init_tag = 0;
    _sgimgui_capture_discard(&_sgimgui);
    if _sgimgui.buffer_window.slots != null {
        for i32 i = 0; i < _sgimgui.buffer_window.num_slots; i++ {
            if _sgimgui.buffer_window.slots[i].res_id.id != cast(u32, SG_INVALID_ID) {
                _sgimgui_buffer_destroyed(&_sgimgui, i);
            }
        }
        _sgimgui_free(&_sgimgui.desc.allocator, cast(void*, _sgimgui.buffer_window.slots));
        _sgimgui.buffer_window.slots = null;
    }
    if _sgimgui.image_window.slots != null {
        for i32 i = 0; i < _sgimgui.image_window.num_slots; i++ {
            if _sgimgui.image_window.slots[i].res_id.id != cast(u32, SG_INVALID_ID) {
                _sgimgui_image_destroyed(&_sgimgui, i);
            }
        }
        _sgimgui_free(&_sgimgui.desc.allocator, cast(void*, _sgimgui.image_window.slots));
        _sgimgui.image_window.slots = null;
    }
    if _sgimgui.sampler_window.slots != null {
        for i32 i = 0; i < _sgimgui.sampler_window.num_slots; i++ {
            if _sgimgui.sampler_window.slots[i].res_id.id != cast(u32, SG_INVALID_ID) {
                _sgimgui_sampler_destroyed(&_sgimgui, i);
            }
        }
        _sgimgui_free(&_sgimgui.desc.allocator, cast(void*, _sgimgui.sampler_window.slots));
        _sgimgui.sampler_window.slots = null;
    }
    if _sgimgui.shader_window.slots != null {
        for i32 i = 0; i < _sgimgui.shader_window.num_slots; i++ {
            if _sgimgui.shader_window.slots[i].res_id.id != cast(u32, SG_INVALID_ID) {
                _sgimgui_shader_destroyed(&_sgimgui, i);
            }
        }
        _sgimgui_free(&_sgimgui.desc.allocator, cast(void*, _sgimgui.shader_window.slots));
        _sgimgui.shader_window.slots = null;
    }
    if _sgimgui.pipeline_window.slots != null {
        for i32 i = 0; i < _sgimgui.pipeline_window.num_slots; i++ {
            if _sgimgui.pipeline_window.slots[i].res_id.id != cast(u32, SG_INVALID_ID) {
                _sgimgui_pipeline_destroyed(&_sgimgui, i);
            }
        }
        _sgimgui_free(&_sgimgui.desc.allocator, cast(void*, _sgimgui.pipeline_window.slots));
        _sgimgui.pipeline_window.slots = null;
    }
    if _sgimgui.view_window.slots != null {
        for i32 i = 0; i < _sgimgui.view_window.num_slots; i++ {
            if _sgimgui.view_window.slots[i].res_id.id != cast(u32, SG_INVALID_ID) {
                _sgimgui_view_destroyed(&_sgimgui, i);
            }
        }
        _sgimgui_free(&_sgimgui.desc.allocator, cast(void*, _sgimgui.view_window.slots));
        _sgimgui.view_window.slots = null;
    }
}

void sgimgui_draw() {
    sgimgui_draw_buffer_window("[sg] Buffers");
    sgimgui_draw_image_window("[sg] Images");
    sgimgui_draw_sampler_window("[sg] Samplers");
    sgimgui_draw_shader_window("[sg] Shaders");
    sgimgui_draw_pipeline_window("[sg] Pipelines");
    sgimgui_draw_view_window("[sg] Views");
    sgimgui_draw_capture_window("[sg] Frame Capture");
    sgimgui_draw_capabilities_window("[sg] Capabilities");
    sgimgui_draw_frame_stats_window("[sg] Frame Stats");
}

void sgimgui_draw_menu(u8* title) {
    if _sgimgui_igbeginmenu(title) != 0 {
        sgimgui_draw_capabilities_menu_item("Capabilities");
        sgimgui_draw_frame_stats_menu_item("Frame Stats");
        sgimgui_draw_buffer_menu_item("Buffers");
        sgimgui_draw_image_menu_item("Images");
        sgimgui_draw_view_menu_item("Views");
        sgimgui_draw_sampler_menu_item("Samplers");
        sgimgui_draw_shader_menu_item("Shaders");
        sgimgui_draw_pipeline_menu_item("Pipelines");
        sgimgui_draw_capture_menu_item("Calls");
        _sgimgui_igendmenu();
    }
}

void sgimgui_draw_buffer_menu_item(u8* label) {
    _sgimgui_igmenuitemboolptr(label, null, &_sgimgui.buffer_window.open, true);
}

void sgimgui_draw_image_menu_item(u8* label) {
    _sgimgui_igmenuitemboolptr(label, null, &_sgimgui.image_window.open, true);
}

void sgimgui_draw_sampler_menu_item(u8* label) {
    _sgimgui_igmenuitemboolptr(label, null, &_sgimgui.sampler_window.open, true);
}

void sgimgui_draw_shader_menu_item(u8* label) {
    _sgimgui_igmenuitemboolptr(label, null, &_sgimgui.shader_window.open, true);
}

void sgimgui_draw_pipeline_menu_item(u8* label) {
    _sgimgui_igmenuitemboolptr(label, null, &_sgimgui.pipeline_window.open, true);
}

void sgimgui_draw_view_menu_item(u8* label) {
    _sgimgui_igmenuitemboolptr(label, null, &_sgimgui.view_window.open, true);
}

void sgimgui_draw_capture_menu_item(u8* label) {
    _sgimgui_igmenuitemboolptr(label, null, &_sgimgui.capture_window.open, true);
}

void sgimgui_draw_capabilities_menu_item(u8* label) {
    _sgimgui_igmenuitemboolptr(label, null, &_sgimgui.caps_window.open, true);
}

void sgimgui_draw_frame_stats_menu_item(u8* label) {
    _sgimgui_igmenuitemboolptr(label, null, &_sgimgui.frame_stats_window.open, true);
}

void sgimgui_draw_buffer_window(u8* title) {
    if _sgimgui.buffer_window.open == 0 {
        return;
    }
    _sgimgui_igsetnextwindowsize(ImVec2{440.0f, 280.0f}, ImGuiCond_Once);
    if _sgimgui_igbegin(title, &_sgimgui.buffer_window.open, 0) != 0 {
        sgimgui_draw_buffer_window_content();
    }
    _sgimgui_igend();
}

void sgimgui_draw_image_window(u8* title) {
    if _sgimgui.image_window.open == 0 {
        return;
    }
    _sgimgui_igsetnextwindowsize(ImVec2{440.0f, 400.0f}, ImGuiCond_Once);
    if _sgimgui_igbegin(title, &_sgimgui.image_window.open, 0) != 0 {
        sgimgui_draw_image_window_content();
    }
    _sgimgui_igend();
}

void sgimgui_draw_sampler_window(u8* title) {
    if _sgimgui.sampler_window.open == 0 {
        return;
    }
    _sgimgui_igsetnextwindowsize(ImVec2{440.0f, 400.0f}, ImGuiCond_Once);
    if _sgimgui_igbegin(title, &_sgimgui.sampler_window.open, 0) != 0 {
        sgimgui_draw_sampler_window_content();
    }
    _sgimgui_igend();
}

void sgimgui_draw_shader_window(u8* title) {
    if _sgimgui.shader_window.open == 0 {
        return;
    }
    _sgimgui_igsetnextwindowsize(ImVec2{440.0f, 400.0f}, ImGuiCond_Once);
    if _sgimgui_igbegin(title, &_sgimgui.shader_window.open, 0) != 0 {
        sgimgui_draw_shader_window_content();
    }
    _sgimgui_igend();
}

void sgimgui_draw_pipeline_window(u8* title) {
    if _sgimgui.pipeline_window.open == 0 {
        return;
    }
    _sgimgui_igsetnextwindowsize(ImVec2{540.0f, 400.0f}, ImGuiCond_Once);
    if _sgimgui_igbegin(title, &_sgimgui.pipeline_window.open, 0) != 0 {
        sgimgui_draw_pipeline_window_content();
    }
    _sgimgui_igend();
}

void sgimgui_draw_view_window(u8* title) {
    if _sgimgui.view_window.open == 0 {
        return;
    }
    _sgimgui_igsetnextwindowsize(ImVec2{440.0f, 400.0f}, ImGuiCond_Once);
    if _sgimgui_igbegin(title, &_sgimgui.view_window.open, 0) != 0 {
        sgimgui_draw_view_window_content();
    }
    _sgimgui_igend();
}

void sgimgui_draw_capture_window(u8* title) {
    if _sgimgui.capture_window.open == 0 {
        return;
    }
    _sgimgui_igsetnextwindowsize(ImVec2{640.0f, 400.0f}, ImGuiCond_Once);
    if _sgimgui_igbegin(title, &_sgimgui.capture_window.open, 0) != 0 {
        sgimgui_draw_capture_window_content();
    }
    _sgimgui_igend();
}

void sgimgui_draw_capabilities_window(u8* title) {
    if _sgimgui.caps_window.open == 0 {
        return;
    }
    _sgimgui_igsetnextwindowsize(ImVec2{440.0f, 400.0f}, ImGuiCond_Once);
    if _sgimgui_igbegin(title, &_sgimgui.caps_window.open, 0) != 0 {
        sgimgui_draw_capabilities_window_content();
    }
    _sgimgui_igend();
}

void sgimgui_draw_frame_stats_window(u8* title) {
    if _sgimgui.frame_stats_window.open == 0 {
        return;
    }
    _sgimgui_igsetnextwindowsize(ImVec2{640.0f, 400.0f}, ImGuiCond_Once);
    if _sgimgui_igbegin(title, &_sgimgui.frame_stats_window.open, 0) != 0 {
        sgimgui_draw_frame_stats_window_content();
    }
    _sgimgui_igend();
}

void sgimgui_draw_buffer_window_content() {
    _sgimgui_draw_buffer_list(&_sgimgui);
    _sgimgui_igsameline();
    _sgimgui_draw_buffer_panel(&_sgimgui, _sgimgui.buffer_window.sel_buf);
}

void sgimgui_draw_image_window_content() {
    _sgimgui_draw_image_list(&_sgimgui);
    _sgimgui_igsameline();
    _sgimgui_draw_image_panel(&_sgimgui, _sgimgui.image_window.sel_img);
}

void sgimgui_draw_sampler_window_content() {
    _sgimgui_draw_sampler_list(&_sgimgui);
    _sgimgui_igsameline();
    _sgimgui_draw_sampler_panel(&_sgimgui, _sgimgui.sampler_window.sel_smp);
}

void sgimgui_draw_shader_window_content() {
    _sgimgui_draw_shader_list(&_sgimgui);
    _sgimgui_igsameline();
    _sgimgui_draw_shader_panel(&_sgimgui, _sgimgui.shader_window.sel_shd);
}

void sgimgui_draw_pipeline_window_content() {
    _sgimgui_draw_pipeline_list(&_sgimgui);
    _sgimgui_igsameline();
    _sgimgui_draw_pipeline_panel(&_sgimgui, _sgimgui.pipeline_window.sel_pip);
}

void sgimgui_draw_view_window_content() {
    _sgimgui_draw_view_list(&_sgimgui);
    _sgimgui_igsameline();
    _sgimgui_draw_view_panel(&_sgimgui, _sgimgui.view_window.sel_view);
}

void sgimgui_draw_capture_window_content() {
    _sgimgui_draw_capture_list(&_sgimgui);
    _sgimgui_igsameline();
    _sgimgui_draw_capture_panel(&_sgimgui);
}

void sgimgui_draw_capabilities_window_content() {
    _sgimgui_draw_caps_panel();
}

void sgimgui_draw_frame_stats_window_content() {
    _sgimgui.frame_stats_window.stats = sg_query_stats();
    _sgimgui_draw_frame_stats_panel(&_sgimgui);
}
private {
u8*[16] _sgimgui_colormask_string__str_var = {
    "NONE", "R", "G", "RG", "B", "RB", "GB", "RGB", "A", "RA", "GA", "RGA", "BA", "RBA", "GBA",
    "RGBA",
};
}  // renamed from: str

