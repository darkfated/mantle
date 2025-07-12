local PANEL = {}

function PANEL:Init()
    self.text = ''
    self.min_value = 0
    self.max_value = 1
    self.decimals = 0
    self.convar = nil
    self.value = 0
    self.smoothPos = 0
    self.targetPos = 0
    self.dragging = false
    self.hover = false
    self:SetTall(60)
    self.OnValueChanged = function() end

    self._convar_last = nil
    self._convar_timer = self:CreateConVarSyncTimer()
end

function PANEL:CreateConVarSyncTimer()
    return timer.Create('MantleSlideBoxSync' .. tostring(self), 0.1, 0, function()
        if not IsValid(self) or not self.convar then return end
        local cvar = GetConVar(self.convar)
        if not cvar then return end
        local val = cvar:GetFloat()
        if self._convar_last ~= val then
            self._convar_last = val
            self:SetValue(val, true)
        end
    end)
end

function PANEL:OnRemove()
    timer.Remove('MantleSlideBoxSync' .. tostring(self))
end

function PANEL:SetRange(min_value, max_value, decimals)
    self.min_value = min_value
    self.max_value = max_value
    self.decimals = decimals or 0
    self:SetValue(self.value or min_value)
end

function PANEL:SetConvar(convar)
    self.convar = convar
    local cvar = GetConVar(convar)
    if cvar then
        self:SetValue(cvar:GetFloat(), true)
        self._convar_last = cvar:GetFloat()
    end
end

function PANEL:SetText(text)
    self.text = text
end

function PANEL:SetValue(val, fromConVar)
    val = math.Clamp(val, self.min_value, self.max_value)
    if self.decimals > 0 then
        val = math.Round(val, self.decimals)
    else
        val = math.Round(val)
    end
    self.value = val
    local progress = (val - self.min_value) / (self.max_value - self.min_value)
    self.targetPos = math.Clamp((self:GetWide() - 32) * progress, 0, self:GetWide() - 32)
    if self.convar and not fromConVar then
        RunConsoleCommand(self.convar, tostring(val))
        self._convar_last = val
    end
    if self.OnValueChanged then self:OnValueChanged(val) end
end

function PANEL:GetValue()
    return self.value
end

function PANEL:UpdateSliderByCursorPos(x)
    local progress = math.Clamp(x / (self:GetWide() - 32), 0, 1)
    local new_value = self.min_value + (progress * (self.max_value - self.min_value))
    if self.decimals > 0 then
        new_value = math.Round(new_value, self.decimals)
    else
        new_value = math.Round(new_value)
    end
    self:SetValue(new_value)
end

function PANEL:Paint(w, h)
    local padX = 16
    local padTop = 2
    local barY = 32
    local barH = 6
    local barR = barH/2
    local handleR = 7
    local handleW, handleH = handleR*2, handleR*2
    local textFont = 'Fated.18'
    local minmaxFont = 'Fated.14'
    local valueFont = 'Fated.16'
    local minmaxPadY = 12

    -- Текст сверху (с большим отступом)
    draw.SimpleText(self.text, textFont, padX, padTop, color_white)

    -- Линия
    local barStart = padX + handleR
    local barEnd = w - padX - handleR
    local barW = barEnd - barStart
    local progress = (self.value - self.min_value) / (self.max_value - self.min_value)
    local activeW = math.Clamp(barW * progress, 0, barW)

    -- Фон линии
    if Mantle.ui.convar.depth_ui then
        RNDX.DrawShadows(16, barStart, barY, barW, barH, Mantle.color.window_shadow, 5, 20, RNDX.SHAPE_IOS)
    end
    RNDX.Draw(16, barStart, barY, barW, barH, Mantle.color.focus_panel)
    RNDX.Draw(16, barStart, barY, barW, barH, Mantle.color.button_shadow)

    -- Активная линия
    RNDX.Draw(16, barStart, barY, activeW, barH, Mantle.color.theme)

    -- Маленький шарик-ручка (идеально круглый)
    self.smoothPos = Lerp(FrameTime() * 12, self.smoothPos or 0, activeW)
    local handleX = barStart + self.smoothPos
    local handleY = barY + barH/2
    local handleCol = (self.dragging or self.hover) and Mantle.color.theme or Mantle.color.button
    surface.SetDrawColor(handleCol)
    draw.NoTexture()
    draw.Circle(handleX, handleY, handleR, 32)
    surface.SetDrawColor(color_white)
    draw.Circle(handleX, handleY, handleR-2, 32)

    -- Значение справа от линии
    draw.SimpleText(self.value, valueFont, barEnd + handleR + 4, barY + barH/2, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)

    -- min/max под линией
    draw.SimpleText(self.min_value, minmaxFont, barStart, barY + barH + minmaxPadY - 4, Mantle.color.gray, TEXT_ALIGN_LEFT)
    draw.SimpleText(self.max_value, minmaxFont, barEnd, barY + barH + minmaxPadY - 4, Mantle.color.gray, TEXT_ALIGN_RIGHT)
end

function draw.Circle(x, y, radius, seg)
    local cir = {}
    for i = 0, seg do
        local a = math.rad((i / seg) * -360)
        table.insert(cir, {x = x + math.sin(a) * radius, y = y + math.cos(a) * radius})
    end
    surface.DrawPoly(cir)
end

function PANEL:OnMousePressed(mcode)
    if mcode == MOUSE_LEFT then
        local x = self:CursorPos()
        self:UpdateSliderByCursorPos(x)
        self.dragging = true
        self:MouseCapture(true)
        self.ripple_x = x
        self.ripple_anim = 0
        self.ripple_active = true
    end
end

function PANEL:OnMouseReleased(mcode)
    if mcode == MOUSE_LEFT then
        self.dragging = false
        self:MouseCapture(false)
    end
end

function PANEL:OnCursorMoved(x)
    if self.dragging then
        self:UpdateSliderByCursorPos(x)
    end
end

function PANEL:OnCursorEntered()
    self.hover = true
end

function PANEL:OnCursorExited()
    self.hover = false
end

vgui.Register('MantleSlideBox', PANEL, 'Panel')
