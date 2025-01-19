local PANEL = {}

local color_on = Color(86, 135, 79)
local color_off = Color(141, 52, 52)

function PANEL:Init()
    self.text = 'Параметр'
    self.bool_enabled = false
    self.convar = ''
    self.description = ''

    self:SetText('')
    self:SetCursor('arrow')
    self:SetTall(28)

    self.btn = vgui.Create('Button', self)
    self.btn:Dock(RIGHT)
    self.btn:SetText('')
    self.btn.Paint = function(_, w, h)
        draw.RoundedBoxEx(6, 0, 2, w - 2, h - 4, Mantle.color.panel_alpha[1], false, true, false, true)
        local col = self.btn:IsHovered() and (self.bool_enabled and color_on or color_off) or color_white
        draw.SimpleText(self.bool_enabled and 'ВКЛ' or 'ВЫКЛ', 'Fated.20', w * 0.5 - 1, h * 0.5, col, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
    self.btn.DoClick = function()
        if self.convar != '' then
            RunConsoleCommand(self.convar, self.bool_enabled and 0 or 1)
        end

        self.bool_enabled = !self.bool_enabled

        Mantle.func.sound()
    end
end

function PANEL:DoClick()
    if self.description == '' then
        return
    end

    if self:GetTall() == 28 then
        self:SetTall(44)
        self.bool_desc = true
    else
        self:SetTall(28)
        self.bool_desc = false
    end
end

function PANEL:SetTxt(text)
    self.text = text
end

function PANEL:GetBool()
    return self.bool_enabled
end

function PANEL:SetConvar(convar)
    self.bool_enabled = GetConVar(convar):GetBool()
    self.convar = convar
end

function PANEL:SetDescription(desc)
    self.description = desc
    self:SetTooltip(desc)
    self:SetTooltipDelay(1.5)
end

function PANEL:Paint(w, h)
    draw.RoundedBox(6, 0, 0, w, h, Mantle.color.panel_alpha[2])
    Mantle.func.gradient(w - 220, 0, 164, h, 4, Mantle.color.button_shadow)
    draw.SimpleText(self.text, 'Fated.18', 8, 5, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)

    if self:GetTall() == 44 then
        draw.SimpleText(self.description, 'Fated.16', 8, h - 5, Mantle.color.gray, TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM)
    end
end

function PANEL:PerformLayout(w, h)
    self.btn:SetWide(56)
end

vgui.Register('MantleCheckBox', PANEL, 'Button')
