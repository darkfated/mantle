local PANEL = {}

function PANEL:Init()
    self:SetText('')

    self.icon = nil

    self._anim = 0
    self._animTarget = 0
    self._animEased = 0

    self.hover_speed = 10
    self.collapse_speed = 20

    self.max_scale = 1.5
    self.magnet_ratio = 0.08
    self.icon_mag_mult = 1.4
    self.icon_base = 32
end

function PANEL:SetIcon(icon, icon_size)
    if isstring(icon) then
        self.icon = Material(icon)
    else
        self.icon = icon
    end

    if icon_size then
        self.icon_base = icon_size
    end
end

function PANEL:Think()
    local ft = FrameTime()
    if self:IsHovered() then
        self._animTarget = 1
    else
        self._animTarget = 0
    end

    self._anim = Mantle.func.approachExp(self._anim, self._animTarget, self:IsHovered() and self.hover_speed or self.collapse_speed, ft)
    self._animEased = Mantle.func.easeOutCubic(self._anim)
end

function PANEL:Paint(w, h)
    local eased = self._animEased

    local scale = 1 + (self.max_scale - 1) * eased
    local drawW = w * scale
    local drawH = h * scale
    local drawX = (w - drawW) * 0.5
    local drawY = (h - drawH) * 0.5

    local cx, cy = w * 0.5, h * 0.5
    if self:IsHovered() then
        local mx, my = self:CursorPos()
        if mx and my then cx, cy = mx, my end
    end

    local nx = (cx - w * 0.5) / (w * 0.5)
    local ny = (cy - h * 0.5) / (h * 0.5)
    nx = math.max(-1, math.min(1, nx))
    ny = math.max(-1, math.min(1, ny))

    local magMax = math.max(w, h) * self.magnet_ratio

    local bgOffsetX = nx * magMax * eased * 0.6
    local bgOffsetY = ny * magMax * eased * 0.6
    drawX = drawX + bgOffsetX
    drawY = drawY + bgOffsetY

    local rad = 16 * scale

    local EPS = 0.02
    local useWorldClip = (self:IsHovered() or eased > EPS)
    local clipTarget = useWorldClip and vgui.GetWorldPanel() or self

    RNDX().Rect(drawX, drawY, drawW, drawH)
        :Rad(rad)
        :Color(Mantle.color.panel_alpha[3])
        :Shape(RNDX.SHAPE_IOS)
        :Clip(clipTarget)
    :Draw()

    local iconSize = self.icon_base * (1 + 0.5 * eased)
    local iconCenterX = drawX + (drawW * 0.5)
    local iconCenterY = drawY + (drawH * 0.5)

    local iconOffsetX = nx * magMax * eased * self.icon_mag_mult
    local iconOffsetY = ny * magMax * eased * self.icon_mag_mult

    local iconX = iconCenterX - (iconSize * 0.5) + iconOffsetX
    local iconY = iconCenterY - (iconSize * 0.5) + iconOffsetY

    if self.icon then
        RNDX().Rect(iconX, iconY, iconSize, iconSize)
            :Material(self.icon)
            :Color(255, 255, 255)
            :Clip(clipTarget)
        :Draw()
    end

    if eased > 0 then
        local textCol = Mantle.color.gray
        local alpha = math.floor((textCol.a or 255) * eased + 0.5)

        RNDX().Rect(drawX, drawY, drawW, drawH)
            :Rad(rad)
            :Color(Color(textCol.r, textCol.g, textCol.b, alpha))
            :Outline(Lerp(eased, 0, 2))
            :Clip(clipTarget)
            :Shape(RNDX.SHAPE_IOS)
        :Draw()
    end
end

vgui.Register('MantleItemBtn', PANEL, 'Button')
