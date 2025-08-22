local PANEL = {}

function PANEL:Init()
    self.text = ''
    self.description = ''
    self.convar = ''
    self.value = false

    self:SetText('')
    self:SetCursor('hand')
    self:SetTall(32)

    self._hover = 0
    self._circle = 0
    self._circleEased = 0
    self._circleColor = table.Copy(Mantle.color.gray)

    self.toggle = vgui.Create('DButton', self)
    self.toggle:Dock(RIGHT)
    self.toggle:SetWide(48)
    self.toggle:DockMargin(0, 0, 8, 0)
    self.toggle:SetText('')
    self.toggle:SetCursor('hand')

    self.toggle.Paint = function(_, w, h)
        local ft = FrameTime()

        local targetHover = self.toggle:IsHovered() and 1 or 0
        self._hover = Mantle.func.approachExp(self._hover, targetHover, 6, ft)
        if math.abs(self._hover - targetHover) < 0.001 then self._hover = targetHover end

        local target = self.value and 1 or 0
        self._circle = Mantle.func.approachExp(self._circle, target, 8, ft)
        if math.abs(self._circle - target) < 0.001 then self._circle = target end

        self._circleEased = Mantle.func.easeInOutCubic(self._circle)

        local trackH = 20
        local trackY = (h - trackH) / 2
        RNDX().Rect(0, trackY, w, trackH)
            :Rad(16)
            :Color(Mantle.color.panel[1])
            :Shape(RNDX.SHAPE_IOS)
        :Draw()

        if self._hover > 0 then
            RNDX().Rect(0, trackY, w, trackH)
                :Rad(16)
                :Color(Color(
                    Mantle.color.button_hovered.r,
                    Mantle.color.button_hovered.g,
                    Mantle.color.button_hovered.b,
                    math.floor(self._hover * 80)
                ))
                :Shape(RNDX.SHAPE_IOS)
            :Draw()
        end

        local circleSize = 16
        local pad = trackY + (trackH - circleSize) / 2
        local x0 = pad
        local x1 = w - circleSize - pad
        local circleX = Lerp(self._circleEased, x0, x1)
        circleX = math.floor(circleX + 0.5)

        local targetCol = self.value and Mantle.color.theme or Mantle.color.gray
        self._circleColor = Mantle.func.LerpColor(12, self._circleColor, targetCol)

        RNDX().Circle(circleX + circleSize/2, h/2, circleSize)
            :Color(self._circleColor)
        :Draw()
    end
    self.toggle.DoClick = function()
        if self.convar ~= '' then
            LocalPlayer():ConCommand(self.convar .. ' ' .. (self.value and 0 or 1))
        end
        self.value = not self.value
        self:OnChange(self.value)

        Mantle.func.sound()
    end
end

function PANEL:SetTxt(text)
    self.text = text
end

function PANEL:SetValue(val)
    self.value = val
end

function PANEL:GetBool()
    return self.value
end

function PANEL:SetConvar(convar)
    self.value = GetConVar(convar):GetBool()
    self.convar = convar
end

function PANEL:SetDescription(desc)
    self.description = desc
    self:SetTooltip(desc)
    self:SetTooltipDelay(1.5)
end

function PANEL:OnChange(new_value)
    -- Clear
end

function PANEL:Paint(w, h)
    if Mantle.ui.convar.depth_ui then
        RNDX().Rect(0, 0, w, h)
            :Rad(16)
            :Color(Mantle.color.window_shadow)
            :Shape(RNDX.SHAPE_IOS)
            :Shadow(5, 20)
        :Draw()
    end
    RNDX().Rect(0, 0, w, h)
        :Rad(16)
        :Color(Mantle.color.focus_panel)
        :Shape(RNDX.SHAPE_IOS)
    :Draw()
    draw.SimpleText(self.text, 'Fated.18', 12, h * 0.5, Mantle.color.text, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
    if self.description ~= '' and self:GetTall() > 32 then
        draw.SimpleText(self.description, 'Fated.16', 12, h - 6, Mantle.color.gray, TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM)
    end
end

function PANEL:DoClick()
    if self.description == '' then return end
    self:SetTall(self:GetTall() == 32 and 48 or 32)
end

function PANEL:PerformLayout(w, h)
    self.toggle:SetWide(48)
    self.toggle:DockMargin(0, 0, 8, 0)
end

vgui.Register('MantleCheckBox', PANEL, 'Panel')
