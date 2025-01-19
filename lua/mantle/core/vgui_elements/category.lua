local PANEL = {}

function PANEL:Init()
    self:SetTall(30)
    self:DockPadding(0, 36, 0, 0)
    self.name = 'Категория'
    self.bool_opened = false
    self.content_size = 0
    self.header_color = Mantle.color.theme
    self.header_color_standard = Mantle.color.theme
    self.header_color_opened = Mantle.color.panel_alpha[2]

    self.header = vgui.Create('Button', self)
    self.header:SetText('')
    self.header.Paint = function(_, w, h)
        draw.RoundedBox(8, 0, 0, w, h, self.header_color)
        draw.SimpleText(self.name, 'Fated.20', 9, 5, color_black)
        draw.SimpleText(self.name, 'Fated.20', 8, 4, color_white)

        self.header_color = Mantle.func.LerpColor(8, self.header_color, self.bool_opened and self.header_color_opened or self.header_color_standard)
    end
    self.header.DoClick = function()
        self.bool_opened = !self.bool_opened

        local totalTall = 30 + (self.bool_opened and self.content_size + 12 or 0)

        self:SizeTo(-1, totalTall, 0.2, 0, 0.2)
    end
end

function PANEL:SetText(name)
    self.name = name
end

function PANEL:AddItem(panel)
    panel:SetParent(self)

    local _, marginTop, _, marginBottom = panel:GetDockMargin()

    self.content_size = self.content_size + panel:GetTall() + marginTop + marginBottom
end

function PANEL:SetColor(col)
    self.header_color_standard = col
end

function PANEL:PerformLayout(w, h)
    self.header:SetSize(w, 30)
end

vgui.Register('MantleCategory', PANEL, 'Panel')
