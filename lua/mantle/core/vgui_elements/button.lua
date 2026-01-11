local PANEL = {}

function PANEL:Init()
    self.txt = ''
    self.txtWide = 0
    self.iconMat = nil
    self.iconSize = 0
    self:SetText('')
    self:SetTall(40)
    self._hover = 0
    self._hoverSpeed = 24
    self._hoverEased = 0
end

function PANEL:SetTxt(text)
    self.txt = text
    surface.SetFont('Fated.Regular')
    self.txtWide = surface.GetTextSize(text)
end

function PANEL:SetIcon(mat, size)
    self.iconMat = type(mat) == 'IMaterial' and mat or Material(mat)
    self.iconSize = size
end

function PANEL:Paint(w, h)
    local ft = FrameTime()
    local target = self:IsHovered() and 1 or 0
    self._hover = Mantle.func.approachExp(self._hover, target, self._hoverSpeed, ft)
    self._hoverEased = Mantle.func.easeOutCubic(self._hover)

    local t = self._hoverEased
    local pr, pg, pb, pa = Mantle.color.p.r, Mantle.color.p.g, Mantle.color.p.b, Mantle.color.p.a or 255
    local hr, hg, hb, ha = Mantle.color.p_hovered.r, Mantle.color.p_hovered.g, Mantle.color.p_hovered.b, Mantle.color.p_hovered.a or 255

    local bg = Color(
        math.floor(Lerp(t, pr, hr) + 0.5),
        math.floor(Lerp(t, pg, hg) + 0.5),
        math.floor(Lerp(t, pb, hb) + 0.5),
        math.floor(Lerp(t, pa, ha) + 0.5)
    )

    RNDX().Rect(0, 0, w, h)
        :Rad(32)
        :Color(bg)
        :Shape(RNDX.SHAPE_IOS)
    :Draw()

    RNDX().Rect(0, 0, w, h)
        :Rad(32)
        :Color(Mantle.color.p_outline)
        :Outline(1)
        :Shape(RNDX.SHAPE_IOS)
    :Draw()

    local textCol = Mantle.color.text
    if self.txt != '' then
        draw.SimpleText(self.txt, 'Fated.Regular', w * 0.5, h * 0.5, textCol, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

        if self.iconMat and self.iconSize > 0 then
            RNDX().Rect(w * 0.5 - self.txtWide * 0.5 - self.iconSize - 6, h * 0.5 - self.iconSize * 0.5, self.iconSize, self.iconSize)
                :Material(self.iconMat)
            :Draw()
        end
        return
    end

    if self.iconMat and self.iconSize > 0 then
        RNDX().Rect(w * 0.5 - self.iconSize * 0.5, h * 0.5 - self.iconSize * 0.5, self.iconSize, self.iconSize)
            :Material(self.iconMat)
        :Draw()
        return
    end

    draw.SimpleText(Mantle.lang.get('mantle', 'btn_default'), 'Fated.Regular', w * 0.5, h * 0.5, textCol, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
end

function PANEL:SetRipple()
end

function PANEL:SetColorHover()
end

vgui.Register('MantleBtn', PANEL, 'Button')
