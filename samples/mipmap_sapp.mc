import dbgui;
import vecmath;

import sokol_all;
import math;

// force high-dpi, sample entry point is __sapp_sample_main()
sapp_desc sokol_main() {
    sapp_desc d = __sapp_sample_main();
    d.high_dpi = true;
    return d;
}

// mipmap-sapp.glsl - ported to minc @shader.

struct MipmapSappVsOut {
    float4 pos;
    float2 uv;
}

@shader vertex
MipmapSappVsOut mipmap_sapp_vs(
    @attr(0) float4 pos,
    @attr(1) float2 uv0,
    @uniform float4x4 mvp
) {
    MipmapSappVsOut o;
    o.pos = mul(mvp, pos);
    o.uv = uv0;
    return o;
}

@shader fragment
float4 mipmap_sapp_fs(
MipmapSappVsOut input,
    @texture(0) Texture2D tex,
    @sampler(0) Sampler smp
) {
    return sample(tex, smp, input.uv);
}


enum __enum_ATTR_mipmap_pos {
    ATTR_mipmap_pos = 0,
    ATTR_mipmap_uv0 = 1,
    UB_vs_params = 0,
    VIEW_tex = 0,
    SMP_smp = 0,
    __shim_end = 255,
}

// Replaces the sokol-shdc generated mipmap-sapp.glsl.h.
struct vs_params_t {
    mat44_t mvp;
}

private struct state_t {
    sg_pipeline pip;
    sg_buffer vbuf;
    sg_view tex_view;
    sg_sampler[12] smp;
    f32 r;
    struct {
        u32[65536] mip0;
        u32[16384] mip1;
        u32[4096] mip2;
        u32[1024] mip3;
        u32[256] mip4;
        u32[64] mip5;
        u32[16] mip6;
        u32[4] mip7;
        u32[1] mip8;
    } pixels;
}

private {
state_t state;
u32[9] mip_colors = {
    0xFF0000FF, 0xFF00FF00, 0xFFFF0000, 0xFFFF00FF, 0xFFFFFF00, 0xFF00FFFF, 0xFFFF00A0, 0xFFFFA0FF,
    0xFFA000FF,
};

void init() {
    sg_setup(&sg_desc{.environment = sglue_environment(), .logger = sg_logger{.func = slog_func}});
    __dbgui_setup();
    f32[20] vertices = {
        -1.0f, -1.0f, 0.0f, 0.0f, 0.0f, 1.0f, -1.0f, 0.0f, 1.0f, 0.0f, -1.0f, 1.0f, 0.0f, 0.0f,
        1.0f, 1.0f, 1.0f, 0.0f, 1.0f, 1.0f,
    };
    state.vbuf = sg_make_buffer(&sg_buffer_desc{.data = sg_range{&vertices, sizeof(vertices)}});
    noinit sg_image_data img_data;
    u32* ptr = state.pixels.mip0;
    bool even_odd = false;
    for i32 mip_index = 0; mip_index <= 8; mip_index++ {
        i32 dim = 1 << 8 - mip_index;
        img_data.mip_levels[mip_index].ptr = ptr;
        img_data.mip_levels[mip_index].size = cast(u64, dim * dim * 4);
        for i32 y = 0; y < dim; y++ {
            for i32 x = 0; x < dim; x++ {
                *ptr++ = even_odd != 0 ? mip_colors[mip_index] : 0xFF000000;
                even_odd = !even_odd;
            }
            even_odd = !even_odd;
        }
    }
    sg_image img = sg_make_image(&sg_image_desc{
        .width = 256,
        .height = 256,
        .num_mipmaps = 9,
        .pixel_format = SG_PIXELFORMAT_RGBA8,
        .data = img_data,
    });
    state.tex_view = sg_make_view(&sg_view_desc{.texture = sg_texture_view_desc{.image = img}});
    var smp_desc = sg_sampler_desc{.mag_filter = SG_FILTER_LINEAR};
    sg_filter[2] filters = {SG_FILTER_NEAREST, SG_FILTER_LINEAR};
    sg_filter[2] mipmap_filters = {SG_FILTER_NEAREST, SG_FILTER_LINEAR};
    i32 smp_index = 0;
    for i32 i = 0; i < 2; i++ {
        for i32 j = 0; j < 2; j++ {
            smp_desc.min_filter = filters[i];
            smp_desc.mipmap_filter = mipmap_filters[j];
            state.smp[smp_index++] = sg_make_sampler(&smp_desc);
        }
    }
    smp_desc.min_lod = 2.0f;
    smp_desc.max_lod = 4.0f;
    for i32 i = 0; i < 2; i++ {
        for i32 j = 0; j < 2; j++ {
            smp_desc.min_filter = filters[i];
            smp_desc.mipmap_filter = mipmap_filters[j];
            state.smp[smp_index++] = sg_make_sampler(&smp_desc);
        }
    }
    smp_desc.min_lod = 0.0f;
    smp_desc.max_lod = 0.0f;
    smp_desc.min_filter = SG_FILTER_LINEAR;
    smp_desc.mag_filter = SG_FILTER_LINEAR;
    smp_desc.mipmap_filter = SG_FILTER_LINEAR;
    for i32 i = 0; i < 4; i++ {
        smp_desc.max_anisotropy = cast(u32, 1 << i);
        state.smp[smp_index++] = sg_make_sampler(&smp_desc);
    }
    state.pip = sg_make_pipeline(&sg_pipeline_desc{
        .layout = sg_vertex_layout_state{
            .attrs[0] = {.format = SG_VERTEXFORMAT_FLOAT3},
            .attrs[1] = {.format = SG_VERTEXFORMAT_FLOAT2},
        },
        .shader = sokol_make_shader(&mipmap_sapp_vs_shader, &mipmap_sapp_fs_shader),
        .primitive_type = SG_PRIMITIVETYPE_TRIANGLE_STRIP,
    });
}

void frame() {
    mat44_t proj = mat44_perspective_fov_rh(vecmath_radians(90.0f), sapp_widthf() / sapp_heightf(), 0.01f, 10.0f);
    mat44_t view = mat44_look_at_rh(vec3(0.0f, 0.0f, 3.5f), vec3(0.0f, 0.0f, 0.0f), vec3(0.0f, 1.0f, 0.0f));
    mat44_t view_proj = mat44_mul_mat44(view, proj);
    state.r += 0.1f * 60.0f * cast(f32, sapp_frame_duration());
    mat44_t rm = mat44_rotation_x(vecmath_radians(state.r));
    var bind = sg_bindings{.vertex_buffers[0] = state.vbuf, .views[0] = state.tex_view};
    sg_begin_pass(&sg_pass{.swapchain = sglue_swapchain()});
    sg_apply_pipeline(state.pip);
    for i32 i = 0; i < 12; i++ {
        f32 x = (cast(f32, i & 3) - 1.5f) * 2.0f;
        f32 y = (cast(f32, i / 4) - 1.0f) * -2.0f;
        mat44_t model = mat44_mul_mat44(rm, mat44_translation(x, y, 0.0f));
        var vs_params = vs_params_t{.mvp = mat44_mul_mat44(model, view_proj)};
        bind.samplers[SMP_smp] = state.smp[i];
        sg_apply_bindings(&bind);
        sg_apply_uniforms(UB_vs_params, &sg_range{&vs_params, sizeof(vs_params)});
        sg_draw(0, 4, 1);
    }
    __dbgui_draw();
    sg_end_pass();
    sg_commit();
}

void cleanup() {
    __dbgui_shutdown();
    sg_shutdown();
}
}

sapp_desc __sapp_sample_main() {
    return sapp_desc{
        .init_cb = init,
        .frame_cb = frame,
        .cleanup_cb = cleanup,
        .event_cb = __dbgui_event,
        .width = 800,
        .height = 600,
        .sample_count = 4,
        .window_title = "mipmap-sapp.mc",
        .icon = sapp_icon_desc{.sokol_default = true},
        .logger = sapp_logger{.func = slog_func},
    };
}
