local PANEL = {}

function PANEL:Init()
    self.content = vgui.Create('Panel', self)
    self.content:SetMouseInputEnabled(true)

    self.vbar = nil
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
    self.gripMin = 28

    self._needLayout = true

    self:SetMouseInputEnabled(true)

    self._springing = false
    self._springTarget = 0
end

function PANEL:DockPadding(l,t,r,b)
    self.padL, self.padT, self.padR, self.padB = l or 0, t or 0, r or 0, b or 0
    self:_markDirty()
end

function PANEL:_markDirty()
    self._needLayout = true
end

function PANEL:GetCanvas()
    return self.content
end

function PANEL:AddItem(pnl)
    pnl:SetParent(self.content)

    local old = pnl.OnSizeChanged
    pnl.OnSizeChanged = function(...)
        if old then pcall(old, ...) end
        if IsValid(self) then
            self:_markDirty()
            self:InvalidateLayout(true)
            self.content:InvalidateLayout(true)
            self.content:SizeToChildren(true, false)
        end
    end

    self:_markDirty()
    return pnl
end

function PANEL:Add(pnl)
    return self:AddItem(pnl)
end

function PANEL:OnChildAdded(child)
    timer.Simple(0, function()
        if !IsValid(child) or !IsValid(self) then return end
        if child == self.content then return end
        if child:GetParent() == self then
            child:SetParent(self.content)

            local old = child.OnSizeChanged
            child.OnSizeChanged = function(...)
                if old then pcall(old, ...) end
                if IsValid(self) then
                    self:_markDirty()
                    self:InvalidateLayout(true)
                    self.content:InvalidateLayout(true)
                    self.content:SizeToChildren(true, false)
                end
            end

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
    if self._needLayout then
        local w, h = self:GetWide(), self:GetTall()

        self.content:DockPadding(0, 0, 0, 0)

        self.content:SetPos(self.padL - self.offset, self.padT)
        self.content:SetTall(math.max(0, h - self.padT - self.padB))
        self.content:InvalidateLayout(true)
        self.content:SizeToChildren(true, false)

        local viewW = math.max(0, w - self.padL - self.padR)
        local contentW = self.content:GetWide()

        if contentW <= viewW then
            self.content:SetWide(math.max(0, w - self.padL - self.padR))
            self.content:InvalidateLayout(true)
            self.content:SizeToChildren(true, false)
            contentW = self.content:GetWide()
        end

        self._needLayout = false
    end

    local viewW = math.max(0, self:GetWide() - self.padL - self.padR)
    local contentW = self.content:GetWide()

    return math.max(0, contentW - viewW), viewW, contentW
end

function PANEL:_nudge(px)
    self.vel = self.vel + px * 10
    self.lastInput = CurTime()
end

function PANEL:OnMouseWheeled(delta)
    local _, _, contentW = self:_range()
    if contentW <= 0 then return end

    self._springing = false

    self.vel = self.vel - delta * self.scrollStep
    self.lastInput = CurTime()
    return true
end

function PANEL:OnMousePressed(mc)
    if mc != MOUSE_LEFT then return end
    if self.MouseReleasedTime + 0.3 > CurTime() then return end

    local hovered = vgui.GetHoveredPanel()
    if IsValid(hovered) and hovered != self and hovered:IsDescendantOf(self.content) then return end

    self.drag = true
    self.dragLast = select(1, self:CursorPos())
    self.vel = 0
    self.lastInput = CurTime()
    self:MouseCapture(true)

    self._springing = false
end

function PANEL:OnMouseReleased(mc)
    if mc != MOUSE_LEFT then return end
    self.drag = false
    self:MouseCapture(false)

    local maxScrollDF = select(1, self:_range()) or 0

    local extraLeft = math.max(0, -self.offset)
    local extraRight = math.max(0, self.offset - maxScrollDF)

    if extraLeft > self.overscrollThreshold then
        self:_startSpring(0)
    elseif extraRight > self.overscrollThreshold then
        self:_startSpring(maxScrollDF)
    end

    self.MouseReleasedTime = CurTime()
end

function PANEL:OnCursorMoved(x, _)
    if !self.drag then return end

    local dx = x - self.dragLast
    self.dragLast = x

    local maxScrollDF = self:_range()
    local next = self.offset - dx
    if next < 0 then
        self.offset = self.offset - dx * self.dragRes
    elseif next > maxScrollDF then
        self.offset = self.offset - dx * self.dragRes
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

function PANEL:Think()
    local ft = FrameTime()
    local maxScrollDF, viewW, contentW = self:_range()

    local extraLeft = math.max(0, -self.offset)
    local extraRight = math.max(0, self.offset - maxScrollDF)

    if self._springing then
        if CurTime() - self.lastInput < 0.02 then
            self._springing = false
        end
    end

    if self._springing then
        local t = math.min(1, ft * self.spring)
        self.offset = Lerp(t, self.offset, self._springTarget)
        self.vel = 0
        if math.abs(self.offset - self._springTarget) < 0.5 then
            self.offset = self._springTarget
            self._springing = false
        end
    else
        if !self.drag then
            self.offset = self.offset + self.vel * ft

            if self.offset < -self.overscroll then
                self.offset = -self.overscroll
                self.vel = 0
            elseif self.offset > maxScrollDF + self.overscroll then
                self.offset = maxScrollDF + self.overscroll
                self.vel = 0
            else
                self.vel = self.vel * math.max(0, 1 - ft * self.friction)
                if math.abs(self.vel) < 2 then self.vel = 0 end
            end

            if CurTime() - self.lastInput > 0.09 and self.vel == 0 then
                if extraLeft > self.overscrollThreshold then
                    self:_startSpring(0)
                elseif extraRight > self.overscrollThreshold then
                    self:_startSpring(maxScrollDF)
                end
            end
        end
    end

    self.content:SetPos(self.padL - math.floor(self.offset), self.padT)
end

vgui.Register('MantleHScroll', PANEL, 'EditablePanel')
