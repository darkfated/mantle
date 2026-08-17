local PANEL = {}

local math_floor = math.floor

local function getTabButton(self, tab_id)
    local tab = self.tabs[tab_id]
    return tab and tab._btn or nil
end

function PANEL:Init()
    self:DockMargin(8, 8, 8, 8)
    self.tabs = {}
    self.activeId = 1
    self.tabHeight = 38
    self.animationSpeed = 12
    self.tabStyle = 'modern'
    self.indicatorHeight = 2

    self.indicatorX = 0
    self.indicatorW = 0
    self._indicator_inited = false

    self._hoverX = 0
    self._hoverY = 0
    self._hoverW = 0
    self._hoverH = 0
    self._hoverA = 0
    self._hoverActive = false

    self._tabShadowA = 0
    self._tabScroll = 0

    self.content = vgui.Create('Panel', self)
    self.content.Paint = nil

    self._tabShadow = vgui.Create('Panel', self)
    self._tabShadow:SetMouseInputEnabled(false)
    self._tabShadow.Paint = function(_, w, h)
        if self.tabStyle != 'modern' then return end

        local a = self._tabShadowA or 0
        local sa = Mantle.color.blur_shadow

        if Mantle.ui.convar.smooth and a > 0 then
            RNDX.Rect(0, 0, w, h)
                :Blur()
                :Fade(1, 0)
                :Alpha(sa.a > 0 and a / sa.a or 0)
            :Draw()
        end
    end

    self:_rebuildTabs()
end

function PANEL:_createTabBar()
    if IsValid(self.panelTabs) then
        self.panelTabs:Remove()
    end

    local bar
    if self.tabStyle == 'modern' then
        bar = vgui.Create('MantleHScroll', self)
    else
        bar = vgui.Create('MantleScrollPanel', self)
    end

    bar.Paint = function() end

    bar.PaintOver = function(s, w, h)
        if self.tabStyle == 'modern' and self.indicatorW > 0 then
            local flags = self._indicator_moving and (RNDX.NO_BL + RNDX.NO_BR) or 0
            RNDX.Rect(self.indicatorX, h - self.indicatorHeight, self.indicatorW, self.indicatorHeight)
                :Rad(self.indicatorHeight)
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

        local hover = Mantle.color.tab_hover
        local flags = self.tabStyle == 'modern' and self._hoverActive and (RNDX.NO_BL + RNDX.NO_BR) or 0
        local radius = self.tabStyle == 'modern' and 16 or 24

        RNDX.Rect(0, 0, w, h)
            :Rad(radius)
            :Shape(RNDX.SHAPE_IOS)
            :Color(Color(hover.r, hover.g, hover.b, math_floor(hover.a * a)))
            :Flags(flags)
        :Draw()
    end

    self.panelTabs = bar
end

function PANEL:_syncPanels()
    for id, tab in ipairs(self.tabs) do
        tab.pan:SetVisible(id == self.activeId)
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
    local btn = vgui.Create('Button', self.panelTabs)
    btn:SetText('')

    if self.tabStyle == 'modern' then
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
        local isActive = self.activeId == id
        local colorText = isActive and Mantle.color.theme or Mantle.color.text
        local colorIcon = isActive and Mantle.color.theme or Mantle.color.icon

        if self.tabStyle == 'modern' then
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
            self._hoverActive = (id == self.activeId)
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

    if self.tabStyle != 'modern' then return end

    local activeTab = self.tabs[self.activeId]
    local activePan = activeTab and IsValid(activeTab.pan) and activeTab.pan

    local targetScroll = 0
    if activePan and activePan.GetScroll then
        targetScroll = activePan:GetScroll() or 0
    end

    self._tabScroll = Mantle.func.approachExp(self._tabScroll, targetScroll, 20, ft)

    local shadowTarget = Mantle.color.blur_shadow.a * math.min(1, math.max(0, self._tabScroll) / (self.tabHeight * 2))
    self._tabShadowA = Mantle.util.stepAlpha(self._tabShadowA, shadowTarget, 200, ft)

    local maxScroll = 0
    if activePan and activePan._range then
        maxScroll = select(1, activePan:_range())
    end

    local activeBtn = getTabButton(self, self.activeId)

    local targetX, targetW = 0, 0
    if IsValid(activeBtn) then
        targetX = activeBtn:GetX() - self.panelTabs:GetScroll()
        targetW = activeBtn:GetWide()
    end

    if !self._indicator_inited then
        self.indicatorX = targetX
        self.indicatorW = targetW
        self._indicator_inited = true
        self._indicator_moving = false
        return
    end

    self.indicatorX = Mantle.func.approachExp(self.indicatorX, targetX, self.animationSpeed, ft)
    self.indicatorW = Mantle.func.approachExp(self.indicatorW, targetW, self.animationSpeed, ft)

    if math.abs(self.indicatorX - targetX) < 0.5 then
        self.indicatorX = targetX
    end

    if math.abs(self.indicatorW - targetW) < 0.5 then
        self.indicatorW = targetW
    end

    self._indicator_moving = math.abs(self.indicatorX - targetX) >= 0.5 or math.abs(self.indicatorW - targetW) >= 0.5
end

function PANEL:_applyTabLayout()
    for _, tab in ipairs(self.tabs) do
        local pan = tab.pan
        if IsValid(pan) then
            if self.tabStyle == 'modern' then
                local offset = self.tabHeight + 8
                if pan.GetScroll then
                    pan:DockPadding(0, offset, 0, 0)
                else
                    pan:DockMargin(0, offset, 0, 0)
                end
            else
                if pan.GetScroll then
                    pan:DockPadding(0, 0, 0, 0)
                end
            end
        end
    end
end

function PANEL:SetTabStyle(style)
    if style != 'modern' and style != 'classic' then return end
    if self.tabStyle == style then return end

    self.tabStyle = style
    self:_rebuildTabs()
    self:_applyTabLayout()
end

function PANEL:SetTabHeight(height)
    self.tabHeight = height
    self:_applyTabLayout()
    self:InvalidateLayout(true)
end

function PANEL:SetIndicatorHeight(height)
    self.indicatorHeight = height
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
            if tab.title == tab_id then
                next_id = id
                break
            end
        end
    end

    local current = self.tabs[self.activeId]
    local next_tab = self.tabs[next_id]
    if !next_tab then return end

    if current and current != next_tab then
        current.pan:SetVisible(false)
    end

    next_tab.pan:SetVisible(true)
    self.activeId = next_id

    if next_tab.pan and next_tab.pan.GetScroll then
        next_tab.pan:SetScroll(0)
    end

    if self.tabStyle == 'modern' then
        local btn = next_tab._btn
        if IsValid(btn) then
            local scroll = self.panelTabs:GetScroll()
            local viewW = self.panelTabs:GetWide()
            local bx = btn:GetX()
            local bw = btn:GetWide()

            if bx - scroll < 0 then
                self.panelTabs:SetScroll(bx)
            elseif bx + bw - scroll > viewW then
                self.panelTabs:SetScroll(bx + bw - viewW)
            end
        end
    end

    if !is_silent then
        Mantle.func.sound()
    end

    return true
end

function PANEL:PerformLayout(w, h)
    if self.tabStyle == 'modern' then
        self.panelTabs:SetPos(0, 0)
        self.panelTabs:SetSize(w, self.tabHeight)
        local blurTall = math.max(self.tabHeight, h * 0.12)
        self._tabShadow:SetPos(0, 0)
        self._tabShadow:SetSize(w, blurTall)
        self._tabShadow:SetVisible(true)
        self.content:Dock(FILL)
    else
        self.panelTabs:Dock(LEFT)
        self.panelTabs:DockMargin(0, 0, 4, 0)
        self.panelTabs:SetWide(190)
        self._tabShadow:SetVisible(false)
        self.content:Dock(FILL)
    end
end

vgui.Register('MantleTabs', PANEL, 'Panel')
