local PANEL = {}

local math_floor = math.floor

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

        if Mantle.ui.convar.depth_ui then
            RNDX.Rect(0, 0, w, h)
                :Rad(RADIUS)
                :Color(Mantle.color.window_shadow)
                :Shadow(4, 2)
            :Draw()
        end

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
                :Shadow(4, self._focusLerp * 2)
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
        menu:AddOption(choice.text, onClick, nil, {
            selected = choice.text == self.selected
        })
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
