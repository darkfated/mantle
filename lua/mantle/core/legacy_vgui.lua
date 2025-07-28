--[[
    Старые функции отрисовки ui-элементов
]]--

local color_gray = Color(200, 200, 200)
local color_red = Color(255, 50, 50)
local mat_close = Material('mantle/close_btn_l.png')

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

        BShadows.BeginShadow()
            draw.RoundedBoxEx(6, x, y, w, 24, Mantle.color.header, true, true)
            draw.RoundedBoxEx(6, x, y + 24, w, h - 24, s.background_alpha and Mantle.color.background_alpha or Mantle.color.background, false, false, true, true)
            draw.SimpleText(self.f_title, 'Fated.16', x + 6, y + 4, Mantle.color.text)
            
            if self.center_title then
                draw.SimpleText(s.center_title, 'Fated.20b', x + w * 0.5, y + 11, Mantle.color.text, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            end
        BShadows.EndShadow(1, 2, 2, 255, 0, 0)
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

        draw.SimpleText(self.btn_text, self.btn_font, w * 0.5 + (icon and icon_size * 0.5 - 2 or 0), h * 0.5 - 1, Mantle.color.text, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

        if icon then
            surface.SetDrawColor(color_white)
            surface.SetMaterial(icon)

            local indent = (h - icon_size) * 0.5
            surface.DrawTexturedRect(indent, indent, icon_size, icon_size)
        end
    end
end

function Mantle.ui.slidebox(parent, label, min_value, max_value, slide_convar, decimals)
    local slider = vgui.Create('DButton', parent)
    slider:Dock(TOP)
    slider:DockMargin(0, 6, 0, 0)
    slider:SetTall(40)
    slider:SetText('')

    local value = GetConVar(slide_convar):GetFloat()
    local sections = max_value - min_value
    local smoothPos = 0
    local targetPos = 0

    local function UpdateSliderPosition(new_value)
        local progress = (new_value - min_value) / sections
        targetPos = (slider:GetWide() - 16) * progress
        LocalPlayer():ConCommand(slide_convar .. ' ' .. new_value)
        value = new_value
    end

    UpdateSliderPosition(value)

    slider.Paint = function(self, w, h)
        draw.RoundedBox(4, 0, h - 16, w, 6, Mantle.color.panel_alpha[1])

        smoothPos = Lerp(FrameTime() * 10, smoothPos, targetPos)
        
        draw.RoundedBox(16, smoothPos, 18, 16, 16, Mantle.color.theme)

        draw.SimpleText(label, 'Fated.18', 4, 0, Mantle.color.text)
        draw.SimpleText(math.Round(value, decimals), 'Fated.18', w - 4, 0, Mantle.color.text, TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP)
    end

    local function UpdateSliderByCursorPos(x)
        local progress = math.Clamp(x / (slider:GetWide() - 16), 0, 1)
        local new_value = math.Round(min_value + (progress * sections), decimals)
        UpdateSliderPosition(new_value)
    end

    slider.OnMousePressed = function(_, mcode)
        if mcode == MOUSE_LEFT then
            UpdateSliderByCursorPos(slider:CursorPos())
            slider:MouseCapture(true)
        end
    end

    slider.OnMouseReleased = function(_, mcode)
        if mcode == MOUSE_LEFT then
            slider:MouseCapture(false)
        end
    end

    slider.OnCursorMoved = function(_, x, _)
        if input.IsMouseDown(MOUSE_LEFT) then
            UpdateSliderByCursorPos(x)
        end
    end

    return slider
end

function Mantle.ui.desc_entry(parent, title, placeholder, bool_title_off)
    if !bool_title_off and title then
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
        draw.SimpleText(text, 'Fated.18', 8, h * 0.5 - 1, Mantle.color.text, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
    end

    local option = vgui.Create('DButton', panel)
    option:Dock(RIGHT)
    option:SetWide(56)
    option:SetText('')
    option.enabled = convar and GetConVar(convar):GetBool() or false
    option.Paint = function(self, w, h)
        draw.RoundedBoxEx(6, 0, 0, w, h, Mantle.color.panel_alpha[1], false, true, false, true)
        draw.SimpleText(self.enabled and 'ВКЛ' or 'ВЫКЛ', 'Fated.19', w * 0.5 - 1, h * 0.5 - 1, Mantle.color.text, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
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
            draw.SimpleText('Выберете вкладку', 'Fated.16', w * 0.5, h * 0.5 - panel_tabs.sp:GetTall() - 7, Mantle.color.text, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
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

            draw.SimpleText(title, 'Fated.20', w * 0.5 + (self.icon and 9 or 0), 11, Mantle.color.text, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

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
