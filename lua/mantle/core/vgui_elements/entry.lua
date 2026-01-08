local PANEL = {}

local HEIGHT = 34
local PADDING = 10
local RADIUS = 12

function PANEL:Init()
    self.title = nil
    self.placeholder = Mantle.lang.get('mantle', 'entry_default_placeholder')
    self:SetTall(HEIGHT)
    self.action = function() end

    self._text_offset = 0
    self._shadowLerp = 5
    self._editing = false

    local font = 'Fated.Regular'
    surface.SetFont(font)
    self._font = font

    self.textEntry = vgui.Create('DTextEntry', self)
    self.textEntry:Dock(FILL)
    self.textEntry:SetText('')
    self.textEntry.Paint = function() end

    self.textEntry.OnGetFocus = function()
        self._editing = true
    end

    self.textEntry.OnLoseFocus = function()
        self._editing = false
        self.action(self:GetValue())
    end

    self.textEntry.OnEnter = function()
        self.action(self:GetValue())
        self.textEntry:KillFocus()
    end
end

function PANEL:SetTitle(title)
    self.title = title

    if IsValid(self.titlePanel) then
        self.titlePanel:Remove()
        self.titlePanel = nil
    end

    if title then
        self:SetTall(HEIGHT + 20)
        self.titlePanel = vgui.Create('Panel', self)
        self.titlePanel:Dock(TOP)
        self.titlePanel:DockMargin(0, 0, 0, 6)
        self.titlePanel:SetTall(18)
        self.titlePanel.Paint = function(_, w, h)
            draw.SimpleText(self.title, 'Fated.RegularPlus', 0, 0, Mantle.color.text)
        end
    else
        self:SetTall(HEIGHT)
    end
end

function PANEL:SetPlaceholder(text)
    self.placeholder = text
end

function PANEL:GetValue()
    return self.textEntry:GetValue()
end

function PANEL:SetValue(value)
    self.textEntry:SetValue(tostring(value or ''))
end

function PANEL:SetAction(fn)
    if isfunction(fn) then
        self.action = fn
    end
end

function PANEL:Think()
    local ft = FrameTime()
    local target = self._editing and 8 or 4
    self._shadowLerp = Mantle.func.approachExp(self._shadowLerp, target, 4, ft)

    local value = self:GetValue() or ''
    surface.SetFont(self._font)
    local w = self:GetWide()
    local available_w = math.max(0, w - PADDING * 2)

    local caret_pos = self.textEntry:GetCaretPos()
    local before = string.sub(value, 1, caret_pos)
    local caret_x = surface.GetTextSize(before)
    local text_w = surface.GetTextSize(value)

    local desired_offset = 0
    if caret_x > available_w then
        desired_offset = caret_x - available_w
    end
    if text_w - desired_offset < available_w then
        desired_offset = math.max(0, text_w - available_w)
    end

    self._text_offset = Mantle.func.approachExp(self._text_offset, desired_offset, 24, ft)
end

function PANEL:Paint(w, h)
    local drawY = 0
    if IsValid(self.titlePanel) then
        drawY = self.titlePanel:GetTall() + 6
    end

    RNDX().Rect(0, drawY, w, h - drawY)
        :Rad(RADIUS)
        :Color(Mantle.color.entry_panel)
        :Shape(RNDX.SHAPE_IOS)
    :Draw()

    local value = self:GetValue() or ''
    local font = self._font
    surface.SetFont(font)

    local textX = PADDING - self._text_offset
    local textY = drawY + (h - drawY) * 0.5

    local drawText = self.placeholder
    local col = Mantle.color.text_muted
    if value != '' then
        drawText = value
        col = Mantle.color.text
    end

    draw.SimpleText(drawText, font, textX, textY, col, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
end

vgui.Register('MantleEntry', PANEL, 'EditablePanel')
