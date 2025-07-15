local PANEL = {}

function PANEL:Init()
    self:SetTall(30)
    self:DockPadding(0, 36, 0, 0)
    self.name = 'Категория'
    self.bool_opened = false
    self.bool_header_centered = false
    self.content_size = 0
    self.header_color = Mantle.color.category
    self.header_color_standard = self.header_color
    self.header_color_opened = Mantle.color.category_opened

    self.header = vgui.Create('Button', self)
    self.header:SetText('')
    self.header.Paint = function(_, w, h)
        RNDX.Draw(16, 0, 0, w, h, self.header_color, RNDX.SHAPE_IOS)
        local posX = self.bool_header_centered and w * 0.5 or 8
        local alignX = self.bool_header_centered and TEXT_ALIGN_CENTER or TEXT_ALIGN_LEFT
        if !Mantle.ui.convar.light_theme then
            draw.SimpleText(self.name, 'Fated.20', posX, 5, color_black, alignX)
        end
        draw.SimpleText(self.name, 'Fated.20', posX, 4, Mantle.color.text, alignX)

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

function PANEL:SetCenterText(is_centered)
    self.bool_header_centered = is_centered
end

function PANEL:AddItem(panel)
    panel:SetParent(self)

    local _, marginTop, _, marginBottom = panel:GetDockMargin()

    self.content_size = self.content_size + panel:GetTall() + marginTop + marginBottom

    if self.bool_opened then
        self:SetTall(30 + self.content_size + 12)
    end
end

function PANEL:SetColor(col)
    self.header_color_standard = col
end

function PANEL:SetActive(is_active)
    if self.bool_opened == is_active then return end
    
    self.bool_opened = is_active
    self.header_color = is_active and self.header_color_opened or self.header_color_standard
    
    local totalTall = 30 + (is_active and self.content_size + 12 or 0)
    self:SetTall(totalTall)
end

function PANEL:PerformLayout(w, h)
    self.header:SetSize(w, 30)
end

vgui.Register('MantleCategory', PANEL, 'Panel')
