local PANEL = {}

local math_clamp = math.Clamp
local math_max = math.max
local math_floor = math.floor

function PANEL:Init()
	self:DockMargin(8, 8, 8, 8)
	self:SetTall(40)

	self.hoverAmount = 0
	self.hoverEnabled = true
	self.font = "Fated.18"
	self.radius = 16
	self.icon = ""
	self.iconSize = 16
	self.text = Mantle.lang.get("mantle", "btn_default")
	self.gradientEnabled = true
	self.rippleEnabled = false
	self.rippleAlpha = 0
	self.rippleX = 0
	self.rippleY = 0
	self.rippleSpeed = 4

	self:SetText("")
	self:SetTooltipPanelOverride("MantleTooltip")
end

function PANEL:SetHover(isHover)
	self.hoverEnabled = isHover
end

function PANEL:SetFont(font)
	self.font = font
end

function PANEL:SetRadius(rad)
	self.radius = rad
end

function PANEL:SetIcon(icon, size)
	self.icon = type(icon) == "IMaterial" and icon or Material(icon)
	self.iconSize = size or self.iconSize
end

function PANEL:SetTxt(text)
	self.text = text
end

function PANEL:SetColor(color)
	self.color = color
end

function PANEL:SetColorHover(color)
	self.colorHover = color
end

function PANEL:SetGradient(enabled)
	self.gradientEnabled = enabled
end

function PANEL:SetRipple(enabled)
	self.rippleEnabled = enabled
end

function PANEL:OnMousePressed(mousecode)
	self.BaseClass.OnMousePressed(self, mousecode)

	if self.rippleEnabled and mousecode == MOUSE_LEFT then
		self.rippleAlpha = 1
		self.rippleX, self.rippleY = self:CursorPos()
	end
end

function PANEL:_drawContent(w, h)
	local hasIcon = self.icon ~= ""
	local hasText = self.text ~= ""

	if hasText then
		surface.SetFont(self.font)
		local tw = select(1, surface.GetTextSize(self.text))
		local total = tw + (hasIcon and (self.iconSize + 6) or 0)
		local startX = (w - total) * 0.5
		local cy = h * 0.5

		if hasIcon then
			RNDX.Rect(startX, cy - self.iconSize * 0.5, self.iconSize, self.iconSize)
				:Material(self.icon)
				:Color(Mantle.color.icon)
				:Draw()
			startX = startX + self.iconSize + 6
		end

		draw.SimpleText(
			self.text,
			self.font,
			startX + tw * 0.5,
			cy,
			Mantle.color.text,
			TEXT_ALIGN_CENTER,
			TEXT_ALIGN_CENTER
		)
	elseif hasIcon then
		RNDX.Rect((w - self.iconSize) * 0.5, (h - self.iconSize) * 0.5, self.iconSize, self.iconSize)
			:Material(self.icon)
			:Color(Mantle.color.icon)
			:Draw()
	end
end

function PANEL:Paint(w, h)
	local ft = FrameTime()
	local hovered = self.hoverEnabled and self:IsHovered()

	self.hoverAmount = Mantle.func.approachExp(self.hoverAmount, hovered and 1 or 0, 14, ft)

	RNDX.Rect(0, 0, w, h):Rad(self.radius):Shape(RNDX.SHAPE_IOS):Color(self.color or Mantle.color.button):Draw()

	if self.gradientEnabled then
		Mantle.func.gradient(0, 0, w, h, 1, Mantle.color.button_shadow, self.radius)
	end

	if self.hoverAmount > 0.01 then
		local hoverColor = self.colorHover or Mantle.color.button_hovered
		RNDX.Rect(0, 0, w, h)
			:Rad(self.radius)
			:Shape(RNDX.SHAPE_IOS)
			:Color(Color(hoverColor.r, hoverColor.g, hoverColor.b, math_floor(hoverColor.a * self.hoverAmount)))
			:Draw()
	end

	if self.rippleEnabled and self.rippleAlpha > 0.01 then
		self.rippleAlpha = math_clamp(self.rippleAlpha - ft * self.rippleSpeed, 0, 1)

		local rippleColor = self.rippleColor or Mantle.color.ripple
		local size = (1 - self.rippleAlpha) * math_max(w, h) * 2
		RNDX.Rect(self.rippleX - size * 0.5, self.rippleY - size * 0.5, size, size)
			:Rad(100)
			:Color(Color(rippleColor.r, rippleColor.g, rippleColor.b, math_floor(rippleColor.a * self.rippleAlpha)))
			:Draw()
	end

	self:_drawContent(w, h)
end

function PANEL:DoClick()
	Mantle.func.sound()
end

vgui.Register("MantleBtn", PANEL, "Button")
