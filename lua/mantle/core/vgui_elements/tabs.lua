local PANEL = {}

local math_max = math.max
local math_min = math.min
local math_floor = math.floor
local math_abs = math.abs

local INDICATOR_SPEED = 18
local INDICATOR_SPEED_ADJACENT = 30
local ACTIVE_SPEED = 18
local HOVER_SPEED = 30
local HOVER_SPEED_ADJACENT = 46

local SNAP_POS = 0.5
local SNAP_ALPHA = 1
local SNAP_HOVER = 0.01
local SNAP_ACTIVE = 0.01

local function approachSnap(current, target, speed, dt, snap)
    if current == target then return target end
    local next = Mantle.func.approachExp(current, target, speed, dt)
    if math_abs(next - target) <= snap then return target end
    return next
end

local function getTabButton(self, tabId)
    local tab = self.tabs[tabId]
    return tab and tab._btn or nil
end

local function colorAlpha(color, alpha)
    if !color then return Color(255, 255, 255, math_floor(alpha)) end
    return Color(color.r, color.g, color.b, math_floor(math.Clamp(alpha, 0, 255)))
end

local function lerpColor(a, b, t)
    if !a then a = Color(255, 255, 255, 255) end
    if !b then b = Color(255, 255, 255, 255) end
    return Color(
        a.r + (b.r - a.r) * t,
        a.g + (b.g - a.g) * t,
        a.b + (b.b - a.b) * t,
        a.a + (b.a - a.a) * t
    )
end

local function getClassicButtonHeight(self, tab)
    local height = math_max(38, self.tabHeight - 6)
    if tab.description != '' then
        height = math_max(height, 50)
    end
    return height
end

function PANEL:Init()
    self:DockMargin(8, 8, 8, 8)

    self.tabs = {}
    self.activeId = 1
    self.tabHeight = 44
    self.animationSpeed = 12
    self.tabStyle = 'modern'
    self.indicatorHeight = 1
    self.classicTabWidth = 200
    self.tabGap = 8
    self.segmentGap = 0
    self._indicatorSpeedMul = 1
    self._indicatorDirty = true
    self._lastIndicatorScroll = nil

    self._savedTabScroll = {
        modern = 0,
        classic = 0
    }

    self._pendingTabScroll = nil
    self._pendingEnsureActive = false
    self._skipEnsureAfterScrollRestore = false
    self.content = vgui.Create('Panel', self)
    self.content:SetZPos(0)
    self.content.Paint = nil

    self:_rebuildTabs()
end

function PANEL:_createTabBar()
    if IsValid(self._tabFrame) then
        self._tabFrame:Remove()
    end

    local frame = vgui.Create('Panel', self)
    frame:SetZPos(3)

    frame.Paint = function(_, w, h)
        if self.tabStyle == 'modern' then
            RNDX.Rect(0, 0, w, h)
                :Rad(13)
                :Color(Mantle.color.window_shadow)
            :Draw()
        else
            RNDX.Rect(0, 0, w, h)
                :Rad(14)
                :Color(Mantle.color.window_shadow)
            :Draw()
        end
    end

    frame.PaintOver = function(_, w, h)
        local border = Mantle.color.gray or Mantle.color.icon
        if self.tabStyle == 'modern' then
            RNDX.Rect(0, 0, w, h)
                :Rad(13)
                :Color(colorAlpha(border, 82))
                :Outline(1)
            :Draw()
        else
            RNDX.Rect(0, 0, w, h)
                :Rad(14)
                :Color(colorAlpha(border, 68))
                :Outline(1)
            :Draw()
        end
    end

    local bar
    if self.tabStyle == 'modern' then
        bar = vgui.Create('MantleHScroll', frame)
        bar:SetPos(1, 1)
        bar:SetSize(0, 0)
    else
        bar = vgui.Create('MantleScrollPanel', frame)
        bar:SetPos(6, 6)
        bar:SetSize(0, 0)
    end
    bar:SetZPos(1)

    bar:DockPadding(0, 0, 0, 0)
    bar.Paint = function() end
    bar.PaintOver = nil

    local indicator = vgui.Create('Panel', frame)
    indicator:SetZPos(0)
    indicator:SetMouseInputEnabled(false)
    indicator:SetKeyboardInputEnabled(false)
    indicator.Paint = function(_, w, h)
        local st = self._indicatorState
        if !st or st.alpha < 1 then return end

        local theme = Mantle.color.theme
        local a = st.alpha / 255

        if self.tabStyle == 'modern' then
            RNDX.Rect(0, 0, w, h)
                :Rad(11)
                :Color(Color(theme.r, theme.g, theme.b, math_floor(15 * a)))
            :Draw()

            RNDX.Rect(0, 0, w, h)
                :Rad(11)
                :Color(Color(theme.r, theme.g, theme.b, math_floor(220 * a)))
                :Outline(self.indicatorHeight)
            :Draw()
        else
            local bg = Mantle.color.focus_panel
            RNDX.Rect(0, 0, w, h)
                :Rad(9)
                :Color(Color(bg.r, bg.g, bg.b, math_floor(bg.a * a)))
            :Draw()

            RNDX.Rect(0, 0, w, h)
                :Rad(9)
                :Color(Color(theme.r, theme.g, theme.b, math_floor(14 * a)))
                :Outline(1)
            :Draw()
        end
    end

    self._indicator = indicator
    self._indicatorState = {
        x = 0, y = 0, w = 0, h = 0,
        alpha = 0,
        initialized = false
    }
    self._indicatorDirty = true
    self._lastIndicatorScroll = nil

    self._tabFrame = frame
    self.panelTabs = bar
    self._pendingTabScroll = self._savedTabScroll[self.tabStyle] or 0
    self._forceTabScrollReset = self._pendingTabScroll == 0
end

function PANEL:_updateIndicator(dt)
    local st = self._indicatorState
    if !st then return end

    local indicator = self._indicator
    if !IsValid(indicator) then return end

    local panelTabs = self.panelTabs
    if IsValid(panelTabs) then
        local scroll = panelTabs:GetScroll() or 0
        if scroll != self._lastIndicatorScroll then
            self._lastIndicatorScroll = scroll
            self._indicatorDirty = true
        end
    end

    if !self._indicatorDirty and st.initialized then return end

    local btn = getTabButton(self, self.activeId)
    local tabFrame = self._tabFrame

    if !IsValid(btn) or !IsValid(tabFrame) then
        if st.alpha > 0 then
            st.alpha = approachSnap(st.alpha, 0, INDICATOR_SPEED, dt, SNAP_ALPHA)
        end
        if st.alpha == 0 then
            self._indicatorDirty = false
        end
        return
    end

    local bx, by = btn:LocalToScreen(0, 0)
    local fx, fy = tabFrame:LocalToScreen(0, 0)
    local targetX, targetY = bx - fx, by - fy
    local targetW, targetH = btn:GetWide(), btn:GetTall()

    local speed = INDICATOR_SPEED * (self._indicatorSpeedMul or 1)

    if !st.initialized then
        st.x, st.y = targetX, targetY
        st.w, st.h = targetW, targetH
        st.alpha = 255
        st.initialized = true
        indicator:SetPos(st.x, st.y)
        indicator:SetSize(st.w, st.h)
        self._indicatorDirty = false
        return
    end

    local nx = approachSnap(st.x, targetX, speed, dt, SNAP_POS)
    local ny = approachSnap(st.y, targetY, speed, dt, SNAP_POS)
    local nw = approachSnap(st.w, targetW, speed, dt, SNAP_POS)
    local nh = approachSnap(st.h, targetH, speed, dt, SNAP_POS)

    if nx != st.x or ny != st.y or nw != st.w or nh != st.h then
        st.x, st.y, st.w, st.h = nx, ny, nw, nh
        indicator:SetPos(nx, ny)
        indicator:SetSize(nw, nh)
    end

    st.alpha = approachSnap(st.alpha, 255, speed, dt, SNAP_ALPHA)

    if nx == targetX and ny == targetY and nw == targetW and nh == targetH and st.alpha == 255 then
        self._indicatorDirty = false
    end
end

function PANEL:_syncPanels()
    for id, tab in ipairs(self.tabs) do
        if IsValid(tab.pan) then
            tab.pan:SetVisible(id == self.activeId)
        end
    end
end

function PANEL:_resetTabAnimation()
    for id, tab in ipairs(self.tabs) do
        tab._hover = 0
        tab._active = (id == self.activeId) and 1 or 0
    end
end

function PANEL:_rebuildTabs()
    self:_resetTabAnimation()
    self:_createTabBar()

    for id, tab in ipairs(self.tabs) do
        tab._btn = nil
        self:_createTabButton(tab, id)
    end

    self:_syncPanels()
    self._pendingEnsureActive = true
    self._indicatorDirty = true
    self:InvalidateLayout(true)
end

function PANEL:_createTabButton(tab, id)
    local btn = vgui.Create('Button')
    btn:SetText('')
    btn:SetCursor('hand')
    btn:SetKeyboardInputEnabled(false)

    if tab.description != '' then
        btn:SetTooltip(tab.description)
    end

    surface.SetFont('Fated.16')
    tab._titleW = select(1, surface.GetTextSize(tab.title))

    self.panelTabs:AddItem(btn)

    if self.tabStyle == 'modern' then
        btn:Dock(LEFT)
        btn:DockMargin(0, 0, self.segmentGap, 0)
        btn:SetWide(88)
    else
        btn:Dock(TOP)
        btn:DockMargin(3, 3, 3, 4)
        btn:SetTall(getClassicButtonHeight(self, tab))
    end

    btn.DoClick = function()
        self:SetActiveTab(id)
    end

    btn.DoRightClick = function()
        local menu = Mantle.ui.derma_menu()
        for k, currentTab in ipairs(self.tabs) do
            local tabIndex = k
            menu:AddOption(currentTab.title, function()
                self:SetActiveTab(tabIndex, true)
            end, currentTab.icon)
        end
    end

    btn.Paint = function(_, w, h)
        local theme = Mantle.color.theme
        local activeAmt = tab._active or 0
        local hoverAmt = tab._hover or 0
        local hoverAlpha = hoverAmt * (1 - activeAmt)

        local textColor, iconColor
        if activeAmt < 0.001 then
            textColor = Mantle.color.text
            iconColor = Mantle.color.icon
        elseif activeAmt > 0.999 then
            textColor = theme
            iconColor = theme
        else
            textColor = lerpColor(Mantle.color.text, theme, activeAmt)
            iconColor = lerpColor(Mantle.color.icon, theme, activeAmt)
        end

        if self.tabStyle == 'modern' then
            if hoverAlpha > 0.01 then
                local hover = Mantle.color.tab_hover
                RNDX.Rect(0, 0, w, h)
                    :Rad(11)
                    :Color(colorAlpha(hover, hover.a * hoverAlpha))
                :Draw()
            end

            local iconW = tab.icon and 16 or 0
            local iconGap = tab.icon and 8 or 0
            local textW = tab._titleW or 0
            local contentW = iconW + iconGap + textW
            local startX = math_floor((w - contentW) * 0.5)

            if tab.icon then
                RNDX.Rect(startX, (h - 16) * 0.5, 16, 16)
                    :Material(tab.icon)
                    :Color(iconColor)
                :Draw()
            end

            local textX = startX + iconW + iconGap
            draw.SimpleText(tab.title, 'Fated.16', textX, h * 0.5, textColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        else
            if hoverAlpha > 0.01 then
                local hover = Mantle.color.tab_hover
                RNDX.Rect(0, 0, w, h)
                    :Rad(9)
                    :Color(colorAlpha(hover, hover.a * hoverAlpha))
                :Draw()
            end

            local textX = 12
            if tab.icon then
                RNDX.Rect(12, (h - 16) * 0.5, 16, 16)
                    :Material(tab.icon)
                    :Color(iconColor)
                :Draw()
                textX = 36
            end

            if tab.description != '' then
                draw.SimpleText(tab.title, 'Fated.16', textX, h * 0.36, textColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
                draw.SimpleText(tab.description, 'Fated.14', textX, h * 0.72, Mantle.color.gray, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
            else
                draw.SimpleText(tab.title, 'Fated.16', textX, h * 0.5, textColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
            end
        end
    end

    tab._btn = btn
    tab._hover = tab._hover or 0
    tab._active = tab._active or ((id == self.activeId) and 1 or 0)
end

function PANEL:_layoutModernButtons()
    if self.tabStyle != 'modern' or !IsValid(self.panelTabs) then return end

    local count = #self.tabs
    if count == 0 then return end

    surface.SetFont('Fated.16')

    local preferredWidths = {}
    local totalPreferredWidth = 0
    local maxPreferredWidth = 0

    for id, tab in ipairs(self.tabs) do
        local textWidth = tab._titleW or select(1, surface.GetTextSize(tab.title))
        local iconWidth = tab.icon and 24 or 0
        local preferredWidth = math_max(72, math.ceil(textWidth + iconWidth + 28))

        preferredWidths[id] = preferredWidth
        totalPreferredWidth = totalPreferredWidth + preferredWidth
        maxPreferredWidth = math_max(maxPreferredWidth, preferredWidth)
    end

    local viewWidth = math_max(0, self.panelTabs:GetWide())
    local gap = self.segmentGap
    local totalGap = gap * math_max(0, count - 1)
    local availableWidth = math_max(0, viewWidth - totalGap)
    local widths = {}

    if maxPreferredWidth * count <= availableWidth then
        local baseWidth = math_floor(availableWidth / count)
        for id = 1, count do
            widths[id] = baseWidth
        end
    elseif totalPreferredWidth <= availableWidth then
        local extraWidth = (availableWidth - totalPreferredWidth) / count
        for id = 1, count do
            widths[id] = math_floor(preferredWidths[id] + extraWidth)
        end
    else
        for id = 1, count do
            widths[id] = preferredWidths[id]
        end
    end

    local used = 0
    for id = 1, count do
        used = used + widths[id]
    end
    widths[count] = widths[count] + (availableWidth - used)

    local buttonHeight = math_max(1, self.panelTabs:GetTall())

    for id, tab in ipairs(self.tabs) do
        local btn = tab._btn
        if IsValid(btn) then
            btn:SetWide(widths[id])
            btn:SetTall(buttonHeight)
            btn:DockMargin(0, 0, id < count and gap or 0, 0)
        end
    end

    if self.panelTabs._markDirty then
        self.panelTabs:_markDirty()
    end

    self.panelTabs:InvalidateLayout(true)
    self._indicatorDirty = true
end

function PANEL:_ensureTabVisible(tabId)
    local btn = getTabButton(self, tabId)
    if !IsValid(btn) or !IsValid(self.panelTabs) then return end

    local scroll = self.panelTabs:GetScroll() or 0

    if self.tabStyle == 'modern' then
        if tabId == 1 then
            self.panelTabs:SetScroll(0)
            self._savedTabScroll.modern = 0
            return
        end

        local logicalX = btn:GetX()
        local width = btn:GetWide()
        local viewWidth = self.panelTabs:GetWide()

        if logicalX < scroll then
            self.panelTabs:SetScroll(math_max(0, logicalX))
        elseif logicalX + width > scroll + viewWidth then
            self.panelTabs:SetScroll(math_max(0, logicalX + width - viewWidth))
        end
    else
        local logicalY = btn:GetY()
        local height = btn:GetTall()
        local viewHeight = self.panelTabs:GetTall()

        if logicalY < scroll then
            self.panelTabs:SetScroll(math_max(0, logicalY))
        elseif logicalY + height > scroll + viewHeight then
            self.panelTabs:SetScroll(math_max(0, logicalY + height - viewHeight))
        end
    end
end

function PANEL:Think()
    local ft = FrameTime()
    local activeId = self.activeId
    local tabs = self.tabs
    local count = #tabs

    for id = 1, count do
        local tab = tabs[id]
        local btn = tab._btn
        local hoverTarget = (IsValid(btn) and btn:IsHovered()) and 1 or 0
        local activeTarget = (id == activeId) and 1 or 0
        local adjacent = math_abs(id - activeId) <= 1

        local hover = tab._hover or 0
        if hover != hoverTarget then
            local speed = adjacent and HOVER_SPEED_ADJACENT or HOVER_SPEED
            tab._hover = approachSnap(hover, hoverTarget, speed, ft, SNAP_HOVER)
        end

        local active = tab._active or 0
        if active != activeTarget then
            local speed = adjacent and (ACTIVE_SPEED * 1.5) or ACTIVE_SPEED
            tab._active = approachSnap(active, activeTarget, speed, ft, SNAP_ACTIVE)
        end
    end

    if self._pendingEnsureActive then
        self._pendingEnsureActive = false
        if self._skipEnsureAfterScrollRestore then
            self._skipEnsureAfterScrollRestore = false
        else
            self:_ensureTabVisible(self.activeId)
        end
    end

    self:_updateIndicator(ft)
end

function PANEL:_applyTabLayout()
    if IsValid(self.content) then
        self.content:InvalidateLayout(true)
    end
end

function PANEL:SetTabStyle(style)
    if style != 'modern' and style != 'classic' then return end
    if self.tabStyle == style then return end

    if IsValid(self.panelTabs) then
        self._savedTabScroll[self.tabStyle] = self.panelTabs:GetScroll() or 0
    end

    self.tabStyle = style
    self:_rebuildTabs()
    self:_applyTabLayout()
    self:InvalidateLayout(true)
    self._pendingEnsureActive = true
end

function PANEL:SetTabHeight(height)
    height = tonumber(height)
    if !height then return end

    self.tabHeight = math.Clamp(math_floor(height), 36, 72)

    if self.tabStyle == 'classic' then
        for _, tab in ipairs(self.tabs) do
            if IsValid(tab._btn) then
                tab._btn:SetTall(getClassicButtonHeight(self, tab))
            end
        end
        self._indicatorDirty = true
    else
        self:_layoutModernButtons()
    end

    self:InvalidateLayout(true)
end

function PANEL:SetIndicatorHeight(height)
    height = tonumber(height)
    if !height then return end

    self.indicatorHeight = math.Clamp(math_floor(height), 1, 3)
    self:InvalidateLayout(true)
end

function PANEL:SetClassicTabWidth(width)
    width = tonumber(width)
    if !width then return end

    self.classicTabWidth = math.Clamp(math_floor(width), 128, 240)
    self:InvalidateLayout(true)
    self._pendingEnsureActive = true
end

function PANEL:AddTab(data, pan, icon)
    local title = data
    local description = ''

    if istable(data) then
        title = data.title or data.name or ''
        description = data.description or ''
        icon = icon or data.icon
        pan = pan or data.pan or data.panel
    end

    if !IsValid(pan) or pan == self.content then return end

    title = tostring(title or '')
    description = tostring(description or '')

    local newId = #self.tabs + 1
    local tab = {
        title = title,
        description = description,
        pan = pan,
        icon = icon,
        _hover = 0,
        _active = (newId == self.activeId) and 1 or 0
    }

    self.tabs[newId] = tab
    pan:SetParent(self.content)
    pan:Dock(FILL)
    pan:SetVisible(newId == self.activeId)

    self:_createTabButton(tab, newId)
    self:_layoutModernButtons()
    self:_applyTabLayout()
    self._pendingEnsureActive = true

    return newId
end

function PANEL:SetActiveTab(tabId, isSilent)
    local nextId = tabId

    if isstring(tabId) then
        nextId = nil
        for id, tab in ipairs(self.tabs) do
            if tab.title == tabId then
                nextId = id
                break
            end
        end
    end

    nextId = tonumber(nextId)
    if !nextId then return end
    nextId = math_floor(nextId)

    local nextTab = self.tabs[nextId]
    if !nextTab or !IsValid(nextTab.pan) then return end

    self._pendingEnsureActive = false

    if self.activeId == nextId then
        return true
    end

    local oldId = self.activeId
    local distance = math_abs(nextId - oldId)
    self._indicatorSpeedMul = (distance <= 1) and (INDICATOR_SPEED_ADJACENT / INDICATOR_SPEED) or 1.0
    self._indicatorDirty = true

    local currentTab = self.tabs[self.activeId]
    if currentTab and IsValid(currentTab.pan) then
        currentTab.pan:SetVisible(false)
    end

    nextTab.pan:SetVisible(true)
    self.activeId = nextId

    if !self._indicatorState then
        self._indicatorState = { x = 0, y = 0, w = 0, h = 0, alpha = 0, initialized = false }
    end

    if !isSilent then
        Mantle.func.sound()
    end

    return true
end

function PANEL:GetActiveTab()
    return self.activeId
end

function PANEL:GetTabCount()
    return #self.tabs
end

function PANEL:PerformLayout(w, h)
    if !IsValid(self._tabFrame) or !IsValid(self.panelTabs) or !IsValid(self.content) then return end

    if self.tabStyle == 'modern' then
        local barHeight = self.tabHeight + 2
        local contentY = barHeight + self.tabGap
        local contentH = math_max(0, h - contentY)

        self._tabFrame:SetPos(0, 0)
        self._tabFrame:SetSize(w, barHeight)
        self.panelTabs:SetPos(1, 1)
        self.panelTabs:SetSize(math_max(0, w - 2), math_max(0, barHeight - 2))

        self.content:SetPos(0, contentY)
        self.content:SetSize(w, contentH)

        self:_layoutModernButtons()
    else
        local preferredWidth = math_min(self.classicTabWidth, math_max(112, math_floor(w * 0.4)))
        local barWidth = math_min(preferredWidth, w)
        local contentX = math_min(w, barWidth + self.tabGap)

        self._tabFrame:SetPos(0, 0)
        self._tabFrame:SetSize(barWidth, h)
        self.panelTabs:SetPos(6, 6)
        self.panelTabs:SetSize(math_max(0, barWidth - 12), math_max(0, h - 12))

        self.content:SetPos(contentX, 0)
        self.content:SetSize(math_max(0, w - contentX), h)

        self._indicatorDirty = true
    end

    self.panelTabs:InvalidateLayout(true)
    self.content:InvalidateLayout(true)

    if self._pendingTabScroll != nil then
        local initialScroll = self._pendingTabScroll
        self.panelTabs:SetScroll(initialScroll)
        self._pendingTabScroll = nil
        self._forceTabScrollReset = nil
        self._pendingEnsureActive = true
        self._skipEnsureAfterScrollRestore = true
    elseif self._forceTabScrollReset then
        self.panelTabs:SetScroll(0)
        self._forceTabScrollReset = nil
    end
end

vgui.Register('MantleTabs', PANEL, 'Panel')
