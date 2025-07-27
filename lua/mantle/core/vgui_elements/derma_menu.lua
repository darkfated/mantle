local PANEL = {}
local color_shadow = Color(0, 0, 0, 120)

local function ClampMenuPosition(panel)
	if not IsValid(panel) then return end
	local x, y = panel:GetPos()
	local w, h = panel:GetSize()
	local sw, sh = Mantle.func.sw, Mantle.func.sh
	if x < 5 then x = 5 elseif x + w > sw - 5 then x = sw - 5 - w end
	if y < 5 then y = 5 elseif y + h > sh - 5 then y = sh - 5 - h end
	panel:SetPos(x, y)
end

function PANEL:Init()
	self.Items = {}
	self:SetSize(160, 0)
	self:DockPadding(6, 7, 6, 7)
	self:MakePopup()
	self:SetKeyboardInputEnabled(false)
	self:SetDrawOnTop(true)
	self.MaxTextWidth = 0

	self._openTime = CurTime()
	self.Think = function()
		if CurTime() - self._openTime < 0.1 then return end

		if input.IsMouseDown(MOUSE_LEFT) or input.IsMouseDown(MOUSE_RIGHT) then
			if not self:IsChildHovered() then
				self:Remove()
			end
		end
	end
end

function PANEL:Paint(w, h)
	RNDX.DrawShadows(16, 0, 0, w, h, Mantle.color.window_shadow, 10, 16, RNDX.SHAPE_IOS)
	RNDX.Draw(16, 0, 0, w, h, Mantle.color.background_panelpopup, RNDX.SHAPE_IOS)
end

function PANEL:AddOption(text, func, icon, optData)
	surface.SetFont('Fated.18')
	local textW = select(1, surface.GetTextSize(text))
	self.MaxTextWidth = math.max(self.MaxTextWidth or 0, textW)

	local option = vgui.Create('DButton', self)
	option:SetText('')
	option:Dock(TOP)
	option:DockMargin(2, 2, 2, 0)
	option:SetTall(26)
	option.sumTall = 28
	option.Icon = icon
	option.Text = text

	option.DoClick = function()
		if func then func() end
		Mantle.func.sound()

		if IsValid(self) then
			self:Remove()
		end
	end

	if optData then
		for k, v in pairs(optData) do
			option[k] = v
		end
	end

	local iconMat

	if option.Icon then
		iconMat = type(option.Icon) == 'IMaterial' and option.Icon or Material(option.Icon)
	end

	option.Paint = function(pnl, w, h)
		w = w or pnl:GetWide()
		h = h or pnl:GetTall()

		if pnl:IsHovered() then
			if Mantle.ui.convar.depth_ui then
				RNDX.DrawShadows(16, 0, 0, w, h, Mantle.color.window_shadow, 5, 20, RNDX.SHAPE_IOS)
			end
			RNDX.Draw(16, 0, 0, w, h, Mantle.color.hover, RNDX.SHAPE_IOS)
		end

		if iconMat then
			local iconSize = 16
			RNDX.DrawMaterial(0, 10, (h - iconSize) / 2, iconSize, iconSize, color_white, iconMat)
		end

		draw.SimpleText(pnl.Text, 'Fated.18', pnl.Icon and 32 or 14, h * 0.5, Mantle.color.text, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
	end

	table.insert(self.Items, option)

	self:UpdateSize()

	return option
end

function PANEL:AddSpacer()
	local spacer = vgui.Create('DPanel', self)
	spacer:Dock(TOP)
	spacer:DockMargin(8, 6, 8, 6)
	spacer:SetTall(1)
	spacer.sumTall = 13
	spacer.Paint = function(_, w, h)
		RNDX.Draw(0, 0, 0, w, h, Mantle.color.focus_panel)
	end

	table.insert(self.Items, spacer)

	self:UpdateSize()

	return spacer
end

function PANEL:UpdateSize()
	local height = 16

	for _, item in ipairs(self.Items) do
		if IsValid(item) then
			height = height + item.sumTall
		end
	end

	local maxWidth = math.max(160, self.MaxTextWidth + 60)

	self:SetSize(maxWidth, math.min(height, ScrH() * 0.8))
end

function PANEL:CloseMenu()
	self:Remove()
end

function PANEL:GetDeleteSelf()
	return true
end

vgui.Register('MantleDermaMenu', PANEL, 'DPanel')

function Mantle.ui.derma_menu()
	if IsValid(Mantle.ui.menu_derma_menu) then
		Mantle.ui.menu_derma_menu:CloseMenu()
	end

	local mouseX, mouseY = input.GetCursorPos()
	local m = vgui.Create('MantleDermaMenu')
	m:SetPos(mouseX, mouseY)

	ClampMenuPosition(m)

	Mantle.ui.menu_derma_menu = m

	return m
end
