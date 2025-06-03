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
    self.click_alpha = 0
    self.click_x = 0
    self.click_y = 0
    self.ripple_speed = 4
    self.enable_ripple = false
    self.ripple_color = Color(255, 255, 255, 30)

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

function PANEL:SetRipple(enable)
    self.enable_ripple = enable
end

function PANEL:OnMousePressed(mousecode)
    self.BaseClass.OnMousePressed(self, mousecode)
    
    if self.enable_ripple and mousecode == MOUSE_LEFT then
        self.click_alpha = 1
        self.click_x, self.click_y = self:CursorPos()
    end
end

local math_clamp = math.Clamp

function PANEL:Paint(w, h)
    if self:IsHovered() then
        self.hover_status = math_clamp(self.hover_status + 4 * FrameTime(), 0, 1)
    else
        self.hover_status = math_clamp(self.hover_status - 8 * FrameTime(), 0, 1)
    end

    draw.RoundedBox(self.radius, 0, 0, w, h, self.col)

    if self.bool_hover then
        draw.RoundedBox(self.radius, 0, 0, w, h, Color(self.col_hov.r, self.col_hov.g, self.col_hov.b, self.hover_status * 255))
    end

    if self.bool_gradient then
        Mantle.func.gradient(0, 0, w, h, 1, Mantle.color.button_shadow)
    end

    if self.click_alpha > 0 then
        self.click_alpha = math_clamp(self.click_alpha - FrameTime() * self.ripple_speed, 0, 1)
        
        local ripple_size = (1 - self.click_alpha) * math.max(w, h) * 2
        local ripple_color = Color(
            self.ripple_color.r,
            self.ripple_color.g,
            self.ripple_color.b,
            self.ripple_color.a * self.click_alpha
        )
        
        draw.RoundedBox(w, self.click_x - ripple_size * 0.5, self.click_y - ripple_size * 0.5, ripple_size, ripple_size, ripple_color)
    end

    draw.SimpleText(
        self.text, 
        self.font, 
        w * 0.5 + (self.icon != '' and self.icon_size * 0.5 + 2 or 0), 
        h * 0.5, 
        color_white, 
        TEXT_ALIGN_CENTER, 
        TEXT_ALIGN_CENTER
    )

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
