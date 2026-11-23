local PANEL = {}

local math_abs = math.abs
local math_floor = math.floor
local LERP_SNAP = 0.001
local syncCounter = 0

local BOX_SIZE = 18
local BOX_X = 9
local INNER_SIZE = 12

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

    self._borderColor = nil
    self._lastCheckedForBorder = nil
    self._lastUnchecked = nil
    self._lastTheme = nil
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
    local checkedTarget = self.value and 1 or 0
    local checked = self._checked

    if checked != checkedTarget then
        checked = Mantle.func.approachExp(checked, checkedTarget, 16, FrameTime())
        if math_abs(checked - checkedTarget) < LERP_SNAP then
            checked = checkedTarget
        end
        self._checked = checked
    end
end

function PANEL:Paint(w, h)
    local checked = self._checked

    local boxY = math_floor((h - BOX_SIZE) * 0.5)
    local innerX = BOX_X + (BOX_SIZE - INNER_SIZE) * 0.5
    local innerY = boxY + (BOX_SIZE - INNER_SIZE) * 0.5

    local unchecked = Mantle.color.toggle
    local theme = Mantle.color.theme

    local border = self._borderColor
    if !border
        or self._lastCheckedForBorder != checked
        or self._lastUnchecked != unchecked
        or self._lastTheme != theme
    then
        border = Mantle.func.LerpColor(checked, unchecked, theme)
        self._borderColor = border
        self._lastCheckedForBorder = checked
        self._lastUnchecked = unchecked
        self._lastTheme = theme
    end

    RNDX.Rect(BOX_X, boxY, BOX_SIZE, BOX_SIZE)
        :Rad(5)
        :Color(border)
    :Draw()

    if checked > 0.001 then
        local fillAlpha = math_floor(255 * checked)

        RNDX.Rect(innerX, innerY, INNER_SIZE, INNER_SIZE)
            :Rad(3.5)
            :Color(Color(theme.r, theme.g, theme.b, fillAlpha))
        :Draw()
    end

    local textColor = Mantle.color.text
    if !self:IsEnabled() then
        textColor = Color(textColor.r, textColor.g, textColor.b, 110)
    end

    local textX = BOX_X + BOX_SIZE + 9
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
