local PANEL = {}

local math_floor = math.floor
local math_max = math.max
local math_abs = math.abs
local math_curtime = CurTime

local HEIGHT = 32
local RADIUS = 12
local TITLE_H = 18
local TITLE_GAP = 6
local LERP_SNAP = 0.005
local OFFSET_SNAP = 0.5
local CARET_ALPHA_SNAP = 2

function PANEL:Init()
    self:DockMargin(8, 8, 8, 8)
    self.title = nil
    self.placeholder = Mantle.lang.get('mantle', 'entry_default_placeholder')
    self:SetTall(HEIGHT)
    self.action = function() end

    self.font = 'Fated.18'
    self._focusLerp = 0
    self._textOffset = 0
    self._caretSize = 2
    self._caretAlpha = 0
    self._caretColor = Mantle.color.gray:Copy()

    self._lastValue = nil
    self._lastTextW = nil
    self._lastAvailableW = nil

    self.textEntry = vgui.Create('DTextEntry', self)
    self.textEntry:Dock(FILL)
    self.textEntry:SetText('')
    self.textEntry.OnLoseFocus = function(s)
        self.action(s:GetValue())
    end
    self.textEntry.Paint = nil
    self.textEntry.PaintOver = function(s, w, h)
        self:_paintEntry(s, w, h)
    end
end

function PANEL:_paintEntry(s, w, h)
    local ft = FrameTime()
    local editing = s:IsEditing()

    local focusTarget = editing and 1 or 0
    if self._focusLerp != focusTarget then
        self._focusLerp = Mantle.func.approachExp(self._focusLerp, focusTarget, 10, ft)
        if math_abs(self._focusLerp - focusTarget) < LERP_SNAP then
            self._focusLerp = focusTarget
        end
    end

    RNDX.Rect(0, 0, w, h)
        :Rad(RADIUS)
        :Color(Mantle.color.focus_panel)
    :Draw()

    if self._focusLerp > 0.01 then
        local theme = Mantle.color.theme
        RNDX.Rect(0, 0, w, h)
            :Rad(RADIUS)
            :Color(Color(theme.r, theme.g, theme.b, math_floor(160 * self._focusLerp)))
            :Outline(1)
        :Draw()
    end

    local value = s:GetValue()
    surface.SetFont(self.font)

    local padding = 6
    local availableW = w - padding * 2
    local textW

    if value == self._lastValue and availableW == self._lastAvailableW and self._lastTextW then
        textW = self._lastTextW
    else
        textW = surface.GetTextSize(value)
        self._lastValue = value
        self._lastAvailableW = availableW
        self._lastTextW = textW
    end

    local desiredOffset = math_max(0, textW - availableW)

    if self._textOffset != desiredOffset then
        self._textOffset = Mantle.func.approachExp(self._textOffset, desiredOffset, 24, ft)
        if math_abs(self._textOffset - desiredOffset) < OFFSET_SNAP then
            self._textOffset = desiredOffset
        end
    end

    local text = self.placeholder
    local col = Mantle.color.gray
    if value != '' then
        text = value
        col = Mantle.color.text
    end

    local drawX = padding - self._textOffset
    draw.SimpleText(text, self.font, drawX, h * 0.5, col, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)

    if editing then
        local blinkTarget = math_floor(math_curtime() * 1.5) % 2 == 0 and 255 or 0

        if math_abs(self._caretAlpha - blinkTarget) > CARET_ALPHA_SNAP then
            self._caretAlpha = Mantle.func.approachExp(self._caretAlpha, blinkTarget, 16, ft)
            if math_abs(self._caretAlpha - blinkTarget) < CARET_ALPHA_SNAP then
                self._caretAlpha = blinkTarget
            end
        end

        self._caretColor.a = self._caretAlpha

        RNDX.Rect(drawX + textW, 5, self._caretSize, h - 10)
            :Color(self._caretColor)
        :Draw()
    else
        if self._caretAlpha != 0 then
            self._caretAlpha = 0
        end
    end
end

function PANEL:SetTitle(title)
    self.title = title
    self:SetTall(HEIGHT + TITLE_H + TITLE_GAP)

    if IsValid(self.titlePanel) then
        self.titlePanel:Remove()
    end

    self.titlePanel = vgui.Create('Panel', self)
    self.titlePanel:Dock(TOP)
    self.titlePanel:DockMargin(0, 0, 0, TITLE_GAP)
    self.titlePanel:SetTall(TITLE_H)
    self.titlePanel.Paint = function(_, w, h)
        draw.SimpleText(self.title, 'Fated.16', 0, 0, Mantle.color.text)
    end
end

function PANEL:SetPlaceholder(placeholder)
    self.placeholder = placeholder
end

function PANEL:GetValue()
    return self.textEntry:GetText()
end

function PANEL:SetValue(value)
    self.textEntry:SetValue(value)
end

vgui.Register('MantleEntry', PANEL, 'EditablePanel')
