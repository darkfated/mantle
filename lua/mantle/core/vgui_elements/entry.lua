local PANEL = {}
AccessorFunc(PANEL, "m_iMaxLength", "MaxLength", FORCE_NUMBER)
AccessorFunc(PANEL, "m_bPasswordMode", "Password", FORCE_BOOL)
AccessorFunc(PANEL, "m_sPasswordSymbol", "PasswordSymbol", FORCE_STRING)

local HEIGHT = 32
local RADIUS = 12
local TITLE_H = 18
local TITLE_GAP = 6
local strAllowedNumericCharacters = "1234567890.-"

function PANEL:Init()
	self:DockMargin(8, 8, 8, 8)

	self.title = nil
	self.placeholder = Mantle.lang.get("mantle", "entry_default_placeholder")
	self.action = function() end

	self:SetTall(HEIGHT)
	self:SetTooltipPanelOverride("MantleTooltip")
	self:SetMaxLength(-1)
	self:SetPassword(false)
	self:SetPasswordSymbol("*")

	self.font = "Fated.18"
	self._focusLerp = 0
	self._textOffset = 0
	self._caretSize = 2
	self._caretAlpha = 0
	self._caretColor = Mantle.color.gray:Copy()

	self.textEntry = vgui.Create("DTextEntry", self)
	self.textEntry:SetTooltipPanelOverride("MantleTooltip")
	self.textEntry:Dock(FILL)
	self.textEntry:SetText("")
	self.textEntry.OnLoseFocus = function(s)
		self.action(s:GetValue())
		self:OnEditingDone(s:GetValue())
	end
	self.textEntry.OnEnter = function(_, strValue)
		self.action(strValue)
		self:OnEditingDone(strValue)
	end
	self.textEntry.OnChange = function(s)
		self:OnChange(s:GetValue())
	end
	self.textEntry.OnValueChange = function(_, strValue)
		self.action(strValue)
		self:OnEditingDone(strValue)
	end
	self.textEntry.OnKeyCode = function(_, numKeyCode)
		self:OnKeyCode(numKeyCode)
	end
	self.textEntry.CheckNumeric = function(s, strValue)
		if not s:GetNumeric() then
			return true
		end
		return string.find(strAllowedNumericCharacters, strValue, 1, true) ~= nil
	end
	self.textEntry.AllowInput = function(s, strValue)
		local max_len = self:GetMaxLength()
		local len = utf8.len(s:GetValue())
		if max_len > 0 and len > max_len then
			return true
		end
		return isfunction(self.AllowInput) and self:AllowInput(strValue) or nil
	end
	self.textEntry.Paint = nil
	self.textEntry.PaintOver = function(s, w, h)
		self:_paintEntry(s, w, h)
	end
end

function PANEL:_paintEntry(s, w, h)
	local ft = FrameTime()

	self._focusLerp = Mantle.func.approachExp(self._focusLerp, s:IsEditing() and 1 or 0, 10, ft)

	RNDX.Rect(0, 0, w, h):Rad(RADIUS):Color(Mantle.color.focus_panel):Draw()

	if self._focusLerp > 0.01 then
		local theme = Mantle.color.theme
		RNDX.Rect(0, 0, w, h)
			:Rad(RADIUS)
			:Color(Color(theme.r, theme.g, theme.b, math.floor(160 * self._focusLerp)))
			:Outline(1)
			:Draw()
	end

	local _value = self:GetValue() or ""
	local value = self:GetPassword() and string.rep(self:GetPasswordSymbol(), utf8.len(_value)) or _value
	surface.SetFont(self.font)
	local padding = 6
	local availableW = w - padding * 2
	local textW = surface.GetTextSize(value)
	local desiredOffset = math.max(0, textW - availableW)

	self._textOffset = Mantle.func.approachExp(self._textOffset, desiredOffset, 24, ft)

	local text = self.placeholder
	local col = Mantle.color.gray
	if value ~= "" then
		text = value
		col = Mantle.color.text
	end

	draw.SimpleText(text, self.font, padding - self._textOffset, h * 0.5, col, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)

	if s:IsEditing() then
		local blinkTarget = math.floor(CurTime() * 1.5) % 2 == 0 and 255 or 0
		self._caretAlpha = Mantle.func.approachExp(self._caretAlpha, blinkTarget, 16, ft)
		self._caretColor.a = self._caretAlpha
		surface.SetDrawColor(self._caretColor:Unpack())
		local caret_x = surface.GetTextSize(string.sub(value, 1, #value))
		surface.DrawRect(padding - self._textOffset + caret_x, 5, self._caretSize, h - 10)
	else
		self._caretAlpha = 0
	end
end

function PANEL:SetTitle(title)
	self.title = title
	self:SetTall(HEIGHT + TITLE_H + TITLE_GAP)

	if IsValid(self.titlePanel) then
		self.titlePanel:Remove()
	end

	self.titlePanel = vgui.Create("Panel", self)
	self.titlePanel:Dock(TOP)
	self.titlePanel:DockMargin(0, 0, 0, TITLE_GAP)
	self.titlePanel:SetTall(TITLE_H)
	self.titlePanel.Paint = function()
		draw.SimpleText(self.title, "Fated.16", 0, 0, Mantle.color.text)
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

function PANEL:SetNumeric(bool)
	self.textEntry:SetNumeric(bool)
end

function PANEL:GetNumeric()
	return self.textEntry:GetNumeric()
end

function PANEL:OnEditingDone(strValue) end

function PANEL:OnChange(strValue) end

function PANEL:OnKeyCode(numKeyCode) end

function PANEL:AllowInput(strValue) end

vgui.Register("MantleEntry", PANEL, "EditablePanel")
