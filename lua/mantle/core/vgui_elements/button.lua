local PANEL = {}

function PANEL:Init()
    self.txt = ''
    self.txtWide = nil
    self.iconMat = nil
    self.iconSize = nil

    self:SetText('')
    self:SetTall(40)
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
    RNDX().Rect(0, 0, w, h)
        :Rad(32)
        :Color(self:IsHovered() and Mantle.color.p_hovered or Mantle.color.p)
        :Shape(RNDX.SHAPE_IOS)
    :Draw()

    RNDX().Rect(0, 0, w, h)
        :Rad(32)
        :Color(Mantle.color.p_outline)
        :Outline(1)
        :Shape(RNDX.SHAPE_IOS)
    :Draw()

    if self.txt != '' then
        draw.SimpleText(self.txt, 'Fated.Regular', w * 0.5, h * 0.5, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

        if self.iconMat then
            RNDX().Rect(w * 0.5 - self.txtWide * 0.5 - self.iconSize - 6, h * 0.5 - self.iconSize * 0.5, self.iconSize, self.iconSize)
                :Material(self.iconMat)
            :Draw()
        end

       return
    end

    if self.iconMat then
        RNDX().Rect(w * 0.5 - self.iconSize * 0.5, h * 0.5 - self.iconSize * 0.5, self.iconSize, self.iconSize)
            :Material(self.iconMat)
        :Draw()

        return
    end

    draw.SimpleText('Кнопка', 'Fated.Regular', w * 0.5, h * 0.5, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
end

function PANEL:SetRipple()
end

function PANEL:SetColorHover()
end

vgui.Register('MantleBtn', PANEL, 'Button')
