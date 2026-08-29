local colorTarget = Color(255, 255, 255, 200)

function Mantle.ui.color_picker(callback, defaultColor)
	if IsValid(Mantle.ui.menu_color_picker) then
		Mantle.ui.menu_color_picker:Remove()
	end

	local selectedColor = defaultColor or Color(255, 255, 255)
	local hue = 0
	local saturation = 1
	local value = 1
	local rgbEntries = {}

	if defaultColor then
		local h, s, v = ColorToHSV(defaultColor)
		hue = h
		saturation = s
		value = v
	end

	local function updateRgbEntries()
		for _, ch in ipairs({ "R", "G", "B" }) do
			if IsValid(rgbEntries[ch]) then
				rgbEntries[ch]:SetValue(
					tostring(ch == "R" and selectedColor.r or ch == "G" and selectedColor.g or selectedColor.b)
				)
			end
		end
	end

	local function syncCursorPositions()
		timer.Simple(0, function()
			if IsValid(colorField) and IsValid(hueSlider) then
				colorCursor.x = saturation * colorField:GetWide()
				colorCursor.y = (1 - value) * colorField:GetTall()
				huePos = (hue / 360) * hueSlider:GetWide()
			end
		end)
	end

	local frame = vgui.Create("MantleFrame")
	Mantle.ui.menu_color_picker = frame
	frame:SetSize(320, 400)
	frame:Center()
	frame:MakePopup()
	frame:SetTitle("")
	frame:SetCenterTitle(Mantle.lang.get("mantle", "color_title"))
	frame:ShowAnimation()
	frame:SetPopupPad(12)

	local preview = vgui.Create("MantlePanel", frame)
	preview:Dock(TOP)
	preview:SetTall(40)
	preview:DockMargin(0, 0, 0, 8)
	preview:SetCustomColor(selectedColor)
	preview:SetRadius(16)

	local colorField = vgui.Create("Panel", frame)
	colorField:SetTooltipPanelOverride("MantleTooltip")
	colorField:Dock(TOP)
	colorField:SetTall(194)
	colorField:DockMargin(0, 0, 0, 8)

	local colorCursor = { x = 0, y = 0 }
	local isDraggingColor = false

	colorField.OnMousePressed = function(self, keyCode)
		if keyCode == MOUSE_LEFT then
			isDraggingColor = true
			self:OnCursorMoved(self:CursorPos())
		end
	end

	colorField.OnMouseReleased = function(self, keyCode)
		if keyCode == MOUSE_LEFT then
			isDraggingColor = false
		end
	end

	colorField.OnCursorMoved = function(self, x, y)
		if isDraggingColor then
			local w, h = self:GetSize()
			x = math.Clamp(x, 0, w)
			y = math.Clamp(y, 0, h)

			colorCursor.x = x
			colorCursor.y = y

			saturation = x / w
			value = 1 - (y / h)

			selectedColor = HSVToColor(hue, saturation, value)
			preview:SetCustomColor(selectedColor)
			updateRgbEntries()
		end
	end

	colorField.Paint = function(self, w, h)
		local segments = 60
		local segmentSize = w / segments

		for x = 0, segments do
			for y = 0, segments do
				local s = x / segments
				local v = 1 - (y / segments)
				local segX = x * segmentSize
				local segY = y * segmentSize

				surface.SetDrawColor(HSVToColor(hue, s, v))
				surface.DrawRect(segX, segY, segmentSize + 1, segmentSize + 1)
			end
		end

		RNDX.Rect(0, 0, w, h):Color(Mantle.color.window_shadow):Outline(1):Draw()

		RNDX.Circle(colorCursor.x, colorCursor.y, 6):Outline(2):Color(colorTarget):Draw()
	end

	local hueSlider = vgui.Create("Panel", frame)
	hueSlider:SetTooltipPanelOverride("MantleTooltip")
	hueSlider:Dock(TOP)
	hueSlider:SetTall(22)
	hueSlider:DockMargin(0, 0, 0, 8)

	local huePos = 0
	local isDraggingHue = false

	hueSlider.OnMousePressed = function(self, keyCode)
		if keyCode == MOUSE_LEFT then
			isDraggingHue = true
			self:OnCursorMoved(self:CursorPos())
		end
	end

	hueSlider.OnMouseReleased = function(self, keyCode)
		if keyCode == MOUSE_LEFT then
			isDraggingHue = false
		end
	end

	hueSlider.OnCursorMoved = function(self, x, y)
		if isDraggingHue then
			local w = self:GetWide()
			x = math.Clamp(x, 0, w)

			huePos = x
			hue = (x / w) * 360

			selectedColor = HSVToColor(hue, saturation, value)
			preview:SetCustomColor(selectedColor)
			updateRgbEntries()
		end
	end

	hueSlider.Paint = function(self, w, h)
		local segments = 60
		local segmentWidth = w / segments

		for i = 0, segments - 1 do
			local hueVal = (i / segments) * 360
			local x = i * segmentWidth

			surface.SetDrawColor(HSVToColor(hueVal, 1, 1))
			surface.DrawRect(x, 1, segmentWidth + 1, h - 2)
		end

		RNDX.Rect(huePos - 2, 0, 4, h):Color(colorTarget):Draw()
	end

	local rgbContainer = vgui.Create("Panel", frame)
	rgbContainer:SetTooltipPanelOverride("MantleTooltip")
	rgbContainer:Dock(TOP)
	rgbContainer:SetTall(32)
	rgbContainer:DockMargin(0, 0, 0, 8)

	local slotGap = 8
	local contentW = frame:GetWide() - 24
	local slotW = (contentW - slotGap * 2) / 3

	for i, ch in ipairs({ "R", "G", "B" }) do
		local slot = vgui.Create("Panel", rgbContainer)
		slot:SetTooltipPanelOverride("MantleTooltip")
		slot:Dock(LEFT)
		slot:DockMargin(0, 0, i < 3 and slotGap or 0, 0)
		slot:SetWide(slotW)

		local entry = vgui.Create("MantleEntry", slot)
		entry:Dock(FILL)
		entry:DockMargin(0, 2, 0, 2)
		entry:SetPlaceholder(ch)
		entry:SetValue(tostring(ch == "R" and selectedColor.r or ch == "G" and selectedColor.g or selectedColor.b))
		entry.textEntry:SetNumeric(true)
		entry.textEntry.OnTextChanged = function(s)
			local v = tonumber(s:GetText())
			if v then
				v = math.Clamp(math.Round(v), 0, 255)
				if ch == "R" then
					selectedColor.r = v
				elseif ch == "G" then
					selectedColor.g = v
				else
					selectedColor.b = v
				end
				local h2, s2, v2 = ColorToHSV(selectedColor)
				hue = h2
				saturation = s2
				value = v2
				preview:SetCustomColor(selectedColor)
				syncCursorPositions()
			end
		end

		rgbEntries[ch] = entry
	end

	local btnContainer = vgui.Create("Panel", frame)
	btnContainer:SetTooltipPanelOverride("MantleTooltip")
	btnContainer:Dock(BOTTOM)
	btnContainer:SetTall(32)

	local btnClose = vgui.Create("MantleBtn", btnContainer)
	btnClose:Dock(LEFT)
	btnClose:DockMargin(0, 0, 0, 0)
	btnClose:SetWide(92)
	btnClose:SetTxt(Mantle.lang.get("mantle", "color_cancel"))
	btnClose.DoClick = function()
		frame:Close()
		Mantle.func.sound()
	end

	local btnSelect = vgui.Create("MantleBtn", btnContainer)
	btnSelect:Dock(RIGHT)
	btnSelect:DockMargin(0, 0, 0, 0)
	btnSelect:SetWide(92)
	btnSelect:SetTxt(Mantle.lang.get("mantle", "color_select"))
	btnSelect.DoClick = function()
		frame:Close()
		Mantle.func.sound()

		callback(selectedColor)
	end

	syncCursorPositions()
end
