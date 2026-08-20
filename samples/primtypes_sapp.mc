import dbgui;
import sokol_debugtext;
import vecmath;

import sokol_all;
import math;

// force high-dpi, sample entry point is __sapp_sample_main()
sapp_desc sokol_main() {
    sapp_desc d = __sapp_sample_main();
    d.high_dpi = true;
    return d;
}

// primtypes-sapp.glsl - ported to minc @shader.

struct PrimtypesSappVsOut {
    float4 pos;
    float4 color;
    // Metal leaves the point size UNDEFINED when the vertex shader
    // doesn't write it (giant flickering points); GL wants
    // gl_PointSize. D3D11/WGSL have no sized points, the row stays
    // 1px there, like upstream.
    when gpu(opengl) || gpu(opengles) || gpu(metal) { @point_size f32 psize; }
}

@gpu_layout
struct Ub_vs_params {
    float4x4 mvp;
    f32 point_size;
}

@shader vertex
PrimtypesSappVsOut primtypes_sapp_vs(
    @attr(0) float2 position,
    @attr(1) float4 color0,
    @uniform(0) Ub_vs_params vs_params
) {
    PrimtypesSappVsOut o;
    o.pos = mul(vs_params.mvp, float4{position.xy, 0.0f, 1.0f});
    when gpu(opengl) || gpu(opengles) || gpu(metal) { o.psize = vs_params.point_size; }
    o.color = color0;
    return o;
}

@shader fragment
float4 primtypes_sapp_fs(
PrimtypesSappVsOut input
) {
    return input.color;
}


enum __enum_ATTR_primtypes_position {
    ATTR_primtypes_position = 0,
    ATTR_primtypes_color0 = 1,
    UB_vs_params = 0,
    __shim_end = 255,
}

// Replaces the sokol-shdc generated primtypes-sapp.glsl.h.
struct vs_params_t {
    mat44_t mvp;
    f32 point_size;
    u8[12] _pad_tail;
}

// primitive type array indices
struct vertex_t {
    f32 x;
    f32 y;
    u32 color;
}

struct __anon_primtypes_sapp_struct_1 {
    sg_buffer ibuf;
    sg_pipeline pip;
    i32 num_elements;
}

private struct state_t {
    i32 cur_prim_type;
    sg_pass_action pass_action;
    sg_buffer vbuf;
    __anon_primtypes_sapp_struct_1[5] prim;
    f32 rx;
    f32 ry;
    f32 point_size;
    vertex_t[1024] vertices;
    struct {
        u16[1984] lines;
        u16[992] line_strip;
        u16[2883] triangles;
        u16[2046] triangle_strip;
    } indices;
}

private { state_t state; }

private {
void init() {
    state.cur_prim_type = 0;
    state.point_size = 4.0f;
    sg_setup(&sg_desc{.environment = sglue_environment(), .logger = sg_logger{.func = slog_func}});
    __dbgui_setup();
    sdtx_setup(&sdtx_desc_t{
        .fonts[0] = sdtx_font_z1013(),
        .logger = sdtx_logger_t{.func = slog_func},
    });
    setup_vertex_and_index_data();
    state.vbuf = sg_make_buffer(&sg_buffer_desc{.data = sg_range{&state.vertices, sizeof(state.vertices)}});
    sg_range[5] index_data = {
        sg_range{},
        sg_range{&state.indices.lines, sizeof(state.indices.lines)},
        sg_range{&state.indices.line_strip, sizeof(state.indices.line_strip)},
        sg_range{&state.indices.triangles, sizeof(state.indices.triangles)},
        sg_range{&state.indices.triangle_strip, sizeof(state.indices.triangle_strip)},
    };
    for i32 i = 0; i < 5; i++ {
        if index_data[i].ptr != null {
            state.prim[i].ibuf = sg_make_buffer(&sg_buffer_desc{
                .usage = sg_buffer_usage{.index_buffer = true},
                .data = index_data[i],
            });
        } else {
            state.prim[i].ibuf.id = cast(u32, SG_INVALID_ID);
        }
    }
    var pip_desc = sg_pipeline_desc{
        .layout = sg_vertex_layout_state{
            .attrs[0] = {.format = SG_VERTEXFORMAT_FLOAT2},
            .attrs[1] = {.format = SG_VERTEXFORMAT_UBYTE4N},
        },
        .shader = sokol_make_shader(&primtypes_sapp_vs_shader, &primtypes_sapp_fs_shader),
        .depth = sg_depth_state{.write_enabled = true, .compare = SG_COMPAREFUNC_LESS_EQUAL},
    };
    sg_primitive_type[5] prim_types = {
        SG_PRIMITIVETYPE_POINTS, SG_PRIMITIVETYPE_LINES, SG_PRIMITIVETYPE_LINE_STRIP,
        SG_PRIMITIVETYPE_TRIANGLES, SG_PRIMITIVETYPE_TRIANGLE_STRIP,
    };
    for i32 i = 0; i < 5; i++ {
        pip_desc.index_type = i == 0 ? SG_INDEXTYPE_NONE : SG_INDEXTYPE_UINT16;
        pip_desc.primitive_type = prim_types[i];
        state.prim[i].pip = sg_make_pipeline(&pip_desc);
    }
    state.prim[0].num_elements = 32 * 32;
    state.prim[1].num_elements = 32 * (32 - 1) * 2;
    state.prim[2].num_elements = 32 * (32 - 1);
    state.prim[3].num_elements = (32 - 1) * (32 - 1) * 3;
    state.prim[4].num_elements = 32 * (32 - 1) * 2 + (32 - 1) * 2;
    state.pass_action = sg_pass_action{
        .colors[0] = {.load_action = SG_LOADACTION_CLEAR, .clear_value = {0.0f, 0.2f, 0.4f, 1.0f}},
    };
}

void frame() {
    var t = cast(f32, sapp_frame_duration() * 60.0);
    state.rx += 0.3f * t;
    state.ry += 0.2f * t;
    f32 w = sapp_widthf();
    f32 h = sapp_heightf();
    vs_params_t vs_params = compute_vsparams(w, h, state.rx, state.ry, state.point_size);
    print_status_text(w, h);
    sg_begin_pass(&sg_pass{.action = state.pass_action, .swapchain = sglue_swapchain()});
    sg_apply_pipeline(state.prim[state.cur_prim_type].pip);
    sg_apply_bindings(&sg_bindings{
        .vertex_buffers[0] = state.vbuf,
        .index_buffer = state.prim[state.cur_prim_type].ibuf,
    });
    sg_apply_uniforms(UB_vs_params, &sg_range{&vs_params, sizeof(vs_params)});
    sg_draw(0, state.prim[state.cur_prim_type].num_elements, 1);
    sdtx_draw();
    __dbgui_draw();
    sg_end_pass();
    sg_commit();
}

// input helpers to cycle through primitive types
void next_prim_type() {
    state.cur_prim_type++;
    if state.cur_prim_type >= 5 {
        state.cur_prim_type = 0;
    }
}

void prev_prim_type() {
    state.cur_prim_type--;
    if state.cur_prim_type < 0 {
        state.cur_prim_type = 5 - 1;
    }
}

void incr_point_size() {
    state.point_size += 1.0f;
}

void decr_point_size() {
    state.point_size -= 1.0f;
    if state.point_size < 1.0f {
        state.point_size = 1.0f;
    }
}

void input(sapp_event* ev) {
    __dbgui_event(ev);
    switch ev.type {
        case SAPP_EVENTTYPE_KEY_DOWN: {
            switch ev.key_code {
                case SAPP_KEYCODE_1: {
                    state.cur_prim_type = 0;
                }
                case SAPP_KEYCODE_2: {
                    state.cur_prim_type = 1;
                }
                case SAPP_KEYCODE_3: {
                    state.cur_prim_type = 2;
                }
                case SAPP_KEYCODE_4: {
                    state.cur_prim_type = 3;
                }
                case SAPP_KEYCODE_5: {
                    state.cur_prim_type = 4;
                }
                case SAPP_KEYCODE_UP: {
                    prev_prim_type();
                }
                case SAPP_KEYCODE_DOWN: {
                    next_prim_type();
                }
                case SAPP_KEYCODE_LEFT: {
                    decr_point_size();
                }
                case SAPP_KEYCODE_RIGHT: {
                    incr_point_size();
                }
                default: {
                }
            }
        }
        case SAPP_EVENTTYPE_TOUCHES_ENDED, SAPP_EVENTTYPE_MOUSE_DOWN: {
            next_prim_type();
        }
        default: {
        }
    }
}

void cleanup() {
    sdtx_shutdown();
    __dbgui_shutdown();
    sg_shutdown();
}
}

// helper function to compute vertex shader params
vs_params_t compute_vsparams(f32 disp_w, f32 disp_h, f32 rx, f32 ry, f32 point_size) {
    mat44_t proj = mat44_perspective_fov_rh(vecmath_radians(60.0f), disp_w / disp_h, 0.01f, 10.0f);
    mat44_t view = mat44_look_at_rh(vec3(0.0f, 0.0f, 1.25f), vec3(0.0f, 0.0f, 0.0f), vec3(0.0f, 1.0f, 0.0f));
    mat44_t view_proj = mat44_mul_mat44(view, proj);
    mat44_t rxm = mat44_rotation_x(vecmath_radians(rx));
    mat44_t rym = mat44_rotation_y(vecmath_radians(ry));
    mat44_t model = mat44_mul_mat44(rym, rxm);
    return vs_params_t{.mvp = mat44_mul_mat44(model, view_proj), .point_size = point_size};
}

// helper function to print the help/status text
void print_status_text(f32 disp_w, f32 disp_h) {
    sdtx_canvas(disp_w * 0.5f, disp_h * 0.5f);
    sdtx_origin(1.0f, 2.0f);
    sdtx_color3f(1.0f, 1.0f, 1.0f);
    sdtx_printf("Point Size (left/right keys): %d\n\n", cast(i32, state.point_size));
    sdtx_puts("Primitive Type (1..5/up/down keys):\n");
    u8*[5] items = {
        "1: Point List\n", "2: Line List\n", "3: Line Strip\n", "4: Triangle List\n",
        "5: Triangle Strip\n",
    };
    for i32 i = 0; i < 5; i++ {
        if i == state.cur_prim_type {
            sdtx_puts("==> ");
        } else {
            sdtx_puts("    ");
        }
        sdtx_puts(items[i]);
    }
}

// helper function to fill index data
void setup_vertex_and_index_data() {
    {
        f32 dx = 1.0f / 32.0f;
        f32 dy = 1.0f / 32.0f;
        f32 offset_x = -dx * cast(f32, 32 / 2);
        f32 offset_y = -dy * cast(f32, 32 / 2);
        u32[3] colors = {0xFF0000DD, 0xFF00DD00, 0xFF00DDDD};
        i32 i = 0;
        for i32 y = 0; y < 32; y++ {
            for i32 x = 0; x < 32; x++ {
                vertex_t* vtx = &state.vertices[i];
                vtx.x = cast(f32, x) * dx + offset_x;
                vtx.y = cast(f32, y) * dy + offset_y;
                vtx.color = colors[i % 3];
                i++;
            }
        }
    }
    {
        i32 ii = 0;
        for u16 y = 0; cast(i32, y) < 32 - 1; y++ {
            for u16 x = 0; x < 32; x++ {
                var i0 = cast(u16, (x & 1) != 0 ? y * 32 + x - 1 : y * 32 + x + 1);
                var i1 = cast(u16, (x & 1) != 0 ? i0 + 32 + 1 : i0 + 32 - 1);
                state.indices.lines[ii++] = i0;
                state.indices.lines[ii++] = i1;
            }
        }
    }
    {
        i32 ii = 0;
        for u16 y = 0; cast(i32, y) < 32 - 1; y++ {
            for u16 x = 0; x < 32; x++ {
                var i0 = cast(u16, (x & 1) != 0 ? y * 32 + x : (y + 1) * 32 + x);
                state.indices.line_strip[ii++] = i0;
            }
        }
    }
    {
        i32 ii = 0;
        for u16 y = 0; cast(i32, y) < 32 - 1; y++ {
            for u16 x = 0; cast(i32, x) < 32 - 1; x++ {
                var i0 = cast(u16, x + y * 32);
                var i1 = cast(u16, (x & 1) != 0 ? i0 + 32 : i0 + 1);
                var i2 = cast(u16, (x & 1) != 0 ? i1 + 1 : i0 + 32);
                state.indices.triangles[ii++] = i0;
                state.indices.triangles[ii++] = i1;
                state.indices.triangles[ii++] = i2;
            }
        }
    }
    {
        i32 ii = 0;
        for u16 y = 0; cast(i32, y) < 32 - 1; y++ {
            u16 i0 = 0;
            u16 i1 = 0;
            for u16 x = 0; x < 32; x++ {
                i0 = cast(u16, x + y * 32);
                i1 = cast(u16, i0 + 32);
                state.indices.triangle_strip[ii++] = i0;
                state.indices.triangle_strip[ii++] = i1;
            }
            i0 = cast(u16, (y + 1) * 32);
            state.indices.triangle_strip[ii++] = i1;
            state.indices.triangle_strip[ii++] = i0;
        }
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
        .window_title = "primtypes-sapp.mc",
        .icon = sapp_icon_desc{.sokol_default = true},
        .logger = sapp_logger{.func = slog_func},
    };
}
