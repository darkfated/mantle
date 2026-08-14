local PANEL = {}

local math_clamp = math.Clamp
local math_max = math.max
local math_floor = math.floor

function PANEL:Init()
    self.hover_status = 0
    self.press_status = 0
    self.bool_hover = true
    self.font = 'Fated.18'
    self.radius = 16
    self.icon = ''
    self.icon_size = 16
    self.text = Mantle.lang.get('mantle', 'btn_default')
    self.bool_gradient = true
    self.enable_ripple = false
    self.ripple_alpha = 0
    self.ripple_x = 0
    self.ripple_y = 0
    self.ripple_speed = 4
    self._activeShadowLerp = 0

    self:SetText('')
end

function PANEL:SetHover(is_hover)
    self.bool_hover = is_hover
end

function PANEL:SetFont(font)
    self.font = font
end

function PANEL:SetRadius(rad)
    self.radius = rad
end

function PANEL:SetIcon(icon, icon_size)
    self.icon = type(icon) == 'IMaterial' and icon or Material(icon)
    self.icon_size = icon_size or self.icon_size
end

function PANEL:SetTxt(text)
    self.text = text
end

function PANEL:SetColor(col)
    self.col = col
end

function PANEL:SetColorHover(col)
    self.col_hov = col
end

function PANEL:SetGradient(is_grad)
    self.bool_gradient = is_grad
end

function PANEL:SetRipple(enable)
    self.enable_ripple = enable
end

function PANEL:OnMousePressed(mousecode)
    self.BaseClass.OnMousePressed(self, mousecode)

    if self.enable_ripple and mousecode == MOUSE_LEFT then
        self.ripple_alpha = 1
        self.ripple_x, self.ripple_y = self:CursorPos()
    end
end

function PANEL:_drawContent(w, h)
    local hasIcon = self.icon != ''
    local hasText = self.text != ''

    if hasText then
        surface.SetFont(self.font)
        local tw = select(1, surface.GetTextSize(self.text))
        local total = tw + (hasIcon and (self.icon_size + 6) or 0)
        local startX = (w - total) * 0.5
        local cy = h * 0.5

        if hasIcon then
            RNDX.Rect(startX, cy - self.icon_size * 0.5, self.icon_size, self.icon_size)
                :Material(self.icon)
                :Color(Mantle.color.icon)
            :Draw()
            startX = startX + self.icon_size + 6
        end

        draw.SimpleText(self.text, self.font, startX + tw * 0.5, cy, Mantle.color.text, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    elseif hasIcon then
        RNDX.Rect((w - self.icon_size) * 0.5, (h - self.icon_size) * 0.5, self.icon_size, self.icon_size)
            :Material(self.icon)
            :Color(Mantle.color.icon)
        :Draw()
    end
end

function PANEL:Paint(w, h)
    local ft = FrameTime()
    local hovered = self.bool_hover and self:IsHovered()
    local pressed = self:IsDown()

    self.hover_status = Mantle.func.approachExp(self.hover_status, hovered and 1 or 0, 14, ft)
    self._activeShadowLerp = Mantle.func.approachExp(self._activeShadowLerp, pressed and 1 or 0, 9, ft)

    if self._activeShadowLerp > 0.01 and Mantle.ui.convar.depth_ui then
        RNDX.Rect(0, 0, w, h)
            :Outline(1)
            :Color(self.col_hov or Mantle.color.button_hovered)
            :Shadow(4, self._activeShadowLerp * 2)
        :Draw()
    end

    RNDX.Rect(0, 0, w, h)
        :Rad(self.radius)
        :Color(self.col or Mantle.color.button)
    :Draw()

    if self.bool_gradient then
        Mantle.func.gradient(0, 0, w, h, 1, Mantle.color.button_shadow, self.radius)
    end

    if self.hover_status > 0.01 then
        local hoverColor = self.col_hov or Mantle.color.button_hovered
        RNDX.Rect(0, 0, w, h)
            :Rad(self.radius)
            :Color(Color(hoverColor.r, hoverColor.g, hoverColor.b, math_floor(hoverColor.a * self.hover_status)))
        :Draw()
    end

    if self.enable_ripple and self.ripple_alpha > 0.01 then
        self.ripple_alpha = math_clamp(self.ripple_alpha - ft * self.ripple_speed, 0, 1)

        local rippleColor = self.ripple_color or Mantle.color.ripple
        local size = (1 - self.ripple_alpha) * math_max(w, h) * 2
        RNDX.Rect(self.ripple_x - size * 0.5, self.ripple_y - size * 0.5, size, size)
            :Rad(100)
            :Color(Color(rippleColor.r, rippleColor.g, rippleColor.b, math_floor(rippleColor.a * self.ripple_alpha)))
        :Draw()
    end

    self:_drawContent(w, h)
end

vgui.Register('MantleBtn', PANEL, 'Button')
