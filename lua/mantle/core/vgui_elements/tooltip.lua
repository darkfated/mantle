local PANEL = {}
AccessorFunc(PANEL, "m_strText", "Text", FORCE_STRING)
AccessorFunc(PANEL, "m_strFont", "Font", FORCE_STRING)

function PANEL:Init()
	self:SetDrawOnTop(true)
	self:SetText("")
	self:SetFont(Mantle.func.cache_font(12))
	self:SetRadius(16)
	self:SetCustomColor(Mantle.color.theme)

	self.DeleteContentsOnClose = false
	self.CVarTooltipDelay = GetConVar("tooltip_delay")

	self.Label = vgui.Create("MantleText", self)
	self.Label:SetAlign(TEXT_ALIGN_CENTER)
	self.Label:SetVAlign("center")
	self.Label:SetPadding(0)
end

function PANEL:SetContents(panel, bDelete)
	panel:SetParent(self)

	self.Contents = panel
	self.DeleteContentsOnClose = bDelete or false
	self.Contents:SizeToContents()
	self:InvalidateLayout(true)

	self.Contents:SetVisible(false)
end

function PANEL:PerformLayout()
	if IsValid(self.Contents) then
		self.Label:SetVisible(false)
		self:SetWide(self.Contents:GetWide() + 8)
		self:SetTall(self.Contents:GetTall() + 8)
		self.Contents:SetPos(4, 4)
		self.Contents:SetVisible(true)
	else
		local w, h = self.Label:GetContentSize()
		self:SetSize(w + 8, h + 6)
		if #self:GetText() < 1 then
			self:Close()
		else
			self.Label:Dock(FILL)
			self.Label:SetVisible(true)
		end
	end
end

function PANEL:PositionTooltip()
	if not IsValid(self.TargetPanel) then
		return self:Close()
	end
	self:InvalidateLayout(true)

	local x, y = input.GetCursorPos()
	local w, h = self:GetSize()
	local _, ly = self.TargetPanel:LocalToScreen(0, 0)

	y = y - 50
	y = math.min(y, ly - h - 10)
	if y < 2 then
		y = 2
	end

	self:SetPos(math.Clamp(x - w * 0.5, 0, ScrW() - self:GetWide()), math.Clamp(y, 0, ScrH() - self:GetTall()))
end

function PANEL:Think()
	self.Label:SetFont(self:GetFont())
	self.Label:SetText(self:GetText())
	self:PositionTooltip()
end

function PANEL:OpenForPanel(panel)
	self.TargetPanel = panel
	self.OpenDelay = isnumber(panel.numTooltipDelay) and panel.numTooltipDelay or self.CVarTooltipDelay:GetFloat()
	self:PositionTooltip()

	if self.OpenDelay > 0 then
		self:SetVisible(false)
		timer.Simple(self.OpenDelay, function()
			if not IsValid(self) or not IsValid(panel) then
				return
			end
			self:PositionTooltip()
			self:SetVisible(true)
		end)
	end
end

function PANEL:Close()
	if not self.DeleteContentsOnClose and IsValid(self.Contents) then
		self.Contents:SetVisible(false)
		self.Contents:SetParent(nil)
	end

	self:Remove()
end

vgui.Register("MantleTooltip", PANEL, "MantlePanel")
