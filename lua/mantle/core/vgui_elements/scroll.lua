local PANEL = {}

PANEL.IsVertical = true

local function isDescendantOf(panel, of)
    while IsValid(panel) do
        if panel == of then return true end
        panel = panel:GetParent()
    end

    return false
end

function PANEL:Init()
    self.content = vgui.Create('Panel', self)
    self.content:SetMouseInputEnabled(true)

    self.MouseReleasedTime = 0

    self.padL, self.padT, self.padR, self.padB = 0, 0, 0, 0

    self.offset = 0
    self.vel = 0
    self.drag = false
    self.dragLast = 0
    self.lastInput = 0

    self.scrollStep = 200
    self.overscroll = 12
    self.overscrollThreshold = 6
    self.friction = 8
    self.spring = 5
    self.dragRes = 0.35

    self._needLayout = true
    self._springing = false
    self._springTarget = 0

    self:SetMouseInputEnabled(true)
end

function PANEL:DockPadding(l, t, r, b)
    self.padL, self.padT, self.padR, self.padB = l or 0, t or 0, r or 0, b or 0
    self:_markDirty()
end

function PANEL:_markDirty()
    self._needLayout = true
end

function PANEL:GetCanvas()
    return self.content
end

function PANEL:_isInternal(child)
    return child == self.content
end

function PANEL:_sizeCanvas() end

function PANEL:_hookSize(pnl)
    local old = pnl.OnSizeChanged
    pnl.OnSizeChanged = function(...)
        if old then old(...) end
        if IsValid(self) then
            self:_markDirty()
            self:InvalidateLayout(true)
            self.content:InvalidateLayout(true)
            self:_sizeCanvas()
        end
    end
end

function PANEL:AddItem(pnl)
    pnl:SetParent(self.content)
    self:_hookSize(pnl)
    self:_markDirty()
    return pnl
end

function PANEL:Add(pnl)
    return self:AddItem(pnl)
end

function PANEL:OnChildAdded(child)
    timer.Simple(0, function()
        if !IsValid(child) or !IsValid(self) then return end
        if self:_isInternal(child) then return end
        if child:GetParent() == self then
            child:SetParent(self.content)
            self:_hookSize(child)
            self:_markDirty()
        end
    end)
end

function PANEL:Clear()
    for _, c in ipairs(self.content:GetChildren()) do c:Remove() end
    self.offset = 0
    self.vel = 0
    self:_markDirty()
end

function PANEL:SetScroll(x)
    self.offset = x or 0
end

function PANEL:GetScroll()
    return self.offset
end

function PANEL:_range()
    return 0, 0, 0
end

function PANEL:_applyScroll() end

function PANEL:_afterScroll(ft, maxScroll, viewSize, contentSize) end

function PANEL:_nudge(px)
    self.vel = self.vel + px * 10
    self.lastInput = CurTime()
end

function PANEL:OnMouseWheeled(delta)
    local _, _, contentSize = self:_range()
    if contentSize <= 0 then return end

    self._springing = false
    self.vel = self.vel - delta * self.scrollStep
    self.lastInput = CurTime()
    return true
end

function PANEL:OnMousePressed(mc)
    if mc != MOUSE_LEFT then return end
    if self.MouseReleasedTime + 0.3 > CurTime() then return end

    local hovered = vgui.GetHoveredPanel()
    if IsValid(hovered) and hovered != self and isDescendantOf(hovered, self.content) then return end

    self.drag = true
    self.dragLast = select(self.IsVertical and 2 or 1, self:CursorPos())
    self.vel = 0
    self.lastInput = CurTime()
    self:MouseCapture(true)

    self._springing = false
end

function PANEL:OnMouseReleased(mc)
    if mc != MOUSE_LEFT then return end

    self.drag = false
    self:MouseCapture(false)

    self:_checkOverscroll(select(1, self:_range()) or 0)
    self.MouseReleasedTime = CurTime()
end

function PANEL:OnCursorMoved(x, y)
    if !self.drag then return end

    local pos = self.IsVertical and y or x
    local d = pos - self.dragLast
    self.dragLast = pos

    local maxScroll = self:_range()
    local next = self.offset - d
    if next < 0 or next > maxScroll then
        self.offset = self.offset - d * self.dragRes
    else
        self.offset = next
    end

    self.lastInput = CurTime()
end

function PANEL:PerformLayout(w, h)
    self:_markDirty()
end

function PANEL:_startSpring(target)
    self._springing = true
    self._springTarget = target
    self.vel = 0
end

function PANEL:_checkOverscroll(maxScroll)
    local extraLo = math.max(0, -self.offset)
    local extraHi = math.max(0, self.offset - maxScroll)

    if extraLo > self.overscrollThreshold then
        self:_startSpring(0)
    elseif extraHi > self.overscrollThreshold then
        self:_startSpring(maxScroll)
    end
end

function PANEL:Think()
    local ft = FrameTime()
    local maxScroll, viewSize, contentSize = self:_range()

    if self._springing and CurTime() - self.lastInput < 0.02 then
        self._springing = false
    end

    if self._springing then
        local t = math.min(1, ft * self.spring)
        self.offset = Lerp(t, self.offset, self._springTarget)
        self.vel = 0

        if math.abs(self.offset - self._springTarget) < 0.5 then
            self.offset = self._springTarget
            self._springing = false
        end
    elseif !self.drag then
        self.offset = self.offset + self.vel * ft

        if self.offset < -self.overscroll then
            self.offset = -self.overscroll
            self.vel = 0
        elseif self.offset > maxScroll + self.overscroll then
            self.offset = maxScroll + self.overscroll
            self.vel = 0
        else
            self.vel = self.vel * math.max(0, 1 - ft * self.friction)
            if math.abs(self.vel) < 2 then self.vel = 0 end
        end

        if CurTime() - self.lastInput > 0.09 and self.vel == 0 then
            self:_checkOverscroll(maxScroll)
        end
    end

    self:_applyScroll()
    self:_afterScroll(ft, maxScroll, viewSize, contentSize)
end

vgui.Register('MantleScroll', PANEL, 'EditablePanel')