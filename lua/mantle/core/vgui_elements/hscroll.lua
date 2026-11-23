local PANEL = {}

local math_max = math.max
local math_floor = math.floor

PANEL.IsVertical = false

function PANEL:_sizeCanvas()
    self.content:SizeToChildren(true, false)
end

function PANEL:_range()
    local w, h = self:GetSize()
    local viewW = math_max(0, w - self.padL - self.padR)
    local contentW

    if self._needLayout then
        local viewH = math_max(0, h - self.padT - self.padB)
        local contentTall = self.content:GetTall()

        if contentTall != viewH then
            self.content:SetTall(viewH)
            self.content:InvalidateLayout(true)
        end

        self:_sizeCanvas()
        contentW = self.content:GetWide()

        if contentW < viewW then
            self.content:SetWide(viewW)
            self.content:InvalidateLayout(true)
            contentW = viewW
        end

        self._needLayout = false
    else
        contentW = self.content:GetWide()
    end

    return math_max(0, contentW - viewW), viewW, contentW
end

function PANEL:_applyScroll()
    self.content:SetPos(self.padL - math_floor(self.offset), self.padT)
end

vgui.Register('MantleHScroll', PANEL, 'MantleScroll')
