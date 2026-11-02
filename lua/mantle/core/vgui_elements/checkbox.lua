local PANEL = {}

local math_abs = math.abs
local math_floor = math.floor
local syncCounter = 0

function PANEL:Init()
    self:DockMargin(8, 8, 8, 8)
    self:SetTall(32)
    self:SetText('')
    self:SetCursor('hand')

    self.text = ''
    self.convar = ''
    self.value = false

    self._checked = 0
    self._convarTimerName = nil
end

function PANEL:SetTxt(text)
    self.text = tostring(text or '')
end

function PANEL:SetText(text)
    self:SetTxt(text)
end

function PANEL:GetText()
    return self.text
end

function PANEL:SetValue(val, fromConVar)
    val = tobool(val)
    if self.value == val then return end

    self.value = val

    if self.convar != '' and !fromConVar then
        LocalPlayer():ConCommand(self.convar .. ' ' .. (val and 1 or 0))
    end

    self:OnChange(val)
end

function PANEL:GetBool()
    return self.value
end

function PANEL:GetValue()
    return self.value
end

function PANEL:SetConvar(convar)
    if self._convarTimerName then
        timer.Remove(self._convarTimerName)
        self._convarTimerName = nil
    end

    self.convar = tostring(convar or '')

    if self.convar == '' then return end

    local c = GetConVar(self.convar)
    if c then
        self:SetValue(c:GetBool(), true)
    end

    self._convarTimerName = self:CreateConVarSyncTimer()
end

function PANEL:CreateConVarSyncTimer()
    syncCounter = syncCounter + 1

    local name = ('MantleCheckSync%d'):format(syncCounter)

    timer.Create(name, 0.1, 0, function()
        if !IsValid(self) then
            timer.Remove(name)
            return
        end

        if self.convar == '' then return end

        local c = GetConVar(self.convar)
        if !c then return end

        local value = c:GetBool()
        if self.value != value then
            self:SetValue(value, true)
        end
    end)

    return name
end

function PANEL:OnMousePressed(mouseCode)
    if mouseCode != MOUSE_LEFT or !self:IsEnabled() then return end

    self:SetValue(!self.value)
    Mantle.func.sound()

    return true
end

function PANEL:Think()
    local ft = FrameTime()
    local checkedTarget = self.value and 1 or 0

    self._checked = Mantle.func.approachExp(self._checked, checkedTarget, 16, ft)

    if math_abs(self._checked - checkedTarget) < 0.001 then
        self._checked = checkedTarget
    end
end

function PANEL:Paint(w, h)
    local checked = self._checked or 0

    local boxSize = 18
    local boxX = 9
    local boxY = math_floor((h - boxSize) * 0.5)
    local innerSize = 12
    local innerX = boxX + (boxSize - innerSize) * 0.5
    local innerY = boxY + (boxSize - innerSize) * 0.5

    local unchecked = Mantle.color.toggle
    local theme = Mantle.color.theme
    local border = Mantle.func.LerpColor(checked, unchecked, theme)

    RNDX.Rect(boxX, boxY, boxSize, boxSize)
        :Rad(5)
        :Color(border)
    :Draw()

    if checked > 0.001 then
        local fillAlpha = math_floor(255 * checked)

        RNDX.Rect(innerX, innerY, innerSize, innerSize)
            :Rad(3.5)
            :Color(Color(theme.r, theme.g, theme.b, fillAlpha))
        :Draw()
    end

    local textColor = Mantle.color.text
    if !self:IsEnabled() then
        textColor = Color(textColor.r, textColor.g, textColor.b, 110)
    end

    local textX = boxX + boxSize + 9
    draw.SimpleText(self.text, 'Fated.16', textX, h * 0.5, textColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
end

function PANEL:OnRemove()
    if self._convarTimerName then
        timer.Remove(self._convarTimerName)
        self._convarTimerName = nil
    end
end

function PANEL:OnChange(newValue)
end

vgui.Register('MantleCheckBox', PANEL, 'Panel')
