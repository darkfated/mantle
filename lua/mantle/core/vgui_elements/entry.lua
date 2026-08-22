local PANEL = {}
AccessorFunc(PANEL, "m_iMaxLength", "MaxLength", FORCE_NUMBER)
AccessorFunc(PANEL, "m_bPasswordMode", "Password", FORCE_BOOL)
AccessorFunc(PANEL, "m_sPasswordSymbol", "PasswordSymbol", FORCE_STRING)

local HEIGHT = 32
local RADIUS = 12
local TITLE_H = 18
local TITLE_GAP = 6

local function mul_str(str, n)
    if not isstring(str) or not isnumber(n) then return "" end
    local needed = ""
    for _ = 1, n do needed = needed .. str end
    return needed
end

function PANEL:Init()
    self:DockMargin(8, 8, 8, 8)

    self.title = nil
    self.placeholder = Mantle.lang.get('mantle', 'entry_default_placeholder')

    self:SetTall(HEIGHT)
    self:SetTooltipPanelOverride("MantleTooltip")
    self:SetMaxLength(-1)
    self:SetPassword(false)
    self:SetPasswordSymbol("*")

    self.font = 'Fated.18'
    self._focusLerp = 0
    self._textOffset = 0
    self._caretSize = 2

    self.textEntry = vgui.Create('DTextEntry', self)
    self.textEntry:Dock(FILL)
    self.textEntry:SetText('')
    self.textEntry.OnLoseFocus = function(s)
        self:OnEditingDone(s:GetValue())
    end
    self.textEntry.OnEnter = function(_, strValue)
        self:OnEditingDone(strValue)
    end
    self.textEntry.OnChange = function(s)
        self:OnChange(s:GetValue())
    end
    self.textEntry.OnValueChange = function(_, strValue)
        self:OnEditingDone(strValue)
    end
    self.textEntry.OnKeyCode = function(_, numKeyCode)
        self:OnKeyCode(numKeyCode)
    end
    self.textEntry.CheckNumeric = function(s, strValue)
        if not s:GetNumeric() then return true end
        return string.find(strAllowedNumericCharacters, strValue, 1, true) ~= nil
    end
    self.textEntry.AllowInput = function(s, strValue)
        local max_len = self:GetMaxLength()
        local len = utf8.len(s:GetValue())
        if max_len > 0 and len > max_len then return true end
        return isfunction(self.AllowInput) and self:AllowInput(strValue) or nil
    end
    self.textEntry.OnLoseFocus = function(s)
        self:OnEditingDone(s:GetValue())
    end
    self.textEntry.Paint = nil
    self.textEntry.PaintOver = function(s, w, h)
        self:_paintEntry(s, w, h)
    end
end

function PANEL:_paintEntry(s, w, h)
    local ft = FrameTime()

    self._focusLerp = Mantle.func.approachExp(self._focusLerp, s:IsEditing() and 1 or 0, 10, ft)

    RNDX.Rect(0, 0, w, h)
        :Rad(RADIUS)
        :Color(Mantle.color.focus_panel)
    :Draw()

    if self._focusLerp > 0.01 then
        local theme = Mantle.color.theme
        RNDX.Rect(0, 0, w, h)
            :Rad(RADIUS)
            :Color(Color(theme.r, theme.g, theme.b, math.floor(160 * self._focusLerp)))
            :Outline(1)
        :Draw()
    end

    local value = self:GetValue() or ''
    value = self:GetPassword() and mul_str(self:GetPasswordSymbol(), #value) or value
    surface.SetFont(self.font)
    local padding = 6
    local availableW = w - padding * 2
    local textW = surface.GetTextSize(value)
    local desiredOffset = math.max(0, textW - availableW)

    self._textOffset = Mantle.func.approachExp(self._textOffset, desiredOffset, 24, ft)

    local text = self.placeholder
    local col = Mantle.color.gray
    if value != '' then
        text = value
        col = Mantle.color.text
    end

    draw.SimpleText(text, self.font, padding - self._textOffset, h * 0.5, col, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)

    if s:IsEditing() then
        local caret = #value
        local before_caret = string.sub(value, 1, caret)

        surface.SetFont(self.font)
        local caret_x = surface.GetTextSize(before_caret)

        if not s.caret_col then s.caret_col = Mantle.color.text:Copy() end
        s.caret_col.a = math.abs(math.floor(255 * math.sin(CurTime() * 3.2)))
        surface.SetDrawColor(s.caret_col:Unpack())
        surface.DrawRect(padding - self._textOffset + caret_x, 5, self._caretSize, h - 10)
    else
        s.caret_col = nil
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

function PANEL:RemoveTitle()
    if IsValid(self.titlePanel) then
        self.titlePanel:Remove()
        self.title = nil
        self:SetTall(HEIGHT)
    end
end

function PANEL:SetPlaceholder(placeholder)
    self.placeholder = placeholder
end

function PANEL:GetPlaceholder()
    return self.placeholder
end

function PANEL:SetValue(value)
    self.textEntry:SetValue(value)
    self.textEntry:SetCaretPos(#value)
end

function PANEL:SetText(txt)
    self.textEntry:SetText(txt)
    self.textEntry:SetCaretPos(#txt)
end

function PANEL:GetValue()
    return self.textEntry:GetValue()
end
PANEL.GetText = PANEL.GetValue

function PANEL:GetFloat()
    return tonumber(self:GetValue())
end
PANEL.GetNumber = PANEL.GetFloat

function PANEL:GetInt()
    local v = self:GetFloat()
    return isnumber(v) and math.floor(v) or nil
end

function PANEL:GetUSInt()
    local v = self:GetInt()
    return isnumber(v) and math.abs(v) or nil
end

function PANEL:TogglePassword()
    self:SetPassword(not self:GetPassword())
end

function PANEL:SetNumeric( bool )
    self.textEntry:SetNumeric(bool)
end

function PANEL:GetNumeric()
    return self.textEntry:GetNumeric()
end

vgui.Register('MantleEntry', PANEL, 'EditablePanel')
