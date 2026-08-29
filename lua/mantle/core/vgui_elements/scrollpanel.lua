local PANEL = {}

PANEL.IsVertical = true

function PANEL:Init()
	self.BaseClass.Init(self)

	self.scrollStep = 500
	self.overscroll = 90
	self.overscrollThreshold = 50
	self.gripMin = 28

	self._vbarPadRight = 6
	self.vbarDefaultWidth = 4
	self.vbarExpandedWidth = 6
	self.vbarWidthSpeed = 12
	self.vbarReserveWidth = self.vbarExpandedWidth

	self.vbarHoverDelay = 1
	self.vbarUnhoverDelay = 0.5

	self.vbar = vgui.Create("Panel", self)
	self.vbar:SetTooltipPanelOverride("MantleTooltip")
	self.vbar:SetMouseInputEnabled(true)
	self.vbar:SetWide(self.vbarDefaultWidth)
	self.vbar:Dock(RIGHT)
	self.vbar:DockMargin(6, 0, 0, 0)
	self.vbar.Paint = function(_, w, h)
		RNDX.Rect(0, 0, w, h):Rad(32):Color(Mantle.color.focus_panel):Draw()
	end

	self.vbar.Dragging = false
	self.vbar._press_off = 0
	self.vbar._hoverEnter = 0
	self.vbar._hoverExit = 0
	self.vbar._expanded = false

	self.vbar.btnGrip = vgui.Create("MantleBtn", self.vbar)
	self.vbar.btnGrip:SetText("")
	self.vbar.btnGrip.Paint = function(s, w, h)
		RNDX.Rect(0, 0, w, h):Rad(32):Color(Mantle.color.theme):Draw()
	end

	self.vbar.btnGrip.OnMousePressed = function(s)
		local _, my = s:GetParent():CursorPos()
		s:GetParent().Dragging = true
		s:GetParent()._press_off = my - s.y
		s:MouseCapture(true)
		s:GetParent()._springing = false
		s:GetParent()._expanded = true
	end

	self.vbar.btnGrip.OnMouseReleased = function(s)
		s:GetParent().Dragging = false
		s:MouseCapture(false)

		if not (s:GetParent():IsHovered() or s:IsHovered()) then
			s:GetParent()._hoverExit = CurTime()
		end
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
end

function PANEL:GetVBar()
	return self.vbar
end

function PANEL:DisableVBarPadding()
	self._vbarPadRight = 0
	self.vbar:DockMargin(0, 0, 0, 0)
	self:_markDirty()
	self:InvalidateLayout(true)
	self.content:InvalidateLayout(true)
end

function PANEL:SetVBarPaddingRight(enabled)
	self.vbar:DockMargin(enabled and 6 or 0, 0, 0, 0)
	self:_markDirty()
end

function PANEL:_isInternal(child)
	return child == self.content or child == self.vbar or child == self.vbar.btnGrip
end

function PANEL:_sizeCanvas()
	self.content:SizeToChildren(false, true)
end

function PANEL:_range()
	if self._needLayout then
		local w, h = self:GetWide(), self:GetTall()
		local vbReserve = self.vbarReserveWidth

		self.content:SetPos(self.padL, self.padT - self.offset)
		self.content:SetWide(math.max(0, w - self.padL - self.padR - vbReserve - self._vbarPadRight))
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

function PANEL:_applyScroll()
	self.content:SetPos(self.padL, self.padT - math.floor(self.offset))
end

function PANEL:_afterScroll(ft, maxScroll, viewH, contentH)
	local vb = self.vbar
	if not vb:IsVisible() then
		return
	end

	local now = CurTime()
	local hoveredNow = vb:IsHovered() or vb.btnGrip:IsHovered()
	if hoveredNow then
		if vb._hoverEnter == 0 then
			vb._hoverEnter = now
		end
		vb._hoverExit = 0
	else
		if vb._hoverExit == 0 then
			vb._hoverExit = now
		end
		vb._hoverEnter = 0
	end

	if vb.Dragging or (vb._hoverEnter > 0 and now - vb._hoverEnter >= self.vbarHoverDelay) then
		vb._expanded = true
	elseif vb._hoverExit > 0 and now - vb._hoverExit >= self.vbarUnhoverDelay then
		vb._expanded = false
	end

	local targetW = (vb._expanded or vb.Dragging) and self.vbarExpandedWidth or self.vbarDefaultWidth
	local width = self._vb_width or targetW
	width = Mantle.func.approachExp(width, targetW, self.vbarWidthSpeed, ft)
	if math.abs(width - targetW) < 0.25 then
		width = targetW
	end
	self._vb_width = width

	local newW = math.max(1, math.floor(width))
	if vb:GetWide() ~= newW then
		vb:SetWide(newW)
		self:_markDirty()
	end

	local trackH = vb:GetTall()
	local clamped = math.Clamp(self.offset, 0, maxScroll)
	local ratio = contentH <= 0 and 1 or math.min(1, viewH / contentH)
	local gripH = math.max(self.gripMin, math.floor(trackH * ratio))
	local scroll01 = maxScroll <= 0 and 0 or clamped / maxScroll

	local extraTop = math.max(0, -self.offset)
	local extraBottom = math.max(0, self.offset - maxScroll)
	local overscrollFrac = math.Clamp(math.max(extraTop, extraBottom) / self.overscroll, 0, 1)

	local gripRatio = gripH / math.max(1, trackH)
	local weight = math.Clamp((1 - gripRatio) * 1.5, 0, 1)

	local contentToTrack = trackH / math.max(1, contentH)
	local extraShift = 0
	if extraTop > 0 then
		extraShift = -extraTop * contentToTrack
	elseif extraBottom > 0 then
		extraShift = extraBottom * contentToTrack
	end

	local desiredY = (trackH - gripH) * scroll01 + extraShift * weight * overscrollFrac

	if clamped <= 0.001 then
		desiredY = 0
	elseif maxScroll > 0 and clamped >= maxScroll - 0.001 then
		desiredY = trackH - gripH
	end

	local visualGripH = math.max(6, gripH * (1 - 0.7 * overscrollFrac * weight))

	local gripSpeed = 14
	if vb.Dragging then
		local _, my = vb:CursorPos()
		local newY = math.Clamp(my - vb._press_off, 0, trackH - visualGripH)
		local range = trackH - visualGripH
		self.offset = range <= 0 and 0 or (newY / range) * maxScroll
		self.vel = 0

		self._vb_gripH = visualGripH
		self._vb_gripY = newY
	else
		local speedY = gripSpeed * (1 + overscrollFrac * 0.5)

		if self._vb_gripH == nil then
			self._vb_gripH = visualGripH
		else
			self._vb_gripH = Mantle.func.approachExp(self._vb_gripH, visualGripH, gripSpeed, ft)
			if math.abs(self._vb_gripH - visualGripH) < 0.25 then
				self._vb_gripH = visualGripH
			end
		end

		if self._vb_gripY == nil then
			self._vb_gripY = desiredY
		else
			self._vb_gripY = Mantle.func.approachExp(self._vb_gripY, desiredY, speedY, ft)
			if math.abs(self._vb_gripY - desiredY) < 0.25 then
				self._vb_gripY = desiredY
			end
		end

		local maxY = math.max(0, trackH - self._vb_gripH)
		if self._vb_gripY < 0 then
			self._vb_gripY = 0
		end
		if self._vb_gripY > maxY then
			self._vb_gripY = maxY
		end

		if clamped <= 0.001 then
			self._vb_gripY = 0
		elseif maxScroll > 0 and clamped >= maxScroll - 0.001 then
			self._vb_gripY = trackH - self._vb_gripH
		end

		if math.abs(self._vb_gripH - visualGripH) < 0.25 then
			self._vb_gripH = visualGripH
		end
		if math.abs((self._vb_gripY or 0) - desiredY) < 0.25 then
			self._vb_gripY = desiredY
		end
	end

	local finalH = math.max(1, math.floor(self._vb_gripH))
	local finalY = math.floor(math.Clamp(self._vb_gripY or 0, 0, math.max(0, trackH - finalH)))

	if clamped <= 0.001 then
		finalY = 0
	elseif maxScroll > 0 and clamped >= maxScroll - 0.001 then
		finalY = trackH - finalH
	end

	vb.btnGrip:SetSize(vb:GetWide(), finalH)
	vb.btnGrip:SetPos(0, finalY)
end

vgui.Register("MantleScrollPanel", PANEL, "MantleScroll")
