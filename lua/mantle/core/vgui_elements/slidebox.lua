local PANEL = {}

function PANEL:Init()
    self.text = ''
    self.min_value = 0
    self.max_value = 1
    self.decimals = 2
    self.convar = nil
    self.value = 0
    self.smoothPos = 0
    self.targetPos = 0

    self:SetTall(40)

    timer.Simple(0, function()
        if IsValid(self) then
            self:SyncSliderWithConvar()
        end
    end)
end

function PANEL:SetRange(min_value, max_value, decimals)
    self.min_value = min_value
    self.max_value = max_value
    self.decimals = decimals or 0
end

function PANEL:SetConvar(convar)
    self.convar = convar

    self:SyncSliderWithConvar()
end

function PANEL:SetText(text)
    self.text = text
end

local math_clamp = math.Clamp
local math_round = math.Round

function PANEL:SyncSliderWithConvar()
    if self.convar then
        local convar_value = GetConVar(self.convar):GetFloat()
        self.value = math_clamp(convar_value, self.min_value, self.max_value)
        self:UpdateSliderPosition(self.value)
    end
end

function PANEL:UpdateSliderPosition(new_value)
    self.value = new_value
    local progress = (new_value - self.min_value) / (self.max_value - self.min_value)
    self.targetPos = math_clamp((self:GetWide() - 16) * progress, 0, self:GetWide() - 16)

    if self.convar then
        LocalPlayer():ConCommand(self.convar .. ' ' .. new_value)
    end
end

function PANEL:UpdateSliderByCursorPos(x)
    local progress = math_clamp(x / (self:GetWide() - 16), 0, 1)
    local new_value = math_round(self.min_value + (progress * (self.max_value - self.min_value)), self.decimals)
    self:UpdateSliderPosition(new_value)
end

function PANEL:Paint(w, h)
    draw.RoundedBox(4, 0, h - 16, w, 6, Mantle.color.panel_alpha[1])

    self.smoothPos = Lerp(FrameTime() * 10, self.smoothPos, self.targetPos)

    draw.RoundedBox(16, self.smoothPos, h - 22, 16, 16, Mantle.color.theme)

    draw.SimpleText(self.text, 'Fated.18', 4, 0, color_white)
    draw.SimpleText(math_round(self.value, self.decimals), 'Fated.18', w - 4, 0, color_white, TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP)
end

function PANEL:OnMousePressed(mcode)
    if mcode == MOUSE_LEFT then
        local x = self:CursorPos()
        self:UpdateSliderByCursorPos(x)
        self:MouseCapture(true)
    end
end

function PANEL:OnMouseReleased(mcode)
    if mcode == MOUSE_LEFT then
        self:MouseCapture(false)
    end
end

function PANEL:OnCursorMoved(x)
    if input.IsMouseDown(MOUSE_LEFT) then
        self:UpdateSliderByCursorPos(x)
    end
end

vgui.Register('MantleSlideBox', PANEL, 'Panel')
