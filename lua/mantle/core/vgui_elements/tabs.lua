local PANEL = {}

local color_btn_hovered = Color(255, 255, 255, 10)
local color_shadow = Color(0, 0, 0, 150)
local math_floor = math.floor

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

    self._hoverX = 0
    self._hoverY = 0
    self._hoverW = 0
    self._hoverH = 0
    self._hoverA = 0
    self._hoverActive = false

    self._tabShadowA = 0
    self._tabScroll = 0
    self._tabFootA = 0

    self.content = vgui.Create('Panel', self)
    self.content.Paint = nil

    self._tabShadow = vgui.Create('Panel', self)
    self._tabShadow:SetMouseInputEnabled(false)
    self._tabShadow.Paint = function(_, w, h)
        if self.tab_style != 'modern' then return end
        local a = self._tabShadowA or 0
        if a <= 0.01 then return end

        local sh = color_shadow
        Mantle.func.gradient(0, 0, w, h, 2, Color(sh.r, sh.g, sh.b, a))
    end

    self._tabFoot = vgui.Create('Panel', self)
    self._tabFoot:SetMouseInputEnabled(false)
    self._tabFoot:SetTall(self.tab_height)
    self._tabFoot.Paint = function(_, w, h)
        if self.tab_style != 'modern' then return end
        local a = self._tabFootA or 0
        if a <= 0.01 then return end

        local sh = color_shadow
        Mantle.func.gradient(0, 0, w, h, 1, Color(sh.r, sh.g, sh.b, a))
    end

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

    bar.Paint = function() end

    bar.PaintOver = function(s, w, h)
        if self.tab_style == 'modern' and self.indicator_w > 0 then
            local flags = self._indicator_moving and (RNDX.NO_BL + RNDX.NO_BR) or 0
            RNDX.Rect(self.indicator_x, h - self.indicator_height, self.indicator_w, self.indicator_height)
                :Rad(self.indicator_height)
                :Color(Mantle.color.theme)
                :Flags(flags)
            :Draw()
        end
    end

    self._hoverBar = vgui.Create('Panel', bar)
    self._hoverBar:SetMouseInputEnabled(false)
    self._hoverBar.Paint = function(_, w, h)
        local a = self._hoverA
        if a <= 0.01 then return end

        local hover = color_btn_hovered
        local flags = self.tab_style == 'modern' and self._hoverActive and (RNDX.NO_BL + RNDX.NO_BR) or 0
        local radius = self.tab_style == 'modern' and 16 or 24

        RNDX.Rect(0, 0, w, h)
            :Rad(radius)
            :Color(Color(hover.r, hover.g, hover.b, math_floor(10 * a)))
            :Flags(flags)
        :Draw()
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
            local padding = 16
            local iconW = tab.icon and 16 or 0
            local iconTextGap = tab.icon and 8 or 0
            local textX = padding + (iconW > 0 and (iconW + iconTextGap) or 0)

            if tab.icon then
                RNDX.Rect(padding, (h - 16) * 0.5, 16, 16)
                    :Material(tab.icon)
                    :Color(colorIcon)
                :Draw()
            end

            draw.SimpleText(tab.title, 'Fated.18', textX, h * 0.5, colorText, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        else
            draw.SimpleText(tab.title, 'Fated.18', 34, h * 0.5 - 1, colorText, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)

            if tab.icon then
                RNDX.Rect(9, 9, 16, 16)
                    :Material(tab.icon)
                    :Color(colorIcon)
                :Draw()
            else
                RNDX.Rect(9, 9, 16, 16)
                    :Rad(24)
                    :Color(colorIcon)
                :Draw()
            end
        end
    end

    tab._btn = btn
end

function PANEL:Think()
    local ft = FrameTime()
    local speed = 30

    local hovered
    for id, tab in ipairs(self.tabs) do
        local btn = tab._btn
        if IsValid(btn) and btn:IsHovered() then
            hovered = btn
            self._hoverActive = (id == self.active_id)
            break
        end
    end

    if IsValid(hovered) then
        self._hoverA = Mantle.func.approachExp(self._hoverA, 1, speed, ft)
        self._hoverX = Mantle.func.approachExp(self._hoverX, hovered:GetX(), speed, ft)
        self._hoverY = Mantle.func.approachExp(self._hoverY, hovered:GetY(), speed, ft)
        self._hoverW = Mantle.func.approachExp(self._hoverW, hovered:GetWide(), speed, ft)
        self._hoverH = Mantle.func.approachExp(self._hoverH, hovered:GetTall(), speed, ft)
    else
        self._hoverA = Mantle.func.approachExp(self._hoverA, 0, 20, ft)
    end

    if IsValid(self._hoverBar) then
        self._hoverBar:SetPos(self._hoverX, self._hoverY)
        self._hoverBar:SetSize(self._hoverW, self._hoverH)
    end

    if self.tab_style != 'modern' then return end

    local activeTab = self.tabs[self.active_id]
    local activePan = activeTab and IsValid(activeTab.pan) and activeTab.pan or nil

    local targetScroll = 0
    if activePan and activePan.GetScroll then
        targetScroll = activePan:GetScroll() or 0
    end

    self._tabScroll = Mantle.func.approachExp(self._tabScroll, targetScroll, 20, ft)
    self._tabShadowA = color_shadow.a * math.min(1, math.max(0, self._tabScroll) / self.tab_height) + 20

    local maxScroll = 0
    if activePan and activePan._range then
        maxScroll = select(1, activePan:_range())
    end

    self._tabFootA = color_shadow.a * math.min(1, math.max(0, maxScroll - self._tabScroll) / self.tab_height)

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

function PANEL:_applyTabLayout()
    for _, tab in ipairs(self.tabs) do
        local pan = tab.pan
        if IsValid(pan) then
            if self.tab_style == 'modern' then
                local offset = self.tab_height + 8
                if pan.GetScroll then
                    pan:DockPadding(0, offset, 0, 0)
                else
                    pan:DockMargin(0, offset, 0, 0)
                end
            else
                if pan.GetScroll then
                    pan:DockPadding(0, 0, 0, 0)
                else
                    pan:DockMargin(0, 0, 0, 0)
                end
            end
        end
    end
end

function PANEL:SetTabStyle(style)
    if style != 'modern' and style != 'classic' then return end
    if self.tab_style == style then return end

    self.tab_style = style
    self:_rebuildTabs()
    self:_applyTabLayout()
end

function PANEL:SetTabHeight(height)
    self.tab_height = height
    self:_applyTabLayout()
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
    self:_applyTabLayout()
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

    if next_tab.pan and next_tab.pan.GetScroll then
        next_tab.pan:SetScroll(0)
    end

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
        self.panel_tabs:SetPos(0, 0)
        self.panel_tabs:SetSize(w, self.tab_height)
        self._tabShadow:SetPos(0, 0)
        self._tabShadow:SetSize(w, self.tab_height * 1.5)
        self._tabShadow:SetVisible(true)
        self._tabFoot:SetPos(0, h - self.tab_height)
        self._tabFoot:SetSize(w, self.tab_height)
        self._tabFoot:SetVisible(true)
        self.content:Dock(FILL)
    else
        self.panel_tabs:Dock(LEFT)
        self.panel_tabs:DockMargin(0, 0, 4, 0)
        self.panel_tabs:SetWide(190)
        self._tabShadow:SetVisible(false)
        self._tabFoot:SetVisible(false)
        self.content:Dock(FILL)
    end
end

vgui.Register('MantleTabs', PANEL, 'Panel')
