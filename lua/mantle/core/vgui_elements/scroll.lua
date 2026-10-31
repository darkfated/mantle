local PANEL = {}

local math_max = math.max
local math_min = math.min
local math_abs = math.abs
local math_exp = math.exp
local math_sqrt = math.sqrt
local math_ceil = math.ceil
local math_clamp = math.Clamp

PANEL.IsVertical = true

function PANEL:Init()
    self:DockMargin(8, 8, 8, 8)

    self.content = vgui.Create('Panel', self)
    self.content:SetMouseInputEnabled(true)
    self.content.OnMousePressed = function(_, mc)
        self:OnMousePressed(mc)
    end
    self.content.OnMouseWheeled = function(_, delta)
        return self:OnMouseWheeled(delta)
    end

    local contentChildAdded = self.content.OnChildAdded
    self.content.OnChildAdded = function(pnl, child)
        if contentChildAdded then contentChildAdded(pnl, child) end
        if !IsValid(self) or !IsValid(child) then return end
        self:_hookSize(child)
        self:_hookWheel(child)
        self:_markDirty()
    end

    local contentChildRemoved = self.content.OnChildRemoved
    self.content.OnChildRemoved = function(pnl, child)
        if contentChildRemoved then contentChildRemoved(pnl, child) end
        if IsValid(self) then self:_markDirty() end
    end

    self.padL, self.padT, self.padR, self.padB = 0, 0, 0, 0

    self.offset = 0
    self.vel = 0
    self.drag = false
    self.dragLast = 0
    self.lastInput = 0

    self.scrollStep = 500
    self.deceleration = 4.6
    self.maxVelocity = 6000
    self.overscroll = 80
    self.rubberBandStrength = 0.55
    self.springStiffness = 190
    self.springDamping = 25.4
    self.dragVelocityDamping = 0.7

    self._needLayout = true
    self._pendingScroll = false
    self._springing = false
    self._springTarget = 0
    self._springVelocity = 0
    self._dragRaw = 0
    self._dragVelocity = 0
    self._dragLastTime = 0

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
    if pnl._mantleScrollSizeOwner == self then return end

    local old = pnl.OnSizeChanged
    pnl._mantleScrollSizeOwner = self
    pnl.OnSizeChanged = function(s, ...)
        if old then old(s, ...) end
        if IsValid(self) then
            self:_markDirty()
        end
    end
end

function PANEL:_hookWheel(pnl)
    if pnl._mantleScrollWheelOwner == self then return end

    local old = pnl.OnMouseWheeled
    pnl._mantleScrollWheelOwner = self
    pnl.OnMouseWheeled = function(s, delta)
        if old then
            local handled = old(s, delta)
            if handled then return handled end
        end

        if !IsValid(self) then return end
        return self:OnMouseWheeled(delta)
    end
end

function PANEL:AddItem(pnl)
    if !IsValid(pnl) then return end

    pnl:SetParent(self.content)
    self:_hookSize(pnl)
    self:_hookWheel(pnl)
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
        if child:GetParent() != self then return end

        child:SetParent(self.content)
        self:_hookSize(child)
        self:_hookWheel(child)
        self:_markDirty()
    end)
end

function PANEL:Clear()
    if self.drag then self:MouseCapture(false) end

    for _, child in ipairs(self.content:GetChildren()) do
        child:Remove()
    end

    self.offset = 0
    self.vel = 0
    self.drag = false
    self._dragVelocity = 0
    self._springing = false
    self._springVelocity = 0
    self._pendingScroll = false
    self:_markDirty()
end

function PANEL:SetScroll(value)
    if self.drag then self:MouseCapture(false) end

    self.offset = math_max(0, tonumber(value) or 0)
    self.vel = 0
    self.drag = false
    self._dragVelocity = 0
    self._springing = false
    self._springVelocity = 0
    self._pendingScroll = true
    self.lastInput = CurTime()

    local maxScroll, viewSize = self:_range()
    if viewSize > 0 then
        self.offset = math_clamp(self.offset, 0, maxScroll)
        self._pendingScroll = false
        self:_applyScroll()
    end
end

function PANEL:GetScroll()
    return self.offset
end

function PANEL:_range()
    return 0, 0, 0
end

function PANEL:_applyScroll() end

function PANEL:_afterScroll(ft, maxScroll, viewSize, contentSize) end

function PANEL:_rubberBand(distance, viewSize)
    local limit = math_max(0, self.overscroll or 0)
    if distance <= 0 or limit <= 0 then return 0 end

    local size = math_max(1, viewSize)
    local scaled = distance * (self.rubberBandStrength or 0.55)
    local resisted = size * (1 - 1 / (scaled / size + 1))

    return math_min(resisted, limit)
end

function PANEL:_resistedOffset(rawOffset, maxScroll, viewSize)
    if rawOffset < 0 then
        return -self:_rubberBand(-rawOffset, viewSize)
    end

    if rawOffset > maxScroll then
        return maxScroll + self:_rubberBand(rawOffset - maxScroll, viewSize)
    end

    return rawOffset
end

function PANEL:_startSpring(target, velocity)
    self._springing = true
    self._springTarget = target
    self._springVelocity = math_clamp(velocity or 0, -900, 900)
    self.vel = 0
end

function PANEL:_checkOverscroll(maxScroll)
    if self.offset < 0 then
        self:_startSpring(0)
    elseif self.offset > maxScroll then
        self:_startSpring(maxScroll)
    end
end

function PANEL:_syncBounds(maxScroll, viewSize)
    if self._pendingScroll and viewSize > 0 then
        self.offset = math_clamp(self.offset, 0, maxScroll)
        self._pendingScroll = false
    end

    if maxScroll <= 0 then
        if !self.drag then
            self.offset = 0
            self.vel = 0
            self._springing = false
            self._springVelocity = 0
        else
            self.offset = 0
            self._dragRaw = 0
        end
        return
    end

    if self.drag then return end

    if self._springing then
        self._springTarget = math_clamp(self._springTarget, 0, maxScroll)
        return
    end

    if self.offset < 0 then
        self:_startSpring(0)
    elseif self.offset > maxScroll then
        self:_startSpring(maxScroll)
    end
end

function PANEL:_stepSpring(ft)
    local stiffness = self.springStiffness or 190
    local damping = self.springDamping or (2 * math_sqrt(stiffness))
    local steps = math_max(1, math_ceil(ft / (1 / 120)))
    local step = ft / steps

    for i = 1, steps do
        local displacement = self.offset - self._springTarget
        local acceleration = -stiffness * displacement - damping * self._springVelocity

        self._springVelocity = self._springVelocity + acceleration * step
        self.offset = self.offset + self._springVelocity * step
    end

    if math_abs(self.offset - self._springTarget) < 0.35 and math_abs(self._springVelocity) < 3 then
        self.offset = self._springTarget
        self._springVelocity = 0
        self._springing = false
    end
end

function PANEL:_stepInertia(ft, maxScroll)
    local decay = math_exp(-self.deceleration * ft)
    local distance = self.vel * (1 - decay) / self.deceleration
    local nextOffset = self.offset + distance
    local nextVelocity = self.vel * decay

    if nextOffset < 0 then
        self.offset = math_max(-self.overscroll, nextOffset)
        self:_startSpring(0, nextVelocity)
        return
    elseif nextOffset > maxScroll then
        self.offset = math_min(maxScroll + self.overscroll, nextOffset)
        self:_startSpring(maxScroll, nextVelocity)
        return
    end

    self.offset = nextOffset
    self.vel = nextVelocity

    if math_abs(self.vel) < 5 then
        self.vel = 0
    end
end

function PANEL:_nudge(distance)
    local maxScroll, viewSize = self:_range()
    if maxScroll <= 0 then return end

    self.offset = math_clamp(self.offset, 0, maxScroll)
    self._springing = false
    self._springVelocity = 0
    self.vel = math_clamp(self.vel + (distance or 0) * 7, -self.maxVelocity, self.maxVelocity)
    self.lastInput = CurTime()
end

function PANEL:OnMouseWheeled(delta)
    if !delta or delta == 0 then return end

    local maxScroll = self:_range()
    if maxScroll <= 0 then return end

    if delta > 0 and self.offset <= 0 and self.vel <= 0 then return end
    if delta < 0 and self.offset >= maxScroll and self.vel >= 0 then return end

    self.offset = math_clamp(self.offset, 0, maxScroll)
    self._springing = false
    self._springVelocity = 0
    self.vel = math_clamp(self.vel - delta * self.scrollStep, -self.maxVelocity, self.maxVelocity)
    self.lastInput = CurTime()

    return true
end

function PANEL:OnMousePressed(mc)
    if mc != MOUSE_LEFT or self.drag then return end

    local hovered = vgui.GetHoveredPanel()
    if IsValid(hovered) and hovered != self and hovered != self.content then
        if Mantle.util.isDescendantOf(hovered, self.content) then return end
        if IsValid(self.vbar) and Mantle.util.isDescendantOf(hovered, self.vbar) then return end
    end

    local maxScroll, viewSize = self:_range()
    if maxScroll <= 0 or viewSize <= 0 then return end

    self.drag = true
    self.dragLast = select(self.IsVertical and 2 or 1, self:CursorPos())
    self._dragRaw = self.offset
    self._dragVelocity = 0
    self._dragLastTime = SysTime()
    self.vel = 0
    self._springing = false
    self._springVelocity = 0
    self.lastInput = CurTime()
    self:MouseCapture(true)
end

function PANEL:OnMouseReleased(mc)
    if mc != MOUSE_LEFT or !self.drag then return end

    self.drag = false
    self:MouseCapture(false)
    self.lastInput = CurTime()

    local maxScroll = self:_range()
    if self.offset < 0 then
        self:_startSpring(0)
    elseif self.offset > maxScroll then
        self:_startSpring(maxScroll)
    else
        self.vel = math_abs(self._dragVelocity) > 8 and self._dragVelocity or 0
    end

    self._dragVelocity = 0
end

function PANEL:OnCursorMoved(x, y)
    if !self.drag then return end

    local pos = self.IsVertical and y or x
    local delta = pos - self.dragLast
    self.dragLast = pos

    local maxScroll, viewSize = self:_range()
    local previousOffset = self.offset
    self._dragRaw = self._dragRaw - delta
    self.offset = self:_resistedOffset(self._dragRaw, maxScroll, viewSize)

    local now = SysTime()
    local dt = math_max(now - self._dragLastTime, 1 / 240)
    local instantVelocity = (self.offset - previousOffset) / dt
    self._dragVelocity = self._dragVelocity * self.dragVelocityDamping + instantVelocity * (1 - self.dragVelocityDamping)
    self._dragVelocity = math_clamp(self._dragVelocity, -self.maxVelocity, self.maxVelocity)
    self._dragLastTime = now
    self.lastInput = CurTime()

    self:_applyScroll()
end

function PANEL:PerformLayout(w, h)
    self:_markDirty()
end

function PANEL:Think()
    local ft = math_min(FrameTime(), 0.05)
    local maxScroll, viewSize, contentSize = self:_range()

    self:_syncBounds(maxScroll, viewSize)

    if !self.drag then
        if self._springing then
            self:_stepSpring(ft)
        elseif self.vel != 0 then
            self:_stepInertia(ft, maxScroll)
        end
    end

    self:_applyScroll()
    self:_afterScroll(ft, maxScroll, viewSize, contentSize)
end

function PANEL:OnRemove()
    if self.drag then
        self.drag = false
        self:MouseCapture(false)
    end
end

vgui.Register('MantleScroll', PANEL, 'EditablePanel')
