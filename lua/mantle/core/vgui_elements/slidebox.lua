local PANEL = {}
local math_floor = math.floor

local TOP_PADDING = 12
local SIDE_PADDING = 16
local BAR_Y = 36
local BAR_H = 5
local HANDLE_R = 7
local TRACK_INSET = 8
local VALUE_GAP = 12

local function formatValue(val, decimals)
    if decimals and decimals > 0 then
        return string.format('%.' .. decimals .. 'f', val)
    end
    return tostring(math.Round(val))
end

local function getValueWidth(maxValue, decimals)
    surface.SetFont('Fated.16')
    return surface.GetTextSize(formatValue(maxValue, decimals)) + VALUE_GAP
end

function PANEL:Init()
    self.text = ''
    self.min_value = 0
    self.max_value = 1
    self.decimals = 0
    self.convar = nil

    self.value = 0
    self.smoothProgress = 0
    self.dragging = false
    self._dragLerp = 0
    self._hoverLerp = 0

    self:SetTall(68)
    self:SetCursor('hand')
    self.OnValueChanged = function() end

    self._convar_last = nil
    self._convar_timer_name = self:CreateConVarSyncTimer()
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

    if self.convar and not fromConVar then
        LocalPlayer():ConCommand(self.convar .. ' ' .. tostring(self.value))
        self._convar_last = self.value
    end

    self:OnValueChanged(self.value)
end

function PANEL:GetValue()
    return self.value
end

local function getProgress(self)
    local denom = self.max_value - self.min_value
    if denom <= 0 then return 0 end
    return math.Clamp((self.value - self.min_value) / denom, 0, 1)
end

local function getTrackBounds(self, w)
    local start = SIDE_PADDING + TRACK_INSET
    local end_ = w - SIDE_PADDING - getValueWidth(self.max_value, self.decimals)
    return start, end_, math.max(0, end_ - start)
end

function PANEL:SetFromProgress(progress)
    progress = math.Clamp(progress, 0, 1)
    local val = self.min_value + progress * (self.max_value - self.min_value)

    if self.decimals > 0 then
        val = tonumber(string.format('%.' .. self.decimals .. 'f', val)) or val
    else
        val = math.Round(val)
    end

    self:SetValue(val)
end

function PANEL:UpdateFromCursor(absX)
    local _, _, barW = getTrackBounds(self, self:GetWide())
    local start = SIDE_PADDING + TRACK_INSET
    if barW <= 0 then return end
    self:SetFromProgress(math.Clamp((absX - start) / barW, 0, 1))
end

function PANEL:Paint(w, h)
    local ft = FrameTime()
    local start, end_, barW = getTrackBounds(self, w)

    local activeW = barW * getProgress(self)
    self.smoothProgress = Mantle.func.approachExp(self.smoothProgress, activeW, 14, ft)

    local dragTarget = self.dragging and 1 or 0
    self._dragLerp = Mantle.func.approachExp(self._dragLerp, dragTarget, 14, ft)
    self._hoverLerp = Mantle.func.approachExp(self._hoverLerp, self:IsHovered() and 1 or 0, 16, ft)

    draw.SimpleText(self.text, 'Fated.16', SIDE_PADDING, TOP_PADDING - 6, Mantle.color.text)

    RNDX.Rect(start, BAR_Y, barW, BAR_H)
        :Rad(BAR_H * 0.5)
        :Color(Mantle.color.focus_panel)
    :Draw()

    if self.smoothProgress > 1 then
        RNDX.Rect(start, BAR_Y, self.smoothProgress, BAR_H)
            :Rad(BAR_H * 0.5)
            :Color(Mantle.color.theme)
        :Draw()
    end

    local handleX = start + self.smoothProgress
    local handleY = BAR_Y + BAR_H * 0.5
    local handleR = HANDLE_R
    local dragAlpha = math.floor((1 - self._dragLerp) * 255)

    RNDX.Circle(handleX, handleY, handleR)
        :Color(Mantle.color.window_shadow)
        :Shadow(4, 2)
    :Draw()

    if self._hoverLerp > 0.01 then
        local hv = Mantle.color.hover_overlay_strong
        RNDX.Circle(handleX, handleY, handleR + 2)
            :Color(Color(hv.r, hv.g, hv.b, math_floor(hv.a * self._hoverLerp)))
        :Draw()
    end

    RNDX.Circle(handleX, handleY, handleR)
        :Color(Color(Mantle.color.theme.r, Mantle.color.theme.g, Mantle.color.theme.b, dragAlpha))
    :Draw()

    local valueStr = formatValue(self.value, self.decimals)
    draw.SimpleText(valueStr, 'Fated.16', end_ + VALUE_GAP, handleY, Mantle.color.theme, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)

    draw.SimpleText(tostring(self.min_value), 'Fated.14', start, BAR_Y + BAR_H + 12, Mantle.color.gray)
    draw.SimpleText(tostring(self.max_value), 'Fated.14', end_, BAR_Y + BAR_H + 12, Mantle.color.gray, TEXT_ALIGN_RIGHT)
end

function PANEL:OnMousePressed(mcode)
    if mcode != MOUSE_LEFT then return end
    self:UpdateFromCursor(self:CursorPos())
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
        self:UpdateFromCursor(x)
    end
end

vgui.Register('MantleSlideBox', PANEL, 'Panel')
