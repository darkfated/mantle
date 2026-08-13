local PANEL = {}

function PANEL:Init()
    self.title = nil
    self.placeholder = Mantle.lang.get('mantle', 'entry_default_placeholder')
    self:SetTall(32)
    self.action = function() end

    self.font = 'Fated.18'
    self._focusLerp = 0
    self._hoverLerp = 0
    self._textOffset = 0

    self.textEntry = vgui.Create('DTextEntry', self)
    self.textEntry:Dock(FILL)
    self.textEntry:SetText('')
    self.textEntry.OnCloseFocus = function()
        self.action(self:GetValue())
    end
    self.textEntry.Paint = nil
    self.textEntry.PaintOver = function(s, w, h)
        self:_paintEntry(s, w, h)
    end
end

function PANEL:_paintEntry(s, w, h)
    local ft = FrameTime()

    self._focusLerp = Mantle.func.approachExp(self._focusLerp, s:IsEditing() and 1 or 0, 10, ft)
    self._hoverLerp = Mantle.func.approachExp(self._hoverLerp, s:IsHovered() and 1 or 0, 12, ft)

    if Mantle.ui.convar.depth_ui then
        RNDX.Rect(0, 0, w, h)
            :Rad(12)
            :Color(Mantle.color.window_shadow)
            :Shadow(4, 2)
        :Draw()
    end

    RNDX.Rect(0, 0, w, h)
        :Rad(12)
        :Color(Mantle.color.focus_panel)
    :Draw()

    if self._hoverLerp > 0.01 then
        local hv = Mantle.color.hover_overlay
        RNDX.Rect(0, 0, w, h)
            :Rad(12)
            :Color(Color(hv.r, hv.g, hv.b, math.floor(hv.a * self._hoverLerp)))
        :Draw()
    end

    if self._focusLerp > 0.01 then
        local theme = Mantle.color.theme
        RNDX.Rect(0, 0, w, h)
            :Rad(12)
            :Color(Color(theme.r, theme.g, theme.b, math.floor(60 * self._focusLerp)))
            :Shadow(4, self._focusLerp * 2)
        :Draw()
        RNDX.Rect(0, 0, w, h)
            :Rad(12)
            :Color(Color(theme.r, theme.g, theme.b, math.floor(160 * self._focusLerp)))
            :Outline(1)
        :Draw()
    end

    local value = self:GetValue() or ''
    surface.SetFont(self.font)
    local padding = 6
    local availableW = w - padding * 2

    local caret = #value
    local beforeCaret = string.sub(value, 1, caret)
    local caretX = surface.GetTextSize(beforeCaret)
    local textW = surface.GetTextSize(value)

    local desiredOffset = 0
    if caretX > availableW then
        desiredOffset = caretX - availableW
    end
    if textW - desiredOffset < availableW then
        desiredOffset = math.max(0, textW - availableW)
    end

    self._textOffset = Mantle.func.approachExp(self._textOffset, desiredOffset, 24, ft)

    local text = self.placeholder
    local col = Mantle.color.gray
    if value != '' then
        text = value
        col = Mantle.color.text
    end

    draw.SimpleText(text, self.font, padding - self._textOffset, h * 0.5, col, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
end

function PANEL:SetTitle(title)
    self.title = title
    self:SetTall(52)

    if IsValid(self.titlePanel) then
        self.titlePanel:Remove()
    end

    self.titlePanel = vgui.Create('DPanel', self)
    self.titlePanel:Dock(TOP)
    self.titlePanel:DockMargin(0, 0, 0, 6)
    self.titlePanel:SetTall(18)
    self.titlePanel.Paint = function(_, w, h)
        draw.SimpleText(self.title, 'Fated.18', 0, 0, Mantle.color.text)
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