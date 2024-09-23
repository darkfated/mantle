Mantle.ui = {}

local color_white = Color(255, 255, 255)
local color_gray = Color(200, 200, 200)
local color_red = Color(255, 50, 50)
local mat_close = Material('mantle/close_btn.png')

function Mantle.ui.frame(s, title, width, height, close_bool, anim_bool)
    s:SetSize(width, height)
    s:SetTitle('')
    s:ShowCloseButton(false)
    s:DockPadding(6, 30, 6, 6)
    s.f_title = title
    s.center_title = ''
    s.background_alpha = true
    s.Paint = function(self, w, h)
        local x, y = self:LocalToScreen()

        BSHADOWS.BeginShadow()
            draw.RoundedBoxEx(6, x, y, w, 24, Mantle.color.header, true, true)
            draw.RoundedBoxEx(6, x, y + 24, w, h - 24, s.background_alpha and Mantle.color.background_alpha or Mantle.color.background, false, false, true, true)
            draw.SimpleText(self.f_title, 'Fated.16', x + 6, y + 4, color_white)
            
            if self.center_title then
                draw.SimpleText(s.center_title, 'Fated.20b', x + w * 0.5, y + 11, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            end
        BSHADOWS.EndShadow(1, 2, 2, 255, 0, 0)
    end

    if anim_bool then
        Mantle.func.animate_appearance(s, width, height, 0.1, 0.2)
    end

    if close_bool then
        s.cls = vgui.Create('DButton', s)
        s.cls:SetSize(20, 20)
        s.cls:SetPos(width - 22, 2)
        s.cls:SetText('')
        s.cls.Paint = function(_, w, h)
            surface.SetDrawColor(color_white)
            surface.SetMaterial(mat_close)
            surface.DrawTexturedRect(0, 0, w, h)
        end
        s.cls.DoClick = function()
            s:AlphaTo(0, 0.1, 0, function()
                s:Remove()
            end)
        end
        s.cls.DoRightClick = function()
            local DM = Mantle.ui.derma_menu()
            DM:AddOption('Закрыть окно', function()
                s:Remove()
            end, 'icon16/cross.png')
        end
    end
end

function Mantle.ui.sp(s)
    local vbar = s:GetVBar()
    vbar:SetWide(12)
    vbar:SetHideButtons(true)
    vbar.Paint = nil
    vbar.btnGrip.Paint = function(self, w, h)
        if self.Depressed then
            self:SetCursor('sizens')
        end

        draw.RoundedBox(6, 6, 0, w - 6, h, Mantle.color.theme)
    end
end

function Mantle.ui.btn(s, icon, icon_size, btn_color, btn_radius, off_grad_bool, btn_color_hov, off_hov_bool)
    s:SetTall(32)
    s.hoverStatus = 0
    s.btn_font = 'Fated.18'
    s.Paint = function(self, w, h)
        if !self.btn_text then
            self.btn_text = self:GetText()
            self:SetText('')
        end
        
        if self:IsHovered() then
            self.hoverStatus = math.Clamp(self.hoverStatus + 4 * FrameTime(), 0, 255)
        else
            self.hoverStatus = math.Clamp(self.hoverStatus - 8 * FrameTime(), 0, 255)
        end

        draw.RoundedBox(btn_radius and btn_radius or 6, 0, 0, w, h, btn_color and btn_color or Mantle.color.button)

        if !off_hov_bool then
            local color_hover = btn_color_hov and btn_color_hov or Mantle.color.button_hovered 
            color_hover = Color(color_hover.r, color_hover.g, color_hover.b, 255 * self.hoverStatus)

            draw.RoundedBox(btn_radius and btn_radius or 6, 0, 0, w, h, color_hover)
        end

        if !off_grad_bool then
            Mantle.func.gradient(0, 0, w, h, 1, Mantle.color.button_shadow)
        end

        draw.SimpleText(self.btn_text, self.btn_font, w * 0.5 + (icon and icon_size * 0.5 - 2 or 0), h * 0.5 - 1, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

        if icon then
            surface.SetDrawColor(color_white)
            surface.SetMaterial(icon)

            local indent = (h - icon_size) * 0.5
            surface.DrawTexturedRect(indent, indent, icon_size, icon_size)
        end
    end
end

function Mantle.ui.slidebox(parent, label, min, max, convar_name, decimals)
    local val = GetConVar(convar_name):GetFloat() or 0
    
    local slider = vgui.Create('DNumSlider', parent)
    slider:Dock(TOP)
    slider:DockMargin(0, 6, 0, 0)
    slider:SetMinMax(min, max)
    slider:SetValue(val)
    slider.decimals = decimals or 0
    slider.Label:SetWide(0)
    slider.TextArea:SetWide(0)

    local command = convar_name .. ' '
    slider.OnValueChanged = function(s, val)
        local value = math.Round(val, decimals)

        s:SetValue(value)
        LocalPlayer():ConCommand(command .. math.Round(value, 0))
    end

    slider.Slider.Paint = nil
    slider.PerformLayout = nil
    slider.Paint = function(self, w, h)
        draw.RoundedBox(4, 0, h - 10, w, 6, Mantle.color.panel_alpha[1])

        draw.SimpleText(label, 'Fated.18', 0, -4, color_white)
        draw.SimpleText(self:GetValue(), 'Fated.18', w, -4, color_white, TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP)
    end
    slider.Slider.Knob.Paint = function(self, w, h)
        draw.RoundedBox(16, 0, 8, 16, 16, Mantle.color.theme)
    end

    return slider
end

function Mantle.ui.desc_entry(parent, title, placeholder, bool_title_off)
    if !bool_title_off then
        local label = vgui.Create('DLabel', parent)
        label:Dock(TOP)
        label:DockMargin(4, 0, 4, 0)
        label:SetText(title)
        label:SetFont('Fated.16')
    end
    
    local entry_background = vgui.Create('DPanel', parent)
    entry_background:Dock(TOP)
    entry_background:DockMargin(4, 4, 4, 0)
    entry_background:SetTall(24)
    
    local entry = vgui.Create('DTextEntry', entry_background)
    entry:Dock(FILL)
    entry:DockMargin(2, 4, 2, 4)
    entry:SetPlaceholderText(placeholder)
    entry:SetFont('Fated.16')
    entry:SetDrawLanguageID(false)
    entry:SetPaintBackground(false)

    return entry, entry_background
end

function Mantle.ui.checkbox(parent, text, convar)
    local panel = vgui.Create('DPanel', parent)
    panel:Dock(TOP)
    panel:DockMargin(4, 0, 4, 0)
    panel:SetTall(28)
    panel.Paint = function(_, w, h)
        draw.RoundedBox(6, 0, 0, w, h, Mantle.color.panel_alpha[2])
        draw.SimpleText(text, 'Fated.18', 8, h * 0.5 - 1, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
    end

    local option = vgui.Create('DButton', panel)
    option:Dock(RIGHT)
    option:SetWide(56)
    option:SetText('')
    option.enabled = convar and GetConVar(convar):GetBool() or false
    option.Paint = function(self, w, h)
        draw.RoundedBoxEx(6, 0, 0, w, h, Mantle.color.panel_alpha[1], false, true, false, true)
        draw.SimpleText(self.enabled and 'ВКЛ' or 'ВЫКЛ', 'Fated.19', w * 0.5 - 1, h * 0.5 - 1, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
    option.DoClick = function()
        if convar then
            RunConsoleCommand(convar, option.enabled and 0 or 1)
        end

        option.enabled = !option.enabled
    end

    return panel, option
end

function Mantle.ui.panel_tabs(parent)
    local panel_tabs = vgui.Create('DPanel', parent)
    panel_tabs:Dock(FILL)
    panel_tabs.Paint = nil
    panel_tabs.content = {}
    panel_tabs.active_tab = ''

    panel_tabs.sp = vgui.Create('DHorizontalScroller', panel_tabs)
    panel_tabs.sp:Dock(TOP)
    panel_tabs.sp:DockMargin(0, 0, 0, 6)
    panel_tabs.sp:SetTall(24)
    panel_tabs.sp:SetOverlap(-6)

    panel_tabs.panel_content = vgui.Create('DPanel', panel_tabs)
    panel_tabs.panel_content:Dock(FILL)
    panel_tabs.panel_content.Paint = function(_, w, h)
        if panel_tabs.active_tab == '' then
            draw.SimpleText('Выберете вкладку', 'Fated.16', w * 0.5, h * 0.5 - panel_tabs.sp:GetTall() - 7, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end
    end

    function panel_tabs:AddTab(title, panel, icon, col, col_hov)
        panel_tabs.content[title] = panel
        panel_tabs.content[title]:SetParent(panel_tabs.panel_content)
        panel_tabs.content[title]:Dock(FILL)
        panel_tabs.content[title]:SetVisible(false)

        local btn_tab = vgui.Create('DButton', panel_tabs.sp)
        surface.SetFont('Fated.20')
        btn_tab:SetSize(surface.GetTextSize(title) + 10 + (icon and 18 or 0), 20)
        btn_tab:SetText('')

        if icon then
            btn_tab.icon = Material(icon)
            panel_tabs.content[title].icon = icon
        end

        btn_tab.Paint = function(self, w, h)
            draw.RoundedBox(6, 0, 0, w, h, panel_tabs.active_tab == title and (col_hov and col_hov or Mantle.color.panel[2]) or (col and col or Mantle.color.theme))

            if self:IsHovered() then
                draw.RoundedBox(6, 0, 0, w, h, Mantle.color.button_shadow)
            end

            draw.SimpleText(title, 'Fated.20', w * 0.5 + (self.icon and 9 or 0), 11, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

            if self.icon then
                surface.SetDrawColor(color_white)
                surface.SetMaterial(self.icon)
                surface.DrawTexturedRect(4, 4, 16, 16)
            end
        end
        btn_tab.DoClick = function()
            panel_tabs:ActiveTab(title)
        end
        btn_tab.DoRightClick = function()
            local DM = Mantle.ui.derma_menu()

            for tab_name, tab in pairs(panel_tabs.content) do
                DM:AddOption(tab_name, function()
                    panel_tabs:ActiveTab(tab_name)
                end, tab.icon)
            end
        end

        panel_tabs.sp:AddPanel(btn_tab)
    end

    function panel_tabs:ActiveTab(title)
        if title == panel_tabs.active_tab then
            return
        end

        for tab_title, tab in pairs(panel_tabs.content) do
            if tab_title != title then
                tab:SetVisible(false)
            else
                tab:SetVisible(true)

                panel_tabs.active_tab = title
            end
        end
    end

    return panel_tabs
end

function Mantle.ui.player_selector(doclick, func_check)
    if IsValid(Mantle.ui.menu_player_selector) then
        Mantle.ui.menu_player_selector:Remove()
    end

    Mantle.ui.menu_player_selector = vgui.Create('DFrame')
    Mantle.ui.frame(Mantle.ui.menu_player_selector, '', 250, 400, false, true)
    Mantle.ui.menu_player_selector:Center()
    Mantle.ui.menu_player_selector:MakePopup()
    Mantle.ui.menu_player_selector.background_alpha = false
    Mantle.ui.menu_player_selector.center_title = 'Выбор игрока'

    Mantle.ui.menu_player_selector.sp = vgui.Create('DScrollPanel', Mantle.ui.menu_player_selector)
    Mantle.ui.sp(Mantle.ui.menu_player_selector.sp)
    Mantle.ui.menu_player_selector.sp:Dock(FILL)

    for i, pl in pairs(player.GetAll()) do
        if isfunction(func_check) and func_check(pl) then
            continue
        end

        local panel_ply = vgui.Create('DButton', Mantle.ui.menu_player_selector.sp)
        panel_ply:Dock(TOP)
        panel_ply:DockMargin(0, 0, 0, 6)
        panel_ply:SetTall(28)
        panel_ply:SetText('')
        panel_ply.Paint = function(self, w, h)
            draw.RoundedBox(6, 0, 0, w, h, Mantle.color.panel[1])
            Mantle.func.gradient(0, 0, w, h, 1, Mantle.color.button_shadow)

            if IsValid(pl) then
                draw.SimpleText(pl:Name(), 'Fated.18', w * 0.5, h * 0.5, self:IsHovered() and color_gray or color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            else
                draw.SimpleText('Вышел', 'Fated.18', w * 0.5, h * 0.5, color_red, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            end
        end
        panel_ply.DoClick = function()
            if IsValid(pl) then
                Mantle.func.sound()
                
                doclick(pl)
            end

            Mantle.ui.menu_player_selector:Remove()
        end

        panel_ply.avatar = vgui.Create('AvatarImage', panel_ply)
        panel_ply.avatar:SetSize(20, 20)
        panel_ply.avatar:SetPos(4, 4)
        panel_ply.avatar:SetPlayer(pl, 24)
    end

    Mantle.ui.menu_player_selector.btn_close = vgui.Create('DButton', Mantle.ui.menu_player_selector)
    Mantle.ui.btn(Mantle.ui.menu_player_selector.btn_close, nil, nil, nil, nil, nil, Color(210, 65, 65))
    Mantle.ui.menu_player_selector.btn_close:Dock(BOTTOM)
    Mantle.ui.menu_player_selector.btn_close:DockMargin(0, 6, 0, 0)
    Mantle.ui.menu_player_selector.btn_close:SetText('Закрыть')
    Mantle.ui.menu_player_selector.btn_close.DoClick = function()
        Mantle.ui.menu_player_selector:AlphaTo(0, 0.1, 0, function()
            Mantle.ui.menu_player_selector:Remove()
        end)
    end
end

function Mantle.ui.color_picker(func, color_standart)
    if IsValid(Mantle.ui.menu_color_picker) then
        Mantle.ui.menu_color_picker:Remove()
    end

    Mantle.ui.menu_color_picker = vgui.Create('DFrame')
    Mantle.ui.frame(Mantle.ui.menu_color_picker, '', 250, 400, false)
    Mantle.ui.menu_color_picker:Center()
    Mantle.ui.menu_color_picker:MakePopup()
    Mantle.ui.menu_color_picker.background_alpha = false
    Mantle.ui.menu_color_picker.center_title = 'Выбор цвета'

    Mantle.ui.menu_color_picker.picker = vgui.Create('DColorMixer', Mantle.ui.menu_color_picker)
    Mantle.ui.menu_color_picker.picker:Dock(FILL)
    Mantle.ui.menu_color_picker.picker:SetAlphaBar(false)

    if color_standart then
        Mantle.ui.menu_color_picker.picker:SetColor(color_standart)
    end

    Mantle.ui.menu_color_picker.btn_close = vgui.Create('DButton', Mantle.ui.menu_color_picker)
    Mantle.ui.btn(Mantle.ui.menu_color_picker.btn_close, nil, nil, Color(210, 65, 65), nil, nil, nil, true)
    Mantle.ui.menu_color_picker.btn_close:Dock(BOTTOM)
    Mantle.ui.menu_color_picker.btn_close:DockMargin(0, 6, 0, 0)
    Mantle.ui.menu_color_picker.btn_close:SetTall(28)
    Mantle.ui.menu_color_picker.btn_close:SetText('Закрыть')
    Mantle.ui.menu_color_picker.btn_close.DoClick = function()
        Mantle.ui.menu_color_picker:Remove()
    end

    Mantle.ui.menu_color_picker.btn_select = vgui.Create('DButton', Mantle.ui.menu_color_picker)
    Mantle.ui.btn(Mantle.ui.menu_color_picker.btn_select)
    Mantle.ui.menu_color_picker.btn_select:Dock(BOTTOM)
    Mantle.ui.menu_color_picker.btn_select:DockMargin(0, 6, 0, 0)
    Mantle.ui.menu_color_picker.btn_select:SetTall(28)
    Mantle.ui.menu_color_picker.btn_select:SetText('Выбрать')
    Mantle.ui.menu_color_picker.btn_select.DoClick = function()
        Mantle.func.sound()

        local col = Mantle.ui.menu_color_picker.picker:GetColor()

        func(Color(col.r, col.g, col.b))

        Mantle.ui.menu_color_picker:Remove()
    end
end

local function ClampPanelPosition(panel)
    local x, y = panel:GetPos()
    local w, h = panel:GetSize()
    local screenWidth, screenHeight = ScrW(), ScrH()

    if x < 0 then
        x = 0
    elseif x + w > screenWidth then
        x = screenWidth - w
    end

    if y < 0 then
        y = 0
    elseif y + h > screenHeight then
        y = screenHeight - h
    end

    panel:SetPos(x, y)
end

function Mantle.ui.derma_menu()
    while IsValid(Mantle.ui.menu_derma_menu) do
        Mantle.ui.menu_derma_menu:Remove()
    end

    local mouse_pos_x, mouse_pos_y = input.GetCursorPos()

    Mantle.ui.menu_derma_menu = vgui.Create('DPanel')
    Mantle.ui.menu_derma_menu:SetSize(200, 100)
    Mantle.ui.menu_derma_menu:SetPos(mouse_pos_x - Mantle.ui.menu_derma_menu:GetWide() * 0.5, mouse_pos_y)
    Mantle.ui.menu_derma_menu:MakePopup()
    Mantle.ui.menu_derma_menu:SetIsMenu(true)
    Mantle.ui.menu_derma_menu:SetKeyBoardInputEnabled(false)
    Mantle.ui.menu_derma_menu.Paint = function(self, w, h)
        local x, y = self:LocalToScreen()

        BSHADOWS.BeginShadow()
            draw.RoundedBox(6, x, y, w, h, Mantle.color.background)
        BSHADOWS.EndShadow(1, 2, 2, 255, 0, 0)
    end
    Mantle.ui.menu_derma_menu.tall = 6
    Mantle.ui.menu_derma_menu.max_width = 0

    Mantle.ui.menu_derma_menu.sp = vgui.Create('DScrollPanel', Mantle.ui.menu_derma_menu)
    Mantle.ui.sp(Mantle.ui.menu_derma_menu.sp)
    Mantle.ui.menu_derma_menu.sp:Dock(FILL)
    Mantle.ui.menu_derma_menu.sp:DockMargin(2, 4, 2, 2)

    RegisterDermaMenuForClose(Mantle.ui.menu_derma_menu)

    function Mantle.ui.menu_derma_menu:AddOption(name, func, icon)
        local option = vgui.Create('DButton', Mantle.ui.menu_derma_menu.sp)
        Mantle.ui.btn(option)
        option:Dock(TOP)
        option:DockMargin(2, Mantle.ui.menu_derma_menu.tall == 0 and 2 or 0, 2, 2)
        option:SetTall(20)
        option:SetText(name)
        option.DoClick = function()
            Mantle.func.sound()

            func()

            Mantle.ui.menu_derma_menu:Remove()
        end

        surface.SetFont('Fated.18')

        Mantle.ui.menu_derma_menu.max_width = math.max(Mantle.ui.menu_derma_menu.max_width, surface.GetTextSize(name))

        if icon then
            option.icon = vgui.Create('DPanel', option)
            option.icon:SetSize(16, 16)
            option.icon:SetPos(2, 2)

            local mat_icon = Material(icon)

            option.icon.Paint = function(_, w, h)
                surface.SetDrawColor(color_white)
                surface.SetMaterial(mat_icon)
                surface.DrawTexturedRect(0, 0, w, h)
            end
        end

        Mantle.ui.menu_derma_menu.tall = Mantle.ui.menu_derma_menu.tall + 22 + (Mantle.ui.menu_derma_menu.tall == 0 and 2 or 0)
        Mantle.ui.menu_derma_menu:SetTall(math.Clamp(Mantle.ui.menu_derma_menu.tall, 0, ScrH() * 0.5))
        Mantle.ui.menu_derma_menu:SetWide(Mantle.ui.menu_derma_menu.max_width + 72)

        ClampPanelPosition(Mantle.ui.menu_derma_menu)
    end

    function Mantle.ui.menu_derma_menu:AddSpacer()
        local pan_spacer = vgui.Create('DPanel', Mantle.ui.menu_derma_menu.sp)
        pan_spacer:Dock(TOP)
        pan_spacer:DockMargin(0, 2, 0, 4)
        pan_spacer:SetTall(4)
        pan_spacer.Paint = function(_, w, h)
            draw.RoundedBox(2, 6, 0, w - 12, h, Mantle.color.panel[2])
        end

        Mantle.ui.menu_derma_menu.tall = Mantle.ui.menu_derma_menu.tall + 10
        Mantle.ui.menu_derma_menu:SetTall(Mantle.ui.menu_derma_menu.tall)
    end

    function Mantle.ui.menu_derma_menu:GetDeleteSelf()
        return true
    end

    return Mantle.ui.menu_derma_menu
end

function Mantle.ui.text_box(title, desc, func)
    Mantle.ui.menu_text_box = vgui.Create('DFrame')
    Mantle.ui.frame(Mantle.ui.menu_text_box, title, 300, 120, true, true)
    Mantle.ui.menu_text_box:Center()
    Mantle.ui.menu_text_box:MakePopup()
    Mantle.ui.menu_text_box.background_alpha = false

    local entry = Mantle.ui.desc_entry(Mantle.ui.menu_text_box, desc)

    local function apply_func()
        func(entry:GetText())

        Mantle.ui.menu_text_box:Remove()
    end

    entry.OnEnter = function()
        apply_func()
    end

    local btn_accept = vgui.Create('DButton', Mantle.ui.menu_text_box)
    Mantle.ui.btn(btn_accept, nil, nil, Color(44, 124, 62), nil, nil, Color(35, 103, 51))
    btn_accept:Dock(FILL)
    btn_accept:DockMargin(0, 8, 0, 0)
    btn_accept:SetText('Применить')
    btn_accept.DoClick = function()
        Mantle.func.sound()

        apply_func()
    end
end

local function DrawArc(cx, cy, radius, thickness, startAngle, endAngle, color)
    local arc = {}
    local innerRadius = radius - thickness

    for i = startAngle, endAngle, 1 do
        local rad = math.rad(i)
        table.insert(arc, {
            x = cx + math.cos(rad) * radius,
            y = cy + math.sin(rad) * radius,
        })
    end

    for i = endAngle, startAngle, -1 do
        local rad = math.rad(i)
        table.insert(arc, {
            x = cx + math.cos(rad) * innerRadius,
            y = cy + math.sin(rad) * innerRadius,
        })
    end

    surface.SetDrawColor(color)
    draw.NoTexture()
    surface.DrawPoly(arc)
end

local segmentColors = {}

function Mantle.ui.ratial_panel(items_config, disable_start_anim_bool, disable_background_bool)
    if IsValid(Mantle.ui.menu_ratial_panel) then
        Mantle.ui.menu_ratial_panel:Remove()
    end

    Mantle.ui.menu_ratial_panel = vgui.Create('DPanel')
    Mantle.ui.menu_ratial_panel:SetSize(ScrW(), ScrH())
    Mantle.ui.menu_ratial_panel:Center()
    Mantle.ui.menu_ratial_panel:MakePopup()
    
    if !disable_start_anim_bool then
        Mantle.ui.menu_ratial_panel:SetAlpha(0)
        Mantle.ui.menu_ratial_panel:AlphaTo(255, 0.1, 0)
    end

    for i = 1, #items_config do
        segmentColors[i] = Mantle.color.header
    end

    local centerX, centerY = ScrW() / 2, ScrH() / 2
    local radius = 200
    local thickness = 90
    local selectedSegment = nil
    local hoveredText = nil

    Mantle.ui.menu_ratial_panel.Paint = function(_, w, h)
        if !disable_background_bool then
            draw.RoundedBox(0, 0, 0, w, h, Mantle.color.background_alpha)
        end

        local angleStep = 360 / #items_config

        for i, btnConfig in ipairs(items_config) do
            local startAngle = (i - 1) * angleStep
            local endAngle = i * angleStep
            local isHovered = (selectedSegment == i)
            local targetColor = isHovered and Mantle.color.theme or Mantle.color.header
            local currentColor = segmentColors[i]
            
            segmentColors[i] = Color(
                Lerp(FrameTime() * 10, currentColor.r, targetColor.r),
                Lerp(FrameTime() * 10, currentColor.g, targetColor.g),
                Lerp(FrameTime() * 10, currentColor.b, targetColor.b),
                Lerp(FrameTime() * 10, currentColor.a, targetColor.a)
            )

            DrawArc(centerX, centerY, radius, thickness, startAngle, endAngle, segmentColors[i])

            local midAngle = math.rad((startAngle + endAngle) / 2)
            local buttonX = centerX + math.cos(midAngle) * (radius - thickness / 1.9)
            local buttonY = centerY + math.sin(midAngle) * (radius - thickness / 1.9)

            draw.SimpleText(btnConfig.name, 'Fated.20', buttonX, buttonY, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

            if isHovered then
                hoveredText = btnConfig.name
            end
        end

        if hoveredText then
            draw.SimpleText(hoveredText, 'Fated.22', centerX + 1, centerY + 1, color_black, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            draw.SimpleText(hoveredText, 'Fated.22', centerX, centerY, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end
    end

    function Mantle.ui.menu_ratial_panel:Think()
        local mouseX, mouseY = Mantle.ui.menu_ratial_panel:CursorPos()
        local dx, dy = mouseX - centerX, mouseY - centerY
        local angle = math.deg(math.atan2(dy, dx))

        if angle < 0 then
            angle = angle + 360
        end

        local newSegment = math.floor(angle / (360 / #items_config)) + 1

        if newSegment != selectedSegment then
            Mantle.func.sound('mantle/ratio_btn.ogg')
        end

        selectedSegment = newSegment
    end

    local function ClosePanel(end_anim_off_bool)
        if !end_anim_off_bool then
            Mantle.ui.menu_ratial_panel:AlphaTo(0, 0.07, 0.1, function(_, self)
                self:Remove()
            end)
        else
            Mantle.ui.menu_ratial_panel:Remove()
        end
    end

    function Mantle.ui.menu_ratial_panel:OnMousePressed(mousecode)
        local mouseX, mouseY = Mantle.ui.menu_ratial_panel:CursorPos()
        local dx, dy = mouseX - centerX, mouseY - centerY
        local distance = math.sqrt(dx * dx + dy * dy)

        if mousecode == MOUSE_LEFT then
            if distance <= radius and selectedSegment then
                local btnConfig = items_config[selectedSegment]

                if btnConfig and btnConfig.func then
                    btnConfig.func()
                end
                
                ClosePanel(btnConfig.off_anim)
            elseif distance > radius then
                ClosePanel()
            end
        elseif mousecode == MOUSE_RIGHT then
            ClosePanel()
        end
    end

    return Mantle.ui.menu_ratial_panel
end
