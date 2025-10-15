local PANEL = {}

local mat_close = Material('mantle/close_btn_new.png')

function PANEL:Init()
    self.bool_alpha = true
    self.bool_lite = false
    self.title = Mantle.lang.get('mantle', 'frame_title')
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
        RNDX().Rect(2, 2, w - 4, h - 4)
            :Color(Mantle.color.header_text)
            :Material(mat_close)
        :Draw()
    end
    self.cls.DoClick = function()
        self:AlphaTo(0, 0.1, 0, function()
            self:Remove()
        end)

        Mantle.func.sound()
    end
    self.cls.DoRightClick = function()
        local DM = Mantle.ui.derma_menu()

        DM:AddOption(Mantle.lang.get('mantle', 'frame_alpha'), function()
            self.bool_alpha = !self.bool_alpha
        end, self.bool_alpha and 'icon16/bullet_green.png' or 'icon16/bullet_red.png')

        local boolInput = self:IsKeyboardInputEnabled()
        DM:AddOption(Mantle.lang.get('mantle', 'frame_move_from_menu'), function()
            self:SetKeyBoardInputEnabled(!boolInput)
        end, !boolInput and 'icon16/bullet_green.png' or 'icon16/bullet_red.png')

        DM:AddOption(Mantle.lang.get('mantle', 'frame_close_window'), function()
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
    Mantle.func.animate_appearance(self, self:GetWide(), self:GetTall(), 0.3, 0.2)
end

function PANEL:DisableCloseBtn()
    self.cls:SetVisible(false)
end

function PANEL:SetDraggable(is_draggable)
    self.top_panel:SetVisible(is_draggable)
end

function PANEL:LiteMode()
    self.bool_lite = true
    self:DockPadding(6, 6, 6, 6)

    self.cls:SetZPos(2)
end

function PANEL:Notify(text, duration, col)
    if IsValid(self.messagePanel) then self.messagePanel:Remove() end
    duration = duration or 2
    col = col or Mantle.color.theme

    surface.SetFont('Fated.20')
    local tw, th = surface.GetTextSize(text)

    local mp = vgui.Create('DPanel', self)
    mp:SetSize(tw + 16, th + 8)
    mp:SetMouseInputEnabled(false)
    local startY = self:GetTall() + mp:GetTall()
    local endY = self:GetTall() - mp:GetTall() - 16
    mp:SetPos((self:GetWide() - mp:GetWide()) * 0.5, startY)
    mp:SetAlpha(0)
    mp.Paint = function(_, w, h)
        RNDX().Rect(0, 0, w, h)
            :Rad(16)
            :Color(col)
            :Shadow(7, 20)
            :Outline(3)
            :Clip(self)
        :Draw()
        RNDX().Rect(0, 0, w, h)
            :Rad(16)
            :Color(col)
        :Draw()
        draw.SimpleText(text, 'Fated.20', w * 0.5, h * 0.5 - 1, Mantle.color.text, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end

    mp:MoveTo(mp.x, endY, 0.3, 0, 0.7)
    mp:AlphaTo(255, 0.3, 0, function()
        timer.Simple(duration, function()
            if !IsValid(mp) then return end
            mp:AlphaTo(0, 0.25, 0, function()
                if IsValid(mp) then
                    mp:Remove()
                end
            end)
        end)
    end)

    self.messagePanel = mp
end

local flagsHeader = RNDX.NO_BL + RNDX.NO_BR
local flagsBackground = RNDX.NO_TL + RNDX.NO_TR

function PANEL:Paint(w, h)
    RNDX().Rect(0, 0, w, h)
        :Rad(6)
        :Color(Mantle.color.window_shadow)
        :Shadow(10, 16)
        :Shape(RNDX.SHAPE_IOS)
    :Draw()
    if !self.bool_lite then
        RNDX().Rect(0, 0, w, 24)
            :Radii(6, 6, 0, 0)
            :Color(Mantle.color.header)
        :Draw()
    end

    local headerTall = self.bool_lite and 0 or 24
    if self.bool_alpha and Mantle.ui.convar.blur then
        RNDX().Rect(0, headerTall, w, h - headerTall)
            :Radii(self.bool_lite and 6 or 0, self.bool_lite and 6 or 0, 6, 6)
            :Blur()
        :Draw()
    end

    if !self.bool_lite then
        Mantle.func.gradient(0, 24, w, 6, 2, Mantle.color.window_shadow)
    end

    RNDX().Rect(0, headerTall, w, h - headerTall)
        :Radii(self.bool_lite and 6 or 0, self.bool_lite and 6 or 0, 6, 6)
        :Color((self.bool_alpha and Mantle.ui.convar.blur) and Mantle.color.background_alpha or Mantle.color.background)
    :Draw()

    if !self.bool_lite then
        if self.center_title != '' then
            draw.SimpleText(self.center_title, 'Fated.20b', w * 0.5, 12, Mantle.color.header_text, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end

        draw.SimpleText(self.title, 'Fated.16', 6, 4, Mantle.color.header_text)
    end
end

function PANEL:PerformLayout(w, h)
    self.top_panel:SetSize(w, 24)

    self.cls:SetSize(20, 20)
    self.cls:SetPos(w - 22, 2)
end

vgui.Register('MantleFrame', PANEL, 'EditablePanel')
