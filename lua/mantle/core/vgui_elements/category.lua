local PANEL = {}

local HEADER_HEIGHT = 30
local CONTENT_OFFSET = 36
local CONTENT_PADDING = 12

function PANEL:Init()
    self:DockMargin(8, 8, 8, 8)
    self:SetTall(HEADER_HEIGHT)

    self.name = 'Категория'
    self.opened = false
    self.centered = false
    self.headerColor = Mantle.color.category
    self.headerColorStandard = self.headerColor
    self.headerColorOpened = Mantle.color.category_opened

    self._anim = 0
    self._animTarget = 0
    self._animSpeed = 12
    self._childrenAlpha = -1
    self._contentTall = -1

    self.header = vgui.Create('Button', self)
    self.header:SetText('')
    self.header.Paint = function(_, w, h)
        RNDX.Rect(0, 0, w, h)
            :Rad(16)
            :Color(self.headerColor)
        :Draw()

        local posX = self.centered and w * 0.5 or 8
        local alignX = self.centered and TEXT_ALIGN_CENTER or TEXT_ALIGN_LEFT
        draw.SimpleText(self.name, 'Fated.20', posX, 4, Mantle.color.text, alignX)

        self.headerColor = Mantle.func.LerpColor(8, self.headerColor, self.opened and self.headerColorOpened or self.headerColorStandard)
    end
    self.header.DoClick = function()
        self.opened = !self.opened
        self._animTarget = self.opened and 1 or 0
    end

    self.content = vgui.Create('Panel', self)
    self.content:SetVisible(false)
    self._contentVisible = false
end

function PANEL:SetText(name)
    self.name = name
end

function PANEL:SetCenterText(isCentered)
    self.centered = isCentered
end

function PANEL:SetColor(col)
    self.headerColorStandard = col
    if !self.opened then
        self.headerColor = self.headerColorStandard
    end
end

function PANEL:SetActive(isActive)
    isActive = tobool(isActive)
    if self.opened == isActive then return end
    self.opened = isActive
    self._animTarget = isActive and 1 or 0
    self.headerColor = isActive and self.headerColorOpened or self.headerColorStandard
end

function PANEL:IsActive()
    return self.opened
end

function PANEL:AddItem(panel)
    if panel:GetParent() == self.content then return panel end
    panel:SetParent(self.content)
    return panel
end

function PANEL:Clear()
    for _, c in ipairs(self.content:GetChildren()) do c:Remove() end
    self.opened = false
    self._animTarget = 0
end

function PANEL:OnChildAdded(child)
    timer.Simple(0, function()
        if !IsValid(child) or !IsValid(self) then return end
        if child == self.header or child == self.content then return end
        if child:GetParent() == self then
            child:SetParent(self.content)
        end
    end)
end

function PANEL:PerformLayout(w, h)
    self.header:SetPos(0, 0)
    self.header:SetSize(w, HEADER_HEIGHT)
    self.content:SetPos(0, CONTENT_OFFSET)
    self.content:SetWide(w)
end

local function measureContent(content)
    local total = 0
    for _, c in ipairs(content:GetChildren()) do
        if IsValid(c) then
            total = total + c:GetTall()
            local _, t, _, b = c:GetDockMargin()
            total = total + (t or 0) + (b or 0)
        end
    end
    return total
end

function PANEL:Think()
    local ft = FrameTime()

    self._anim = Mantle.func.approachExp(self._anim, self._animTarget, self._animSpeed, ft)
    local eased = Mantle.func.easeOutCubic(self._anim)

    local contentTall = measureContent(self.content)
    if contentTall != self._contentTall then
        self._contentTall = contentTall
        self.content:SetTall(math.max(0, contentTall))
    end

    local targetTall = math.max(HEADER_HEIGHT, math.floor(HEADER_HEIGHT + (contentTall + CONTENT_PADDING) * eased + 0.5))
    if self:GetTall() != targetTall then
        self:SetTall(targetTall)
    end

    local alphaVal = math.floor(255 * eased + 0.5)
    if alphaVal != self._childrenAlpha then
        self._childrenAlpha = alphaVal
        self.content:SetAlpha(alphaVal)
    end

    local visible = eased >= 0.004
    if visible != self._contentVisible then
        self._contentVisible = visible
        self.content:SetVisible(visible)
    end
end

vgui.Register('MantleCategory', PANEL, 'Panel')
