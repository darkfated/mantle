local function L(key)
    return Mantle.lang.get('mantle_menu', key)
end

local function buildPanel(tab)
    local panel = vgui.Create('MantleScrollPanel')

    local cat = vgui.Create('MantleCategory', panel)
    cat:Dock(TOP)
    cat:SetText(L('legacy_category'))
    cat:SetActive(true)

    local button = vgui.Create('MantleBtn', cat)
    button:Dock(TOP)
    button:SetTxt(L('legacy_btn_view'))
    button.DoClick = function()
        local frame = vgui.Create('DFrame')
        frame:SetSize(400, 300)
        frame:Center()
        frame:MakePopup()
        Mantle.ui.frame(frame, L('legacy_frame_title'), 400, 300, true, true)

        local scroll = vgui.Create('DScrollPanel', frame)
        scroll:Dock(FILL)
        Mantle.ui.sp(scroll)

        local btn1 = vgui.Create('DButton', scroll)
        btn1:Dock(TOP)
        btn1:DockMargin(8, 8, 8, 8)
        btn1:SetText(L('legacy_btn_default'))
        Mantle.ui.btn(btn1)

        local btn2 = vgui.Create('DButton', scroll)
        btn2:Dock(TOP)
        btn2:DockMargin(8, 8, 8, 8)
        btn2:SetText(L('legacy_btn_icon'))
        Mantle.ui.btn(btn2, Material('icon16/accept.png'), 16)

        local btn3 = vgui.Create('DButton', scroll)
        btn3:Dock(TOP)
        btn3:DockMargin(8, 8, 8, 8)
        btn3:SetText(L('legacy_btn_no_gradient'))
        Mantle.ui.btn(btn3, nil, nil, nil, nil, true)

        local btn4 = vgui.Create('DButton', scroll)
        btn4:Dock(TOP)
        btn4:DockMargin(8, 8, 8, 8)
        btn4:SetText(L('legacy_btn_no_hover'))
        Mantle.ui.btn(btn4, nil, nil, nil, nil, nil, nil, true)

        local slider1 = Mantle.ui.slidebox(scroll, L('legacy_slider_skybox'), 0, 5, 'r_skybox', 0)
        slider1:DockMargin(8, 8, 8, 8)

        local slider2 = Mantle.ui.slidebox(scroll, L('legacy_slider_hud'), 0, 1, 'cl_drawhud', 2)
        slider2:DockMargin(8, 8, 8, 8)

        local entry1, entry_bg1 = Mantle.ui.desc_entry(scroll, L('legacy_entry_title'), L('legacy_entry_placeholder'))
        entry_bg1:DockMargin(8, 8, 8, 8)

        local entry2, entry_bg2 = Mantle.ui.desc_entry(scroll, nil, L('legacy_entry_no_title'))
        entry_bg2:DockMargin(8, 8, 8, 8)

        local checkbox1 = Mantle.ui.checkbox(scroll, L('legacy_checkbox_convar'), 'cl_drawhud')
        checkbox1:DockMargin(8, 8, 8, 8)

        local checkbox2 = Mantle.ui.checkbox(scroll, L('legacy_checkbox'))
        checkbox2:DockMargin(8, 8, 8, 8)

        local panelTabs = vgui.Create('Panel', scroll)
        panelTabs:Dock(TOP)
        panelTabs:DockMargin(8, 8, 8, 8)
        panelTabs:SetTall(250)
        panelTabs.Paint = nil

        local tabs = Mantle.ui.panel_tabs(panelTabs)

        local tab1 = vgui.Create('Panel')
        tab1.Paint = function(_, w, h)
            draw.SimpleText(string.format(L('legacy_tab'), 1), 'Fated.20', w / 2, h / 2, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end
        tabs:AddTab(string.format(L('legacy_tab'), 1), tab1, 'icon16/page_white.png')

        local tab2 = vgui.Create('Panel')
        tab2.Paint = function(_, w, h)
            draw.SimpleText(string.format(L('legacy_tab'), 2), 'Fated.20', w / 2, h / 2, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end
        tabs:AddTab(string.format(L('legacy_tab'), 2), tab2, 'icon16/page_white_edit.png', Color(100, 200, 100))

        local tab3 = vgui.Create('Panel')
        tab3.Paint = function(_, w, h)
            draw.SimpleText(string.format(L('legacy_tab'), 3), 'Fated.20', w / 2, h / 2, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end
        tabs:AddTab(string.format(L('legacy_tab'), 3), tab3, 'icon16/page_white_gear.png', nil, Color(200, 100, 100))

        tabs:ActiveTab(string.format(L('legacy_tab'), 1))
    end

    return panel
end

Mantle.menu.registerTab('legacy', {
    order = 4,
    title = L('tab_legacy'),
    description = L('tab_legacy_desc'),
    icon = Material('icon16/exclamation.png'),
    build = buildPanel
})
