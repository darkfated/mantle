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
    self._dragAlpha = 255
end

function PANEL:CreateConVarSyncTimer()
    local name = 'MantleSlideBoxSync' .. tostring(self)
    timer.Create(name, 0.1, 0, function()
        if not IsValid(self) or not self.convar then return end
        local cvar = GetConVar(self.convar)
        if not cvar then return end
        local val = cvar:GetFloat()
        if self._convar_last ~= val then
            self._convar_last = val
            self:SetValue(val, true)
        end
    end)
    return name
end

function PANEL:OnRemove()
    if self._convar_timer then
        timer.Remove(self._convar_timer)
        self._convar_timer = nil
    end
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
    if self.max_value == self.min_value then
        val = self.min_value
    else
        val = math.Clamp(val, self.min_value, self.max_value)
    end

    if self.decimals > 0 then
        val = tonumber(string.format('%.' .. tostring(self.decimals) .. 'f', val)) or val
    else
        val = math.Round(val)
    end

    self.value = val
    local denom = (self.max_value - self.min_value)
    local progress = denom == 0 and 0 or (val - self.min_value) / denom
    local w = math.max(0, self:GetWide() - 32)
    self.targetPos = math.Clamp(w * progress, 0, w)
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
    local w = math.max(0, self:GetWide() - 32)
    local progress = math.Clamp(x / w, 0, 1)
    local new_value = self.min_value + (progress * (self.max_value - self.min_value))
    if self.decimals > 0 then
        new_value = tonumber(string.format('%.' .. tostring(self.decimals) .. 'f', new_value))
    else
        new_value = math.Round(new_value)
    end
    self:SetValue(new_value)
end

function PANEL:Paint(w, h)
    local ft = FrameTime()
    local padX = 16
    local padTop = 2
    local barY = 32
    local barH = 6
    local barR = barH / 2
    local handleW, handleH = 14, 14
    local handleR = handleH / 2
    local textFont = 'Fated.18'
    local minmaxFont = 'Fated.14'
    local valueFont = 'Fated.16'
    local minmaxPadY = 12

    -- Текст сверху
    draw.SimpleText(self.text, textFont, padX, padTop, Mantle.color.text)

    -- Линия
    local barStart = padX + handleW / 2
    local barEnd = w - padX - handleW / 2
    local barW = math.max(0, barEnd - barStart)

    local denom = (self.max_value - self.min_value)
    local progress = denom == 0 and 0 or (self.value - self.min_value) / denom
    progress = math.Clamp(progress, 0, 1)
    local activeW = barW * progress

    -- Тень под линией
    if Mantle.ui.convar.depth_ui then
        RNDX().Rect(barStart, barY, barW, barH)
            :Rad(barR)
            :Color(Mantle.color.window_shadow)
            :Shadow(5, 20)
        :Draw()
    end

    -- Фон линии
    RNDX.Draw(barR, barStart, barY, barW, barH, Mantle.color.focus_panel)
    RNDX.Draw(barR, barStart, barY, barW, barH, Mantle.color.button_shadow)

    -- Активная линия
    self.smoothPos = Mantle.func.approachExp(self.smoothPos or 0, activeW, 14, ft)
    if math.abs(self.smoothPos - activeW) < 0.5 then self.smoothPos = activeW end

    RNDX.Draw(barR, barStart, barY, self.smoothPos, barH, Mantle.color.theme)

    local handleX = barStart + self.smoothPos
    local handleY = barY + barH / 2

    -- Тень под ручкой
    RNDX.DrawShadows(handleR, handleX - handleW / 2, handleY - handleH / 2, handleW, handleH, Mantle.color.window_shadow, 3, 10)

    local targetAlpha = self.dragging and 100 or 255
    self._dragAlpha = Mantle.func.approachExp(self._dragAlpha or 255, targetAlpha, 24, ft)
    if math.abs(self._dragAlpha - targetAlpha) < 1 then self._dragAlpha = targetAlpha end
    local colorText = Color(Mantle.color.theme.r, Mantle.color.theme.g, Mantle.color.theme.b, math.floor(self._dragAlpha))

    -- Ручка
    RNDX.Draw(handleR, handleX - handleW / 2, handleY - handleH / 2, handleW, handleH, colorText)

    -- Значение справа от линии
    local valText = (self.decimals > 0) and tostring(self.value) or tostring(self.value)
    draw.SimpleText(valText, valueFont, barEnd + handleW / 2 + 4, barY + barH / 2, colorText, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)

    -- min/max под линией
    draw.SimpleText(self.min_value, minmaxFont, barStart, barY + barH + minmaxPadY - 4, Mantle.color.gray, TEXT_ALIGN_LEFT)
    draw.SimpleText(self.max_value, minmaxFont, barEnd, barY + barH + minmaxPadY - 4, Mantle.color.gray, TEXT_ALIGN_RIGHT)
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
