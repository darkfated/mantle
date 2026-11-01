local PANEL = {}

local math_floor = math.floor
local math_ceil = math.ceil
local math_max = math.max
local math_min = math.min
local math_huge = math.huge
local syncCounter = 0

local HEIGHT = 68
local SIDE_PADDING = 16
local BAR_Y = 36
local BAR_H = 5
local HANDLE_R = 7
local TITLE_Y = 11
local LABEL_Y = 56
local TRACK_INSET = 8
local HOVER_SPEED = 16
local DRAG_SPEED = 14

local function isFinite(value)
    return isnumber(value) and value == value and value != math_huge and value != -math_huge
end

local function normalizeDecimals(decimals)
    decimals = tonumber(decimals) or 0
    if !isFinite(decimals) then decimals = 0 end

    return math.Clamp(math_floor(decimals), 0, 6)
end

local function roundValue(value, decimals)
    if decimals <= 0 then
        if value >= 0 then
            return math_floor(value + 0.5)
        end

        return math_ceil(value - 0.5)
    end

    local scale = 10 ^ decimals
    local scaled = value * scale
    if !isFinite(scaled) then return value end

    if scaled >= 0 then
        return math_floor(scaled + 0.5000001) / scale
    end

    return math_ceil(scaled - 0.5000001) / scale
end

local function formatValue(value, decimals)
    if math.abs(value) >= 100000000000000 then
        return tostring(value)
    end

    if decimals > 0 then
        return string.format('%.' .. decimals .. 'f', value)
    end

    return tostring(roundValue(value, 0))
end

local function getTrackBounds(width)
    local start = SIDE_PADDING + TRACK_INSET
    local finish = width - SIDE_PADDING - TRACK_INSET

    return start, finish, math_max(0, finish - start)
end


local function textSub(text, length)
    if utf8 and utf8.sub then
        return utf8.sub(text, 1, length)
    end

    return string.sub(text, 1, length)
end

local function fitText(text, font, maxWidth)
    if maxWidth <= 0 then return '' end

    surface.SetFont(font)
    if surface.GetTextSize(text) <= maxWidth then return text end

    local length = utf8 and utf8.len and utf8.len(text) or #text
    if !length or length <= 0 then return '' end

    local suffix = '...'
    local suffixWidth = surface.GetTextSize(suffix)
    if suffixWidth > maxWidth then return '' end

    local low, high = 0, length
    local result = suffix

    while low <= high do
        local middle = math_floor((low + high) * 0.5)
        local candidate = textSub(text, middle) .. suffix

        if surface.GetTextSize(candidate) <= maxWidth then
            result = candidate
            low = middle + 1
        else
            high = middle - 1
        end
    end

    return result
end

local function getProgress(self)
    local range = self.maxValue - self.minValue
    if range <= 0 then return 0 end

    return math.Clamp((self.value - self.minValue) / range, 0, 1)
end

function PANEL:Init()
    self:DockMargin(8, 8, 8, 8)
    self:SetTall(HEIGHT)
    self:SetCursor('hand')

    self.text = ''
    self.minValue = 0
    self.maxValue = 1
    self.decimals = 0
    self.value = 0
    self.convar = nil

    self.dragging = false
    self.smoothProgress = 0
    self._hoverLerp = 0
    self._dragLerp = 0
    self._syncTimerName = nil
    self._convar_last = nil

    self.OnValueChanged = function() end
end

function PANEL:_removeConVarSync()
    if !self._syncTimerName then return end

    timer.Remove(self._syncTimerName)
    self._syncTimerName = nil
end

function PANEL:_writeConVar(value)
    if !self.convar or self.convar == '' then return end

    local valueString = formatValue(value, self.decimals)
    RunConsoleCommand(self.convar, valueString)
    self._convar_last = value
end

function PANEL:_createConVarSync()
    self:_removeConVarSync()
    if !self.convar or self.convar == '' then return end

    syncCounter = syncCounter + 1
    local timerName = 'MantleSlideSync' .. syncCounter
    self._syncTimerName = timerName

    timer.Create(timerName, 0.15, 0, function()
        if !IsValid(self) then
            timer.Remove(timerName)
            return
        end

        if !self.convar or self.convar == '' then return end

        local cvar = GetConVar(self.convar)
        if !cvar then return end

        local convarValue = cvar:GetFloat()
        if !isFinite(convarValue) then return end

        if self._convar_last == nil or convarValue != self._convar_last then
            self:SetValue(convarValue, true)

            if self.value != convarValue then
                self:_writeConVar(self.value)
            else
                self._convar_last = convarValue
            end
        end
    end)
end

function PANEL:OnRemove()
    if self.dragging then
        self.dragging = false
        self:MouseCapture(false)
    end

    self:_removeConVarSync()
end

function PANEL:SetRange(minValue, maxValue, decimals)
    minValue = tonumber(minValue)
    maxValue = tonumber(maxValue)

    if !isFinite(minValue) then minValue = 0 end
    if !isFinite(maxValue) then maxValue = 1 end

    if maxValue < minValue then
        minValue, maxValue = maxValue, minValue
    end

    self.minValue = minValue
    self.maxValue = maxValue
    self.decimals = normalizeDecimals(decimals)

    if self.convar then
        local cvar = GetConVar(self.convar)
        local convarValue = cvar and cvar:GetFloat()

        if isFinite(convarValue) then
            self:SetValue(convarValue, true)
            if self.value != convarValue then
                self:_writeConVar(self.value)
            else
                self._convar_last = convarValue
            end
            return
        end
    end

    self:SetValue(self.value, true)
end

function PANEL:SetConvar(name)
    self:_removeConVarSync()

    if !isstring(name) or name == '' then
        self.convar = nil
        self._convar_last = nil
        return
    end

    self.convar = name
    self._convar_last = nil

    local cvar = GetConVar(name)
    if cvar then
        local convarValue = cvar:GetFloat()
        if isFinite(convarValue) then
            self:SetValue(convarValue, true)

            if self.value != convarValue then
                self:_writeConVar(self.value)
            else
                self._convar_last = convarValue
            end
        end
    end

    self:_createConVarSync()
end

function PANEL:SetText(text)
    self.text = tostring(text or '')
end

function PANEL:GetText()
    return self.text
end

function PANEL:SetValue(value, fromConVar)
    value = tonumber(value)
    if !isFinite(value) then return false end

    value = math.Clamp(value, self.minValue, self.maxValue)
    value = roundValue(value, self.decimals)
    value = math.Clamp(value, self.minValue, self.maxValue)

    if self.value == value then return false end

    self.value = value

    if self.convar and !fromConVar then
        self:_writeConVar(value)
    elseif fromConVar then
        self._convar_last = value
    end

    self:OnValueChanged(value)
    return true
end

function PANEL:GetValue()
    return self.value
end

function PANEL:GetFraction()
    return getProgress(self)
end

function PANEL:SetDecimals(decimals)
    self.decimals = normalizeDecimals(decimals)
    self:SetValue(self.value, true)

    if self.convar then
        self:_writeConVar(self.value)
    end
end

function PANEL:_updateFromCursor(x)
    local start, _, trackWidth = getTrackBounds(self:GetWide())
    if trackWidth <= 0 then return end

    local fraction = math.Clamp((x - start) / trackWidth, 0, 1)
    local value = self.minValue + fraction * (self.maxValue - self.minValue)

    self:SetValue(value)
end

function PANEL:Paint(w, h)
    if w <= 0 or h <= 0 then return end

    local ft = FrameTime()
    local enabled = self:IsEnabled()
    local hovered = enabled and self:IsHovered()

    self._hoverLerp = Mantle.func.approachExp(self._hoverLerp, hovered and 1 or 0, HOVER_SPEED, ft)
    self._dragLerp = Mantle.func.approachExp(self._dragLerp, self.dragging and 1 or 0, DRAG_SPEED, ft)

    local start, _, trackWidth = getTrackBounds(w)
    local targetProgress = getProgress(self)
    self.smoothProgress = Mantle.func.approachExp(self.smoothProgress, targetProgress, 14, ft)

    if math.abs(self.smoothProgress - targetProgress) < 0.001 then
        self.smoothProgress = targetProgress
    end

    local fraction = math.Clamp(self.smoothProgress, 0, 1)
    local handleX = start + trackWidth * fraction
    local handleY = BAR_Y + BAR_H * 0.5

    local textColor = enabled and Mantle.color.text or Mantle.color.gray
    local valueColor = enabled and Mantle.color.theme or Mantle.color.gray
    local alpha = enabled and 255 or 110

    local valueText = formatValue(self.value, self.decimals)
    surface.SetFont('Fated.16')
    local valueWidth = surface.GetTextSize(valueText)
    local labelMaxWidth = w - SIDE_PADDING * 2 - valueWidth - 12

    if self.text != '' and labelMaxWidth > 0 then
        local label = fitText(self.text, 'Fated.16', labelMaxWidth)
        if label != '' then
            draw.SimpleText(label, 'Fated.16', SIDE_PADDING, TITLE_Y, textColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        end
    end

    draw.SimpleText(valueText, 'Fated.16', w - SIDE_PADDING, TITLE_Y, valueColor, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)

    if trackWidth > 0 then
        RNDX.Rect(start, BAR_Y, trackWidth, BAR_H)
            :Rad(BAR_H * 0.5)
            :Color(Color(Mantle.color.focus_panel.r, Mantle.color.focus_panel.g, Mantle.color.focus_panel.b, alpha))
        :Draw()

        local activeWidth = trackWidth * fraction
        if activeWidth > 0.5 then
            RNDX.Rect(start, BAR_Y, activeWidth, BAR_H)
                :Rad(BAR_H * 0.5)
                :Color(Color(Mantle.color.theme.r, Mantle.color.theme.g, Mantle.color.theme.b, alpha))
            :Draw()
        end

        if self._hoverLerp > 0.01 then
            local hover = Mantle.color.hover_overlay_strong
            local haloAlpha = math_floor(hover.a * self._hoverLerp * (enabled and 1 or 0))
            if haloAlpha > 0 then
                RNDX.Circle(handleX, handleY, HANDLE_R + 2)
                    :Color(Color(hover.r, hover.g, hover.b, haloAlpha))
                :Draw()
            end
        end

        local handleAlpha = math_floor(alpha * (1 - self._dragLerp))

        RNDX.Circle(handleX, handleY + 1, HANDLE_R + 0.5)
            :Color(Mantle.color.circle_shadow)
        :Draw()

        if handleAlpha > 0 then
            RNDX.Circle(handleX, handleY, HANDLE_R)
                :Color(Color(Mantle.color.theme.r, Mantle.color.theme.g, Mantle.color.theme.b, handleAlpha))
            :Draw()
        end
    end

    local minText = formatValue(self.minValue, self.decimals)
    local maxText = formatValue(self.maxValue, self.decimals)

    draw.SimpleText(minText, 'Fated.14', start, LABEL_Y, Mantle.color.gray, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
    draw.SimpleText(maxText, 'Fated.14', w - start, LABEL_Y, Mantle.color.gray, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
end

function PANEL:OnMousePressed(mouseCode)
    if mouseCode != MOUSE_LEFT or !self:IsEnabled() then return end

    local x = self:CursorPos()
    self:_updateFromCursor(x)

    self.dragging = true
    self:MouseCapture(true)
end

function PANEL:OnMouseReleased(mouseCode)
    if mouseCode != MOUSE_LEFT or !self.dragging then return end

    self.dragging = false
    self:MouseCapture(false)
end

function PANEL:OnMouseCaptureLost()
    self.dragging = false
end

function PANEL:OnCursorMoved(x)
    if !self.dragging then return end
    self:_updateFromCursor(x)
end

vgui.Register('MantleSlideBox', PANEL, 'Panel')
