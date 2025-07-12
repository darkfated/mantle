local PANEL = {}

function PANEL:Init()
    self.title = ''

    self:SetTall(24)

    self.main = vgui.Create('Panel', self)
    self.main.Paint = function(_, w, h)
        RNDX.Draw(16, 0, 0, w, h, color_white, RNDX.SHAPE_IOS)
    end

    self.entry = vgui.Create('DTextEntry', self.main)
    self.entry:SetFont('Fated.18')
    self.entry:SetDrawLanguageID(false)
    self.entry:SetPaintBackground(false)
end

function PANEL:SetTitle(title)
    self.title = title
    self:SetTall(44)
end

function PANEL:SetPlaceholder(placeholder)
    self.entry:SetPlaceholderText(placeholder)
end

function PANEL:GetValue()
    return self.entry:GetText()
end

function PANEL:Paint(w, h)
    if self.title != '' then
        draw.SimpleText(self.title, 'Fated.18', 6, 0, color_white)
    end
end

function PANEL:PerformLayout(w, h)
    self.main:SetSize(w - 12, 24)

    if self.title != '' then
        self.main:SetPos(6, 20)
    else
        self.main:SetPos(6, 0)
    end

    self.entry:Dock(FILL)
end

vgui.Register('MantleEntry', PANEL, 'Panel')

local PANEL = {}

function PANEL:Init()
    self.title = nil
    self.placeholder = 'Введите текст'

    self:SetTall(26)
    self.action = function()
        // что-то
    end

    self.textEntry = vgui.Create('DTextEntry', self)
    self.textEntry:Dock(FILL)
    self.textEntry:SetText('')
    self.textEntry.OnCloseFocus = function()
        self.action(self:GetValue())
    end
    self.textEntry.Paint = nil
    self.textEntry.PaintOver = function(_, w, h)
        if Mantle.ui.convar.depth_ui then
            RNDX.DrawShadows(16, 0, 0, w, h, Mantle.color.window_shadow, 5, 20, RNDX.SHAPE_IOS)
        end
        RNDX.Draw(16, 0, 0, w, h, Mantle.color.focus_panel, RNDX.SHAPE_IOS)

        local text = self.placeholder
        local value = self:GetValue()

        if value != '' then
            text = value
        end

        draw.SimpleText(text, 'Fated.18', 6, h * 0.5, value != '' and color_white or Mantle.color.gray, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
    end
end

function PANEL:SetTitle(title)
    self.title = title
    self:SetTall(52)

    self.titlePanel = vgui.Create('DPanel', self)
    self.titlePanel:Dock(TOP)
    self.titlePanel:DockMargin(0, 0, 0, 6)
    self.titlePanel:SetTall(18)
    self.titlePanel.Paint = function(_, w, h)
        draw.SimpleText(self.title, 'Fated.18', 0, 0, color_white)
    end
end

function PANEL:SetPlaceholder(placeholder)
    self.placeholder = placeholder
end

function PANEL:GetValue()
    return self.textEntry:GetText()
end

vgui.Register('MantleEntry', PANEL, 'EditablePanel')
