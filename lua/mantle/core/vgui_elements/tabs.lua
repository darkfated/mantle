local PANEL = {}

local color_btn_hovered = Color(255, 255, 255, 10)

local function getTabButton(self, tab_id)
    local tab = self.tabs[tab_id]
    return tab and tab._btn or nil
end

function PANEL:Init()
    self.tabs = {}
    self.active_id = 1
    self.tab_height = 38
    self.animation_speed = 12
    self.tab_style = 'modern'
    self.indicator_height = 2

    self.indicator_x = 0
    self.indicator_w = 0
    self._indicator_inited = false

    self.content = vgui.Create('Panel', self)
    self.content.Paint = nil

    self:_rebuildTabs()
end

function PANEL:_createTabBar()
    if IsValid(self.panel_tabs) then
        self.panel_tabs:Remove()
    end

    local bar
    if self.tab_style == 'modern' then
        bar = vgui.Create('MantleHScroll', self)
    else
        bar = vgui.Create('MantleScrollPanel', self)
    end

    bar.Paint = function(s, w, h)
        if self.tab_style == 'modern' and self.indicator_w > 0 then
            local flags = self._indicator_moving and (RNDX.NO_BL + RNDX.NO_BR) or 0
            RNDX.Draw(self.indicator_height, self.indicator_x, h - self.indicator_height, self.indicator_w, self.indicator_height, Mantle.color.theme, flags)
        end
    end

    self.panel_tabs = bar
end

function PANEL:_syncPanels()
    for id, tab in ipairs(self.tabs) do
        tab.pan:SetVisible(id == self.active_id)
    end
end

function PANEL:_rebuildTabs()
    self:_createTabBar()

    for id, tab in ipairs(self.tabs) do
        self:_createTabButton(tab, id)
    end

    self:_syncPanels()
    self:InvalidateLayout(true)
end

function PANEL:_createTabButton(tab, id)
    local btn = vgui.Create('Button', self.panel_tabs)
    btn:SetText('')

    if self.tab_style == 'modern' then
        surface.SetFont('Fated.18')
        local textW = select(1, surface.GetTextSize(tab.title))
        local iconW = tab.icon and 16 or 0
        local iconTextGap = tab.icon and 8 or 0
        btn:Dock(LEFT)
        btn:DockMargin(0, 0, 6, 0)
        btn:SetTall(34)
        btn:SetWide(16 + iconW + iconTextGap + textW + 16)
    else
        btn:Dock(TOP)
        btn:DockMargin(0, 0, 0, 6)
        btn:SetTall(34)
    end

    btn.DoClick = function()
        self:SetActiveTab(id)
    end

    btn.DoRightClick = function()
        local dm = Mantle.ui.derma_menu()
        for k, t in ipairs(self.tabs) do
            dm:AddOption(t.title, function()
                self:SetActiveTab(k, true)
            end, t.icon)
        end
    end

    btn.Paint = function(s, w, h)
        local isActive = self.active_id == id
        local colorText = isActive and Mantle.color.theme or Mantle.color.text
        local colorIcon = isActive and Mantle.color.theme or color_white

        if self.tab_style == 'modern' then
            if s:IsHovered() then
                RNDX.Draw(16, 0, 0, w, h, color_btn_hovered, RNDX.SHAPE_IOS + (isActive and RNDX.NO_BL + RNDX.NO_BR or 0))
            end

            local padding = 16
            local iconW = tab.icon and 16 or 0
            local iconTextGap = tab.icon and 8 or 0
            local textX = padding + (iconW > 0 and (iconW + iconTextGap) or 0)

            if tab.icon then
                RNDX.DrawMaterial(0, padding, (h - 16) * 0.5, 16, 16, colorIcon, tab.icon)
            end

            draw.SimpleText(tab.title, 'Fated.18', textX, h * 0.5, colorText, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        else
            if s:IsHovered() then
                RNDX.Draw(24, 0, 0, w, h, color_btn_hovered, RNDX.SHAPE_IOS)
            end

            draw.SimpleText(tab.title, 'Fated.18', 34, h * 0.5 - 1, colorText, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)

            if tab.icon then
                RNDX.DrawMaterial(0, 9, 9, 16, 16, colorIcon, tab.icon)
            else
                RNDX.Draw(24, 9, 9, 16, 16, colorIcon, RNDX.SHAPE_IOS)
            end
        end
    end

    tab._btn = btn
end

function PANEL:Think()
    if self.tab_style != 'modern' then return end

    local ft = FrameTime()
    local activeBtn = getTabButton(self, self.active_id)

    local targetX, targetW = 0, 0
    if IsValid(activeBtn) then
        targetX = activeBtn:GetX() - self.panel_tabs:GetScroll()
        targetW = activeBtn:GetWide()
    end

    if !self._indicator_inited then
        self.indicator_x = targetX
        self.indicator_w = targetW
        self._indicator_inited = true
        self._indicator_moving = false
        return
    end

    self.indicator_x = Mantle.func.approachExp(self.indicator_x, targetX, self.animation_speed, ft)
    self.indicator_w = Mantle.func.approachExp(self.indicator_w, targetW, self.animation_speed, ft)

    if math.abs(self.indicator_x - targetX) < 0.5 then
        self.indicator_x = targetX
    end

    if math.abs(self.indicator_w - targetW) < 0.5 then
        self.indicator_w = targetW
    end

    self._indicator_moving = math.abs(self.indicator_x - targetX) >= 0.5 or math.abs(self.indicator_w - targetW) >= 0.5
end

function PANEL:SetTabStyle(style)
    if style != 'modern' and style != 'classic' then return end
    if self.tab_style == style then return end

    self.tab_style = style
    self:_rebuildTabs()
end

function PANEL:SetTabHeight(height)
    self.tab_height = height
    self:InvalidateLayout(true)
end

function PANEL:SetIndicatorHeight(height)
    self.indicator_height = height
end

function PANEL:AddTab(data, pan, icon)
    local title = data
    local description = ''

    if istable(data) then
        title = data.title or data.name or ''
        description = data.description or ''
        icon = data.icon
        pan = pan or data.pan or data.panel
    end

    local newId = #self.tabs + 1

    local tab = {
        name = title,
        title = title,
        description = description,
        pan = pan,
        icon = icon
    }

    self.tabs[newId] = tab

    tab.pan:SetParent(self.content)
    tab.pan:Dock(FILL)
    self:_createTabButton(tab, newId)
    self:_syncPanels()

    return newId
end

function PANEL:SetActiveTab(tab_id, is_silent)
    local next_id = tab_id

    if isstring(tab_id) then
        for id, tab in ipairs(self.tabs) do
            if tab.title == tab_id or tab.name == tab_id then
                next_id = id
                break
            end
        end
    end

    local current = self.tabs[self.active_id]
    local next_tab = self.tabs[next_id]
    if !next_tab then return end

    if current and current != next_tab then
        current.pan:SetVisible(false)
    end

    next_tab.pan:SetVisible(true)
    self.active_id = next_id

    if self.tab_style == 'modern' then
        local btn = next_tab._btn
        if IsValid(btn) then
            local scroll = self.panel_tabs:GetScroll()
            local viewW = self.panel_tabs:GetWide()
            local bx = btn:GetX()
            local bw = btn:GetWide()

            if bx - scroll < 0 then
                self.panel_tabs:SetScroll(bx)
            elseif bx + bw - scroll > viewW then
                self.panel_tabs:SetScroll(bx + bw - viewW)
            end
        end
    end

    if !is_silent then
        Mantle.func.sound()
    end

    return true
end

function PANEL:PerformLayout(w, h)
    if self.tab_style == 'modern' then
        self.panel_tabs:Dock(TOP)
        self.panel_tabs:DockMargin(0, 0, 0, 4)
        self.panel_tabs:SetTall(self.tab_height)
    else
        self.panel_tabs:Dock(LEFT)
        self.panel_tabs:DockMargin(0, 0, 4, 0)
        self.panel_tabs:SetWide(190)
    end

    self.content:Dock(FILL)
end

vgui.Register('MantleTabs', PANEL, 'Panel')
