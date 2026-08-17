local PANEL = {}

PANEL.IsVertical = false

function PANEL:_sizeCanvas()
    self.content:SizeToChildren(true, false)
end

function PANEL:_range()
    if self._needLayout then
        local w, h = self:GetWide(), self:GetTall()

        self.content:SetPos(self.padL - self.offset, self.padT)
        self.content:SetTall(math.max(0, h - self.padT - self.padB))
        self.content:InvalidateLayout(true)
        self.content:SizeToChildren(true, false)

        local viewW = math.max(0, w - self.padL - self.padR)
        local contentW = self.content:GetWide()

        if contentW <= viewW then
            self.content:SetWide(math.max(0, w - self.padL - self.padR))
            self.content:InvalidateLayout(true)
            self.content:SizeToChildren(true, false)
            contentW = self.content:GetWide()
        end

        self._needLayout = false
    end

    local viewW = math.max(0, self:GetWide() - self.padL - self.padR)
    local contentW = self.content:GetWide()

    return math.max(0, contentW - viewW), viewW, contentW
end

function PANEL:_applyScroll()
    self.content:SetPos(self.padL - math.floor(self.offset), self.padT)
end

vgui.Register('MantleHScroll', PANEL, 'MantleScroll')
