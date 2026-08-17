local PANEL = {}

local mat_close = Material('mantle/close_btn_new.png')

local HEADER_TALL = 24

function PANEL:Init()
    self.alpha = true
    self.lite = false
    self.draggable = true
    self.title = Mantle.lang.get('mantle', 'frame_title')
    self.centerTitle = ''

    self._drag = nil

    self:DockPadding(8, HEADER_TALL + 8, 8, 8)

    self.header = vgui.Create('Panel', self)
    self.header:SetCursor('sizeall')
    self.header.Paint = nil
    self.header.frame = self

    function self.header:OnMousePressed(key)
        local frame = self.frame
        if key != MOUSE_LEFT or !frame.draggable then return end

        frame._drag = {
            x = gui.MouseX() - frame.x,
            y = gui.MouseY() - frame.y
        }
        self:MouseCapture(true)
        frame:SetAlpha(200)
    end

    function self.header:OnMouseReleased(key)
        if key != MOUSE_LEFT then return end

        local frame = self.frame
        frame._drag = nil
        self:MouseCapture(false)
        frame:SetAlpha(255)
    end

    function self.header:Think()
        local frame = self.frame
        if !frame._drag then return end

        frame:SetPos(gui.MouseX() - frame._drag.x, gui.MouseY() - frame._drag.y)
    end

    self.cls = vgui.Create('MantleBtn', self)
    self.cls:SetRadius(6)
    self.cls.Paint = function(btn, w, h)
        if btn:IsHovered() then
            RNDX.Rect(2, 2, w - 4, h - 4)
                :Rad(6)
                :Color(Mantle.color.hover_overlay)
            :Draw()
        end

        RNDX.Rect(4, 4, w - 8, h - 8)
            :Color(Mantle.color.header_text)
            :Material(mat_close)
        :Draw()
    end
    self.cls.DoClick = function()
        self:Close()
        Mantle.func.sound()
    end
    self.cls.DoRightClick = function()
        local DM = Mantle.ui.derma_menu()

        DM:AddOption(Mantle.lang.get('mantle', 'frame_alpha'), function()
            self.alpha = !self.alpha
        end, self.alpha and 'icon16/bullet_green.png' or 'icon16/bullet_red.png')

        local boolInput = self:IsKeyboardInputEnabled()
        DM:AddOption(Mantle.lang.get('mantle', 'frame_move_from_menu'), function()
            self:SetKeyBoardInputEnabled(!boolInput)
        end, !boolInput and 'icon16/bullet_green.png' or 'icon16/bullet_red.png')

        DM:AddOption(Mantle.lang.get('mantle', 'frame_close_window'), function()
            self:Remove()
        end, 'icon16/cross.png')
    end
end

function PANEL:SetAlphaBackground(isAlpha)
    self.alpha = isAlpha
end

function PANEL:SetTitle(title)
    self.title = title
end

function PANEL:SetCenterTitle(centerTitle)
    self.centerTitle = centerTitle
end

function PANEL:ShowAnimation()
    Mantle.func.animate_appearance(self, self:GetWide(), self:GetTall(), 0.3, 0.2)
end

function PANEL:Close()
    if self._closing then return end
    self._closing = true

    self:AlphaTo(0, 0.1, 0, function()
        self:Remove()
    end)
end

function PANEL:DisableCloseBtn()
    self.cls:SetVisible(false)
end

function PANEL:SetDraggable(isDraggable)
    self.draggable = isDraggable
end

function PANEL:SetPopupPad(pad)
    self:DockPadding(pad, HEADER_TALL + pad, pad, pad)
end

function PANEL:LiteMode()
    if self.lite then return end

    self.lite = true
    self:DockPadding(24, 24, 24, 24)
    self.cls:SetZPos(2)
end

function PANEL:Notify(text, duration, col)
    if IsValid(self.messagePanel) then self.messagePanel:Remove() end
    duration = duration or 2
    col = col or Mantle.color.theme

    surface.SetFont('Fated.20')
    local tw, th = surface.GetTextSize(text)

    local mp = vgui.Create('Panel', self)
    mp:SetSize(tw + 16, th + 8)
    mp:SetMouseInputEnabled(false)
    mp:SetAlpha(0)
    mp:SetPos((self:GetWide() - mp:GetWide()) * 0.5, self:GetTall() + mp:GetTall())

    local endY = self:GetTall() - mp:GetTall() - 16

    mp.Paint = function(_, w, h)
        RNDX.Rect(0, 0, w, h)
            :Rad(14)
            :Blur(2)
        :Draw()
        RNDX.Rect(0, 0, w, h)
            :Rad(14)
            :Color(Mantle.color.background_panelpopup)
        :Draw()
        RNDX.Rect(0, 0, w, h)
            :Rad(14)
            :Color(Mantle.color.notify_outline)
            :Outline(1)
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

function PANEL:Paint(w, h)
    local col = Mantle.color.window_shadow
    RNDX.Rect(0, 0, w, h)
        :Radii(6, 6, 6, 6)
        :Color(col)
        :Shadow(20, 12)
    :Draw()
    RNDX.Rect(0, 0, w, h)
        :Radii(6, 6, 6, 6)
        :Color(col)
        :Shadow(6, 3)
    :Draw()

    local lite = self.lite
    local headerTall = lite and 0 or HEADER_TALL
    local bodyRad = lite and 6 or 0

    local alphaBg = self.alpha and Mantle.ui.convar.blur
    if alphaBg then
        RNDX.Rect(0, 0, w, h)
            :Radii(bodyRad, bodyRad, 6, 6)
            :Blur()
        :Draw()
    end

    RNDX.Rect(0, 0, w, h)
        :Radii(bodyRad, bodyRad, 6, 6)
        :Color(alphaBg and Mantle.color.background_alpha or Mantle.color.background)
    :Draw()

    if !lite then
        RNDX.Rect(0, 0, w, headerTall)
            :Radii(6, 6, 0, 0)
            :Color(Mantle.color.header)
        :Draw()
    end

    if lite then return end

    Mantle.func.gradient(0, headerTall, w, 6, 2, Mantle.color.window_shadow)

    if self.centerTitle != '' then
        draw.SimpleText(self.centerTitle, 'Fated.20b', w * 0.5, 12, Mantle.color.header_text, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end

    if self.title != '' then
        draw.SimpleText(self.title, 'Fated.16', 6, 4, Mantle.color.header_text)
    end
end

function PANEL:PerformLayout(w, h)
    self.header:SetSize(w - 24, HEADER_TALL)

    self.cls:SetSize(24, 24)
    self.cls:SetPos(w - 24, 0)
end

vgui.Register('MantleFrame', PANEL, 'EditablePanel')
