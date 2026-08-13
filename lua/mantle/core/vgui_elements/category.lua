local PANEL = {}

local HEADER_HEIGHT = 30
local CONTENT_OFFSET = 36
local CONTENT_PADDING = 12

function PANEL:Init()
    self:SetTall(HEADER_HEIGHT)

    self.name = 'Категория'
    self.bool_opened = false
    self.bool_header_centered = false
    self.header_color = Mantle.color.category
    self.header_color_standard = self.header_color
    self.header_color_opened = Mantle.color.category_opened

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
            :Color(self.header_color)
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

    self.content = vgui.Create('Panel', self)
    self.content:SetVisible(false)
    self._contentVisible = false
end

function PANEL:SetText(name)
    self.name = name
end

function PANEL:SetCenterText(is_centered)
    self.bool_header_centered = is_centered
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

function PANEL:IsActive()
    return self.bool_opened
end

function PANEL:AddItem(panel)
    if panel:GetParent() == self.content then return panel end
    panel:SetParent(self.content)
    return panel
end

function PANEL:Clear()
    for _, c in ipairs(self.content:GetChildren()) do c:Remove() end
    self.bool_opened = false
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
        if IsValid(c) and c.GetTall then
            total = total + c:GetTall()
            if c.GetDockMargin then
                local _, t, _, b = c:GetDockMargin()
                total = total + (t or 0) + (b or 0)
            end
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
