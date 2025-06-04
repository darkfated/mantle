local PANEL = {}

function PANEL:Init()
    local vbar = self:GetVBar()
    vbar:SetWide(6)
    vbar:SetHideButtons(true)
    vbar.Paint = function(_, w, h)
        RNDX.Draw(32, 0, 0, w, h, Mantle.color.sp)

        self.pnlCanvas:DockPadding(0, 0, m_bNoSizing and 0 or 6, 0)
    end
    vbar.btnGrip.Paint = function(_, w, h)
        RNDX.Draw(32, 0, 0, w, h, Mantle.color.theme)
    end
end

vgui.Register('MantleScrollPanel', PANEL, 'DScrollPanel')
