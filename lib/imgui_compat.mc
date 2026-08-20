// imgui_compat
import imgui;
import math;

// Call shapes the upstream samples were written against, forwarded
// onto the bundled Dear ImGui API.

// imgui 1.90 turned BeginChild's `bool border` into ImGuiChildFlags.
bool ImGui_BeginChild(u8* str_id, ImVec2 size_arg, bool border,
                      ImGuiWindowFlags window_flags) {
    ImGuiChildFlags cf = ImGuiChildFlags_None;
    if border { cf = ImGuiChildFlags_Borders; }
    return ImGui_BeginChild(str_id, size_arg, cf, window_flags);
}

void ImDrawList_AddCallback(ImDrawList* self, ImDrawCallback callback) {
    ImDrawList_AddCallback(self, callback, null, cast(u64, 0));
}

bool ImGui_Combo(u8* label, i32* current_item, fn(void*, i32): u8* getter,
                 void* user_data, i32 items_count) {
    return ImGui_Combo(label, current_item, getter, user_data, items_count, 0 - 1);
}

bool ImGui_Combo(u8* label, i32* current_item, u8** items, i32 items_count) {
    return ImGui_Combo(label, current_item, items, items_count, 0 - 1);
}

bool ImGui_SliderFloat2(u8* label, f32* v, f32 v_min, f32 v_max) {
    return ImGui_SliderFloat2(label, v, v_min, v_max, "%.3f", 0);
}

// imgui_demo.cpp is not bundled in lib/imgui.mc. This window mirrors a
// subset of ShowDemoWindow with the same section layout.
private {
    bool _demo_inited;
    bool _demo_checked = true;
    f32  _demo_slider = 0.5f;
    i32  _demo_clicks = 0;
    i32  _demo_radio = 0;
    i32  _demo_slider_i = 3;
    f32  _demo_drag = 1.0f;
    i32  _demo_combo = 0;
    u8[128] _demo_text;
    f32[4] _demo_color;
    i32  _demo_listbox = 0;
    f32[7] _demo_frame_times;
    i32  _demo_input_int = 5;
    f32  _demo_input_float = 1.5f;
    f32  _demo_angle = 0.5f;
    i32  _demo_drag_int = 20;
    i32  _demo_dnd_received = 0;
    f32[3] _demo_vec3;
    i32[2] _demo_vec2i;
    f64  _demo_dbl = 3.14159;
    u8[256] _demo_multiline;
    u8[64] _demo_hint;
    f32[3] _demo_col3;
    f32[4] _demo_pick;
    f32  _demo_vslider = 0.5f;
    i32  _demo_status_clicks = 0;
    bool[5] _demo_selected;
    f32  _demo_progress = 0.0f;
    f32  _demo_slider_log = 0.5f;
    bool _demo_show_metrics = false;
    bool _demo_no_titlebar = false;
    bool _demo_no_scrollbar = false;
    bool _demo_no_menu = false;
    bool _demo_no_move = false;
    bool _demo_no_resize = false;
    bool _demo_no_collapse = false;
    bool _demo_no_nav = false;
    bool _demo_no_background = false;
    bool _demo_no_front = false;
    f32[90] _demo_anim;
    i32  _demo_anim_off = 0;
    f32  _demo_anim_phase = 0.0f;
    bool _demo_animate = true;
    f64  _demo_refresh_time = 0.0;
}

private void _demo_set_text(u8* dst, u8* src, i32 cap) {
    i32 i = 0;
    for ; i < cap - 1 && src[i] != 0; i++ { dst[i] = src[i]; }
    dst[i] = 0;
}

private void _demo_init() {
    _demo_set_text(_demo_text, "type here", 128);
    _demo_color[0] = 0.4f; _demo_color[1] = 0.7f; _demo_color[2] = 0.95f; _demo_color[3] = 1.0f;
    _demo_vec3[0] = 0.1f; _demo_vec3[1] = 0.2f; _demo_vec3[2] = 0.3f;
    _demo_vec2i[0] = 1; _demo_vec2i[1] = 2;
    _demo_col3[0] = 0.2f; _demo_col3[1] = 0.5f; _demo_col3[2] = 0.8f;
    _demo_pick[0] = 0.3f; _demo_pick[1] = 0.6f; _demo_pick[2] = 0.9f; _demo_pick[3] = 1.0f;
    _demo_set_text(_demo_multiline, "multi-line\ntext editor", 256);
    _demo_hint[0] = 0;
    // the original demo's static "Frame Times" sample array
    _demo_frame_times[0] = 0.6f; _demo_frame_times[1] = 0.1f; _demo_frame_times[2] = 1.0f;
    _demo_frame_times[3] = 0.5f; _demo_frame_times[4] = 0.92f; _demo_frame_times[5] = 0.1f;
    _demo_frame_times[6] = 0.2f;
}

void ImGui_ShowDemoWindow(bool* p_open) {
    if !_demo_inited { _demo_inited = true; _demo_init(); }

    ImGuiWindowFlags wflags = cast(ImGuiWindowFlags, 0);
    if !_demo_no_menu       { wflags = wflags | ImGuiWindowFlags_MenuBar; }
    if _demo_no_titlebar    { wflags = wflags | ImGuiWindowFlags_NoTitleBar; }
    if _demo_no_scrollbar   { wflags = wflags | ImGuiWindowFlags_NoScrollbar; }
    if _demo_no_move        { wflags = wflags | ImGuiWindowFlags_NoMove; }
    if _demo_no_resize      { wflags = wflags | ImGuiWindowFlags_NoResize; }
    if _demo_no_collapse    { wflags = wflags | ImGuiWindowFlags_NoCollapse; }
    if _demo_no_nav         { wflags = wflags | ImGuiWindowFlags_NoNav; }
    if _demo_no_background  { wflags = wflags | ImGuiWindowFlags_NoBackground; }
    if _demo_no_front       { wflags = wflags | ImGuiWindowFlags_NoBringToFrontOnFocus; }
    ImGui_SetNextWindowSize(ImVec2{550.0f, 680.0f}, ImGuiCond_FirstUseEver);
    if ImGui_Begin("Dear ImGui Demo", p_open, wflags) {
        if ImGui_BeginMenuBar() {
            if ImGui_BeginMenu("Menu", true) {
                ignore ImGui_MenuItem("New", null, false, true);
                ignore ImGui_MenuItem("Open", "Ctrl+O", false, true);
                ignore ImGui_MenuItem("Save", "Ctrl+S", false, true);
                ImGui_Separator();
                ignore ImGui_MenuItem("Quit", "Alt+F4", false, true);
                ImGui_EndMenu();
            }
            if ImGui_BeginMenu("Tools", true) {
                ImGui_MenuItem("Metrics/Debugger", null, &_demo_show_metrics, true);
                ImGui_EndMenu();
            }
            ImGui_EndMenuBar();
        }

        ImGui_Text("dear imgui says hello!");
        ImGui_Spacing();

        if ImGui_CollapsingHeader("Help", 0) {
            ImGui_SeparatorText("ABOUT THIS DEMO:");
            ImGui_BulletText("This window mirrors a subset of Dear ImGui's demo,");
            ImGui_BulletText("written against the bundled minc imgui port.");
        }

        if ImGui_CollapsingHeader("Configuration", 0) {
            var io = ImGui_GetIO();
            ImGui_Text("%.3f ms/frame (%.1f FPS)", 1000.0f / io.Framerate, io.Framerate);
            ImGui_SeparatorText("Flags");
            ImGui_Text("io.ConfigFlags = 0x%08X", cast(i32, io.ConfigFlags));
            ImGui_Checkbox("a config checkbox", &_demo_checked);
        }

        if ImGui_CollapsingHeader("Window options", 0) {
            ImGui_Checkbox("No titlebar", &_demo_no_titlebar);      ImGui_SameLine(150.0f, -1.0f);
            ImGui_Checkbox("No scrollbar", &_demo_no_scrollbar);    ImGui_SameLine(300.0f, -1.0f);
            ImGui_Checkbox("No menu", &_demo_no_menu);
            ImGui_Checkbox("No move", &_demo_no_move);              ImGui_SameLine(150.0f, -1.0f);
            ImGui_Checkbox("No resize", &_demo_no_resize);          ImGui_SameLine(300.0f, -1.0f);
            ImGui_Checkbox("No collapse", &_demo_no_collapse);
            ImGui_Checkbox("No nav", &_demo_no_nav);                ImGui_SameLine(150.0f, -1.0f);
            ImGui_Checkbox("No background", &_demo_no_background);   ImGui_SameLine(300.0f, -1.0f);
            ImGui_Checkbox("No bring to front", &_demo_no_front);
        }

        if ImGui_CollapsingHeader("Widgets", 0) {
            if ImGui_TreeNode("Basic") {
                if ImGui_Button("Button", ImVec2{0.0f, 0.0f}) { _demo_clicks = _demo_clicks + 1; }
                ImGui_SameLine(0.0f, -1.0f);
                ImGui_Text("clicks: %d", _demo_clicks);
                if ImGui_SmallButton("Small Button") { _demo_clicks = _demo_clicks + 1; }
                ImGui_SameLine(0.0f, -1.0f);
                ignore ImGui_ArrowButton("##left", ImGuiDir_Left);
                ImGui_SameLine(0.0f, -1.0f);
                ignore ImGui_ArrowButton("##right", ImGuiDir_Right);
                ImGui_Checkbox("checkbox", &_demo_checked);
                ImGui_RadioButton("radio a", &_demo_radio, 0); ImGui_SameLine(0.0f, -1.0f);
                ImGui_RadioButton("radio b", &_demo_radio, 1); ImGui_SameLine(0.0f, -1.0f);
                ImGui_RadioButton("radio c", &_demo_radio, 2);
                u8*[3] combo_items = {"alpha", "beta", "gamma"};
                ImGui_Combo("combo", &_demo_combo, combo_items, 3, -1);
                ImGui_SliderFloat("slider float", &_demo_slider, 0.0f, 1.0f, null, 0);
                ImGui_SliderInt("slider int", &_demo_slider_i, 0, 10, null, 0);
                ImGui_DragFloat("drag float", &_demo_drag, 0.1f, 0.0f, 0.0f, null, 0);
                ImGui_PushStyleVar(ImGuiStyleVar_FrameRounding, 6.0f);
                ImGui_Button("rounded button", ImVec2{0.0f, 0.0f});
                ImGui_PopStyleVar(1);
                ImGui_TreePop();
            }
            if ImGui_TreeNode("Tooltips") {
                ImGui_Button("Hover me", ImVec2{0.0f, 0.0f});
                if ImGui_IsItemHovered(0) {
                    if ImGui_BeginTooltip() {
                        ImGui_TextUnformatted("I am a tooltip", null);
                        ImGui_EndTooltip();
                    }
                }
                ImGui_TreePop();
            }
            if ImGui_TreeNode("Tree Nodes") {
                if ImGui_TreeNode("tree root") {
                    if ImGui_TreeNode("branch") {
                        ImGui_TextUnformatted("leaf", null);
                        ImGui_TreePop();
                    }
                    ImGui_TextUnformatted("sibling", null);
                    ImGui_TreePop();
                }
                ImGui_TreePop();
            }
            if ImGui_TreeNode("Collapsing Headers") {
                if ImGui_CollapsingHeader("a nested collapsing header", 0) {
                    ImGui_TextUnformatted("content under the header", null);
                }
                ImGui_TreePop();
            }
            if ImGui_TreeNode("Bullets") {
                ImGui_BulletText("Bullet point 1");
                ImGui_BulletText("Bullet point 2");
                ImGui_TreePop();
            }
            if ImGui_TreeNode("Text") {
                ImGui_TextColored(ImVec4{1.0f, 0.6f, 0.2f, 1.0f}, "colored text");
                ImGui_TextDisabled("disabled text");
                ImGui_TextWrapped("wrapped text that is long enough to wrap inside the window width when the panel is narrow");
                ImGui_LabelText("label", "value %d", 3);
                ImGui_SeparatorText("a separator with text");
                ImGui_TreePop();
            }
            if ImGui_TreeNode("Images") {
                var io = ImGui_GetIO();
                if io.Fonts != null && io.Fonts.TexData != null {
                    ImTextureRef tex = io.Fonts.TexRef;
                    f32 tw = cast(f32, io.Fonts.TexData.Width);
                    f32 th = cast(f32, io.Fonts.TexData.Height);
                    ImGui_Text("Font atlas texture: %.0fx%.0f", tw, th);
                    ImGui_Image(tex, ImVec2{tw, th}, ImVec2{0.0f, 0.0f}, ImVec2{1.0f, 1.0f});
                }
                ImGui_TreePop();
            }
            if ImGui_TreeNode("Combo") {
                u8*[5] combo2_items = {"AAAA", "BBBB", "CCCC", "DDDD", "EEEE"};
                if ImGui_BeginCombo("combo", combo2_items[_demo_combo], 0) {
                    for i32 n = 0; n < 5; n++ {
                        bool is_sel = _demo_combo == n;
                        if ImGui_Selectable(combo2_items[n], is_sel, 0, ImVec2{0.0f, 0.0f}) { _demo_combo = n; }
                    }
                    ImGui_EndCombo();
                }
                ImGui_TreePop();
            }
            if ImGui_TreeNode("List boxes") {
                u8*[4] list_items = {"item one", "item two", "item three", "item four"};
                ImGui_ListBox("listbox", &_demo_listbox, list_items, 4, 4);
                ImGui_TreePop();
            }
            if ImGui_TreeNode("Selectables") {
                if ImGui_Selectable("1. I am selectable", _demo_selected[0], 0, ImVec2{0.0f, 0.0f}) { _demo_selected[0] = !_demo_selected[0]; }
                if ImGui_Selectable("2. I am selectable", _demo_selected[1], 0, ImVec2{0.0f, 0.0f}) { _demo_selected[1] = !_demo_selected[1]; }
                if ImGui_Selectable("3. I am selectable", _demo_selected[2], 0, ImVec2{0.0f, 0.0f}) { _demo_selected[2] = !_demo_selected[2]; }
                ImGui_TreePop();
            }
            if ImGui_TreeNode("Text Input") {
                ImGui_InputText("input text", _demo_text, 128, 0, null, null);
                ImGui_InputTextMultiline("multiline", _demo_multiline, 256, ImVec2{0.0f, 60.0f}, 0, null, null);
                ImGui_InputTextWithHint("with hint", "type here...", _demo_hint, 64, 0, null, null);
                ImGui_TreePop();
            }
            if ImGui_TreeNode("Tabs") {
                if ImGui_BeginTabBar("tabs", 0) {
                    if ImGui_BeginTabItem("first", null, 0) {
                        if ImGui_BeginChild("first_scroll", ImVec2{0.0f, 80.0f}, ImGuiChildFlags_Borders, 0) {
                            for i32 row = 0; row < 20; row++ { ImGui_Text("first row %d", row); }
                        }
                        ImGui_EndChild();
                        ImGui_EndTabItem();
                    }
                    if ImGui_BeginTabItem("second", null, 0) {
                        if ImGui_BeginChild("second_scroll", ImVec2{0.0f, 80.0f}, ImGuiChildFlags_Borders, 0) {
                            for i32 row = 0; row < 20; row++ { ImGui_Text("second row %d", row); }
                        }
                        ImGui_EndChild();
                        ImGui_EndTabItem();
                    }
                    ImGui_EndTabBar();
                }
                ImGui_TreePop();
            }
            if ImGui_TreeNode("Plotting") {
                ImGui_Checkbox("Animate", &_demo_animate);
                ImGui_PlotLines("Frame Times", _demo_frame_times, 7, 0, null, 3.402823466e+38f, 3.402823466e+38f, ImVec2{0.0f, 0.0f}, 4);
                ImGui_PlotHistogram("Histogram", _demo_frame_times, 7, 0, null, 0.0f, 1.0f, ImVec2{0.0f, 80.0f}, 4);
                if !_demo_animate || _demo_refresh_time == 0.0 { _demo_refresh_time = ImGui_GetTime(); }
                while _demo_refresh_time < ImGui_GetTime() {
                    _demo_anim[_demo_anim_off] = cosf(_demo_anim_phase);
                    _demo_anim_off = (_demo_anim_off + 1) % 90;
                    _demo_anim_phase = _demo_anim_phase + 0.1f * cast(f32, _demo_anim_off);
                    _demo_refresh_time = _demo_refresh_time + 1.0 / 60.0;
                }
                ImGui_PlotLines("Lines", _demo_anim, 90, _demo_anim_off, null, -1.0f, 1.0f, ImVec2{0.0f, 80.0f}, 4);
                ImGui_TreePop();
            }
            if ImGui_TreeNode("Progress Bars") {
                _demo_progress = _demo_progress + 0.004f;
                if _demo_progress > 1.0f { _demo_progress = 0.0f; }
                ImGui_ProgressBar(_demo_progress, ImVec2{0.0f, 0.0f}, null);
                ImGui_ProgressBar(_demo_progress, ImVec2{0.0f, 0.0f}, "loading...");
                ImGui_TreePop();
            }
            if ImGui_TreeNode("Color/Picker Widgets") {
                ImGui_ColorEdit3("color 1", _demo_col3, 0);
                ImGui_ColorEdit4("color 2", _demo_color, 0);
                ignore ImGui_ColorButton("swatch", ImVec4{_demo_col3[0], _demo_col3[1], _demo_col3[2], 1.0f}, 0, ImVec2{0.0f, 0.0f});
                ImGui_ColorPicker4("picker", _demo_pick, 0, null);
                ImGui_TreePop();
            }
            if ImGui_TreeNode("Drag and Slider Flags") {
                ImGui_DragFloat("drag (AlwaysClamp)", &_demo_drag, 0.1f, 0.0f, 1.0f, null, ImGuiSliderFlags_AlwaysClamp);
                ImGui_SliderFloat("slider (Logarithmic)", &_demo_slider_log, 0.001f, 10.0f, "%.4f", ImGuiSliderFlags_Logarithmic);
                ImGui_TreePop();
            }
            if ImGui_TreeNode("Data Types") {
                ImGui_InputInt("input int", &_demo_input_int, 1, 10, 0);
                ImGui_InputFloat("input float", &_demo_input_float, 0.1f, 1.0f, "%.3f", 0);
                ImGui_InputDouble("input double", &_demo_dbl, 0.1, 1.0, "%.5f", 0);
                ImGui_SliderAngle("slider angle", &_demo_angle, -360.0f, 360.0f, "%.0f deg", 0);
                ImGui_DragInt("drag int", &_demo_drag_int, 1.0f, 0, 100, "%d", 0);
                ImGui_TreePop();
            }
            if ImGui_TreeNode("Multi-component Widgets") {
                ImGui_SliderFloat3("slider float3", _demo_vec3, 0.0f, 1.0f, null, 0);
                ImGui_DragFloat3("drag float3", _demo_vec3, 0.01f, 0.0f, 0.0f, null, 0);
                ImGui_InputFloat3("input float3", _demo_vec3, null, 0);
                ImGui_SliderInt2("slider int2", _demo_vec2i, 0, 10, null, 0);
                ImGui_TreePop();
            }
            if ImGui_TreeNode("Vertical Sliders") {
                ImGui_VSliderFloat("##v", ImVec2{20.0f, 80.0f}, &_demo_vslider, 0.0f, 1.0f, null, 0);
                ImGui_TreePop();
            }
            if ImGui_TreeNode("Drag and Drop") {
                ImGui_Button("Drag source", ImVec2{0.0f, 0.0f});
                if ImGui_BeginDragDropSource(0) {
                    i32 payload = 7;
                    ignore ImGui_SetDragDropPayload("DEMO_INT", &payload, sizeof(i32), 0);
                    ImGui_TextUnformatted("dragging 7", null);
                    ImGui_EndDragDropSource();
                }
                ImGui_SameLine(0.0f, -1.0f);
                ImGui_Text("Drop target (got %d)", _demo_dnd_received);
                if ImGui_BeginDragDropTarget() {
                    ImGuiPayload* p = ImGui_AcceptDragDropPayload("DEMO_INT", 0);
                    if p != null { _demo_dnd_received = *cast(i32*, p.Data); }
                    ImGui_EndDragDropTarget();
                }
                ImGui_TreePop();
            }
            if ImGui_TreeNode("Querying Item Status") {
                if ImGui_Button("status button", ImVec2{0.0f, 0.0f}) { _demo_status_clicks = _demo_status_clicks + 1; }
                ImGui_Text("active=%d clicks=%d", cast(i32, ImGui_IsItemActive()), _demo_status_clicks);
                for i32 i = 0; i < 4; i++ {
                    ImGui_PushID(i);
                    if ImGui_SmallButton("dup") { _demo_clicks = _demo_clicks + 1; }
                    ImGui_SameLine(0.0f, -1.0f);
                    ImGui_PopID();
                }
                ImGui_NewLine();
                ImGui_TreePop();
            }
            if ImGui_TreeNode("Querying Window Status") {
                ImGui_Text("IsWindowFocused() = %d", cast(i32, ImGui_IsWindowFocused(0)));
                ImGui_Text("IsWindowHovered() = %d", cast(i32, ImGui_IsWindowHovered(0)));
                ImGui_TreePop();
            }
        }

        if ImGui_CollapsingHeader("Layout & Scrolling", 0) {
            if ImGui_TreeNode("Indent / Group") {
                ImGui_Indent(0.0f);
                ImGui_TextUnformatted("indented line", null);
                ImGui_Unindent(0.0f);
                ImGui_BeginGroup();
                ImGui_TextUnformatted("grouped A", null);
                ImGui_TextUnformatted("grouped B", null);
                ImGui_EndGroup();
                ImGui_TreePop();
            }
            if ImGui_TreeNode("Columns") {
                ImGui_Columns(2, "cols", true);
                ImGui_TextUnformatted("left column", null); ImGui_NextColumn();
                ImGui_TextUnformatted("right column", null); ImGui_NextColumn();
                ImGui_Columns(1, null, false);
                ImGui_TreePop();
            }
            if ImGui_TreeNode("Disabled") {
                ImGui_BeginDisabled(true);
                ImGui_Button("disabled button", ImVec2{0.0f, 0.0f});
                ImGui_EndDisabled();
                ImGui_TreePop();
            }
        }

        if ImGui_CollapsingHeader("Popups & Modal windows", 0) {
            if ImGui_TreeNode("Popups") {
                ImGui_Button("right-click me", ImVec2{0.0f, 0.0f});
                if ImGui_BeginPopupContextItem("ctx", ImGuiPopupFlags_MouseButtonRight) {
                    if ImGui_Selectable("a context action", false, 0, ImVec2{0.0f, 0.0f}) { _demo_clicks = _demo_clicks + 1; }
                    ImGui_EndPopup();
                }
                ImGui_TreePop();
            }
            if ImGui_TreeNode("Modals") {
                if ImGui_Button("Open Modal", ImVec2{0.0f, 0.0f}) { ImGui_OpenPopup("Delete?", 0); }
                if ImGui_BeginPopupModal("Delete?", null, 0) {
                    ImGui_TextUnformatted("This is a modal popup.", null);
                    if ImGui_Button("OK", ImVec2{0.0f, 0.0f}) { ImGui_CloseCurrentPopup(); }
                    ImGui_EndPopup();
                }
                ImGui_TreePop();
            }
        }

        if ImGui_CollapsingHeader("Tables & Columns", 0) {
            if ImGui_BeginTable("table", 2, 0, ImVec2{0.0f, 0.0f}, 0.0f) {
                ImGui_TableSetupColumn("name", 0, 0.0f, 0);
                ImGui_TableSetupColumn("value", 0, 0.0f, 0);
                ImGui_TableHeadersRow();
                ImGui_TableNextRow(0, 0.0f);
                ImGui_TableNextColumn();
                ImGui_TextUnformatted("slider float", null);
                ImGui_TableNextColumn();
                ImGui_Text("%.3f", _demo_slider);
                ImGui_EndTable();
            }
        }

        if ImGui_CollapsingHeader("Inputs & Focus", 0) {
            var io = ImGui_GetIO();
            ImGui_Text("Mouse pos: (%.1f, %.1f)", io.MousePos.x, io.MousePos.y);
            ImGui_Text("Mouse left down: %d", cast(i32, ImGui_IsMouseDown(ImGuiMouseButton_Left)));
            ImGui_Text("KeyCtrl: %d", cast(i32, io.KeyCtrl));
            ImGui_Text("Space down: %d", cast(i32, ImGui_IsKeyDown(ImGuiKey_Space)));
        }
    }
    ImGui_End();

    if _demo_show_metrics { ImGui_ShowMetricsWindow(&_demo_show_metrics); }
}

