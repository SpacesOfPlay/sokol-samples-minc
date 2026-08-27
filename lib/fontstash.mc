// fontstash : transpiled from fontstash.h

//
//  NOTE sokol: all IO functions have been removed
//
// Copyright (c) 2009-2013 Mikko Mononen memon@inside.org
//
// This software is provided 'as-is', without any express or implied
// warranty.  In no event will the authors be held liable for any damages
// arising from the use of this software.
// Permission is granted to anyone to use this software for any purpose,
// including commercial applications, and to alter it and redistribute it
// freely, subject to the following restrictions:
// 1. The origin of this software must not be misrepresented; you must not
//	claim that you wrote the original software. If you use this software
//	in a product, an acknowledgment in the product documentation would be
//	appreciated but is not required.
// 2. Altered source versions must be plainly marked as such, and must not be
//	misrepresented as being the original software.
// 3. This notice may not be removed or altered from any source distribution.
//
// To make the implementation private to the file that generates the implementation
enum FONSflags {
    FONS_ZERO_TOPLEFT = 1,
    FONS_ZERO_BOTTOMLEFT = 2,
}

enum FONSalign {
    FONS_ALIGN_LEFT = 1,
    FONS_ALIGN_CENTER = 2,
    FONS_ALIGN_RIGHT = 4,
    FONS_ALIGN_TOP = 8,
    FONS_ALIGN_MIDDLE = 16,
    FONS_ALIGN_BOTTOM = 32,
    FONS_ALIGN_BASELINE = 64,
}

enum FONSerrorCode {
    FONS_ATLAS_FULL = 1,
    FONS_SCRATCH_FULL = 2,
    FONS_STATES_OVERFLOW = 3,
    FONS_STATES_UNDERFLOW = 4,
}

enum __enum_STBTT_vmove {
    STBTT_vmove = 1,
    STBTT_vline = 2,
    STBTT_vcurve = 3,
    STBTT_vcubic = 4,
}

enum __enum_STBTT_PLATFORM_ID_UNICODE {
    STBTT_PLATFORM_ID_UNICODE = 0,
    STBTT_PLATFORM_ID_MAC = 1,
    STBTT_PLATFORM_ID_ISO = 2,
    STBTT_PLATFORM_ID_MICROSOFT = 3,
}

enum __enum_STBTT_UNICODE_EID_UNICODE_1_0 {
    STBTT_UNICODE_EID_UNICODE_1_0 = 0,
    STBTT_UNICODE_EID_UNICODE_1_1 = 1,
    STBTT_UNICODE_EID_ISO_10646 = 2,
    STBTT_UNICODE_EID_UNICODE_2_0_BMP = 3,
    STBTT_UNICODE_EID_UNICODE_2_0_FULL = 4,
}

enum __enum_STBTT_MS_EID_SYMBOL {
    STBTT_MS_EID_SYMBOL = 0,
    STBTT_MS_EID_UNICODE_BMP = 1,
    STBTT_MS_EID_SHIFTJIS = 2,
    STBTT_MS_EID_UNICODE_FULL = 10,
}

enum __enum_STBTT_MAC_EID_ROMAN {
    STBTT_MAC_EID_ROMAN = 0,
    STBTT_MAC_EID_ARABIC = 4,
    STBTT_MAC_EID_JAPANESE = 1,
    STBTT_MAC_EID_HEBREW = 5,
    STBTT_MAC_EID_CHINESE_TRAD = 2,
    STBTT_MAC_EID_GREEK = 6,
    STBTT_MAC_EID_KOREAN = 3,
    STBTT_MAC_EID_RUSSIAN = 7,
}

enum __enum_STBTT_MS_LANG_ENGLISH {
    STBTT_MS_LANG_ENGLISH = 1033,
    STBTT_MS_LANG_ITALIAN = 1040,
    STBTT_MS_LANG_CHINESE = 2052,
    STBTT_MS_LANG_JAPANESE = 1041,
    STBTT_MS_LANG_DUTCH = 1043,
    STBTT_MS_LANG_KOREAN = 1042,
    STBTT_MS_LANG_FRENCH = 1036,
    STBTT_MS_LANG_RUSSIAN = 1049,
    STBTT_MS_LANG_GERMAN = 1031,
    STBTT_MS_LANG_SPANISH = 1033,
    STBTT_MS_LANG_HEBREW = 1037,
    STBTT_MS_LANG_SWEDISH = 1053,
}

enum __enum_STBTT_MAC_LANG_ENGLISH {
    STBTT_MAC_LANG_ENGLISH = 0,
    STBTT_MAC_LANG_JAPANESE = 11,
    STBTT_MAC_LANG_ARABIC = 12,
    STBTT_MAC_LANG_KOREAN = 23,
    STBTT_MAC_LANG_DUTCH = 4,
    STBTT_MAC_LANG_RUSSIAN = 32,
    STBTT_MAC_LANG_FRENCH = 1,
    STBTT_MAC_LANG_SPANISH = 6,
    STBTT_MAC_LANG_GERMAN = 2,
    STBTT_MAC_LANG_SWEDISH = 5,
    STBTT_MAC_LANG_HEBREW = 10,
    STBTT_MAC_LANG_CHINESE_SIMPLIFIED = 33,
    STBTT_MAC_LANG_ITALIAN = 3,
    STBTT_MAC_LANG_CHINESE_TRAD = 19,
}

// stb_truetype.h - v1.16 - public domain
// authored from 2009-2016 by Sean Barrett / RAD Game Tools
//
//   This library processes TrueType files:
//        parse files
//        extract glyph metrics
//        extract glyph shapes
//        render glyphs to one-channel bitmaps with antialiasing (box filter)
//        render glyphs to one-channel SDF bitmaps (signed-distance field/function)
//
//   Todo:
//        non-MS cmaps
//        crashproof on bad data
//        hinting? (no longer patented)
//        cleartype-style AA?
//        optimize: use simple memory allocator for intermediates
//        optimize: build edge-list directly from curves
//        optimize: rasterize directly from curves?
//
// ADDITIONAL CONTRIBUTORS
//
//   Mikko Mononen: compound shape support, more cmap formats
//   Tor Andersson: kerning, subpixel rendering
//   Dougall Johnson: OpenType / Type 2 font handling
//
//   Misc other:
//       Ryan Gordon
//       Simon Glass
//       github:IntellectualKitty
//
//   Bug/warning reports/fixes:
//       "Zer" on mollyrocket
//       Cass Everitt
//       stoiko (Haemimont Games)
//       Brian Hook 
//       Walter van Niftrik
//       David Gow
//       David Given
//       Ivan-Assen Ivanov
//       Anthony Pesch
//       Johan Duparc
//       Hou Qiming
//       Fabian "ryg" Giesen
//       Martins Mozeiko
//       Cap Petschulat
//       Omar Cornut
//       github:aloucks
//       Peter LaValle
//       Sergey Popov
//       Giumo X. Clanjor
//       Higor Euripedes
//       Thomas Fields
//       Derek Vinyard
//       Cort Stratton
//
// VERSION HISTORY
//
//   1.16 (2017-07-12) SDF support
//   1.15 (2017-03-03) make more arguments const
//   1.14 (2017-01-16) num-fonts-in-TTC function
//   1.13 (2017-01-02) support OpenType fonts, certain Apple fonts
//   1.12 (2016-10-25) suppress warnings about casting away const with -Wcast-qual
//   1.11 (2016-04-02) fix unused-variable warning
//   1.10 (2016-04-02) user-defined fabs(); rare memory leak; remove duplicate typedef
//   1.09 (2016-01-16) warning fix; avoid crash on outofmem; use allocation userdata properly
//   1.08 (2015-09-13) document stbtt_Rasterize(); fixes for vertical & horizontal edges
//   1.07 (2015-08-01) allow PackFontRanges to accept arrays of sparse codepoints;
//                     variant PackFontRanges to pack and render in separate phases;
//                     fix stbtt_GetFontOFfsetForIndex (never worked for non-0 input?);
//                     fixed an assert() bug in the new rasterizer
//                     replace assert() with STBTT_assert() in new rasterizer
//
//   Full history can be found at the end of this file.
//
// LICENSE
//
//   See end of file for license information.
//
// USAGE
//
//   Include this file in whatever places neeed to refer to it. In ONE C/C++
//   file, write:
//      #define STB_TRUETYPE_IMPLEMENTATION
//   before the #include of this file. This expands out the actual
//   implementation into that C/C++ file.
//
//   To make the implementation private to the file that generates the implementation,
//      #define STBTT_STATIC
//
//   Simple 3D API (don't ship this, but it's fine for tools and quick start)
//           stbtt_BakeFontBitmap()               -- bake a font to a bitmap for use as texture
//           stbtt_GetBakedQuad()                 -- compute quad to draw for a given char
//
//   Improved 3D API (more shippable):
//           #include "stb_rect_pack.h"           -- optional, but you really want it
//           stbtt_PackBegin()
//           stbtt_PackSetOversample()            -- for improved quality on small fonts
//           stbtt_PackFontRanges()               -- pack and renders
//           stbtt_PackEnd()
//           stbtt_GetPackedQuad()
//
//   "Load" a font file from a memory buffer (you have to keep the buffer loaded)
//           stbtt_InitFont()
//           stbtt_GetFontOffsetForIndex()        -- indexing for TTC font collections
//           stbtt_GetNumberOfFonts()             -- number of fonts for TTC font collections
//
//   Render a unicode codepoint to a bitmap
//           stbtt_GetCodepointBitmap()           -- allocates and returns a bitmap
//           stbtt_MakeCodepointBitmap()          -- renders into bitmap you provide
//           stbtt_GetCodepointBitmapBox()        -- how big the bitmap must be
//
//   Character advance/positioning
//           stbtt_GetCodepointHMetrics()
//           stbtt_GetFontVMetrics()
//           stbtt_GetCodepointKernAdvance()
//
//   Starting with version 1.06, the rasterizer was replaced with a new,
//   faster and generally-more-precise rasterizer. The new rasterizer more
//   accurately measures pixel coverage for anti-aliasing, except in the case
//   where multiple shapes overlap, in which case it overestimates the AA pixel
//   coverage. Thus, anti-aliasing of intersecting shapes may look wrong. If
//   this turns out to be a problem, you can re-enable the old rasterizer with
//        #define STBTT_RASTERIZER_VERSION 1
//   which will incur about a 15% speed hit.
//
// ADDITIONAL DOCUMENTATION
//
//   Immediately after this block comment are a series of sample programs.
//
//   After the sample programs is the "header file" section. This section
//   includes documentation for each API function.
//
//   Some important concepts to understand to use this library:
//
//      Codepoint
//         Characters are defined by unicode codepoints, e.g. 65 is
//         uppercase A, 231 is lowercase c with a cedilla, 0x7e30 is
//         the hiragana for "ma".
//
//      Glyph
//         A visual character shape (every codepoint is rendered as
//         some glyph)
//
//      Glyph index
//         A font-specific integer ID representing a glyph
//
//      Baseline
//         Glyph shapes are defined relative to a baseline, which is the
//         bottom of uppercase characters. Characters extend both above
//         and below the baseline.
//
//      Current Point
//         As you draw text to the screen, you keep track of a "current point"
//         which is the origin of each character. The current point's vertical
//         position is the baseline. Even "baked fonts" use this model.
//
//      Vertical Font Metrics
//         The vertical qualities of the font, used to vertically position
//         and space the characters. See docs for stbtt_GetFontVMetrics.
//
//      Font Size in Pixels or Points
//         The preferred interface for specifying font sizes in stb_truetype
//         is to specify how tall the font's vertical extent should be in pixels.
//         If that sounds good enough, skip the next paragraph.
//
//         Most font APIs instead use "points", which are a common typographic
//         measurement for describing font size, defined as 72 points per inch.
//         stb_truetype provides a point API for compatibility. However, true
//         "per inch" conventions don't make much sense on computer displays
//         since they different monitors have different number of pixels per
//         inch. For example, Windows traditionally uses a convention that
//         there are 96 pixels per inch, thus making 'inch' measurements have
//         nothing to do with inches, and thus effectively defining a point to
//         be 1.333 pixels. Additionally, the TrueType font data provides
//         an explicit scale factor to scale a given font's glyphs to points,
//         but the author has observed that this scale factor is often wrong
//         for non-commercial fonts, thus making fonts scaled in points
//         according to the TrueType spec incoherently sized in practice.
//
// ADVANCED USAGE
//
//   Quality:
//
//    - Use the functions with Subpixel at the end to allow your characters
//      to have subpixel positioning. Since the font is anti-aliased, not
//      hinted, this is very import for quality. (This is not possible with
//      baked fonts.)
//
//    - Kerning is now supported, and if you're supporting subpixel rendering
//      then kerning is worth using to give your text a polished look.
//
//   Performance:
//
//    - Convert Unicode codepoints to glyph indexes and operate on the glyphs;
//      if you don't do this, stb_truetype is forced to do the conversion on
//      every call.
//
//    - There are a lot of memory allocations. We should modify it to take
//      a temp buffer and allocate from the temp buffer (without freeing),
//      should help performance a lot.
//
// NOTES
//
//   The system uses the raw data found in the .ttf file without changing it
//   and without building auxiliary data structures. This is a bit inefficient
//   on little-endian systems (the data is big-endian), but assuming you're
//   caching the bitmaps or glyph shapes this shouldn't be a big deal.
//
//   It appears to be very hard to programmatically determine what font a
//   given file is in a general way. I provide an API for this, but I don't
//   recommend it.
//
//
// SOURCE STATISTICS (based on v0.6c, 2050 LOC)
//
//   Documentation & header file        520 LOC  \___ 660 LOC documentation
//   Sample code                        140 LOC  /
//   Truetype parsing                   620 LOC  ---- 620 LOC TrueType
//   Software rasterization             240 LOC  \                           .
//   Curve tesselation                  120 LOC   \__ 550 LOC Bitmap creation
//   Bitmap management                  100 LOC   /
//   Baked bitmap interface              70 LOC  /
//   Font name matching & access        150 LOC  ---- 150 
//   C runtime library abstraction       60 LOC  ----  60
//
//
// PERFORMANCE MEASUREMENTS FOR 1.06:
//
//                      32-bit     64-bit
//   Previous release:  8.83 s     7.68 s
//   Pool allocations:  7.72 s     6.34 s
//   Inline sort     :  6.54 s     5.65 s
//   New rasterizer  :  5.63 s     5.00 s
//////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////
////
////  SAMPLE PROGRAMS
////
//
//  Incomplete text-in-3d-api example, which draws quads properly aligned to be lossless
//
//
//
//////////////////////////////////////////////////////////////////////////////
//
// Complete program (this compiles): get a single bitmap, print as ASCII art
//
//
// Output:
//
//     .ii.
//    @@@@@@.
//   V@Mio@@o
//   :i.  V@V
//     :oM@@M
//   :@@@MM@M
//   @@o  o@M
//  :@@.  M@M
//   @@@o@@@@
//   :M@@V:@@.
//  
//////////////////////////////////////////////////////////////////////////////
// 
// Complete program: print "Hello World!" banner, with bugs
//
//////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////
////
////   INTEGRATION WITH YOUR CODEBASE
////
////   The following sections allow you to supply alternate definitions
////   of C library functions used by stb_truetype.
// #define your own (u)stbtt_int8/16/32 before including to override this
type stbtt_uint8 = u8;
type stbtt_int8 = i8;
type stbtt_uint16 = u16;
type stbtt_int16 = i16;
type stbtt_uint32 = u32;
type stbtt_int32 = i32;
type stbtt__check_size32 = u8[sizeof(stbtt_int32) == 4 ? 1 : -1];
type stbtt__check_size16 = u8[sizeof(stbtt_int16) == 2 ? 1 : -1];
when !(defined(STB_RECT_PACK_VERSION)) {
}
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
////
////   IMPLEMENTATION
////
////
type stbtt__test_oversample_pow2 = i32[(8 & 8 - 1) == 0 ? 1 : -1];
when !(defined(STB_RECT_PACK_VERSION)) {
    type stbrp_coord = i32;
}
struct FONSparams {
    i32 width;
    i32 height;
    u8 flags;
    void* userPtr;
    fn(void*, i32, i32): i32 renderCreate;
    fn(void*, i32, i32): i32 renderResize;
    fn(void*, i32*, u8*): void renderUpdate;
    fn(void*, f32*, f32*, u32*, i32): void renderDraw;
    fn(void*): void renderDelete;
}

struct FONSquad {
    f32 x0;
    f32 y0;
    f32 s0;
    f32 t0;
    f32 x1;
    f32 y1;
    f32 s1;
    f32 t1;
}

struct FONStextIter {
    f32 x;
    f32 y;
    f32 nextx;
    f32 nexty;
    f32 scale;
    f32 spacing;
    u32 codepoint;
    i16 isize;
    i16 iblur;
    FONSfont* font;
    i32 prevGlyphIndex;
    u8* str_var;
    u8* next;
    u8* end;
    u32 utf8state;
}

// #define your own STBTT_ifloor/STBTT_iceil() to avoid math.h
// #define your own functions "STBTT_malloc" / "STBTT_free" to avoid malloc.h
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
////
////   INTERFACE
////
////
// private structure
struct stbtt__buf {
    u8* data;
    i32 cursor;
    i32 size;
}

//////////////////////////////////////////////////////////////////////////////
//
// TEXTURE BAKING API
//
// If you use this API, you only have to call two functions ever.
//
struct stbtt_bakedchar {
    u16 x0;
    u16 y0;
    u16 x1;
    u16 y1;
    f32 xoff;
    f32 yoff;
    f32 xadvance;
}

// you allocate this, it's num_chars long
// if return is positive, the first unused row of the bitmap
// if return is negative, returns the negative of the number of characters that fit
// if return is 0, no characters fit and no rows were used
// This uses a very crappy packing.
struct stbtt_aligned_quad {
    f32 x0;
    f32 y0;
    f32 s0;
    f32 t0;
    f32 x1;
    f32 y1;
    f32 s1;
    f32 t1;
}

// true if opengl fill rule; false if DX9 or earlier
// Call GetBakedQuad with char_index = 'character - first_char', and it
// creates the quad you need to draw and advances the current position.
//
// The coordinate system used assumes y increases downwards.
//
// Characters will extend both above and below the current position;
// see discussion of "BASELINE" above.
//
// It's inefficient; you might want to c&p it and optimize it.
//////////////////////////////////////////////////////////////////////////////
//
// NEW TEXTURE BAKING API
//
// This provides options for packing multiple fonts into one atlas, not
// perfectly but better than nothing.
struct stbtt_packedchar {
    u16 x0;
    u16 y0;
    u16 x1;
    u16 y1;
    f32 xoff;
    f32 yoff;
    f32 xadvance;
    f32 xoff2;
    f32 yoff2;
}

// Creates character bitmaps from the font_index'th font found in fontdata (use
// font_index=0 if you don't know what that is). It creates num_chars_in_range
// bitmaps for characters with unicode values starting at first_unicode_char_in_range
// and increasing. Data for how to render them is stored in chardata_for_range;
// pass these to stbtt_GetPackedQuad to get back renderable quads.
//
// font_size is the full height of the character from ascender to descender,
// as computed by stbtt_ScaleForPixelHeight. To use a point size as computed
// by stbtt_ScaleForMappingEmToPixels, wrap the point size in STBTT_POINT_SIZE()
// and pass that result as 'font_size':
//       ...,                  20 , ... // font max minus min y is 20 pixels tall
//       ..., STBTT_POINT_SIZE(20), ... // 'M' is 20 pixels tall
struct stbtt_pack_range {
    f32 font_size;
    i32 first_unicode_codepoint_in_range;
    i32* array_of_unicode_codepoints;
    i32 num_chars;
    stbtt_packedchar* chardata_for_range;
    u8 h_oversample;
    u8 v_oversample;
}

// Calling these functions in sequence is roughly equivalent to calling
// stbtt_PackFontRanges(). If you more control over the packing of multiple
// fonts, or if you want to pack custom data into a font texture, take a look
// at the source to of stbtt_PackFontRanges() and create a custom version 
// using these functions, e.g. call GatherRects multiple times,
// building up a single array of rects, then call PackRects once,
// then call RenderIntoRects repeatedly. This may result in a
// better packing than calling PackFontRanges multiple times
// (or it may not).
// this is an opaque structure that you shouldn't mess with which holds
// all the context needed from PackBegin to PackEnd.
struct stbtt_pack_context {
    void* user_allocator_context;
    void* pack_info;
    i32 width;
    i32 height;
    i32 stride_in_bytes;
    i32 padding;
    u32 h_oversample;
    u32 v_oversample;
    u8* pixels;
    void* nodes;
}

// Each .ttf/.ttc file may have more than one font. Each font has a sequential
// index number starting from 0. Call this function to get the font offset for
// a given index; it returns -1 if the index is out of range. A regular .ttf
// file will only define one font and it always be at offset 0, so it will
// return '0' for index 0, and -1 for all other indices.
// The following structure is defined publically so you can declare one on
// the stack or as a global or etc, but you should treat it as opaque.
struct stbtt_fontinfo {
    void* userdata;
    u8* data;
    i32 fontstart;
    i32 numGlyphs;
    i32 loca;
    i32 head;
    i32 glyf;
    i32 hhea;
    i32 hmtx;
    i32 kern;
    i32 index_map;
    i32 indexToLocFormat;
    stbtt__buf cff;
    stbtt__buf charstrings;
    stbtt__buf gsubrs;
    stbtt__buf subrs;
    stbtt__buf fontdicts;
    stbtt__buf fdselect;
}

// (we share this with other code at RAD)
struct stbtt_vertex {
    i16 x;
    i16 y;
    i16 cx;
    i16 cy;
    i16 cx1;
    i16 cy1;
    u8 type;
    u8 padding;
}

// @TODO: don't expose this structure
struct stbtt__bitmap {
    i32 w;
    i32 h;
    i32 stride;
    u8* pixels;
}

struct stbtt__csctx {
    i32 bounds;
    i32 started;
    f32 first_x;
    f32 first_y;
    f32 x;
    f32 y;
    stbtt_int32 min_x;
    stbtt_int32 max_x;
    stbtt_int32 min_y;
    stbtt_int32 max_y;
    stbtt_vertex* pvertices;
    i32 num_vertices;
}

//////////////////////////////////////////////////////////////////////////////
//
//  Rasterizer
struct stbtt__hheap_chunk {
    stbtt__hheap_chunk* next;
}

struct stbtt__hheap {
    stbtt__hheap_chunk* head;
    void* first_free;
    i32 num_remaining_in_head_chunk;
}

struct stbtt__edge {
    f32 x0;
    f32 y0;
    f32 x1;
    f32 y1;
    i32 invert;
}

struct stbtt__active_edge {
    stbtt__active_edge* next;
    f32 fx;
    f32 fdx;
    f32 fdy;
    f32 direction;
    f32 sy;
    f32 ey;
}

struct stbtt__point {
    f32 x;
    f32 y;
}

////////////////////////////////////////////////////////////////////////////////////
//                                                                                //
//                                                                                //
// COMPILER WARNING ?!?!?                                                         //
//                                                                                //
//                                                                                //
// if you get a compile warning due to these symbols being defined more than      //
// once, move #include "stb_rect_pack.h" before #include "stb_truetype.h"         //
//                                                                                //
////////////////////////////////////////////////////////////////////////////////////
struct stbrp_context {
    i32 width;
    i32 height;
    i32 x;
    i32 y;
    i32 bottom_y;
}

struct stbrp_node {
    u8 x;
}

struct stbrp_rect {
    stbrp_coord x;
    stbrp_coord y;
    i32 id;
    i32 w;
    i32 h;
    i32 was_packed;
}

struct FONSttFontImpl {
    stbtt_fontinfo font;
}

struct FONSglyph {
    u32 codepoint;
    i32 index;
    i32 next;
    i16 size;
    i16 blur;
    i16 x0;
    i16 y0;
    i16 x1;
    i16 y1;
    i16 xadv;
    i16 xoff;
    i16 yoff;
}

struct FONSfont {
    FONSttFontImpl font;
    u8[64] name;
    u8* data;
    i32 dataSize;
    u8 freeData;
    f32 ascender;
    f32 descender;
    f32 lineh;
    FONSglyph* glyphs;
    i32 cglyphs;
    i32 nglyphs;
    i32[256] lut;
    i32[20] fallbacks;
    i32 nfallbacks;
}

struct FONSstate {
    i32 font;
    i32 align;
    f32 size;
    u32 color;
    f32 blur;
    f32 spacing;
}

struct FONSatlasNode {
    i16 x;
    i16 y;
    i16 width;
}

struct FONSatlas {
    i32 width;
    i32 height;
    FONSatlasNode* nodes;
    i32 nnodes;
    i32 cnodes;
}

struct FONScontext {
    FONSparams params;
    f32 itw;
    f32 ith;
    u8* texData;
    i32[4] dirtyRect;
    FONSfont** fonts;
    FONSatlas* atlas;
    i32 cfonts;
    i32 nfonts;
    f32[1024 * 2] verts;
    f32[1024 * 2] tcoords;
    u32[1024] colors;
    i32 nverts;
    u8* scratch;
    i32 nscratch;
    FONSstate[20] states;
    i32 nstates;
    fn(void*, i32, i32): void handleError;
    void* errorUptr;
}

when !(defined(STB_RECT_PACK_VERSION)) {
}
// as above, but takes one or more glyph indices for greater efficiency
//////////////////////////////////////////////////////////////////////////////
//
// GLYPH SHAPES (you probably don't need these, but they have to go before
// the bitmaps for C declaration-order reasons)
//
when !(defined(STBTT_vmove)) {
}

//////////////////////////////////////////////////////////////////////////
//
// stbtt__buf helpers to parse data from file
//
private {
stbtt_uint8 stbtt__buf_get8(stbtt__buf* b) {
    if b.cursor >= b.size {
        return 0;
    }
    return b.data[b.cursor++];
}

stbtt_uint8 stbtt__buf_peek8(stbtt__buf* b) {
    if b.cursor >= b.size {
        return 0;
    }
    return b.data[b.cursor];
}

void stbtt__buf_seek(stbtt__buf* b, i32 o) {
    b.cursor = o > b.size || o < 0 ? b.size : o;
}

void stbtt__buf_skip(stbtt__buf* b, i32 o) {
    stbtt__buf_seek(b, b.cursor + o);
}

stbtt_uint32 stbtt__buf_get(stbtt__buf* b, i32 n) {
    stbtt_uint32 v = 0;
    i32 i;
    for i = 0; i < n; i++ {
        v = v << 8 | stbtt__buf_get8(b);
    }
    return v;
}

stbtt__buf stbtt__new_buf(void* p, u64 size) {
    noinit stbtt__buf r;
    r.data = cast(stbtt_uint8*, p);
    r.size = cast(i32, size);
    r.cursor = 0;
    return r;
}

stbtt__buf stbtt__buf_range(stbtt__buf* b, i32 o, i32 s) {
    stbtt__buf r = stbtt__new_buf(null, 0);
    if o < 0 || s < 0 || o > b.size || s > b.size - o {
        return r;
    }
    r.data = b.data + o;
    r.size = s;
    return r;
}

stbtt__buf stbtt__cff_get_index(stbtt__buf* b) {
    i32 count;
    i32 start;
    i32 offsize;
    start = b.cursor;
    count = cast(i32, stbtt__buf_get(b, 2));
    if count != 0 {
        offsize = cast(i32, stbtt__buf_get8(b));
        stbtt__buf_skip(b, offsize * count);
        stbtt__buf_skip(b, cast(i32, stbtt__buf_get(b, offsize) - 1));
    }
    return stbtt__buf_range(b, start, b.cursor - start);
}

stbtt_uint32 stbtt__cff_int(stbtt__buf* b) {
    var b0 = cast(i32, stbtt__buf_get8(b));
    if b0 >= 32 && b0 <= 246 {
        return cast(stbtt_uint32, b0 - 139);
    } else if b0 >= 247 && b0 <= 250 {
        return cast(stbtt_uint32, (b0 - 247) * 256 + stbtt__buf_get8(b) + 108);
    } else if b0 >= 251 && b0 <= 254 {
        return cast(stbtt_uint32, -(b0 - 251) * 256 - stbtt__buf_get8(b) - 108);
    } else if b0 == 28 {
        return stbtt__buf_get(b, 2);
    } else if b0 == 29 {
        return stbtt__buf_get(b, 4);
    }
    return 0;
}

void stbtt__cff_skip_operand(stbtt__buf* b) {
    i32 v;
    var b0 = cast(i32, stbtt__buf_peek8(b));
    if b0 == 30 {
        stbtt__buf_skip(b, 1);
        while b.cursor < b.size {
            v = cast(i32, stbtt__buf_get8(b));
            if (v & 0xF) == 0xF || v >> 4 == 0xF {
                break;
            }
        }
    } else {
        stbtt__cff_int(b);
    }
}

stbtt__buf stbtt__dict_get(stbtt__buf* b, i32 key) {
    stbtt__buf_seek(b, 0);
    while b.cursor < b.size {
        i32 start = b.cursor;
        i32 end;
        i32 op;
        while stbtt__buf_peek8(b) >= 28 {
            stbtt__cff_skip_operand(b);
        }
        end = b.cursor;
        op = cast(i32, stbtt__buf_get8(b));
        if op == 12 {
            op = cast(i32, stbtt__buf_get8(b)) | 0x100;
        }
        if op == key {
            return stbtt__buf_range(b, start, end - start);
        }
    }
    return stbtt__buf_range(b, 0, 0);
}

void stbtt__dict_get_ints(stbtt__buf* b, i32 key, i32 outcount, stbtt_uint32* out) {
    i32 i;
    stbtt__buf operands = stbtt__dict_get(b, key);
    for i = 0; i < outcount && operands.cursor < operands.size; i++ {
        out[i] = stbtt__cff_int(&operands);
    }
}

i32 stbtt__cff_index_count(stbtt__buf* b) {
    stbtt__buf_seek(b, 0);
    return cast(i32, stbtt__buf_get(b, 2));
}

stbtt__buf stbtt__cff_index_get(stbtt__buf b, i32 i) {
    i32 count;
    i32 offsize;
    i32 start;
    i32 end;
    stbtt__buf_seek(&b, 0);
    count = cast(i32, stbtt__buf_get(&b, 2));
    offsize = cast(i32, stbtt__buf_get8(&b));
    stbtt__buf_skip(&b, i * offsize);
    start = cast(i32, stbtt__buf_get(&b, offsize));
    end = cast(i32, stbtt__buf_get(&b, offsize));
    return stbtt__buf_range(&b, 2 + (count + 1) * offsize + start, end - start);
}

//////////////////////////////////////////////////////////////////////////
//
// accessors to parse data from file
//
// on platforms that don't allow misaligned reads, if we want to allow
// truetype fonts that aren't padded to alignment, define ALLOW_UNALIGNED_TRUETYPE
stbtt_uint16 ttUSHORT(stbtt_uint8* p) {
    return cast(stbtt_uint16, cast(i32, p[0]) * 256 + p[1]);
}

stbtt_int16 ttSHORT(stbtt_uint8* p) {
    return cast(stbtt_int16, cast(i32, p[0]) * 256 + p[1]);
}

stbtt_uint32 ttULONG(stbtt_uint8* p) {
    return cast(stbtt_uint32, (cast(i32, p[0]) << 24) + (cast(i32, p[1]) << 16) + (cast(i32, p[2]) << 8) + p[3]);
}

stbtt_int32 ttLONG(stbtt_uint8* p) {
    return (cast(i32, p[0]) << 24) + (cast(i32, p[1]) << 16) + (cast(i32, p[2]) << 8) + p[3];
}

i32 stbtt__isfont(stbtt_uint8* font) {
    if font[0] == 49 && font[1] == 0 && font[2] == 0 && font[3] == 0 {
        return 1;
    }
    if font[0] == cast(u8, "typ1"[0]) && font[1] == cast(u8, "typ1"[1]) && font[2] == cast(u8, "typ1"[2]) && font[3] == cast(u8, "typ1"[3]) {
        return 1;
    }
    if font[0] == cast(u8, "OTTO"[0]) && font[1] == cast(u8, "OTTO"[1]) && font[2] == cast(u8, "OTTO"[2]) && font[3] == cast(u8, "OTTO"[3]) {
        return 1;
    }
    if font[0] == 0 && font[1] == 1 && font[2] == 0 && font[3] == 0 {
        return 1;
    }
    if font[0] == cast(u8, "true"[0]) && font[1] == cast(u8, "true"[1]) && font[2] == cast(u8, "true"[2]) && font[3] == cast(u8, "true"[3]) {
        return 1;
    }
    return 0;
}

// @OPTIMIZE: binary search
stbtt_uint32 stbtt__find_table(stbtt_uint8* data, stbtt_uint32 fontstart, u8* tag) {
    var num_tables = cast(stbtt_int32, ttUSHORT(data + fontstart + 4));
    stbtt_uint32 tabledir = fontstart + 12;
    stbtt_int32 i;
    for i = 0; i < num_tables; ++i {
        stbtt_uint32 loc = tabledir + cast(u32, 16 * i);
        if (data + loc + 0)[0] == cast(u8, tag[0]) && (data + loc + 0)[1] == cast(u8, tag[1]) && (data + loc + 0)[2] == cast(u8, tag[2]) && (data + loc + 0)[3] == cast(u8, tag[3]) {
            return ttULONG(data + loc + 8);
        }
    }
    return 0;
}

i32 stbtt_GetFontOffsetForIndex_internal(u8* font_collection, i32 index) {
    if stbtt__isfont(font_collection) != 0 {
        return index == 0 ? 0 : -1;
    }
    if font_collection[0] == cast(u8, "ttcf"[0]) && font_collection[1] == cast(u8, "ttcf"[1]) && font_collection[2] == cast(u8, "ttcf"[2]) && font_collection[3] == cast(u8, "ttcf"[3]) {
        if ttULONG(font_collection + 4) == 0x00010000 || ttULONG(font_collection + 4) == 0x00020000 {
            stbtt_int32 n = ttLONG(font_collection + 8);
            if index >= n {
                return -1;
            }
            return cast(i32, ttULONG(font_collection + 12 + index * 4));
        }
    }
    return -1;
}

i32 stbtt_GetNumberOfFonts_internal(u8* font_collection) {
    if stbtt__isfont(font_collection) != 0 {
        return 1;
    }
    if font_collection[0] == cast(u8, "ttcf"[0]) && font_collection[1] == cast(u8, "ttcf"[1]) && font_collection[2] == cast(u8, "ttcf"[2]) && font_collection[3] == cast(u8, "ttcf"[3]) {
        if ttULONG(font_collection + 4) == 0x00010000 || ttULONG(font_collection + 4) == 0x00020000 {
            return ttLONG(font_collection + 8);
        }
    }
    return 0;
}

stbtt__buf stbtt__get_subrs(stbtt__buf cff, stbtt__buf fontdict) {
    stbtt_uint32 subrsoff = 0;
    stbtt_uint32[2] private_loc = {0, 0};
    noinit stbtt__buf pdict;
    stbtt__dict_get_ints(&fontdict, 18, 2, private_loc);
    if !private_loc[1] || !private_loc[0] {
        return stbtt__new_buf(null, 0);
    }
    pdict = stbtt__buf_range(&cff, cast(i32, private_loc[1]), cast(i32, private_loc[0]));
    stbtt__dict_get_ints(&pdict, 19, 1, &subrsoff);
    if subrsoff == 0 {
        return stbtt__new_buf(null, 0);
    }
    stbtt__buf_seek(&cff, cast(i32, private_loc[1] + subrsoff));
    return stbtt__cff_get_index(&cff);
}

i32 stbtt_InitFont_internal(stbtt_fontinfo* info, u8* data, i32 fontstart) {
    stbtt_uint32 cmap;
    stbtt_uint32 t;
    stbtt_int32 i;
    stbtt_int32 numTables;
    info.data = data;
    info.fontstart = fontstart;
    info.cff = stbtt__new_buf(null, 0);
    cmap = stbtt__find_table(data, cast(stbtt_uint32, fontstart), "cmap");
    info.loca = cast(i32, stbtt__find_table(data, cast(stbtt_uint32, fontstart), "loca"));
    info.head = cast(i32, stbtt__find_table(data, cast(stbtt_uint32, fontstart), "head"));
    info.glyf = cast(i32, stbtt__find_table(data, cast(stbtt_uint32, fontstart), "glyf"));
    info.hhea = cast(i32, stbtt__find_table(data, cast(stbtt_uint32, fontstart), "hhea"));
    info.hmtx = cast(i32, stbtt__find_table(data, cast(stbtt_uint32, fontstart), "hmtx"));
    info.kern = cast(i32, stbtt__find_table(data, cast(stbtt_uint32, fontstart), "kern"));
    if !cmap || !info.head || !info.hhea || !info.hmtx {
        return 0;
    }
    if info.glyf != 0 {
        if info.loca == 0 {
            return 0;
        }
    } else {
        noinit stbtt__buf b;
        noinit stbtt__buf topdict;
        noinit stbtt__buf topdictidx;
        stbtt_uint32 cstype = 2;
        stbtt_uint32 charstrings = 0;
        stbtt_uint32 fdarrayoff = 0;
        stbtt_uint32 fdselectoff = 0;
        stbtt_uint32 cff;
        cff = stbtt__find_table(data, cast(stbtt_uint32, fontstart), "CFF ");
        if cff == 0 {
            return 0;
        }
        info.fontdicts = stbtt__new_buf(null, 0);
        info.fdselect = stbtt__new_buf(null, 0);
        info.cff = stbtt__new_buf(data + cff, cast(u64, 512 * 1024 * 1024));
        b = info.cff;
        stbtt__buf_skip(&b, 2);
        stbtt__buf_seek(&b, cast(i32, stbtt__buf_get8(&b)));
        stbtt__cff_get_index(&b);
        topdictidx = stbtt__cff_get_index(&b);
        topdict = stbtt__cff_index_get(topdictidx, 0);
        stbtt__cff_get_index(&b);
        info.gsubrs = stbtt__cff_get_index(&b);
        stbtt__dict_get_ints(&topdict, 17, 1, &charstrings);
        stbtt__dict_get_ints(&topdict, 0x100 | 6, 1, &cstype);
        stbtt__dict_get_ints(&topdict, 0x100 | 36, 1, &fdarrayoff);
        stbtt__dict_get_ints(&topdict, 0x100 | 37, 1, &fdselectoff);
        info.subrs = stbtt__get_subrs(b, topdict);
        if cstype != 2 {
            return 0;
        }
        if charstrings == 0 {
            return 0;
        }
        if fdarrayoff != 0 {
            if fdselectoff == 0 {
                return 0;
            }
            stbtt__buf_seek(&b, cast(i32, fdarrayoff));
            info.fontdicts = stbtt__cff_get_index(&b);
            info.fdselect = stbtt__buf_range(&b, cast(i32, fdselectoff), cast(i32, cast(u32, b.size) - fdselectoff));
        }
        stbtt__buf_seek(&b, cast(i32, charstrings));
        info.charstrings = stbtt__cff_get_index(&b);
    }
    t = stbtt__find_table(data, cast(stbtt_uint32, fontstart), "maxp");
    if t != 0 {
        info.numGlyphs = cast(i32, ttUSHORT(data + t + 4));
    } else {
        info.numGlyphs = 0xffff;
    }
    numTables = cast(i32, ttUSHORT(data + cmap + 2));
    info.index_map = 0;
    for i = 0; i < numTables; ++i {
        stbtt_uint32 encoding_record = cmap + 4 + cast(u32, 8 * i);
        switch ttUSHORT(data + encoding_record) {
            case STBTT_PLATFORM_ID_MICROSOFT: {
                switch ttUSHORT(data + encoding_record + 2) {
                    case STBTT_MS_EID_UNICODE_BMP, STBTT_MS_EID_UNICODE_FULL: {
                        info.index_map = cast(i32, cmap + ttULONG(data + encoding_record + 4));
                    }
                }
            }
            case STBTT_PLATFORM_ID_UNICODE: {
                info.index_map = cast(i32, cmap + ttULONG(data + encoding_record + 4));
            }
        }
    }
    if info.index_map == 0 {
        return 0;
    }
    info.indexToLocFormat = cast(i32, ttUSHORT(data + info.head + 50));
    return 1;
}

i32 stbtt_FindGlyphIndex(stbtt_fontinfo* info, i32 unicode_codepoint) {
    stbtt_uint8* data = info.data;
    var index_map = cast(stbtt_uint32, info.index_map);
    stbtt_uint16 format_var = ttUSHORT(data + index_map + 0);  // renamed from: format
    if format_var == 0 {
        var bytes = cast(stbtt_int32, ttUSHORT(data + index_map + 2));
        if unicode_codepoint < bytes - 6 {
            return cast(i32, *(data + index_map + 6 + unicode_codepoint));
        }
        return 0;
    } else if format_var == 6 {
        stbtt_uint32 first = ttUSHORT(data + index_map + 6);
        stbtt_uint32 count = ttUSHORT(data + index_map + 8);
        if cast(stbtt_uint32, unicode_codepoint) >= first && cast(stbtt_uint32, unicode_codepoint) < first + count {
            return cast(i32, ttUSHORT(data + index_map + 10 + (cast(u32, unicode_codepoint) - first) * 2));
        }
        return 0;
    } else if format_var == 2 {
        return 0;
    } else if format_var == 4 {
        var segcount = cast(stbtt_uint16, cast(i32, ttUSHORT(data + index_map + 6)) >> 1);
        var searchRange = cast(stbtt_uint16, cast(i32, ttUSHORT(data + index_map + 8)) >> 1);
        stbtt_uint16 entrySelector = ttUSHORT(data + index_map + 10);
        var rangeShift = cast(stbtt_uint16, cast(i32, ttUSHORT(data + index_map + 12)) >> 1);
        stbtt_uint32 endCount = index_map + 14;
        stbtt_uint32 search = endCount;
        if unicode_codepoint > 0xffff {
            return 0;
        }
        if unicode_codepoint >= cast(i32, ttUSHORT(data + search + rangeShift * 2)) {
            search += rangeShift * 2;
        }
        search -= 2;
        while entrySelector != 0 {
            stbtt_uint16 end;
            searchRange >>= 1;
            end = ttUSHORT(data + search + searchRange * 2);
            if unicode_codepoint > cast(i32, end) {
                search += searchRange * 2;
            }
            --entrySelector;
        }
        search += 2;
        {
            stbtt_uint16 offset;
            stbtt_uint16 start;
            var item = cast(stbtt_uint16, search - endCount >> 1);
            start = ttUSHORT(data + index_map + 14 + segcount * 2 + 2 + 2 * item);
            if unicode_codepoint < cast(i32, start) {
                return 0;
            }
            offset = ttUSHORT(data + index_map + 14 + segcount * 6 + 2 + 2 * item);
            if offset == 0 {
                return cast(stbtt_uint16, unicode_codepoint + ttSHORT(data + index_map + 14 + segcount * 4 + 2 + 2 * item));
            }
            return cast(i32, ttUSHORT(data + offset + (unicode_codepoint - start) * 2 + index_map + 14 + segcount * 6 + 2 + 2 * item));
        }
    } else if format_var == 12 || format_var == 13 {
        stbtt_uint32 ngroups = ttULONG(data + index_map + 12);
        stbtt_int32 low;
        stbtt_int32 high;
        low = 0;
        high = cast(stbtt_int32, ngroups);
        while low < high {
            stbtt_int32 mid = low + (high - low >> 1);
            stbtt_uint32 start_char = ttULONG(data + index_map + 16 + mid * 12);
            stbtt_uint32 end_char = ttULONG(data + index_map + 16 + mid * 12 + 4);
            if cast(stbtt_uint32, unicode_codepoint) < start_char {
                high = mid;
            } else if cast(stbtt_uint32, unicode_codepoint) > end_char {
                low = mid + 1;
            } else {
                stbtt_uint32 start_glyph = ttULONG(data + index_map + 16 + mid * 12 + 8);
                if format_var == 12 {
                    return cast(i32, start_glyph + cast(u32, unicode_codepoint) - start_char);
                } else {
                    return cast(i32, start_glyph);
                }
            }
        }
        return 0;
    }
    return 0;
}

i32 stbtt_GetCodepointShape(stbtt_fontinfo* info, i32 unicode_codepoint, stbtt_vertex** vertices) {
    return stbtt_GetGlyphShape(info, stbtt_FindGlyphIndex(info, unicode_codepoint), vertices);
}

void stbtt_setvertex(stbtt_vertex* v, stbtt_uint8 type, stbtt_int32 x, stbtt_int32 y, stbtt_int32 cx, stbtt_int32 cy) {
    v.type = type;
    v.x = cast(stbtt_int16, x);
    v.y = cast(stbtt_int16, y);
    v.cx = cast(stbtt_int16, cx);
    v.cy = cast(stbtt_int16, cy);
}

i32 stbtt__GetGlyfOffset(stbtt_fontinfo* info, i32 glyph_index) {
    i32 g1;
    i32 g2;
    if glyph_index >= info.numGlyphs {
        return -1;
    }
    if info.indexToLocFormat >= 2 {
        return -1;
    }
    if info.indexToLocFormat == 0 {
        g1 = cast(i32, cast(u32, info.glyf) + ttUSHORT(info.data + info.loca + glyph_index * 2) * 2);
        g2 = cast(i32, cast(u32, info.glyf) + ttUSHORT(info.data + info.loca + glyph_index * 2 + 2) * 2);
    } else {
        g1 = cast(i32, cast(u32, info.glyf) + ttULONG(info.data + info.loca + glyph_index * 4));
        g2 = cast(i32, cast(u32, info.glyf) + ttULONG(info.data + info.loca + glyph_index * 4 + 4));
    }
    return g1 == g2 ? -1 : g1;
}
}

private {
i32 stbtt_GetGlyphBox(stbtt_fontinfo* info, i32 glyph_index, i32* x0, i32* y0, i32* x1, i32* y1) {
    if info.cff.size != 0 {
        stbtt__GetGlyphInfoT2(info, glyph_index, x0, y0, x1, y1);
    } else {
        i32 g = stbtt__GetGlyfOffset(info, glyph_index);
        if g < 0 {
            return 0;
        }
        if x0 != null {
            *x0 = ttSHORT(info.data + g + 2);
        }
        if y0 != null {
            *y0 = ttSHORT(info.data + g + 4);
        }
        if x1 != null {
            *x1 = ttSHORT(info.data + g + 6);
        }
        if y1 != null {
            *y1 = ttSHORT(info.data + g + 8);
        }
    }
    return 1;
}

i32 stbtt_GetCodepointBox(stbtt_fontinfo* info, i32 codepoint, i32* x0, i32* y0, i32* x1, i32* y1) {
    return stbtt_GetGlyphBox(info, stbtt_FindGlyphIndex(info, codepoint), x0, y0, x1, y1);
}

i32 stbtt_IsGlyphEmpty(stbtt_fontinfo* info, i32 glyph_index) {
    stbtt_int16 numberOfContours;
    i32 g;
    if info.cff.size != 0 {
        return stbtt__GetGlyphInfoT2(info, glyph_index, null, null, null, null) == 0;
    }
    g = stbtt__GetGlyfOffset(info, glyph_index);
    if g < 0 {
        return 1;
    }
    numberOfContours = ttSHORT(info.data + g);
    return numberOfContours == 0;
}

i32 stbtt__close_shape(stbtt_vertex* vertices, i32 num_vertices, i32 was_off, i32 start_off, stbtt_int32 sx, stbtt_int32 sy, stbtt_int32 scx, stbtt_int32 scy, stbtt_int32 cx, stbtt_int32 cy) {
    if start_off != 0 {
        if was_off != 0 {
            stbtt_setvertex(&vertices[num_vertices++], cast(stbtt_uint8, STBTT_vcurve), cx + scx >> 1, cy + scy >> 1, cx, cy);
        }
        stbtt_setvertex(&vertices[num_vertices++], cast(stbtt_uint8, STBTT_vcurve), sx, sy, scx, scy);
    } else {
        if was_off != 0 {
            stbtt_setvertex(&vertices[num_vertices++], cast(stbtt_uint8, STBTT_vcurve), sx, sy, cx, cy);
        } else {
            stbtt_setvertex(&vertices[num_vertices++], cast(stbtt_uint8, STBTT_vline), sx, sy, 0, 0);
        }
    }
    return num_vertices;
}

i32 stbtt__GetGlyphShapeTT(stbtt_fontinfo* info, i32 glyph_index, stbtt_vertex** pvertices) {
    stbtt_int16 numberOfContours;
    stbtt_uint8* endPtsOfContours;
    stbtt_uint8* data = info.data;
    stbtt_vertex* vertices = null;
    i32 num_vertices = 0;
    i32 g = stbtt__GetGlyfOffset(info, glyph_index);
    *pvertices = null;
    if g < 0 {
        return 0;
    }
    numberOfContours = ttSHORT(data + g);
    if numberOfContours > 0 {
        stbtt_uint8 flags = 0;
        stbtt_uint8 flagcount;
        stbtt_int32 ins;
        stbtt_int32 i;
        stbtt_int32 j = 0;
        stbtt_int32 m;
        stbtt_int32 n;
        stbtt_int32 next_move;
        stbtt_int32 was_off = 0;
        stbtt_int32 off;
        stbtt_int32 start_off = 0;
        stbtt_int32 x;
        stbtt_int32 y;
        stbtt_int32 cx;
        stbtt_int32 cy;
        stbtt_int32 sx;
        stbtt_int32 sy;
        stbtt_int32 scx;
        stbtt_int32 scy;
        stbtt_uint8* points;
        endPtsOfContours = data + g + 10;
        ins = cast(i32, ttUSHORT(data + g + 10 + numberOfContours * 2));
        points = data + g + 10 + numberOfContours * 2 + 2 + ins;
        n = cast(i32, 1 + ttUSHORT(endPtsOfContours + numberOfContours * 2 - 2));
        m = n + 2 * numberOfContours;
        vertices = cast(stbtt_vertex*, fons__tmpalloc(cast(u64, m * sizeof(vertices[0])), info.userdata));
        if vertices == null {
            return 0;
        }
        next_move = 0;
        flagcount = 0;
        off = m - n;
        for i = 0; i < n; ++i {
            if flagcount == 0 {
                flags = *points++;
                if (flags & 8) != 0 {
                    flagcount = *points++;
                }
            } else {
                --flagcount;
            }
            vertices[off + i].type = flags;
        }
        x = 0;
        for i = 0; i < n; ++i {
            flags = vertices[off + i].type;
            if (flags & 2) != 0 {
                var dx = cast(stbtt_int16, *points++);
                x += (flags & 16) != 0 ? dx : -dx;
            } else {
                if (flags & 16) == 0 {
                    x = x + cast(stbtt_int16, cast(i32, points[0]) * 256 + points[1]);
                    points += 2;
                }
            }
            vertices[off + i].x = cast(stbtt_int16, x);
        }
        y = 0;
        for i = 0; i < n; ++i {
            flags = vertices[off + i].type;
            if (flags & 4) != 0 {
                var dy = cast(stbtt_int16, *points++);
                y += (flags & 32) != 0 ? dy : -dy;
            } else {
                if (flags & 32) == 0 {
                    y = y + cast(stbtt_int16, cast(i32, points[0]) * 256 + points[1]);
                    points += 2;
                }
            }
            vertices[off + i].y = cast(stbtt_int16, y);
        }
        num_vertices = 0;
        scy = 0;
        scx = scy;
        cy = scx;
        cx = cy;
        sy = cx;
        sx = sy;
        for i = 0; i < n; ++i {
            flags = vertices[off + i].type;
            x = cast(stbtt_int16, vertices[off + i].x);
            y = cast(stbtt_int16, vertices[off + i].y);
            if next_move == i {
                if i != 0 {
                    num_vertices = stbtt__close_shape(vertices, num_vertices, was_off, start_off, sx, sy, scx, scy, cx, cy);
                }
                start_off = !(flags & 1);
                if start_off != 0 {
                    scx = x;
                    scy = y;
                    if (vertices[off + i + 1].type & 1) == 0 {
                        sx = x + cast(stbtt_int32, vertices[off + i + 1].x) >> 1;
                        sy = y + cast(stbtt_int32, vertices[off + i + 1].y) >> 1;
                    } else {
                        sx = cast(stbtt_int32, vertices[off + i + 1].x);
                        sy = cast(stbtt_int32, vertices[off + i + 1].y);
                        ++i;
                    }
                } else {
                    sx = x;
                    sy = y;
                }
                stbtt_setvertex(&vertices[num_vertices++], cast(stbtt_uint8, STBTT_vmove), sx, sy, 0, 0);
                was_off = 0;
                next_move = cast(i32, 1 + ttUSHORT(endPtsOfContours + j * 2));
                ++j;
            } else {
                if (flags & 1) == 0 {
                    if was_off != 0 {
                        stbtt_setvertex(&vertices[num_vertices++], cast(stbtt_uint8, STBTT_vcurve), cx + x >> 1, cy + y >> 1, cx, cy);
                    }
                    cx = x;
                    cy = y;
                    was_off = 1;
                } else {
                    if was_off != 0 {
                        stbtt_setvertex(&vertices[num_vertices++], cast(stbtt_uint8, STBTT_vcurve), x, y, cx, cy);
                    } else {
                        stbtt_setvertex(&vertices[num_vertices++], cast(stbtt_uint8, STBTT_vline), x, y, 0, 0);
                    }
                    was_off = 0;
                }
            }
        }
        num_vertices = stbtt__close_shape(vertices, num_vertices, was_off, start_off, sx, sy, scx, scy, cx, cy);
    } else if numberOfContours == -1 {
        i32 more = 1;
        stbtt_uint8* comp = data + g + 10;
        num_vertices = 0;
        vertices = null;
        while more != 0 {
            stbtt_uint16 flags;
            stbtt_uint16 gidx;
            i32 comp_num_verts = 0;
            i32 i;
            stbtt_vertex* comp_verts = null;
            stbtt_vertex* tmp = null;
            f32[6] mtx = {1.0f, 0.0f, 0.0f, 1.0f, 0.0f, 0.0f};
            f32 m;
            f32 n;
            flags = cast(u16, ttSHORT(comp));
            comp += 2;
            gidx = cast(u16, ttSHORT(comp));
            comp += 2;
            if (flags & 2) != 0 {
                if (flags & 1) != 0 {
                    mtx[4] = cast(f32, ttSHORT(comp));
                    comp += 2;
                    mtx[5] = cast(f32, ttSHORT(comp));
                    comp += 2;
                } else {
                    mtx[4] = cast(f32, *cast(stbtt_int8*, comp));
                    comp += 1;
                    mtx[5] = cast(f32, *cast(stbtt_int8*, comp));
                    comp += 1;
                }
            } else {
            }
            if (flags & 1 << 3) != 0 {
                mtx[3] = cast(f32, ttSHORT(comp)) / 16384.0f;
                mtx[0] = mtx[3];
                comp += 2;
                mtx[2] = 0.0f;
                mtx[1] = mtx[2];
            } else if (flags & 1 << 6) != 0 {
                mtx[0] = cast(f32, ttSHORT(comp)) / 16384.0f;
                comp += 2;
                mtx[2] = 0.0f;
                mtx[1] = mtx[2];
                mtx[3] = cast(f32, ttSHORT(comp)) / 16384.0f;
                comp += 2;
            } else if (flags & 1 << 7) != 0 {
                mtx[0] = cast(f32, ttSHORT(comp)) / 16384.0f;
                comp += 2;
                mtx[1] = cast(f32, ttSHORT(comp)) / 16384.0f;
                comp += 2;
                mtx[2] = cast(f32, ttSHORT(comp)) / 16384.0f;
                comp += 2;
                mtx[3] = cast(f32, ttSHORT(comp)) / 16384.0f;
                comp += 2;
            }
            m = cast(f32, sqrt(mtx[0] * mtx[0] + mtx[1] * mtx[1]));
            n = cast(f32, sqrt(mtx[2] * mtx[2] + mtx[3] * mtx[3]));
            comp_num_verts = stbtt_GetGlyphShape(info, cast(i32, gidx), &comp_verts);
            if comp_num_verts > 0 {
                for i = 0; i < comp_num_verts; ++i {
                    stbtt_vertex* v = &comp_verts[i];
                    i16 x;
                    i16 y;
                    x = v.x;
                    y = v.y;
                    v.x = cast(i16, m * (mtx[0] * cast(f32, x) + mtx[2] * cast(f32, y) + mtx[4]));
                    v.y = cast(i16, n * (mtx[1] * cast(f32, x) + mtx[3] * cast(f32, y) + mtx[5]));
                    x = v.cx;
                    y = v.cy;
                    v.cx = cast(i16, m * (mtx[0] * cast(f32, x) + mtx[2] * cast(f32, y) + mtx[4]));
                    v.cy = cast(i16, n * (mtx[1] * cast(f32, x) + mtx[3] * cast(f32, y) + mtx[5]));
                }
                tmp = cast(stbtt_vertex*, fons__tmpalloc(cast(u64, (num_vertices + comp_num_verts) * sizeof(stbtt_vertex)), info.userdata));
                if tmp == null {
                    if vertices != null {
                        fons__tmpfree(vertices, info.userdata);
                    }
                    if comp_verts != null {
                        fons__tmpfree(comp_verts, info.userdata);
                    }
                    return 0;
                }
                if num_vertices > 0 {
                    memcpy(tmp, vertices, cast(u64, num_vertices * sizeof(stbtt_vertex)));
                }
                memcpy(tmp + num_vertices, comp_verts, cast(u64, comp_num_verts * sizeof(stbtt_vertex)));
                if vertices != null {
                    fons__tmpfree(vertices, info.userdata);
                }
                vertices = tmp;
                fons__tmpfree(comp_verts, info.userdata);
                num_vertices += comp_num_verts;
            }
            more = flags & 1 << 5;
        }
    } else if numberOfContours < 0 {
    } else {
    }
    *pvertices = vertices;
    return num_vertices;
}

void stbtt__track_vertex(stbtt__csctx* c, stbtt_int32 x, stbtt_int32 y) {
    if x > c.max_x || !c.started {
        c.max_x = x;
    }
    if y > c.max_y || !c.started {
        c.max_y = y;
    }
    if x < c.min_x || !c.started {
        c.min_x = x;
    }
    if y < c.min_y || !c.started {
        c.min_y = y;
    }
    c.started = 1;
}

void stbtt__csctx_v(stbtt__csctx* c, stbtt_uint8 type, stbtt_int32 x, stbtt_int32 y, stbtt_int32 cx, stbtt_int32 cy, stbtt_int32 cx1, stbtt_int32 cy1) {
    if c.bounds != 0 {
        stbtt__track_vertex(c, x, y);
        if cast(i32, type) == STBTT_vcubic {
            stbtt__track_vertex(c, cx, cy);
            stbtt__track_vertex(c, cx1, cy1);
        }
    } else {
        stbtt_setvertex(&c.pvertices[c.num_vertices], type, x, y, cx, cy);
        c.pvertices[c.num_vertices].cx1 = cast(stbtt_int16, cx1);
        c.pvertices[c.num_vertices].cy1 = cast(stbtt_int16, cy1);
    }
    c.num_vertices++;
}

void stbtt__csctx_close_shape(stbtt__csctx* ctx) {
    if ctx.first_x != ctx.x || ctx.first_y != ctx.y {
        stbtt__csctx_v(ctx, cast(stbtt_uint8, STBTT_vline), cast(i32, ctx.first_x), cast(i32, ctx.first_y), 0, 0, 0, 0);
    }
}

void stbtt__csctx_rmove_to(stbtt__csctx* ctx, f32 dx, f32 dy) {
    stbtt__csctx_close_shape(ctx);
    ctx.x = ctx.x + dx;
    ctx.first_x = ctx.x;
    ctx.y = ctx.y + dy;
    ctx.first_y = ctx.y;
    stbtt__csctx_v(ctx, cast(stbtt_uint8, STBTT_vmove), cast(i32, ctx.x), cast(i32, ctx.y), 0, 0, 0, 0);
}

void stbtt__csctx_rline_to(stbtt__csctx* ctx, f32 dx, f32 dy) {
    ctx.x += dx;
    ctx.y += dy;
    stbtt__csctx_v(ctx, cast(stbtt_uint8, STBTT_vline), cast(i32, ctx.x), cast(i32, ctx.y), 0, 0, 0, 0);
}

void stbtt__csctx_rccurve_to(stbtt__csctx* ctx, f32 dx1, f32 dy1, f32 dx2, f32 dy2, f32 dx3, f32 dy3) {
    f32 cx1 = ctx.x + dx1;
    f32 cy1 = ctx.y + dy1;
    f32 cx2 = cx1 + dx2;
    f32 cy2 = cy1 + dy2;
    ctx.x = cx2 + dx3;
    ctx.y = cy2 + dy3;
    stbtt__csctx_v(ctx, cast(stbtt_uint8, STBTT_vcubic), cast(i32, ctx.x), cast(i32, ctx.y), cast(i32, cx1), cast(i32, cy1), cast(i32, cx2), cast(i32, cy2));
}

stbtt__buf stbtt__get_subr(stbtt__buf idx, i32 n) {
    i32 count = stbtt__cff_index_count(&idx);
    i32 bias = 107;
    if count >= 33900 {
        bias = 32768;
    } else if count >= 1240 {
        bias = 1131;
    }
    n += bias;
    if n < 0 || n >= count {
        return stbtt__new_buf(null, 0);
    }
    return stbtt__cff_index_get(idx, n);
}

stbtt__buf stbtt__cid_get_glyph_subrs(stbtt_fontinfo* info, i32 glyph_index) {
    stbtt__buf fdselect = info.fdselect;
    i32 nranges;
    i32 start;
    i32 end;
    i32 v;
    i32 fmt;
    i32 fdselector = -1;
    i32 i;
    stbtt__buf_seek(&fdselect, 0);
    fmt = cast(i32, stbtt__buf_get8(&fdselect));
    if fmt == 0 {
        stbtt__buf_skip(&fdselect, glyph_index);
        fdselector = cast(i32, stbtt__buf_get8(&fdselect));
    } else if fmt == 3 {
        nranges = cast(i32, stbtt__buf_get(&fdselect, 2));
        start = cast(i32, stbtt__buf_get(&fdselect, 2));
        for i = 0; i < nranges; i++ {
            v = cast(i32, stbtt__buf_get8(&fdselect));
            end = cast(i32, stbtt__buf_get(&fdselect, 2));
            if glyph_index >= start && glyph_index < end {
                fdselector = v;
                break;
            }
            start = end;
        }
    }
    if fdselector == -1 {
        stbtt__new_buf(null, 0);
    }
    return stbtt__get_subrs(info.cff, stbtt__cff_index_get(info.fontdicts, fdselector));
}

i32 stbtt__run_charstring(stbtt_fontinfo* info, i32 glyph_index, stbtt__csctx* c) {
    i32 in_header = 1;
    i32 maskbits = 0;
    i32 subr_stack_height = 0;
    i32 sp = 0;
    i32 v;
    i32 i;
    i32 b0;
    i32 has_subrs = 0;
    i32 clear_stack;
    noinit f32[48] s;
    noinit stbtt__buf[10] subr_stack;
    stbtt__buf subrs = info.subrs;
    noinit stbtt__buf b;
    f32 f;
    b = stbtt__cff_index_get(info.charstrings, glyph_index);
    while b.cursor < b.size {
        i = 0;
        clear_stack = 1;
        b0 = cast(i32, stbtt__buf_get8(&b));
        switch b0 {
            case 0x13, 0x14: {
                if in_header != 0 {
                    maskbits += sp / 2;
                }
                in_header = 0;
                stbtt__buf_skip(&b, (maskbits + 7) / 8);
            }
            case 0x01, 0x03, 0x12, 0x17: {
                maskbits += sp / 2;
            }
            case 0x15: {
                in_header = 0;
                if sp < 2 {
                    return 0;
                }
                stbtt__csctx_rmove_to(c, s[sp - 2], s[sp - 1]);
            }
            case 0x04: {
                in_header = 0;
                if sp < 1 {
                    return 0;
                }
                stbtt__csctx_rmove_to(c, 0.0f, s[sp - 1]);
            }
            case 0x16: {
                in_header = 0;
                if sp < 1 {
                    return 0;
                }
                stbtt__csctx_rmove_to(c, s[sp - 1], 0.0f);
            }
            case 0x05: {
                if sp < 2 {
                    return 0;
                }
                for ; i + 1 < sp; i += 2 {
                    stbtt__csctx_rline_to(c, s[i], s[i + 1]);
                }
            }
            case 0x07: {
                if sp < 1 {
                    return 0;
                }
                // TODO transminc: goto vlineto
            }
            case 0x06: {
                if sp < 1 {
                    return 0;
                }
                while true {
                    if i >= sp {
                        break;
                    }
                    stbtt__csctx_rline_to(c, s[i], 0.0f);
                    i++;
                    // TODO transminc: label vlineto:
                    if i >= sp {
                        break;
                    }
                    stbtt__csctx_rline_to(c, 0.0f, s[i]);
                    i++;
                }
            }
            case 0x1F: {
                if sp < 4 {
                    return 0;
                }
                // TODO transminc: goto hvcurveto
            }
            case 0x1E: {
                if sp < 4 {
                    return 0;
                }
                while true {
                    if i + 3 >= sp {
                        break;
                    }
                    stbtt__csctx_rccurve_to(c, 0.0f, s[i], s[i + 1], s[i + 2], s[i + 3], sp - i == 5 ? s[i + 4] : 0.0f);
                    i += 4;
                    // TODO transminc: label hvcurveto:
                    if i + 3 >= sp {
                        break;
                    }
                    stbtt__csctx_rccurve_to(c, s[i], 0.0f, s[i + 1], s[i + 2], sp - i == 5 ? s[i + 4] : 0.0f, s[i + 3]);
                    i += 4;
                }
            }
            case 0x08: {
                if sp < 6 {
                    return 0;
                }
                for ; i + 5 < sp; i += 6 {
                    stbtt__csctx_rccurve_to(c, s[i], s[i + 1], s[i + 2], s[i + 3], s[i + 4], s[i + 5]);
                }
            }
            case 0x18: {
                if sp < 8 {
                    return 0;
                }
                for ; i + 5 < sp - 2; i += 6 {
                    stbtt__csctx_rccurve_to(c, s[i], s[i + 1], s[i + 2], s[i + 3], s[i + 4], s[i + 5]);
                }
                if i + 1 >= sp {
                    return 0;
                }
                stbtt__csctx_rline_to(c, s[i], s[i + 1]);
            }
            case 0x19: {
                if sp < 8 {
                    return 0;
                }
                for ; i + 1 < sp - 6; i += 2 {
                    stbtt__csctx_rline_to(c, s[i], s[i + 1]);
                }
                if i + 5 >= sp {
                    return 0;
                }
                stbtt__csctx_rccurve_to(c, s[i], s[i + 1], s[i + 2], s[i + 3], s[i + 4], s[i + 5]);
            }
            case 0x1A, 0x1B: {
                if sp < 4 {
                    return 0;
                }
                f = cast(f32, 0.0);
                if (sp & 1) != 0 {
                    f = s[i];
                    i++;
                }
                for ; i + 3 < sp; i += 4 {
                    if b0 == 0x1B {
                        stbtt__csctx_rccurve_to(c, s[i], f, s[i + 1], s[i + 2], s[i + 3], 0.0f);
                    } else {
                        stbtt__csctx_rccurve_to(c, f, s[i], s[i + 1], s[i + 2], 0.0f, s[i + 3]);
                    }
                    f = cast(f32, 0.0);
                }
            }
            case 0x0A: {
                if has_subrs == 0 {
                    if info.fdselect.size != 0 {
                        subrs = stbtt__cid_get_glyph_subrs(info, glyph_index);
                    }
                    has_subrs = 1;
                }
                fallthrough;
            }
            case 0x1D: {
                if sp < 1 {
                    return 0;
                }
                v = cast(i32, s[--sp]);
                if subr_stack_height >= 10 {
                    return 0;
                }
                subr_stack[subr_stack_height++] = b;
                b = stbtt__get_subr(b0 == 0x0A ? subrs : info.gsubrs, v);
                if b.size == 0 {
                    return 0;
                }
                b.cursor = 0;
                clear_stack = 0;
            }
            case 0x0B: {
                if subr_stack_height <= 0 {
                    return 0;
                }
                b = subr_stack[--subr_stack_height];
                clear_stack = 0;
            }
            case 0x0E: {
                stbtt__csctx_close_shape(c);
                return 1;
            }
            case 0x0C: {
                {
                    f32 dx1;
                    f32 dx2;
                    f32 dx3;
                    f32 dx4;
                    f32 dx5;
                    f32 dx6;
                    f32 dy1;
                    f32 dy2;
                    f32 dy3;
                    f32 dy4;
                    f32 dy5;
                    f32 dy6;
                    f32 dx;
                    f32 dy;
                    var b1 = cast(i32, stbtt__buf_get8(&b));
                    switch b1 {
                        case 0x22: {
                            if sp < 7 {
                                return 0;
                            }
                            dx1 = s[0];
                            dx2 = s[1];
                            dy2 = s[2];
                            dx3 = s[3];
                            dx4 = s[4];
                            dx5 = s[5];
                            dx6 = s[6];
                            stbtt__csctx_rccurve_to(c, dx1, 0.0f, dx2, dy2, dx3, 0.0f);
                            stbtt__csctx_rccurve_to(c, dx4, 0.0f, dx5, -dy2, dx6, 0.0f);
                        }
                        case 0x23: {
                            if sp < 13 {
                                return 0;
                            }
                            dx1 = s[0];
                            dy1 = s[1];
                            dx2 = s[2];
                            dy2 = s[3];
                            dx3 = s[4];
                            dy3 = s[5];
                            dx4 = s[6];
                            dy4 = s[7];
                            dx5 = s[8];
                            dy5 = s[9];
                            dx6 = s[10];
                            dy6 = s[11];
                            stbtt__csctx_rccurve_to(c, dx1, dy1, dx2, dy2, dx3, dy3);
                            stbtt__csctx_rccurve_to(c, dx4, dy4, dx5, dy5, dx6, dy6);
                        }
                        case 0x24: {
                            if sp < 9 {
                                return 0;
                            }
                            dx1 = s[0];
                            dy1 = s[1];
                            dx2 = s[2];
                            dy2 = s[3];
                            dx3 = s[4];
                            dx4 = s[5];
                            dx5 = s[6];
                            dy5 = s[7];
                            dx6 = s[8];
                            stbtt__csctx_rccurve_to(c, dx1, dy1, dx2, dy2, dx3, 0.0f);
                            stbtt__csctx_rccurve_to(c, dx4, 0.0f, dx5, dy5, dx6, -(dy1 + dy2 + dy5));
                        }
                        case 0x25: {
                            if sp < 11 {
                                return 0;
                            }
                            dx1 = s[0];
                            dy1 = s[1];
                            dx2 = s[2];
                            dy2 = s[3];
                            dx3 = s[4];
                            dy3 = s[5];
                            dx4 = s[6];
                            dy4 = s[7];
                            dx5 = s[8];
                            dy5 = s[9];
                            dy6 = s[10];
                            dx6 = dy6;
                            dx = dx1 + dx2 + dx3 + dx4 + dx5;
                            dy = dy1 + dy2 + dy3 + dy4 + dy5;
                            if fabs(dx) > fabs(dy) {
                                dy6 = -dy;
                            } else {
                                dx6 = -dx;
                            }
                            stbtt__csctx_rccurve_to(c, dx1, dy1, dx2, dy2, dx3, dy3);
                            stbtt__csctx_rccurve_to(c, dx4, dy4, dx5, dy5, dx6, dy6);
                        }
                        default: {
                            return 0;
                        }
                    }
                }
            }
            default: {
                if b0 != 255 && b0 != 28 && (b0 < 32 || b0 > 254) {
                    return 0;
                }
                if b0 == 255 {
                    f = cast(f32, stbtt__buf_get(&b, 4)) / 65536.0f;
                } else {
                    stbtt__buf_skip(&b, -1);
                    f = cast(f32, cast(stbtt_int16, stbtt__cff_int(&b)));
                }
                if sp >= 48 {
                    return 0;
                }
                s[sp++] = f;
                clear_stack = 0;
            }
        }
        if clear_stack != 0 {
            sp = 0;
        }
    }
    return 0;
}

i32 stbtt__GetGlyphShapeT2(stbtt_fontinfo* info, i32 glyph_index, stbtt_vertex** pvertices) {
    var count_ctx = stbtt__csctx{1, 0, 0.0f, 0.0f, 0.0f, 0.0f, 0, 0, 0, 0, null, 0};
    var output_ctx = stbtt__csctx{0, 0, 0.0f, 0.0f, 0.0f, 0.0f, 0, 0, 0, 0, null, 0};
    if stbtt__run_charstring(info, glyph_index, &count_ctx) != 0 {
        *pvertices = cast(stbtt_vertex*, fons__tmpalloc(cast(u64, count_ctx.num_vertices * sizeof(stbtt_vertex)), info.userdata));
        output_ctx.pvertices = *pvertices;
        if stbtt__run_charstring(info, glyph_index, &output_ctx) != 0 {
            return output_ctx.num_vertices;
        }
    }
    *pvertices = null;
    return 0;
}

i32 stbtt__GetGlyphInfoT2(stbtt_fontinfo* info, i32 glyph_index, i32* x0, i32* y0, i32* x1, i32* y1) {
    var c = stbtt__csctx{1, 0, 0.0f, 0.0f, 0.0f, 0.0f, 0, 0, 0, 0, null, 0};
    i32 r = stbtt__run_charstring(info, glyph_index, &c);
    if x0 != null {
        *x0 = r != 0 ? c.min_x : 0;
        *y0 = r != 0 ? c.min_y : 0;
        *x1 = r != 0 ? c.max_x : 0;
        *y1 = r != 0 ? c.max_y : 0;
    }
    return r != 0 ? c.num_vertices : 0;
}

i32 stbtt_GetGlyphShape(stbtt_fontinfo* info, i32 glyph_index, stbtt_vertex** pvertices) {
    if info.cff.size == 0 {
        return stbtt__GetGlyphShapeTT(info, glyph_index, pvertices);
    } else {
        return stbtt__GetGlyphShapeT2(info, glyph_index, pvertices);
    }
}

void stbtt_GetGlyphHMetrics(stbtt_fontinfo* info, i32 glyph_index, i32* advanceWidth, i32* leftSideBearing) {
    stbtt_uint16 numOfLongHorMetrics = ttUSHORT(info.data + info.hhea + 34);
    if glyph_index < cast(i32, numOfLongHorMetrics) {
        if advanceWidth != null {
            *advanceWidth = ttSHORT(info.data + info.hmtx + 4 * glyph_index);
        }
        if leftSideBearing != null {
            *leftSideBearing = ttSHORT(info.data + info.hmtx + 4 * glyph_index + 2);
        }
    } else {
        if advanceWidth != null {
            *advanceWidth = ttSHORT(info.data + info.hmtx + 4 * (numOfLongHorMetrics - 1));
        }
        if leftSideBearing != null {
            *leftSideBearing = ttSHORT(info.data + info.hmtx + 4 * numOfLongHorMetrics + 2 * (glyph_index - numOfLongHorMetrics));
        }
    }
}

i32 stbtt_GetGlyphKernAdvance(stbtt_fontinfo* info, i32 glyph1, i32 glyph2) {
    stbtt_uint8* data = info.data + info.kern;
    stbtt_uint32 needle;
    stbtt_uint32 straw;
    i32 l;
    i32 r;
    i32 m;
    if info.kern == 0 {
        return 0;
    }
    if ttUSHORT(data + 2) < 1 {
        return 0;
    }
    if ttUSHORT(data + 8) != 1 {
        return 0;
    }
    l = 0;
    r = cast(i32, ttUSHORT(data + 10) - 1);
    needle = cast(u32, glyph1 << 16 | glyph2);
    while l <= r {
        m = l + r >> 1;
        straw = ttULONG(data + 18 + m * 6);
        if needle < straw {
            r = m - 1;
        } else if needle > straw {
            l = m + 1;
        } else {
            return ttSHORT(data + 22 + m * 6);
        }
    }
    return 0;
}

i32 stbtt_GetCodepointKernAdvance(stbtt_fontinfo* info, i32 ch1, i32 ch2) {
    if info.kern == 0 {
        return 0;
    }
    return stbtt_GetGlyphKernAdvance(info, stbtt_FindGlyphIndex(info, ch1), stbtt_FindGlyphIndex(info, ch2));
}

void stbtt_GetCodepointHMetrics(stbtt_fontinfo* info, i32 codepoint, i32* advanceWidth, i32* leftSideBearing) {
    stbtt_GetGlyphHMetrics(info, stbtt_FindGlyphIndex(info, codepoint), advanceWidth, leftSideBearing);
}

void stbtt_GetFontVMetrics(stbtt_fontinfo* info, i32* ascent, i32* descent, i32* lineGap) {
    if ascent != null {
        *ascent = ttSHORT(info.data + info.hhea + 4);
    }
    if descent != null {
        *descent = ttSHORT(info.data + info.hhea + 6);
    }
    if lineGap != null {
        *lineGap = ttSHORT(info.data + info.hhea + 8);
    }
}

void stbtt_GetFontBoundingBox(stbtt_fontinfo* info, i32* x0, i32* y0, i32* x1, i32* y1) {
    *x0 = ttSHORT(info.data + info.head + 36);
    *y0 = ttSHORT(info.data + info.head + 38);
    *x1 = ttSHORT(info.data + info.head + 40);
    *y1 = ttSHORT(info.data + info.head + 42);
}

f32 stbtt_ScaleForPixelHeight(stbtt_fontinfo* info, f32 height) {
    i32 fheight = ttSHORT(info.data + info.hhea + 4) - ttSHORT(info.data + info.hhea + 6);
    return height / cast(f32, fheight);
}

f32 stbtt_ScaleForMappingEmToPixels(stbtt_fontinfo* info, f32 pixels) {
    var unitsPerEm = cast(i32, ttUSHORT(info.data + info.head + 18));
    return pixels / cast(f32, unitsPerEm);
}

void stbtt_FreeShape(stbtt_fontinfo* info, stbtt_vertex* v) {
    fons__tmpfree(v, info.userdata);
}

//////////////////////////////////////////////////////////////////////////////
//
// antialiasing software rasterizer
//
void stbtt_GetGlyphBitmapBoxSubpixel(stbtt_fontinfo* font, i32 glyph, f32 scale_x, f32 scale_y, f32 shift_x, f32 shift_y, i32* ix0, i32* iy0, i32* ix1, i32* iy1) {
    i32 x0 = 0;
    i32 y0 = 0;
    i32 x1;
    i32 y1;
    if stbtt_GetGlyphBox(font, glyph, &x0, &y0, &x1, &y1) == 0 {
        if ix0 != null {
            *ix0 = 0;
        }
        if iy0 != null {
            *iy0 = 0;
        }
        if ix1 != null {
            *ix1 = 0;
        }
        if iy1 != null {
            *iy1 = 0;
        }
    } else {
        if ix0 != null {
            *ix0 = cast(i32, floor(cast(f32, x0) * scale_x + shift_x));
        }
        if iy0 != null {
            *iy0 = cast(i32, floor(cast(f32, -y1) * scale_y + shift_y));
        }
        if ix1 != null {
            *ix1 = cast(i32, ceil(cast(f32, x1) * scale_x + shift_x));
        }
        if iy1 != null {
            *iy1 = cast(i32, ceil(cast(f32, -y0) * scale_y + shift_y));
        }
    }
}

void stbtt_GetGlyphBitmapBox(stbtt_fontinfo* font, i32 glyph, f32 scale_x, f32 scale_y, i32* ix0, i32* iy0, i32* ix1, i32* iy1) {
    stbtt_GetGlyphBitmapBoxSubpixel(font, glyph, scale_x, scale_y, 0.0f, 0.0f, ix0, iy0, ix1, iy1);
}

void stbtt_GetCodepointBitmapBoxSubpixel(stbtt_fontinfo* font, i32 codepoint, f32 scale_x, f32 scale_y, f32 shift_x, f32 shift_y, i32* ix0, i32* iy0, i32* ix1, i32* iy1) {
    stbtt_GetGlyphBitmapBoxSubpixel(font, stbtt_FindGlyphIndex(font, codepoint), scale_x, scale_y, shift_x, shift_y, ix0, iy0, ix1, iy1);
}

void stbtt_GetCodepointBitmapBox(stbtt_fontinfo* font, i32 codepoint, f32 scale_x, f32 scale_y, i32* ix0, i32* iy0, i32* ix1, i32* iy1) {
    stbtt_GetCodepointBitmapBoxSubpixel(font, codepoint, scale_x, scale_y, 0.0f, 0.0f, ix0, iy0, ix1, iy1);
}

void* stbtt__hheap_alloc(stbtt__hheap* hh, u64 size, void* userdata) {
    if hh.first_free != null {
        void* p = hh.first_free;
        hh.first_free = *cast(void**, p);
        return p;
    } else {
        if hh.num_remaining_in_head_chunk == 0 {
            i32 count = size < 32 ? 2000 : size < 128 ? 800 : 100;
            var c = cast(stbtt__hheap_chunk*, fons__tmpalloc(cast(u64, sizeof(stbtt__hheap_chunk)) + size * cast(u64, count), userdata));
            if c == null {
                return null;
            }
            c.next = hh.head;
            hh.head = c;
            hh.num_remaining_in_head_chunk = count;
        }
        --hh.num_remaining_in_head_chunk;
        return cast(u8*, hh.head) + size * cast(u64, hh.num_remaining_in_head_chunk);
    }
}

void stbtt__hheap_free(stbtt__hheap* hh, void* p) {
    *cast(void**, p) = hh.first_free;
    hh.first_free = p;
}

void stbtt__hheap_cleanup(stbtt__hheap* hh, void* userdata) {
    stbtt__hheap_chunk* c = hh.head;
    while c != null {
        stbtt__hheap_chunk* n = c.next;
        fons__tmpfree(c, userdata);
        c = n;
    }
}

stbtt__active_edge* stbtt__new_active(stbtt__hheap* hh, stbtt__edge* e, i32 off_x, f32 start_point, void* userdata) {
    var z = cast(stbtt__active_edge*, stbtt__hheap_alloc(hh, cast(u64, sizeof(stbtt__active_edge)), userdata));
    f32 dxdy = (e.x1 - e.x0) / (e.y1 - e.y0);
    if z == null {
        return z;
    }
    z.fdx = dxdy;
    z.fdy = dxdy != 0.0f ? 1.0f / dxdy : 0.0f;
    z.fx = e.x0 + dxdy * (start_point - e.y0);
    z.fx -= cast(f32, off_x);
    z.direction = e.invert != 0 ? 1.0f : -1.0f;
    z.sy = e.y0;
    z.ey = e.y1;
    z.next = null;
    return z;
}

// the edge passed in here does not cross the vertical line at x or the vertical line at x+1
// (i.e. it has already been clipped to those)
void stbtt__handle_clipped_edge(f32* scanline, i32 x, stbtt__active_edge* e, f32 x0, f32 y0, f32 x1, f32 y1) {
    if y0 == y1 {
        return;
    }
    if y0 > e.ey {
        return;
    }
    if y1 < e.sy {
        return;
    }
    if y0 < e.sy {
        x0 += (x1 - x0) * (e.sy - y0) / (y1 - y0);
        y0 = e.sy;
    }
    if y1 > e.ey {
        x1 += (x1 - x0) * (e.ey - y1) / (y1 - y0);
        y1 = e.ey;
    }
    if x0 == cast(f32, x) {
    } else if x0 == cast(f32, x + 1) {
    } else if x0 <= cast(f32, x) {
    } else if x0 >= cast(f32, x + 1) {
    } else {
    }
    if x0 <= cast(f32, x) && x1 <= cast(f32, x) {
        scanline[x] += e.direction * (y1 - y0);
    } else if x0 >= cast(f32, x + 1) && x1 >= cast(f32, x + 1) {
    } else {
        scanline[x] += e.direction * (y1 - y0) * (1.0f - (x0 - cast(f32, x) + (x1 - cast(f32, x))) / 2.0f);
    }
}

void stbtt__fill_active_edges_new(f32* scanline, f32* scanline_fill, i32 len, stbtt__active_edge* e, f32 y_top) {
    f32 y_bottom = y_top + 1.0f;
    while e != null {
        if e.fdx == 0.0f {
            f32 x0 = e.fx;
            if x0 < cast(f32, len) {
                if x0 >= 0.0f {
                    stbtt__handle_clipped_edge(scanline, cast(i32, x0), e, x0, y_top, x0, y_bottom);
                    stbtt__handle_clipped_edge(scanline_fill - 1, cast(i32, x0) + 1, e, x0, y_top, x0, y_bottom);
                } else {
                    stbtt__handle_clipped_edge(scanline_fill - 1, 0, e, x0, y_top, x0, y_bottom);
                }
            }
        } else {
            f32 x0 = e.fx;
            f32 dx = e.fdx;
            f32 xb = x0 + dx;
            f32 x_top;
            f32 x_bottom;
            f32 sy0;
            f32 sy1;
            f32 dy = e.fdy;
            if e.sy > y_top {
                x_top = x0 + dx * (e.sy - y_top);
                sy0 = e.sy;
            } else {
                x_top = x0;
                sy0 = y_top;
            }
            if e.ey < y_bottom {
                x_bottom = x0 + dx * (e.ey - y_top);
                sy1 = e.ey;
            } else {
                x_bottom = xb;
                sy1 = y_bottom;
            }
            if x_top >= 0.0f && x_bottom >= 0.0f && x_top < cast(f32, len) && x_bottom < cast(f32, len) {
                if cast(i32, x_top) == cast(i32, x_bottom) {
                    f32 height;
                    var x = cast(i32, x_top);
                    height = sy1 - sy0;
                    scanline[x] += e.direction * (1.0f - (x_top - cast(f32, x) + (x_bottom - cast(f32, x))) / 2.0f) * height;
                    scanline_fill[x] += e.direction * height;
                } else {
                    i32 x;
                    i32 x1;
                    i32 x2;
                    f32 y_crossing;
                    f32 step;
                    f32 sign;
                    f32 area;
                    if x_top > x_bottom {
                        f32 t;
                        sy0 = y_bottom - (sy0 - y_top);
                        sy1 = y_bottom - (sy1 - y_top);
                        t = sy0;
                        sy0 = sy1;
                        sy1 = t;
                        t = x_bottom;
                        x_bottom = x_top;
                        x_top = t;
                        dx = -dx;
                        dy = -dy;
                        t = x0;
                        x0 = xb;
                        xb = t;
                    }
                    x1 = cast(i32, x_top);
                    x2 = cast(i32, x_bottom);
                    y_crossing = (cast(f32, x1 + 1) - x0) * dy + y_top;
                    sign = e.direction;
                    area = sign * (y_crossing - sy0);
                    scanline[x1] += area * (1.0f - (x_top - cast(f32, x1) + cast(f32, x1 + 1 - x1)) / 2.0f);
                    step = sign * dy;
                    for x = x1 + 1; x < x2; ++x {
                        scanline[x] += area + step / 2.0f;
                        area += step;
                    }
                    y_crossing += dy * cast(f32, x2 - (x1 + 1));
                    scanline[x2] += area + sign * (1.0f - (cast(f32, x2 - x2) + (x_bottom - cast(f32, x2))) / 2.0f) * (sy1 - y_crossing);
                    scanline_fill[x2] += sign * (sy1 - sy0);
                }
            } else {
                i32 x;
                for x = 0; x < len; ++x {
                    f32 y0 = y_top;
                    var x1 = cast(f32, x);
                    var x2 = cast(f32, x + 1);
                    f32 x3 = xb;
                    f32 y3 = y_bottom;
                    f32 y1 = (cast(f32, x) - x0) / dx + y_top;
                    f32 y2 = (cast(f32, x + 1) - x0) / dx + y_top;
                    if x0 < x1 && x3 > x2 {
                        stbtt__handle_clipped_edge(scanline, x, e, x0, y0, x1, y1);
                        stbtt__handle_clipped_edge(scanline, x, e, x1, y1, x2, y2);
                        stbtt__handle_clipped_edge(scanline, x, e, x2, y2, x3, y3);
                    } else if x3 < x1 && x0 > x2 {
                        stbtt__handle_clipped_edge(scanline, x, e, x0, y0, x2, y2);
                        stbtt__handle_clipped_edge(scanline, x, e, x2, y2, x1, y1);
                        stbtt__handle_clipped_edge(scanline, x, e, x1, y1, x3, y3);
                    } else if x0 < x1 && x3 > x1 {
                        stbtt__handle_clipped_edge(scanline, x, e, x0, y0, x1, y1);
                        stbtt__handle_clipped_edge(scanline, x, e, x1, y1, x3, y3);
                    } else if x3 < x1 && x0 > x1 {
                        stbtt__handle_clipped_edge(scanline, x, e, x0, y0, x1, y1);
                        stbtt__handle_clipped_edge(scanline, x, e, x1, y1, x3, y3);
                    } else if x0 < x2 && x3 > x2 {
                        stbtt__handle_clipped_edge(scanline, x, e, x0, y0, x2, y2);
                        stbtt__handle_clipped_edge(scanline, x, e, x2, y2, x3, y3);
                    } else if x3 < x2 && x0 > x2 {
                        stbtt__handle_clipped_edge(scanline, x, e, x0, y0, x2, y2);
                        stbtt__handle_clipped_edge(scanline, x, e, x2, y2, x3, y3);
                    } else {
                        stbtt__handle_clipped_edge(scanline, x, e, x0, y0, x3, y3);
                    }
                }
            }
        }
        e = e.next;
    }
}

// directly AA rasterize edges w/o supersampling
void stbtt__rasterize_sorted_edges(stbtt__bitmap* result, stbtt__edge* e, i32 n, i32 vsubsample, i32 off_x, i32 off_y, void* userdata) {
    stbtt__hheap hh;
    stbtt__active_edge* active = null;
    i32 y;
    i32 j = 0;
    i32 i;
    noinit f32[129] scanline_data;
    f32* scanline;
    f32* scanline2;
    ignore vsubsample;
    if result.w > 64 {
        scanline = cast(f32*, fons__tmpalloc(cast(u64, (result.w * 2 + 1) * sizeof(f32)), userdata));
    } else {
        scanline = scanline_data;
    }
    scanline2 = scanline + result.w;
    y = off_y;
    e[n].y0 = cast(f32, off_y + result.h) + 1.0f;
    while j < result.h {
        f32 scan_y_top = cast(f32, y) + 0.0f;
        f32 scan_y_bottom = cast(f32, y) + 1.0f;
        stbtt__active_edge** step = &active;
        memset(scanline, 0, cast(u64, result.w * sizeof(scanline[0])));
        memset(scanline2, 0, cast(u64, (result.w + 1) * sizeof(scanline[0])));
        while *step != null {
            stbtt__active_edge* z = *step;
            if z.ey <= scan_y_top {
                *step = z.next;
                z.direction = 0.0f;
                stbtt__hheap_free(&hh, z);
            } else {
                step = &(*step).next;
            }
        }
        while e.y0 <= scan_y_bottom {
            if e.y0 != e.y1 {
                stbtt__active_edge* z = stbtt__new_active(&hh, e, off_x, scan_y_top, userdata);
                if z != null {
                    z.next = active;
                    active = z;
                }
            }
            ++e;
        }
        if active != null {
            stbtt__fill_active_edges_new(scanline, scanline2 + 1, result.w, active, scan_y_top);
        }
        {
            f32 sum = 0.0f;
            for i = 0; i < result.w; ++i {
                f32 k;
                i32 m;
                sum += scanline2[i];
                k = scanline[i] + sum;
                k = cast(f32, fabs(k)) * 255.0f + 0.5f;
                m = cast(i32, k);
                if m > 255 {
                    m = 255;
                }
                result.pixels[j * result.stride + i] = cast(u8, m);
            }
        }
        step = &active;
        while *step != null {
            stbtt__active_edge* z = *step;
            z.fx += z.fdx;
            step = &(*step).next;
        }
        ++y;
        ++j;
    }
    stbtt__hheap_cleanup(&hh, userdata);
    if scanline != scanline_data {
        fons__tmpfree(scanline, userdata);
    }
}

void stbtt__sort_edges_ins_sort(stbtt__edge* p, i32 n) {
    i32 i;
    i32 j;
    for i = 1; i < n; ++i {
        stbtt__edge t = p[i];
        stbtt__edge* a = &t;
        j = i;
        while j > 0 {
            stbtt__edge* b = &p[j - 1];
            i32 c = a.y0 < b.y0;
            if c == 0 {
                break;
            }
            p[j] = p[j - 1];
            --j;
        }
        if i != j {
            p[j] = t;
        }
    }
}

void stbtt__sort_edges_quicksort(stbtt__edge* p, i32 n) {
    while n > 12 {
        noinit stbtt__edge t;
        i32 c01;
        i32 c12;
        i32 c;
        i32 m;
        i32 i;
        i32 j;
        m = n >> 1;
        c01 = p[0].y0 < p[m].y0;
        c12 = p[m].y0 < p[n - 1].y0;
        if c01 != c12 {
            i32 z;
            c = p[0].y0 < p[n - 1].y0;
            z = c == c12 ? 0 : n - 1;
            t = p[z];
            p[z] = p[m];
            p[m] = t;
        }
        t = p[0];
        p[0] = p[m];
        p[m] = t;
        i = 1;
        j = n - 1;
        while true {
            for ; true; ++i {
                if p[i].y0 < p[0].y0 == 0 {
                    break;
                }
            }
            for ; true; --j {
                if p[0].y0 < p[j].y0 == 0 {
                    break;
                }
            }
            if i >= j {
                break;
            }
            t = p[i];
            p[i] = p[j];
            p[j] = t;
            ++i;
            --j;
        }
        if j < n - i {
            stbtt__sort_edges_quicksort(p, j);
            p = p + i;
            n = n - i;
        } else {
            stbtt__sort_edges_quicksort(p + i, n - i);
            n = j;
        }
    }
}

void stbtt__sort_edges(stbtt__edge* p, i32 n) {
    stbtt__sort_edges_quicksort(p, n);
    stbtt__sort_edges_ins_sort(p, n);
}

void stbtt__rasterize(stbtt__bitmap* result, stbtt__point* pts, i32* wcount, i32 windings, f32 scale_x, f32 scale_y, f32 shift_x, f32 shift_y, i32 off_x, i32 off_y, i32 invert, void* userdata) {
    f32 y_scale_inv = invert != 0 ? -scale_y : scale_y;
    stbtt__edge* e;
    i32 n;
    i32 i;
    i32 j;
    i32 k;
    i32 m;
    i32 vsubsample = 1;
    n = 0;
    for i = 0; i < windings; ++i {
        n += wcount[i];
    }
    e = cast(stbtt__edge*, fons__tmpalloc(cast(u64, sizeof(*e) * (n + 1)), userdata));
    if e == null {
        return;
    }
    n = 0;
    m = 0;
    for i = 0; i < windings; ++i {
        stbtt__point* p = pts + m;
        m += wcount[i];
        j = wcount[i] - 1;
        for k = 0; k < wcount[i]; j = k++ {
            i32 a = k;
            i32 b = j;
            if p[j].y == p[k].y {
                continue;
            }
            e[n].invert = 0;
            if (invert != 0 ? p[j].y > p[k].y : p[j].y < p[k].y) != 0 {
                e[n].invert = 1;
                a = j;
                b = k;
            }
            e[n].x0 = p[a].x * scale_x + shift_x;
            e[n].y0 = (p[a].y * y_scale_inv + shift_y) * cast(f32, vsubsample);
            e[n].x1 = p[b].x * scale_x + shift_x;
            e[n].y1 = (p[b].y * y_scale_inv + shift_y) * cast(f32, vsubsample);
            ++n;
        }
    }
    stbtt__sort_edges(e, n);
    stbtt__rasterize_sorted_edges(result, e, n, vsubsample, off_x, off_y, userdata);
    fons__tmpfree(e, userdata);
}

void stbtt__add_point(stbtt__point* points, i32 n, f32 x, f32 y) {
    if points == null {
        return;
    }
    points[n].x = x;
    points[n].y = y;
}

// tesselate until threshhold p is happy... @TODO warped to compensate for non-linear stretching
i32 stbtt__tesselate_curve(stbtt__point* points, i32* num_points, f32 x0, f32 y0, f32 x1, f32 y1, f32 x2, f32 y2, f32 objspace_flatness_squared, i32 n) {
    f32 mx = (x0 + 2.0f * x1 + x2) / 4.0f;
    f32 my = (y0 + 2.0f * y1 + y2) / 4.0f;
    f32 dx = (x0 + x2) / 2.0f - mx;
    f32 dy = (y0 + y2) / 2.0f - my;
    if n > 16 {
        return 1;
    }
    if dx * dx + dy * dy > objspace_flatness_squared {
        stbtt__tesselate_curve(points, num_points, x0, y0, (x0 + x1) / 2.0f, (y0 + y1) / 2.0f, mx, my, objspace_flatness_squared, n + 1);
        stbtt__tesselate_curve(points, num_points, mx, my, (x1 + x2) / 2.0f, (y1 + y2) / 2.0f, x2, y2, objspace_flatness_squared, n + 1);
    } else {
        stbtt__add_point(points, *num_points, x2, y2);
        *num_points = *num_points + 1;
    }
    return 1;
}

void stbtt__tesselate_cubic(stbtt__point* points, i32* num_points, f32 x0, f32 y0, f32 x1, f32 y1, f32 x2, f32 y2, f32 x3, f32 y3, f32 objspace_flatness_squared, i32 n) {
    f32 dx0 = x1 - x0;
    f32 dy0 = y1 - y0;
    f32 dx1 = x2 - x1;
    f32 dy1 = y2 - y1;
    f32 dx2 = x3 - x2;
    f32 dy2 = y3 - y2;
    f32 dx = x3 - x0;
    f32 dy = y3 - y0;
    var longlen = cast(f32, sqrt(dx0 * dx0 + dy0 * dy0) + sqrt(dx1 * dx1 + dy1 * dy1) + sqrt(dx2 * dx2 + dy2 * dy2));
    var shortlen = cast(f32, sqrt(dx * dx + dy * dy));
    f32 flatness_squared = longlen * longlen - shortlen * shortlen;
    if n > 16 {
        return;
    }
    if flatness_squared > objspace_flatness_squared {
        f32 x01 = (x0 + x1) / 2.0f;
        f32 y01 = (y0 + y1) / 2.0f;
        f32 x12 = (x1 + x2) / 2.0f;
        f32 y12 = (y1 + y2) / 2.0f;
        f32 x23 = (x2 + x3) / 2.0f;
        f32 y23 = (y2 + y3) / 2.0f;
        f32 xa = (x01 + x12) / 2.0f;
        f32 ya = (y01 + y12) / 2.0f;
        f32 xb = (x12 + x23) / 2.0f;
        f32 yb = (y12 + y23) / 2.0f;
        f32 mx = (xa + xb) / 2.0f;
        f32 my = (ya + yb) / 2.0f;
        stbtt__tesselate_cubic(points, num_points, x0, y0, x01, y01, xa, ya, mx, my, objspace_flatness_squared, n + 1);
        stbtt__tesselate_cubic(points, num_points, mx, my, xb, yb, x23, y23, x3, y3, objspace_flatness_squared, n + 1);
    } else {
        stbtt__add_point(points, *num_points, x3, y3);
        *num_points = *num_points + 1;
    }
}

// returns number of contours
stbtt__point* stbtt_FlattenCurves(stbtt_vertex* vertices, i32 num_verts, f32 objspace_flatness, i32** contour_lengths, i32* num_contours, void* userdata) {
    stbtt__point* points = null;
    i32 num_points = 0;
    f32 objspace_flatness_squared = objspace_flatness * objspace_flatness;
    i32 i;
    i32 n = 0;
    i32 start = 0;
    i32 pass;
    for i = 0; i < num_verts; ++i {
        if cast(i32, vertices[i].type) == STBTT_vmove {
            ++n;
        }
    }
    *num_contours = n;
    if n == 0 {
        return null;
    }
    *contour_lengths = cast(i32*, fons__tmpalloc(cast(u64, sizeof(**contour_lengths) * n), userdata));
    if *contour_lengths == null {
        *num_contours = 0;
        return null;
    }
    for pass = 0; pass < 2; ++pass {
        f32 x = 0.0f;
        f32 y = 0.0f;
        if pass == 1 {
            points = cast(stbtt__point*, fons__tmpalloc(cast(u64, num_points * sizeof(points[0])), userdata));
            if points == null {
                fons__tmpfree(points, userdata);
                fons__tmpfree(*contour_lengths, userdata);
                *contour_lengths = null;
                *num_contours = 0;
                return null;
            }
        }
        num_points = 0;
        n = -1;
        for i = 0; i < num_verts; ++i {
            switch vertices[i].type {
                case STBTT_vmove: {
                    if n >= 0 {
                        (*contour_lengths)[n] = num_points - start;
                    }
                    ++n;
                    start = num_points;
                    x = cast(f32, vertices[i].x);
                    y = cast(f32, vertices[i].y);
                    stbtt__add_point(points, num_points++, x, y);
                }
                case STBTT_vline: {
                    x = cast(f32, vertices[i].x);
                    y = cast(f32, vertices[i].y);
                    stbtt__add_point(points, num_points++, x, y);
                }
                case STBTT_vcurve: {
                    stbtt__tesselate_curve(points, &num_points, x, y, cast(f32, vertices[i].cx), cast(f32, vertices[i].cy), cast(f32, vertices[i].x), cast(f32, vertices[i].y), objspace_flatness_squared, 0);
                    x = cast(f32, vertices[i].x);
                    y = cast(f32, vertices[i].y);
                }
                case STBTT_vcubic: {
                    stbtt__tesselate_cubic(points, &num_points, x, y, cast(f32, vertices[i].cx), cast(f32, vertices[i].cy), cast(f32, vertices[i].cx1), cast(f32, vertices[i].cy1), cast(f32, vertices[i].x), cast(f32, vertices[i].y), objspace_flatness_squared, 0);
                    x = cast(f32, vertices[i].x);
                    y = cast(f32, vertices[i].y);
                }
            }
        }
        (*contour_lengths)[n] = num_points - start;
    }
    return points;
}

void stbtt_Rasterize(stbtt__bitmap* result, f32 flatness_in_pixels, stbtt_vertex* vertices, i32 num_verts, f32 scale_x, f32 scale_y, f32 shift_x, f32 shift_y, i32 x_off, i32 y_off, i32 invert, void* userdata) {
    f32 scale = scale_x > scale_y ? scale_y : scale_x;
    i32 winding_count;
    i32* winding_lengths;
    stbtt__point* windings = stbtt_FlattenCurves(vertices, num_verts, flatness_in_pixels / scale, &winding_lengths, &winding_count, userdata);
    if windings != null {
        stbtt__rasterize(result, windings, winding_lengths, winding_count, scale_x, scale_y, shift_x, shift_y, x_off, y_off, invert, userdata);
        fons__tmpfree(winding_lengths, userdata);
        fons__tmpfree(windings, userdata);
    }
}

void stbtt_FreeBitmap(u8* bitmap, void* userdata) {
    fons__tmpfree(bitmap, userdata);
}

u8* stbtt_GetGlyphBitmapSubpixel(stbtt_fontinfo* info, f32 scale_x, f32 scale_y, f32 shift_x, f32 shift_y, i32 glyph, i32* width, i32* height, i32* xoff, i32* yoff) {
    i32 ix0;
    i32 iy0;
    i32 ix1;
    i32 iy1;
    noinit stbtt__bitmap gbm;
    stbtt_vertex* vertices;
    i32 num_verts = stbtt_GetGlyphShape(info, glyph, &vertices);
    if scale_x == 0.0f {
        scale_x = scale_y;
    }
    if scale_y == 0.0f {
        if scale_x == 0.0f {
            fons__tmpfree(vertices, info.userdata);
            return null;
        }
        scale_y = scale_x;
    }
    stbtt_GetGlyphBitmapBoxSubpixel(info, glyph, scale_x, scale_y, shift_x, shift_y, &ix0, &iy0, &ix1, &iy1);
    gbm.w = ix1 - ix0;
    gbm.h = iy1 - iy0;
    gbm.pixels = null;
    if width != null {
        *width = gbm.w;
    }
    if height != null {
        *height = gbm.h;
    }
    if xoff != null {
        *xoff = ix0;
    }
    if yoff != null {
        *yoff = iy0;
    }
    if gbm.w && gbm.h {
        gbm.pixels = cast(u8*, fons__tmpalloc(cast(u64, gbm.w * gbm.h), info.userdata));
        if gbm.pixels != null {
            gbm.stride = gbm.w;
            stbtt_Rasterize(&gbm, 0.35f, vertices, num_verts, scale_x, scale_y, shift_x, shift_y, ix0, iy0, 1, info.userdata);
        }
    }
    fons__tmpfree(vertices, info.userdata);
    return gbm.pixels;
}

u8* stbtt_GetGlyphBitmap(stbtt_fontinfo* info, f32 scale_x, f32 scale_y, i32 glyph, i32* width, i32* height, i32* xoff, i32* yoff) {
    return stbtt_GetGlyphBitmapSubpixel(info, scale_x, scale_y, 0.0f, 0.0f, glyph, width, height, xoff, yoff);
}

void stbtt_MakeGlyphBitmapSubpixel(stbtt_fontinfo* info, u8* output, i32 out_w, i32 out_h, i32 out_stride, f32 scale_x, f32 scale_y, f32 shift_x, f32 shift_y, i32 glyph) {
    i32 ix0;
    i32 iy0;
    stbtt_vertex* vertices;
    i32 num_verts = stbtt_GetGlyphShape(info, glyph, &vertices);
    noinit stbtt__bitmap gbm;
    stbtt_GetGlyphBitmapBoxSubpixel(info, glyph, scale_x, scale_y, shift_x, shift_y, &ix0, &iy0, null, null);
    gbm.pixels = output;
    gbm.w = out_w;
    gbm.h = out_h;
    gbm.stride = out_stride;
    if gbm.w && gbm.h {
        stbtt_Rasterize(&gbm, 0.35f, vertices, num_verts, scale_x, scale_y, shift_x, shift_y, ix0, iy0, 1, info.userdata);
    }
    fons__tmpfree(vertices, info.userdata);
}

void stbtt_MakeGlyphBitmap(stbtt_fontinfo* info, u8* output, i32 out_w, i32 out_h, i32 out_stride, f32 scale_x, f32 scale_y, i32 glyph) {
    stbtt_MakeGlyphBitmapSubpixel(info, output, out_w, out_h, out_stride, scale_x, scale_y, 0.0f, 0.0f, glyph);
}

u8* stbtt_GetCodepointBitmapSubpixel(stbtt_fontinfo* info, f32 scale_x, f32 scale_y, f32 shift_x, f32 shift_y, i32 codepoint, i32* width, i32* height, i32* xoff, i32* yoff) {
    return stbtt_GetGlyphBitmapSubpixel(info, scale_x, scale_y, shift_x, shift_y, stbtt_FindGlyphIndex(info, codepoint), width, height, xoff, yoff);
}

void stbtt_MakeCodepointBitmapSubpixel(stbtt_fontinfo* info, u8* output, i32 out_w, i32 out_h, i32 out_stride, f32 scale_x, f32 scale_y, f32 shift_x, f32 shift_y, i32 codepoint) {
    stbtt_MakeGlyphBitmapSubpixel(info, output, out_w, out_h, out_stride, scale_x, scale_y, shift_x, shift_y, stbtt_FindGlyphIndex(info, codepoint));
}

u8* stbtt_GetCodepointBitmap(stbtt_fontinfo* info, f32 scale_x, f32 scale_y, i32 codepoint, i32* width, i32* height, i32* xoff, i32* yoff) {
    return stbtt_GetCodepointBitmapSubpixel(info, scale_x, scale_y, 0.0f, 0.0f, codepoint, width, height, xoff, yoff);
}

void stbtt_MakeCodepointBitmap(stbtt_fontinfo* info, u8* output, i32 out_w, i32 out_h, i32 out_stride, f32 scale_x, f32 scale_y, i32 codepoint) {
    stbtt_MakeCodepointBitmapSubpixel(info, output, out_w, out_h, out_stride, scale_x, scale_y, 0.0f, 0.0f, codepoint);
}

//////////////////////////////////////////////////////////////////////////////
//
// bitmap baking
//
// This is SUPER-CRAPPY packing to keep source code small
i32 stbtt_BakeFontBitmap_internal(u8* data, i32 offset, f32 pixel_height, u8* pixels, i32 pw, i32 ph, i32 first_char, i32 num_chars, stbtt_bakedchar* chardata) {
    f32 scale;
    i32 x;
    i32 y;
    i32 bottom_y;
    i32 i;
    noinit stbtt_fontinfo f;
    f.userdata = null;
    if stbtt_InitFont(&f, data, offset) == 0 {
        return -1;
    }
    memset(pixels, 0, cast(u64, pw * ph));
    y = 1;
    x = y;
    bottom_y = 1;
    scale = stbtt_ScaleForPixelHeight(&f, pixel_height);
    for i = 0; i < num_chars; ++i {
        i32 advance;
        i32 lsb;
        i32 x0;
        i32 y0;
        i32 x1;
        i32 y1;
        i32 gw;
        i32 gh;
        i32 g = stbtt_FindGlyphIndex(&f, first_char + i);
        stbtt_GetGlyphHMetrics(&f, g, &advance, &lsb);
        stbtt_GetGlyphBitmapBox(&f, g, scale, scale, &x0, &y0, &x1, &y1);
        gw = x1 - x0;
        gh = y1 - y0;
        if x + gw + 1 >= pw {
            y = bottom_y;
            x = 1;
        }
        if y + gh + 1 >= ph {
            return -i;
        }
        stbtt_MakeGlyphBitmap(&f, pixels + x + y * pw, gw, gh, pw, scale, scale, g);
        chardata[i].x0 = cast(u16, cast(stbtt_int16, x));
        chardata[i].y0 = cast(u16, cast(stbtt_int16, y));
        chardata[i].x1 = cast(u16, cast(stbtt_int16, x + gw));
        chardata[i].y1 = cast(u16, cast(stbtt_int16, y + gh));
        chardata[i].xadvance = scale * cast(f32, advance);
        chardata[i].xoff = cast(f32, x0);
        chardata[i].yoff = cast(f32, y0);
        x = x + gw + 1;
        if y + gh + 1 > bottom_y {
            bottom_y = y + gh + 1;
        }
    }
    return bottom_y;
}

void stbtt_GetBakedQuad(stbtt_bakedchar* chardata, i32 pw, i32 ph, i32 char_index, f32* xpos, f32* ypos, stbtt_aligned_quad* q, i32 opengl_fillrule) {
    var d3d_bias = cast(f32, opengl_fillrule != 0 ? 0.0f : -0.5f);
    f32 ipw = 1.0f / cast(f32, pw);
    f32 iph = 1.0f / cast(f32, ph);
    stbtt_bakedchar* b = chardata + char_index;
    var round_x = cast(i32, floor(*xpos + b.xoff + 0.5f));
    var round_y = cast(i32, floor(*ypos + b.yoff + 0.5f));
    q.x0 = cast(f32, round_x) + d3d_bias;
    q.y0 = cast(f32, round_y) + d3d_bias;
    q.x1 = cast(f32, round_x + b.x1 - b.x0) + d3d_bias;
    q.y1 = cast(f32, round_y + b.y1 - b.y0) + d3d_bias;
    q.s0 = cast(f32, b.x0) * ipw;
    q.t0 = cast(f32, b.y0) * iph;
    q.s1 = cast(f32, b.x1) * ipw;
    q.t1 = cast(f32, b.y1) * iph;
    *xpos += b.xadvance;
}
}
//////////////////////////////////////////////////////////////////////////////
//
// rectangle packing replacement routines if you don't have stb_rect_pack.h
//
when !(defined(STB_RECT_PACK_VERSION)) {

private {
void stbrp_init_target(stbrp_context* con, i32 pw, i32 ph, stbrp_node* nodes, i32 num_nodes) {
    con.width = pw;
    con.height = ph;
    con.x = 0;
    con.y = 0;
    con.bottom_y = 0;
    ignore nodes;
    ignore num_nodes;
}

void stbrp_pack_rects(stbrp_context* con, stbrp_rect* rects, i32 num_rects) {
    i32 i;
    for i = 0; i < num_rects; ++i {
        if con.x + rects[i].w > con.width {
            con.x = 0;
            con.y = con.bottom_y;
        }
        if con.y + rects[i].h > con.height {
            break;
        }
        rects[i].x = con.x;
        rects[i].y = con.y;
        rects[i].was_packed = 1;
        con.x += rects[i].w;
        if con.y + rects[i].h > con.bottom_y {
            con.bottom_y = con.y + rects[i].h;
        }
    }
    for ; i < num_rects; ++i {
        rects[i].was_packed = 0;
    }
}
}
}

//////////////////////////////////////////////////////////////////////////////
//
// bitmap baking
//
// This is SUPER-AWESOME (tm Ryan Gordon) packing using stb_rect_pack.h. If
// stb_rect_pack.h isn't available, it uses the BakeFontBitmap strategy.
private {
i32 stbtt_PackBegin(stbtt_pack_context* spc, u8* pixels, i32 pw, i32 ph, i32 stride_in_bytes, i32 padding, void* alloc_context) {
    var context = cast(stbrp_context*, fons__tmpalloc(cast(u64, sizeof(stbrp_context)), alloc_context));
    i32 num_nodes = pw - padding;
    var nodes = cast(stbrp_node*, fons__tmpalloc(cast(u64, sizeof(stbrp_node) * num_nodes), alloc_context));
    if context == null || nodes == null {
        if context != null {
            fons__tmpfree(context, alloc_context);
        }
        if nodes != null {
            fons__tmpfree(nodes, alloc_context);
        }
        return 0;
    }
    spc.user_allocator_context = alloc_context;
    spc.width = pw;
    spc.height = ph;
    spc.pixels = pixels;
    spc.pack_info = context;
    spc.nodes = nodes;
    spc.padding = padding;
    spc.stride_in_bytes = stride_in_bytes != 0 ? stride_in_bytes : pw;
    spc.h_oversample = 1;
    spc.v_oversample = 1;
    stbrp_init_target(context, pw - padding, ph - padding, nodes, num_nodes);
    if pixels != null {
        memset(pixels, 0, cast(u64, pw * ph));
    }
    return 1;
}

void stbtt_PackEnd(stbtt_pack_context* spc) {
    fons__tmpfree(spc.nodes, spc.user_allocator_context);
    fons__tmpfree(spc.pack_info, spc.user_allocator_context);
}

void stbtt_PackSetOversampling(stbtt_pack_context* spc, u32 h_oversample, u32 v_oversample) {
    if h_oversample <= 8 {
        spc.h_oversample = h_oversample;
    }
    if v_oversample <= 8 {
        spc.v_oversample = v_oversample;
    }
}

void stbtt__h_prefilter(u8* pixels, i32 w, i32 h, i32 stride_in_bytes, u32 kernel_width) {
    noinit u8[8] buffer;
    var safe_w = cast(i32, cast(u32, w) - kernel_width);
    i32 j;
    memset(buffer, 0, cast(u64, 8));
    for j = 0; j < h; ++j {
        i32 i;
        u32 total;
        memset(buffer, 0, cast(u64, kernel_width));
        total = 0;
        switch kernel_width {
            case 2: {
                for i = 0; i <= safe_w; ++i {
                    total += pixels[i] - buffer[i & 8 - 1];
                    buffer[cast(u32, i) + kernel_width & cast(u32, 8 - 1)] = pixels[i];
                    pixels[i] = cast(u8, total / 2);
                }
            }
            case 3: {
                for i = 0; i <= safe_w; ++i {
                    total += pixels[i] - buffer[i & 8 - 1];
                    buffer[cast(u32, i) + kernel_width & cast(u32, 8 - 1)] = pixels[i];
                    pixels[i] = cast(u8, total / 3);
                }
            }
            case 4: {
                for i = 0; i <= safe_w; ++i {
                    total += pixels[i] - buffer[i & 8 - 1];
                    buffer[cast(u32, i) + kernel_width & cast(u32, 8 - 1)] = pixels[i];
                    pixels[i] = cast(u8, total / 4);
                }
            }
            case 5: {
                for i = 0; i <= safe_w; ++i {
                    total += pixels[i] - buffer[i & 8 - 1];
                    buffer[cast(u32, i) + kernel_width & cast(u32, 8 - 1)] = pixels[i];
                    pixels[i] = cast(u8, total / 5);
                }
            }
            default: {
                for i = 0; i <= safe_w; ++i {
                    total += pixels[i] - buffer[i & 8 - 1];
                    buffer[cast(u32, i) + kernel_width & cast(u32, 8 - 1)] = pixels[i];
                    pixels[i] = cast(u8, total / kernel_width);
                }
            }
        }
        for ; i < w; ++i {
            total -= buffer[i & 8 - 1];
            pixels[i] = cast(u8, total / kernel_width);
        }
        pixels += stride_in_bytes;
    }
}

void stbtt__v_prefilter(u8* pixels, i32 w, i32 h, i32 stride_in_bytes, u32 kernel_width) {
    noinit u8[8] buffer;
    var safe_h = cast(i32, cast(u32, h) - kernel_width);
    i32 j;
    memset(buffer, 0, cast(u64, 8));
    for j = 0; j < w; ++j {
        i32 i;
        u32 total;
        memset(buffer, 0, cast(u64, kernel_width));
        total = 0;
        switch kernel_width {
            case 2: {
                for i = 0; i <= safe_h; ++i {
                    total += pixels[i * stride_in_bytes] - buffer[i & 8 - 1];
                    buffer[cast(u32, i) + kernel_width & cast(u32, 8 - 1)] = pixels[i * stride_in_bytes];
                    pixels[i * stride_in_bytes] = cast(u8, total / 2);
                }
            }
            case 3: {
                for i = 0; i <= safe_h; ++i {
                    total += pixels[i * stride_in_bytes] - buffer[i & 8 - 1];
                    buffer[cast(u32, i) + kernel_width & cast(u32, 8 - 1)] = pixels[i * stride_in_bytes];
                    pixels[i * stride_in_bytes] = cast(u8, total / 3);
                }
            }
            case 4: {
                for i = 0; i <= safe_h; ++i {
                    total += pixels[i * stride_in_bytes] - buffer[i & 8 - 1];
                    buffer[cast(u32, i) + kernel_width & cast(u32, 8 - 1)] = pixels[i * stride_in_bytes];
                    pixels[i * stride_in_bytes] = cast(u8, total / 4);
                }
            }
            case 5: {
                for i = 0; i <= safe_h; ++i {
                    total += pixels[i * stride_in_bytes] - buffer[i & 8 - 1];
                    buffer[cast(u32, i) + kernel_width & cast(u32, 8 - 1)] = pixels[i * stride_in_bytes];
                    pixels[i * stride_in_bytes] = cast(u8, total / 5);
                }
            }
            default: {
                for i = 0; i <= safe_h; ++i {
                    total += pixels[i * stride_in_bytes] - buffer[i & 8 - 1];
                    buffer[cast(u32, i) + kernel_width & cast(u32, 8 - 1)] = pixels[i * stride_in_bytes];
                    pixels[i * stride_in_bytes] = cast(u8, total / kernel_width);
                }
            }
        }
        for ; i < h; ++i {
            total -= buffer[i & 8 - 1];
            pixels[i * stride_in_bytes] = cast(u8, total / kernel_width);
        }
        pixels += 1;
    }
}

f32 stbtt__oversample_shift(i32 oversample) {
    if oversample == 0 {
        return 0.0f;
    }
    return cast(f32, -(oversample - 1)) / (2.0f * cast(f32, oversample));
}

// rects array must be big enough to accommodate all characters in the given ranges
i32 stbtt_PackFontRangesGatherRects(stbtt_pack_context* spc, stbtt_fontinfo* info, stbtt_pack_range* ranges, i32 num_ranges, stbrp_rect* rects) {
    i32 i;
    i32 j;
    i32 k;
    k = 0;
    for i = 0; i < num_ranges; ++i {
        f32 fh = ranges[i].font_size;
        f32 scale = fh > 0.0f ? stbtt_ScaleForPixelHeight(info, fh) : stbtt_ScaleForMappingEmToPixels(info, -fh);
        ranges[i].h_oversample = cast(u8, spc.h_oversample);
        ranges[i].v_oversample = cast(u8, spc.v_oversample);
        for j = 0; j < ranges[i].num_chars; ++j {
            i32 x0;
            i32 y0;
            i32 x1;
            i32 y1;
            i32 codepoint = ranges[i].array_of_unicode_codepoints == null ? ranges[i].first_unicode_codepoint_in_range + j : ranges[i].array_of_unicode_codepoints[j];
            i32 glyph = stbtt_FindGlyphIndex(info, codepoint);
            stbtt_GetGlyphBitmapBoxSubpixel(info, glyph, scale * cast(f32, spc.h_oversample), scale * cast(f32, spc.v_oversample), 0.0f, 0.0f, &x0, &y0, &x1, &y1);
            rects[k].w = cast(stbrp_coord, cast(u32, x1 - x0 + spc.padding) + spc.h_oversample - 1);
            rects[k].h = cast(stbrp_coord, cast(u32, y1 - y0 + spc.padding) + spc.v_oversample - 1);
            ++k;
        }
    }
    return k;
}

void stbtt_MakeGlyphBitmapSubpixelPrefilter(stbtt_fontinfo* info, u8* output, i32 out_w, i32 out_h, i32 out_stride, f32 scale_x, f32 scale_y, f32 shift_x, f32 shift_y, i32 prefilter_x, i32 prefilter_y, f32* sub_x, f32* sub_y, i32 glyph) {
    stbtt_MakeGlyphBitmapSubpixel(info, output, out_w - (prefilter_x - 1), out_h - (prefilter_y - 1), out_stride, scale_x, scale_y, shift_x, shift_y, glyph);
    if prefilter_x > 1 {
        stbtt__h_prefilter(output, out_w, out_h, out_stride, cast(u32, prefilter_x));
    }
    if prefilter_y > 1 {
        stbtt__v_prefilter(output, out_w, out_h, out_stride, cast(u32, prefilter_y));
    }
    *sub_x = stbtt__oversample_shift(prefilter_x);
    *sub_y = stbtt__oversample_shift(prefilter_y);
}

// rects array must be big enough to accommodate all characters in the given ranges
i32 stbtt_PackFontRangesRenderIntoRects(stbtt_pack_context* spc, stbtt_fontinfo* info, stbtt_pack_range* ranges, i32 num_ranges, stbrp_rect* rects) {
    i32 i;
    i32 j;
    i32 k;
    i32 return_value = 1;
    var old_h_over = cast(i32, spc.h_oversample);
    var old_v_over = cast(i32, spc.v_oversample);
    k = 0;
    for i = 0; i < num_ranges; ++i {
        f32 fh = ranges[i].font_size;
        f32 scale = fh > 0.0f ? stbtt_ScaleForPixelHeight(info, fh) : stbtt_ScaleForMappingEmToPixels(info, -fh);
        f32 recip_h;
        f32 recip_v;
        f32 sub_x;
        f32 sub_y;
        spc.h_oversample = ranges[i].h_oversample;
        spc.v_oversample = ranges[i].v_oversample;
        recip_h = 1.0f / cast(f32, spc.h_oversample);
        recip_v = 1.0f / cast(f32, spc.v_oversample);
        sub_x = stbtt__oversample_shift(cast(i32, spc.h_oversample));
        sub_y = stbtt__oversample_shift(cast(i32, spc.v_oversample));
        for j = 0; j < ranges[i].num_chars; ++j {
            stbrp_rect* r = &rects[k];
            if r.was_packed != 0 {
                stbtt_packedchar* bc = &ranges[i].chardata_for_range[j];
                i32 advance;
                i32 lsb;
                i32 x0;
                i32 y0;
                i32 x1;
                i32 y1;
                i32 codepoint = ranges[i].array_of_unicode_codepoints == null ? ranges[i].first_unicode_codepoint_in_range + j : ranges[i].array_of_unicode_codepoints[j];
                i32 glyph = stbtt_FindGlyphIndex(info, codepoint);
                var pad = cast(stbrp_coord, spc.padding);
                r.x += pad;
                r.y += pad;
                r.w -= pad;
                r.h -= pad;
                stbtt_GetGlyphHMetrics(info, glyph, &advance, &lsb);
                stbtt_GetGlyphBitmapBox(info, glyph, scale * cast(f32, spc.h_oversample), scale * cast(f32, spc.v_oversample), &x0, &y0, &x1, &y1);
                stbtt_MakeGlyphBitmapSubpixel(info, spc.pixels + r.x + r.y * spc.stride_in_bytes, cast(i32, cast(u32, r.w) - spc.h_oversample + 1), cast(i32, cast(u32, r.h) - spc.v_oversample + 1), spc.stride_in_bytes, scale * cast(f32, spc.h_oversample), scale * cast(f32, spc.v_oversample), 0.0f, 0.0f, glyph);
                if spc.h_oversample > 1 {
                    stbtt__h_prefilter(spc.pixels + r.x + r.y * spc.stride_in_bytes, r.w, r.h, spc.stride_in_bytes, spc.h_oversample);
                }
                if spc.v_oversample > 1 {
                    stbtt__v_prefilter(spc.pixels + r.x + r.y * spc.stride_in_bytes, r.w, r.h, spc.stride_in_bytes, spc.v_oversample);
                }
                bc.x0 = cast(u16, cast(stbtt_int16, r.x));
                bc.y0 = cast(u16, cast(stbtt_int16, r.y));
                bc.x1 = cast(u16, cast(stbtt_int16, r.x + r.w));
                bc.y1 = cast(u16, cast(stbtt_int16, r.y + r.h));
                bc.xadvance = scale * cast(f32, advance);
                bc.xoff = cast(f32, x0) * recip_h + sub_x;
                bc.yoff = cast(f32, y0) * recip_v + sub_y;
                bc.xoff2 = cast(f32, x0 + r.w) * recip_h + sub_x;
                bc.yoff2 = cast(f32, y0 + r.h) * recip_v + sub_y;
            } else {
                return_value = 0;
            }
            ++k;
        }
    }
    spc.h_oversample = cast(u32, old_h_over);
    spc.v_oversample = cast(u32, old_v_over);
    return return_value;
}

void stbtt_PackFontRangesPackRects(stbtt_pack_context* spc, stbrp_rect* rects, i32 num_rects) {
    stbrp_pack_rects(cast(stbrp_context*, spc.pack_info), rects, num_rects);
}

i32 stbtt_PackFontRanges(stbtt_pack_context* spc, u8* fontdata, i32 font_index, stbtt_pack_range* ranges, i32 num_ranges) {
    noinit stbtt_fontinfo info;
    i32 i;
    i32 j;
    i32 n;
    i32 return_value = 1;
    stbrp_rect* rects;
    for i = 0; i < num_ranges; ++i {
        for j = 0; j < ranges[i].num_chars; ++j {
            ranges[i].chardata_for_range[j].y1 = 0;
            ranges[i].chardata_for_range[j].x1 = ranges[i].chardata_for_range[j].y1;
            ranges[i].chardata_for_range[j].y0 = ranges[i].chardata_for_range[j].x1;
            ranges[i].chardata_for_range[j].x0 = ranges[i].chardata_for_range[j].y0;
        }
    }
    n = 0;
    for i = 0; i < num_ranges; ++i {
        n += ranges[i].num_chars;
    }
    rects = cast(stbrp_rect*, fons__tmpalloc(cast(u64, sizeof(*rects) * n), spc.user_allocator_context));
    if rects == null {
        return 0;
    }
    info.userdata = spc.user_allocator_context;
    stbtt_InitFont(&info, fontdata, stbtt_GetFontOffsetForIndex(fontdata, font_index));
    n = stbtt_PackFontRangesGatherRects(spc, &info, ranges, num_ranges, rects);
    stbtt_PackFontRangesPackRects(spc, rects, n);
    return_value = stbtt_PackFontRangesRenderIntoRects(spc, &info, ranges, num_ranges, rects);
    fons__tmpfree(rects, spc.user_allocator_context);
    return return_value;
}

i32 stbtt_PackFontRange(stbtt_pack_context* spc, u8* fontdata, i32 font_index, f32 font_size, i32 first_unicode_codepoint_in_range, i32 num_chars_in_range, stbtt_packedchar* chardata_for_range) {
    noinit stbtt_pack_range range;
    range.first_unicode_codepoint_in_range = first_unicode_codepoint_in_range;
    range.array_of_unicode_codepoints = null;
    range.num_chars = num_chars_in_range;
    range.chardata_for_range = chardata_for_range;
    range.font_size = font_size;
    return stbtt_PackFontRanges(spc, fontdata, font_index, &range, 1);
}

void stbtt_GetPackedQuad(stbtt_packedchar* chardata, i32 pw, i32 ph, i32 char_index, f32* xpos, f32* ypos, stbtt_aligned_quad* q, i32 align_to_integer) {
    f32 ipw = 1.0f / cast(f32, pw);
    f32 iph = 1.0f / cast(f32, ph);
    stbtt_packedchar* b = chardata + char_index;
    if align_to_integer != 0 {
        var x = cast(f32, cast(i32, floor(*xpos + b.xoff + 0.5f)));
        var y = cast(f32, cast(i32, floor(*ypos + b.yoff + 0.5f)));
        q.x0 = x;
        q.y0 = y;
        q.x1 = x + b.xoff2 - b.xoff;
        q.y1 = y + b.yoff2 - b.yoff;
    } else {
        q.x0 = *xpos + b.xoff;
        q.y0 = *ypos + b.yoff;
        q.x1 = *xpos + b.xoff2;
        q.y1 = *ypos + b.yoff2;
    }
    q.s0 = cast(f32, b.x0) * ipw;
    q.t0 = cast(f32, b.y0) * iph;
    q.s1 = cast(f32, b.x1) * ipw;
    q.t1 = cast(f32, b.y1) * iph;
    *xpos += b.xadvance;
}

//////////////////////////////////////////////////////////////////////////////
//
// sdf computation
//
i32 stbtt__ray_intersect_bezier(f32* orig, f32* ray, f32* q0, f32* q1, f32* q2, f32[2]* hits) {
    f32 q0perp = q0[1] * ray[0] - q0[0] * ray[1];
    f32 q1perp = q1[1] * ray[0] - q1[0] * ray[1];
    f32 q2perp = q2[1] * ray[0] - q2[0] * ray[1];
    f32 roperp = orig[1] * ray[0] - orig[0] * ray[1];
    f32 a = q0perp - 2.0f * q1perp + q2perp;
    f32 b = q1perp - q0perp;
    f32 c = q0perp - roperp;
    var s0 = cast(f32, 0.0);
    var s1 = cast(f32, 0.0);
    i32 num_s = 0;
    if a != 0.0 {
        f32 discr = b * b - a * c;
        if discr > 0.0 {
            f32 rcpna = -1.0f / a;
            var d = cast(f32, sqrt(discr));
            s0 = (b + d) * rcpna;
            s1 = (b - d) * rcpna;
            if s0 >= 0.0 && s0 <= 1.0 {
                num_s = 1;
            }
            if d > 0.0 && s1 >= 0.0 && s1 <= 1.0 {
                if num_s == 0 {
                    s0 = s1;
                }
                ++num_s;
            }
        }
    } else {
        s0 = c / (-2.0f * b);
        if s0 >= 0.0 && s0 <= 1.0 {
            num_s = 1;
        }
    }
    if num_s == 0 {
        return 0;
    } else {
        f32 rcp_len2 = 1.0f / (ray[0] * ray[0] + ray[1] * ray[1]);
        f32 rayn_x = ray[0] * rcp_len2;
        f32 rayn_y = ray[1] * rcp_len2;
        f32 q0d = q0[0] * rayn_x + q0[1] * rayn_y;
        f32 q1d = q1[0] * rayn_x + q1[1] * rayn_y;
        f32 q2d = q2[0] * rayn_x + q2[1] * rayn_y;
        f32 rod = orig[0] * rayn_x + orig[1] * rayn_y;
        f32 q10d = q1d - q0d;
        f32 q20d = q2d - q0d;
        f32 q0rd = q0d - rod;
        hits[0][0] = q0rd + s0 * (2.0f - 2.0f * s0) * q10d + s0 * s0 * q20d;
        hits[0][1] = a * s0 + b;
        if num_s > 1 {
            hits[1][0] = q0rd + s1 * (2.0f - 2.0f * s1) * q10d + s1 * s1 * q20d;
            hits[1][1] = a * s1 + b;
            return 2;
        } else {
            return 1;
        }
    }
}

i32 equal(f32* a, f32* b) {
    return a[0] == b[0] && a[1] == b[1];
}

i32 stbtt__compute_crossings_x(f32 x, f32 y, i32 nverts, stbtt_vertex* verts) {
    i32 i;
    noinit f32[2] orig;
    f32[2] ray = {1.0f, 0.0f};
    f32 y_frac;
    i32 winding = 0;
    orig[0] = x;
    orig[1] = y;
    y_frac = cast(f32, fmod(y, 1.0f));
    if y_frac < 0.01f {
        y += 0.01f;
    } else if y_frac > 0.99f {
        y -= 0.01f;
    }
    orig[1] = y;
    for i = 0; i < nverts; ++i {
        if cast(i32, verts[i].type) == STBTT_vline {
            var x0 = cast(i32, verts[i - 1].x);
            var y0 = cast(i32, verts[i - 1].y);
            var x1 = cast(i32, verts[i].x);
            var y1 = cast(i32, verts[i].y);
            if y > cast(f32, y0 < y1 ? y0 : y1) && y < cast(f32, y0 < y1 ? y1 : y0) && x > cast(f32, x0 < x1 ? x0 : x1) {
                f32 x_inter = (y - cast(f32, y0)) / cast(f32, y1 - y0) * cast(f32, x1 - x0) + cast(f32, x0);
                if x_inter < x {
                    winding += y0 < y1 ? 1 : -1;
                }
            }
        }
        if cast(i32, verts[i].type) == STBTT_vcurve {
            var x0 = cast(i32, verts[i - 1].x);
            var y0 = cast(i32, verts[i - 1].y);
            var x1 = cast(i32, verts[i].cx);
            var y1 = cast(i32, verts[i].cy);
            var x2 = cast(i32, verts[i].x);
            var y2 = cast(i32, verts[i].y);
            i32 ax = x0 < (x1 < x2 ? x1 : x2) ? x0 : x1 < x2 ? x1 : x2;
            i32 ay = y0 < (y1 < y2 ? y1 : y2) ? y0 : y1 < y2 ? y1 : y2;
            i32 by = y0 < (y1 < y2 ? y2 : y1) ? y1 < y2 ? y2 : y1 : y0;
            if y > cast(f32, ay) && y < cast(f32, by) && x > cast(f32, ax) {
                noinit f32[2] q0;
                noinit f32[2] q1;
                noinit f32[2] q2;
                noinit f32:[2][2] hits;
                q0[0] = cast(f32, x0);
                q0[1] = cast(f32, y0);
                q1[0] = cast(f32, x1);
                q1[1] = cast(f32, y1);
                q2[0] = cast(f32, x2);
                q2[1] = cast(f32, y2);
                if equal(q0, q1) || equal(q1, q2) {
                    x0 = cast(i32, verts[i - 1].x);
                    y0 = cast(i32, verts[i - 1].y);
                    x1 = cast(i32, verts[i].x);
                    y1 = cast(i32, verts[i].y);
                    if y > cast(f32, y0 < y1 ? y0 : y1) && y < cast(f32, y0 < y1 ? y1 : y0) && x > cast(f32, x0 < x1 ? x0 : x1) {
                        f32 x_inter = (y - cast(f32, y0)) / cast(f32, y1 - y0) * cast(f32, x1 - x0) + cast(f32, x0);
                        if x_inter < x {
                            winding += y0 < y1 ? 1 : -1;
                        }
                    }
                } else {
                    i32 num_hits = stbtt__ray_intersect_bezier(orig, ray, q0, q1, q2, hits);
                    if num_hits >= 1 {
                        if hits[0][0] < 0.0f {
                            winding += hits[0][1] < 0.0f ? -1 : 1;
                        }
                    }
                    if num_hits >= 2 {
                        if hits[1][0] < 0.0f {
                            winding += hits[1][1] < 0.0f ? -1 : 1;
                        }
                    }
                }
            }
        }
    }
    return winding;
}

f32 stbtt__cuberoot(f32 x) {
    if x < 0.0f {
        return -cast(f32, pow(-x, 1.0f / 3.0f));
    } else {
        return cast(f32, pow(x, 1.0f / 3.0f));
    }
}

// x^3 + c*x^2 + b*x + a = 0
i32 stbtt__solve_cubic(f32 a, f32 b, f32 c, f32* r) {
    f32 s = -a / 3.0f;
    f32 p = b - a * a / 3.0f;
    f32 q = a * (2.0f * a * a - 9.0f * b) / 27.0f + c;
    f32 p3 = p * p * p;
    f32 d = q * q + 4.0f * p3 / 27.0f;
    if d >= 0.0f {
        var z = cast(f32, sqrt(d));
        f32 u = (-q + z) / 2.0f;
        f32 v = (-q - z) / 2.0f;
        u = stbtt__cuberoot(u);
        v = stbtt__cuberoot(v);
        r[0] = s + u + v;
        return 1;
    } else {
        var u = cast(f32, sqrt(-p / 3.0f));
        f32 v = cast(f32, acos(-sqrt(-27.0f / p3) * q / 2.0)) / 3.0f;
        var m = cast(f32, cos(v));
        f32 n = cast(f32, cos(v - 3.141592 / 2.0)) * 1.7320508079999999f;
        r[0] = s + u * 2.0f * m;
        r[1] = s - u * (m + n);
        r[2] = s - u * (m - n);
        return 3;
    }
}

u8* stbtt_GetGlyphSDF(stbtt_fontinfo* info, f32 scale, i32 glyph, i32 padding, u8 onedge_value, f32 pixel_dist_scale, i32* width, i32* height, i32* xoff, i32* yoff) {
    f32 scale_x = scale;
    f32 scale_y = scale;
    i32 ix0;
    i32 iy0;
    i32 ix1;
    i32 iy1;
    i32 w;
    i32 h;
    u8* data;
    if scale_x == 0.0f {
        scale_x = scale_y;
    }
    if scale_y == 0.0f {
        if scale_x == 0.0f {
            return null;
        }
        scale_y = scale_x;
    }
    stbtt_GetGlyphBitmapBoxSubpixel(info, glyph, scale, scale, 0.0f, 0.0f, &ix0, &iy0, &ix1, &iy1);
    if ix0 == ix1 || iy0 == iy1 {
        return null;
    }
    ix0 -= padding;
    iy0 -= padding;
    ix1 += padding;
    iy1 += padding;
    w = ix1 - ix0;
    h = iy1 - iy0;
    if width != null {
        *width = w;
    }
    if height != null {
        *height = h;
    }
    if xoff != null {
        *xoff = ix0;
    }
    if yoff != null {
        *yoff = iy0;
    }
    scale_y = -scale_y;
    {
        i32 x;
        i32 y;
        i32 i;
        i32 j;
        f32* precompute;
        stbtt_vertex* verts;
        i32 num_verts = stbtt_GetGlyphShape(info, glyph, &verts);
        data = cast(u8*, fons__tmpalloc(cast(u64, w * h), info.userdata));
        precompute = cast(f32*, fons__tmpalloc(cast(u64, num_verts * sizeof(f32)), info.userdata));
        {
            i = 0;
            for j = num_verts - 1; i < num_verts; j = i++ {
                if cast(i32, verts[i].type) == STBTT_vline {
                    f32 x0 = cast(f32, verts[i].x) * scale_x;
                    f32 y0 = cast(f32, verts[i].y) * scale_y;
                    f32 x1 = cast(f32, verts[j].x) * scale_x;
                    f32 y1 = cast(f32, verts[j].y) * scale_y;
                    var dist = cast(f32, sqrt((x1 - x0) * (x1 - x0) + (y1 - y0) * (y1 - y0)));
                    precompute[i] = dist == 0.0f ? 0.0f : 1.0f / dist;
                } else if cast(i32, verts[i].type) == STBTT_vcurve {
                    f32 x2 = cast(f32, verts[j].x) * scale_x;
                    f32 y2 = cast(f32, verts[j].y) * scale_y;
                    f32 x1 = cast(f32, verts[i].cx) * scale_x;
                    f32 y1 = cast(f32, verts[i].cy) * scale_y;
                    f32 x0 = cast(f32, verts[i].x) * scale_x;
                    f32 y0 = cast(f32, verts[i].y) * scale_y;
                    f32 bx = x0 - 2.0f * x1 + x2;
                    f32 by = y0 - 2.0f * y1 + y2;
                    f32 len2 = bx * bx + by * by;
                    if len2 != 0.0f {
                        precompute[i] = 1.0f / (bx * bx + by * by);
                    } else {
                        precompute[i] = 0.0f;
                    }
                } else {
                    precompute[i] = 0.0f;
                }
            }
        }
        for y = iy0; y < iy1; ++y {
            for x = ix0; x < ix1; ++x {
                f32 val;
                f32 min_dist = 999999.0f;
                f32 sx = cast(f32, x) + 0.5f;
                f32 sy = cast(f32, y) + 0.5f;
                f32 x_gspace = sx / scale_x;
                f32 y_gspace = sy / scale_y;
                i32 winding = stbtt__compute_crossings_x(x_gspace, y_gspace, num_verts, verts);
                for i = 0; i < num_verts; ++i {
                    f32 x0 = cast(f32, verts[i].x) * scale_x;
                    f32 y0 = cast(f32, verts[i].y) * scale_y;
                    f32 dist2 = (x0 - sx) * (x0 - sx) + (y0 - sy) * (y0 - sy);
                    if dist2 < min_dist * min_dist {
                        min_dist = cast(f32, sqrt(dist2));
                    }
                    if cast(i32, verts[i].type) == STBTT_vline {
                        f32 x1 = cast(f32, verts[i - 1].x) * scale_x;
                        f32 y1 = cast(f32, verts[i - 1].y) * scale_y;
                        f32 dist = cast(f32, fabs((x1 - x0) * (y0 - sy) - (y1 - y0) * (x0 - sx))) * precompute[i];
                        if dist < min_dist {
                            f32 dx = x1 - x0;
                            f32 dy = y1 - y0;
                            f32 px = x0 - sx;
                            f32 py = y0 - sy;
                            f32 t = -(px * dx + py * dy) / (dx * dx + dy * dy);
                            if t >= 0.0f && t <= 1.0f {
                                min_dist = dist;
                            }
                        }
                    } else if cast(i32, verts[i].type) == STBTT_vcurve {
                        f32 x2 = cast(f32, verts[i - 1].x) * scale_x;
                        f32 y2 = cast(f32, verts[i - 1].y) * scale_y;
                        f32 x1 = cast(f32, verts[i].cx) * scale_x;
                        f32 y1 = cast(f32, verts[i].cy) * scale_y;
                        f32 box_x0 = (x0 < x1 ? x0 : x1) < x2 ? x0 < x1 ? x0 : x1 : x2;
                        f32 box_y0 = (y0 < y1 ? y0 : y1) < y2 ? y0 < y1 ? y0 : y1 : y2;
                        f32 box_x1 = (x0 < x1 ? x1 : x0) < x2 ? x2 : x0 < x1 ? x1 : x0;
                        f32 box_y1 = (y0 < y1 ? y1 : y0) < y2 ? y2 : y0 < y1 ? y1 : y0;
                        if sx > box_x0 - min_dist && sx < box_x1 + min_dist && sy > box_y0 - min_dist && sy < box_y1 + min_dist {
                            i32 num = 0;
                            f32 ax = x1 - x0;
                            f32 ay = y1 - y0;
                            f32 bx = x0 - 2.0f * x1 + x2;
                            f32 by = y0 - 2.0f * y1 + y2;
                            f32 mx = x0 - sx;
                            f32 my = y0 - sy;
                            noinit f32[3] res;
                            f32 px;
                            f32 py;
                            f32 t;
                            f32 it;
                            f32 a_inv = precompute[i];
                            if a_inv == 0.0 {
                                f32 a = 3.0f * (ax * bx + ay * by);
                                f32 b = 2.0f * (ax * ax + ay * ay) + (mx * bx + my * by);
                                f32 c = mx * ax + my * ay;
                                if a == 0.0 {
                                    if b != 0.0 {
                                        res[num++] = -c / b;
                                    }
                                } else {
                                    f32 discriminant = b * b - 4.0f * a * c;
                                    if discriminant < 0.0f {
                                        num = 0;
                                    } else {
                                        var root = cast(f32, sqrt(discriminant));
                                        res[0] = (-b - root) / (2.0f * a);
                                        res[1] = (-b + root) / (2.0f * a);
                                        num = 2;
                                    }
                                }
                            } else {
                                f32 b = 3.0f * (ax * bx + ay * by) * a_inv;
                                f32 c = (2.0f * (ax * ax + ay * ay) + (mx * bx + my * by)) * a_inv;
                                f32 d = (mx * ax + my * ay) * a_inv;
                                num = stbtt__solve_cubic(b, c, d, res);
                            }
                            if num >= 1 && res[0] >= 0.0f && res[0] <= 1.0f {
                                t = res[0];
                                it = 1.0f - t;
                                px = it * it * x0 + 2.0f * t * it * x1 + t * t * x2;
                                py = it * it * y0 + 2.0f * t * it * y1 + t * t * y2;
                                dist2 = (px - sx) * (px - sx) + (py - sy) * (py - sy);
                                if dist2 < min_dist * min_dist {
                                    min_dist = cast(f32, sqrt(dist2));
                                }
                            }
                            if num >= 2 && res[1] >= 0.0f && res[1] <= 1.0f {
                                t = res[1];
                                it = 1.0f - t;
                                px = it * it * x0 + 2.0f * t * it * x1 + t * t * x2;
                                py = it * it * y0 + 2.0f * t * it * y1 + t * t * y2;
                                dist2 = (px - sx) * (px - sx) + (py - sy) * (py - sy);
                                if dist2 < min_dist * min_dist {
                                    min_dist = cast(f32, sqrt(dist2));
                                }
                            }
                            if num >= 3 && res[2] >= 0.0f && res[2] <= 1.0f {
                                t = res[2];
                                it = 1.0f - t;
                                px = it * it * x0 + 2.0f * t * it * x1 + t * t * x2;
                                py = it * it * y0 + 2.0f * t * it * y1 + t * t * y2;
                                dist2 = (px - sx) * (px - sx) + (py - sy) * (py - sy);
                                if dist2 < min_dist * min_dist {
                                    min_dist = cast(f32, sqrt(dist2));
                                }
                            }
                        }
                    }
                }
                if winding == 0 {
                    min_dist = -min_dist;
                }
                val = cast(f32, onedge_value) + pixel_dist_scale * min_dist;
                if val < 0.0f {
                    val = 0.0f;
                } else if val > 255.0f {
                    val = 255.0f;
                }
                data[(y - iy0) * w + (x - ix0)] = cast(u8, val);
            }
        }
        fons__tmpfree(precompute, info.userdata);
        fons__tmpfree(verts, info.userdata);
    }
    return data;
}

u8* stbtt_GetCodepointSDF(stbtt_fontinfo* info, f32 scale, i32 codepoint, i32 padding, u8 onedge_value, f32 pixel_dist_scale, i32* width, i32* height, i32* xoff, i32* yoff) {
    return stbtt_GetGlyphSDF(info, scale, stbtt_FindGlyphIndex(info, codepoint), padding, onedge_value, pixel_dist_scale, width, height, xoff, yoff);
}

void stbtt_FreeSDF(u8* bitmap, void* userdata) {
    fons__tmpfree(bitmap, userdata);
}

//////////////////////////////////////////////////////////////////////////////
//
// font name matching -- recommended not to use this
//
// check if a utf8 string contains a prefix which is the utf16 string; if so return length of matching utf8 string
stbtt_int32 stbtt__CompareUTF8toUTF16_bigendian_prefix(stbtt_uint8* s1, stbtt_int32 len1, stbtt_uint8* s2, stbtt_int32 len2) {
    stbtt_int32 i = 0;
    while len2 != 0 {
        var ch = cast(stbtt_uint16, cast(i32, s2[0]) * 256 + s2[1]);
        if ch < 0x80 {
            if i >= len1 {
                return -1;
            }
            if s1[i++] != ch {
                return -1;
            }
        } else if ch < 0x800 {
            if i + 1 >= len1 {
                return -1;
            }
            if cast(i32, s1[i++]) != 0xc0 + (cast(i32, ch) >> 6) {
                return -1;
            }
            if s1[i++] != 0x80 + (ch & 0x3f) {
                return -1;
            }
        } else if ch >= 0xd800 && ch < 0xdc00 {
            stbtt_uint32 c;
            var ch2 = cast(stbtt_uint16, cast(i32, s2[2]) * 256 + s2[3]);
            if i + 3 >= len1 {
                return -1;
            }
            c = (ch - 0xd800 << 10) + (ch2 - 0xdc00) + 0x10000;
            if s1[i++] != 0xf0 + (c >> 18) {
                return -1;
            }
            if s1[i++] != 0x80 + (c >> 12 & 0x3f) {
                return -1;
            }
            if s1[i++] != 0x80 + (c >> 6 & 0x3f) {
                return -1;
            }
            if s1[i++] != 0x80 + (c & 0x3f) {
                return -1;
            }
            s2 += 2;
            len2 -= 2;
        } else if ch >= 0xdc00 && ch < 0xe000 {
            return -1;
        } else {
            if i + 2 >= len1 {
                return -1;
            }
            if cast(i32, s1[i++]) != 0xe0 + (cast(i32, ch) >> 12) {
                return -1;
            }
            if cast(i32, s1[i++]) != 0x80 + (cast(i32, ch) >> 6 & 0x3f) {
                return -1;
            }
            if s1[i++] != 0x80 + (ch & 0x3f) {
                return -1;
            }
        }
        s2 += 2;
        len2 -= 2;
    }
    return i;
}

i32 stbtt_CompareUTF8toUTF16_bigendian_internal(u8* s1, i32 len1, u8* s2, i32 len2) {
    return len1 == stbtt__CompareUTF8toUTF16_bigendian_prefix(cast(stbtt_uint8*, s1), len1, cast(stbtt_uint8*, s2), len2);
}

// returns results in whatever encoding you request... but note that 2-byte encodings
// will be BIG-ENDIAN... use stbtt_CompareUTF8toUTF16_bigendian() to compare
u8* stbtt_GetFontNameString(stbtt_fontinfo* font, i32* length, i32 platformID, i32 encodingID, i32 languageID, i32 nameID) {
    stbtt_int32 i;
    stbtt_int32 count;
    stbtt_int32 stringOffset;
    stbtt_uint8* fc = font.data;
    var offset = cast(stbtt_uint32, font.fontstart);
    stbtt_uint32 nm = stbtt__find_table(fc, offset, "name");
    if nm == 0 {
        return null;
    }
    count = cast(i32, ttUSHORT(fc + nm + 2));
    stringOffset = cast(i32, nm + ttUSHORT(fc + nm + 4));
    for i = 0; i < count; ++i {
        stbtt_uint32 loc = nm + 6 + cast(u32, 12 * i);
        if platformID == cast(i32, ttUSHORT(fc + loc + 0)) && encodingID == cast(i32, ttUSHORT(fc + loc + 2)) && languageID == cast(i32, ttUSHORT(fc + loc + 4)) && nameID == cast(i32, ttUSHORT(fc + loc + 6)) {
            *length = cast(i32, ttUSHORT(fc + loc + 8));
            return cast(u8*, fc + stringOffset + ttUSHORT(fc + loc + 10));
        }
    }
    return null;
}

i32 stbtt__matchpair(stbtt_uint8* fc, stbtt_uint32 nm, stbtt_uint8* name, stbtt_int32 nlen, stbtt_int32 target_id, stbtt_int32 next_id) {
    stbtt_int32 i;
    var count = cast(stbtt_int32, ttUSHORT(fc + nm + 2));
    var stringOffset = cast(stbtt_int32, nm + ttUSHORT(fc + nm + 4));
    for i = 0; i < count; ++i {
        stbtt_uint32 loc = nm + 6 + cast(u32, 12 * i);
        var id = cast(stbtt_int32, ttUSHORT(fc + loc + 6));
        if id == target_id {
            var platform = cast(stbtt_int32, ttUSHORT(fc + loc + 0));
            var encoding = cast(stbtt_int32, ttUSHORT(fc + loc + 2));
            var language = cast(stbtt_int32, ttUSHORT(fc + loc + 4));
            if platform == 0 || platform == 3 && encoding == 1 || platform == 3 && encoding == 10 {
                var slen = cast(stbtt_int32, ttUSHORT(fc + loc + 8));
                var off = cast(stbtt_int32, ttUSHORT(fc + loc + 10));
                stbtt_int32 matchlen = stbtt__CompareUTF8toUTF16_bigendian_prefix(name, nlen, fc + stringOffset + off, slen);
                if matchlen >= 0 {
                    if i + 1 < count && cast(i32, ttUSHORT(fc + loc + 12 + 6)) == next_id && cast(i32, ttUSHORT(fc + loc + 12)) == platform && cast(i32, ttUSHORT(fc + loc + 12 + 2)) == encoding && cast(i32, ttUSHORT(fc + loc + 12 + 4)) == language {
                        slen = cast(i32, ttUSHORT(fc + loc + 12 + 8));
                        off = cast(i32, ttUSHORT(fc + loc + 12 + 10));
                        if slen == 0 {
                            if matchlen == nlen {
                                return 1;
                            }
                        } else if matchlen < nlen && name[matchlen] == 32 {
                            ++matchlen;
                            if stbtt_CompareUTF8toUTF16_bigendian_internal(cast(u8*, name + matchlen), nlen - matchlen, cast(u8*, fc + stringOffset + off), slen) != 0 {
                                return 1;
                            }
                        }
                    } else {
                        if matchlen == nlen {
                            return 1;
                        }
                    }
                }
            }
        }
    }
    return 0;
}

i32 stbtt__matches(stbtt_uint8* fc, stbtt_uint32 offset, stbtt_uint8* name, stbtt_int32 flags) {
    var nlen = cast(stbtt_int32, strlen(cast(u8*, name)));
    stbtt_uint32 nm;
    stbtt_uint32 hd;
    if stbtt__isfont(fc + offset) == 0 {
        return 0;
    }
    if flags != 0 {
        hd = stbtt__find_table(fc, offset, "head");
        if cast(i32, ttUSHORT(fc + hd + 44) & 7) != (flags & 7) {
            return 0;
        }
    }
    nm = stbtt__find_table(fc, offset, "name");
    if nm == 0 {
        return 0;
    }
    if flags != 0 {
        if stbtt__matchpair(fc, nm, name, nlen, 16, -1) != 0 {
            return 1;
        }
        if stbtt__matchpair(fc, nm, name, nlen, 1, -1) != 0 {
            return 1;
        }
        if stbtt__matchpair(fc, nm, name, nlen, 3, -1) != 0 {
            return 1;
        }
    } else {
        if stbtt__matchpair(fc, nm, name, nlen, 16, 17) != 0 {
            return 1;
        }
        if stbtt__matchpair(fc, nm, name, nlen, 1, 2) != 0 {
            return 1;
        }
        if stbtt__matchpair(fc, nm, name, nlen, 3, -1) != 0 {
            return 1;
        }
    }
    return 0;
}

i32 stbtt_FindMatchingFont_internal(u8* font_collection, u8* name_utf8, stbtt_int32 flags) {
    stbtt_int32 i;
    for i = 0; true; ++i {
        stbtt_int32 off = stbtt_GetFontOffsetForIndex(font_collection, i);
        if off < 0 {
            return off;
        }
        if stbtt__matches(cast(stbtt_uint8*, font_collection), cast(stbtt_uint32, off), cast(stbtt_uint8*, name_utf8), flags) != 0 {
            return off;
        }
    }
}

i32 stbtt_BakeFontBitmap(u8* data, i32 offset, f32 pixel_height, u8* pixels, i32 pw, i32 ph, i32 first_char, i32 num_chars, stbtt_bakedchar* chardata) {
    return stbtt_BakeFontBitmap_internal(data, offset, pixel_height, pixels, pw, ph, first_char, num_chars, chardata);
}

i32 stbtt_GetFontOffsetForIndex(u8* data, i32 index) {
    return stbtt_GetFontOffsetForIndex_internal(data, index);
}

i32 stbtt_GetNumberOfFonts(u8* data) {
    return stbtt_GetNumberOfFonts_internal(data);
}

i32 stbtt_InitFont(stbtt_fontinfo* info, u8* data, i32 offset) {
    return stbtt_InitFont_internal(info, data, offset);
}

i32 stbtt_FindMatchingFont(u8* fontdata, u8* name, i32 flags) {
    return stbtt_FindMatchingFont_internal(fontdata, name, flags);
}

i32 stbtt_CompareUTF8toUTF16_bigendian(u8* s1, i32 len1, u8* s2, i32 len2) {
    return stbtt_CompareUTF8toUTF16_bigendian_internal(s1, len1, s2, len2);
}

i32 fons__tt_init(FONScontext* context) {
    ignore sizeof(context);
    return 1;
}

i32 fons__tt_loadFont(FONScontext* context, FONSttFontImpl* font, u8* data, i32 dataSize) {
    i32 stbError;
    ignore sizeof(dataSize);
    font.font.userdata = context;
    stbError = stbtt_InitFont(&font.font, data, 0);
    return stbError;
}

void fons__tt_getFontVMetrics(FONSttFontImpl* font, i32* ascent, i32* descent, i32* lineGap) {
    stbtt_GetFontVMetrics(&font.font, ascent, descent, lineGap);
}

f32 fons__tt_getPixelHeightScale(FONSttFontImpl* font, f32 size) {
    return stbtt_ScaleForPixelHeight(&font.font, size);
}

i32 fons__tt_getGlyphIndex(FONSttFontImpl* font, i32 codepoint) {
    return stbtt_FindGlyphIndex(&font.font, codepoint);
}

i32 fons__tt_buildGlyphBitmap(FONSttFontImpl* font, i32 glyph, f32 size, f32 scale, i32* advance, i32* lsb, i32* x0, i32* y0, i32* x1, i32* y1) {
    ignore sizeof(size);
    stbtt_GetGlyphHMetrics(&font.font, glyph, advance, lsb);
    stbtt_GetGlyphBitmapBox(&font.font, glyph, scale, scale, x0, y0, x1, y1);
    return 1;
}

void fons__tt_renderGlyphBitmap(FONSttFontImpl* font, u8* output, i32 outWidth, i32 outHeight, i32 outStride, f32 scaleX, f32 scaleY, i32 glyph) {
    stbtt_MakeGlyphBitmap(&font.font, output, outWidth, outHeight, outStride, scaleX, scaleY, glyph);
}

i32 fons__tt_getGlyphKernAdvance(FONSttFontImpl* font, i32 glyph1, i32 glyph2) {
    return stbtt_GetGlyphKernAdvance(&font.font, glyph1, glyph2);
}

u32 fons__hashint(u32 a) {
    a += ~(a << 15);
    a ^= a >> 10;
    a += a << 3;
    a ^= a >> 6;
    a += ~(a << 11);
    a ^= a >> 16;
    return a;
}

i32 fons__mini(i32 a, i32 b) {
    return a < b ? a : b;
}

i32 fons__maxi(i32 a, i32 b) {
    return a > b ? a : b;
}

void* fons__tmpalloc(u64 size, void* up) {
    u8* ptr;
    var stash = cast(FONScontext*, up);
    size = size + 0xf & cast(u64, ~0xf);
    if stash.nscratch + cast(i32, size) > 64000 {
        if stash.handleError != null {
            stash.handleError(stash.errorUptr, FONS_SCRATCH_FULL, stash.nscratch + cast(i32, size));
        }
        return null;
    }
    ptr = stash.scratch + stash.nscratch;
    stash.nscratch += cast(i32, size);
    return ptr;
}

void fons__tmpfree(void* ptr, void* up) {
    ignore ptr;
    ignore up;
}

// Copyright (c) 2008-2010 Bjoern Hoehrmann <bjoern@hoehrmann.de>
// See http://bjoern.hoehrmann.de/utf-8/decoder/dfa/ for details.
u32 fons__decutf8(u32* state, u32* codep, u32 byte) {
    u32 type = fons__decutf8__utf8d[byte];
    *codep = *state != 0 ? byte & 0x3f | *codep << 6 : 0xff >> type & byte;
    *state = fons__decutf8__utf8d[256 + *state + type];
    return *state;
}

// Atlas based on Skyline Bin Packer by Jukka Jylänki
void fons__deleteAtlas(FONSatlas* atlas) {
    if atlas == null {
        return;
    }
    if atlas.nodes != null {
        free(atlas.nodes);
    }
    free(atlas);
}

FONSatlas* fons__allocAtlas(i32 w, i32 h, i32 nnodes) {
    FONSatlas* atlas = null;
    bool _keep = false;
    defer {
        if !_keep {
            if atlas != null {
                fons__deleteAtlas(atlas);
            }
        }
    }
    atlas = null;
    atlas = new(FONSatlas);
    if atlas == null {
        return null;
    }
    memset(atlas, 0, cast(u64, sizeof(FONSatlas)));
    atlas.width = w;
    atlas.height = h;
    atlas.nodes = new(FONSatlasNode[nnodes]);
    if atlas.nodes == null {
        return null;
    }
    memset(atlas.nodes, 0, cast(u64, sizeof(FONSatlasNode) * nnodes));
    atlas.nnodes = 0;
    atlas.cnodes = nnodes;
    atlas.nodes[0].x = 0;
    atlas.nodes[0].y = 0;
    atlas.nodes[0].width = cast(i16, w);
    atlas.nnodes++;
    _keep = true;
    return atlas;
}

i32 fons__atlasInsertNode(FONSatlas* atlas, i32 idx, i32 x, i32 y, i32 w) {
    i32 i;
    if atlas.nnodes + 1 > atlas.cnodes {
        atlas.cnodes = atlas.cnodes == 0 ? 8 : atlas.cnodes * 2;
        atlas.nodes = cast(FONSatlasNode*, realloc(atlas.nodes, cast(u64, sizeof(FONSatlasNode) * atlas.cnodes)));
        if atlas.nodes == null {
            return 0;
        }
    }
    for i = atlas.nnodes; i > idx; i-- {
        atlas.nodes[i] = atlas.nodes[i - 1];
    }
    atlas.nodes[idx].x = cast(i16, x);
    atlas.nodes[idx].y = cast(i16, y);
    atlas.nodes[idx].width = cast(i16, w);
    atlas.nnodes++;
    return 1;
}

void fons__atlasRemoveNode(FONSatlas* atlas, i32 idx) {
    i32 i;
    if atlas.nnodes == 0 {
        return;
    }
    for i = idx; i < atlas.nnodes - 1; i++ {
        atlas.nodes[i] = atlas.nodes[i + 1];
    }
    atlas.nnodes--;
}

void fons__atlasExpand(FONSatlas* atlas, i32 w, i32 h) {
    if w > atlas.width {
        fons__atlasInsertNode(atlas, atlas.nnodes, atlas.width, 0, w - atlas.width);
    }
    atlas.width = w;
    atlas.height = h;
}

void fons__atlasReset(FONSatlas* atlas, i32 w, i32 h) {
    atlas.width = w;
    atlas.height = h;
    atlas.nnodes = 0;
    atlas.nodes[0].x = 0;
    atlas.nodes[0].y = 0;
    atlas.nodes[0].width = cast(i16, w);
    atlas.nnodes++;
}

i32 fons__atlasAddSkylineLevel(FONSatlas* atlas, i32 idx, i32 x, i32 y, i32 w, i32 h) {
    i32 i;
    if fons__atlasInsertNode(atlas, idx, x, y + h, w) == 0 {
        return 0;
    }
    for i = idx + 1; i < atlas.nnodes; i++ {
        if atlas.nodes[i].x < atlas.nodes[i - 1].x + atlas.nodes[i - 1].width {
            i32 shrink = atlas.nodes[i - 1].x + atlas.nodes[i - 1].width - atlas.nodes[i].x;
            atlas.nodes[i].x += cast(i16, shrink);
            atlas.nodes[i].width -= cast(i16, shrink);
            if atlas.nodes[i].width <= 0 {
                fons__atlasRemoveNode(atlas, i);
                i--;
            } else {
                break;
            }
        } else {
            break;
        }
    }
    for i = 0; i < atlas.nnodes - 1; i++ {
        if atlas.nodes[i].y == atlas.nodes[i + 1].y {
            atlas.nodes[i].width += atlas.nodes[i + 1].width;
            fons__atlasRemoveNode(atlas, i + 1);
            i--;
        }
    }
    return 1;
}

i32 fons__atlasRectFits(FONSatlas* atlas, i32 i, i32 w, i32 h) {
    i32 x = atlas.nodes[i].x;
    i32 y = atlas.nodes[i].y;
    i32 spaceLeft;
    if x + w > atlas.width {
        return -1;
    }
    spaceLeft = w;
    while spaceLeft > 0 {
        if i == atlas.nnodes {
            return -1;
        }
        y = fons__maxi(y, atlas.nodes[i].y);
        if y + h > atlas.height {
            return -1;
        }
        spaceLeft -= atlas.nodes[i].width;
        ++i;
    }
    return y;
}

i32 fons__atlasAddRect(FONSatlas* atlas, i32 rw, i32 rh, i32* rx, i32* ry) {
    i32 besth = atlas.height;
    i32 bestw = atlas.width;
    i32 besti = -1;
    i32 bestx = -1;
    i32 besty = -1;
    i32 i;
    for i = 0; i < atlas.nnodes; i++ {
        i32 y = fons__atlasRectFits(atlas, i, rw, rh);
        if y != -1 {
            if y + rh < besth || y + rh == besth && atlas.nodes[i].width < bestw {
                besti = i;
                bestw = atlas.nodes[i].width;
                besth = y + rh;
                bestx = atlas.nodes[i].x;
                besty = y;
            }
        }
    }
    if besti == -1 {
        return 0;
    }
    if fons__atlasAddSkylineLevel(atlas, besti, bestx, besty, rw, rh) == 0 {
        return 0;
    }
    *rx = bestx;
    *ry = besty;
    return 1;
}

void fons__addWhiteRect(FONScontext* stash, i32 w, i32 h) {
    i32 x;
    i32 y;
    i32 gx;
    i32 gy;
    u8* dst;
    if fons__atlasAddRect(stash.atlas, w, h, &gx, &gy) == 0 {
        return;
    }
    dst = &stash.texData[gx + gy * stash.params.width];
    for y = 0; y < h; y++ {
        for x = 0; x < w; x++ {
            dst[x] = 0xff;
        }
        dst += stash.params.width;
    }
    stash.dirtyRect[0] = fons__mini(stash.dirtyRect[0], gx);
    stash.dirtyRect[1] = fons__mini(stash.dirtyRect[1], gy);
    stash.dirtyRect[2] = fons__maxi(stash.dirtyRect[2], gx + w);
    stash.dirtyRect[3] = fons__maxi(stash.dirtyRect[3], gy + h);
}
}

FONScontext* fonsCreateInternal(FONSparams* params) {
    FONScontext* stash = null;
    stash = new(FONScontext);
    if stash == null {
        fonsDeleteInternal(stash);
        return null;
    }
    memset(stash, 0, cast(u64, sizeof(FONScontext)));
    stash.params = *params;
    stash.scratch = cast(u8*, alloc(64000));
    if stash.scratch == null {
        fonsDeleteInternal(stash);
        return null;
    }
    if fons__tt_init(stash) == 0 {
        fonsDeleteInternal(stash);
        return null;
    }
    if stash.params.renderCreate != null {
        if stash.params.renderCreate(stash.params.userPtr, stash.params.width, stash.params.height) == 0 {
            fonsDeleteInternal(stash);
            return null;
        }
    }
    stash.atlas = fons__allocAtlas(stash.params.width, stash.params.height, 256);
    if stash.atlas == null {
        fonsDeleteInternal(stash);
        return null;
    }
    stash.fonts = new(FONSfont*[4]);
    if stash.fonts == null {
        fonsDeleteInternal(stash);
        return null;
    }
    memset(stash.fonts, 0, cast(u64, sizeof(FONSfont*) * 4));
    stash.cfonts = 4;
    stash.nfonts = 0;
    stash.itw = 1.0f / cast(f32, stash.params.width);
    stash.ith = 1.0f / cast(f32, stash.params.height);
    stash.texData = cast(u8*, alloc(cast(i64, stash.params.width * stash.params.height)));
    if stash.texData == null {
        fonsDeleteInternal(stash);
        return null;
    }
    memset(stash.texData, 0, cast(u64, stash.params.width * stash.params.height));
    stash.dirtyRect[0] = stash.params.width;
    stash.dirtyRect[1] = stash.params.height;
    stash.dirtyRect[2] = 0;
    stash.dirtyRect[3] = 0;
    fons__addWhiteRect(stash, 2, 2);
    fonsPushState(stash);
    fonsClearState(stash);
    return stash;
}

private {
FONSstate* fons__getState(FONScontext* stash) {
    return &stash.states[stash.nstates - 1];
}
}

i32 fonsAddFallbackFont(FONScontext* stash, i32 base, i32 fallback) {
    FONSfont* baseFont = stash.fonts[base];
    if baseFont.nfallbacks < 20 {
        baseFont.fallbacks[baseFont.nfallbacks++] = fallback;
        return 1;
    }
    return 0;
}

void fonsSetSize(FONScontext* stash, f32 size) {
    fons__getState(stash).size = size;
}

void fonsSetColor(FONScontext* stash, u32 color) {
    fons__getState(stash).color = color;
}

void fonsSetSpacing(FONScontext* stash, f32 spacing) {
    fons__getState(stash).spacing = spacing;
}

void fonsSetBlur(FONScontext* stash, f32 blur) {
    fons__getState(stash).blur = blur;
}

void fonsSetAlign(FONScontext* stash, i32 align) {
    fons__getState(stash).align = align;
}

void fonsSetFont(FONScontext* stash, i32 font) {
    fons__getState(stash).font = font;
}

void fonsPushState(FONScontext* stash) {
    if stash.nstates >= 20 {
        if stash.handleError != null {
            stash.handleError(stash.errorUptr, FONS_STATES_OVERFLOW, 0);
        }
        return;
    }
    if stash.nstates > 0 {
        memcpy(&stash.states[stash.nstates], &stash.states[stash.nstates - 1], cast(u64, sizeof(FONSstate)));
    }
    stash.nstates++;
}

void fonsPopState(FONScontext* stash) {
    if stash.nstates <= 1 {
        if stash.handleError != null {
            stash.handleError(stash.errorUptr, FONS_STATES_UNDERFLOW, 0);
        }
        return;
    }
    stash.nstates--;
}

void fonsClearState(FONScontext* stash) {
    FONSstate* state = fons__getState(stash);
    state.size = 12.0f;
    state.color = 0xffffffff;
    state.font = 0;
    state.blur = 0.0f;
    state.spacing = 0.0f;
    state.align = FONS_ALIGN_LEFT | FONS_ALIGN_BASELINE;
}

private {
void fons__freeFont(FONSfont* font) {
    if font == null {
        return;
    }
    if font.glyphs != null {
        free(font.glyphs);
    }
    if font.freeData && font.data {
        free(font.data);
    }
    free(font);
}

i32 fons__allocFont(FONScontext* stash) {
    FONSfont* font = null;
    if stash.nfonts + 1 > stash.cfonts {
        stash.cfonts = stash.cfonts == 0 ? 8 : stash.cfonts * 2;
        stash.fonts = cast(FONSfont**, realloc(stash.fonts, cast(u64, sizeof(FONSfont*) * stash.cfonts)));
        if stash.fonts == null {
            return -1;
        }
    }
    font = new(FONSfont);
    if font == null {
        fons__freeFont(font);
        return -1;
    }
    memset(font, 0, cast(u64, sizeof(FONSfont)));
    font.glyphs = new(FONSglyph[256]);
    if font.glyphs == null {
        fons__freeFont(font);
        return -1;
    }
    font.cglyphs = 256;
    font.nglyphs = 0;
    stash.fonts[stash.nfonts++] = font;
    return stash.nfonts - 1;
}
}

i32 fonsAddFontMem(FONScontext* stash, u8* name, u8* data, i32 dataSize, i32 freeData) {
    i32 i;
    i32 ascent;
    i32 descent;
    i32 fh;
    i32 lineGap;
    FONSfont* font;
    i32 idx = fons__allocFont(stash);
    if idx == -1 {
        return -1;
    }
    font = stash.fonts[idx];
    strncpy(font.name, name, cast(u64, sizeof(font.name)));
    font.name[sizeof(font.name) - 1] = 0;
    for i = 0; i < 256; ++i {
        font.lut[i] = -1;
    }
    font.dataSize = dataSize;
    font.data = data;
    font.freeData = cast(u8, freeData);
    stash.nscratch = 0;
    if fons__tt_loadFont(stash, &font.font, data, dataSize) == 0 {
        fons__freeFont(font);
        stash.nfonts--;
        return -1;
    }
    fons__tt_getFontVMetrics(&font.font, &ascent, &descent, &lineGap);
    fh = ascent - descent;
    font.ascender = cast(f32, ascent) / cast(f32, fh);
    font.descender = cast(f32, descent) / cast(f32, fh);
    font.lineh = cast(f32, fh + lineGap) / cast(f32, fh);
    return idx;
}

i32 fonsGetFontByName(FONScontext* s, u8* name) {
    i32 i;
    for i = 0; i < s.nfonts; i++ {
        if strcmp(s.fonts[i].name, name) == 0 {
            return i;
        }
    }
    return -1;
}

private {
FONSglyph* fons__allocGlyph(FONSfont* font) {
    if font.nglyphs + 1 > font.cglyphs {
        font.cglyphs = font.cglyphs == 0 ? 8 : font.cglyphs * 2;
        font.glyphs = cast(FONSglyph*, realloc(font.glyphs, cast(u64, sizeof(FONSglyph) * font.cglyphs)));
        if font.glyphs == null {
            return null;
        }
    }
    font.nglyphs++;
    return &font.glyphs[font.nglyphs - 1];
}

// Based on Exponential blur, Jani Huhtanen, 2006
void fons__blurCols(u8* dst, i32 w, i32 h, i32 dstStride, i32 alpha) {
    i32 x;
    i32 y;
    for y = 0; y < h; y++ {
        i32 z = 0;
        for x = 1; x < w; x++ {
            z += alpha * ((cast(i32, dst[x]) << 7) - z) >> 16;
            dst[x] = cast(u8, z >> 7);
        }
        dst[w - 1] = 0;
        z = 0;
        for x = w - 2; x >= 0; x-- {
            z += alpha * ((cast(i32, dst[x]) << 7) - z) >> 16;
            dst[x] = cast(u8, z >> 7);
        }
        dst[0] = 0;
        dst += dstStride;
    }
}

void fons__blurRows(u8* dst, i32 w, i32 h, i32 dstStride, i32 alpha) {
    i32 x;
    i32 y;
    for x = 0; x < w; x++ {
        i32 z = 0;
        for y = dstStride; y < h * dstStride; y += dstStride {
            z += alpha * ((cast(i32, dst[y]) << 7) - z) >> 16;
            dst[y] = cast(u8, z >> 7);
        }
        dst[(h - 1) * dstStride] = 0;
        z = 0;
        for y = (h - 2) * dstStride; y >= 0; y -= dstStride {
            z += alpha * ((cast(i32, dst[y]) << 7) - z) >> 16;
            dst[y] = cast(u8, z >> 7);
        }
        dst[0] = 0;
        dst++;
    }
}

void fons__blur(FONScontext* stash, u8* dst, i32 w, i32 h, i32 dstStride, i32 blur) {
    i32 alpha;
    f32 sigma;
    ignore stash;
    if blur < 1 {
        return;
    }
    sigma = cast(f32, blur) * 0.57735f;
    alpha = cast(i32, cast(f32, 1 << 16) * (1.0f - expf(-2.3f / (sigma + 1.0f))));
    fons__blurRows(dst, w, h, dstStride, alpha);
    fons__blurCols(dst, w, h, dstStride, alpha);
    fons__blurRows(dst, w, h, dstStride, alpha);
    fons__blurCols(dst, w, h, dstStride, alpha);
}

FONSglyph* fons__getGlyph(FONScontext* stash, FONSfont* font, u32 codepoint, i16 isize, i16 iblur) {
    i32 i;
    i32 g;
    i32 advance;
    i32 lsb;
    i32 x0;
    i32 y0;
    i32 x1;
    i32 y1;
    i32 gw;
    i32 gh;
    i32 gx;
    i32 gy;
    i32 x;
    i32 y;
    f32 scale;
    FONSglyph* glyph = null;
    u32 h;
    f32 size = cast(f32, isize) / 10.0f;
    i32 pad;
    i32 added;
    u8* bdst;
    u8* dst;
    FONSfont* renderFont = font;
    if isize < 2 {
        return null;
    }
    if iblur > 20 {
        iblur = 20;
    }
    pad = iblur + 2;
    stash.nscratch = 0;
    h = fons__hashint(codepoint) & cast(u32, 256 - 1);
    i = font.lut[h];
    while i != -1 {
        if font.glyphs[i].codepoint == codepoint && font.glyphs[i].size == isize && font.glyphs[i].blur == iblur {
            return &font.glyphs[i];
        }
        i = font.glyphs[i].next;
    }
    g = fons__tt_getGlyphIndex(&font.font, cast(i32, codepoint));
    if g == 0 {
        for i = 0; i < font.nfallbacks; ++i {
            FONSfont* fallbackFont = stash.fonts[font.fallbacks[i]];
            i32 fallbackIndex = fons__tt_getGlyphIndex(&fallbackFont.font, cast(i32, codepoint));
            if fallbackIndex != 0 {
                g = fallbackIndex;
                renderFont = fallbackFont;
                break;
            }
        }
    }
    scale = fons__tt_getPixelHeightScale(&renderFont.font, size);
    fons__tt_buildGlyphBitmap(&renderFont.font, g, size, scale, &advance, &lsb, &x0, &y0, &x1, &y1);
    gw = x1 - x0 + pad * 2;
    gh = y1 - y0 + pad * 2;
    added = fons__atlasAddRect(stash.atlas, gw, gh, &gx, &gy);
    if added == 0 && stash.handleError != null {
        stash.handleError(stash.errorUptr, FONS_ATLAS_FULL, 0);
        added = fons__atlasAddRect(stash.atlas, gw, gh, &gx, &gy);
    }
    if added == 0 {
        return null;
    }
    glyph = fons__allocGlyph(font);
    glyph.codepoint = codepoint;
    glyph.size = isize;
    glyph.blur = iblur;
    glyph.index = g;
    glyph.x0 = cast(i16, gx);
    glyph.y0 = cast(i16, gy);
    glyph.x1 = cast(i16, glyph.x0 + gw);
    glyph.y1 = cast(i16, glyph.y0 + gh);
    glyph.xadv = cast(i16, scale * cast(f32, advance) * 10.0f);
    glyph.xoff = cast(i16, x0 - pad);
    glyph.yoff = cast(i16, y0 - pad);
    glyph.next = 0;
    glyph.next = font.lut[h];
    font.lut[h] = font.nglyphs - 1;
    dst = &stash.texData[glyph.x0 + pad + (glyph.y0 + pad) * stash.params.width];
    fons__tt_renderGlyphBitmap(&renderFont.font, dst, gw - pad * 2, gh - pad * 2, stash.params.width, scale, scale, g);
    dst = &stash.texData[glyph.x0 + glyph.y0 * stash.params.width];
    for y = 0; y < gh; y++ {
        dst[y * stash.params.width] = 0;
        dst[gw - 1 + y * stash.params.width] = 0;
    }
    for x = 0; x < gw; x++ {
        dst[x] = 0;
        dst[x + (gh - 1) * stash.params.width] = 0;
    }
    if iblur > 0 {
        stash.nscratch = 0;
        bdst = &stash.texData[glyph.x0 + glyph.y0 * stash.params.width];
        fons__blur(stash, bdst, gw, gh, stash.params.width, iblur);
    }
    stash.dirtyRect[0] = fons__mini(stash.dirtyRect[0], glyph.x0);
    stash.dirtyRect[1] = fons__mini(stash.dirtyRect[1], glyph.y0);
    stash.dirtyRect[2] = fons__maxi(stash.dirtyRect[2], glyph.x1);
    stash.dirtyRect[3] = fons__maxi(stash.dirtyRect[3], glyph.y1);
    return glyph;
}

void fons__getQuad(FONScontext* stash, FONSfont* font, i32 prevGlyphIndex, FONSglyph* glyph, f32 scale, f32 spacing, f32* x, f32* y, FONSquad* q) {
    f32 rx;
    f32 ry;
    f32 xoff;
    f32 yoff;
    f32 x0;
    f32 y0;
    f32 x1;
    f32 y1;
    if prevGlyphIndex != -1 {
        f32 adv = cast(f32, fons__tt_getGlyphKernAdvance(&font.font, prevGlyphIndex, glyph.index)) * scale;
        *x += cast(f32, cast(i32, adv + spacing + 0.5f));
    }
    xoff = cast(f32, cast(i16, glyph.xoff + 1));
    yoff = cast(f32, cast(i16, glyph.yoff + 1));
    x0 = cast(f32, glyph.x0 + 1);
    y0 = cast(f32, glyph.y0 + 1);
    x1 = cast(f32, glyph.x1 - 1);
    y1 = cast(f32, glyph.y1 - 1);
    if (stash.params.flags & FONS_ZERO_TOPLEFT) != 0 {
        rx = cast(f32, cast(i32, *x + xoff));
        ry = cast(f32, cast(i32, *y + yoff));
        q.x0 = rx;
        q.y0 = ry;
        q.x1 = rx + x1 - x0;
        q.y1 = ry + y1 - y0;
        q.s0 = x0 * stash.itw;
        q.t0 = y0 * stash.ith;
        q.s1 = x1 * stash.itw;
        q.t1 = y1 * stash.ith;
    } else {
        rx = cast(f32, cast(i32, *x + xoff));
        ry = cast(f32, cast(i32, *y - yoff));
        q.x0 = rx;
        q.y0 = ry;
        q.x1 = rx + x1 - x0;
        q.y1 = ry - y1 + y0;
        q.s0 = x0 * stash.itw;
        q.t0 = y0 * stash.ith;
        q.s1 = x1 * stash.itw;
        q.t1 = y1 * stash.ith;
    }
    *x += cast(f32, cast(i32, cast(f32, glyph.xadv) / 10.0f + 0.5f));
}

void fons__flush(FONScontext* stash) {
    if stash.dirtyRect[0] < stash.dirtyRect[2] && stash.dirtyRect[1] < stash.dirtyRect[3] {
        if stash.params.renderUpdate != null {
            stash.params.renderUpdate(stash.params.userPtr, stash.dirtyRect, stash.texData);
        }
        stash.dirtyRect[0] = stash.params.width;
        stash.dirtyRect[1] = stash.params.height;
        stash.dirtyRect[2] = 0;
        stash.dirtyRect[3] = 0;
    }
    if stash.nverts > 0 {
        if stash.params.renderDraw != null {
            stash.params.renderDraw(stash.params.userPtr, stash.verts, stash.tcoords, stash.colors, stash.nverts);
        }
        stash.nverts = 0;
    }
}

void fons__vertex(FONScontext* stash, f32 x, f32 y, f32 s, f32 t, u32 c) {
    stash.verts[stash.nverts * 2 + 0] = x;
    stash.verts[stash.nverts * 2 + 1] = y;
    stash.tcoords[stash.nverts * 2 + 0] = s;
    stash.tcoords[stash.nverts * 2 + 1] = t;
    stash.colors[stash.nverts] = c;
    stash.nverts++;
}

f32 fons__getVertAlign(FONScontext* stash, FONSfont* font, i32 align, i16 isize) {
    if (stash.params.flags & FONS_ZERO_TOPLEFT) != 0 {
        if (align & FONS_ALIGN_TOP) != 0 {
            return font.ascender * cast(f32, isize) / 10.0f;
        } else if (align & FONS_ALIGN_MIDDLE) != 0 {
            return (font.ascender + font.descender) / 2.0f * cast(f32, isize) / 10.0f;
        } else if (align & FONS_ALIGN_BASELINE) != 0 {
            return 0.0f;
        } else if (align & FONS_ALIGN_BOTTOM) != 0 {
            return font.descender * cast(f32, isize) / 10.0f;
        }
    } else {
        if (align & FONS_ALIGN_TOP) != 0 {
            return -font.ascender * cast(f32, isize) / 10.0f;
        } else if (align & FONS_ALIGN_MIDDLE) != 0 {
            return -(font.ascender + font.descender) / 2.0f * cast(f32, isize) / 10.0f;
        } else if (align & FONS_ALIGN_BASELINE) != 0 {
            return 0.0f;
        } else if (align & FONS_ALIGN_BOTTOM) != 0 {
            return -font.descender * cast(f32, isize) / 10.0f;
        }
    }
    return 0.0f;
}
}

f32 fonsDrawText(FONScontext* stash, f32 x, f32 y, u8* str_var, u8* end) {
    FONSstate* state = fons__getState(stash);
    u32 codepoint;
    u32 utf8state = 0;
    FONSglyph* glyph = null;
    noinit FONSquad q;
    i32 prevGlyphIndex = -1;
    var isize = cast(i16, state.size * 10.0f);
    var iblur = cast(i16, state.blur);
    f32 scale;
    FONSfont* font;
    f32 width;
    if stash == null {
        return x;
    }
    if state.font < 0 || state.font >= stash.nfonts {
        return x;
    }
    font = stash.fonts[state.font];
    if font.data == null {
        return x;
    }
    scale = fons__tt_getPixelHeightScale(&font.font, cast(f32, isize) / 10.0f);
    if end == null {
        end = str_var + strlen(str_var);
    }
    if (state.align & FONS_ALIGN_LEFT) != 0 {
    } else if (state.align & FONS_ALIGN_RIGHT) != 0 {
        width = fonsTextBounds(stash, x, y, str_var, end, null);
        x -= width;
    } else if (state.align & FONS_ALIGN_CENTER) != 0 {
        width = fonsTextBounds(stash, x, y, str_var, end, null);
        x -= width * 0.5f;
    }
    y += fons__getVertAlign(stash, font, state.align, isize);
    for ; str_var != end; ++str_var {
        if fons__decutf8(&utf8state, &codepoint, *cast(u8*, str_var)) != 0 {
            continue;
        }
        glyph = fons__getGlyph(stash, font, codepoint, isize, iblur);
        if glyph != null {
            fons__getQuad(stash, font, prevGlyphIndex, glyph, scale, state.spacing, &x, &y, &q);
            if stash.nverts + 6 > 1024 {
                fons__flush(stash);
            }
            fons__vertex(stash, q.x0, q.y0, q.s0, q.t0, state.color);
            fons__vertex(stash, q.x1, q.y1, q.s1, q.t1, state.color);
            fons__vertex(stash, q.x1, q.y0, q.s1, q.t0, state.color);
            fons__vertex(stash, q.x0, q.y0, q.s0, q.t0, state.color);
            fons__vertex(stash, q.x0, q.y1, q.s0, q.t1, state.color);
            fons__vertex(stash, q.x1, q.y1, q.s1, q.t1, state.color);
        }
        prevGlyphIndex = glyph != null ? glyph.index : -1;
    }
    fons__flush(stash);
    return x;
}

i32 fonsTextIterInit(FONScontext* stash, FONStextIter* iter, f32 x, f32 y, u8* str_var, u8* end) {
    FONSstate* state = fons__getState(stash);
    f32 width;
    memset(iter, 0, cast(u64, sizeof(*iter)));
    if stash == null {
        return 0;
    }
    if state.font < 0 || state.font >= stash.nfonts {
        return 0;
    }
    iter.font = stash.fonts[state.font];
    if iter.font.data == null {
        return 0;
    }
    iter.isize = cast(i16, state.size * 10.0f);
    iter.iblur = cast(i16, state.blur);
    iter.scale = fons__tt_getPixelHeightScale(&iter.font.font, cast(f32, iter.isize) / 10.0f);
    if (state.align & FONS_ALIGN_LEFT) != 0 {
    } else if (state.align & FONS_ALIGN_RIGHT) != 0 {
        width = fonsTextBounds(stash, x, y, str_var, end, null);
        x -= width;
    } else if (state.align & FONS_ALIGN_CENTER) != 0 {
        width = fonsTextBounds(stash, x, y, str_var, end, null);
        x -= width * 0.5f;
    }
    y += fons__getVertAlign(stash, iter.font, state.align, iter.isize);
    if end == null {
        end = str_var + strlen(str_var);
    }
    iter.nextx = x;
    iter.x = iter.nextx;
    iter.nexty = y;
    iter.y = iter.nexty;
    iter.spacing = state.spacing;
    iter.str_var = str_var;
    iter.next = str_var;
    iter.end = end;
    iter.codepoint = 0;
    iter.prevGlyphIndex = -1;
    return 1;
}

i32 fonsTextIterNext(FONScontext* stash, FONStextIter* iter, FONSquad* quad) {
    FONSglyph* glyph = null;
    u8* str_var = iter.next;  // renamed from: str
    iter.str_var = iter.next;
    if str_var == iter.end {
        return 0;
    }
    for ; str_var != iter.end; str_var++ {
        if fons__decutf8(&iter.utf8state, &iter.codepoint, *cast(u8*, str_var)) != 0 {
            continue;
        }
        str_var++;
        iter.x = iter.nextx;
        iter.y = iter.nexty;
        glyph = fons__getGlyph(stash, iter.font, iter.codepoint, iter.isize, iter.iblur);
        if glyph != null {
            fons__getQuad(stash, iter.font, iter.prevGlyphIndex, glyph, iter.scale, iter.spacing, &iter.nextx, &iter.nexty, quad);
        }
        iter.prevGlyphIndex = glyph != null ? glyph.index : -1;
        break;
    }
    iter.next = str_var;
    return 1;
}

void fonsDrawDebug(FONScontext* stash, f32 x, f32 y) {
    i32 i;
    i32 w = stash.params.width;
    i32 h = stash.params.height;
    var u = cast(f32, w == 0 ? 0.0f : 1.0f / cast(f32, w));
    var v = cast(f32, h == 0 ? 0.0f : 1.0f / cast(f32, h));
    if stash.nverts + 6 + 6 > 1024 {
        fons__flush(stash);
    }
    fons__vertex(stash, x + 0.0f, y + 0.0f, u, v, 0x0fffffff);
    fons__vertex(stash, x + cast(f32, w), y + cast(f32, h), u, v, 0x0fffffff);
    fons__vertex(stash, x + cast(f32, w), y + 0.0f, u, v, 0x0fffffff);
    fons__vertex(stash, x + 0.0f, y + 0.0f, u, v, 0x0fffffff);
    fons__vertex(stash, x + 0.0f, y + cast(f32, h), u, v, 0x0fffffff);
    fons__vertex(stash, x + cast(f32, w), y + cast(f32, h), u, v, 0x0fffffff);
    fons__vertex(stash, x + 0.0f, y + 0.0f, 0.0f, 0.0f, 0xffffffff);
    fons__vertex(stash, x + cast(f32, w), y + cast(f32, h), 1.0f, 1.0f, 0xffffffff);
    fons__vertex(stash, x + cast(f32, w), y + 0.0f, 1.0f, 0.0f, 0xffffffff);
    fons__vertex(stash, x + 0.0f, y + 0.0f, 0.0f, 0.0f, 0xffffffff);
    fons__vertex(stash, x + 0.0f, y + cast(f32, h), 0.0f, 1.0f, 0xffffffff);
    fons__vertex(stash, x + cast(f32, w), y + cast(f32, h), 1.0f, 1.0f, 0xffffffff);
    for i = 0; i < stash.atlas.nnodes; i++ {
        FONSatlasNode* n = &stash.atlas.nodes[i];
        if stash.nverts + 6 > 1024 {
            fons__flush(stash);
        }
        fons__vertex(stash, x + cast(f32, n.x) + 0.0f, y + cast(f32, n.y) + 0.0f, u, v, 0xc00000ff);
        fons__vertex(stash, x + cast(f32, n.x) + cast(f32, n.width), y + cast(f32, n.y) + 1.0f, u, v, 0xc00000ff);
        fons__vertex(stash, x + cast(f32, n.x) + cast(f32, n.width), y + cast(f32, n.y) + 0.0f, u, v, 0xc00000ff);
        fons__vertex(stash, x + cast(f32, n.x) + 0.0f, y + cast(f32, n.y) + 0.0f, u, v, 0xc00000ff);
        fons__vertex(stash, x + cast(f32, n.x) + 0.0f, y + cast(f32, n.y) + 1.0f, u, v, 0xc00000ff);
        fons__vertex(stash, x + cast(f32, n.x) + cast(f32, n.width), y + cast(f32, n.y) + 1.0f, u, v, 0xc00000ff);
    }
    fons__flush(stash);
}

f32 fonsTextBounds(FONScontext* stash, f32 x, f32 y, u8* str_var, u8* end, f32* bounds) {
    FONSstate* state = fons__getState(stash);
    u32 codepoint;
    u32 utf8state = 0;
    noinit FONSquad q;
    FONSglyph* glyph = null;
    i32 prevGlyphIndex = -1;
    var isize = cast(i16, state.size * 10.0f);
    var iblur = cast(i16, state.blur);
    f32 scale;
    FONSfont* font;
    f32 startx;
    f32 advance;
    f32 minx;
    f32 miny;
    f32 maxx;
    f32 maxy;
    if stash == null {
        return 0.0f;
    }
    if state.font < 0 || state.font >= stash.nfonts {
        return 0.0f;
    }
    font = stash.fonts[state.font];
    if font.data == null {
        return 0.0f;
    }
    scale = fons__tt_getPixelHeightScale(&font.font, cast(f32, isize) / 10.0f);
    y += fons__getVertAlign(stash, font, state.align, isize);
    maxx = x;
    minx = maxx;
    maxy = y;
    miny = maxy;
    startx = x;
    if end == null {
        end = str_var + strlen(str_var);
    }
    for ; str_var != end; ++str_var {
        if fons__decutf8(&utf8state, &codepoint, *cast(u8*, str_var)) != 0 {
            continue;
        }
        glyph = fons__getGlyph(stash, font, codepoint, isize, iblur);
        if glyph != null {
            fons__getQuad(stash, font, prevGlyphIndex, glyph, scale, state.spacing, &x, &y, &q);
            if q.x0 < minx {
                minx = q.x0;
            }
            if q.x1 > maxx {
                maxx = q.x1;
            }
            if (stash.params.flags & FONS_ZERO_TOPLEFT) != 0 {
                if q.y0 < miny {
                    miny = q.y0;
                }
                if q.y1 > maxy {
                    maxy = q.y1;
                }
            } else {
                if q.y1 < miny {
                    miny = q.y1;
                }
                if q.y0 > maxy {
                    maxy = q.y0;
                }
            }
        }
        prevGlyphIndex = glyph != null ? glyph.index : -1;
    }
    advance = x - startx;
    if (state.align & FONS_ALIGN_LEFT) != 0 {
    } else if (state.align & FONS_ALIGN_RIGHT) != 0 {
        minx -= advance;
        maxx -= advance;
    } else if (state.align & FONS_ALIGN_CENTER) != 0 {
        minx -= advance * 0.5f;
        maxx -= advance * 0.5f;
    }
    if bounds != null {
        bounds[0] = minx;
        bounds[1] = miny;
        bounds[2] = maxx;
        bounds[3] = maxy;
    }
    return advance;
}

void fonsVertMetrics(FONScontext* stash, f32* ascender, f32* descender, f32* lineh) {
    FONSfont* font;
    FONSstate* state = fons__getState(stash);
    i16 isize;
    if stash == null {
        return;
    }
    if state.font < 0 || state.font >= stash.nfonts {
        return;
    }
    font = stash.fonts[state.font];
    isize = cast(i16, state.size * 10.0f);
    if font.data == null {
        return;
    }
    if ascender != null {
        *ascender = font.ascender * cast(f32, isize) / 10.0f;
    }
    if descender != null {
        *descender = font.descender * cast(f32, isize) / 10.0f;
    }
    if lineh != null {
        *lineh = font.lineh * cast(f32, isize) / 10.0f;
    }
}

void fonsLineBounds(FONScontext* stash, f32 y, f32* miny, f32* maxy) {
    FONSfont* font;
    FONSstate* state = fons__getState(stash);
    i16 isize;
    if stash == null {
        return;
    }
    if state.font < 0 || state.font >= stash.nfonts {
        return;
    }
    font = stash.fonts[state.font];
    isize = cast(i16, state.size * 10.0f);
    if font.data == null {
        return;
    }
    y += fons__getVertAlign(stash, font, state.align, isize);
    if (stash.params.flags & FONS_ZERO_TOPLEFT) != 0 {
        *miny = y - font.ascender * cast(f32, isize) / 10.0f;
        *maxy = *miny + font.lineh * cast(f32, isize) / 10.0f;
    } else {
        *maxy = y + font.descender * cast(f32, isize) / 10.0f;
        *miny = *maxy - font.lineh * cast(f32, isize) / 10.0f;
    }
}

u8* fonsGetTextureData(FONScontext* stash, i32* width, i32* height) {
    if width != null {
        *width = stash.params.width;
    }
    if height != null {
        *height = stash.params.height;
    }
    return stash.texData;
}

i32 fonsValidateTexture(FONScontext* stash, i32* dirty) {
    if stash.dirtyRect[0] < stash.dirtyRect[2] && stash.dirtyRect[1] < stash.dirtyRect[3] {
        dirty[0] = stash.dirtyRect[0];
        dirty[1] = stash.dirtyRect[1];
        dirty[2] = stash.dirtyRect[2];
        dirty[3] = stash.dirtyRect[3];
        stash.dirtyRect[0] = stash.params.width;
        stash.dirtyRect[1] = stash.params.height;
        stash.dirtyRect[2] = 0;
        stash.dirtyRect[3] = 0;
        return 1;
    }
    return 0;
}

void fonsDeleteInternal(FONScontext* stash) {
    i32 i;
    if stash == null {
        return;
    }
    if stash.params.renderDelete != null {
        stash.params.renderDelete(stash.params.userPtr);
    }
    for i = 0; i < stash.nfonts; ++i {
        fons__freeFont(stash.fonts[i]);
    }
    if stash.atlas != null {
        fons__deleteAtlas(stash.atlas);
    }
    if stash.fonts != null {
        free(stash.fonts);
    }
    if stash.texData != null {
        free(stash.texData);
    }
    if stash.scratch != null {
        free(stash.scratch);
    }
    free(stash);
}

void fonsSetErrorCallback(FONScontext* stash, fn(void*, i32, i32): void callback, void* uptr) {
    if stash == null {
        return;
    }
    stash.handleError = callback;
    stash.errorUptr = uptr;
}

void fonsGetAtlasSize(FONScontext* stash, i32* width, i32* height) {
    if stash == null {
        return;
    }
    *width = stash.params.width;
    *height = stash.params.height;
}

i32 fonsExpandAtlas(FONScontext* stash, i32 width, i32 height) {
    i32 i;
    i32 maxy = 0;
    u8* data = null;
    if stash == null {
        return 0;
    }
    width = fons__maxi(width, stash.params.width);
    height = fons__maxi(height, stash.params.height);
    if width == stash.params.width && height == stash.params.height {
        return 1;
    }
    fons__flush(stash);
    if stash.params.renderResize != null {
        if stash.params.renderResize(stash.params.userPtr, width, height) == 0 {
            return 0;
        }
    }
    data = cast(u8*, alloc(cast(i64, width * height)));
    if data == null {
        return 0;
    }
    for i = 0; i < stash.params.height; i++ {
        u8* dst = &data[i * width];
        u8* src = &stash.texData[i * stash.params.width];
        memcpy(dst, src, cast(u64, stash.params.width));
        if width > stash.params.width {
            memset(dst + stash.params.width, 0, cast(u64, width - stash.params.width));
        }
    }
    if height > stash.params.height {
        memset(&data[stash.params.height * width], 0, cast(u64, (height - stash.params.height) * width));
    }
    free(stash.texData);
    stash.texData = data;
    fons__atlasExpand(stash.atlas, width, height);
    for i = 0; i < stash.atlas.nnodes; i++ {
        maxy = fons__maxi(maxy, stash.atlas.nodes[i].y);
    }
    stash.dirtyRect[0] = 0;
    stash.dirtyRect[1] = 0;
    stash.dirtyRect[2] = stash.params.width;
    stash.dirtyRect[3] = maxy;
    stash.params.width = width;
    stash.params.height = height;
    stash.itw = 1.0f / cast(f32, stash.params.width);
    stash.ith = 1.0f / cast(f32, stash.params.height);
    return 1;
}

i32 fonsResetAtlas(FONScontext* stash, i32 width, i32 height) {
    i32 i;
    i32 j;
    if stash == null {
        return 0;
    }
    fons__flush(stash);
    if stash.params.renderResize != null {
        if stash.params.renderResize(stash.params.userPtr, width, height) == 0 {
            return 0;
        }
    }
    fons__atlasReset(stash.atlas, width, height);
    stash.texData = cast(u8*, realloc(stash.texData, cast(u64, width * height)));
    if stash.texData == null {
        return 0;
    }
    memset(stash.texData, 0, cast(u64, width * height));
    stash.dirtyRect[0] = width;
    stash.dirtyRect[1] = height;
    stash.dirtyRect[2] = 0;
    stash.dirtyRect[3] = 0;
    for i = 0; i < stash.nfonts; i++ {
        FONSfont* font = stash.fonts[i];
        font.nglyphs = 0;
        for j = 0; j < 256; j++ {
            font.lut[j] = -1;
        }
    }
    stash.params.width = width;
    stash.params.height = height;
    stash.itw = 1.0f / cast(f32, stash.params.width);
    stash.ith = 1.0f / cast(f32, stash.params.height);
    fons__addWhiteRect(stash, 2, 2);
    return 1;
}
private {
u8[364] fons__decutf8__utf8d = {
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9,
    7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7,
    8, 8, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2,
    10, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 4, 3, 3, 11, 6, 6, 6, 5, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8,
    8, 0, 12, 24, 36, 60, 96, 84, 12, 12, 12, 48, 72, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12,
    12, 12, 0, 12, 12, 12, 12, 12, 0, 12, 0, 12, 12, 12, 24, 12, 12, 12, 12, 12, 24, 12, 24, 12, 12,
    12, 12, 12, 12, 12, 12, 12, 24, 12, 12, 12, 12, 12, 24, 12, 12, 12, 12, 12, 12, 12, 24, 12, 12,
    12, 12, 12, 12, 12, 12, 12, 36, 12, 36, 12, 12, 12, 36, 12, 12, 12, 12, 12, 36, 12, 36, 12, 12,
    12, 36, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12,
};
}

