local PANEL = {}

local math_floor = math.floor

local HEIGHT = 32
local PAD = 12
local RADIUS = 12

function PANEL:Init()
    self:DockMargin(8, 8, 8, 8)
    self.choices = {}
    self.selected = nil
    self.selectedIndex = nil
    self.opened = false
    self:SetTall(HEIGHT)
    self:SetText('')
    self.hoverAnim = 0
    self._focusLerp = 0
    self.OnSelect = function(_, _, _) end

    self.btn = vgui.Create('Button', self)
    self.btn:Dock(FILL)
    self.btn:SetText('')
    self.btn:SetCursor('hand')

    self.btn.Paint = function(button, w, h)
        local ft = FrameTime()
        local target = button:IsHovered() and 1 or 0
        self.hoverAnim = Mantle.func.approachExp(self.hoverAnim, target, 12, ft)
        self._focusLerp = Mantle.func.approachExp(self._focusLerp, self.opened and 1 or 0, 10, ft)

        RNDX.Rect(0, 0, w, h)
            :Rad(RADIUS)
            :Color(Mantle.color.focus_panel)
        :Draw()

        if self.hoverAnim > 0.01 then
            local hv = Mantle.color.hover_overlay
            RNDX.Rect(0, 0, w, h)
                :Rad(RADIUS)
                :Color(Color(hv.r, hv.g, hv.b, math_floor(hv.a * self.hoverAnim)))
            :Draw()
        end

        if self._focusLerp > 0.01 then
            local theme = Mantle.color.theme
            RNDX.Rect(0, 0, w, h)
                :Rad(RADIUS)
                :Color(Color(theme.r, theme.g, theme.b, math_floor(60 * self._focusLerp)))
            :Draw()
            RNDX.Rect(0, 0, w, h)
                :Rad(RADIUS)
                :Color(Color(theme.r, theme.g, theme.b, math_floor(160 * self._focusLerp)))
                :Outline(1)
            :Draw()
        end

        local text = self.selected or self.placeholder or Mantle.lang.get('mantle', 'color_select') .. '...'
        local col = self.selected and Mantle.color.theme or Mantle.color.gray

        draw.SimpleText(text, 'Fated.16', PAD, h * 0.5, col, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
    end

    self.btn.DoClick = function()
        if IsValid(self.menu) and !self.menu._closing then
            self:CloseMenu()
        else
            self:OpenMenu()
            Mantle.func.sound()
        end
    end
end

function PANEL:AddChoice(text, data)
    self.choices[#self.choices + 1] = {text = text, data = data}
    return #self.choices
end

function PANEL:SetValue(text)
    self.selected = nil
    self.selectedIndex = nil

    for i, choice in ipairs(self.choices) do
        if choice.text == text then
            self.selected = choice.text
            self.selectedIndex = i
            return
        end
    end
end

function PANEL:GetValue()
    return self.selected
end

function PANEL:SetPlaceholder(text)
    self.placeholder = text
end

function PANEL:SelectChoice(index)
    local choice = self.choices[index]
    if !choice then return end

    self.selected = choice.text
    self.selectedIndex = index

    if self.OnSelect then
        self.OnSelect(index, choice.text, choice.data)
    end
end

function PANEL:OpenMenu()
    if IsValid(self.menu) then
        self.menu:Remove()
    end

    local menu = vgui.Create('MantleDermaMenu')
    menu._owner = self

    for i, choice in ipairs(self.choices) do
        menu:AddOption(choice.text, function()
            self:SelectChoice(i)
        end, nil, {
            selected = i == self.selectedIndex
        })
    end

    menu:SetAnchor(self)
    menu:UpdateSize()

    self.menu = menu
    self.opened = true

    menu.OnRemove = function()
        if self.menu != menu then return end
        self.menu = nil
        self.opened = false
    end
end

function PANEL:CloseMenu()
    if IsValid(self.menu) then
        self.menu:CloseMenu()
    end
    self.opened = false
end

function PANEL:Think()
    if !IsValid(self.menu) then return end

    local panel = self
    while IsValid(panel) do
        if !panel:IsVisible() then
            self:CloseMenu()
            return
        end
        panel = panel:GetParent()
    end
end

function PANEL:OnRemove()
    if IsValid(self.menu) then
        self.menu:Remove()
    end
    self.menu = nil
    self.opened = false
end

vgui.Register('MantleComboBox', PANEL, 'Panel')
