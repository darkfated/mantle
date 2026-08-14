local mat_close = Material('mantle/close_btn.png')

function Mantle.ui.frame(s, title, width, height, close_bool, anim_bool)
    s:SetSize(width, height)
    s:SetTitle('')
    s:ShowCloseButton(false)
    s:DockPadding(6, 30, 6, 6)
    s.f_title = title
    s.center_title = ''
    s.background_alpha = false
    s.Paint = function(self, w, h)
        local x, y = self:LocalToScreen()

        BShadows.BeginShadow()
            RNDX.Rect(x, y, w, 24)
                :Radii(6, 6, 0, 0)
                :Color(Mantle.color.header)
                :Shape(RNDX.SHAPE_FIGMA)
            :Draw()
            RNDX.Rect(x, y + 24, w, h - 24)
                :Radii(0, 0, 6, 6)
                :Color(s.background_alpha and Mantle.color.background_alpha or Mantle.color.background)
                :Shape(RNDX.SHAPE_FIGMA)
            :Draw()
            draw.SimpleText(self.f_title, 'Fated.16', x + 6, y + 4, Mantle.color.text)

            if self.center_title then
                draw.SimpleText(s.center_title, 'Fated.20b', x + w * 0.5, y + 11, Mantle.color.text, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            end
        BShadows.EndShadow(1, 2, 2, 255, 0, 0)
    end

    if anim_bool then
        s:SetVisible(false)
        timer.Simple(0, function()
            s:SetVisible(true)
            Mantle.func.animate_appearance(s, width, height, 0.1, 0.2)
        end)
    end

    if close_bool then
        s.cls = vgui.Create('Button', s)
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

        RNDX.Rect(6, 0, w - 6, h)
            :Rad(6)
            :Color(Mantle.color.theme)
            :Shape(RNDX.SHAPE_FIGMA)
        :Draw()
    end
end

function Mantle.ui.btn(s, icon, icon_size, col, rad, off_grad_bool, hov_color, off_hov_bool)
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

        RNDX.Rect(0, 0, w, h)
            :Rad(rad or 6)
            :Color(col or Mantle.color.button)
            :Shape(RNDX.SHAPE_FIGMA)
        :Draw()

        if !off_hov_bool then
            local color_hover = hov_color or Mantle.color.button_hovered
            color_hover = Color(color_hover.r, color_hover.g, color_hover.b, 255 * self.hoverStatus)

            RNDX.Rect(0, 0, w, h)
                :Rad(rad or 6)
                :Color(color_hover)
                :Shape(RNDX.SHAPE_FIGMA)
            :Draw()
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

function Mantle.ui.slidebox(parent, label, min_value, max_value, convar, decimals)
    local slider = vgui.Create('Button', parent)
    slider:Dock(TOP)
    slider:DockMargin(0, 6, 0, 0)
    slider:SetTall(40)
    slider:SetText('')
    slider:SetCursor('hand')

    slider.min_value = min_value
    slider.max_value = max_value
    slider.decimals = decimals or 0
    slider.convar = convar

    slider.smoothProgress = 0
    slider.dragging = false

    local TRACK_INSET = 8
    local BAR_H = 6
    local HANDLE_R = 8

    local function formatValue(val)
        if slider.decimals > 0 then
            return string.format('%.' .. slider.decimals .. 'f', val)
        end
        return tostring(math.Round(val))
    end

    local function clampValue(val)
        if slider.decimals > 0 then
            val = tonumber(string.format('%.' .. slider.decimals .. 'f', val)) or val
        else
            val = math.Round(val)
        end
        return math.Clamp(val, slider.min_value, slider.max_value)
    end

    slider.value = clampValue(convar and GetConVar(convar):GetFloat() or slider.min_value)

    local function setValue(val)
        val = clampValue(val)
        if slider.value == val then return end

        slider.value = val

        if slider.convar then
            LocalPlayer():ConCommand(slider.convar .. ' ' .. tostring(val))
        end
    end

    local sync_name = 'mantle_slide_sync_' .. tostring(slider)
    timer.Create(sync_name, 0.1, 0, function()
        if not IsValid(slider) or not slider.convar then return end

        local cvar = GetConVar(slider.convar)
        if not cvar then return end

        local val = clampValue(cvar:GetFloat())
        if slider.value != val then
            slider.value = val
        end
    end)

    slider.OnRemove = function()
        timer.Remove(sync_name)
    end

    local function getTrackBounds(w)
        return TRACK_INSET, math.max(0, w - TRACK_INSET * 2)
    end

    local function getProgress()
        local denom = slider.max_value - slider.min_value
        if denom <= 0 then return 0 end

        return math.Clamp((slider.value - slider.min_value) / denom, 0, 1)
    end

    slider.Paint = function(self, w, h)
        local start, barW = getTrackBounds(w)
        local barY = h - 10

        self.smoothProgress = Mantle.func.approachExp(self.smoothProgress, barW * getProgress(), 14, FrameTime())

        RNDX.Rect(start, barY - BAR_H * 0.5, barW, BAR_H)
            :Rad(BAR_H * 0.5)
            :Color(Mantle.color.panel_alpha[1])
            :Shape(RNDX.SHAPE_FIGMA)
        :Draw()

        RNDX.Circle(start + self.smoothProgress, barY, HANDLE_R)
            :Color(Mantle.color.theme)
        :Draw()

        draw.SimpleText(label, 'Fated.18', 4, 0, Mantle.color.text)
        draw.SimpleText(formatValue(slider.value), 'Fated.18', w - 4, 0, Mantle.color.text, TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP)
    end

    slider.UpdateFromCursor = function(_, x)
        local start, barW = getTrackBounds(slider:GetWide())
        if barW <= 0 then return end

        local progress = math.Clamp((x - start) / barW, 0, 1)
        setValue(slider.min_value + progress * (slider.max_value - slider.min_value))
    end

    slider.OnMousePressed = function(_, mcode)
        if mcode != MOUSE_LEFT then return end

        slider:UpdateFromCursor(slider:CursorPos())
        slider.dragging = true
        slider:MouseCapture(true)
    end

    slider.OnMouseReleased = function(_, mcode)
        if mcode != MOUSE_LEFT then return end

        slider.dragging = false
        slider:MouseCapture(false)
    end

    slider.OnCursorMoved = function(_, x, _)
        if slider.dragging then
            slider:UpdateFromCursor(x)
        end
    end

    return slider
end

function Mantle.ui.desc_entry(parent, title, placeholder, off_title_bool)
    if !off_title_bool and title then
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
    panel:SetCursor('hand')
    panel.Paint = function(_, w, h)
        RNDX.Rect(0, 0, w, h)
            :Rad(6)
            :Color(Mantle.color.panel_alpha[2])
            :Shape(RNDX.SHAPE_FIGMA)
        :Draw()
        draw.SimpleText(text, 'Fated.18', 8, h * 0.5 - 1, Mantle.color.text, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
    end

    local option = vgui.Create('Button', panel)
    option:Dock(RIGHT)
    option:SetWide(56)
    option:SetText('')
    option:SetCursor('hand')
    option.enabled = convar and GetConVar(convar) and GetConVar(convar):GetBool() or false
    option.Paint = function(self, w, h)
        RNDX.Rect(0, 0, w, h)
            :Radii(0, 6, 0, 6)
            :Color(Mantle.color.panel_alpha[1])
            :Shape(RNDX.SHAPE_FIGMA)
        :Draw()
        draw.SimpleText(self.enabled and 'ВКЛ' or 'ВЫКЛ', 'Fated.19', w * 0.5 - 1, h * 0.5 - 1, Mantle.color.text, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end

    local function toggle()
        if convar then
            LocalPlayer():ConCommand(convar .. ' ' .. (option.enabled and 0 or 1))
        end

        option.enabled = !option.enabled
    end

    option.DoClick = toggle
    panel.OnMousePressed = function(_, mcode)
        if mcode == MOUSE_LEFT then
            toggle()
        end
    end

    if convar then
        local sync_name = 'mantle_checkbox_sync_' .. tostring(panel)
        timer.Create(sync_name, 0.1, 0, function()
            if not IsValid(panel) then return end

            local cvar = GetConVar(convar)
            if not cvar then return end

            option.enabled = cvar:GetBool()
        end)

        panel.OnRemove = function()
            timer.Remove(sync_name)
        end
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

        local btn_tab = vgui.Create('Button', panel_tabs.sp)
        surface.SetFont('Fated.20')
        btn_tab:SetSize(surface.GetTextSize(title) + 10 + (icon and 18 or 0), 20)
        btn_tab:SetText('')

        if icon then
            btn_tab.icon = Material(icon)
            panel_tabs.content[title].icon = icon
        end

        btn_tab.Paint = function(self, w, h)
            RNDX.Rect(0, 0, w, h)
                :Rad(6)
                :Color(panel_tabs.active_tab == title and (col_hov or Mantle.color.panel[2]) or (col or Mantle.color.theme))
                :Shape(RNDX.SHAPE_FIGMA)
            :Draw()

            if self:IsHovered() then
                RNDX.Rect(0, 0, w, h)
                    :Rad(6)
                    :Color(Mantle.color.button_shadow)
                    :Shape(RNDX.SHAPE_FIGMA)
                :Draw()
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
