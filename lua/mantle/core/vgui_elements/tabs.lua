local PANEL = {}

local math_max = math.max
local math_min = math.min
local math_floor = math.floor

local function getTabButton(self, tabId)
    local tab = self.tabs[tabId]
    return tab and tab._btn or nil
end

local function colorAlpha(color, alpha)
    if !color then return Color(255, 255, 255, math_floor(alpha)) end

    return Color(color.r, color.g, color.b, math_floor(math.Clamp(alpha, 0, 255)))
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
        local theme = Mantle.color.theme
        local border = Mantle.color.gray or Mantle.color.icon

        if self.tabStyle == 'modern' then
            RNDX.Rect(0, 0, w, h)
                :Rad(13)
                :Color(Mantle.color.window_shadow)
            :Draw()

            RNDX.Rect(0, 0, w, h)
                :Rad(13)
                :Color(colorAlpha(border, 82))
                :Outline(1)
            :Draw()
        else
            RNDX.Rect(0, 0, w, h)
                :Rad(14)
                :Color(Mantle.color.window_shadow)
            :Draw()

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

    bar:DockPadding(0, 0, 0, 0)
    bar.Paint = function() end
    bar.PaintOver = nil

    self._tabFrame = frame
    self.panelTabs = bar
    self._pendingTabScroll = self._savedTabScroll[self.tabStyle] or 0
    self._forceTabScrollReset = self._pendingTabScroll == 0
end

function PANEL:_syncPanels()
    for id, tab in ipairs(self.tabs) do
        if IsValid(tab.pan) then
            tab.pan:SetVisible(id == self.activeId)
        end
    end
end

function PANEL:_resetTabAnimation()
    for _, tab in ipairs(self.tabs) do
        tab._hover = 0
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

    self.panelTabs:AddItem(btn)

    if self.tabStyle == 'modern' then
        btn:Dock(LEFT)
        btn:DockMargin(0, 0, self.segmentGap, 0)
        btn:SetTall(math_max(24, self.tabHeight - 4))
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
        local isActive = self.activeId == id
        local hoverAlpha = tab._hover or 0
        local theme = Mantle.color.theme
        local textColor = isActive and theme or Mantle.color.text
        local iconColor = isActive and theme or Mantle.color.icon

        if self.tabStyle == 'modern' then
            local radius = 11

            if isActive then
                RNDX.Rect(0, 0, w, h)
                    :Rad(radius)
                    :Color(colorAlpha(theme, 15))
                :Draw()

                RNDX.Rect(0, 0, w, h)
                    :Rad(radius)
                    :Color(colorAlpha(theme, 220))
                    :Outline(self.indicatorHeight)
                :Draw()
            elseif hoverAlpha > 0.01 then
                local hover = Mantle.color.tab_hover
                RNDX.Rect(0, 0, w, h)
                    :Rad(radius)
                    :Color(colorAlpha(hover, hover.a * hoverAlpha))
                :Draw()
            end

            local iconW = tab.icon and 16 or 0
            local iconGap = tab.icon and 8 or 0
            local textW = 0
            surface.SetFont('Fated.16')
            textW = select(1, surface.GetTextSize(tab.title))

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
            if isActive then
                RNDX.Rect(0, 0, w, h)
                    :Rad(9)
                    :Color(Mantle.color.focus_panel)
                :Draw()

                RNDX.Rect(0, 0, w, h)
                    :Rad(9)
                    :Color(colorAlpha(theme, 14))
                    :Outline(1)
                :Draw()
            elseif hoverAlpha > 0.01 then
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
        local textWidth = select(1, surface.GetTextSize(tab.title))
        local iconWidth = tab.icon and 24 or 0
        local preferredWidth = math_max(72, math.ceil(textWidth + iconWidth + 28))

        preferredWidths[id] = preferredWidth
        totalPreferredWidth = totalPreferredWidth + preferredWidth
        maxPreferredWidth = math_max(maxPreferredWidth, preferredWidth)
    end

    local viewWidth = math_max(0, self.panelTabs:GetWide())
    local gapWidth = self.segmentGap * math_max(0, count - 1)
    local availableWidth = math_max(0, viewWidth - gapWidth)
    local widths = {}

    if maxPreferredWidth * count <= availableWidth then
        local baseWidth = math_floor(availableWidth / count)
        local remainder = availableWidth - baseWidth * count

        for id = 1, count do
            widths[id] = baseWidth + (id <= remainder and 1 or 0)
        end
    elseif totalPreferredWidth <= availableWidth then
        local extraWidth = (availableWidth - totalPreferredWidth) / count
        local usedWidth = 0

        for id = 1, count do
            widths[id] = math_floor(preferredWidths[id] + extraWidth)
            usedWidth = usedWidth + widths[id]
        end

        widths[count] = widths[count] + availableWidth - usedWidth
    else
        for id = 1, count do
            widths[id] = preferredWidths[id]
        end
    end

    local buttonHeight = math_max(24, self.panelTabs:GetTall())

    for id, tab in ipairs(self.tabs) do
        local btn = tab._btn
        if IsValid(btn) then
            btn:SetWide(widths[id])
            btn:SetTall(buttonHeight)
            btn:DockMargin(0, 0, id < count and self.segmentGap or 0, 0)
        end
    end

    if self.panelTabs._markDirty then
        self.panelTabs:_markDirty()
    end

    self.panelTabs:InvalidateLayout(true)
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
    local hoverSpeed = 26

    for _, tab in ipairs(self.tabs) do
        local btn = tab._btn
        local target = IsValid(btn) and btn:IsHovered() and 1 or 0
        tab._hover = Mantle.func.approachExp(tab._hover or 0, target, hoverSpeed, ft)
    end

    if self._pendingEnsureActive then
        self._pendingEnsureActive = false
        if self._skipEnsureAfterScrollRestore then
            self._skipEnsureAfterScrollRestore = false
        else
            self:_ensureTabVisible(self.activeId)
        end
    end

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
        _hover = 0
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

    local currentTab = self.tabs[self.activeId]
    if currentTab and IsValid(currentTab.pan) then
        currentTab.pan:SetVisible(false)
    end

    nextTab.pan:SetVisible(true)
    self.activeId = nextId

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
        local barHeight = math_min(self.tabHeight, h)
        local contentY = math_min(h, self.tabHeight + self.tabGap)

        self._tabFrame:SetPos(0, 0)
        self._tabFrame:SetSize(w, barHeight)
        self.panelTabs:SetPos(1, 1)
        self.panelTabs:SetSize(math_max(0, w - 2), math_max(0, barHeight - 2))

        self.content:SetPos(0, contentY)
        self.content:SetSize(w, math_max(0, h - contentY))

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
