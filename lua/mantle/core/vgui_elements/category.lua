local PANEL = {}

local math_max = math.max
local math_floor = math.floor
local math_abs = math.abs

local HEADER_HEIGHT = 30
local CONTENT_OFFSET = 36
local CONTENT_PADDING = 12
local ANIM_SNAP = 0.001
local COLOR_SNAP = 0.5

function PANEL:Init()
    self:DockMargin(8, 8, 8, 8)
    self:SetTall(HEADER_HEIGHT)

    self.name = Mantle.lang.get('mantle', 'category_default')
    self.opened = false
    self.centered = false
    self.headerColor = Mantle.color.category
    self.headerColorStandard = self.headerColor
    self.headerColorOpened = Mantle.color.category_opened

    self._anim = 0
    self._animTarget = 0
    self._animSpeed = 12
    self._childrenAlpha = -1
    self._contentTall = -1
    self._contentDirty = true
    self._childCount = 0
    self._contentVisible = false

    self.header = vgui.Create('Button', self)
    self.header:SetText('')
    self.header.Paint = function(_, w, h)
        RNDX.Rect(0, 0, w, h)
            :Rad(12)
            :Color(self.headerColor)
        :Draw()

        local posX = self.centered and w * 0.5 or 8
        local alignX = self.centered and TEXT_ALIGN_CENTER or TEXT_ALIGN_LEFT
        draw.SimpleText(self.name, 'Fated.20', posX, 4, Mantle.color.text, alignX)

        local target = self.opened and self.headerColorOpened or self.headerColorStandard
        local current = self.headerColor

        if current != target then
            if math_abs(current.r - target.r) < COLOR_SNAP
                and math_abs(current.g - target.g) < COLOR_SNAP
                and math_abs(current.b - target.b) < COLOR_SNAP
                and math_abs(current.a - target.a) < COLOR_SNAP
            then
                self.headerColor = target
            else
                self.headerColor = Mantle.func.LerpColor(8, current, target)
            end
        end
    end
    self.header.DoClick = function()
        self.opened = !self.opened
        self._animTarget = self.opened and 1 or 0
    end

    self.content = vgui.Create('Panel', self)
    self.content:SetVisible(false)

    local contentChildAdded = self.content.OnChildAdded
    self.content.OnChildAdded = function(pnl, child)
        if contentChildAdded then contentChildAdded(pnl, child) end
        if !IsValid(self) or !IsValid(child) then return end
        self:_hookChild(child)
        self._contentDirty = true
        self._childCount = self._childCount + 1
    end

    local contentChildRemoved = self.content.OnChildRemoved
    self.content.OnChildRemoved = function(pnl, child)
        if contentChildRemoved then contentChildRemoved(pnl, child) end
        if !IsValid(self) then return end
        self._contentDirty = true
        self._childCount = math_max(0, self._childCount - 1)
    end
end

function PANEL:_hookChild(child)
    if !IsValid(child) or child == self.header or child == self.content then return end
    if child._mantleCatHook then return end
    child._mantleCatHook = true

    local old = child.OnSizeChanged
    child.OnSizeChanged = function(s, ...)
        if old then old(s, ...) end
        if IsValid(self) then self._contentDirty = true end
    end
end

function PANEL:SetText(name)
    self.name = name
end

function PANEL:SetCenterText(isCentered)
    self.centered = isCentered
end

function PANEL:SetColor(col)
    self.headerColorStandard = col
    if !self.opened then
        self.headerColor = self.headerColorStandard
    end
end

function PANEL:SetActive(isActive)
    isActive = tobool(isActive)
    if self.opened == isActive then return end
    self.opened = isActive
    self._animTarget = isActive and 1 or 0
    self.headerColor = isActive and self.headerColorOpened or self.headerColorStandard
end

function PANEL:IsActive()
    return self.opened
end

function PANEL:AddItem(panel)
    if !IsValid(panel) then return panel end
    if panel:GetParent() == self.content then
        self:_hookChild(panel)
        return panel
    end
    panel:SetParent(self.content)
    return panel
end

function PANEL:Clear()
    for _, c in ipairs(self.content:GetChildren()) do c:Remove() end
    self.opened = false
    self._animTarget = 0
end

function PANEL:OnChildAdded(child)
    timer.Simple(0, function()
        if !IsValid(child) or !IsValid(self) then return end
        if child == self.header or child == self.content then return end
        if child:GetParent() == self then
            child:SetParent(self.content)
        end
    end)
end

function PANEL:PerformLayout(w, h)
    self.header:SetPos(0, 0)
    self.header:SetSize(w, HEADER_HEIGHT)
    self.content:SetPos(0, CONTENT_OFFSET)
    self.content:SetWide(w)
end

function PANEL:_measureContent()
    local children = self.content:GetChildren()
    local total = 0
    for i = 1, #children do
        local c = children[i]
        if IsValid(c) then
            total = total + c:GetTall()
            local _, t, _, b = c:GetDockMargin()
            total = total + (t or 0) + (b or 0)
        end
    end
    return total
end

function PANEL:Think()
    local ft = FrameTime()

    if self._anim != self._animTarget then
        self._anim = Mantle.func.approachExp(self._anim, self._animTarget, self._animSpeed, ft)
        if math_abs(self._anim - self._animTarget) < ANIM_SNAP then
            self._anim = self._animTarget
        end
    end

    local anim = self._anim
    local eased

    if anim == 0 then
        eased = 0
    elseif anim == 1 then
        eased = 1
    else
        eased = Mantle.func.easeOutCubic(anim)
    end

    local contentTall = self._contentTall

    if self._contentDirty then
        contentTall = self:_measureContent()
        self._contentDirty = false

        if contentTall != self._contentTall then
            self._contentTall = contentTall
            self.content:SetTall(math_max(0, contentTall))
        end
    elseif contentTall < 0 then
        contentTall = 0
    end

    local targetTall = math_max(HEADER_HEIGHT, math_floor(HEADER_HEIGHT + (contentTall + CONTENT_PADDING) * eased + 0.5))
    if self:GetTall() != targetTall then
        self:SetTall(targetTall)
    end

    local alphaVal = math_floor(255 * eased + 0.5)
    if alphaVal != self._childrenAlpha then
        self._childrenAlpha = alphaVal
        self.content:SetAlpha(alphaVal)
    end

    local visible = eased >= 0.004
    if visible != self._contentVisible then
        self._contentVisible = visible
        self.content:SetVisible(visible)
    end
end

vgui.Register('MantleCategory', PANEL, 'Panel')
