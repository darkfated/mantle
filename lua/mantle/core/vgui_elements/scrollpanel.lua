local PANEL = {}

function PANEL:Init()
    self.content = vgui.Create('Panel', self)
    self.content:SetMouseInputEnabled(true)

    self.vbar = vgui.Create('Panel', self)
    self.vbar:SetMouseInputEnabled(true)
    self.vbar:SetWide(6)
    self.vbar.Dragging = false
    self.vbar._press_off = 0
    self.vbar:Dock(RIGHT)
    self.vbar:DockMargin(6, 0, 0, 0)
    self.vbar.Paint = function(_, w, h)
        RNDX().Rect(0, 0, w, h)
            :Rad(32)
            :Color(Mantle.color.focus_panel)
        :Draw()
    end

    self.vbar.btnGrip = vgui.Create('MantleBtn', self.vbar)
    self.vbar.btnGrip:SetText('')
    self.vbar.btnGrip._ShadowLerp = 0
    self.vbar.btnGrip.Paint = function(s, w, h)
        s._ShadowLerp = Lerp(FrameTime() * 10, s._ShadowLerp, self.vbar.Dragging and 7 or 0)

        RNDX().Rect(0, 0, w, h)
            :Rad(32)
            :Color(Mantle.color.theme)
            :Shadow(s._ShadowLerp, 20)
        :Draw()
        RNDX().Rect(0, 0, w, h)
            :Rad(32)
            :Color(Mantle.color.theme)
        :Draw()
    end

    self.vbar.btnGrip.OnMousePressed = function(s)
        local _, my = s:GetParent():CursorPos()
        s:GetParent().Dragging = true
        s:GetParent()._press_off = my - s.y
        s:MouseCapture(true)
        s:GetParent()._springing = false
    end

    self.vbar.btnGrip.OnMouseReleased = function(s)
        s:GetParent().Dragging = false
        s:MouseCapture(false)
    end

    self.vbar.OnMousePressed = function(pnl)
        local _, my = pnl:CursorPos()
        local gy, gh = pnl.btnGrip.y, pnl.btnGrip:GetTall()
        if my < gy then
            self:_nudge(-self:GetTall())
        elseif my > gy + gh then
            self:_nudge(self:GetTall())
        end
        self.lastInput = CurTime()
        self._springing = false
    end

    function self.vbar:AnimateTo(yPos)
        self:GetParent():SetScroll(yPos)
    end

    function self.vbar:GetScroll()
        return self:GetParent():GetScroll()
    end

    self.padL, self.padT, self.padR, self.padB = 0, 0, 0, 0
    self.offset = 0
    self.vel = 0
    self.drag = false
    self.dragLast = 0
    self.lastInput = 0

    self.scrollStep = 500
    self.overscroll = 90
    self.overscrollThreshold = 50
    self.friction = 8
    self.spring = 5
    self.dragRes = 0.35
    self.gripMin = 28
    self.vbarSmooth = 3

    self._vb_gripH = nil
    self._vb_gripY = nil

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

function PANEL:GetVBar()
    return self.vbar
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
            self.content:SizeToChildren(false, true)
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
        if child == self.content or child == self.vbar or child == self.vbar.btnGrip then return end
        if not IsValid(child) or not IsValid(self) then return end
        if child:GetParent() == self then
            child:SetParent(self.content)

            local old = child.OnSizeChanged
            child.OnSizeChanged = function(...)
                if old then pcall(old, ...) end
                if IsValid(self) then
                    self:_markDirty()
                    self:InvalidateLayout(true)
                    self.content:InvalidateLayout(true)
                    self.content:SizeToChildren(false, true)
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

function PANEL:SetScroll(y)
    self.offset = y or 0
end

function PANEL:GetScroll()
    return self.offset
end

function PANEL:_range()
    if self._needLayout then
        local w, h = self:GetWide(), self:GetTall()
        local vbw = self.vbar:GetWide()

        self.content:DockPadding(0, 0, 0, 0)
        self.content:SetPos(self.padL, self.padT - self.offset)

        local contentW = math.max(0, w - self.padL - self.padR - vbw - 6)
        self.content:SetWide(contentW)
        self.content:InvalidateLayout(true)
        self.content:SizeToChildren(false, true)

        local viewH = math.max(0, h - self.padT - self.padB)
        local contentH = self.content:GetTall()

        if contentH <= viewH then
            self.vbar:SetVisible(false)
            self.content:SetWide(math.max(0, w - self.padL - self.padR))
            self.content:InvalidateLayout(true)
            self.content:SizeToChildren(false, true)
            contentH = self.content:GetTall()
        else
            self.vbar:SetVisible(true)
        end

        self._needLayout = false
    end

    local viewH = math.max(0, self:GetTall() - self.padT - self.padB)
    local contentH = self.content:GetTall()

    return math.max(0, contentH - viewH), viewH, contentH
end

function PANEL:_nudge(px)
    self.vel = self.vel + px * 10
    self.lastInput = CurTime()
end

function PANEL:OnMouseWheeled(delta)
    local _, _, contentH = self:_range()
    if contentH <= 0 then return end

    self._springing = false

    self.vel = self.vel - delta * self.scrollStep
    self.lastInput = CurTime()
    return true
end

function PANEL:OnMousePressed(mc)
    if mc != MOUSE_LEFT then return end

    local hovered = vgui.GetHoveredPanel()
    if IsValid(hovered) and hovered != self and hovered:IsDescendantOf(self.content) then return end

    self.drag = true
    self.dragLast = select(2, self:CursorPos())
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

    local extraTop = math.max(0, -self.offset)
    local extraBottom = math.max(0, self.offset - maxScrollDF)

    if extraTop > self.overscrollThreshold then
        self:_startSpring(0)
    elseif extraBottom > self.overscrollThreshold then
        self:_startSpring(maxScrollDF)
    end
end

function PANEL:OnCursorMoved(_, y)
    if not self.drag then return end

    local dy = y - self.dragLast
    self.dragLast = y

    local maxScrollDF = self:_range()
    local next = self.offset - dy
    if next < 0 then
        self.offset = self.offset - dy * self.dragRes
    elseif next > maxScrollDF then
        self.offset = self.offset - dy * self.dragRes
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
    local maxScrollDF, viewH, contentH = self:_range()

    local extraTop = math.max(0, -self.offset)
    local extraBottom = math.max(0, self.offset - maxScrollDF)

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
        if not self.drag then
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
                if extraTop > self.overscrollThreshold then
                    self:_startSpring(0)
                elseif extraBottom > self.overscrollThreshold then
                    self:_startSpring(maxScrollDF)
                end
            end
        end
    end

    self.content:SetPos(self.padL, self.padT - math.floor(self.offset))

    local vb = self.vbar
    if not vb:IsVisible() then return end

    local trackH = vb:GetTall()
    local clampedOffset = math.Clamp(self.offset, 0, maxScrollDF)
    local ratio = (contentH <= 0) and 1 or math.min(1, viewH / contentH)
    local gripH = math.max(self.gripMin, math.floor(trackH * ratio))
    local scroll01 = (maxScrollDF <= 0) and 0 or (clampedOffset / maxScrollDF)

    local topFrac = math.Clamp(extraTop / self.overscroll, 0, 1)
    local bottomFrac = math.Clamp(extraBottom / self.overscroll, 0, 1)
    local maxFrac = math.max(topFrac, bottomFrac)
    local overscrollFrac = math.Clamp(math.max(extraTop, extraBottom) / self.overscroll, 0, 1)

    local gripRatio = gripH / math.max(1, trackH)
    local weight = math.Clamp((1 - gripRatio) * 1.5, 0, 1)

    local contentToTrack = trackH / math.max(1, contentH)
    local extraShift = 0
    if extraTop > 0 then extraShift = -extraTop * contentToTrack
    elseif extraBottom > 0 then extraShift = extraBottom * contentToTrack end

    local proportionalY = (trackH - gripH) * scroll01

    local desiredY = proportionalY + extraShift * weight * overscrollFrac

    if clampedOffset <= 0.001 then
        desiredY = 0
    elseif maxScrollDF > 0 and clampedOffset >= maxScrollDF - 0.001 then
        desiredY = trackH - gripH
    end

    local maxShrink = 0.7
    local visualGripH = gripH * (1 - maxShrink * overscrollFrac * weight)
    visualGripH = math.max(6, visualGripH)

    local heightSpeedNormal = 6
    local heightSpeedOverscroll = 0.35
    local heightSpeed = Lerp(maxFrac, heightSpeedNormal, heightSpeedOverscroll)
    local s_h = math.min(1, ft * self.vbarSmooth * heightSpeed)

    local posSpeed = 3.5
    local s_y = math.min(1, ft * self.vbarSmooth * posSpeed)

    if vb.Dragging then
        local _, my = vb:CursorPos()
        local newY = math.Clamp(my - vb._press_off, 0, trackH - visualGripH)
        local s01 = (trackH - visualGripH) <= 0 and 0 or (newY / (trackH - visualGripH))
        self.offset = s01 * maxScrollDF
        self.vel = 0

        self._vb_gripH = visualGripH
        self._vb_gripY = newY
    else
        self._vb_gripH = (self._vb_gripH == nil) and visualGripH or Lerp(s_h, self._vb_gripH, visualGripH)
        self._vb_gripY = (self._vb_gripY == nil) and desiredY or Lerp(s_y, self._vb_gripY, desiredY)

        local maxY = math.max(0, trackH - self._vb_gripH)
        if self._vb_gripY < 0 then self._vb_gripY = 0 end
        if self._vb_gripY > maxY then self._vb_gripY = maxY end

        if clampedOffset <= 0.001 then
            self._vb_gripY = 0
        elseif maxScrollDF > 0 and clampedOffset >= maxScrollDF - 0.001 then
            self._vb_gripY = trackH - self._vb_gripH
        end

        if math.abs(self._vb_gripH - visualGripH) < 0.25 then self._vb_gripH = visualGripH end
        if math.abs((self._vb_gripY or 0) - desiredY) < 0.25 then self._vb_gripY = desiredY end
    end

    local finalH = math.max(1, math.floor(self._vb_gripH))
    local finalY = math.floor(math.Clamp(self._vb_gripY or 0, 0, math.max(0, trackH - finalH)))

    if clampedOffset <= 0.001 then finalY = 0 end
    if maxScrollDF > 0 and clampedOffset >= maxScrollDF - 0.001 then finalY = trackH - finalH end

    vb.btnGrip:SetSize(vb:GetWide(), finalH)
    vb.btnGrip:SetPos(0, finalY)
end

vgui.Register('MantleScrollPanel', PANEL, 'EditablePanel')
