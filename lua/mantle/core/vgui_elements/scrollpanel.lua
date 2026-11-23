local PANEL = {}

local math_max = math.max
local math_min = math.min
local math_floor = math.floor
local math_abs = math.abs

PANEL.IsVertical = true

function PANEL:Init()
    self.BaseClass.Init(self)

    self.scrollStep = 560
    self.overscroll = 90
    self.springStiffness = 190
    self.springDamping = 25.4
    self.gripMin = 28

    self._vbarPadRight = 2
    self.vbarReserveWidth = 12
    self.vbarDefaultWidth = 4
    self.vbarHoverDelay = 0
    self.vbarUnhoverDelay = 0.85

    self._vbarAlpha = 0
    self._vb_gripH = nil
    self._vb_gripY = nil

    self._vb_visible = false
    self._vb_lastX = nil
    self._vb_lastY = nil
    self._vb_lastW = nil
    self._vb_lastH = nil
    self._vb_cursor = nil
    self._vb_finalW = nil
    self._vb_finalY = nil
    self._vb_finalH = nil

    self.vbar = vgui.Create('Panel', self)
    self.vbar:SetMouseInputEnabled(true)
    self.vbar:SetWide(self.vbarReserveWidth)
    self.vbar:SetVisible(false)
    self.vbar:SetZPos(10)
    self.vbar.Paint = function(_, w, h)
        local alpha = self._vbarAlpha
        if alpha <= 0.01 then return end

        local color = Mantle.color.focus_panel
        local a = math_floor((color.a or 255) * alpha * 0.35)
        RNDX.Rect(w * 0.5 - 1, 3, 2, math_max(0, h - 6))
            :Rad(2)
            :Color(Color(color.r, color.g, color.b, a))
        :Draw()
    end

    self.vbar.Dragging = false
    self.vbar._press_off = 0

    self.vbar.btnGrip = vgui.Create('Panel', self.vbar)
    self.vbar.btnGrip:SetMouseInputEnabled(true)
    self.vbar.btnGrip:SetCursor('hand')
    self.vbar.btnGrip.Paint = function(_, w, h)
        local alpha = self._vbarAlpha
        if alpha <= 0.01 then return end

        local color = Mantle.color.gray or Mantle.color.text
        local width = math_min(w, self.vbarDefaultWidth)
        local x = (w - width) * 0.5
        local a = math_floor((color.a or 255) * alpha)

        RNDX.Rect(x, 0, width, h)
            :Rad(32)
            :Color(Color(color.r, color.g, color.b, a))
        :Draw()
    end

    self.vbar.btnGrip.OnMousePressed = function(s, mc)
        if mc != MOUSE_LEFT then return end

        local parent = s:GetParent()
        local _, my = parent:CursorPos()
        parent.Dragging = true
        parent._press_off = my - s.y

        self.vel = 0
        self.drag = false
        self._springing = false
        self._springVelocity = 0
        self.lastInput = CurTime()

        s:MouseCapture(true)
    end

    self.vbar.btnGrip.OnMouseReleased = function(s, mc)
        if mc != MOUSE_LEFT then return end

        local parent = s:GetParent()
        parent.Dragging = false
        s:MouseCapture(false)
        self.lastInput = CurTime()

        local maxScroll = self:_range()
        self:_checkOverscroll(maxScroll)
    end

    self.vbar.OnMousePressed = function(pnl, mc)
        if mc != MOUSE_LEFT or pnl.Dragging then return end

        local _, my = pnl:CursorPos()
        local grip = pnl.btnGrip
        local gy, gh = grip.y, grip:GetTall()
        local page = math_max(1, self:GetTall() - self.padT - self.padB) * 0.85

        if my < gy then
            self:SetScroll(self.offset - page)
        elseif my > gy + gh then
            self:SetScroll(self.offset + page)
        end
    end

    self.vbar.OnMouseWheeled = function(_, delta)
        return self:OnMouseWheeled(delta)
    end
end

function PANEL:GetVBar()
    return self.vbar
end

function PANEL:DisableVBarPadding()
    self._vbarPadRight = 0
    self:_markDirty()
    self.content:InvalidateLayout(true)
end

function PANEL:SetVBarPaddingRight(enabled)
    self._vbarPadRight = enabled and 6 or 0
    self:_markDirty()
    self.content:InvalidateLayout(true)
end

function PANEL:_isInternal(child)
    return child == self.content or child == self.vbar or (IsValid(self.vbar) and child == self.vbar.btnGrip)
end

function PANEL:_sizeCanvas()
    self.content:SizeToChildren(false, true)
end

function PANEL:_layoutVBar(viewH)
    local vb = self.vbar
    if !IsValid(vb) then return end

    local x = math_max(self.padL, self:GetWide() - self.padR - self.vbarReserveWidth)
    local y = self.padT
    local w = self.vbarReserveWidth
    local h = math_max(0, viewH)

    if self._vb_lastX == x and self._vb_lastY == y and self._vb_lastW == w and self._vb_lastH == h then
        return
    end

    self._vb_lastX, self._vb_lastY, self._vb_lastW, self._vb_lastH = x, y, w, h
    vb:SetPos(x, y)
    vb:SetSize(w, h)
end

function PANEL:_range()
    local w, h = self:GetSize()
    local viewW = math_max(0, w - self.padL - self.padR)
    local viewH = math_max(0, h - self.padT - self.padB)

    local contentH
    local wantVisible

    if self._needLayout then
        local contentW = math_max(0, viewW - self.vbarReserveWidth - self._vbarPadRight)

        self.content:SetWide(contentW)
        self.content:InvalidateLayout(true)
        self:_sizeCanvas()
        contentH = self.content:GetTall()

        if contentH > viewH + 0.5 then
            wantVisible = true
        else
            self.content:SetWide(viewW)
            self.content:InvalidateLayout(true)
            self:_sizeCanvas()
            contentH = self.content:GetTall()

            if contentH > viewH + 0.5 then
                wantVisible = true
                self.content:SetWide(contentW)
                self.content:InvalidateLayout(true)
                self:_sizeCanvas()
                contentH = self.content:GetTall()
            else
                wantVisible = false
            end
        end

        self._needLayout = false
    else
        contentH = self.content:GetTall()
        wantVisible = contentH > viewH
    end

    local maxScroll = math_max(0, contentH - viewH)

    if self._vb_visible != wantVisible then
        self._vb_visible = wantVisible
        self.vbar:SetVisible(wantVisible)
    end

    self:_layoutVBar(viewH)

    return maxScroll, viewH, contentH
end

function PANEL:_applyScroll()
    self.content:SetPos(self.padL, self.padT - self.offset)
end

function PANEL:_afterScroll(ft, maxScroll, viewH, contentH)
    local vb = self.vbar
    if !IsValid(vb) then return end

    if !vb:IsVisible() or maxScroll <= 0 then
        if self._vbarAlpha != 0 then self._vbarAlpha = 0 end
        if self._vb_cursor != 'arrow' then
            self._vb_cursor = 'arrow'
            if IsValid(vb.btnGrip) then vb.btnGrip:SetCursor('arrow') end
        end
        if self._vb_gripY != 0 then self._vb_gripY = 0 end
        if self._vb_gripH != 0 then self._vb_gripH = 0 end
        return
    end

    local now = CurTime()
    local hovered = vb:IsHovered() or vb.btnGrip:IsHovered()
    local moving = self.drag or vb.Dragging or self._springing or math_abs(self.vel) > 6
    local recentlyUsed = self.lastInput > 0 and now - self.lastInput < self.vbarUnhoverDelay
    local visible = hovered or moving or recentlyUsed

    local targetAlpha = visible and 1 or 0
    local newAlpha = Mantle.func.approachExp(self._vbarAlpha, targetAlpha, visible and 16 or 5, ft)
    if math_abs(newAlpha - targetAlpha) < 0.005 then
        newAlpha = targetAlpha
    end
    self._vbarAlpha = newAlpha

    local cursor = newAlpha > 0.1 and 'hand' or 'arrow'
    if self._vb_cursor != cursor then
        self._vb_cursor = cursor
        vb.btnGrip:SetCursor(cursor)
    end

    local trackH = vb:GetTall()
    if trackH <= 0 then return end

    local ratio = math_min(1, viewH / math_max(1, contentH))
    local gripH = math_max(self.gripMin, math_floor(trackH * ratio))
    gripH = math_min(trackH, gripH)

    local clampedOffset = math.Clamp(self.offset, 0, maxScroll)
    local scroll01 = maxScroll <= 0 and 0 or clampedOffset / maxScroll
    local desiredY = (trackH - gripH) * scroll01

    local overscroll = math_max(0, -self.offset, self.offset - maxScroll)
    local overscroll01 = math.Clamp(overscroll / math_max(1, self.overscroll), 0, 1)
    local visualGripH = math_max(math_min(self.gripMin * 0.65, trackH), gripH * (1 - overscroll01 * 0.16))

    if vb.Dragging then
        local _, my = vb:CursorPos()
        local maxY = math_max(0, trackH - visualGripH)
        local newY = math.Clamp(my - vb._press_off, 0, maxY)
        local range = trackH - visualGripH

        self.offset = range <= 0 and 0 or (newY / range) * maxScroll
        self.vel = 0
        self._springing = false
        self._vb_gripY = newY
        self._vb_gripH = visualGripH
        self.lastInput = now
        self:_applyScroll()
        self._lastAppliedOffset = self.offset
    else
        if self._vb_gripH == nil then self._vb_gripH = visualGripH end
        if self._vb_gripY == nil then self._vb_gripY = desiredY end

        local newGripH = Mantle.func.approachExp(self._vb_gripH, visualGripH, 18, ft)
        if math_abs(newGripH - visualGripH) < 0.25 then newGripH = visualGripH end
        self._vb_gripH = newGripH

        local newGripY = Mantle.func.approachExp(self._vb_gripY, desiredY, 22, ft)
        if math_abs(newGripY - desiredY) < 0.25 then newGripY = desiredY end
        self._vb_gripY = newGripY
    end

    local finalH = math_max(1, math_floor(self._vb_gripH))
    local finalY = math_floor(math.Clamp(self._vb_gripY or 0, 0, math_max(0, trackH - finalH)))
    local finalW = vb:GetWide()

    if self._vb_finalH != finalH or self._vb_finalY != finalY or self._vb_finalW != finalW then
        self._vb_finalH, self._vb_finalY, self._vb_finalW = finalH, finalY, finalW
        vb.btnGrip:SetSize(finalW, finalH)
        vb.btnGrip:SetPos(0, finalY)
    end
end

vgui.Register('MantleScrollPanel', PANEL, 'MantleScroll')
