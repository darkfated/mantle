local PANEL = {}

local TOP_PADDING = 12
local SIDE_PADDING = 16
local BAR_Y = 36
local BAR_H = 5
local HANDLE_W, HANDLE_H = 14, 14

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

    self:SetTall(68)

    self.OnValueChanged = function() end

    self._convar_last = nil
    self._convar_timer_name = self:CreateConVarSyncTimer()

    self._dragAlpha = 255
    self._ripple = { active = false, x = 0, t = 0 }
end

function PANEL:CreateConVarSyncTimer()
    local name = ('mantle_slide_sync_%s'):format(tostring(self))
    timer.Create(name, 0.1, 0, function()
        if not IsValid(self) or not self.convar then return end
        local cvar = GetConVar(self.convar)
        if not cvar then return end

        local val = cvar:GetFloat()
        if self._convar_last != val then
            self._convar_last = val
            self:SetValue(val, true)
        end
    end)
    return name
end

function PANEL:OnRemove()
    if self._convar_timer_name then
        timer.Remove(self._convar_timer_name)
        self._convar_timer_name = nil
    end
end

function PANEL:SetRange(min_value, max_value, decimals)
    self.min_value = tonumber(min_value) or 0
    self.max_value = tonumber(max_value) or 1
    self.decimals = tonumber(decimals) or 0
    self:SetValue(self.value, true)
end

function PANEL:SetConvar(name)
    self.convar = name
    local cvar = GetConVar(name)
    if cvar then
        local v = cvar:GetFloat()
        self._convar_last = v
        self:SetValue(v, true)
    end
end

function PANEL:SetText(text)
    self.text = tostring(text or '')
end

local function formatValue(val, decimals)
    if decimals and decimals > 0 then
        return string.format('%.' .. decimals .. 'f', val)
    end
    return tostring(math.Round(val))
end

function PANEL:SetValue(val, fromConVar)
    if self.max_value == self.min_value then
        val = self.min_value
    else
        val = math.Clamp(val, self.min_value, self.max_value)
    end

    if self.decimals > 0 then
        val = tonumber(string.format('%.' .. self.decimals .. 'f', val)) or val
    else
        val = math.Round(val)
    end

    if self.value == val then return end
    self.value = val

    local denom = (self.max_value - self.min_value)
    local progress = denom == 0 and 0 or (self.value - self.min_value) / denom

    local barW = math.max(0, self:GetWide() - SIDE_PADDING * 2 - HANDLE_W - 24)
    self.targetPos = math.Clamp(barW * progress, 0, barW)

    if self.convar and not fromConVar then
        RunConsoleCommand(self.convar, tostring(self.value))
        self._convar_last = self.value
    end

    self:OnValueChanged(self.value)
end

function PANEL:GetValue()
    return self.value
end

function PANEL:UpdateSliderByCursorPos(absX)
    local w = self:GetWide()
    local barStart = SIDE_PADDING + HANDLE_W / 2 + 10
    local barEnd = w - SIDE_PADDING - HANDLE_W / 2 - 20
    local barW = math.max(0, barEnd - barStart)

    local localX = absX - barStart
    local progress = math.Clamp(localX / barW, 0, 1)
    local new_value = self.min_value + progress * (self.max_value - self.min_value)

    if self.decimals > 0 then
        new_value = tonumber(string.format('%.' .. self.decimals .. 'f', new_value))
    else
        new_value = math.Round(new_value)
    end

    self:SetValue(new_value)
end

function PANEL:Paint(w, h)
    local ft = FrameTime()
    local pad = SIDE_PADDING
    local barStart = pad + HANDLE_W / 2 + 10
    local barEnd = w - pad - HANDLE_W / 2 - 20
    local barW = math.max(0, barEnd - barStart)
    local barR = BAR_H * 0.5

    local denom = self.max_value - self.min_value
    local progress = denom == 0 and 0 or (self.value - self.min_value) / denom
    progress = math.Clamp(progress, 0, 1)

    local activeW = barW * progress
    self.smoothPos = Mantle.func.approachExp(self.smoothPos, activeW, 14, ft)

    draw.SimpleText(self.text, 'Fated.16', pad, TOP_PADDING - 6, Mantle.color.text)

    RNDX.Draw(barR, barStart, BAR_Y, barW, BAR_H, Mantle.color.focus_panel)
    RNDX.Draw(barR, barStart, BAR_Y, barW, BAR_H, Mantle.color.button_shadow)
    RNDX.Draw(barR, barStart, BAR_Y, self.smoothPos, BAR_H, Mantle.color.theme)

    local handleX = barStart + self.smoothPos
    local handleY = BAR_Y + BAR_H / 2
    local handleR = HANDLE_H * 0.5

    RNDX.DrawShadows(
        handleR,
        handleX - HANDLE_W / 2,
        handleY - HANDLE_H / 2,
        HANDLE_W,
        HANDLE_H,
        Mantle.color.window_shadow,
        3,
        10
    )

    local targetAlpha = self.dragging and 200 or 255
    self._dragAlpha = Mantle.func.approachExp(self._dragAlpha, targetAlpha, 24, ft)

    local handleColor = Color(
        Mantle.color.theme.r,
        Mantle.color.theme.g,
        Mantle.color.theme.b,
        math.floor(self._dragAlpha)
    )

    RNDX.Draw(handleR, handleX - HANDLE_W / 2, handleY - HANDLE_H / 2, HANDLE_W, HANDLE_H, handleColor)

    draw.SimpleText(
        formatValue(self.value, self.decimals),
        'Fated.16',
        barEnd + HANDLE_W / 2 + 6,
        BAR_Y + BAR_H / 2,
        handleColor,
        TEXT_ALIGN_LEFT,
        TEXT_ALIGN_CENTER
    )

    draw.SimpleText(tostring(self.min_value), 'Fated.14', barStart, BAR_Y + BAR_H + 12, Mantle.color.gray)
    draw.SimpleText(tostring(self.max_value), 'Fated.14', barEnd, BAR_Y + BAR_H + 12, Mantle.color.gray, TEXT_ALIGN_RIGHT)
end

function PANEL:OnMousePressed(mcode)
    if mcode != MOUSE_LEFT then return end
    local mx = self:CursorPos()
    self:UpdateSliderByCursorPos(mx)
    self.dragging = true
    self:MouseCapture(true)
end

function PANEL:OnMouseReleased(mcode)
    if mcode != MOUSE_LEFT then return end
    self.dragging = false
    self:MouseCapture(false)
end

function PANEL:OnCursorMoved(x)
    if self.dragging then
        self:UpdateSliderByCursorPos(x)
    end
end

vgui.Register('MantleSlideBox', PANEL, 'Panel')
