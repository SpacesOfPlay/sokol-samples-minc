import dbgui;
import imgui_compat;
import sokol_gfx_imgui;
import sokol_app_imgui;
import sokol_shape;
import sokol_time;
import vecmath;

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

// box3d comes from the published minc port, not a transpile of the C
// sources: the sample's b3* calls are extern-declared from box3d.h and
// resolve against lib/box3d.mc.
import box3d;

// vecmath's vm_* are C11 _Generic macros that dispatch on argument
// type. A manifest [defines] entry can only bind one name to one
// concrete function, which breaks as soon as a sample uses the same
// vm_* at two types (box3d-simple: vm_mul on mat44xmat44 and on
// vec3xf32). Leave the names unexpanded instead and let minc's
// overload resolution stand in for _Generic.
//
// Add arities as samples need them; an unlisted combination shows up
// as a plain unresolved overload.

mat44_t vm_mul(mat44_t a, mat44_t b) { return mat44_mul_mat44(a, b); }
vec3_t vm_add(vec3_t a, vec3_t b)    { return vec3_add(a, b); }
f32 vm_clamp(f32 v, f32 lo, f32 hi)  { return vecmath_clamp(v, lo, hi); }
f32 vm_cos(f32 x)                    { return vecmath_cos(x); }
f32 vm_sin(f32 x)                    { return vecmath_sin(x); }
vec3_t vm_mul(vec3_t v, f32 s)       { return vec3_mulf(v, s); }
vec3_t vm_sub(vec3_t v, f32 s)       { return vec3_subf(v, s); }
vec3_t vm_normalize(vec3_t v)        { return vec3_normalize(v); }
mat44_t vm_transpose(mat44_t m)      { return mat44_transpose(m); }
f32 vm_radians(f32 x)                { return vecmath_radians(x); }

// box3d-simple-sapp.glsl, hand-ported. Four programs over three
// vertex shaders: an instanced depth-only shadow pass, and a lit
// display pass in both a single-mesh and an instanced form, which
// share one fragment shader (PCF shadow lookup through a comparison
// sampler).
//
// The instanced passes carry the body transform as three rows of
// float4 and reconstruct the world position with dots, so no matrix
// per instance is uploaded.

struct Ub_shadow_inst_vs_params {
    float4x4 light_view_proj;
}

struct Ub_display_vs_params {
    float4x4 mvp;
    float4x4 model;
    float4x4 light_mvp;
    float4 diff_color;
}

@gpu_layout
struct Ub_display_inst_vs_params {
    float4x4 view_proj;
    float4x4 light_view_proj;
    f32 awake_filter;
}

@gpu_layout
struct Ub_display_fs_params {
    float3 light_dir;
    float3 eye_pos;
}

struct Box3DSimpleSappShadowOut {
    float4 pos;
}

// display_vs and display_inst_vs both feed display_fs, so they share
// one output shape.
struct Box3DSimpleSappDisplayOut {
    float4 pos;
    float3 color;
    float4 light_proj_pos;
    float4 world_pos;
    float3 world_nrm;
}

// --- shared helpers ---------------------------------------------------

float4 box3d_simple_gamma(float4 c) {
    f32 p = 1.0f / 2.2f;
    return float4{pow(c.x, p), pow(c.y, p), pow(c.z, p), c.w};
}

// --- shadow pass: depth only, instanced -------------------------------

@shader vertex
Box3DSimpleSappShadowOut box3d_simple_sapp_shadow_inst_vs(
    @attr(0) float4 pos,
    @attr(1) float4 inst_xxxx,
    @attr(2) float4 inst_yyyy,
    @attr(3) float4 inst_zzzz,
    @uniform(0) Ub_shadow_inst_vs_params p
) {
    float4 world_pos = float4{dot(pos, inst_xxxx), dot(pos, inst_yyyy),
                              dot(pos, inst_zzzz), 1.0f};
    Box3DSimpleSappShadowOut o;
    o.pos = mul(p.light_view_proj, world_pos);
    // GL clip-space fixup: clip z is [0,1] by convention, GL expects [-1,1].
    when gpu(opengl) || gpu(opengles) {
        o.pos.z = o.pos.z * 2.0f - o.pos.w;
    }
    return o;
}

@shader fragment
float4 box3d_simple_sapp_shadow_fs(Box3DSimpleSappShadowOut input) {
    // depth-only pass; the pipeline declares no color target
    return float4{0.0f, 0.0f, 0.0f, 1.0f};
}

// --- display pass, single mesh ---------------------------------------

@shader vertex
Box3DSimpleSappDisplayOut box3d_simple_sapp_display_vs(
    @attr(0) float4 pos,
    @attr(1) float3 normal,
    @uniform(0) Ub_display_vs_params p
) {
    Box3DSimpleSappDisplayOut o;
    o.pos = mul(p.mvp, pos);
    o.light_proj_pos = mul(p.light_mvp, pos);
    // upstream's `#if !SOKOL_GLSL`: the GL backends already agree on
    // clip-space y, the others need the flip
    when !gpu(opengl) && !gpu(opengles) {
        o.light_proj_pos.y = 0.0f - o.light_proj_pos.y;
    }
    o.world_pos = mul(p.model, pos);
    float4 n4 = mul(p.model, float4{normal.x, normal.y, normal.z, 0.0f});
    o.world_nrm = float3{n4.x, n4.y, n4.z};
    o.color = float3{p.diff_color.x, p.diff_color.y, p.diff_color.z};
    return o;
}

// --- display pass, instanced -----------------------------------------

@shader vertex
Box3DSimpleSappDisplayOut box3d_simple_sapp_display_inst_vs(
    @attr(0) float4 pos,
    @attr(1) float3 normal,
    @attr(2) float4 inst_xxxx,
    @attr(3) float4 inst_yyyy,
    @attr(4) float4 inst_zzzz,
    @attr(5) float4 inst_color,
    @uniform(0) Ub_display_inst_vs_params p
) {
    float4 wp = float4{dot(pos, inst_xxxx), dot(pos, inst_yyyy),
                       dot(pos, inst_zzzz), 1.0f};
    float4 nrm4 = float4{normal.x, normal.y, normal.z, 0.0f};
    float3 wn = float3{dot(nrm4, inst_xxxx), dot(nrm4, inst_yyyy),
                       dot(nrm4, inst_zzzz)};

    Box3DSimpleSappDisplayOut o;
    o.pos = mul(p.view_proj, wp);
    o.light_proj_pos = mul(p.light_view_proj, wp);
    when !gpu(opengl) && !gpu(opengles) {
        o.light_proj_pos.y = 0.0f - o.light_proj_pos.y;
    }
    o.world_pos = wp;
    o.world_nrm = wn;
    // sleeping bodies fade toward grey
    f32 t = p.awake_filter * inst_color.w;
    o.color = float3{mix(inst_color.x, 0.25f, t),
                     mix(inst_color.y, 0.25f, t),
                     mix(inst_color.z, 0.25f, t)};
    return o;
}

// --- shared display fragment shader -----------------------------------

@shader fragment
float4 box3d_simple_sapp_display_fs(
    Box3DSimpleSappDisplayOut input,
    @uniform(1) Ub_display_fs_params p,
    @texture(0) Texture2D shadow_map,
    @sampler(0) Sampler shadow_sampler
) {
    f32 spec_power = 16.0f;
    f32 ambient_intensity = 0.25f;

    float3 l = p.light_dir;
    float3 n = normalize(input.world_nrm);
    f32 n_dot_l = dot(n, l);

    float4 c;
    if n_dot_l > 0.0f {
        float3 light_pos = float3{input.light_proj_pos.x / input.light_proj_pos.w,
                                  input.light_proj_pos.y / input.light_proj_pos.w,
                                  input.light_proj_pos.z / input.light_proj_pos.w};
        f32 depth_bias = max(0.0001f * (1.0f - n_dot_l), 0.00001f);
        float3 sm_pos = float3{(light_pos.x + 1.0f) * 0.5f,
                               (light_pos.y + 1.0f) * 0.5f,
                               light_pos.z + depth_bias};

        // 5x5 PCF over the comparison sampler
        int2 sm_size = texture_size(shadow_map);
        f32 s = 0.0f;
        for i32 x = 0 - 2; x <= 2; x++ {
            for i32 y = 0 - 2; y <= 2; y++ {
                float2 uv = float2{sm_pos.x + cast(f32, x) / cast(f32, sm_size.x),
                                   sm_pos.y + cast(f32, y) / cast(f32, sm_size.y)};
                s = s + sample_cmp(shadow_map, shadow_sampler, uv, sm_pos.z);
            }
        }
        s = s / 25.0f;

        f32 diff_intensity = max(n_dot_l * s, 0.0f);
        float3 v = normalize(float3{p.eye_pos.x - input.world_pos.x,
                                    p.eye_pos.y - input.world_pos.y,
                                    p.eye_pos.z - input.world_pos.z});
        float3 r = reflect(float3{0.0f - l.x, 0.0f - l.y, 0.0f - l.z}, n);
        f32 r_dot_v = max(dot(r, v), 0.0f);
        f32 spec_intensity = pow(r_dot_v, spec_power) * n_dot_l * s;

        f32 k = diff_intensity + ambient_intensity;
        c = float4{spec_intensity + k * input.color.x,
                   spec_intensity + k * input.color.y,
                   spec_intensity + k * input.color.z,
                   1.0f};
    } else {
        c = float4{input.color.x * ambient_intensity,
                   input.color.y * ambient_intensity,
                   input.color.z * ambient_intensity,
                   1.0f};
    }
    return box3d_simple_gamma(c);
}

enum __enum_ATTR_shadow_instanced_pos {
    ATTR_shadow_instanced_pos = 0,
    ATTR_shadow_instanced_inst_xxxx = 1,
    ATTR_shadow_instanced_inst_yyyy = 2,
    ATTR_shadow_instanced_inst_zzzz = 3,
    ATTR_display_pos = 0,
    ATTR_display_normal = 1,
    ATTR_display_instanced_pos = 0,
    ATTR_display_instanced_normal = 1,
    ATTR_display_instanced_inst_xxxx = 2,
    ATTR_display_instanced_inst_yyyy = 3,
    ATTR_display_instanced_inst_zzzz = 4,
    ATTR_display_instanced_inst_color = 5,
    UB_shadow_inst_vs_params = 0,
    UB_display_vs_params = 0,
    UB_display_fs_params = 1,
    UB_display_inst_vs_params = 0,
    VIEW_shadow_map = 0,
    SMP_shadow_sampler = 0,
    __shim_end = 255,
}

type __arr_f32_4 = f32[4];
/*
    Quick'n'dirty Maya-style camera. Include after vecmath.h
    and sokol_app.h
*/
struct camera_desc_t {
    f32 min_dist;
    f32 max_dist;
    f32 min_lat;
    f32 max_lat;
    f32 distance;
    f32 latitude;
    f32 longitude;
    f32 fov;
    f32 nearz;
    f32 farz;
    vec3_t center;
}

struct camera_t {
    f32 min_dist;
    f32 max_dist;
    f32 min_lat;
    f32 max_lat;
    f32 distance;
    f32 latitude;
    f32 longitude;
    f32 fov;
    f32 nearz;
    f32 farz;
    vec3_t center;
    vec3_t eye_pos;
    mat44_t view;
    mat44_t proj;
    mat44_t view_proj;
}

// Replaces the sokol-shdc generated box3d-simple-sapp.glsl.h.
struct shadow_inst_vs_params_t {
    mat44_t light_view_proj;
}

struct display_vs_params_t {
    mat44_t mvp;
    mat44_t model;
    mat44_t light_mvp;
    vec4_t diff_color;
}

struct display_inst_vs_params_t {
    mat44_t view_proj;
    mat44_t light_view_proj;
    f32 awake_filter;
    u8[12] _pad_tail;
}

struct display_fs_params_t {
    vec3_t light_dir;
    u8[4] _pad_12;
    vec3_t eye_pos;
    u8[4] _pad_tail;
}

struct instdata_t {
    vec4_t xxxx;
    vec4_t yyyy;
    vec4_t zzzz;
    vec4_t color;
}

private struct state_t {
    sg_buffer vbuf;
    sg_buffer ibuf;
    sg_buffer box_inst_buf;
    sg_buffer ball_inst_buf;
    struct {
        sshape_element_range_t plane;
        sshape_element_range_t ball;
        sshape_element_range_t box;
    } shapes;
    struct {
        sg_pass pass;
        sg_view tex_view;
        sg_sampler smp;
        sg_pipeline inst_pip;
    } shadow;
    struct {
        sg_pass_action pass_action;
        sg_pipeline pip;
        sg_pipeline inst_pip;
    } display;
    f64 spawn_timer;
    camera_t camera;
    vec3_t light_pos;
    mat44_t light_view_proj;
    mat44_t view_proj;
    struct {
        i64 physics_world_step_time;
        i64 copy_transforms_time;
        i32 sub_steps_per_frame;
        i32 num_awake_bodies;
    } profiling;
    struct {
        bool show_sleeping;
    } ui;
    struct {
        b3WorldId world;
        b3BodyId ground;
        i64 tick_error_us;
        i32 num_bodies;
        b3BodyId[1024] bodies;
    } physics;
    struct {
        i32 num_boxes;
        i32 num_balls;
        instdata_t[513] boxes;
        instdata_t[513] balls;
    } inst_data;
}

private {
f32 _cam_def(f32 val, f32 def) {
    return val == 0.0f ? def : val;
}

/* initialize to default parameters */
void cam_init(camera_t* cam, camera_desc_t* desc) {
    memset(cam, 0, cast(u64, sizeof(camera_t)));
    cam.min_dist = _cam_def(desc.min_dist, 2.0f);
    cam.max_dist = _cam_def(desc.max_dist, 30.0f);
    cam.min_lat = _cam_def(desc.min_lat, -85.0f);
    cam.max_lat = _cam_def(desc.max_lat, 85.0f);
    cam.distance = _cam_def(desc.distance, 5.0f);
    cam.center = desc.center;
    cam.latitude = desc.latitude;
    cam.longitude = desc.longitude;
    cam.fov = _cam_def(desc.fov, 60.0f);
    cam.nearz = _cam_def(desc.nearz, 0.01f);
    cam.farz = _cam_def(desc.farz, 100.0f);
}

/* feed mouse movement */
void cam_orbit(camera_t* cam, f32 dx, f32 dy) {
    cam.longitude -= dx;
    if cam.longitude < 0.0f {
        cam.longitude += 360.0f;
    }
    if cam.longitude > 360.0f {
        cam.longitude -= 360.0f;
    }
    cam.latitude = vm_clamp(cam.latitude + dy, cam.min_lat, cam.max_lat);
}

/* feed zoom (mouse wheel) input */
void cam_zoom(camera_t* cam, f32 d) {
    cam.distance = vm_clamp(cam.distance + d * cam.distance * 0.1f, cam.min_dist, cam.max_dist);
}

vec3_t _cam_euclidean(f32 latitude, f32 longitude) {
    f32 lat = vm_radians(latitude);
    f32 lng = vm_radians(longitude);
    return vec3(vm_cos(lat) * vm_sin(lng), vm_sin(lat), vm_cos(lat) * vm_cos(lng));
}

/* update the view, proj and view_proj matrix */
void cam_update(camera_t* cam, i32 fb_width, i32 fb_height) {
    var w = cast(f32, fb_width);
    var h = cast(f32, fb_height);
    cam.eye_pos = vm_add(cam.center, vec3_mulf(_cam_euclidean(cam.latitude, cam.longitude), cam.distance));
    cam.view = mat44_look_at_rh(cam.eye_pos, cam.center, vec3(0.0f, 1.0f, 0.0f));
    cam.proj = mat44_perspective_fov_rh(vm_radians(cam.fov), w / h, cam.nearz, cam.farz);
    cam.view_proj = vm_mul(cam.view, cam.proj);
}

/* handle sokol-app input events */
void cam_handle_event(camera_t* cam, sapp_event* ev) {
    switch ev.type {
        case SAPP_EVENTTYPE_MOUSE_DOWN: {
            if ev.mouse_button == SAPP_MOUSEBUTTON_LEFT {
                sapp_lock_mouse(true);
            }
        }
        case SAPP_EVENTTYPE_MOUSE_UP: {
            if ev.mouse_button == SAPP_MOUSEBUTTON_LEFT {
                sapp_lock_mouse(false);
            }
        }
        case SAPP_EVENTTYPE_MOUSE_SCROLL: {
            cam_zoom(cam, ev.scroll_y * 0.5f);
        }
        case SAPP_EVENTTYPE_MOUSE_MOVE: {
            if sapp_mouse_locked() != 0 {
                cam_orbit(cam, ev.mouse_dx * 0.25f, ev.mouse_dy * 0.25f);
            }
        }
        default: {
        }
    }
}
state_t state;
}

private {
void init() {
    stm_setup();
    sg_setup(&sg_desc{.environment = sglue_environment(), .logger = sg_logger{.func = slog_func}});
    sgimgui_setup(&sgimgui_desc_t{});
    sappimgui_setup();
    simgui_setup(&simgui_desc_t{.logger = simgui_logger_t{.func = slog_func}});
    cam_init(&state.camera, &camera_desc_t{
        .center = vec3(0.0f, 0.0f, 0.0f),
        .latitude = 25.0f,
        .longitude = 225.0f,
        .distance = 50.0f,
        .max_dist = 300.0f,
    });
    physics_init();
    gfx_init();
}

void frame() {
    cam_update(&state.camera, sapp_width(), sapp_height());
    state.spawn_timer -= sapp_frame_duration();
    if state.spawn_timer <= 0.0 {
        state.spawn_timer += 0.25;
        physics_add_body();
    }
    physics_update();
    update_instance_buffers();
    update_matrices();
    ui_draw();
    sg_begin_pass(&state.shadow.pass);
    draw_instanced_shapes_shadow_pass(&state.shapes.box, state.box_inst_buf, state.inst_data.num_boxes);
    draw_instanced_shapes_shadow_pass(&state.shapes.ball, state.ball_inst_buf, state.inst_data.num_balls);
    sg_end_pass();
    sg_begin_pass(&sg_pass{.action = state.display.pass_action, .swapchain = sglue_swapchain()});
    draw_shape_display_pass(&state.shapes.plane, mat44_identity(), vec4(0.5f, 0.5f, 0.5f, 1.0f));
    draw_instanced_shapes_display_pass(&state.shapes.box, state.box_inst_buf, state.inst_data.num_boxes);
    draw_instanced_shapes_display_pass(&state.shapes.ball, state.ball_inst_buf, state.inst_data.num_balls);
    simgui_render();
    sg_end_pass();
    sg_commit();
}

void cleanup() {
    physics_cleanup();
    sgimgui_shutdown();
    sappimgui_shutdown();
    simgui_shutdown();
    sg_shutdown();
}

void input(sapp_event* ev) {
    sappimgui_track_event(ev);
    if simgui_handle_event(ev) != 0 {
        return;
    }
    cam_handle_event(&state.camera, ev);
}

void update_matrices() {
    mat44_t light_view = mat44_look_at_rh(state.light_pos, vec3(0.0f, 0.0f, 0.0f), vec3(0.0f, 1.0f, 0.0f));
    mat44_t light_proj = mat44_ortho_off_center_rh(-100.0f, 100.0f, -100.0f, 100.0f, 1.0f, 250.0f);
    state.light_view_proj = vm_mul(light_view, light_proj);
    mat44_t proj = mat44_perspective_fov_rh(vm_radians(60.0f), sapp_widthf() / sapp_heightf(), 0.1f, 500.0f);
    mat44_t view = mat44_look_at_rh(state.camera.eye_pos, vec3(0.0f, 0.0f, 0.0f), vec3(0.0f, 1.0f, 0.0f));
    state.view_proj = vm_mul(view, proj);
}

void update_instance_buffers() {
    if state.inst_data.num_boxes > 0 {
        sg_update_buffer(state.box_inst_buf, &sg_range{
            .ptr = cast(void*, &state.inst_data.boxes[0]),
            .size = cast(u64, sizeof(instdata_t)) * cast(u64, state.inst_data.num_boxes),
        });
    }
    if state.inst_data.num_balls > 0 {
        sg_update_buffer(state.ball_inst_buf, &sg_range{
            .ptr = cast(void*, &state.inst_data.balls[0]),
            .size = cast(u64, sizeof(instdata_t)) * cast(u64, state.inst_data.num_balls),
        });
    }
}

void draw_instanced_shapes_shadow_pass(sshape_element_range_t* shape, sg_buffer inst_buf, i32 num_instances) {
    if num_instances == 0 {
        return;
    }
    var vs_params = shadow_inst_vs_params_t{.light_view_proj = state.light_view_proj};
    sg_apply_pipeline(state.shadow.inst_pip);
    sg_apply_bindings(&sg_bindings{
        .vertex_buffers = {
            state.vbuf,
            inst_buf,
            sg_buffer{},
            sg_buffer{},
            sg_buffer{},
            sg_buffer{},
            sg_buffer{},
            sg_buffer{},
        },
        .index_buffer = state.ibuf,
    });
    sg_apply_uniforms(UB_shadow_inst_vs_params, &sg_range{&vs_params, sizeof(vs_params)});
    sg_draw(shape.base_element, shape.num_elements, num_instances);
}

void draw_shape_display_pass(sshape_element_range_t* shape, mat44_t model, vec4_t color) {
    var vs_params = display_vs_params_t{
        .model = model,
        .mvp = vm_mul(model, state.view_proj),
        .light_mvp = vm_mul(model, state.light_view_proj),
        .diff_color = color,
    };
    var fs_params = display_fs_params_t{
        .eye_pos = state.camera.eye_pos,
        .light_dir = vm_normalize(state.light_pos),
    };
    sg_apply_pipeline(state.display.pip);
    sg_apply_bindings(&sg_bindings{
        .vertex_buffers[0] = state.vbuf,
        .index_buffer = state.ibuf,
        .views[0] = state.shadow.tex_view,
        .samplers[0] = state.shadow.smp,
    });
    sg_apply_uniforms(UB_display_vs_params, &sg_range{&vs_params, sizeof(vs_params)});
    sg_apply_uniforms(UB_display_fs_params, &sg_range{&fs_params, sizeof(fs_params)});
    sg_draw(shape.base_element, shape.num_elements, 1);
}

void draw_instanced_shapes_display_pass(sshape_element_range_t* shape, sg_buffer inst_buf, i32 num_instances) {
    if num_instances == 0 {
        return;
    }
    var vs_params = display_inst_vs_params_t{
        .view_proj = state.view_proj,
        .light_view_proj = state.light_view_proj,
        .awake_filter = state.ui.show_sleeping != 0 ? 1.0f : 0.0f,
    };
    var fs_params = display_fs_params_t{
        .eye_pos = state.camera.eye_pos,
        .light_dir = vm_normalize(state.light_pos),
    };
    sg_apply_pipeline(state.display.inst_pip);
    sg_apply_bindings(&sg_bindings{
        .vertex_buffers = {
            state.vbuf,
            inst_buf,
            sg_buffer{},
            sg_buffer{},
            sg_buffer{},
            sg_buffer{},
            sg_buffer{},
            sg_buffer{},
        },
        .index_buffer = state.ibuf,
        .views[0] = state.shadow.tex_view,
        .samplers[0] = state.shadow.smp,
    });
    sg_apply_uniforms(UB_display_inst_vs_params, &sg_range{&vs_params, sizeof(vs_params)});
    sg_apply_uniforms(UB_display_fs_params, &sg_range{&fs_params, sizeof(fs_params)});
    sg_draw(shape.base_element, shape.num_elements, num_instances);
}

void physics_init() {
    b3WorldDef world_def = b3DefaultWorldDef();
    state.physics.world = b3CreateWorld(&world_def);
    b3BodyDef ground_body_def = b3DefaultBodyDef();
    ground_body_def.position = b3Vec3{0.0f, -10.0f, 0.0f};
    state.physics.ground = b3CreateBody(state.physics.world, &ground_body_def);
    f32 hs = 200.0f * 0.5f;
    b3BoxHull ground_box = b3MakeBoxHull(hs, 10.0f, hs);
    b3ShapeDef ground_shape_def = b3DefaultShapeDef();
    b3CreateHullShape(state.physics.ground, &ground_shape_def, &ground_box.base);
}

void copy_instance_transform(instdata_t* inst_data, b3WorldTransform* tf) {
    mat44_t rm = mat44_from_quat(vec4(tf.q.v.x, tf.q.v.y, tf.q.v.z, tf.q.s));
    mat44_t tm = mat44_translation(tf.p.x, tf.p.y, tf.p.z);
    mat44_t m = vm_transpose(vm_mul(rm, tm));
    inst_data.xxxx = m.x;
    inst_data.yyyy = m.y;
    inst_data.zzzz = m.z;
}

void physics_update() {
    f64 dt_sec = sapp_frame_duration();
    var dt_usec = cast(i64, dt_sec * 1000000.0);
    state.physics.tick_error_us += dt_usec;
    var num_sub_steps = cast(i64, cast(u64, state.physics.tick_error_us) / cast(u64, 1.0 / 250.0 * 1000000.0));
    state.physics.tick_error_us -= cast(i64, cast(u64, num_sub_steps) * cast(u64, 1.0 / 250.0 * 1000000.0));
    u64 t = stm_now();
    b3World_Step(state.physics.world, cast(f32, dt_sec), cast(i32, num_sub_steps));
    state.profiling.physics_world_step_time = cast(i64, stm_since(t));
    state.profiling.sub_steps_per_frame = cast(i32, num_sub_steps);
    t = stm_now();
    b3BodyEvents events = b3World_GetBodyEvents(state.physics.world);
    for i32 i = 0; i < events.moveCount; i++ {
        b3BodyMoveEvent* ev = &events.moveEvents[i];
        var inst_data = cast(instdata_t*, ev.userData);
        copy_instance_transform(inst_data, &ev.transform);
    }
    state.profiling.copy_transforms_time = cast(i64, stm_since(t));
    state.profiling.num_awake_bodies = b3World_GetAwakeBodyCount(state.physics.world);
    if state.ui.show_sleeping != 0 {
        for i32 i = 0; i < state.physics.num_bodies; i++ {
            var inst_data = cast(instdata_t*, b3Body_GetUserData(state.physics.bodies[i]));
            if b3Body_IsAwake(state.physics.bodies[i]) != 0 {
                inst_data.color.w = 0.0f;
            } else {
                inst_data.color.w = 1.0f;
            }
        }
    }
}

u32 xorshift32() {
    xorshift32__x ^= xorshift32__x << 13;
    xorshift32__x ^= xorshift32__x >> 17;
    xorshift32__x ^= xorshift32__x << 5;
    return xorshift32__x;
}

vec3_t rand_uvec3() {
    u32 c = xorshift32();
    f32 x = cast(f32, c & 255) / 255.0f;
    f32 y = cast(f32, c >> 8 & 255) / 255.0f;
    f32 z = cast(f32, c >> 16 & 255) / 255.0f;
    return vec3_t{x, y, z};
}

vec3_t rand_ivec3() {
    vec3_t v = rand_uvec3();
    return vm_mul(vm_sub(v, 0.5f), 2.0f);
}

bool physics_is_box(i32 idx) {
    return (idx & 1) == 0;
}

void physics_add_body() {
    i32 idx = state.physics.num_bodies;
    if idx >= 1024 {
        return;
    }
    instdata_t* inst_data = null;
    if physics_is_box(idx) != 0 {
        inst_data = &state.inst_data.boxes[state.inst_data.num_boxes++];
    } else {
        inst_data = &state.inst_data.balls[state.inst_data.num_balls++];
    }
    vec3_t pos = vec3(0.0f, 15.0f, 0.0f);
    b3BodyDef body_def = b3DefaultBodyDef();
    body_def.type = b3_dynamicBody;
    body_def.position = b3Vec3{pos.x, pos.y, pos.z};
    body_def.userData = cast(void*, inst_data);
    b3BodyId body = b3CreateBody(state.physics.world, &body_def);
    b3ShapeDef shape_def = b3DefaultShapeDef();
    shape_def.density = 1.0f;
    shape_def.baseMaterial.restitution = 0.25f;
    if physics_is_box(idx) != 0 {
        b3BoxHull hull = b3MakeCubeHull(1.5f * 0.5f);
        b3CreateHullShape(body, &shape_def, &hull.base);
    } else {
        shape_def.baseMaterial.rollingResistance = 0.05f;
        var sphere = b3Sphere{.radius = 1.0f};
        b3CreateSphereShape(body, &shape_def, &sphere);
    }
    state.physics.bodies[idx] = body;
    vec3_t c = rand_uvec3();
    inst_data.color = vec4(c.x, c.y, c.z, 1.0f);
    b3WorldTransform tf = b3Body_GetTransform(body);
    copy_instance_transform(inst_data, &tf);
    vec3_t v = rand_ivec3();
    vec3_t li = vm_mul(vm_normalize(vec3(v.x, v.y + 10.0f, v.z)), 75.0f);
    b3Body_ApplyLinearImpulseToCenter(body, b3Vec3{li.x, li.y, li.z}, true);
    v = rand_ivec3();
    vec3_t ai = vm_mul(v, 5.0f);
    b3Body_ApplyAngularImpulse(body, b3Vec3{ai.x, ai.y, ai.z}, true);
    state.physics.num_bodies += 1;
}

void physics_cleanup() {
    b3DestroyWorld(state.physics.world);
}

void gfx_init() {
    state.light_pos = vec3(50.0f, 100.0f, -75.0f);
    state.display.pass_action = sg_pass_action{
        .colors[0] = {.load_action = SG_LOADACTION_CLEAR, .clear_value = {0.2f, 0.4f, 0.8f, 1.0f}},
    };
    noinit u8[98304] vertices;
    noinit u16[4096] indices;
    var shp = sshape_state_t{
        .disable = sshape_optional_components_t{.texcoords = true, .colors = true},
        .vertices = sshape_buffer_state_t{.buffer = sshape_range_t{&vertices, sizeof(vertices)}},
        .indices = sshape_buffer_state_t{.buffer = sshape_range_t{&indices, sizeof(indices)}},
    };
    sshape_build_plane(&shp, &sshape_plane_t{.width = 200.0f, .depth = 200.0f});
    state.shapes.plane = sshape_element_range(&shp);
    sshape_build_sphere(&shp, &sshape_sphere_t{.radius = 1.0f, .slices = 15, .stacks = 11});
    state.shapes.ball = sshape_element_range(&shp);
    sshape_build_box(&shp, &sshape_box_t{.width = 1.5f, .height = 1.5f, .depth = 1.5f});
    state.shapes.box = sshape_element_range(&shp);
    sg_buffer_desc vbuf_desc = sshape_vertex_buffer_desc(&shp);
    sg_buffer_desc ibuf_desc = sshape_index_buffer_desc(&shp);
    state.vbuf = sg_make_buffer(&vbuf_desc);
    state.ibuf = sg_make_buffer(&ibuf_desc);
    state.display.pip = sg_make_pipeline(&sg_pipeline_desc{
        .shader = sokol_make_shader(&box3d_simple_sapp_display_vs_shader, &box3d_simple_sapp_display_fs_shader),
        .layout = sg_vertex_layout_state{
            .buffers[0] = sshape_vertex_buffer_layout_state(&shp),
            .attrs = {
                sshape_position_vertex_attr_state(&shp),
                sshape_normal_vertex_attr_state(&shp),
                sg_vertex_attr_state{},
                sg_vertex_attr_state{},
                sg_vertex_attr_state{},
                sg_vertex_attr_state{},
                sg_vertex_attr_state{},
                sg_vertex_attr_state{},
                sg_vertex_attr_state{},
                sg_vertex_attr_state{},
                sg_vertex_attr_state{},
                sg_vertex_attr_state{},
                sg_vertex_attr_state{},
                sg_vertex_attr_state{},
                sg_vertex_attr_state{},
                sg_vertex_attr_state{},
            },
        },
        .depth = sg_depth_state{.write_enabled = true, .compare = SG_COMPAREFUNC_LESS_EQUAL},
        .index_type = SG_INDEXTYPE_UINT16,
        .cull_mode = SG_CULLMODE_BACK,
        .label = "display-pipeline",
    });
    state.display.inst_pip = sg_make_pipeline(&sg_pipeline_desc{
        .shader = sokol_make_shader(&box3d_simple_sapp_display_inst_vs_shader, &box3d_simple_sapp_display_fs_shader),
        .layout = sg_vertex_layout_state{
            .buffers = {
                sshape_vertex_buffer_layout_state(&shp),
                sg_vertex_buffer_layout_state{
                    .step_func = SG_VERTEXSTEP_PER_INSTANCE,
                    .stride = cast(i32, sizeof(instdata_t)),
                },
                sg_vertex_buffer_layout_state{},
                sg_vertex_buffer_layout_state{},
                sg_vertex_buffer_layout_state{},
                sg_vertex_buffer_layout_state{},
                sg_vertex_buffer_layout_state{},
                sg_vertex_buffer_layout_state{},
            },
            .attrs = {
                sshape_position_vertex_attr_state(&shp),
                sshape_normal_vertex_attr_state(&shp),
                sg_vertex_attr_state{
                    .format = SG_VERTEXFORMAT_FLOAT4,
                    .buffer_index = 1,
                    .offset = 0,
                },
                sg_vertex_attr_state{
                    .format = SG_VERTEXFORMAT_FLOAT4,
                    .buffer_index = 1,
                    .offset = 16,
                },
                sg_vertex_attr_state{
                    .format = SG_VERTEXFORMAT_FLOAT4,
                    .buffer_index = 1,
                    .offset = 32,
                },
                sg_vertex_attr_state{
                    .format = SG_VERTEXFORMAT_FLOAT4,
                    .buffer_index = 1,
                    .offset = 48,
                },
                sg_vertex_attr_state{},
                sg_vertex_attr_state{},
                sg_vertex_attr_state{},
                sg_vertex_attr_state{},
                sg_vertex_attr_state{},
                sg_vertex_attr_state{},
                sg_vertex_attr_state{},
                sg_vertex_attr_state{},
                sg_vertex_attr_state{},
                sg_vertex_attr_state{},
            },
        },
        .depth = sg_depth_state{.write_enabled = true, .compare = SG_COMPAREFUNC_LESS_EQUAL},
        .index_type = SG_INDEXTYPE_UINT16,
        .cull_mode = SG_CULLMODE_BACK,
        .label = "display-instanced-pipeline",
    });
    sg_image shadow_map_img = sg_make_image(&sg_image_desc{
        .usage = sg_image_usage{.depth_stencil_attachment = true},
        .width = 2048,
        .height = 2048,
        .pixel_format = SG_PIXELFORMAT_DEPTH,
        .sample_count = 1,
        .label = "shadow-map-image",
    });
    state.shadow.tex_view = sg_make_view(&sg_view_desc{
        .texture = sg_texture_view_desc{.image = shadow_map_img},
        .label = "shadow-map-texview",
    });
    state.shadow.pass = sg_pass{
        .action = sg_pass_action{
            .depth = sg_depth_attachment_action{
                .load_action = SG_LOADACTION_CLEAR,
                .store_action = SG_STOREACTION_STORE,
                .clear_value = 1.0f,
            },
        },
        .attachments = sg_attachments{
            .depth_stencil = sg_make_view(&sg_view_desc{
                .depth_stencil_attachment = sg_image_view_desc{.image = shadow_map_img},
                .label = "shadow-map-dsview",
            }),
        },
        .label = "shadow-pass",
    };
    state.shadow.smp = sg_make_sampler(&sg_sampler_desc{
        .min_filter = SG_FILTER_LINEAR,
        .mag_filter = SG_FILTER_LINEAR,
        .wrap_u = SG_WRAP_CLAMP_TO_EDGE,
        .wrap_v = SG_WRAP_CLAMP_TO_EDGE,
        .compare = SG_COMPAREFUNC_LESS,
        .label = "shadow-map-sampler",
    });
    state.shadow.inst_pip = sg_make_pipeline(&sg_pipeline_desc{
        .shader = sokol_make_shader(&box3d_simple_sapp_shadow_inst_vs_shader, &box3d_simple_sapp_shadow_fs_shader),
        .layout = sg_vertex_layout_state{
            .buffers = {
                sshape_vertex_buffer_layout_state(&shp),
                sg_vertex_buffer_layout_state{
                    .stride = cast(i32, sizeof(instdata_t)),
                    .step_func = SG_VERTEXSTEP_PER_INSTANCE,
                },
                sg_vertex_buffer_layout_state{},
                sg_vertex_buffer_layout_state{},
                sg_vertex_buffer_layout_state{},
                sg_vertex_buffer_layout_state{},
                sg_vertex_buffer_layout_state{},
                sg_vertex_buffer_layout_state{},
            },
            .attrs = {
                sshape_position_vertex_attr_state(&shp),
                sg_vertex_attr_state{
                    .format = SG_VERTEXFORMAT_FLOAT4,
                    .buffer_index = 1,
                    .offset = 0,
                },
                sg_vertex_attr_state{
                    .format = SG_VERTEXFORMAT_FLOAT4,
                    .buffer_index = 1,
                    .offset = 16,
                },
                sg_vertex_attr_state{
                    .format = SG_VERTEXFORMAT_FLOAT4,
                    .buffer_index = 1,
                    .offset = 32,
                },
                sg_vertex_attr_state{},
                sg_vertex_attr_state{},
                sg_vertex_attr_state{},
                sg_vertex_attr_state{},
                sg_vertex_attr_state{},
                sg_vertex_attr_state{},
                sg_vertex_attr_state{},
                sg_vertex_attr_state{},
                sg_vertex_attr_state{},
                sg_vertex_attr_state{},
                sg_vertex_attr_state{},
                sg_vertex_attr_state{},
            },
        },
        .depth = sg_depth_state{
            .pixel_format = SG_PIXELFORMAT_DEPTH,
            .compare = SG_COMPAREFUNC_LESS_EQUAL,
            .write_enabled = true,
        },
        .index_type = SG_INDEXTYPE_UINT16,
        .cull_mode = SG_CULLMODE_FRONT,
        .sample_count = 1,
        .colors[0] = {.pixel_format = SG_PIXELFORMAT_NONE},
        .label = "shadow-instanced-pipeline",
    });
    state.box_inst_buf = sg_make_buffer(&sg_buffer_desc{
        .usage = sg_buffer_usage{.stream_update = true},
        .size = cast(u64, (1024 / 2 + 1) * sizeof(instdata_t)),
        .label = "box-instance-buffer",
    });
    state.ball_inst_buf = sg_make_buffer(&sg_buffer_desc{
        .usage = sg_buffer_usage{.stream_update = true},
        .size = cast(u64, (1024 / 2 + 1) * sizeof(instdata_t)),
        .label = "ball-instance-buffer",
    });
}

void ui_draw() {
    sappimgui_track_frame();
    simgui_new_frame(&simgui_frame_desc_t{
        .width = sapp_width(),
        .height = sapp_height(),
        .delta_time = sapp_frame_duration(),
        .dpi_scale = sapp_dpi_scale(),
    });
    if ImGui_BeginMainMenuBar() != 0 {
        sgimgui_draw_menu("sokol-gfx");
        sappimgui_draw_menu("sokol-app");
        ImGui_EndMainMenuBar();
    }
    sappimgui_draw();
    sgimgui_draw();
    ImGui_SetNextWindowPos(ImVec2{30.0f, 50.0f}, ImGuiCond_Once);
    ImGui_SetNextWindowBgAlpha(0.5f);
    if ImGui_Begin("Status", null, ImGuiWindowFlags_NoDecoration | ImGuiWindowFlags_AlwaysAutoResize) != 0 {
        ImGui_Checkbox("Show sleeping", &state.ui.show_sleeping);
        ImGui_Text("Total bodies: %d", state.physics.num_bodies);
        ImGui_Text("Awake bodies: %d", state.profiling.num_awake_bodies);
        ImGui_Text("Sub-steps per frame: %d", state.profiling.sub_steps_per_frame);
        ImGui_Text("World Step Time: %.3fms", stm_ms(cast(u64, state.profiling.physics_world_step_time)));
        ImGui_Text("Copy Transforms Time: %.3fms", stm_ms(cast(u64, state.profiling.copy_transforms_time)));
    }
    ImGui_End();
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
        .window_title = "box3d-simple-sapp.mc",
        .icon = sapp_icon_desc{.sokol_default = true},
        .logger = sapp_logger{.func = slog_func},
    };
}
private { u32 xorshift32__x = 0x12345678; }
