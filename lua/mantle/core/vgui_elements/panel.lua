local PANEL = {}

function PANEL:Init()
	self:SetTall(60)
	self:DockMargin(8, 8, 8, 8)
	self:SetTooltipPanelOverride("MantleTooltip")

	self.colorIndex = 1
	self.colorAlphaIndex = nil
	self.color = nil
	self.radius = 12
end

function PANEL:SetColor(index)
	self.colorIndex = index
end

function PANEL:SetColorAlpha(index)
	self.colorAlphaIndex = index
end

function PANEL:SetCustomColor(color)
	self.color = color
end

function PANEL:SetRadius(radius)
	self.radius = radius
end

function PANEL:Paint(w, h)
	local col = self.color
	if not col then
		if self.colorAlphaIndex then
			col = Mantle.color.panel_alpha[self.colorAlphaIndex]
		else
			col = Mantle.color.panel[self.colorIndex]
		end
	end

	RNDX.Rect(0, 0, w, h):Rad(self.radius):Color(col):Draw()
end

vgui.Register("MantlePanel", PANEL, "EditablePanel")
