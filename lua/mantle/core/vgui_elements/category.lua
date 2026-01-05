local PANEL = {}

local HEADER_HEIGHT = 30
local HEADER_PADDING_LEFT = 8
local HEADER_FONT_APPROX = 20
local CONTENT_OFFSET = 6
local PADDING = 12
local CONTENT_EXTRA = 16

function PANEL:Init()
    self:SetTall(HEADER_HEIGHT)
    self.name = 'Категория'
    self.isOpen = false
    self.isHeaderCentered = false

    self.childHeights = {}
    self.contentSize = 0

    self._textColor = Mantle.color.text_muted

    self.anim = 0
    self.animTarget = 0
    self.animSpeed = 12
    self.animEased = 0

    self.header = vgui.Create('Button', self)
    self.header:SetText('')
    self.header.Paint = function(_, w, h)
        local targetColor = self.isOpen and Mantle.color.text or Mantle.color.text_muted
        self._textColor = Mantle.func.LerpColor(8, self._textColor, targetColor)

        local posX = self.isHeaderCentered and w * 0.5 or HEADER_PADDING_LEFT
        local alignX = self.isHeaderCentered and TEXT_ALIGN_CENTER or TEXT_ALIGN_LEFT
        local textY = math.floor((HEADER_HEIGHT - HEADER_FONT_APPROX) * 0.5)

        draw.SimpleText(self.name, 'Fated.Medium', posX, textY, self._textColor, alignX)
    end
    self.header.DoClick = function()
        self.isOpen = not self.isOpen
        self.animTarget = self.isOpen and 1 or 0
    end

    self.content = vgui.Create('MantlePanel', self)
    self.content:SetPos(0, HEADER_HEIGHT + CONTENT_OFFSET)
    self.content:SetTall(0)
    self.content:SetWide(self:GetWide() or 0)
end

function PANEL:SetText(name)
    self.name = tostring(name or '')
end

function PANEL:SetCenterText(is_centered)
    self.isHeaderCentered = tobool(is_centered)
end

local function getTopBottomMargin(pnl)
    local l, t, r, b = pnl:GetDockMargin()
    return t or 0, b or 0
end

function PANEL:AddItem(panel)
    panel:SetParent(self.content)
    panel:Dock(TOP)

    local top, bottom = getTopBottomMargin(panel)
    local contribution = math.ceil(panel:GetTall() + top + bottom)

    self.childHeights[panel] = contribution
    self.contentSize = self.contentSize + contribution

    if self.isOpen then
        self:SetTall(HEADER_HEIGHT + CONTENT_OFFSET + self.contentSize + CONTENT_EXTRA + PADDING)
        self.content:SetTall(self.contentSize + CONTENT_EXTRA)
    end

    local old = panel.OnSizeChanged
    panel.OnSizeChanged = function(...)
        if old then old(...) end
        if not IsValid(self) then return end

        local nt, nb = getTopBottomMargin(panel)
        local newContribution = math.ceil(panel:GetTall() + nt + nb)
        local oldContribution = self.childHeights[panel] or 0
        local delta = newContribution - oldContribution

        if delta ~= 0 then
            self.childHeights[panel] = newContribution
            self.contentSize = math.max(0, self.contentSize + delta)
        end
    end

    return panel
end

function PANEL:SetColor(col)
    if not self.isOpen then
        self._textColor = col or Mantle.color.text_muted
    end
end

function PANEL:SetActive(is_active)
    is_active = tobool(is_active)
    if self.isOpen == is_active then return end

    self.isOpen = is_active
    self.animTarget = is_active and 1 or 0
    self._textColor = is_active and Mantle.color.text or Mantle.color.text_muted
end

function PANEL:PerformLayout(w, h)
    self.header:SetPos(0, 0)
    self.header:SetSize(w, HEADER_HEIGHT)

    self.content:SetPos(0, HEADER_HEIGHT + CONTENT_OFFSET)
    self.content:SetWide(w)
end

function PANEL:Think()
    local ft = FrameTime()

    self.anim = Mantle.func.approachExp(self.anim, self.animTarget, self.animSpeed, ft)
    self.animEased = Mantle.func.easeOutCubic(self.anim)

    local totalContent = (self.contentSize + CONTENT_EXTRA) * self.animEased
    local padded = PADDING * self.animEased

    self:SetTall(
        math.max(
            HEADER_HEIGHT,
            math.ceil(HEADER_HEIGHT + CONTENT_OFFSET + totalContent + padded)
        )
    )

    self.content:SetTall(math.ceil(totalContent))
    self.content:SetAlpha(math.floor(255 * self.animEased + 0.5))
end

vgui.Register('MantleCategory', PANEL, 'Panel')
