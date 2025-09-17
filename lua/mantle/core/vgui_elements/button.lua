local PANEL = {}

function PANEL:Init()
    self._activeShadowTimer = 0
    self._activeShadowMinTime = 0.03 -- минимальная длительность (сек)
    self._activeShadowLerp = 0
    self.hover_status = 0
    self.bool_hover = true
    self.font = 'Fated.18'
    self.radius = 16
    self.icon = ''
    self.icon_size = 16
    self.text = Mantle.lang.get('mantle', 'btn_default')
    self.col = Mantle.color.button
    self.col_hov = Mantle.color.button_hovered
    self.bool_gradient = true
    self.click_alpha = 0
    self.click_x = 0
    self.click_y = 0
    self.ripple_speed = 4
    self.enable_ripple = false
    self.ripple_color = Color(255, 255, 255, 30)

    --[[
    TODO: тень, которая не вылезает за окно при прокрутке
    ]]--
    -- local parent = self:GetParent()
    -- local grandParent = IsValid(parent:GetParent()) and parent:GetParent() or parent
    -- self.clipParent = IsValid(parent) and grandParent or nil

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
local btnFlags = RNDX.SHAPE_IOS

function PANEL:Paint(w, h)
    if self:IsHovered() then
        self.hover_status = math_clamp(self.hover_status + 4 * FrameTime(), 0, 1)
    else
        self.hover_status = math_clamp(self.hover_status - 8 * FrameTime(), 0, 1)
    end

    -- Минимальный порог длительности для активной тени
    local isActive = (self:IsDown() or self.Depressed) and self.hover_status > 0.8
    if isActive then
        self._activeShadowTimer = SysTime() + self._activeShadowMinTime
    end
    local showActiveShadow = isActive or (self._activeShadowTimer > SysTime())

    -- Плавная анимация дополнительной тени при зажатии
    local activeTarget = showActiveShadow and 10 or 0
    local activeSpeed = (activeTarget > 0) and 7 or 3 -- скорость появления/затухания
    self._activeShadowLerp = Lerp(FrameTime() * activeSpeed, self._activeShadowLerp, activeTarget)

    -- Обычная тень
    -- if Mantle.ui.convar.depth_ui then
    --     RNDX().Rect(0, 0, w, h)
    --         :Rad(self.radius)
    --         :Color(Mantle.color.window_shadow)
    --         :Shape(RNDX.SHAPE_IOS)
    --         :Shadow(5, 20)
    --         :Clip(self.clipParent)
    --     :Draw()
    -- end

    -- Дополнительная тень при зажатии
    if self._activeShadowLerp > 0 and Mantle.ui.convar.depth_ui then
        local col = Color(self.col_hov.r, self.col_hov.g, self.col_hov.b, math.Clamp(self.col_hov.a * 1.5, 0, 255))
        RNDX().Rect(0, 0, w, h)
            :Rad(self.radius)
            :Color(col)
            :Shape(btnFlags)
            :Shadow(self._activeShadowLerp * 1.5, 24)
        :Draw()
    end

    RNDX().Rect(0, 0, w, h)
        :Rad(self.radius)
        :Color(self.col)
        :Shape(btnFlags)
    :Draw()

    if self.bool_gradient then
        Mantle.func.gradient(0, 0, w, h, 1, Mantle.color.button_shadow, self.radius, btnFlags)
    end

    if self.bool_hover then
        RNDX().Rect(0, 0, w, h)
            :Rad(self.radius)
            :Color(Color(self.col_hov.r, self.col_hov.g, self.col_hov.b, self.hover_status * 255))
            :Shape(btnFlags)
        :Draw()
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

        RNDX().Rect(self.click_x - ripple_size * 0.5, self.click_y - ripple_size * 0.5, ripple_size, ripple_size)
            :Rad(100)
            :Color(ripple_color)
            :Shape(btnFlags)
        :Draw()
    end

    if self.text != '' then
        draw.SimpleText(
            self.text,
            self.font,
            w * 0.5 + (self.icon ~= '' and self.icon_size * 0.5 + 2 or 0),
            h * 0.5,
            Mantle.color.text,
            TEXT_ALIGN_CENTER,
            TEXT_ALIGN_CENTER
        )
        if self.icon != '' then
            surface.SetFont(self.font)
            local posX = (w - surface.GetTextSize(self.text) - self.icon_size) * 0.5 - 2
            local posY = (h - self.icon_size) * 0.5
            RNDX().Rect(posX, posY, self.icon_size, self.icon_size)
                :Material(self.icon)
                :Color(color_white)
                :Shape(btnFlags)
            :Draw()
        end
    elseif self.icon != '' then
        local posX = (w - self.icon_size) * 0.5
        local posY = (h - self.icon_size) * 0.5
        RNDX().Rect(posX, posY, self.icon_size, self.icon_size)
            :Material(self.icon)
            :Color(color_white)
            :Shape(btnFlags)
        :Draw()
    end
end

vgui.Register('MantleBtn', PANEL, 'Button')
