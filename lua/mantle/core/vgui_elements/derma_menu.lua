local PANEL = {}

local math_max = math.max
local math_min = math.min
local math_floor = math.floor
local math_clamp = math.Clamp

local PAD = 6
local ITEM_HEIGHT = 32
local ITEM_GAP = 2
local RADIUS = 14
local MIN_WIDTH = 160
local TEXT_PAD = 56
local LIST_GAP = 4
local MAX_SCREEN_FRAC = 0.8
local SUBMENU_DELAY = 0.15

local function isHoveredTree(pnl)
    if !IsValid(pnl) then return false end

    local hovered = vgui.GetHoveredPanel()
    if !IsValid(hovered) then return false end

    return hovered == pnl or hovered:HasParent(pnl)
end

function PANEL:Init()
    self.Items = {}
    self.MaxTextWidth = 0

    self:SetSize(MIN_WIDTH, PAD * 2)
    self:DockPadding(PAD, PAD, PAD, PAD)
    self:SetKeyboardInputEnabled(false)
    self:SetDrawOnTop(true)
    self:MakePopup()

    self._anim = 0
    self._animTarget = 1
    self._animSpeed = 18
    self._closing = false
    self._disableBlur = false
    self._openTime = CurTime()
    self._targetX = nil
    self._targetY = nil
    self._scrollToSelected = true
    self._lastAlpha = -1
    self:SetAlpha(0)

    self._hoverX, self._hoverY = 0, 0
    self._hoverW, self._hoverH = 0, 0
    self._hoverA = 0

    self.scroll = vgui.Create('MantleScrollPanel', self)
    self.scroll:Dock(FILL)
    self.scroll:DockMargin(0, 0, 0, 0)
    self.scroll.scrollStep = 160
    self.scroll.overscroll = 36
    self.scroll.overscrollThreshold = 20

    self._hoverBar = vgui.Create('Panel', self.scroll:GetCanvas())
    self._hoverBar:SetMouseInputEnabled(false)
    self._hoverBar.Paint = function(_, w, h)
        local a = self._hoverA
        if a <= 0.01 then return end

        local hv = Mantle.color.hover_overlay_strong
        RNDX.Rect(0, 0, w, h)
            :Rad(8)
            :Color(Color(hv.r, hv.g, hv.b, math_floor(hv.a * a)))
        :Draw()
    end
end

function PANEL:Paint(w, h)
    if !self._disableBlur then
        RNDX.Rect(0, 0, w, h)
            :Rad(RADIUS)
            :KBlur(4, 2)
        :Draw()
    end

    local bg = Mantle.color.background_panelpopup
    RNDX.Rect(0, 0, w, h)
        :Rad(RADIUS)
        :Color(Color(bg.r, bg.g, bg.b, math_floor((bg.a or 150) * self._anim)))
    :Draw()

    RNDX.Rect(0, 0, w, h)
        :Rad(RADIUS)
        :Color(Mantle.color.window_shadow)
        :Outline(1)
    :Draw()
end

function PANEL:AddOption(text, func, icon, optData)
    surface.SetFont('Fated.16')
    local textW = select(1, surface.GetTextSize(text))
    self.MaxTextWidth = math_max(self.MaxTextWidth, textW)

    local option = vgui.Create('MantleBtn', self.scroll:GetCanvas())
    option:SetText('')
    option:Dock(TOP)
    option:DockMargin(0, ITEM_GAP, 0, 0)
    option:SetTall(ITEM_HEIGHT)
    option.sumTall = ITEM_HEIGHT + ITEM_GAP
    option.Text = text
    option._menu = self
    option._submenu = nil
    option._submenu_open = false

    if icon then
        option:SetIcon(icon)
        self.MaxTextWidth = self.MaxTextWidth + 26
    end

    if optData then
        for k, v in pairs(optData) do
            option[k] = v
        end
    end

    local submenu

    function option:AddSubMenu()
        if IsValid(submenu) then submenu:Remove() end

        submenu = vgui.Create('MantleDermaMenu')
        submenu._parentMenu = self._menu
        submenu._parentItem = self
        submenu._owner = self
        submenu:SetVisible(false)

        option._submenu = submenu
        option._submenu_open = false

        self.OnRemove = function()
            if IsValid(submenu) then submenu:Remove() end
        end

        submenu.OnCursorExited = function()
            timer.Simple(SUBMENU_DELAY, function()
                if !IsValid(option) or !IsValid(submenu) then return end
                if isHoveredTree(option) or isHoveredTree(submenu) then return end
                option:CloseSubMenu()
            end)
        end

        return submenu
    end

    function option:OpenSubMenu()
        if !IsValid(submenu) then return end

        for _, sibling in ipairs(self._menu.Items) do
            if sibling != self and sibling.CloseSubMenu then sibling:CloseSubMenu() end
        end

        submenu:UpdateSize()

        local sw, sh = Mantle.func.sw, Mantle.func.sh
        local w, h = submenu:GetSize()
        local x, y = self:LocalToScreen(self:GetWide() - LIST_GAP, 0)

        if x + w > sw - 5 then
            x = select(1, self:LocalToScreen(0, 0)) - w + LIST_GAP
        end

        if y + h > sh - 5 then
            y = sh - 5 - h
        end

        submenu:OpenAt(x, y)
        self._submenu_open = true
    end

    function option:CloseSubMenu()
        self._submenu_open = false

        if !IsValid(submenu) then return end

        submenu:SetVisible(false)
        for _, item in ipairs(submenu.Items) do
            if item.CloseSubMenu then item:CloseSubMenu() end
        end
    end

    option.OnCursorEntered = function(pnl)
        if IsValid(submenu) and !pnl._submenu_open then
            pnl:OpenSubMenu()
        end
    end

    option.OnCursorExited = function()
        if !IsValid(submenu) then return end

        timer.Simple(SUBMENU_DELAY, function()
            if !IsValid(option) or !IsValid(submenu) then return end
            if isHoveredTree(option) or isHoveredTree(submenu) then return end
            option:CloseSubMenu()
        end)
    end

    option.DoClick = function()
        if IsValid(submenu) then
            if option._submenu_open then
                option:CloseSubMenu()
            else
                option:OpenSubMenu()
            end
            return
        end

        if func then func() end

        Mantle.func.sound()

        local menu = option._menu
        while IsValid(menu._parentMenu) do
            menu = menu._parentMenu
        end
        menu:CloseMenu()
    end

    option.Paint = function(pnl, w, h)
        local textX = 10 + (self.icon != '' and 24 or 0)
        local col = pnl.selected and Mantle.color.theme or Mantle.color.text
        draw.SimpleText(pnl.Text, 'Fated.16', textX, h * 0.5 - 1, col, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)

        if pnl._submenu then
            local s = 4
            local cx = w - 14
            local cy = h * 0.5

            surface.SetDrawColor(Mantle.color.gray)
            draw.NoTexture()
            surface.DrawPoly({
                {x = cx - s * 0.7, y = cy - s},
                {x = cx - s * 0.7, y = cy + s},
                {x = cx + s * 0.7, y = cy}
            })
        end
    end

    table.insert(self.Items, option)
    self.scroll:_markDirty()
    self:UpdateSize()

    return option
end

function PANEL:AddSpacer()
    local spacer = vgui.Create('Panel', self.scroll:GetCanvas())
    spacer:SetMouseInputEnabled(false)
    spacer:Dock(TOP)
    spacer:DockMargin(6, 4, 6, 4)
    spacer:SetTall(1)
    spacer.sumTall = 9
    spacer.Paint = function(_, w, h)
        RNDX.Rect(0, 0, w, h)
            :Color(Mantle.color.window_shadow)
        :Draw()
    end

    table.insert(self.Items, spacer)
    self.scroll:_markDirty()
    self:UpdateSize()

    return spacer
end

function PANEL:SetAnchor(pnl)
    self._anchor = pnl
    self:_updateAnchor()
    return self
end

function PANEL:OpenAt(x, y)
    local first = self._anim <= 0.01

    self._animTarget = 1
    self._closing = false
    self._disableBlur = false
    self._lastAlpha = -1
    self._openTime = CurTime()

    if first then
        self._anim = 0
        self:SetAlpha(0)
    end

    self:SetVisible(true)
    self:_setTarget(x, y)
    self:MakePopup()
end

function PANEL:UpdateSize()
    local contentH = 0
    for _, item in ipairs(self.Items) do
        if IsValid(item) then
            contentH = contentH + (item.sumTall or item:GetTall())
        end
    end

    local maxH = math_floor(Mantle.func.sh * MAX_SCREEN_FRAC)
    local height = math_min(PAD * 2 + contentH, maxH)
    local scrollable = contentH > height - PAD * 2
    local reserve = scrollable and (self.scroll.vbarReserveWidth + self.scroll._vbarPadRight) or 0

    local width = math_max(MIN_WIDTH, self.MaxTextWidth + TEXT_PAD + reserve)
    width = math_min(width, Mantle.func.sw - 10)

    self:SetSize(width, height)
    self:_updatePosition()
end

function PANEL:_setTarget(x, y)
    self._wantX, self._wantY = x, y

    local w, h = self:GetSize()
    local sw, sh = Mantle.func.sw, Mantle.func.sh

    self._targetX = math_clamp(x, 5, math_max(5, sw - 5 - w))
    self._targetY = math_clamp(y, 5, math_max(5, sh - 5 - h))
end

function PANEL:_updatePosition()
    if IsValid(self._anchor) then
        self:_updateAnchor()
    elseif self._wantX then
        self:_setTarget(self._wantX, self._wantY)
    else
        local x, y = self:GetPos()
        self:_setTarget(x, y)
    end
end

function PANEL:_updateAnchor()
    local anchor = self._anchor
    if !IsValid(anchor) then return end

    local ax, ay = anchor:LocalToScreen(0, 0)
    local _, ah = anchor:GetSize()
    local _, h = self:GetSize()
    local sh = Mantle.func.sh

    local y = ay + ah + LIST_GAP

    if y + h > sh - 5 and ay - LIST_GAP - h >= 5 then
        y = ay - LIST_GAP - h
    end

    self:_setTarget(ax, y)
end

function PANEL:_findHoveredItem()
    local hovered = vgui.GetHoveredPanel()

    if IsValid(hovered) then
        for _, item in ipairs(self.Items) do
            if item == hovered and item.Text != nil then return item end
            if IsValid(item._submenu) and isHoveredTree(item._submenu) then return item end
        end
    end

    if IsValid(self._parentItem) and self._parentItem._submenu_open and self._parentItem._submenu == self then
        for _, item in ipairs(self.Items) do
            if item.Text != nil then return item end
        end
    end
end

function PANEL:_updateHover(ft)
    local hovered = self:_findHoveredItem()

    if IsValid(hovered) then
        local speed = 30
        self._hoverA = Mantle.func.approachExp(self._hoverA, 1, speed, ft)
        self._hoverX = Mantle.func.approachExp(self._hoverX, hovered:GetX() + 3, speed, ft)
        self._hoverY = Mantle.func.approachExp(self._hoverY, hovered:GetY(), speed, ft)
        self._hoverW = Mantle.func.approachExp(self._hoverW, hovered:GetWide() - 6, speed, ft)
        self._hoverH = Mantle.func.approachExp(self._hoverH, hovered:GetTall(), speed, ft)
    else
        self._hoverA = Mantle.func.approachExp(self._hoverA, 0, 20, ft)
    end

    self._hoverBar:SetPos(self._hoverX, self._hoverY)
    self._hoverBar:SetSize(self._hoverW, self._hoverH)
end

function PANEL:_hasHoveredSubmenu()
    for _, item in ipairs(self.Items) do
        local submenu = item._submenu
        if IsValid(submenu) and submenu:IsVisible() and (isHoveredTree(submenu) or submenu:_hasHoveredSubmenu()) then
            return true
        end
    end

    return false
end

function PANEL:_scrollToSelection()
    if !self._scrollToSelected then return end

    local contentH = 0
    local selectedY, selectedH

    for _, item in ipairs(self.Items) do
        if IsValid(item) then
            local tall = item.sumTall or item:GetTall()
            if item.selected then
                selectedY, selectedH = contentH, tall
            end
            contentH = contentH + tall
        end
    end

    self._scrollToSelected = false

    if !selectedY then return end

    local viewH = self:GetTall() - PAD * 2
    local maxScroll = contentH - viewH

    if maxScroll <= 0 then return end

    self.scroll.offset = math_clamp(selectedY - (viewH - selectedH) * 0.5, 0, maxScroll)
    self.scroll.vel = 0
end

function PANEL:CloseMenu()
    if self._closing then return end

    self._closing = true
    self._disableBlur = true
    self._animTarget = 0

    for _, item in ipairs(self.Items) do
        if item.CloseSubMenu then item:CloseSubMenu() end
    end
end

function PANEL:Think()
    if !self:IsVisible() then return end

    local ft = FrameTime()

    if !self._targetX then
        local x, y = self:GetPos()
        self:_setTarget(x, y)
    end

    if !self._closing and CurTime() - self._openTime >= 0.08 then
        local overOwner = IsValid(self._owner) and (self._owner:IsHovered() or self._owner:IsChildHovered())
        if (input.IsMouseDown(MOUSE_LEFT) or input.IsMouseDown(MOUSE_RIGHT))
            and !isHoveredTree(self)
            and !self:_hasHoveredSubmenu()
            and !overOwner
        then
            self:CloseMenu()
        end
    end

    if self._scrollToSelected then
        self:_scrollToSelection()
    end

    self:_updateHover(ft)

    self._anim = Mantle.func.approachExp(self._anim, self._animTarget, self._animSpeed, ft)
    self:SetPos(self._targetX, self._targetY + LIST_GAP * (1 - self._anim))

    local alpha = math_floor(255 * self._anim + 0.5)
    if alpha != self._lastAlpha then
        self._lastAlpha = alpha
        self:SetAlpha(alpha)
    end

    if self._closing and self._anim <= 0.005 then
        self:Remove()
    end
end

vgui.Register('MantleDermaMenu', PANEL, 'Panel')

function Mantle.ui.derma_menu()
    if IsValid(Mantle.ui.menu_derma_menu) then
        Mantle.ui.menu_derma_menu:Remove()
    end

    local x, y = input.GetCursorPos()
    local menu = vgui.Create('MantleDermaMenu')
    menu:_setTarget(x, y)

    Mantle.ui.menu_derma_menu = menu
    return menu
end
