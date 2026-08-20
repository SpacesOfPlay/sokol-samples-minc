import dbgui;
import imgui_compat;
import sokol_gfx_imgui;
import sokol_app_imgui;
import sokol_letterbox;

// sapp samples that use Dear ImGui
import sokol_all;
import imgui;
import sokol_imgui;
import math;

// upstream samples leave high_dpi off and blur on scaled displays.
// Forced enabled here.
sapp_desc sokol_main() {
    sapp_desc d = __sapp_sample_main();
    d.high_dpi = true;
    return d;
}

// writeimage-sapp.glsl, hand-ported. One bufferless fullscreen
// triangle feeding four fragment shaders, one per texture type, so the
// sample can display whatever it just wrote: 2D, 2D array, 3D and cube.

struct Ub_fs_params {
    f32 miplevel;
    f32 slice;
}

struct WriteimageSappVsOut {
    float4 pos;
    float2 uv;
}

@shader vertex
WriteimageSappVsOut writeimage_sapp_vs() {
    u32 vid = vertex_id();
    f32 x = 0.0f;
    f32 y = 0.0f;
    if (vid & cast(u32, 1)) != cast(u32, 0) { x = 2.0f; }
    if (vid & cast(u32, 2)) != cast(u32, 0) { y = 2.0f; }
    WriteimageSappVsOut o;
    o.pos = float4{x * 2.0f - 1.0f, y * 2.0f - 1.0f, 0.5f, 1.0f};
    o.uv = float2{x, 1.0f - y};
    return o;
}

@shader fragment
float4 writeimage_sapp_fs_tex2d(
    WriteimageSappVsOut input,
    @uniform(0) Ub_fs_params p,
    @texture(0) Texture2D tex2d,
    @sampler(0) Sampler smp
) {
    return sample_level(tex2d, smp, input.uv, p.miplevel);
}

@shader fragment
float4 writeimage_sapp_fs_texarray(
    WriteimageSappVsOut input,
    @uniform(0) Ub_fs_params p,
    @texture(0) Texture2DArray texarray,
    @sampler(0) Sampler smp
) {
    return sample_level(texarray, smp, float3{input.uv.x, input.uv.y, p.slice},
                        p.miplevel);
}

@shader fragment
float4 writeimage_sapp_fs_tex3d(
    WriteimageSappVsOut input,
    @uniform(0) Ub_fs_params p,
    @texture(0) Texture3D tex3d,
    @sampler(0) Sampler smp
) {
    // depth of the mip about to be sampled
    int3 sz = texture_size(tex3d, cast(i32, p.miplevel));
    f32 w = (p.slice + 0.5f) / cast(f32, sz.z);
    return sample_level(tex3d, smp, float3{input.uv.x, input.uv.y, w}, p.miplevel);
}

@shader fragment
float4 writeimage_sapp_fs_texcube(
    WriteimageSappVsOut input,
    @uniform(0) Ub_fs_params p,
    @texture(0) TextureCube texcube,
    @sampler(0) Sampler smp
) {
    float2 t = float2{input.uv.x * 2.0f - 1.0f, input.uv.y * 2.0f - 1.0f};
    i32 face = cast(i32, p.slice);
    float3 dir = float3{0.0f - t.x, 0.0f - t.y, 0.0f - 1.0f};   // -Z
    if face == 0      { dir = float3{1.0f, 0.0f - t.y, 0.0f - t.x}; }
    else if face == 1 { dir = float3{0.0f - 1.0f, 0.0f - t.y, t.x}; }
    else if face == 2 { dir = float3{t.x, 1.0f, t.y}; }
    else if face == 3 { dir = float3{t.x, 0.0f - 1.0f, 0.0f - t.y}; }
    else if face == 4 { dir = float3{t.x, 0.0f - t.y, 1.0f}; }
    return sample_level(texcube, smp, dir, p.miplevel);
}

enum __enum_UB_fs_params {
    UB_fs_params = 0,
    VIEW_tex2d = 0,
    SMP_smp = 0,
    VIEW_texarray = 0,
    VIEW_tex3d = 0,
    VIEW_texcube = 0,
    __shim_end = 255,
}

enum image_type_t {
    IMGTYPE_2D = 0,
    IMGTYPE_CUBE = 1,
    IMGTYPE_3D = 2,
    IMGTYPE_ARRAY = 3,
    NUM_IMGTYPES = 4,
}

// Replaces the sokol-shdc generated writeimage-sapp.glsl.h.
struct fs_params_t {
    f32 miplevel;
    f32 slice;
    u8[8] _pad_tail;
}

private struct state_t {
    sg_image img;
    sg_view view;
    sg_sampler smp;
    sg_pipeline pip;
    sg_range mip_data;
    struct {
        i32 image_type;
        bool show_code_panel;
        i32 min_bytes_per_row;
        i32 max_bytes_per_row;
        i32 min_bytes_per_slice;
        i32 max_bytes_per_slice;
        i32 max_x;
        i32 max_y;
        i32 max_slice;
        i32 max_width;
        i32 max_height;
        i32 max_num_slices;
        bool dirty;
        struct {
            struct {
                i32 offset;
                bool use_defaults;
                i32 bytes_per_row;
                i32 bytes_per_slice;
            } src;
            struct {
                i32 mip_level;
                i32 x;
                i32 y;
                i32 slice;
            } dst;
            struct {
                bool use_defaults;
                i32 width;
                i32 height;
                i32 num_slices;
            } size;
        } write;
        struct {
            i32 mip_level;
            i32 slice;
        } display;
    } ui;
}

private {
u8*[4] imgtype_str = {"2D", "Cube Map", "3D", "2D Array"};
state_t state = state_t{
    .ui = {.write = {.src = {.use_defaults = true}, .size = {.use_defaults = true}}},
};
}

private {
void init() {
    sg_setup(&sg_desc{.environment = sglue_environment(), .logger = sg_logger{.func = slog_func}});
    sgimgui_setup(&sgimgui_desc_t{});
    sappimgui_setup();
    simgui_setup(&simgui_desc_t{.logger = simgui_logger_t{.func = slog_func}});
    ui_update_deps(true);
    ui_apply_changes();
}

void frame() {
    ui();
    var action = sg_pass_action{
        .colors[0] = {
            .load_action = SG_LOADACTION_CLEAR,
            .clear_value = state.ui.dirty != 0 ? sg_color{0.5f, 0.0f, 0.0f, 1.0f} : sg_color{0.0f, 0.5f, 0.0f, 1.0f},
        },
    };
    var fs_params = fs_params_t{
        .miplevel = cast(f32, state.ui.display.mip_level),
        .slice = cast(f32, state.ui.display.slice),
    };
    slbx_viewport vp = slbx_letterbox(sapp_width(), sapp_height(), &slbx_letterbox_desc{
        .border = slbx_border{.top = 30, .bottom = 20, .left = 20, .right = 20},
        .content_aspect_ratio = 1.0f,
    });
    sg_begin_pass(&sg_pass{.action = action, .swapchain = sglue_swapchain()});
    sg_apply_viewport(vp.x, vp.y, vp.width, vp.height, true);
    sg_apply_pipeline(state.pip);
    sg_apply_bindings(&sg_bindings{.views[0] = state.view, .samplers[0] = state.smp});
    sg_apply_uniforms(UB_fs_params, &sg_range{&fs_params, sizeof(fs_params)});
    sg_draw(0, 3, 1);
    simgui_render();
    sg_end_pass();
    sg_commit();
}

void input(sapp_event* ev) {
    sappimgui_track_event(ev);
    simgui_handle_event(ev);
}

void cleanup() {
    discard_resources();
    sappimgui_shutdown();
    sgimgui_shutdown();
    simgui_shutdown();
    sg_shutdown();
}

i32 _max(i32 v0, i32 v1) {
    return v0 > v1 ? v0 : v1;
}

i32 _min(i32 v0, i32 v1) {
    return v0 < v1 ? v0 : v1;
}

i32 _mip_dim(i32 base, i32 mip_level) {
    return _max(base >> mip_level, 1);
}

void ui_update_deps(bool img_type_changed) {
    state.ui.dirty = true;
    if img_type_changed != 0 {
        state.ui.display.mip_level = 0;
        state.ui.display.slice = 0;
        state.ui.write.dst.mip_level = 0;
        state.ui.write.dst.slice = 0;
    }
    i32 mip_level = state.ui.write.dst.mip_level;
    i32 mip_width = _mip_dim(1 << 9 - 1, mip_level);
    i32 mip_height = _mip_dim(1 << 9 - 1, mip_level);
    i32 mip_depth = _mip_dim(6, mip_level);
    state.ui.max_x = mip_width - 1;
    state.ui.max_y = mip_height - 1;
    switch state.ui.image_type {
        case IMGTYPE_2D: {
            state.ui.max_slice = 0;
        }
        case IMGTYPE_3D: {
            state.ui.max_slice = mip_depth - 1;
        }
        default: {
            state.ui.max_slice = 6 - 1;
        }
    }
    state.ui.write.dst.x = _min(state.ui.write.dst.x, state.ui.max_x);
    state.ui.write.dst.y = _min(state.ui.write.dst.y, state.ui.max_y);
    state.ui.write.dst.slice = _min(state.ui.write.dst.slice, state.ui.max_slice);
    state.ui.max_width = mip_width - state.ui.write.dst.x;
    state.ui.max_height = mip_height - state.ui.write.dst.y;
    switch state.ui.image_type {
        case IMGTYPE_2D: {
            state.ui.max_num_slices = 1;
        }
        case IMGTYPE_3D: {
            state.ui.max_num_slices = mip_depth - state.ui.write.dst.slice;
        }
        default: {
            state.ui.max_num_slices = 6 - state.ui.write.dst.slice;
        }
    }
    if state.ui.write.size.use_defaults || img_type_changed {
        state.ui.write.size.width = state.ui.max_width;
        state.ui.write.size.height = state.ui.max_height;
        state.ui.write.size.num_slices = state.ui.max_num_slices;
    } else {
        state.ui.write.size.width = _min(state.ui.write.size.width, state.ui.max_width);
        state.ui.write.size.height = _min(state.ui.write.size.height, state.ui.max_height);
        state.ui.write.size.num_slices = _min(state.ui.write.size.num_slices, state.ui.max_num_slices);
    }
    state.ui.min_bytes_per_row = mip_width * 4;
    state.ui.max_bytes_per_row = 2048;
    if state.ui.write.src.use_defaults != 0 {
        state.ui.write.src.bytes_per_row = state.ui.min_bytes_per_row;
    } else {
        i32 min_bpr = state.ui.min_bytes_per_row;
        i32 max_bpr = state.ui.max_bytes_per_row;
        state.ui.write.src.bytes_per_row = _max(_min(state.ui.write.src.bytes_per_row, max_bpr), min_bpr);
    }
    i32 bpp_mask = ~(4 - 1);
    state.ui.write.src.offset &= bpp_mask;
    state.ui.write.src.bytes_per_row &= bpp_mask;
    i32 bpr = state.ui.write.src.bytes_per_row;
    state.ui.min_bytes_per_slice = bpr * mip_height;
    state.ui.max_bytes_per_slice = bpr * 2048;
    if state.ui.write.src.use_defaults != 0 {
        state.ui.write.src.bytes_per_slice = state.ui.min_bytes_per_slice;
    } else {
        i32 min_bps = state.ui.min_bytes_per_slice;
        i32 max_bps = state.ui.max_bytes_per_slice;
        state.ui.write.src.bytes_per_slice = _max(_min(state.ui.write.src.bytes_per_slice, max_bps), min_bps);
    }
    state.ui.write.src.bytes_per_slice = state.ui.write.src.bytes_per_slice / bpr * bpr;
}

u64 src_buffer_size() {
    return cast(u64, state.ui.write.src.offset + (state.ui.max_slice + 1) * state.ui.write.src.bytes_per_slice);
}

void ui() {
    sappimgui_track_frame();
    simgui_new_frame(&simgui_frame_desc_t{
        .width = sapp_width(),
        .height = sapp_height(),
        .dpi_scale = sapp_dpi_scale(),
        .delta_time = sapp_frame_duration(),
    });
    if ImGui_BeginMainMenuBar() != 0 {
        sgimgui_draw_menu("sokol-gfx");
        sappimgui_draw_menu("sokol-app");
        ImGui_EndMainMenuBar();
    }
    sappimgui_draw();
    sgimgui_draw();
    ImGui_SetNextWindowPos(ImVec2{30.0f, 50.0f}, ImGuiCond_Once);
    ImGui_SetNextWindowBgAlpha(0.75f);
    if ImGui_Begin("Controls", null, ImGuiWindowFlags_NoDecoration | ImGuiWindowFlags_AlwaysAutoResize) != 0 {
        ImGui_BeginChild("##controls", ImVec2{}, ImGuiChildFlags_AutoResizeX | ImGuiChildFlags_AutoResizeY, ImGuiWindowFlags_None);
        ImGui_Checkbox("Show code example", &state.ui.show_code_panel);
        if ImGui_Combo("Image Type", &state.ui.image_type, imgtype_str, cast(i32, sizeof(imgtype_str) / sizeof(*imgtype_str))) != 0 {
            ui_update_deps(true);
        }
        ImGui_SeparatorText("Display Options");
        ImGui_SliderInt("Mip Level##display", &state.ui.display.mip_level, 0, 9 - 1);
        ImGui_SliderInt("Slice##display", &state.ui.display.slice, 0, state.ui.max_slice);
        ImGui_SeparatorText("Write Options");
        ImGui_Text("Write Source:");
        if ImGui_SliderInt("Offset:", &state.ui.write.src.offset, 0, 1024) != 0 {
            ui_update_deps(false);
        }
        if ImGui_Checkbox("Use Defaults##pitch", &state.ui.write.src.use_defaults) != 0 {
            ui_update_deps(false);
        }
        ImGui_BeginDisabled(state.ui.write.src.use_defaults);
        if ImGui_SliderInt("Bytes Per Row", &state.ui.write.src.bytes_per_row, state.ui.min_bytes_per_row, state.ui.max_bytes_per_row) != 0 {
            ui_update_deps(false);
        }
        if ImGui_SliderInt("Bytes Per Slice", &state.ui.write.src.bytes_per_slice, state.ui.min_bytes_per_slice, state.ui.max_bytes_per_slice) != 0 {
            ui_update_deps(false);
        }
        ImGui_EndDisabled();
        ImGui_Text("Write Destination:");
        if ImGui_SliderInt("Mip Level##dst", &state.ui.write.dst.mip_level, 0, 9 - 1) != 0 {
            ui_update_deps(false);
        }
        if ImGui_SliderInt("X", &state.ui.write.dst.x, 0, state.ui.max_x) != 0 {
            ui_update_deps(false);
        }
        if ImGui_SliderInt("Y", &state.ui.write.dst.y, 0, state.ui.max_y) != 0 {
            ui_update_deps(false);
        }
        if ImGui_SliderInt("Slice##dst", &state.ui.write.dst.slice, 0, state.ui.max_slice) != 0 {
            ui_update_deps(false);
        }
        ImGui_Text("Write Size:");
        if ImGui_Checkbox("Use Defaults##sizes", &state.ui.write.size.use_defaults) != 0 {
            ui_update_deps(false);
        }
        ImGui_BeginDisabled(state.ui.write.size.use_defaults);
        if ImGui_SliderInt("Width", &state.ui.write.size.width, 1, state.ui.max_width) != 0 {
            ui_update_deps(false);
        }
        if ImGui_SliderInt("Height", &state.ui.write.size.height, 1, state.ui.max_height) != 0 {
            ui_update_deps(false);
        }
        if ImGui_SliderInt("Num Slices", &state.ui.write.size.num_slices, 1, state.ui.max_num_slices) != 0 {
            ui_update_deps(false);
        }
        ImGui_EndDisabled();
        ImGui_BeginDisabled(!state.ui.dirty);
        bool dirty = state.ui.dirty;
        if dirty != 0 {
            ImGui_PushStyleColor(ImGuiCol_Button, ImVec4{1.0f, 0.0f, 0.0f, 1.0f});
        }
        if ImGui_Button("Apply Changes") != 0 {
            ui_apply_changes();
        }
        if dirty != 0 {
            ImGui_PopStyleColor();
        }
        ImGui_EndDisabled();
        ImGui_EndChild();
        if state.ui.show_code_panel != 0 {
            ImGui_SameLine();
            ImGui_BeginChild("##code_panel", ImVec2{384.0f, 0.0f}, ImGuiChildFlags_Borders, ImGuiWindowFlags_HorizontalScrollbar);
            if state.ui.image_type != IMGTYPE_2D {
                ImGui_Text("NOTE: src.data.size is shown here for number of\nslices of the image, not for number of written\nslices!\n");
                ImGui_Separator();
            }
            ImGui_Text("\nsg_write_image_unsealed(&(sg_write_image_desc){");
            ImGui_Text("  .src = {");
            ImGui_Text("    .data = {");
            ImGui_Text("      .ptr = src_data_ptr,");
            ImGui_Text("      .size = %d,", cast(i32, src_buffer_size()));
            ImGui_Text("    },");
            if state.ui.write.src.offset != 0 {
                ImGui_Text("    .offset = %d,", state.ui.write.src.offset);
            }
            if state.ui.write.src.use_defaults == 0 {
                ImGui_Text("    .bytes_per_row = %d,", state.ui.write.src.bytes_per_row);
                ImGui_Text("    .bytes_per_slice = %d,", state.ui.write.src.bytes_per_slice);
            }
            ImGui_Text("  },");
            ImGui_Text("  .dst = {");
            ImGui_Text("    .image = img,");
            if state.ui.write.dst.mip_level != 0 {
                ImGui_Text("    .mip_level = %d,", state.ui.write.dst.mip_level);
            }
            if state.ui.write.dst.x != 0 {
                ImGui_Text("    .x = %d,", state.ui.write.dst.x);
            }
            if state.ui.write.dst.y != 0 {
                ImGui_Text("    .y = %d,", state.ui.write.dst.y);
            }
            if state.ui.write.dst.slice != 0 {
                ImGui_Text("    .slice = %d,", state.ui.write.dst.slice);
            }
            ImGui_Text("  },");
            if state.ui.write.size.use_defaults == 0 {
                ImGui_Text("  .size = {");
                ImGui_Text("    .width = %d,", state.ui.write.size.width);
                ImGui_Text("    .height = %d,", state.ui.write.size.height);
                ImGui_Text("    .num_slices = %d,", state.ui.write.size.num_slices);
                ImGui_Text("  },");
            }
            ImGui_Text("});");
            ImGui_EndChild();
        }
    }
    ImGui_End();
}

void ui_apply_changes() {
    state.ui.dirty = false;
    state.ui.display.mip_level = state.ui.write.dst.mip_level;
    state.ui.display.slice = state.ui.write.dst.slice;
    discard_resources();
    create_resources();
}

void alloc_mip_data() {
    state.mip_data.size = src_buffer_size();
    state.mip_data.ptr = cast(void*, new(u8[state.mip_data.size]));
}

void free_mip_data() {
    if state.mip_data.ptr != null {
        free(state.mip_data.ptr);
        state.mip_data.ptr = null;
        state.mip_data.size = 0;
    }
}

void pixel(i32 x, i32 y, i32 slice, u32 rgba) {
    i32 u32pr = state.ui.write.src.bytes_per_row >> 2;
    i32 u32ps = state.ui.write.src.bytes_per_slice >> 2;
    i32 u32offset = state.ui.write.src.offset >> 2;
    i32 idx = u32offset + slice * u32ps + y * u32pr + x;
    var ptr = cast(u32*, state.mip_data.ptr);
    ptr[idx] = rgba;
}

void populate_slice(i32 slice, u32 rgba0, u32 rgba1) {
    i32 w = state.ui.max_x + 1;
    i32 h = state.ui.max_y + 1;
    i32 ww = _max(w / 2, 1);
    i32 hh = _max(h / 2, 1);
    for i32 y = 0; y < hh; y++ {
        for i32 x = 0; x < ww; x++ {
            u32 c;
            if y & 1 && x >= y || x & 1 && y >= x {
                c = rgba0;
            } else {
                c = rgba1;
            }
            i32 xx = w - x - 1;
            i32 yy = h - y - 1;
            pixel(x, y, slice, c);
            pixel(y, xx, slice, c);
            pixel(yy, x, slice, c);
            pixel(yy, xx, slice, c);
        }
    }
}

void populate_mipmap_data() {
    i32 num_slices = state.ui.max_slice + 1;
    for i32 slice = 0; slice < num_slices; slice++ {
        populate_slice(slice, 0xFF444444, populate_mipmap_data__palette[slice]);
    }
}

sg_image_type as_sg_image_type(image_type_t t) {
    switch t {
        case IMGTYPE_CUBE: {
            return SG_IMAGETYPE_CUBE;
        }
        case IMGTYPE_3D: {
            return SG_IMAGETYPE_3D;
        }
        case IMGTYPE_ARRAY: {
            return SG_IMAGETYPE_ARRAY;
        }
        default: {
            return SG_IMAGETYPE_2D;
        }
    }
}

sg_shader select_shader_by_image_type(image_type_t t) {
    unused sg_backend backend = sg_query_backend();
    switch t {
        case IMGTYPE_CUBE: {
            return sokol_make_shader(&writeimage_sapp_vs_shader, &writeimage_sapp_fs_texcube_shader);
        }
        case IMGTYPE_3D: {
            return sokol_make_shader(&writeimage_sapp_vs_shader, &writeimage_sapp_fs_tex3d_shader);
        }
        case IMGTYPE_ARRAY: {
            return sokol_make_shader(&writeimage_sapp_vs_shader, &writeimage_sapp_fs_texarray_shader);
        }
        default: {
            return sokol_make_shader(&writeimage_sapp_vs_shader, &writeimage_sapp_fs_tex2d_shader);
        }
    }
}

void create_resources() {
    alloc_mip_data();
    populate_mipmap_data();
    sg_image_type img_type = as_sg_image_type(state.ui.image_type);
    state.img = sg_make_image(&sg_image_desc{
        .type = img_type,
        .usage = sg_image_usage{.write_unsealed = true},
        .pixel_format = SG_PIXELFORMAT_RGBA8,
        .width = 1 << 9 - 1,
        .height = 1 << 9 - 1,
        .num_slices = img_type == SG_IMAGETYPE_2D ? 1 : 6,
        .num_mipmaps = 9,
        .label = "test-image",
    });
    bool src_defaults = state.ui.write.src.use_defaults;
    bool size_defaults = state.ui.write.size.use_defaults;
    sg_write_image_unsealed(&sg_write_image_desc{
        .src = sg_write_image_source{
            .data = state.mip_data,
            .offset = cast(u64, state.ui.write.src.offset),
            .bytes_per_row = src_defaults != 0 ? 0 : state.ui.write.src.bytes_per_row,
            .bytes_per_slice = src_defaults != 0 ? 0 : state.ui.write.src.bytes_per_slice,
        },
        .dst = sg_image_location{
            .image = state.img,
            .mip_level = state.ui.write.dst.mip_level,
            .x = state.ui.write.dst.x,
            .y = state.ui.write.dst.y,
            .slice = state.ui.write.dst.slice,
        },
        .size = sg_image_extent{
            .width = size_defaults != 0 ? 0 : state.ui.write.size.width,
            .height = size_defaults != 0 ? 0 : state.ui.write.size.height,
            .num_slices = size_defaults != 0 ? 0 : state.ui.write.size.num_slices,
        },
    });
    sg_seal_image(state.img);
    free_mip_data();
    state.view = sg_make_view(&sg_view_desc{
        .texture = sg_texture_view_desc{.image = state.img},
        .label = "test-image-view",
    });
    state.smp = sg_make_sampler(&sg_sampler_desc{
        .min_filter = SG_FILTER_NEAREST,
        .mag_filter = SG_FILTER_NEAREST,
        .mipmap_filter = SG_FILTER_NEAREST,
        .wrap_u = SG_WRAP_CLAMP_TO_EDGE,
        .wrap_v = SG_WRAP_CLAMP_TO_EDGE,
        .wrap_w = SG_WRAP_CLAMP_TO_EDGE,
        .label = "test-sampler",
    });
    state.pip = sg_make_pipeline(&sg_pipeline_desc{
        .shader = select_shader_by_image_type(state.ui.image_type),
        .label = "test-pipeline",
    });
}

void discard_resources() {
    sg_destroy_image(state.img);
    sg_destroy_view(state.view);
    sg_destroy_sampler(state.smp);
    sg_destroy_pipeline(state.pip);
}
}

sapp_desc __sapp_sample_main() {
    return sapp_desc{
        .init_cb = init,
        .frame_cb = frame,
        .cleanup_cb = cleanup,
        .event_cb = input,
        .width = 1024,
        .height = 768,
        .depth_format = SAPP_PIXELFORMAT_NONE,
        .window_title = "writeimage-sapp.mc",
        .icon = sapp_icon_desc{.sokol_default = true},
        .logger = sapp_logger{.func = slog_func},
    };
}
private {
u32[6] populate_mipmap_data__palette = {
    0xFFFF0000, 0xFF00FF00, 0xFF0000FF, 0xFFFFFF00, 0xFF00FFFF, 0xFFFF00FF,
};
}
