local PANEL = {}

local mat_close = Material('mantle/close_btn.png')

function PANEL:Init()
    self.bool_alpha = true
    self.title = 'Заголовок'
    self.center_title = ''

    self:DockPadding(6, 30, 6, 6)
    
    self.top_panel = vgui.Create('DButton', self)
    self.top_panel:SetText('')
    self.top_panel:SetCursor('sizeall')
    self.top_panel.Paint = nil
    self.top_panel.OnMousePressed = function(s, key)
        if key == MOUSE_LEFT then
            self.Dragging = {gui.MouseX() - self.x, gui.MouseY() - self.y}
            s:MouseCapture(true)
            self:SetAlpha(200)
        end
    end
    self.top_panel.OnMouseReleased = function(s, key)
        if key == MOUSE_LEFT then
            self.Dragging = nil
            s:MouseCapture(false)
            self:SetAlpha(255)
        end
    end
    self.top_panel.Think = function(s)
        if self.Dragging then
            local mouseX, mouseY = gui.MousePos()
            local newPosX, newPosY = mouseX - self.Dragging[1], mouseY - self.Dragging[2]

            self:SetPos(newPosX, newPosY)
        end
    end

    self.cls = vgui.Create('Button', self)
    self.cls:SetText('')
    self.cls.Paint = function(_, w, h)
        RNDX.DrawMaterial(0, 0, 0, w, h, color_white, mat_close)
    end
    self.cls.DoClick = function()
        self:AlphaTo(0, 0.1, 0, function()
            self:Remove()
        end)

        Mantle.func.sound()
    end
    self.cls.DoRightClick = function()
        local DM = Mantle.ui.derma_menu()

        DM:AddOption('Прозрачность', function()
            self.bool_alpha = !self.bool_alpha
        end, self.bool_alpha and 'icon16/bullet_green.png' or 'icon16/bullet_red.png')

        local boolInput = self:IsKeyboardInputEnabled()
        DM:AddOption('Передвижение из меню', function()
            self:SetKeyBoardInputEnabled(!boolInput)
        end, !boolInput and 'icon16/bullet_green.png' or 'icon16/bullet_red.png')

        DM:AddOption('Закрыть окно', function()
            self:Remove()
        end, 'icon16/cross.png')
    end
end

function PANEL:SetAlphaBackground(is_alpha)
    self.bool_alpha = is_alpha
end

function PANEL:SetTitle(title)
    self.title = title
end

function PANEL:SetCenterTitle(center_title)
    self.center_title = center_title
end

function PANEL:ShowAnimation()
    Mantle.func.animate_appearance(self, self:GetWide(), self:GetTall(), 0.1, 0.2)
end

function PANEL:DisableCloseBtn()
    self.cls:SetVisible(false)
end

function PANEL:SetDraggable(is_draggable)
    self.top_panel:SetVisible(is_draggable)
end

local flagsHeader = RNDX.NO_BL + RNDX.NO_BR
local flagsBackground = RNDX.NO_TL + RNDX.NO_TR

function PANEL:Paint(w, h)
    RNDX.DrawShadows(6, 0, 0, w, h, Mantle.color.window_shadow, 10, 16, RNDX.SHAPE_IOS)
    RNDX.Draw(6, 0, 0, w, 24, Mantle.color.header, flagsHeader)

    if self.bool_alpha then
        RNDX.Draw(6, 0, 24, w, h - 24, Mantle.color.window_blur, flagsBackground + RNDX.BLUR)
    end
    RNDX.Draw(6, 0, 24, w, h - 24, self.bool_alpha and Mantle.color.background_alpha or Mantle.color.background, flagsBackground)

    if self.center_title != '' then
        draw.SimpleText(self.center_title, 'Fated.20b', w * 0.5, 12, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end

    draw.SimpleText(self.title, 'Fated.16', 6, 4, color_white)
end

function PANEL:PerformLayout(w, h)
    self.top_panel:SetSize(w, 24)

    self.cls:SetSize(20, 20)
    self.cls:SetPos(w - 22, 2)
end

vgui.Register('MantleFrame', PANEL, 'EditablePanel')
