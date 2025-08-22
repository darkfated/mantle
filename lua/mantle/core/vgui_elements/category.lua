local PANEL = {}

local function easeOutCubic(t)
    return 1 - (1 - t) * (1 - t) * (1 - t)
end

local function approachExp(current, target, speed, dt)
    local t = 1 - math.exp(-speed * dt)
    return current + (target - current) * t
end

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

    self._childHeights = {}

    self._anim = 0
    self._animTarget = 0
    self._animSpeed = 12
    self._animEased = 0

    self.header = vgui.Create('Button', self)
    self.header:SetText('')
    self.header.Paint = function(_, w, h)
        RNDX().Rect(0, 0, w, h)
            :Rad(16)
            :Color(self.header_color)
            :Shape(RNDX.SHAPE_IOS)
        :Draw()
        local posX = self.bool_header_centered and w * 0.5 or 8
        local alignX = self.bool_header_centered and TEXT_ALIGN_CENTER or TEXT_ALIGN_LEFT
        draw.SimpleText(self.name, 'Fated.20', posX, 4, Mantle.color.text, alignX)

        self.header_color = Mantle.func.LerpColor(8, self.header_color, self.bool_opened and self.header_color_opened or self.header_color_standard)
    end
    self.header.DoClick = function()
        self.bool_opened = !self.bool_opened
        self._animTarget = self.bool_opened and 1 or 0
    end
end

function PANEL:SetText(name)
    self.name = name
end

function PANEL:SetCenterText(is_centered)
    self.bool_header_centered = is_centered
end

local function getTopBottomMargin(pnl)
    if !pnl.GetDockMargin then return 0, 0 end
    local ok, l, t, r, b = pcall(function()
        return pnl:GetDockMargin()
    end)
    if !ok or !l then return 0, 0 end
    return t or 0, b or 0
end

function PANEL:AddItem(panel)
    panel:SetParent(self)

    local top, bottom = getTopBottomMargin(panel)
    local contribution = (panel.GetTall and panel:GetTall() or 0) + top + bottom

    self._childHeights[panel] = contribution
    self.content_size = (self.content_size or 0) + contribution

    if self.bool_opened then
        self:SetTall(30 + self.content_size + 12)
    end

    local old = panel.OnSizeChanged
    panel.OnSizeChanged = function(...)
        if old then pcall(old, ...) end
        if !IsValid(self) then return end

        local nt, nb = getTopBottomMargin(panel)
        local newContribution = (panel.GetTall and panel:GetTall() or 0) + nt + nb
        local oldContribution = self._childHeights[panel] or 0
        local delta = newContribution - oldContribution
        if delta != 0 then
            self._childHeights[panel] = newContribution
            self.content_size = math.max(0, (self.content_size or 0) + delta)
        end
    end

    return panel
end

function PANEL:SetColor(col)
    self.header_color_standard = col
    if !self.bool_opened then
        self.header_color = self.header_color_standard
    end
end

function PANEL:SetActive(is_active)
    is_active = tobool(is_active)
    if self.bool_opened == is_active then return end
    self.bool_opened = is_active
    self._animTarget = is_active and 1 or 0
    self.header_color = is_active and self.header_color_opened or self.header_color_standard
end

function PANEL:PerformLayout(w, h)
    self.header:SetSize(w, 30)
end

function PANEL:Think()
    local ft = FrameTime()

    self._anim = approachExp(self._anim, self._animTarget, self._animSpeed, ft)
    self._animEased = easeOutCubic(self._anim)

    local currentContentTall = (self.content_size or 0) * self._animEased

    local padded = 12 * self._animEased

    local totalTall = 30 + currentContentTall + padded
    self:SetTall(math.max(30, math.floor(totalTall + 0.5)))

    local alphaVal = math.floor(255 * self._animEased + 0.5)

    for _, c in ipairs(self:GetChildren()) do
        if IsValid(c) and c != self.header then
            if c.SetAlpha then c:SetAlpha(alphaVal) end
        end
    end
end

vgui.Register('MantleCategory', PANEL, 'Panel')
