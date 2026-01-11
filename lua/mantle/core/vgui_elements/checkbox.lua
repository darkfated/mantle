local PANEL = {}

local HEIGHT = 30
local PADDING_LEFT = 12
local PADDING_RIGHT = 12
local KNOB_PADDING = 2

function PANEL:Init()
    self:SetTall(HEIGHT)
    self:SetText('')

    self.isChecked = false

    self.anim = 0
    self.animTarget = 0
    self.animSpeed = 10
    self.animEased = 0

    self.txt = ''
    self.txtWide = 0

    self._convarName = nil
    self._convar = nil
    self._onChange = nil

    self.DoClick = function()
        Mantle.func.sound()
        self:SetValue(not self.isChecked, true)
    end
end

function PANEL:SetTxt(text)
    self.txt = tostring(text or '')
    surface.SetFont('Fated.Regular')
    self.txtWide = surface.GetTextSize(self.txt)
end

function PANEL:SetConvar(name)
    if not name then return end

    self._convarName = tostring(name)
    self._convar = GetConVar(self._convarName)

    if self._convar then
        local val = tobool(self._convar:GetBool())

        self.isChecked = val
        self.animTarget = val and 1 or 0
        self.anim = self.animTarget
        self.animEased = self.animTarget
    end
end

function PANEL:OnChange(fn)
    self._onChange = isfunction(fn) and fn or nil
end

function PANEL:SetValue(val, userInitiated)
    val = tobool(val)
    if self.isChecked == val then return end

    self.isChecked = val
    self.animTarget = val and 1 or 0

    if userInitiated and self._convarName then
        RunConsoleCommand(self._convarName, val and '1' or '0')
    end

    if userInitiated and self._onChange then
        self._onChange(self, val)
    end
end

function PANEL:GetValue()
    return self.isChecked
end

function PANEL:Think()
    local ft = FrameTime()

    self.anim = Mantle.func.approachExp(
        self.anim,
        self.animTarget,
        self.animSpeed,
        ft
    )

    self.animEased = Mantle.func.easeOutCubic(self.anim)
end

function PANEL:Paint(w, h)
    local trackH = 18
    local trackW = 40

    local trackX = w - PADDING_RIGHT - trackW
    local trackY = math.floor((h - trackH) * 0.5)

    local knobSize = trackH - KNOB_PADDING * 2
    local knobY = trackY + KNOB_PADDING

    RNDX().Rect(0, 0, w, h)
        :Rad(10)
        :Color(Mantle.color.p)
        :Shape(RNDX.SHAPE_IOS)
    :Draw()

    RNDX().Rect(0, 0, w, h)
        :Rad(10)
        :Color(Mantle.color.p_outline)
        :Outline(1)
        :Shape(RNDX.SHAPE_IOS)
    :Draw()

    local trackColor = Mantle.func.LerpColor(
        self.animEased * 8,
        Mantle.color.checkbox_panel,
        Mantle.color.theme
    )

    RNDX().Rect(trackX, trackY, trackW, trackH)
        :Rad(trackH * 0.5)
        :Color(trackColor)
        :Shape(RNDX.SHAPE_IOS)
    :Draw()

    RNDX().Rect(trackX, trackY, trackW, trackH)
        :Rad(trackH * 0.5)
        :Color(Mantle.color.p_outline)
        :Outline(1)
        :Shape(RNDX.SHAPE_IOS)
    :Draw()

    local knobMin = trackX + KNOB_PADDING + 1
    local knobMax = trackX + trackW - KNOB_PADDING - knobSize - 1
    local knobX = Lerp(self.animEased, knobMin, knobMax)

    RNDX().Rect(knobX + 1, knobY + 1, knobSize - 2, knobSize - 2)
        :Rad(knobSize * 0.5)
        :Color(color_white)
        :Shape(RNDX.SHAPE_CIRCLE)
    :Draw()

    draw.SimpleText(self.txt, 'Fated.Regular', PADDING_LEFT, h * 0.5, Mantle.color.text, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
end

vgui.Register('MantleCheckBox', PANEL, 'Button')
