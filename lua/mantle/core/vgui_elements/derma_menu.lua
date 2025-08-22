local PANEL = {}

function PANEL:Init()
    self.Items = {}
    self:SetSize(160, 0)
    self:DockPadding(4, 5, 4, 5)
    self:MakePopup()
    self:SetKeyboardInputEnabled(false)
    self:SetDrawOnTop(true)
    self.MaxTextWidth = 0

    self._anim = 0
    self._animTarget = 1
    self._animSpeed = 18
    self._animEased = 0
    self._initPosSet = false
    self._closing = false
    self._disableBlur = false

    self._openTime = CurTime()
    self:SetAlpha(0)

    self.Think = function()
        local ft = FrameTime()

        if not self._initPosSet then
            local tx, ty = self:GetPos()
            Mantle.func.ClampMenuPosition(self)
            self._targetX, self._targetY = self:GetPos()
            self:SetPos(self._targetX, self._targetY + 6)
            self._initPosSet = true
        end

        if CurTime() - self._openTime >= 0.08 then
            if input.IsMouseDown(MOUSE_LEFT) or input.IsMouseDown(MOUSE_RIGHT) then
                if not self:IsChildHovered() then
                    self:CloseMenu()
                end
            end
        end

        self._anim = Mantle.func.approachExp(self._anim, self._animTarget, self._animSpeed, ft)
        self._animEased = self._anim
        local a = math.floor(255 * self._animEased + 0.5)
        self:SetAlpha(a)

        if self._targetX and self._targetY then
            local offsetY = 6 * (1 - self._animEased)
            self:SetPos(self._targetX, self._targetY + offsetY)
        end

        if self._closing and self._animEased <= 0.005 then
            return self:Remove()
        end
    end
end

function PANEL:Paint(w, h)
    local aMul = (self._animEased ~= nil) and self._animEased or ((self:GetAlpha() or 255) / 255)

    local blurMul
    if self._closing or self._disableBlur or self._animTarget == 0 then
        blurMul = 0
    else
        local fadeStart = 0.3
        blurMul = math.Clamp((aMul - fadeStart) / (1 - fadeStart), 0, 1)
    end

    local shadowSpread = math.max(0, math.floor(10 * blurMul))
    local shadowIntensity = math.max(0, math.floor(16 * blurMul))

    RNDX().Rect(0, 0, w, h)
        :Rad(16)
        :Color(Color(Mantle.color.window_shadow.r, Mantle.color.window_shadow.g, Mantle.color.window_shadow.b, math.floor(100 * aMul)))
        :Shape(RNDX.SHAPE_IOS)
        :Shadow(shadowSpread, shadowIntensity)
    :Draw()

    if not self._disableBlur then
        RNDX().Rect(0, 0, w, h)
            :Rad(16)
            :Shape(RNDX.SHAPE_IOS)
            :Blur(blurMul)
        :Draw()
    end

    RNDX().Rect(0, 0, w, h)
        :Rad(16)
        :Color(Color(Mantle.color.background_panelpopup.r, Mantle.color.background_panelpopup.g, Mantle.color.background_panelpopup.b, math.floor(150 * aMul)))
        :Shape(RNDX.SHAPE_IOS)
    :Draw()

    RNDX().Rect(0, 0, w, h)
        :Rad(16)
        :Color(Color(Mantle.color.background_panelpopup.r, Mantle.color.background_panelpopup.g, Mantle.color.background_panelpopup.b, math.floor(150 * aMul)))
        :Shape(RNDX.SHAPE_IOS)
        :Outline(1)
    :Draw()
end

function PANEL:AddOption(text, func, icon, optData)
    surface.SetFont('Fated.18')
    local textW = select(1, surface.GetTextSize(text))
    self.MaxTextWidth = math.max(self.MaxTextWidth or 0, textW)

    local option = vgui.Create('DButton', self)
    option:SetText('')
    option:Dock(TOP)
    option:DockMargin(2, 2, 2, 0)
    option:SetTall(26)
    option.sumTall = 28
    option.Icon = icon
    option.Text = text

    option._submenu = nil
    option._submenu_open = false

    option.DoClick = function()
        if option._submenu then
            if option._submenu_open then
                option:CloseSubMenu()
            else
                option:OpenSubMenu()
            end
            return
        end
        if func then func() end
        Mantle.func.sound()
        local function closeAllMenus(panel)
            while IsValid(panel) do
                if panel.GetName and panel:GetName() == 'MantleDermaMenu' then
                    local parent = panel:GetParent()
                    panel:CloseMenu()
                    panel = parent
                else
                    panel = panel:GetParent()
                end
            end
        end
        closeAllMenus(option)
    end

    function option:AddSubMenu()
        if IsValid(option._submenu) then option._submenu:Remove() end
        local submenu = vgui.Create('MantleDermaMenu')
        submenu:SetDrawOnTop(true)
        submenu:SetParent(self:GetParent())
        submenu:SetVisible(false)
        option._submenu = submenu
        option._submenu_open = false

        option.OnRemove = function()
            if IsValid(submenu) then submenu:Remove() end
        end

        function option:OpenSubMenu()
            if not IsValid(submenu) then return end
            for _, sibling in ipairs(self:GetParent().Items or {}) do
                if sibling ~= self and sibling.CloseSubMenu then sibling:CloseSubMenu() end
            end
            local x, y = self:LocalToScreen(self:GetWide(), 0)
            submenu:SetPos(x, y)
            Mantle.func.ClampMenuPosition(submenu)
            submenu._targetX, submenu._targetY = submenu:GetPos()
            submenu:SetVisible(true)
            submenu:MakePopup()
            submenu:SetKeyboardInputEnabled(false)
            option._submenu_open = true
        end

        function option:CloseSubMenu()
            if IsValid(submenu) then submenu:SetVisible(false) end
            option._submenu_open = false
            if submenu.Items then
                for _, item in ipairs(submenu.Items) do
                    if item.CloseSubMenu then item:CloseSubMenu() end
                end
            end
        end

        local function isAnySubmenuHovered(opt)
            if not IsValid(opt) then return false end
            if opt:IsHovered() then return true end
            if opt._submenu and IsValid(opt._submenu) and opt._submenu:IsVisible() then
                if isAnySubmenuHovered(opt._submenu) then return true end
                for _, item in ipairs(opt._submenu.Items or {}) do
                    if isAnySubmenuHovered(item) then return true end
                end
            end
            return false
        end

        option.OnCursorExited = function(pnl)
            timer.Simple(0.15, function()
                if not isAnySubmenuHovered(pnl) then
                    pnl:CloseSubMenu()
                end
            end)
        end
        submenu.OnCursorExited = function(pnl)
            timer.Simple(0.15, function()
                if not isAnySubmenuHovered(option) then
                    option:CloseSubMenu()
                end
            end)
        end

        return submenu
    end

    option.AddSubMenu = option.AddSubMenu

    if optData then
        for k, v in pairs(optData) do
            option[k] = v
        end
    end

    local iconMat

    if option.Icon then
        iconMat = type(option.Icon) == 'IMaterial' and option.Icon or Material(option.Icon)
    end

    option.Paint = function(pnl, w, h)
        w = w or pnl:GetWide()
        h = h or pnl:GetTall()

        if pnl:IsHovered() then
            if Mantle.ui.convar.depth_ui then
                RNDX().Rect(0, 0, w, h)
                    :Rad(16)
                    :Color(Mantle.color.window_shadow)
                    :Shape(RNDX.SHAPE_IOS)
                    :Shadow(5, 20)
                :Draw()
            end
            RNDX.Draw(16, 0, 0, w, h, Mantle.color.hover, RNDX.SHAPE_IOS)

            if pnl._submenu and not pnl._submenu_open then
                pnl:OpenSubMenu()
            end
        end

        if iconMat then
            local iconSize = 16
            RNDX.DrawMaterial(0, 10, (h - iconSize) / 2, iconSize, iconSize, color_white, iconMat)
        end

        draw.SimpleText(pnl.Text, 'Fated.18', pnl.Icon and 32 or 14, h * 0.5, Mantle.color.text, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
    end

    table.insert(self.Items, option)

    self:UpdateSize()

    return option
end

function PANEL:AddSpacer()
    local spacer = vgui.Create('DPanel', self)
    spacer:Dock(TOP)
    spacer:DockMargin(8, 6, 8, 6)
    spacer:SetTall(1)
    spacer.sumTall = 13
    spacer.Paint = function(_, w, h)
        RNDX.Draw(0, 0, 0, w, h, Mantle.color.focus_panel)
    end

    table.insert(self.Items, spacer)
    self:UpdateSize()

    return spacer
end

function PANEL:UpdateSize()
    local height = 12
    for _, item in ipairs(self.Items) do
        if IsValid(item) then
            height = height + (item.sumTall or item:GetTall())
        end
    end

    local maxWidth = math.max(160, self.MaxTextWidth + 56)
    self:SetSize(maxWidth, math.min(height, ScrH() * 0.8))

    if not self._targetX or not self._targetY then
        Mantle.func.ClampMenuPosition(self)
        self._targetX, self._targetY = self:GetPos()
        if not self._initPosSet then
            self:SetPos(self._targetX, self._targetY + 6)
        end
    else
        Mantle.func.ClampMenuPosition(self)
        self._targetX, self._targetY = self:GetPos()
    end
end

function PANEL:Open()
    -- Clear
end

function PANEL:CloseMenu()
    if self._closing then return end
    self._closing = true
    self._animTarget = 0
    self._disableBlur = true
end

function PANEL:GetDeleteSelf()
    return true
end

vgui.Register('MantleDermaMenu', PANEL, 'DPanel')

function Mantle.ui.derma_menu()
    if IsValid(Mantle.ui.menu_derma_menu) then
        Mantle.ui.menu_derma_menu:CloseMenu()
    end

    local mouseX, mouseY = input.GetCursorPos()
    local m = vgui.Create('MantleDermaMenu')
    m:SetPos(mouseX, mouseY)

    Mantle.func.ClampMenuPosition(m)

    m._targetX, m._targetY = m:GetPos()
    Mantle.ui.menu_derma_menu = m

    return m
end
