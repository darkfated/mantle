local PANEL = {}
local color_shadow = Color(0, 0, 0, 120)

local function ClampMenuPosition(panel)
    if not IsValid(panel) then return end
    local x, y = panel:GetPos()
    local w, h = panel:GetSize()
    local sw, sh = Mantle.func.sw, Mantle.func.sh
    if x < 5 then x = 5 elseif x + w > sw - 5 then x = sw - 5 - w end
    if y < 5 then y = 5 elseif y + h > sh - 5 then y = sh - 5 - h end
    panel:SetPos(x, y)
end

function PANEL:Init()
    self.Items = {}
    self:SetSize(160, 0)
    self:DockPadding(6, 7, 6, 7)
    self:MakePopup()
    self:SetKeyboardInputEnabled(false)
    self:SetDrawOnTop(true)
    self.MaxTextWidth = 0

    self._openTime = CurTime()
    self.Think = function()
        if CurTime() - self._openTime < 0.1 then return end

        if input.IsMouseDown(MOUSE_LEFT) or input.IsMouseDown(MOUSE_RIGHT) then
            if not self:IsChildHovered() then
                self:Remove()
            end
        end
    end
end

function PANEL:Paint(w, h)
    RNDX.DrawShadows(16, 0, 0, w, h, Mantle.color.window_shadow, 10, 16, RNDX.SHAPE_IOS)
    RNDX.Draw(16, 0, 0, w, h, Mantle.color.background_panelpopup, RNDX.SHAPE_IOS)
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
                if panel:GetName() == 'MantleDermaMenu' then
                    local parent = panel:GetParent()
                    panel:Remove()
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
                RNDX.DrawShadows(16, 0, 0, w, h, Mantle.color.window_shadow, 5, 20, RNDX.SHAPE_IOS)
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
    local height = 16

    for _, item in ipairs(self.Items) do
        if IsValid(item) then
            height = height + item.sumTall
        end
    end

    local maxWidth = math.max(160, self.MaxTextWidth + 60)

    self:SetSize(maxWidth, math.min(height, ScrH() * 0.8))
end

function PANEL:Open()
    -- Clear
end

function PANEL:CloseMenu()
    self:Remove()
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

    ClampMenuPosition(m)

    Mantle.ui.menu_derma_menu = m

    return m
end
