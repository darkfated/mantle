local PANEL = {}

local math_clamp = math.Clamp
local math_max = math.max
local math_floor = math.floor
local math_abs = math.abs

local HOVER_SNAP = 0.005
local RIPPLE_SNAP = 0.01

function PANEL:Init()
    self:DockMargin(8, 8, 8, 8)
    self:SetTall(36)

    self.hoverAmount = 0
    self.hoverEnabled = true
    self.font = 'Fated.18'
    self.radius = 12
    self.icon = ''
    self.iconSize = 16
    self.text = Mantle.lang.get('mantle', 'btn_default')
    self.gradientEnabled = true
    self.rippleEnabled = false
    self.rippleAlpha = 0
    self.rippleX = 0
    self.rippleY = 0
    self.rippleSpeed = 4

    self._iconValid = false
    self._textWidth = nil
    self._textWidthFor = nil
    self._textFontFor = nil

    self:SetText('')
end

function PANEL:SetHover(isHover)
    self.hoverEnabled = isHover
end

function PANEL:SetFont(font)
    if self.font == font then return end
    self.font = font
    self._textWidthFor = nil
end

function PANEL:SetRadius(rad)
    self.radius = rad
end

function PANEL:SetIcon(icon, size)
    self.icon = type(icon) == 'IMaterial' and icon or Material(icon)
    self.iconSize = size or self.iconSize
    self._iconValid = self.icon != nil and self.icon != ''
end

function PANEL:SetTxt(text)
    if self.text == text then return end
    self.text = text
    self._textWidthFor = nil
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

function PANEL:_getTextWidth()
    local text = self.text
    local font = self.font

    if self._textWidthFor == text and self._textFontFor == font and self._textWidth then
        return self._textWidth
    end

    surface.SetFont(font)
    local tw = select(1, surface.GetTextSize(text))
    self._textWidth = tw
    self._textWidthFor = text
    self._textFontFor = font
    return tw
end

function PANEL:_drawContent(w, h)
    local hasIcon = self._iconValid
    local hasText = self.text != ''

    if hasText then
        local tw = self:_getTextWidth()
        local iconSize = self.iconSize
        local total = tw + (hasIcon and (iconSize + 6) or 0)
        local startX = (w - total) * 0.5
        local cy = h * 0.5
        local iconColor = Mantle.color.icon

        if hasIcon then
            RNDX.Rect(startX, cy - iconSize * 0.5, iconSize, iconSize)
                :Material(self.icon)
                :Color(iconColor)
            :Draw()
            startX = startX + iconSize + 6
        end

        draw.SimpleText(self.text, self.font, startX + tw * 0.5, cy, Mantle.color.text, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    elseif hasIcon then
        local iconSize = self.iconSize
        RNDX.Rect((w - iconSize) * 0.5, (h - iconSize) * 0.5, iconSize, iconSize)
            :Material(self.icon)
            :Color(Mantle.color.icon)
        :Draw()
    end
end

function PANEL:Paint(w, h)
    local hovered = self.hoverEnabled and self:IsHovered()
    local hoverTarget = hovered and 1 or 0

    if self.hoverAmount != hoverTarget then
        self.hoverAmount = Mantle.func.approachExp(self.hoverAmount, hoverTarget, 14, FrameTime())
        if math_abs(self.hoverAmount - hoverTarget) < HOVER_SNAP then
            self.hoverAmount = hoverTarget
        end
    end

    RNDX.Rect(0, 0, w, h)
        :Rad(self.radius)
        :Color(self.color or Mantle.color.button)
    :Draw()

    if self.gradientEnabled then
        Mantle.func.gradient(0, 0, w, h, 1, Mantle.color.button_shadow, self.radius)
    end

    if self.hoverAmount > 0.01 then
        local hoverColor = self.colorHover or Mantle.color.button_hovered
        RNDX.Rect(0, 0, w, h)
            :Rad(self.radius)
            :Color(Color(hoverColor.r, hoverColor.g, hoverColor.b, math_floor(hoverColor.a * self.hoverAmount)))
        :Draw()
    end

    local rippleAlpha = self.rippleAlpha
    if self.rippleEnabled and rippleAlpha > RIPPLE_SNAP then
        rippleAlpha = math_clamp(rippleAlpha - FrameTime() * self.rippleSpeed, 0, 1)
        self.rippleAlpha = rippleAlpha

        local rippleColor = self.rippleColor or Mantle.color.ripple
        local size = (1 - rippleAlpha) * math_max(w, h) * 2
        RNDX.Rect(self.rippleX - size * 0.5, self.rippleY - size * 0.5, size, size)
            :Rad(100)
            :Color(Color(rippleColor.r, rippleColor.g, rippleColor.b, math_floor(rippleColor.a * rippleAlpha)))
        :Draw()
    end

    self:_drawContent(w, h)
end

function PANEL:DoClick()
    Mantle.func.sound()
end

vgui.Register('MantleBtn', PANEL, 'Button')
