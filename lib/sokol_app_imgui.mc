// sokol_app_imgui
import sokol_all;
import imgui;

//-- ring buffer helper --------------------------------------------------------
struct _sappimgui_ring_t {
    i32 head;
    i32 tail;
}

//-- internal state ------------------------------------------------------------
struct _sappimgui_frame_t {
    u64 frame_count;
    f64 raw_dt;
    f64 filtered_dt;
}

struct _sappimgui_hud_window_t {
    bool open;
}

struct _sappimgui_publicstate_window_t {
    bool open;
}

struct _sappimgui_event_window_t {
    bool open;
    sapp_event[24] events;
}

struct _sappimgui_state_t {
    u32 init_tag;
    struct {
        _sappimgui_ring_t ring;
        _sappimgui_frame_t[256] items;
    } frames;
    _sappimgui_hud_window_t hud_window;
    _sappimgui_publicstate_window_t publicstate_window;
    _sappimgui_event_window_t event_window;
}

struct _sappimgui_frame_stats_t {
    i32 num;
    struct {
        f64 average;
        f64 minimum;
        f64 maximum;
    } filtered;
    struct {
        f64 average;
        f64 minimum;
        f64 maximum;
    } raw;
}

private {
i32 _sappimgui_ring_idx(i32 i) {
    return i % 256;
}

void _sappimgui_ring_init(_sappimgui_ring_t* ring) {
    ring.head = 0;
    ring.tail = 0;
}

bool _sappimgui_ring_full(_sappimgui_ring_t* ring) {
    return _sappimgui_ring_idx(ring.head + 1) == ring.tail;
}

bool _sappimgui_ring_empty(_sappimgui_ring_t* ring) {
    return ring.head == ring.tail;
}

i32 _sappimgui_ring_count(_sappimgui_ring_t* ring) {
    i32 count;
    if ring.head >= ring.tail {
        count = ring.head - ring.tail;
    } else {
        count = ring.head + 256 - ring.tail;
    }
    return count;
}

i32 _sappimgui_ring_rem(_sappimgui_ring_t* ring) {
    i32 idx = ring.tail;
    ring.tail = _sappimgui_ring_idx(ring.tail + 1);
    return idx;
}

i32 _sappimgui_ring_add(_sappimgui_ring_t* ring) {
    if _sappimgui_ring_full(ring) != 0 {
        _sappimgui_ring_rem(ring);
    }
    i32 idx = ring.head;
    ring.head = _sappimgui_ring_idx(idx + 1);
    return idx;
}
_sappimgui_state_t _sappimgui;

//--- utils --------------------------------------------------------------------
void _sappimgui_clear(void* ptr, u64 size) {
    memset(ptr, 0, size);
}

void _sappimgui_add_frame(_sappimgui_frame_t* f) {
    _sappimgui.frames.items[_sappimgui_ring_add(&_sappimgui.frames.ring)] = *f;
}

i32 _sappimgui_num_frames() {
    return _sappimgui_ring_count(&_sappimgui.frames.ring);
}

_sappimgui_frame_t* _sappimgui_frame_at(i32 idx) {
    i32 frame_idx = _sappimgui_ring_idx(_sappimgui.frames.ring.tail + idx);
    return &_sappimgui.frames.items[frame_idx];
}

_sappimgui_frame_stats_t _sappimgui_frame_stats() {
    noinit _sappimgui_frame_stats_t res;
    _sappimgui_clear(&res, cast(u64, sizeof(res)));
    res.num = _sappimgui_num_frames();
    if res.num > 0 {
        for i32 i = 0; i < res.num; i++ {
            _sappimgui_frame_t* f = &_sappimgui.frames.items[_sappimgui_ring_idx(_sappimgui.frames.ring.tail + i)];
            f64 filtered_dt = f.filtered_dt;
            f64 raw_dt = f.raw_dt;
            res.filtered.average += filtered_dt;
            if res.filtered.minimum == 0.0 || res.filtered.minimum > filtered_dt {
                res.filtered.minimum = filtered_dt;
            }
            if res.filtered.maximum < filtered_dt {
                res.filtered.maximum = filtered_dt;
            }
            res.raw.average += raw_dt;
            if res.raw.minimum == 0.0 || res.raw.minimum > raw_dt {
                res.raw.minimum = raw_dt;
            }
            if res.raw.maximum < raw_dt {
                res.raw.maximum = raw_dt;
            }
        }
        res.filtered.average /= cast(f64, res.num);
        res.raw.average /= cast(f64, res.num);
    }
    return res;
}

f32 _sappimgui_filtered_dt_getter(void* data, i32 idx) {
    ignore data;
    if idx < _sappimgui_num_frames() {
        return cast(f32, _sappimgui_frame_at(idx).filtered_dt * 1000.0);
    } else {
        return 0.0f;
    }
}

f32 _sappimgui_raw_dt_getter(void* data, i32 idx) {
    ignore data;
    if idx < _sappimgui_num_frames() {
        return cast(f32, _sappimgui_frame_at(idx).raw_dt * 1000.0);
    } else {
        return 0.0f;
    }
}

u8* _sappimgui_bool_string(bool b) {
    return b != 0 ? "true" : "false";
}

u8* _sappimgui_pixelformat_string(sapp_pixel_format fmt) {
    switch fmt {
        case SAPP_PIXELFORMAT_NONE: {
            return "NONE";
        }
        case SAPP_PIXELFORMAT_RGBA8: {
            return "RGBA8";
        }
        case SAPP_PIXELFORMAT_SRGB8A8: {
            return "SRGB8A8";
        }
        case SAPP_PIXELFORMAT_BGRA8: {
            return "BGRA8";
        }
        case SAPP_PIXELFORMAT_SBGR8A8: {
            return "SBGR8A8";
        }
        case SAPP_PIXELFORMAT_RGBA16F: {
            return "RGBA16F";
        }
        case SAPP_PIXELFORMAT_DEPTH: {
            return "DEPTH";
        }
        case SAPP_PIXELFORMAT_DEPTH_STENCIL: {
            return "DEPTH_STENCIL";
        }
        default: {
            return "???";
        }
    }
}

u8* _sappimgui_mousecursor_string(sapp_mouse_cursor c) {
    switch c {
        case SAPP_MOUSECURSOR_ARROW: {
            return "ARROW";
        }
        case SAPP_MOUSECURSOR_IBEAM: {
            return "IBEAM";
        }
        case SAPP_MOUSECURSOR_CROSSHAIR: {
            return "CROSSHAIR";
        }
        case SAPP_MOUSECURSOR_POINTING_HAND: {
            return "POINTING_HAND";
        }
        case SAPP_MOUSECURSOR_RESIZE_EW: {
            return "RESIZE_EW";
        }
        case SAPP_MOUSECURSOR_RESIZE_NS: {
            return "RESIZE_NS";
        }
        case SAPP_MOUSECURSOR_RESIZE_NWSE: {
            return "RESIZE_NWSE";
        }
        case SAPP_MOUSECURSOR_RESIZE_NESW: {
            return "RESIZE_NESW";
        }
        case SAPP_MOUSECURSOR_RESIZE_ALL: {
            return "RESIZE_ALL";
        }
        case SAPP_MOUSECURSOR_NOT_ALLOWED: {
            return "NOT_ALLOWED";
        }
        case SAPP_MOUSECURSOR_CUSTOM_0: {
            return "CUSTOM_0";
        }
        case SAPP_MOUSECURSOR_CUSTOM_1: {
            return "CUSTOM_1";
        }
        case SAPP_MOUSECURSOR_CUSTOM_2: {
            return "CUSTOM_2";
        }
        case SAPP_MOUSECURSOR_CUSTOM_3: {
            return "CUSTOM_3";
        }
        case SAPP_MOUSECURSOR_CUSTOM_4: {
            return "CUSTOM_4";
        }
        case SAPP_MOUSECURSOR_CUSTOM_5: {
            return "CUSTOM_5";
        }
        case SAPP_MOUSECURSOR_CUSTOM_6: {
            return "CUSTOM_6";
        }
        case SAPP_MOUSECURSOR_CUSTOM_7: {
            return "CUSTOM_7";
        }
        case SAPP_MOUSECURSOR_CUSTOM_8: {
            return "CUSTOM_8";
        }
        case SAPP_MOUSECURSOR_CUSTOM_9: {
            return "CUSTOM_9";
        }
        case SAPP_MOUSECURSOR_CUSTOM_10: {
            return "CUSTOM_10";
        }
        case SAPP_MOUSECURSOR_CUSTOM_11: {
            return "CUSTOM_11";
        }
        case SAPP_MOUSECURSOR_CUSTOM_12: {
            return "CUSTOM_12";
        }
        case SAPP_MOUSECURSOR_CUSTOM_13: {
            return "CUSTOM_13";
        }
        case SAPP_MOUSECURSOR_CUSTOM_14: {
            return "CUSTOM_14";
        }
        case SAPP_MOUSECURSOR_CUSTOM_15: {
            return "CUSTOM_15";
        }
        default: {
            return "???";
        }
    }
}

u8* _sappimgui_eventtype_string(sapp_event_type ev_type) {
    switch ev_type {
        case SAPP_EVENTTYPE_INVALID: {
            return "INVALID";
        }
        case SAPP_EVENTTYPE_KEY_DOWN: {
            return "KEY_DOWN";
        }
        case SAPP_EVENTTYPE_KEY_UP: {
            return "KEY_UP";
        }
        case SAPP_EVENTTYPE_CHAR: {
            return "CHAR";
        }
        case SAPP_EVENTTYPE_MOUSE_DOWN: {
            return "MOUSE_DOWN";
        }
        case SAPP_EVENTTYPE_MOUSE_UP: {
            return "MOUSE_UP";
        }
        case SAPP_EVENTTYPE_MOUSE_SCROLL: {
            return "MOUSE_SCROLL";
        }
        case SAPP_EVENTTYPE_MOUSE_MOVE: {
            return "MOUSE_MOVE";
        }
        case SAPP_EVENTTYPE_MOUSE_ENTER: {
            return "MOUSE_ENTER";
        }
        case SAPP_EVENTTYPE_MOUSE_LEAVE: {
            return "MOUSE_LEAVE";
        }
        case SAPP_EVENTTYPE_TOUCHES_BEGAN: {
            return "TOUCHES_BEGAN";
        }
        case SAPP_EVENTTYPE_TOUCHES_MOVED: {
            return "TOUCHES_MOVED";
        }
        case SAPP_EVENTTYPE_TOUCHES_ENDED: {
            return "TOUCHES_ENDED";
        }
        case SAPP_EVENTTYPE_TOUCHES_CANCELLED: {
            return "TOUCHES_CANCELLED";
        }
        case SAPP_EVENTTYPE_RESIZED: {
            return "RESIZED";
        }
        case SAPP_EVENTTYPE_ICONIFIED: {
            return "ICONIFIED";
        }
        case SAPP_EVENTTYPE_RESTORED: {
            return "RESTORED";
        }
        case SAPP_EVENTTYPE_FOCUSED: {
            return "FOCUSED";
        }
        case SAPP_EVENTTYPE_UNFOCUSED: {
            return "UNFOCUSED";
        }
        case SAPP_EVENTTYPE_SUSPENDED: {
            return "SUSPENDED";
        }
        case SAPP_EVENTTYPE_RESUMED: {
            return "RESUMED";
        }
        case SAPP_EVENTTYPE_QUIT_REQUESTED: {
            return "QUIT_REQUESTED";
        }
        case SAPP_EVENTTYPE_CLIPBOARD_PASTED: {
            return "CLIPBOARD_PASTED";
        }
        case SAPP_EVENTTYPE_FILES_DROPPED: {
            return "FILES_DROPPED";
        }
        default: {
            return "???";
        }
    }
}

u8* _sappimgui_keycode_string(sapp_keycode k) {
    switch k {
        case SAPP_KEYCODE_INVALID: {
            return "INVALID";
        }
        case SAPP_KEYCODE_SPACE: {
            return "SPACE";
        }
        case SAPP_KEYCODE_APOSTROPHE: {
            return "APOSTROPHE";
        }
        case SAPP_KEYCODE_COMMA: {
            return "COMMA";
        }
        case SAPP_KEYCODE_MINUS: {
            return "MINUS";
        }
        case SAPP_KEYCODE_PERIOD: {
            return "PERIOD";
        }
        case SAPP_KEYCODE_SLASH: {
            return "SLASH";
        }
        case SAPP_KEYCODE_0: {
            return "0";
        }
        case SAPP_KEYCODE_1: {
            return "1";
        }
        case SAPP_KEYCODE_2: {
            return "2";
        }
        case SAPP_KEYCODE_3: {
            return "3";
        }
        case SAPP_KEYCODE_4: {
            return "4";
        }
        case SAPP_KEYCODE_5: {
            return "5";
        }
        case SAPP_KEYCODE_6: {
            return "6";
        }
        case SAPP_KEYCODE_7: {
            return "7";
        }
        case SAPP_KEYCODE_8: {
            return "8";
        }
        case SAPP_KEYCODE_9: {
            return "9";
        }
        case SAPP_KEYCODE_SEMICOLON: {
            return "SEMICOLON";
        }
        case SAPP_KEYCODE_EQUAL: {
            return "EQUAL";
        }
        case SAPP_KEYCODE_A: {
            return "A";
        }
        case SAPP_KEYCODE_B: {
            return "B";
        }
        case SAPP_KEYCODE_C: {
            return "C";
        }
        case SAPP_KEYCODE_D: {
            return "D";
        }
        case SAPP_KEYCODE_E: {
            return "E";
        }
        case SAPP_KEYCODE_F: {
            return "F";
        }
        case SAPP_KEYCODE_G: {
            return "G";
        }
        case SAPP_KEYCODE_H: {
            return "H";
        }
        case SAPP_KEYCODE_I: {
            return "I";
        }
        case SAPP_KEYCODE_J: {
            return "J";
        }
        case SAPP_KEYCODE_K: {
            return "K";
        }
        case SAPP_KEYCODE_L: {
            return "L";
        }
        case SAPP_KEYCODE_M: {
            return "M";
        }
        case SAPP_KEYCODE_N: {
            return "N";
        }
        case SAPP_KEYCODE_O: {
            return "O";
        }
        case SAPP_KEYCODE_P: {
            return "P";
        }
        case SAPP_KEYCODE_Q: {
            return "Q";
        }
        case SAPP_KEYCODE_R: {
            return "R";
        }
        case SAPP_KEYCODE_S: {
            return "S";
        }
        case SAPP_KEYCODE_T: {
            return "T";
        }
        case SAPP_KEYCODE_U: {
            return "U";
        }
        case SAPP_KEYCODE_V: {
            return "V";
        }
        case SAPP_KEYCODE_W: {
            return "W";
        }
        case SAPP_KEYCODE_X: {
            return "X";
        }
        case SAPP_KEYCODE_Y: {
            return "Y";
        }
        case SAPP_KEYCODE_Z: {
            return "Z";
        }
        case SAPP_KEYCODE_LEFT_BRACKET: {
            return "LEFT_BRACKET";
        }
        case SAPP_KEYCODE_BACKSLASH: {
            return "BACKSLASH";
        }
        case SAPP_KEYCODE_RIGHT_BRACKET: {
            return "RIGHT_BRACKET";
        }
        case SAPP_KEYCODE_GRAVE_ACCENT: {
            return "ACCENT";
        }
        case SAPP_KEYCODE_WORLD_1: {
            return "WORLD_1";
        }
        case SAPP_KEYCODE_WORLD_2: {
            return "WORLD_2";
        }
        case SAPP_KEYCODE_ESCAPE: {
            return "ESCAPE";
        }
        case SAPP_KEYCODE_ENTER: {
            return "ENTER";
        }
        case SAPP_KEYCODE_TAB: {
            return "TAB";
        }
        case SAPP_KEYCODE_BACKSPACE: {
            return "BACKSPACE";
        }
        case SAPP_KEYCODE_INSERT: {
            return "INSERT";
        }
        case SAPP_KEYCODE_DELETE: {
            return "DELETE";
        }
        case SAPP_KEYCODE_RIGHT: {
            return "RIGHT";
        }
        case SAPP_KEYCODE_LEFT: {
            return "LEFT";
        }
        case SAPP_KEYCODE_DOWN: {
            return "DOWN";
        }
        case SAPP_KEYCODE_UP: {
            return "UP";
        }
        case SAPP_KEYCODE_PAGE_UP: {
            return "PAGE_UP";
        }
        case SAPP_KEYCODE_PAGE_DOWN: {
            return "PAGE_DOWN";
        }
        case SAPP_KEYCODE_HOME: {
            return "HOME";
        }
        case SAPP_KEYCODE_END: {
            return "END";
        }
        case SAPP_KEYCODE_CAPS_LOCK: {
            return "CAPS_LOCK";
        }
        case SAPP_KEYCODE_SCROLL_LOCK: {
            return "SCROLL_LOCK";
        }
        case SAPP_KEYCODE_NUM_LOCK: {
            return "NUM_LOCK";
        }
        case SAPP_KEYCODE_PRINT_SCREEN: {
            return "PRINT_SCREEN";
        }
        case SAPP_KEYCODE_PAUSE: {
            return "PAUSE";
        }
        case SAPP_KEYCODE_F1: {
            return "F1";
        }
        case SAPP_KEYCODE_F2: {
            return "F2";
        }
        case SAPP_KEYCODE_F3: {
            return "F3";
        }
        case SAPP_KEYCODE_F4: {
            return "F4";
        }
        case SAPP_KEYCODE_F5: {
            return "F5";
        }
        case SAPP_KEYCODE_F6: {
            return "F6";
        }
        case SAPP_KEYCODE_F7: {
            return "F7";
        }
        case SAPP_KEYCODE_F8: {
            return "F8";
        }
        case SAPP_KEYCODE_F9: {
            return "F9";
        }
        case SAPP_KEYCODE_F10: {
            return "F10";
        }
        case SAPP_KEYCODE_F11: {
            return "F11";
        }
        case SAPP_KEYCODE_F12: {
            return "F12";
        }
        case SAPP_KEYCODE_F13: {
            return "F13";
        }
        case SAPP_KEYCODE_F14: {
            return "F14";
        }
        case SAPP_KEYCODE_F15: {
            return "F15";
        }
        case SAPP_KEYCODE_F16: {
            return "F16";
        }
        case SAPP_KEYCODE_F17: {
            return "F17";
        }
        case SAPP_KEYCODE_F18: {
            return "F18";
        }
        case SAPP_KEYCODE_F19: {
            return "F19";
        }
        case SAPP_KEYCODE_F20: {
            return "F20";
        }
        case SAPP_KEYCODE_F21: {
            return "F21";
        }
        case SAPP_KEYCODE_F22: {
            return "F22";
        }
        case SAPP_KEYCODE_F23: {
            return "F23";
        }
        case SAPP_KEYCODE_F24: {
            return "F24";
        }
        case SAPP_KEYCODE_F25: {
            return "F25";
        }
        case SAPP_KEYCODE_KP_0: {
            return "KP_0";
        }
        case SAPP_KEYCODE_KP_1: {
            return "KP_1";
        }
        case SAPP_KEYCODE_KP_2: {
            return "KP_2";
        }
        case SAPP_KEYCODE_KP_3: {
            return "KP_3";
        }
        case SAPP_KEYCODE_KP_4: {
            return "KP_4";
        }
        case SAPP_KEYCODE_KP_5: {
            return "KP_5";
        }
        case SAPP_KEYCODE_KP_6: {
            return "KP_6";
        }
        case SAPP_KEYCODE_KP_7: {
            return "KP_7";
        }
        case SAPP_KEYCODE_KP_8: {
            return "KP_8";
        }
        case SAPP_KEYCODE_KP_9: {
            return "KP_9";
        }
        case SAPP_KEYCODE_KP_DECIMAL: {
            return "KP_DECIMAL";
        }
        case SAPP_KEYCODE_KP_DIVIDE: {
            return "KP_DIVIDE";
        }
        case SAPP_KEYCODE_KP_MULTIPLY: {
            return "KP_MULTIPLY";
        }
        case SAPP_KEYCODE_KP_SUBTRACT: {
            return "KP_SUBTRACT";
        }
        case SAPP_KEYCODE_KP_ADD: {
            return "KP_ADD";
        }
        case SAPP_KEYCODE_KP_ENTER: {
            return "KP_ENTER";
        }
        case SAPP_KEYCODE_KP_EQUAL: {
            return "KP_EQUAL";
        }
        case SAPP_KEYCODE_LEFT_SHIFT: {
            return "LEFT_SHIFT";
        }
        case SAPP_KEYCODE_LEFT_CONTROL: {
            return "LEFT_CONTROL";
        }
        case SAPP_KEYCODE_LEFT_ALT: {
            return "LEFT_ALT";
        }
        case SAPP_KEYCODE_LEFT_SUPER: {
            return "LEFT_SUPER";
        }
        case SAPP_KEYCODE_RIGHT_SHIFT: {
            return "RIGHT_SHIFT";
        }
        case SAPP_KEYCODE_RIGHT_CONTROL: {
            return "RIGHT_CONTROL";
        }
        case SAPP_KEYCODE_RIGHT_ALT: {
            return "RIGHT_ALT";
        }
        case SAPP_KEYCODE_RIGHT_SUPER: {
            return "RIGHT_SUPER";
        }
        case SAPP_KEYCODE_MENU: {
            return "MENU";
        }
        default: {
            return "???";
        }
    }
}

u8* _sappimgui_mousebutton_string(sapp_mousebutton btn) {
    switch btn {
        case SAPP_MOUSEBUTTON_INVALID: {
            return "INVALID";
        }
        case SAPP_MOUSEBUTTON_LEFT: {
            return "LEFT";
        }
        case SAPP_MOUSEBUTTON_RIGHT: {
            return "RIGHT";
        }
        case SAPP_MOUSEBUTTON_MIDDLE: {
            return "MIDDLE";
        }
        default: {
            return "???";
        }
    }
}

u8* _sappimgui_androidtooltype_string(sapp_android_tooltype t) {
    switch t {
        case SAPP_ANDROIDTOOLTYPE_UNKNOWN: {
            return "UNKNOWN";
        }
        case SAPP_ANDROIDTOOLTYPE_FINGER: {
            return "FINGER";
        }
        case SAPP_ANDROIDTOOLTYPE_STYLUS: {
            return "STYLUS";
        }
        case SAPP_ANDROIDTOOLTYPE_MOUSE: {
            return "MOUSE";
        }
        default: {
            return "???";
        }
    }
}

//--- C => C++ layer -----------------------------------------------------------
void _sappimgui_igsameline() {
    ImGui_SameLine();
}

void _sappimgui_igtext(u8* fmt, ...) {
    ImGui_TextV(fmt, cast(void*, &...));
}

void _sappimgui_pushstylevar(ImGuiStyleVar v, f32 val) {
    ImGui_PushStyleVar(v, val);
}

void _sappimgui_popstylevar() {
    ImGui_PopStyleVar();
}

ImGuiViewport* _sappimgui_iggetmainviewport() {
    return ImGui_GetMainViewport();
}

void _sappimgui_igsetnextwindowpos(ImVec2 pos, ImGuiCond cond) {
    ImGui_SetNextWindowPos(pos, cond);
}

void _sappimgui_igsetnextwindowsize(ImVec2 size, ImGuiCond cond) {
    ImGui_SetNextWindowSize(size, cond);
}

void _sappimgui_igsetnextwindowbgalpha(f32 a) {
    ImGui_SetNextWindowBgAlpha(a);
}

bool _sappimgui_igbegin(u8* name, bool* p_open, ImGuiWindowFlags flags) {
    return ImGui_Begin(name, p_open, flags);
}

void _sappimgui_igend() {
    ImGui_End();
}

bool _sappimgui_igbeginmenu(u8* label) {
    return ImGui_BeginMenu(label);
}

void _sappimgui_igendmenu() {
    ImGui_EndMenu();
}

bool _sappimgui_igmenuitemboolptr(u8* label, u8* shortcut, bool* p_selected, bool enabled) {
    return ImGui_MenuItem(label, shortcut, p_selected, enabled);
}

void _sappimgui_igplotlines(u8* label, fn(void*, i32): f32 values_getter, void* data, i32 values_count, i32 values_offset, u8* overlay_text, f32 scale_min, f32 scale_max, ImVec2 graph_size) {
    ImGui_PlotLines(label, values_getter, data, values_count, values_offset, overlay_text, scale_min, scale_max, graph_size);
}

bool _sappimgui_igcollapsingheader(u8* label, ImGuiTreeNodeFlags flags) {
    return ImGui_CollapsingHeader(label, flags);
}

ImVec4 _sappimgui_getstylecolorvec4(ImGuiCol c) {
    return *ImGui_GetStyleColorVec4(c);
}

void _sappimgui_pushstylecolor(ImGuiCol idx, ImVec4 c) {
    ImGui_PushStyleColor(idx, c);
}

void _sappimgui_popstylecolor() {
    ImGui_PopStyleColor();
}

//--- internal ui functions -----------------------------------------------------
void _sappimgui_draw_modifiers(u32 modifiers) {
    _sappimgui_igsameline();
    if 0 == modifiers {
        _sappimgui_igtext("NONE");
    } else {
        if 0 != (modifiers & cast(u32, SAPP_MODIFIER_SHIFT)) {
            _sappimgui_igsameline();
            _sappimgui_igtext("SHIFT");
        }
        if 0 != (modifiers & cast(u32, SAPP_MODIFIER_CTRL)) {
            _sappimgui_igsameline();
            _sappimgui_igtext("CTRL");
        }
        if 0 != (modifiers & cast(u32, SAPP_MODIFIER_ALT)) {
            _sappimgui_igsameline();
            _sappimgui_igtext("ALT");
        }
        if 0 != (modifiers & cast(u32, SAPP_MODIFIER_SUPER)) {
            _sappimgui_igsameline();
            _sappimgui_igtext("SUPER");
        }
        if 0 != (modifiers & cast(u32, SAPP_MODIFIER_LMB)) {
            _sappimgui_igsameline();
            _sappimgui_igtext("LMB");
        }
        if 0 != (modifiers & cast(u32, SAPP_MODIFIER_RMB)) {
            _sappimgui_igsameline();
            _sappimgui_igtext("RMB");
        }
        if 0 != (modifiers & cast(u32, SAPP_MODIFIER_MMB)) {
            _sappimgui_igsameline();
            _sappimgui_igtext("MMB");
        }
    }
}

void _sappimgui_draw_event(sapp_event_type ev_type, u64 cur_frame_count) {
    sapp_event* ev = &_sappimgui.event_window.events[ev_type];
    u8* ev_name = _sappimgui_eventtype_string(ev_type);
    noinit u8[32] imgui_id;
    snprintf(imgui_id, sizeof(imgui_id), "###id_%d", cast(i32, ev_type));
    noinit u8[128] title;
    if ev.frame_count == 0 {
        snprintf(title, sizeof(title), "%s [none]%s", ev_name, imgui_id);
    } else {
        switch ev_type {
            case SAPP_EVENTTYPE_KEY_DOWN, SAPP_EVENTTYPE_KEY_UP: {
                snprintf(title, sizeof(title), "%s %s%s", ev_name, _sappimgui_keycode_string(ev.key_code), imgui_id);
            }
            case SAPP_EVENTTYPE_CHAR: {
                snprintf(title, sizeof(title), "%s 0x%05X%s", ev_name, ev.char_code, imgui_id);
            }
            case SAPP_EVENTTYPE_MOUSE_DOWN, SAPP_EVENTTYPE_MOUSE_UP: {
                snprintf(title, sizeof(title), "%s %s [%.2f, %.2f]%s", ev_name, _sappimgui_mousebutton_string(ev.mouse_button), ev.mouse_x, ev.mouse_y, imgui_id);
            }
            case SAPP_EVENTTYPE_MOUSE_SCROLL: {
                snprintf(title, sizeof(title), "%s [%.2f, %.2f]%s", ev_name, ev.scroll_x, ev.scroll_y, imgui_id);
            }
            case SAPP_EVENTTYPE_MOUSE_MOVE: {
                snprintf(title, sizeof(title), "%s [%.2f, %.2f] [%.2f, %.2f]%s", ev_name, ev.mouse_x, ev.mouse_y, ev.mouse_dx, ev.mouse_dy, imgui_id);
            }
            case SAPP_EVENTTYPE_RESIZED: {
                snprintf(title, sizeof(title), "%s [%d, %d]%s", ev_name, ev.framebuffer_width, ev.framebuffer_height, imgui_id);
            }
            case SAPP_EVENTTYPE_MOUSE_ENTER, SAPP_EVENTTYPE_MOUSE_LEAVE, SAPP_EVENTTYPE_ICONIFIED, SAPP_EVENTTYPE_RESTORED, SAPP_EVENTTYPE_FOCUSED, SAPP_EVENTTYPE_UNFOCUSED, SAPP_EVENTTYPE_SUSPENDED, SAPP_EVENTTYPE_RESUMED, SAPP_EVENTTYPE_QUIT_REQUESTED, SAPP_EVENTTYPE_CLIPBOARD_PASTED, SAPP_EVENTTYPE_FILES_DROPPED: {
                snprintf(title, sizeof(title), "%s%s", ev_name, imgui_id);
            }
            case SAPP_EVENTTYPE_TOUCHES_BEGAN, SAPP_EVENTTYPE_TOUCHES_MOVED, SAPP_EVENTTYPE_TOUCHES_ENDED, SAPP_EVENTTYPE_TOUCHES_CANCELLED: {
                snprintf(title, sizeof(title), "%s %d [%.2f, %.2f]%s", ev_name, ev.num_touches, ev.touches[0].pos_x, ev.touches[0].pos_y, imgui_id);
            }
            default: {
                snprintf(title, sizeof(title), "???%s", imgui_id);
            }
        }
    }
    var frame_age = cast(f32, cur_frame_count - ev.frame_count);
    f32 flash_intensity = (40.0f - frame_age) / 40.0f;
    if flash_intensity < 0.0f {
        flash_intensity = 0.0f;
    } else if flash_intensity > 1.0f {
        flash_intensity = 1.0f;
    }
    ImVec4 c = _sappimgui_getstylecolorvec4(ImGuiCol_Header);
    c.x += flash_intensity;
    c.y -= flash_intensity;
    c.z -= flash_intensity;
    c.w += flash_intensity;
    _sappimgui_pushstylecolor(ImGuiCol_Header, c);
    if _sappimgui_igcollapsingheader(title, 0) != 0 {
        _sappimgui_igtext("frame: %d", ev.frame_count);
        _sappimgui_igtext("type: %s", ev_name);
        _sappimgui_igtext("key code: %s", _sappimgui_keycode_string(ev.key_code));
        _sappimgui_igtext("char code: 0x%05X", ev.char_code);
        _sappimgui_igtext("key repeat: %s", _sappimgui_bool_string(ev.key_repeat));
        _sappimgui_igtext("modifiers: ");
        _sappimgui_draw_modifiers(ev.modifiers);
        _sappimgui_igtext("mouse button: %s", _sappimgui_mousebutton_string(ev.mouse_button));
        _sappimgui_igtext("mouse x: %.2f", ev.mouse_x);
        _sappimgui_igtext("mouse y: %.2f", ev.mouse_y);
        _sappimgui_igtext("scroll x: %.2f", ev.scroll_x);
        _sappimgui_igtext("scroll y: %.2f", ev.scroll_y);
        _sappimgui_igtext("window width: %d", ev.window_width);
        _sappimgui_igtext("window height: %d", ev.window_height);
        _sappimgui_igtext("framebuffer width: %d", ev.framebuffer_width);
        _sappimgui_igtext("framebuffer height: %d", ev.framebuffer_height);
        _sappimgui_igtext("num touches: %d", ev.num_touches);
        for i32 i = 0; i < ev.num_touches; i++ {
            _sappimgui_igtext("touch point %d", i);
            _sappimgui_igtext("  identifier: %x", ev.touches[i].identifier);
            _sappimgui_igtext("  pos x: %.2f", ev.touches[i].pos_x);
            _sappimgui_igtext("  pos y: %.2f", ev.touches[i].pos_y);
            _sappimgui_igtext("  changed: %s", _sappimgui_bool_string(ev.touches[i].changed));
            _sappimgui_igtext("  android tooltype: %s", _sappimgui_androidtooltype_string(ev.touches[i].android_tooltype));
        }
    }
    _sappimgui_popstylecolor();
}
}

//--- public functions ---------------------------------------------------------
void sappimgui_setup() {
    _sappimgui_clear(&_sappimgui, cast(u64, sizeof(_sappimgui)));
    _sappimgui.init_tag = 0xABCDABCD;
    _sappimgui_ring_init(&_sappimgui.frames.ring);
}

void sappimgui_shutdown() {
    _sappimgui.init_tag = 0;
}

void sappimgui_track_frame() {
    noinit _sappimgui_frame_t frame;
    _sappimgui_clear(&frame, cast(u64, sizeof(frame)));
    frame.frame_count = sapp_frame_count();
    frame.filtered_dt = sapp_frame_duration();
    frame.raw_dt = sapp_frame_duration_unfiltered();
    _sappimgui_add_frame(&frame);
}

void sappimgui_track_event(sapp_event* ev) {
    _sappimgui.event_window.events[cast(i32, ev.type)] = *ev;
}

void sappimgui_draw() {
    sappimgui_draw_hud_window("[sapp] Hud");
    sappimgui_draw_publicstate_window("[sapp] Public State");
    sappimgui_draw_event_window("[sapp] Events");
}

void sappimgui_draw_menu(u8* title) {
    if _sappimgui_igbeginmenu(title) != 0 {
        sappimgui_draw_hud_menu_item("Hud");
        sappimgui_draw_publicstate_menu_item("Public State");
        sappimgui_draw_event_menu_item("Events");
        _sappimgui_igendmenu();
    }
}

void sappimgui_draw_hud_menu_item(u8* label) {
    _sappimgui_igmenuitemboolptr(label, null, &_sappimgui.hud_window.open, true);
}

void sappimgui_draw_publicstate_menu_item(u8* label) {
    _sappimgui_igmenuitemboolptr(label, null, &_sappimgui.publicstate_window.open, true);
}

void sappimgui_draw_event_menu_item(u8* label) {
    _sappimgui_igmenuitemboolptr(label, null, &_sappimgui.event_window.open, true);
}

void sappimgui_draw_hud_window(u8* title) {
    if _sappimgui.hud_window.open == 0 {
        return;
    }
    ImVec2 vp_workpos = _sappimgui_iggetmainviewport().WorkPos;
    _sappimgui_igsetnextwindowpos(ImVec2{vp_workpos.x + 20.0f, vp_workpos.y + 10.0f}, ImGuiCond_Once);
    _sappimgui_igsetnextwindowsize(ImVec2{256.0f, 30.0f}, ImGuiCond_Once);
    _sappimgui_igsetnextwindowbgalpha(0.5f);
    _sappimgui_pushstylevar(ImGuiStyleVar_WindowRounding, 8.0f);
    ImGuiWindowFlags f = ImGuiWindowFlags_AlwaysAutoResize | ImGuiWindowFlags_NoDecoration;
    if _sappimgui_igbegin(title, &_sappimgui.hud_window.open, f) != 0 {
        sappimgui_draw_hud_window_content();
    }
    _sappimgui_popstylevar();
    _sappimgui_igend();
}

void sappimgui_draw_publicstate_window(u8* title) {
    if _sappimgui.publicstate_window.open == 0 {
        return;
    }
    if _sappimgui_igbegin(title, &_sappimgui.publicstate_window.open, 0) != 0 {
        sappimgui_draw_publicstate_window_content();
    }
    _sappimgui_igend();
}

void sappimgui_draw_event_window(u8* title) {
    if _sappimgui.event_window.open == 0 {
        return;
    }
    _sappimgui_igsetnextwindowsize(ImVec2{360.0f, 512.0f}, ImGuiCond_Once);
    if _sappimgui_igbegin(title, &_sappimgui.event_window.open, 0) != 0 {
        sappimgui_draw_event_window_content();
    }
    _sappimgui_igend();
}

void sappimgui_draw_hud_window_content() {
    _sappimgui_frame_stats_t stats = _sappimgui_frame_stats();
    f32 scale_min = cast(f32, stats.filtered.average * 1000.0) - 4.0f;
    f32 scale_max = cast(f32, stats.filtered.average * 1000.0) + 4.0f;
    f64 cur_dt = sapp_frame_duration();
    var fps = cast(i32, round(1.0 / cur_dt));
    _sappimgui_igtext("fps: %d (%.3fms)", fps, cur_dt * 1000.0);
    _sappimgui_igplotlines("##filtered", cast(fn(void*, i32): f32, _sappimgui_filtered_dt_getter), null, 256 - 1, 0, "filtered frame dt (ms)", scale_min, scale_max, ImVec2{256.0f, 48.0f});
    _sappimgui_igsameline();
    _sappimgui_igtext("min: %6.3fms\nmax: %6.3fms", stats.filtered.minimum * 1000.0, stats.filtered.maximum * 1000.0);
    _sappimgui_igplotlines("##raw", cast(fn(void*, i32): f32, _sappimgui_raw_dt_getter), null, 256 - 1, 0, "raw frame dt (ms)", scale_min, scale_max, ImVec2{256.0f, 48.0f});
    _sappimgui_igsameline();
    _sappimgui_igtext("min: %6.3fms\nmax: %6.3fms", stats.raw.minimum * 1000.0, stats.raw.maximum * 1000.0);
}

void sappimgui_draw_publicstate_window_content() {
    _sappimgui_igtext("width: %d", sapp_width());
    _sappimgui_igtext("height: %d", sapp_height());
    _sappimgui_igtext("color format: %s", _sappimgui_pixelformat_string(sapp_color_format()));
    _sappimgui_igtext("depth format: %s", _sappimgui_pixelformat_string(sapp_depth_format()));
    _sappimgui_igtext("sample count: %d", sapp_sample_count());
    _sappimgui_igtext("high dpi: %s", _sappimgui_bool_string(sapp_high_dpi()));
    _sappimgui_igtext("dpi scale: %f", sapp_dpi_scale());
    _sappimgui_igtext("frame count: %d", sapp_frame_count());
    _sappimgui_igtext("frame duration: %.6f", sapp_frame_duration());
    _sappimgui_igtext("frame duration unfiltered: %.6f", sapp_frame_duration_unfiltered());
    _sappimgui_igtext("is fullscreen: %s", _sappimgui_bool_string(sapp_is_fullscreen()));
    _sappimgui_igtext("mouse shown: %s", _sappimgui_bool_string(sapp_mouse_shown()));
    _sappimgui_igtext("mouse locked: %s", _sappimgui_bool_string(sapp_mouse_locked()));
    _sappimgui_igtext("mouse cursor: %s", _sappimgui_mousecursor_string(sapp_get_mouse_cursor()));
    _sappimgui_igtext("user data: %p", sapp_userdata());
    _sappimgui_igtext("clipboard string: %s", sapp_get_clipboard_string());
    _sappimgui_igtext("num dropped files: %d", sapp_get_num_dropped_files());
    for i32 i = 0; i < sapp_get_num_dropped_files(); i++ {
        _sappimgui_igtext("dropped file path #%d: %s", sapp_get_dropped_file_path(i));
    }
}

void sappimgui_draw_event_window_content() {
    u64 cur_frame_count = sapp_frame_count();
    for i32 i = 1; i < _SAPP_EVENTTYPE_NUM; i++ {
        _sappimgui_draw_event(cast(sapp_event_type, i), cur_frame_count);
    }
}

