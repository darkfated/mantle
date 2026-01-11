local PANEL = {}

local HEIGHT = 32
local PAD = 12
local RADIUS = 12

function PANEL:Init()
    self.choices = {}
    self.selected = nil
    self.opened = false
    self:SetTall(HEIGHT)
    self:SetText('')
    self.hoverAnim = 0
    self.OnSelect = function(_, _, _) end

    self.btn = vgui.Create('Button', self)
    self.btn:Dock(FILL)
    self.btn:DockMargin(0, 0, 0, 0)
    self.btn:SetText('')
    self.btn:SetCursor('hand')

    self.btn.Paint = function(_, w, h)
        if _.IsHovered(_) then
            self.hoverAnim = Mantle.func.approachExp(self.hoverAnim, 1, 8, FrameTime())
        else
            self.hoverAnim = Mantle.func.approachExp(self.hoverAnim, 0, 12, FrameTime())
        end

        RNDX().Rect(0, 0, w, h)
            :Rad(RADIUS)
            :Color(Mantle.color.p)
            :Shape(RNDX.SHAPE_IOS)
        :Draw()

        RNDX().Rect(0, 0, w, h)
            :Rad(RADIUS)
            :Color(Mantle.color.p_outline)
            :Outline(1)
            :Shape(RNDX.SHAPE_IOS)
        :Draw()

        if self.hoverAnim > 0 then
            local hcol = Color(Mantle.color.p_hovered.r, Mantle.color.p_hovered.g, Mantle.color.p_hovered.b, math.floor(255 * self.hoverAnim))
            RNDX().Rect(0, 0, w, h)
                :Rad(RADIUS)
                :Color(hcol)
                :Shape(RNDX.SHAPE_IOS)
            :Draw()
        end

        local text = self.selected or self.placeholder or Mantle.lang.get('mantle', 'color_select') .. '...'
        local col = Mantle.color.text_muted
        if self.selected then col = Mantle.color.text end

        draw.SimpleText(text, 'Fated.Regular', PAD, h * 0.5, col, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)

        local arrowSize = 6
        local ax = w - PAD - arrowSize
        local ay = h * 0.5
        surface.SetDrawColor(col)
        draw.NoTexture()
        surface.DrawPoly({
            {x = ax - arrowSize, y = ay - arrowSize / 2},
            {x = ax + arrowSize, y = ay - arrowSize / 2},
            {x = ax, y = ay + arrowSize / 2}
        })
    end

    self.btn.DoClick = function()
        if self.opened then
            self:CloseMenu()
        else
            self:OpenMenu()
            Mantle.func.sound()
        end
    end
end

function PANEL:AddChoice(text, data)
    table.insert(self.choices, {text = text, data = data})
end

function PANEL:SetValue(val)
    self.selected = val
end

function PANEL:GetValue()
    return self.selected
end

function PANEL:SetPlaceholder(text)
    self.placeholder = text
end

function PANEL:OpenMenu()
    if IsValid(self.menu) then
        self.menu:CloseMenu()
    end

    local x, y = self:LocalToScreen(0, self:GetTall())
    local menu = vgui.Create('MantleDermaMenu')
    menu:SetParent(nil)
    menu:SetPos(x, y)

    for i, choice in ipairs(self.choices) do
        local function onClick()
            self.selected = choice.text

            if IsValid(menu) then
                menu:CloseMenu()
            end
            if self.OnSelect then
                self.OnSelect(i, choice.text, choice.data)
            end
            Mantle.func.sound()
        end
        menu:AddOption(choice.text, onClick)
    end

    menu:MakePopup()
    menu:SetKeyboardInputEnabled(false)
    menu._initPosSet = false
    menu:UpdateSize()

    self.menu = menu
    self.opened = true

    menu.OnRemove = function()
        if IsValid(self) then
            self.opened = false
        end
    end
end

function PANEL:CloseMenu()
    if IsValid(self.menu) then
        self.menu:CloseMenu()
    end
    self.opened = false
end

function PANEL:OnRemove()
    self:CloseMenu()
end

vgui.Register('MantleComboBox', PANEL, 'Panel')
