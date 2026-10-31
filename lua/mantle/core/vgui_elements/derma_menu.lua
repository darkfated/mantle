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
local HOVER_MARGIN = PAD + ITEM_GAP
local BOTTOM_PAD = PAD + ITEM_GAP
local MAX_SCREEN_FRAC = 0.8
local SUBMENU_DELAY = 0.15

local function isPointInside(pnl, x, y)
    if !IsValid(pnl) or !pnl:IsVisible() then return false end

    local px, py = pnl:LocalToScreen(0, 0)
    local w, h = pnl:GetSize()

    return x >= px and y >= py and x < px + w and y < py + h
end

local function isCursorOverMenuTree(menu, x, y)
    if !IsValid(menu) or !menu:IsVisible() then return false end
    if isPointInside(menu, x, y) then return true end

    for _, item in ipairs(menu.Items or {}) do
        if IsValid(item) and IsValid(item._submenu) and item._submenu:IsVisible() then
            if isCursorOverMenuTree(item._submenu, x, y) then
                return true
            end
        end
    end

    return false
end

local function getRootMenu(menu)
    while IsValid(menu) and IsValid(menu._parentMenu) do
        menu = menu._parentMenu
    end

    return menu
end

local function scheduleSubMenuClose(option, submenu)
    timer.Simple(SUBMENU_DELAY, function()
        if !IsValid(option) or !IsValid(submenu) then return end

        local x, y = input.GetCursorPos()
        if isPointInside(option, x, y) or isCursorOverMenuTree(submenu, x, y) then return end

        option:CloseSubMenu()
    end)
end

function PANEL:Init()
    self.Items = {}
    self.MaxTextWidth = 0

    self:SetSize(MIN_WIDTH, PAD + BOTTOM_PAD)
    self:DockPadding(PAD, PAD, PAD, BOTTOM_PAD)
    self:SetDrawOnTop(true)
    self:MakePopup()
    self:SetKeyboardInputEnabled(false)
    self:SetMouseInputEnabled(true)

    self._anim = 0
    self._animTarget = 1
    self._animSpeed = 18
    self._closing = false
    self._disableBlur = false
    self._openTime = CurTime()
    self._waitingForMouseRelease = input.IsMouseDown(MOUSE_LEFT) or input.IsMouseDown(MOUSE_RIGHT)
    self._targetX = nil
    self._targetY = nil
    self._wantX = nil
    self._wantY = nil
    self._anchor = nil
    self._scrollToSelected = true
    self._lastAlpha = -1
    self:SetAlpha(0)

    self._hoverX = HOVER_MARGIN
    self._hoverY = PAD
    self._hoverW = 0
    self._hoverH = ITEM_HEIGHT
    self._hoverDrawY = PAD
    self._hoverDrawH = 0
    self._hoverA = 0

    self.scroll = vgui.Create('MantleScrollPanel', self)
    self.scroll:Dock(FILL)
    self.scroll:DockMargin(0, 0, 0, 0)
    self.scroll:SetMouseInputEnabled(true)
    self.scroll:GetCanvas():SetMouseInputEnabled(true)
    self.scroll.scrollStep = 160
    self.scroll.overscroll = 36
    self.scroll.overscrollThreshold = 20
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
        :Color(Color(bg.r, bg.g, bg.b, bg.a or 150))
    :Draw()

    if self._hoverA > 0.01 and self._hoverW > 0 and self._hoverDrawH > 0 then
        local hv = Mantle.color.button
        local alpha = math_floor((hv.a or 80) * self._hoverA)

        RNDX.Rect(self._hoverX, self._hoverDrawY, self._hoverW, self._hoverDrawH)
            :Rad(8)
            :Color(Color(hv.r, hv.g, hv.b, alpha))
        :Draw()
    end

    RNDX.Rect(0, 0, w, h)
        :Rad(RADIUS)
        :Color(Mantle.color.window_shadow)
        :Outline(1)
    :Draw()
end

function PANEL:AddOption(text, func, icon, optData)
    text = tostring(text or '')

    surface.SetFont('Fated.16')
    local textW = select(1, surface.GetTextSize(text))
    local itemTextW = textW + (icon and 24 or 0)
    self.MaxTextWidth = math_max(self.MaxTextWidth, itemTextW)

    local option = vgui.Create('Button', self.scroll:GetCanvas())
    option:SetText('')
    option:SetMouseInputEnabled(true)
    option:SetKeyboardInputEnabled(false)
    option:SetCursor('hand')
    option:SetPos(0, 0)
    option:SetSize(self.scroll:GetCanvas():GetWide(), ITEM_HEIGHT)
    option:SetZPos(#self.Items + 1)
    option.sumTall = ITEM_HEIGHT + ITEM_GAP
    option.Text = text
    option._menu = self
    option._submenu = nil
    option._submenu_open = false

    if icon then
        option.matIcon = type(icon) == 'IMaterial' and icon or Material(icon)
    end

    if optData then
        for k, v in pairs(optData) do
            option[k] = v
        end
    end

    function option:AddSubMenu()
        if IsValid(self._submenu) then
            self._submenu:Remove()
        end

        local submenu = vgui.Create('MantleDermaMenu')
        if !IsValid(submenu) then return end

        submenu._parentMenu = self._menu
        submenu._parentItem = self
        submenu._owner = self._menu
        submenu:SetVisible(false)

        self._submenu = submenu
        self._submenu_open = false

        submenu.OnCursorExited = function()
            scheduleSubMenuClose(option, submenu)
        end

        local oldSubmenuOnRemove = submenu.OnRemove
        submenu.OnRemove = function(pnl)
            if oldSubmenuOnRemove then
                oldSubmenuOnRemove(pnl)
            end

            if IsValid(option) and option._submenu == submenu then
                option._submenu_open = false
            end
        end

        return submenu
    end

    function option:OpenSubMenu()
        local submenu = self._submenu
        if !IsValid(submenu) then return end
        if IsValid(self._menu) and self._menu._closing then return end

        local parentMenu = self._menu
        if !IsValid(parentMenu) or parentMenu._closing then return end

        for _, sibling in ipairs(parentMenu.Items) do
            if IsValid(sibling) and sibling != self and sibling.CloseSubMenu then
                sibling:CloseSubMenu()
            end
        end

        submenu:UpdateSize()

        local sw, sh = Mantle.func.sw, Mantle.func.sh
        local w, h = submenu:GetSize()
        local itemX, itemY = self:LocalToScreen(0, 0)
        local itemW = self:GetWide()

        local rightX = itemX + itemW + LIST_GAP
        local leftX = itemX - w - LIST_GAP
        local x, y

        if rightX + w <= sw - 5 then
            x = rightX
        elseif leftX >= 5 then
            x = leftX
        else
            local rightSpace = sw - 5 - rightX
            local leftSpace = itemX - 5

            if rightSpace >= leftSpace then
                x = math_clamp(rightX, 5, math_max(5, sw - 5 - w))
            else
                x = math_clamp(leftX, 5, math_max(5, sw - 5 - w))
            end
        end

        y = math_clamp(itemY - HOVER_MARGIN, 5, math_max(5, sh - 5 - h))

        submenu:OpenAt(x, y)
        self._submenu_open = true
    end

    function option:CloseSubMenu()
        self._submenu_open = false

        local submenu = self._submenu
        if !IsValid(submenu) then return end

        submenu:SetVisible(false)

        for _, item in ipairs(submenu.Items) do
            if IsValid(item) and item.CloseSubMenu then
                item:CloseSubMenu()
            end
        end
    end

    option.OnCursorEntered = function(pnl)
        if IsValid(pnl._submenu) and !pnl._submenu_open then
            pnl:OpenSubMenu()
        end
    end

    option.OnCursorExited = function(pnl)
        if IsValid(pnl._submenu) then
            scheduleSubMenuClose(pnl, pnl._submenu)
        end
    end

    local oldOptionOnRemove = option.OnRemove
    option.OnRemove = function(pnl)
        if oldOptionOnRemove then
            oldOptionOnRemove(pnl)
        end

        if IsValid(pnl._submenu) then
            pnl._submenu:Remove()
        end
    end

    option.DoClick = function()
        local submenu = option._submenu
        if IsValid(submenu) then
            if option._submenu_open then
                option:CloseSubMenu()
            else
                option:OpenSubMenu()
            end
            return
        end

        local rootMenu = getRootMenu(option._menu)

        if func then
            func()
        end

        Mantle.func.sound()

        if IsValid(rootMenu) then
            rootMenu:CloseMenu()
        end
    end

    option.Paint = function(pnl, w, h)
        local textX = 10 + (pnl.matIcon and 24 or 0)

        if pnl.matIcon then
            RNDX.Rect(8, 8, 16, 16)
                :Color(color_white)
                :Material(pnl.matIcon)
            :Draw()
        end

        local col = pnl.selected and Mantle.color.theme or Mantle.color.text
        draw.SimpleText(pnl.Text, 'Fated.16', textX, h * 0.5 - 1, col, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)

        if IsValid(pnl._submenu) then
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

    if option.selected then
        self._scrollToSelected = true
    end

    self:UpdateSize()

    return option
end

function PANEL:AddSpacer()
    local spacer = vgui.Create('Panel', self.scroll:GetCanvas())
    spacer:SetMouseInputEnabled(false)
    spacer:SetPos(6, 0)
    spacer:SetSize(math_max(0, self.scroll:GetCanvas():GetWide() - 12), 9)
    spacer:SetZPos(#self.Items + 1)
    spacer._menuSpacer = true
    spacer.sumTall = 9
    spacer.Paint = function(_, w, h)
        RNDX.Rect(0, 4, w, 1)
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
    self._waitingForMouseRelease = input.IsMouseDown(MOUSE_LEFT) or input.IsMouseDown(MOUSE_RIGHT)

    if first then
        self._anim = 0
        self:SetAlpha(0)
    end

    self:SetVisible(true)
    self:_setTarget(x, y)
    self:MakePopup()
    self:SetKeyboardInputEnabled(false)
    self:SetMouseInputEnabled(true)
end

function PANEL:_layoutItems()
    local canvas = self.scroll:GetCanvas()
    local canvasW = canvas:GetWide()
    local y = 0

    for _, item in ipairs(self.Items) do
        if IsValid(item) then
            if item._menuSpacer then
                item:SetPos(6, y)
                item:SetSize(math_max(0, canvasW - 12), 9)
            else
                item:SetPos(0, y + ITEM_GAP)
                item:SetSize(canvasW, ITEM_HEIGHT)
            end

            y = y + (item.sumTall or item:GetTall())
        end
    end

    canvas:SetTall(y)
end

function PANEL:UpdateSize()
    local contentH = 0

    for _, item in ipairs(self.Items) do
        if IsValid(item) then
            contentH = contentH + (item.sumTall or item:GetTall())
        end
    end

    local maxH = math_max(1, math_floor(Mantle.func.sh * MAX_SCREEN_FRAC))
    local height = math_min(PAD + BOTTOM_PAD + contentH, maxH)
    local scrollable = contentH > height - PAD - BOTTOM_PAD
    local reserve = scrollable and (self.scroll.vbarReserveWidth + self.scroll._vbarPadRight) or 0

    local width = math_max(MIN_WIDTH, self.MaxTextWidth + TEXT_PAD + reserve)
    width = math_min(width, math_max(1, Mantle.func.sw - 10))

    self:SetSize(width, height)
    self:InvalidateLayout(true)
    self.scroll:_markDirty()
    self.scroll:InvalidateLayout(true)
    self.scroll:_range()
    self:_layoutItems()
    self.scroll:_markDirty()
    self.scroll:_range()
    self:_layoutItems()
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
    elseif self._wantX != nil then
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
    local mouseX, mouseY = input.GetCursorPos()
    if !isPointInside(self.scroll, mouseX, mouseY) then return end

    for _, item in ipairs(self.Items) do
        if IsValid(item) then
            if item.Text != nil and isPointInside(item, mouseX, mouseY) then
                return item
            end

            if IsValid(item._submenu) and item._submenu:IsVisible() and isCursorOverMenuTree(item._submenu, mouseX, mouseY) then
                return item
            end
        end
    end
end

function PANEL:_updateHover(ft)
    local hovered = self:_findHoveredItem()

    local scrollX, scrollY = self.scroll:LocalToScreen(0, 0)
    local _, clipY = self:ScreenToLocal(scrollX, scrollY)
    local clipBottom = clipY + self.scroll:GetTall()

    if IsValid(hovered) then
        local _, itemScreenY = hovered:LocalToScreen(0, 0)
        local _, targetY = self:ScreenToLocal(0, itemScreenY)
        local targetW = math_max(0, self:GetWide() - HOVER_MARGIN * 2)

        self._hoverA = Mantle.func.approachExp(self._hoverA, 1, 30, ft)
        self._hoverX = HOVER_MARGIN
        self._hoverY = Mantle.func.approachExp(self._hoverY, targetY, 26, ft)
        self._hoverW = targetW
        self._hoverH = ITEM_HEIGHT
    else
        self._hoverA = Mantle.func.approachExp(self._hoverA, 0, 20, ft)
    end

    local top = math_max(self._hoverY, clipY)
    local bottom = math_min(self._hoverY + ITEM_HEIGHT, clipBottom)
    self._hoverDrawY = top
    self._hoverDrawH = math_max(0, bottom - top)
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

    local viewH = self.scroll:GetTall()
    local maxScroll = contentH - viewH
    if maxScroll <= 0 then return end

    self.scroll.offset = math_clamp(selectedY - (viewH - selectedH) * 0.5, 0, maxScroll)
    self.scroll.vel = 0
    self.scroll:_markDirty()
end

function PANEL:CloseMenu()
    if self._closing then return end

    self._closing = true
    self._disableBlur = true
    self._animTarget = 0

    for _, item in ipairs(self.Items) do
        if IsValid(item) and item.CloseSubMenu then
            item:CloseSubMenu()
        end
    end
end

function PANEL:Think()
    if !self:IsVisible() then return end

    local ft = FrameTime()

    if !self._targetX then
        local x, y = self:GetPos()
        self:_setTarget(x, y)
    end

    local mouseLeftDown = input.IsMouseDown(MOUSE_LEFT)
    local mouseRightDown = input.IsMouseDown(MOUSE_RIGHT)

    if self._waitingForMouseRelease then
        if !mouseLeftDown and !mouseRightDown then
            self._waitingForMouseRelease = false
        end
    elseif !self._closing and CurTime() - self._openTime >= 0.08 and (mouseLeftDown or mouseRightDown) then
        local mouseX, mouseY = input.GetCursorPos()
        local overMenu = isCursorOverMenuTree(self, mouseX, mouseY)
        local overOwner = IsValid(self._owner) and isPointInside(self._owner, mouseX, mouseY)

        if !overMenu and !overOwner then
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

function PANEL:OnRemove()
    for _, item in ipairs(self.Items or {}) do
        if IsValid(item) and IsValid(item._submenu) then
            item._submenu:Remove()
        end
    end
end

vgui.Register('MantleDermaMenu', PANEL, 'EditablePanel')

function Mantle.ui.derma_menu()
    if IsValid(Mantle.ui.menu_derma_menu) then
        Mantle.ui.menu_derma_menu:Remove()
    end

    local x, y = input.GetCursorPos()
    local menu = vgui.Create('MantleDermaMenu')
    menu:OpenAt(x, y)

    Mantle.ui.menu_derma_menu = menu
    return menu
end
