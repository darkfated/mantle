local PANEL = {}

local math_floor = math.floor

function PANEL:Init()
    self:DockMargin(8, 8, 8, 8)
    self.text = ''
    self.convar = ''
    self.value = false

    self._toggleHover = 0

    self:SetText('')
    self:SetCursor('hand')
    self:SetTall(32)

    self._circle = 0
    self._circleEased = 0
    self._circleColor = Mantle.color.gray

    self.toggle = vgui.Create('Button', self)
    self.toggle:Dock(RIGHT)
    self.toggle:SetWide(38)
    self.toggle:DockMargin(0, 0, 10, 0)
    self.toggle:SetText('')
    self.toggle:SetCursor('hand')
    self.toggle.Paint = nil

    self.toggle.DoClick = function()
        if self.convar != '' then
            LocalPlayer():ConCommand(self.convar .. ' ' .. (self.value and 0 or 1))
        end

        self:SetValue(not self.value)
        self:OnChange(self.value)

        Mantle.func.sound()
    end

    self._convar_timer_name = self:CreateConVarSyncTimer()
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

function PANEL:CreateConVarSyncTimer()
    local name = ('mantle_check_sync_%s'):format(tostring(self))
    timer.Create(name, 0.1, 0, function()
        if not IsValid(self) or self.convar == '' then return end

        local cvar = GetConVar(self.convar)
        if not cvar then return end

        local val = cvar:GetBool()
        if self.value != val then
            self:SetValue(val)
            self:OnChange(self.value)
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

function PANEL:OnChange(new_value)
end

function PANEL:Paint(w, h)
    RNDX.Rect(0, 0, w, h)
        :Rad(12)
        :Color(Mantle.color.focus_panel)
    :Draw()

    draw.SimpleText(self.text, 'Fated.16', 10, h * 0.5, Mantle.color.text, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
end

function PANEL:PaintOver(w, h)
    local tw, th = self.toggle:GetWide(), self.toggle:GetTall()
    local tx, ty = self.toggle:GetPos()
    local ft = FrameTime()

    local target = self.value and 1 or 0
    self._circle = Mantle.func.approachExp(self._circle, target, 12, ft)
    if math.abs(self._circle - target) < 0.001 then self._circle = target end
    self._circleEased = Mantle.func.easeInOutCubic(self._circle)

    self._toggleHover = Mantle.func.approachExp(self._toggleHover, self.toggle:IsHovered() and 1 or 0, 14, ft)

    local trackW = tw - 8
    local trackH = 14
    local trackX = tx + (tw - trackW) * 0.5
    local trackY = ty + (th - trackH) * 0.5

    RNDX.Rect(trackX, trackY + 1, trackW, trackH - 2)
        :Rad(trackH / 2)
        :Color(Mantle.color.toggle)
    :Draw()

    if self._toggleHover > 0.01 then
        local hv = Mantle.color.hover_overlay_strong
        RNDX.Rect(trackX, trackY + 1, trackW, trackH - 2)
            :Rad(trackH / 2)
            :Color(Color(hv.r, hv.g, hv.b, math_floor(hv.a * self._toggleHover)))
        :Draw()
    end

    local circleSize = 16
    local pad = 0
    local textMargin = 10

    local x0_base = trackX + pad - (circleSize * 0.5) + 0.5
    local x1 = trackX + trackW - pad - (circleSize * 0.5) - 0.5
    local x0_align = textMargin - (circleSize * 0.5)
    local x0 = math.max(x0_base, x0_align)

    local circleX = x0 + (x1 - x0) * self._circleEased
    local circleCenterX = circleX + circleSize * 0.5
    local circleCenterY = trackY + trackH * 0.5

    local baseCircle = self.value and Mantle.color.theme or Mantle.color.gray
    local circleCol = Color(baseCircle.r, baseCircle.g, baseCircle.b, 255)
    self._circleColor = Mantle.func.LerpColor(14, self._circleColor, circleCol)

    RNDX.Circle(circleCenterX, circleCenterY, circleSize * 0.5)
        :Color(self._circleColor)
    :Draw()

    RNDX.Circle(circleCenterX, circleCenterY + 1, circleSize * 1.03 * 0.5)
        :Color(Mantle.color.circle_shadow)
    :Draw()
end

function PANEL:PerformLayout(w, h)
    self.toggle:SetWide(38)
    self.toggle:DockMargin(0, 0, 10, 0)
end

vgui.Register('MantleCheckBox', PANEL, 'Panel')
