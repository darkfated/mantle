local PANEL = {}

function PANEL:Init()
    self:DockPadding(8, 8, 8, 8)
    self.color = Mantle.color.p
end

function PANEL:Paint(w, h)
    RNDX().Rect(0, 0, w, h)
        :Rad(16)
        :Color(self.color)
        :Shape(RNDX.SHAPE_IOS)
    :Draw()
end

vgui.Register('MantlePanel', PANEL, 'Panel')
