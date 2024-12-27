local PANEL = {}

function PANEL:Init()
    self.hover_status = 0
    self.bool_hover = true
    self.font = 'Fated.18'
    self.radius = 6
    self.icon = ''
    self.icon_size = 16
    self.text = 'Кнопка'
    self.col = Mantle.color.button
    self.col_hov = Mantle.color.button_hovered
    self.bool_gradient = true

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
    self.icon = icon
    self.icon_size = icon_size
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

local math_clamp = math.Clamp

function PANEL:Paint(w, h)
    if self:IsHovered() then
        self.hover_status = math_clamp(self.hover_status + 4 * FrameTime(), 0, 255)
    else
        self.hover_status = math_clamp(self.hover_status - 8 * FrameTime(), 0, 255)
    end

    draw.RoundedBox(self.radius, 0, 0, w, h, self.col)

    if self.bool_hover then
        draw.RoundedBox(self.radius, 0, 0, w, h, Color(self.col_hov.r, self.col_hov.g, self.col_hov.b, self.hover_status * 255))
    end

    if self.bool_gradient then
        Mantle.func.gradient(0, 0, w, h, 1, Mantle.color.button_shadow)
    end

    draw.SimpleText(self.text, self.font, w * 0.5 + (self.icon != '' and self.icon_size * 0.5 + 2 or 0), h * 0.5 - 1, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

    if self.icon != '' then
        surface.SetFont(self.font)
        
        local posX = (w - surface.GetTextSize(self.text) - self.icon_size) * 0.5 - 2
        local posY = (h - self.icon_size) * 0.5

        surface.SetDrawColor(color_white)
        surface.SetMaterial(self.icon)
        surface.DrawTexturedRect(posX, posY, self.icon_size, self.icon_size)
    end
end

vgui.Register('MantleBtn', PANEL, 'Button')
