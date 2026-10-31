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
    if !IsValid(self.vbar) then return end

    local x = self:GetWide() - self.padR - self.vbarReserveWidth
    self.vbar:SetPos(math_max(self.padL, x), self.padT)
    self.vbar:SetSize(self.vbarReserveWidth, math_max(0, viewH))
end

function PANEL:_range()
    local w, h = self:GetSize()
    local viewW = math_max(0, w - self.padL - self.padR)
    local viewH = math_max(0, h - self.padT - self.padB)

    if self._needLayout then
        local contentW = math_max(0, viewW - self.vbarReserveWidth - self._vbarPadRight)

        self.content:SetWide(contentW)
        self.content:InvalidateLayout(true)
        self:_sizeCanvas()

        local contentH = self.content:GetTall()
        local hasOverflow = contentH > viewH + 0.5

        if hasOverflow then
            self.vbar:SetVisible(true)
        else
            self.vbar:SetVisible(false)
            self.content:SetWide(viewW)
            self.content:InvalidateLayout(true)
            self:_sizeCanvas()

            contentH = self.content:GetTall()
            hasOverflow = contentH > viewH + 0.5

            if hasOverflow then
                self.vbar:SetVisible(true)
                self.content:SetWide(contentW)
                self.content:InvalidateLayout(true)
                self:_sizeCanvas()
            end
        end

        self._needLayout = false
    end

    local contentH = self.content:GetTall()
    local maxScroll = math_max(0, contentH - viewH)

    if maxScroll <= 0 then
        self.vbar:SetVisible(false)
    else
        self.vbar:SetVisible(true)
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
        self._vbarAlpha = 0
        if IsValid(vb.btnGrip) then vb.btnGrip:SetCursor('arrow') end
        self._vb_gripY = 0
        self._vb_gripH = 0
        return
    end

    local now = CurTime()
    local hovered = vb:IsHovered() or vb.btnGrip:IsHovered()
    local moving = self.drag or vb.Dragging or self._springing or math_abs(self.vel) > 6
    local recentlyUsed = self.lastInput > 0 and now - self.lastInput < self.vbarUnhoverDelay
    local visible = hovered or moving or recentlyUsed

    self._vbarAlpha = Mantle.func.approachExp(self._vbarAlpha, visible and 1 or 0, visible and 16 or 5, ft)
    vb.btnGrip:SetCursor(self._vbarAlpha > 0.1 and 'hand' or 'arrow')

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
    else
        self._vb_gripH = self._vb_gripH or visualGripH
        self._vb_gripY = self._vb_gripY or desiredY

        self._vb_gripH = Mantle.func.approachExp(self._vb_gripH, visualGripH, 18, ft)
        self._vb_gripY = Mantle.func.approachExp(self._vb_gripY, desiredY, 22, ft)

        if math_abs(self._vb_gripH - visualGripH) < 0.25 then self._vb_gripH = visualGripH end
        if math_abs(self._vb_gripY - desiredY) < 0.25 then self._vb_gripY = desiredY end
    end

    local finalH = math_max(1, math_floor(self._vb_gripH))
    local finalY = math_floor(math.Clamp(self._vb_gripY or 0, 0, math_max(0, trackH - finalH)))

    vb.btnGrip:SetSize(vb:GetWide(), finalH)
    vb.btnGrip:SetPos(0, finalY)
end

vgui.Register('MantleScrollPanel', PANEL, 'MantleScroll')
