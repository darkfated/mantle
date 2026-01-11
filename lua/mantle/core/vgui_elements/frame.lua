local PANEL = {}

function PANEL:Init()
    self:DockPadding(16, 44, 16, 16)

    self.centerTitle = nil

    self.panelBtns = vgui.Create('Panel', self)
    self.panelBtns:SetSize(16 * 3 + 12, 16)

    self.btnClose = vgui.Create('Button', self.panelBtns)
    self.btnClose:SetSize(16, 16)
    self.btnClose:Dock(LEFT)
    self.btnClose:SetText('')
    self.btnClose.Paint = function(_, w, h)
        RNDX().Rect(0, 0, w, h)
            :Rad(100)
            :Color(Mantle.color.btn_close)
        :Draw()
    end
    self.btnClose.DoClick = function()
        self:Close()

        Mantle.func.sound()
    end

    self.btnMiddle = vgui.Create('Button', self.panelBtns)
    self.btnMiddle:SetSize(16, 16)
    self.btnMiddle:Dock(LEFT)
    self.btnMiddle:DockMargin(6, 0, 0, 0)
    self.btnMiddle:SetText('')
    self.btnMiddle.Paint = function(_, w, h)
        RNDX().Rect(0, 0, w, h)
            :Rad(100)
            :Color(Mantle.color.btn_middle)
        :Draw()
    end

    self.btnRight = vgui.Create('Button', self.panelBtns)
    self.btnRight:SetSize(16, 16)
    self.btnRight:Dock(LEFT)
    self.btnRight:DockMargin(6, 0, 0, 0)
    self.btnRight:SetText('')
    self.btnRight.Paint = function(_, w, h)
        RNDX().Rect(0, 0, w, h)
            :Rad(100)
            :Color(Mantle.color.btn_right)
        :Draw()
    end
end

function PANEL:OnlyCloseBtn()
    self.btnMiddle:Remove()
    self.btnRight:Remove()
end

function PANEL:SetCenterTitle(text)
    self.centerTitle = text
end

function PANEL:ShowAnimation()
    Mantle.func.animate_appearance(self, self:GetWide(), self:GetTall(), 0.3, 0.2)
end

function PANEL:Close()
    self:AlphaTo(0, 0.1, 0, function()
        self:Remove()
    end)
end

function PANEL:Paint(w, h)
    RNDX().Rect(0, 0, w, h)
        :Rad(32)
        :Blur(2, 10)
        :Shape(RNDX.SHAPE_IOS)
    :Draw()

    RNDX().Rect(0, 0, w, h)
        :Rad(32)
        :Color(Mantle.color.background)
        :Shape(RNDX.SHAPE_IOS)
    :Draw()

    RNDX().Rect(2, 2, w - 4, h - 4)
        :Rad(32)
        :Color(Mantle.color.outline)
        :Outline(1)
        :Shape(RNDX.SHAPE_IOS)
    :Draw()

    if self.centerTitle then
        draw.SimpleText(self.centerTitle, 'Fated.Regular', w * 0.5, 16, Mantle.color.text_muted, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
    end
end

function PANEL:PerformLayout(w, h)
    self.panelBtns:SetPos(16, 16)
end

function PANEL:SetTitle(title)
end

function PANEL:Notify(text, duration, col)
end

function PANEL:LiteMode()
end

function PANEL:DisableCloseBtn()
end

vgui.Register('MantleFrame', PANEL, 'EditablePanel')
