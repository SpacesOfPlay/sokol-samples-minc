import dbgui;
import imgui_compat;
import sapp_util;
import sokol_fetch;
import sokol_gfx_imgui;
import sokol_app_imgui;
import sokol_gl;
import spine_c;
import sokol_spine;

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

/* Replaces stb_image.h; the samples only use the
   load-from-memory surface, provided by ext/sokol_samples/
   stbi_shim.mc over lib/png.mc + lib/jpeg.mc (RGBA8). Extern-included:
   declarations register, nothing emits. */
type stbi_uc = u8;
private struct state_t {
    sspine_atlas atlas;
    sspine_skeleton skeleton;
    sspine_instance instance;
    sg_pass_action pass_action;
    sspine_layer_transform layer_transform;
    sspine_vec2 iktarget_pos;
    struct {
        i32 scene_index;
        i32 pending_count;
        bool failed;
        sspine_range atlas_data;
        sspine_range skel_data;
        bool skel_data_is_binary;
    } load_status;
    struct {
        bool draw_bones_enabled;
        bool atlas_open;
        bool bones_open;
        bool slots_open;
        bool anims_open;
        bool events_open;
        bool skins_open;
        bool iktargets_open;
        struct {
            sspine_bone bone;
            sspine_slot slot;
            sspine_anim anim;
            sspine_event event;
            sspine_skin skin;
            sspine_iktarget iktarget;
        } selected;
        f64 cur_time;
        struct {
            f64 time;
            sspine_event event;
        } last_triggered_event;
    } ui;
    struct {
        u8[16384] atlas;
        u8[524288] skeleton;
        u8[524288] image;
    } buffers;
}

// describe Spine scenes available for loading
struct anim_t {
    u8* name;
    bool looping;
    f32 delay;
}

struct scene_t {
    u8* ui_name;
    u8* atlas_file;
    u8* skel_file_json;
    u8* skel_file_binary;
    u8* skin;
    f32 prescale;
    sspine_atlas_overrides atlas_overrides;
    anim_t[4] anim_queue;
}

private { state_t state; }
scene_t[5] spine_scenes = {
    scene_t{
        .ui_name = "Spine Boy",
        .atlas_file = "spineboy.atlas",
        .skel_file_json = "spineboy-pro.json",
        .prescale = 0.75f,
        .atlas_overrides = sspine_atlas_overrides{
            .min_filter = SG_FILTER_NEAREST,
            .mag_filter = SG_FILTER_NEAREST,
        },
        .anim_queue = {
            anim_t{.name = "portal"},
            anim_t{.name = "run", .looping = true},
            anim_t{},
            anim_t{},
        },
    },
    scene_t{
        .ui_name = "Raptor",
        .atlas_file = "raptor-pma.atlas",
        .skel_file_binary = "raptor-pro.skel",
        .prescale = 0.5f,
        .anim_queue = {
            anim_t{.name = "jump"},
            anim_t{.name = "roar"},
            anim_t{.name = "walk", .looping = true},
            anim_t{},
        },
    },
    scene_t{
        .ui_name = "Alien",
        .atlas_file = "alien-pma.atlas",
        .skel_file_binary = "alien-pro.skel",
        .prescale = 0.5f,
        .anim_queue = {
            anim_t{.name = "run", .looping = true},
            anim_t{.name = "death", .looping = false, .delay = 5.0f},
            anim_t{.name = "run", .looping = true},
            anim_t{.name = "death", .looping = true, .delay = 5.0f},
        },
    },
    scene_t{
        .ui_name = "Speedy",
        .atlas_file = "speedy-pma.atlas",
        .skel_file_binary = "speedy-ess.skel",
        .anim_queue = {anim_t{.name = "run", .looping = true}, anim_t{}, anim_t{}, anim_t{}},
    },
    scene_t{
        .ui_name = "Mix & Match",
        .atlas_file = "mix-and-match-pma.atlas",
        .skel_file_binary = "mix-and-match-pro.skel",
        .skin = "full-skins/girl",
        .prescale = 0.5f,
        .anim_queue[0] = {.name = "walk", .looping = true},
    },
};

private {
void init() {
    sg_setup(&sg_desc{.environment = sglue_environment(), .logger = sg_logger{.func = slog_func}});
    ui_setup();
    sgl_setup(&sgl_desc_t{.logger = sgl_logger_t{.func = slog_func}});
    sfetch_setup(&sfetch_desc_t{
        .max_requests = 3,
        .num_channels = 2,
        .num_lanes = 1,
        .logger = sfetch_logger_t{.func = slog_func},
    });
    sspine_setup(&sspine_desc{.logger = sspine_logger{.func = slog_func}});
    load_spine_scene(0);
}

void frame() {
    f64 delta_time = sapp_frame_duration();
    state.ui.cur_time += delta_time;
    state.layer_transform = sspine_layer_transform{
        .size = sspine_vec2{.x = sapp_widthf(), .y = sapp_heightf()},
        .origin = sspine_vec2{.x = sapp_widthf() * 0.5f, .y = sapp_heightf() * 0.8f},
    };
    sfetch_dowork();
    simgui_new_frame(&simgui_frame_desc_t{
        .width = sapp_width(),
        .height = sapp_height(),
        .dpi_scale = sapp_dpi_scale(),
        .delta_time = delta_time,
    });
    sspine_set_iktarget_world_pos(state.instance, state.ui.selected.iktarget, state.iktarget_pos);
    sspine_update_instance(state.instance, cast(f32, delta_time));
    sspine_draw_instance_in_layer(state.instance, 0);
    i32 num_triggered_events = sspine_num_triggered_events(state.instance);
    for i32 i = 0; i < num_triggered_events; i++ {
        state.ui.last_triggered_event.time = state.ui.cur_time;
        state.ui.last_triggered_event.event = sspine_get_triggered_event_info(state.instance, i).event;
    }
    if state.ui.draw_bones_enabled != 0 {
        draw_bones();
    }
    ui_draw();
    if state.load_status.failed != 0 {
        state.pass_action = sg_pass_action{
            .colors[0] = {
                .load_action = SG_LOADACTION_CLEAR,
                .clear_value = {1.0f, 0.0f, 0.0f, 1.0f},
            },
        };
    } else {
        state.pass_action = sg_pass_action{
            .colors[0] = {
                .load_action = SG_LOADACTION_CLEAR,
                .clear_value = {0.0f, 0.5f, 0.7f, 1.0f},
            },
        };
    }
    sg_begin_pass(&sg_pass{.action = state.pass_action, .swapchain = sglue_swapchain()});
    sspine_draw_layer(0, &state.layer_transform);
    sgl_draw();
    simgui_render();
    sg_end_pass();
    sg_commit();
}

void input(sapp_event* ev) {
    sappimgui_track_event(ev);
    if simgui_handle_event(ev) != 0 {
        return;
    }
    if ev.type == SAPP_EVENTTYPE_MOUSE_MOVE {
        state.iktarget_pos.x = ev.mouse_x - state.layer_transform.origin.x;
        state.iktarget_pos.y = ev.mouse_y - state.layer_transform.origin.y;
    }
}

void cleanup() {
    ui_shutdown();
    sspine_shutdown();
    sfetch_shutdown();
    sgl_shutdown();
    sg_shutdown();
}

// start loading a spine scene asynchronously
bool load_spine_scene(i32 scene_index) {
    if state.load_status.pending_count > 0 {
        return false;
    }
    state.load_status.scene_index = scene_index;
    state.load_status.pending_count = 0;
    state.load_status.failed = false;
    state.load_status.atlas_data = sspine_range{};
    state.load_status.skel_data = sspine_range{};
    state.load_status.skel_data_is_binary = false;
    sspine_destroy_instance(state.instance);
    sspine_destroy_skeleton(state.skeleton);
    sspine_destroy_atlas(state.atlas);
    noinit u8[512] path_buf;
    sfetch_send(&sfetch_request_t{
        .path = fileutil_get_path(spine_scenes[scene_index].atlas_file, path_buf, cast(u64, sizeof(path_buf))),
        .channel = 0,
        .buffer = sfetch_range_t{&state.buffers.atlas, sizeof(state.buffers.atlas)},
        .callback = atlas_data_loaded,
    });
    state.load_status.pending_count++;
    u8* skel_file = spine_scenes[scene_index].skel_file_json;
    if skel_file == null {
        skel_file = spine_scenes[scene_index].skel_file_binary;
        state.load_status.skel_data_is_binary = true;
    }
    sfetch_send(&sfetch_request_t{
        .path = fileutil_get_path(skel_file, path_buf, cast(u64, sizeof(path_buf))),
        .channel = 1,
        .buffer = sfetch_range_t{
            .ptr = state.buffers.skeleton,
            .size = cast(u64, sizeof(state.buffers.skeleton) - 1),
        },
        .callback = skeleton_data_loaded,
    });
    state.load_status.pending_count++;
    return true;
}

// called by sokol-fetch when atlas file has been loaded
void atlas_data_loaded(sfetch_response_t* response) {
    if response.fetched || response.failed {
        state.load_status.pending_count--;
    }
    if response.fetched != 0 {
        state.load_status.atlas_data = sspine_range{response.data.ptr, response.data.size};
        if state.load_status.pending_count == 0 {
            create_spine_objects();
        }
    } else if response.failed != 0 {
        state.load_status.failed = true;
    }
}

// called by sokol-fetch when skeleton file has been loaded
void skeleton_data_loaded(sfetch_response_t* response) {
    if response.fetched || response.failed {
        state.load_status.pending_count--;
    }
    if response.fetched != 0 {
        state.load_status.skel_data = sspine_range{response.data.ptr, response.data.size};
        state.buffers.skeleton[response.data.size] = 0;
        if state.load_status.pending_count == 0 {
            create_spine_objects();
        }
    } else if response.failed != 0 {
        state.load_status.failed = true;
    }
}

// called when both the Spine atlas and skeleton file has finished loading
void create_spine_objects() {
    i32 scene_index = state.load_status.scene_index;
    state.atlas = sspine_make_atlas(&sspine_atlas_desc{
        .data = state.load_status.atlas_data,
        .override = spine_scenes[scene_index].atlas_overrides,
    });
    u8* skel_json_data = null;
    sspine_range skel_binary_data;
    if state.load_status.skel_data_is_binary != 0 {
        skel_binary_data = state.load_status.skel_data;
    } else {
        skel_json_data = cast(u8*, state.load_status.skel_data.ptr);
    }
    state.skeleton = sspine_make_skeleton(&sspine_skeleton_desc{
        .atlas = state.atlas,
        .prescale = spine_scenes[scene_index].prescale,
        .anim_default_mix = 0.2f,
        .json_data = skel_json_data,
        .binary_data = skel_binary_data,
    });
    state.instance = sspine_make_instance(&sspine_instance_desc{.skeleton = state.skeleton});
    if spine_scenes[scene_index].skin != null {
        sspine_set_skin(state.instance, sspine_skin_by_name(state.skeleton, spine_scenes[scene_index].skin));
    }
    for i32 anim_index = 0; anim_index < 4; anim_index++ {
        anim_t* queue_anim = &spine_scenes[scene_index].anim_queue[anim_index];
        if queue_anim.name != null {
            sspine_anim anim = sspine_anim_by_name(state.skeleton, queue_anim.name);
            if anim_index == 0 {
                sspine_set_animation(state.instance, anim, 0, queue_anim.looping);
            } else {
                sspine_add_animation(state.instance, anim, 0, queue_anim.looping, queue_anim.delay);
            }
        }
    }
    i32 num_images = sspine_num_images(state.atlas);
    for i32 img_index = 0; img_index < num_images; img_index++ {
        sspine_image img = sspine_image_by_index(state.atlas, img_index);
        sspine_image_info img_info = sspine_get_image_info(img);
        noinit u8[512] path_buf;
        sfetch_send(&sfetch_request_t{
            .channel = 0,
            .path = fileutil_get_path(img_info.filename.cstr, path_buf, cast(u64, sizeof(path_buf))),
            .buffer = sfetch_range_t{&state.buffers.image, sizeof(state.buffers.image)},
            .callback = image_data_loaded,
            .user_data = sfetch_range_t{&img, sizeof(img)},
        });
        state.load_status.pending_count++;
    }
}

// called when atlas image data has finished loading
void image_data_loaded(sfetch_response_t* response) {
    if response.fetched || response.failed {
        state.load_status.pending_count--;
    }
    sspine_image img = *cast(sspine_image*, response.user_data);
    sspine_image_info img_info = sspine_get_image_info(img);
    if response.fetched != 0 {
        i32 desired_channels = 4;
        i32 img_width;
        i32 img_height;
        i32 num_channels;
        stbi_uc* pixels = stbi_load_from_memory(response.data.ptr, cast(i32, response.data.size), &img_width, &img_height, &num_channels, desired_channels);
        if pixels != null {
            sg_init_image(img_info.sgimage, &sg_image_desc{
                .width = img_width,
                .height = img_height,
                .pixel_format = SG_PIXELFORMAT_RGBA8,
                .label = img_info.filename.cstr,
                .data = sg_image_data{
                    .mip_levels[0] = {.ptr = pixels, .size = cast(u64, img_width * img_height * 4)},
                },
            });
            sg_init_view(img_info.sgview, &sg_view_desc{.texture = sg_texture_view_desc{.image = img_info.sgimage}});
            sg_init_sampler(img_info.sgsampler, &sg_sampler_desc{
                .min_filter = img_info.min_filter,
                .mag_filter = img_info.mag_filter,
                .mipmap_filter = img_info.mipmap_filter,
                .wrap_u = img_info.wrap_u,
                .wrap_v = img_info.wrap_v,
                .label = img_info.filename.cstr,
            });
            stbi_image_free(pixels);
        } else {
            state.load_status.failed = false;
            sg_fail_image(img_info.sgimage);
        }
    } else if response.failed != 0 {
        state.load_status.failed = true;
        sg_fail_image(img_info.sgimage);
    }
}

//=== UI STUFF =================================================================
void ui_setup() {
    sappimgui_setup();
    sgimgui_setup(&sgimgui_desc_t{});
    simgui_setup(&simgui_desc_t{.logger = simgui_logger_t{.func = slog_func}});
}

void ui_shutdown() {
    sappimgui_shutdown();
    sgimgui_shutdown();
    simgui_shutdown();
}

u8* ui_sgfilter_name(sg_filter f) {
    switch f {
        case _SG_FILTER_DEFAULT: {
            return "DEFAULT";
        }
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

u8* ui_sgwrap_name(sg_wrap w) {
    switch w {
        case _SG_WRAP_DEFAULT: {
            return "DEFAULT";
        }
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

void ui_draw() {
    sappimgui_track_frame();
    if ImGui_BeginMainMenuBar() != 0 {
        if ImGui_BeginMenu("sokol-spine") != 0 {
            if ImGui_BeginMenu("Load") != 0 {
                for i32 i = 0; i < 5; i++ {
                    if spine_scenes[i].ui_name != null {
                        if ImGui_MenuItem(spine_scenes[i].ui_name, null, i == state.load_status.scene_index, true) != 0 {
                            load_spine_scene(i);
                        }
                    }
                }
                ImGui_EndMenu();
            }
            ImGui_MenuItem("Draw Bones", null, &state.ui.draw_bones_enabled, true);
            ImGui_MenuItem("Atlas...", null, &state.ui.atlas_open, true);
            ImGui_MenuItem("Bones...", null, &state.ui.bones_open, true);
            ImGui_MenuItem("Slots...", null, &state.ui.slots_open, true);
            ImGui_MenuItem("Anims...", null, &state.ui.anims_open, true);
            ImGui_MenuItem("Events...", null, &state.ui.events_open, true);
            ImGui_MenuItem("Skins...", null, &state.ui.skins_open, true);
            ImGui_MenuItem("IK Targets...", null, &state.ui.iktargets_open, true);
            ImGui_EndMenu();
        }
        sgimgui_draw_menu("sokol-gfx");
        sappimgui_draw_menu("sokol-app");
        if ImGui_BeginMenu("options") != 0 {
            if ImGui_RadioButton("Dark Theme", &ui_draw__theme, 0) != 0 {
                ImGui_StyleColorsDark(null);
            }
            if ImGui_RadioButton("Light Theme", &ui_draw__theme, 1) != 0 {
                ImGui_StyleColorsLight(null);
            }
            if ImGui_RadioButton("Classic Theme", &ui_draw__theme, 2) != 0 {
                ImGui_StyleColorsClassic(null);
            }
            ImGui_EndMenu();
        }
        ImGui_EndMainMenuBar();
    }
    var pos = ImVec2{30.0f, 30.0f};
    if state.ui.atlas_open != 0 {
        ImGui_SetNextWindowSize(ImVec2{300.0f, 330.0f}, ImGuiCond_Once);
        ImGui_SetNextWindowPos(pos, ImGuiCond_Once);
        if ImGui_Begin("Spine Atlas", &state.ui.atlas_open, 0) != 0 {
            if sspine_atlas_valid(state.atlas) == 0 {
                ImGui_Text("No Spine data loaded.");
            } else {
                i32 num_atlas_pages = sspine_num_atlas_pages(state.atlas);
                ImGui_Text("Num Pages: %d", num_atlas_pages);
                for i32 i = 0; i < num_atlas_pages; i++ {
                    sspine_atlas_page_info info = sspine_get_atlas_page_info(sspine_atlas_page_by_index(state.atlas, i));
                    ImGui_Separator();
                    ImGui_Text("Filename: %s", info.image.filename.cstr);
                    ImGui_Text("Width: %d", info.image.width);
                    ImGui_Text("Height: %d", info.image.height);
                    ImGui_Text("Premul Alpha: %s", info.image.premul_alpha == 0 ? "NO" : "YES");
                    ImGui_Text("Original Spine params:");
                    ImGui_Text("  Min Filter: %s", ui_sgfilter_name(info.image.min_filter));
                    ImGui_Text("  Mag Filter: %s", ui_sgfilter_name(info.image.mag_filter));
                    ImGui_Text("  Mipmap Filter: %s", ui_sgfilter_name(info.image.mipmap_filter));
                    ImGui_Text("  Wrap U: %s", ui_sgwrap_name(info.image.wrap_u));
                    ImGui_Text("  Wrap V: %s", ui_sgwrap_name(info.image.wrap_v));
                    ImGui_Text("Overrides:");
                    ImGui_Text("  Min Filter: %s", ui_sgfilter_name(info.overrides.min_filter));
                    ImGui_Text("  Mag Filter: %s", ui_sgfilter_name(info.overrides.mag_filter));
                    ImGui_Text("  Mipmap Filter: %s", ui_sgfilter_name(info.overrides.mipmap_filter));
                    ImGui_Text("  Wrap U: %s", ui_sgwrap_name(info.overrides.wrap_u));
                    ImGui_Text("  Wrap V: %s", ui_sgwrap_name(info.overrides.wrap_v));
                    ImGui_Text("  Premul Alpha Enabled: %s", info.overrides.premul_alpha_enabled != 0 ? "YES" : "NO");
                    ImGui_Text("  Premul Alpha Disabled: %s", info.overrides.premul_alpha_disabled != 0 ? "YES" : "NO");
                }
            }
        }
        ImGui_End();
    }
    pos.x += 20.0f;
    pos.y += 20.0f;
    if state.ui.bones_open != 0 {
        ImGui_SetNextWindowSize(ImVec2{300.0f, 300.0f}, ImGuiCond_Once);
        ImGui_SetNextWindowPos(pos, ImGuiCond_Once);
        if ImGui_Begin("Bones", &state.ui.bones_open, 0) != 0 {
            if sspine_instance_valid(state.instance) == 0 {
                ImGui_Text("No Spine data loaded.");
            } else {
                i32 num_bones = sspine_num_bones(state.skeleton);
                ImGui_Text("Num Bones: %d", num_bones);
                ImGui_BeginChild("bones_list", ImVec2{128.0f, 0.0f}, ImGuiChildFlags_Borders, ImGuiWindowFlags_None);
                for i32 i = 0; i < num_bones; i++ {
                    sspine_bone bone = sspine_bone_by_index(state.skeleton, i);
                    sspine_bone_info info = sspine_get_bone_info(bone);
                    ImGui_PushID(bone.index);
                    if ImGui_Selectable(info.name.cstr, sspine_bone_equal(state.ui.selected.bone, bone), 0, ImVec2{0.0f, 0.0f}) != 0 {
                        state.ui.selected.bone = bone;
                    }
                    ImGui_PopID();
                }
                ImGui_EndChild();
                ImGui_SameLine();
                if sspine_bone_valid(state.ui.selected.bone) != 0 {
                    sspine_bone_info info = sspine_get_bone_info(state.ui.selected.bone);
                    ImGui_BeginChild("bone_info", ImVec2{0.0f, 0.0f}, ImGuiChildFlags_None, ImGuiWindowFlags_None);
                    ImGui_Text("Index: %d", info.index);
                    ImGui_Text("Parent Bone: %s", sspine_bone_valid(info.parent_bone) != 0 ? sspine_get_bone_info(info.parent_bone).name.cstr : "---");
                    ImGui_Text("Name: %s", info.name.cstr);
                    ImGui_Text("Length: %.3f", info.length);
                    ImGui_Text("Pose Transform:");
                    ImGui_Text("  Position: %.3f,%.3f", info.pose.position.x, info.pose.position.y);
                    ImGui_Text("  Rotation: %.3f", info.pose.rotation);
                    ImGui_Text("  Scale: %.3f,%.3f", info.pose.scale.x, info.pose.scale.y);
                    ImGui_Text("  Shear: %.3f,%.3f", info.pose.shear.x, info.pose.shear.y);
                    ImGui_Text("Color: %.2f,%.2f,%.2f,%.2f", info.color.r, info.color.b, info.color.g, info.color.a);
                    ImGui_Text("Current Transform:");
                    sspine_bone_transform cur_tform = sspine_get_bone_transform(state.instance, state.ui.selected.bone);
                    ImGui_Text("  Position: %.3f,%.3f", cur_tform.position.x, cur_tform.position.y);
                    ImGui_Text("  Rotation: %.3f", cur_tform.rotation);
                    ImGui_Text("  Scale: %.3f,%.3f", cur_tform.scale.x, cur_tform.scale.y);
                    ImGui_Text("  Shear: %.3f,%.3f", cur_tform.shear.x, cur_tform.shear.y);
                    ImGui_EndChild();
                }
            }
        }
        ImGui_End();
    }
    pos.x += 20.0f;
    pos.y += 20.0f;
    if state.ui.slots_open != 0 {
        ImGui_SetNextWindowSize(ImVec2{300.0f, 300.0f}, ImGuiCond_Once);
        ImGui_SetNextWindowPos(pos, ImGuiCond_Once);
        if ImGui_Begin("Slots", &state.ui.slots_open, 0) != 0 {
            if sspine_instance_valid(state.instance) == 0 {
                ImGui_Text("No Spine data loaded.");
            } else {
                i32 num_slots = sspine_num_slots(state.skeleton);
                ImGui_Text("Num Slots: %d", num_slots);
                ImGui_BeginChild("slot_list", ImVec2{128.0f, 0.0f}, ImGuiChildFlags_Borders, ImGuiWindowFlags_None);
                for i32 i = 0; i < num_slots; i++ {
                    sspine_slot slot = sspine_slot_by_index(state.skeleton, i);
                    sspine_slot_info info = sspine_get_slot_info(slot);
                    ImGui_PushID(slot.index);
                    if ImGui_Selectable(info.name.cstr, sspine_slot_equal(state.ui.selected.slot, slot), 0, ImVec2{0.0f, 0.0f}) != 0 {
                        state.ui.selected.slot = slot;
                    }
                    ImGui_PopID();
                }
                ImGui_EndChild();
                ImGui_SameLine();
                if sspine_slot_valid(state.ui.selected.slot) != 0 {
                    sspine_slot_info slot_info = sspine_get_slot_info(state.ui.selected.slot);
                    sspine_bone_info bone_info = sspine_get_bone_info(slot_info.bone);
                    ImGui_BeginChild("slot_info", ImVec2{0.0f, 0.0f}, ImGuiChildFlags_None, ImGuiWindowFlags_None);
                    ImGui_Text("Index: %d", slot_info.index);
                    ImGui_Text("Name: %s", slot_info.name.cstr);
                    ImGui_Text("Attachment: %s", slot_info.attachment_name.valid != 0 ? slot_info.attachment_name.cstr : "-");
                    ImGui_Text("Bone Name: %s", bone_info.name.cstr);
                    ImGui_Text("Color: %.2f,%.2f,%.2f,%.2f", slot_info.color.r, slot_info.color.b, slot_info.color.g, slot_info.color.a);
                    ImGui_EndChild();
                }
            }
        }
        ImGui_End();
    }
    pos.x += 20.0f;
    pos.y += 20.0f;
    if state.ui.anims_open != 0 {
        ImGui_SetNextWindowSize(ImVec2{300.0f, 300.0f}, ImGuiCond_Once);
        ImGui_SetNextWindowPos(pos, ImGuiCond_Once);
        if ImGui_Begin("Anims", &state.ui.anims_open, 0) != 0 {
            if sspine_instance_valid(state.instance) == 0 {
                ImGui_Text("No Spine data loaded.");
            } else {
                i32 num_anims = sspine_num_anims(state.skeleton);
                ImGui_Text("Num Anims: %d", num_anims);
                ImGui_BeginChild("anim_list", ImVec2{128.0f, 0.0f}, ImGuiChildFlags_Borders, ImGuiWindowFlags_None);
                for i32 i = 0; i < num_anims; i++ {
                    sspine_anim anim = sspine_anim_by_index(state.skeleton, i);
                    sspine_anim_info info = sspine_get_anim_info(anim);
                    ImGui_PushID(anim.index);
                    if ImGui_Selectable(info.name.cstr, sspine_anim_equal(state.ui.selected.anim, anim), 0, ImVec2{0.0f, 0.0f}) != 0 {
                        state.ui.selected.anim = anim;
                        sspine_set_animation(state.instance, anim, 0, true);
                    }
                    ImGui_PopID();
                }
                ImGui_EndChild();
                ImGui_SameLine();
                if sspine_anim_valid(state.ui.selected.anim) != 0 {
                    sspine_anim_info info = sspine_get_anim_info(state.ui.selected.anim);
                    ImGui_BeginChild("anim_info", ImVec2{0.0f, 0.0f}, ImGuiChildFlags_None, ImGuiWindowFlags_None);
                    ImGui_Text("Index: %d", info.index);
                    ImGui_Text("Name: %s", info.name.cstr);
                    ImGui_Text("Duration: %.3f", info.duration);
                    ImGui_EndChild();
                }
            }
        }
        ImGui_End();
    }
    pos.x += 20.0f;
    pos.y += 20.0f;
    if state.ui.events_open != 0 {
        ImGui_SetNextWindowSize(ImVec2{300.0f, 300.0f}, ImGuiCond_Once);
        ImGui_SetNextWindowPos(pos, ImGuiCond_Once);
        if ImGui_Begin("Events", &state.ui.events_open, 0) != 0 {
            if sspine_skeleton_valid(state.skeleton) == 0 {
                ImGui_Text("No Spine data loaded");
            } else {
                i32 num_events = sspine_num_events(state.skeleton);
                ImGui_Text("Num Events: %d", num_events);
                ImGui_BeginChild("event_list", ImVec2{128.0f, 0.0f}, ImGuiChildFlags_Borders, ImGuiWindowFlags_None);
                for i32 i = 0; i < num_events; i++ {
                    sspine_event event = sspine_event_by_index(state.skeleton, i);
                    sspine_event_info info = sspine_get_event_info(event);
                    ImGui_PushID(event.index);
                    if ImGui_Selectable(info.name.cstr, sspine_event_equal(state.ui.selected.event, event), 0, ImVec2{0.0f, 0.0f}) != 0 {
                        state.ui.selected.event = event;
                    }
                    ImGui_PopID();
                }
                ImGui_EndChild();
                ImGui_SameLine();
                if sspine_event_valid(state.ui.selected.event) != 0 {
                    sspine_event_info info = sspine_get_event_info(state.ui.selected.event);
                    ImGui_BeginChild("event_info", ImVec2{0.0f, 0.0f}, ImGuiChildFlags_None, ImGuiWindowFlags_None);
                    ImGui_Text("Index: %d", info.index);
                    ImGui_Text("Name: %s", info.name.cstr);
                    ImGui_Text("Int Value: %d\n", info.int_value);
                    ImGui_Text("Float Value: %.3f\n", info.float_value);
                    ImGui_Text("String Value: %s", info.string_value.valid != 0 ? info.string_value.cstr : "NONE");
                    ImGui_Text("Audio Path: %s", info.audio_path.valid != 0 ? info.audio_path.cstr : "NONE");
                    ImGui_Text("Volume: %.3f", info.volume);
                    ImGui_Text("Balance: %.3f", info.balance);
                    ImGui_EndChild();
                }
            }
        }
        ImGui_End();
    }
    pos.x += 20.0f;
    pos.y += 20.0f;
    if state.ui.skins_open != 0 {
        ImGui_SetNextWindowSize(ImVec2{300.0f, 300.0f}, ImGuiCond_Once);
        ImGui_SetNextWindowPos(pos, ImGuiCond_Once);
        if ImGui_Begin("Skins", &state.ui.skins_open, 0) != 0 {
            if sspine_skeleton_valid(state.skeleton) == 0 {
                ImGui_Text("No Spine data loaded");
            } else {
                i32 num_skins = sspine_num_skins(state.skeleton);
                ImGui_Text("Num Skins: %d", num_skins);
                ImGui_BeginChild("skin_list", ImVec2{128.0f, 0.0f}, ImGuiChildFlags_Borders, ImGuiWindowFlags_None);
                for i32 i = 0; i < num_skins; i++ {
                    sspine_skin skin = sspine_skin_by_index(state.skeleton, i);
                    sspine_skin_info info = sspine_get_skin_info(skin);
                    ImGui_PushID(skin.index);
                    if ImGui_Selectable(info.name.cstr, sspine_skin_equal(state.ui.selected.skin, skin), 0, ImVec2{0.0f, 0.0f}) != 0 {
                        state.ui.selected.skin = skin;
                        sspine_set_skin(state.instance, skin);
                    }
                    ImGui_PopID();
                }
                ImGui_EndChild();
                ImGui_SameLine();
                if sspine_skin_valid(state.ui.selected.skin) != 0 {
                    sspine_skin_info info = sspine_get_skin_info(state.ui.selected.skin);
                    ImGui_BeginChild("skin_info", ImVec2{0.0f, 0.0f}, ImGuiChildFlags_None, ImGuiWindowFlags_None);
                    ImGui_Text("Index: %d", info.index);
                    ImGui_Text("Name: %s", info.name.cstr);
                    ImGui_EndChild();
                }
            }
        }
        ImGui_End();
    }
    pos.x += 20.0f;
    pos.y += 20.0f;
    if state.ui.iktargets_open != 0 {
        ImGui_SetNextWindowSize(ImVec2{300.0f, 300.0f}, ImGuiCond_Once);
        ImGui_SetNextWindowPos(pos, ImGuiCond_Once);
        if ImGui_Begin("IK Targets", &state.ui.iktargets_open, 0) != 0 {
            if sspine_skeleton_valid(state.skeleton) == 0 {
                ImGui_Text("No Spine data loaded");
            } else {
                i32 num_iktargets = sspine_num_iktargets(state.skeleton);
                ImGui_Text("Num IK Targets: %d", num_iktargets);
                ImGui_BeginChild("iktarget_list", ImVec2{128.0f, 0.0f}, ImGuiChildFlags_Borders, ImGuiWindowFlags_None);
                for i32 i = 0; i < num_iktargets; i++ {
                    sspine_iktarget iktarget = sspine_iktarget_by_index(state.skeleton, i);
                    sspine_iktarget_info info = sspine_get_iktarget_info(iktarget);
                    ImGui_PushID(iktarget.index);
                    if ImGui_Selectable(info.name.cstr, sspine_iktarget_equal(state.ui.selected.iktarget, iktarget), 0, ImVec2{0.0f, 0.0f}) != 0 {
                        state.ui.selected.iktarget = iktarget;
                    }
                    ImGui_PopID();
                }
                ImGui_EndChild();
                ImGui_SameLine();
                if sspine_iktarget_valid(state.ui.selected.iktarget) != 0 {
                    sspine_iktarget_info info = sspine_get_iktarget_info(state.ui.selected.iktarget);
                    ImGui_BeginChild("iktarget_info", ImVec2{0.0f, 0.0f}, ImGuiChildFlags_None, ImGuiWindowFlags_None);
                    ImGui_Text("Index: %d", info.index);
                    ImGui_Text("Name: %s", info.name.cstr);
                    ImGui_Text("Target Bone: %s", sspine_get_bone_info(info.target_bone).name.cstr);
                    ImGui_EndChild();
                }
            }
        }
        ImGui_End();
    }
    f64 triggered_event_fade_time = 1.0;
    if sspine_event_valid(state.ui.last_triggered_event.event) && state.ui.last_triggered_event.time + triggered_event_fade_time > state.ui.cur_time {
        sspine_event event = state.ui.last_triggered_event.event;
        sspine_event_info event_info = sspine_get_event_info(event);
        f64 event_time = state.ui.last_triggered_event.time;
        if event_info.valid != 0 {
            var alpha = cast(f32, 1.0 - (state.ui.cur_time - event_time) / triggered_event_fade_time);
            ImGui_SetNextWindowBgAlpha(alpha);
            ImGui_SetNextWindowPos(ImVec2{sapp_widthf() * 0.5f, sapp_heightf() - 50.0f}, ImGuiCond_Always, ImVec2{0.5f, 0.5f});
            ImGui_PushStyleColor(ImGuiCol_WindowBg, 0xFF0000FF);
            if ImGui_Begin("Triggered Events", null, ImGuiWindowFlags_AlwaysAutoResize | ImGuiWindowFlags_NoDecoration | ImGuiWindowFlags_NoFocusOnAppearing | ImGuiWindowFlags_NoNav) != 0 {
                ImGui_Text("%s: %.3f (age: %.3f)", event_info.name.cstr, event_time, state.ui.cur_time - event_time);
            }
            ImGui_End();
            ImGui_PopStyleColor();
        }
    }
    sgimgui_draw();
    sappimgui_draw();
}

void draw_bones() {
    if sspine_instance_valid(state.instance) == 0 {
        return;
    }
    sspine_mat4 proj = sspine_layer_transform_to_mat4(&state.layer_transform);
    sgl_defaults();
    sgl_matrix_mode_projection();
    sgl_load_matrix(proj.m);
    sgl_c3f(0.0f, 1.0f, 0.0f);
    sgl_begin_lines();
    i32 num_bones = sspine_num_bones(state.skeleton);
    for i32 i = 0; i < num_bones; i++ {
        sspine_bone bone = sspine_bone_by_index(state.skeleton, i);
        sspine_bone parent_bone = sspine_get_bone_info(bone).parent_bone;
        if sspine_bone_valid(parent_bone) != 0 {
            sspine_vec2 p0 = sspine_get_bone_world_position(state.instance, parent_bone);
            sspine_vec2 p1 = sspine_get_bone_world_position(state.instance, bone);
            sgl_v2f(p0.x, p0.y);
            sgl_v2f(p1.x, p1.y);
        }
    }
    sgl_end();
}
}

sapp_desc __sapp_sample_main() {
    return sapp_desc{
        .init_cb = init,
        .frame_cb = frame,
        .cleanup_cb = cleanup,
        .event_cb = input,
        .width = 800,
        .height = 600,
        .sample_count = 4,
        .window_title = "spine-inspector-sapp.mc",
        .icon = sapp_icon_desc{.sokol_default = true},
        .logger = sapp_logger{.func = slog_func},
    };
}
private { i32 ui_draw__theme = 0; }
