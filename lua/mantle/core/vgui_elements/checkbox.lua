local PANEL = {}

function PANEL:Init()
    self.text = ''
    self.convar = ''
    self.value = false

    self:SetText('')
    self:SetCursor('hand')
    self:SetTall(36)

    self._circle = 0
    self._circleEased = 0
    self._circleColor = table.Copy(Mantle.color.gray)

    self.toggle = vgui.Create('Button', self)
    self.toggle:Dock(RIGHT)
    self.toggle:SetWide(48)
    self.toggle:DockMargin(0, 0, 14, 0)
    self.toggle:SetText('')
    self.toggle:SetCursor('hand')
    self.toggle.Paint = nil

    self.toggle.DoClick = function()
        if self.convar ~= '' then
            LocalPlayer():ConCommand(self.convar .. ' ' .. (self.value and 0 or 1))
        end

        self:SetValue(not self.value)
        self:OnChange(self.value)

        Mantle.func.sound()
    end
end

function PANEL:OnMousePressed(mcode)
    if mcode == MOUSE_LEFT then
        self.toggle:DoClick()
    end
end

function PANEL:SetTxt(text)
    self.text = text
end

function PANEL:SetValue(val)
    self.value = tobool(val)
end

function PANEL:GetBool()
    return self.value
end

function PANEL:SetConvar(convar)
    local c = GetConVar(convar)
    if c then self.value = c:GetBool() end
    self.convar = convar
end

function PANEL:OnChange(new_value)
end

function PANEL:Paint(w, h)
    if Mantle.ui and Mantle.ui.convar and Mantle.ui.convar.depth_ui then
        RNDX().Rect(0, 0, w, h)
            :Rad(12)
            :Color(Mantle.color.window_shadow)
            :Shape(RNDX.SHAPE_IOS)
            :Shadow(6, 22)
        :Draw()
    end

    RNDX().Rect(0, 0, w, h)
        :Rad(12)
        :Color(Mantle.color.focus_panel)
        :Shape(RNDX.SHAPE_IOS)
    :Draw()

    local textX = 14
    draw.SimpleText(self.text, 'Fated.18', textX, h * 0.5, Mantle.color.text, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
end

function PANEL:PaintOver(w, h)
    local tw, th = self.toggle:GetWide(), self.toggle:GetTall()
    local tx, ty = self.toggle:GetPos()
    local ft = FrameTime()

    local target = self.value and 1 or 0
    local circleSpeed = 8
    self._circle = Mantle.func.approachExp(self._circle, target, circleSpeed, ft)
    if math.abs(self._circle - target) < 0.001 then self._circle = target end
    self._circleEased = Mantle.func.easeInOutCubic(self._circle)

    local trackW = tw - 10
    local trackH = 18
    local trackX = tx + (tw - trackW) / 2
    local trackY = ty + (th - trackH) / 2

    RNDX().Rect(trackX, trackY + 1, trackW, trackH - 2)
        :Rad(trackH / 2)
        :Color(Mantle.color.toggle)
        :Shape(RNDX.SHAPE_IOS)
    :Draw()

    local circleSize = 20
    local pad = 0
    local textMargin = 14

    local x0_base = trackX + pad - (circleSize * 0.5) + 0.5
    local x1 = trackX + trackW - pad - (circleSize * 0.5) - 0.5
    local x0_align = textMargin - (circleSize * 0.5)
    local x0 = math.max(x0_base, x0_align)

    local circleXPrec = x0 + (x1 - x0) * self._circleEased
    local circleCenterX = circleXPrec + circleSize * 0.5
    local circleCenterY = trackY + trackH * 0.5

    local baseCircle = self.value and Mantle.color.theme or Mantle.color.gray
    local circleCol = table.Copy(baseCircle)
    circleCol.a = 255
    self._circleColor = Mantle.func.LerpColor(12, self._circleColor, circleCol)
    RNDX().Circle(circleCenterX, circleCenterY, circleSize)
        :Color(self._circleColor)
    :Draw()

    RNDX().Circle(circleCenterX, circleCenterY + 2, circleSize * 1.05)
        :Color(Color(0, 0, 0, 30))
    :Draw()
end

function PANEL:PerformLayout(w, h)
    self.toggle:SetWide(48)
    self.toggle:DockMargin(0, 0, 14, 0)
end

vgui.Register('MantleCheckBox', PANEL, 'Panel')
