local PANEL = {}

local math_max = math.max
local math_floor = math.floor

local MIN_WIDTH = 160
local PAD = 6
local ITEM_HEIGHT = 32
local RADIUS = 14

function PANEL:Init()
    self.Items = {}
    self:SetSize(MIN_WIDTH, 0)
    self:DockPadding(PAD, PAD, PAD, PAD)
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
    self._targetX = nil
    self._targetY = nil
    self:SetAlpha(0)

    self._hoverX = 0
    self._hoverY = 0
    self._hoverW = 0
    self._hoverH = 0
    self._hoverA = 0

    self._hoverBar = vgui.Create('Panel', self)
    self._hoverBar:SetMouseInputEnabled(false)
    self._hoverBar.Paint = function(_, w, h)
        local a = self._hoverA
        if a <= 0.01 then return end
        local hv = Mantle.color.hover_overlay_strong
        RNDX.Rect(0, 0, w, h)
            :Rad(8)
            :Color(Color(hv.r, hv.g, hv.b, math_floor(hv.a * a)))
        :Draw()
    end

    self.Think = function()
        local ft = FrameTime()

        if !self._initPosSet then
            Mantle.func.ClampMenuPosition(self)
            self._targetX, self._targetY = self:GetPos()
            self:SetPos(self._targetX, self._targetY + 6)
            self._initPosSet = true
        end

        if CurTime() - self._openTime >= 0.08 then
            if (input.IsMouseDown(MOUSE_LEFT) or input.IsMouseDown(MOUSE_RIGHT)) and !self:IsChildHovered() then
                self:CloseMenu()
            end
        end

        local _, my = self:ScreenToLocal(input.GetCursorPos())

        local hovered
        for _, item in ipairs(self.Items) do
            if IsValid(item) and item.Text != nil then
                local overItem = my >= item:GetY() and my <= item:GetY() + item:GetTall()
                local overSub = IsValid(item._submenu) and item._submenu:IsVisible() and item._submenu:IsHovered()
                if overItem or overSub then
                    hovered = item
                    break
                end
            end
        end

        if !IsValid(hovered) and IsValid(self._hoverParent) and self._hoverParent._submenu == self and self._hoverParent._submenu_open then
            for _, item in ipairs(self.Items) do
                if IsValid(item) and item.Text != nil then
                    hovered = item
                    break
                end
            end
        end

        local speed = 30
        if IsValid(hovered) then
            self._hoverA = Mantle.func.approachExp(self._hoverA, 1, speed, ft)
            self._hoverX = Mantle.func.approachExp(self._hoverX, hovered:GetX(), speed, ft)
            self._hoverY = Mantle.func.approachExp(self._hoverY, hovered:GetY(), speed, ft)
            self._hoverW = Mantle.func.approachExp(self._hoverW, hovered:GetWide(), speed, ft)
            self._hoverH = Mantle.func.approachExp(self._hoverH, hovered:GetTall(), speed, ft)
        else
            self._hoverA = Mantle.func.approachExp(self._hoverA, 0, 20, ft)
        end

        self._hoverBar:SetPos(self._hoverX, self._hoverY)
        self._hoverBar:SetSize(self._hoverW, self._hoverH)

        self._anim = Mantle.func.approachExp(self._anim, self._animTarget, self._animSpeed, ft)
        self._animEased = self._anim
        self:SetAlpha(math_floor(255 * self._animEased + 0.5))

        if self._targetX and self._targetY then
            self:SetPos(self._targetX, self._targetY + 6 * (1 - self._animEased))
        end

        if self._closing and self._animEased <= 0.005 then
            return self:Remove()
        end
    end
end

function PANEL:Paint(w, h)
    local aMul = self._animEased or (self:GetAlpha() or 255) / 255

    local blurMul = 0
    if !(self._closing or self._disableBlur or self._animTarget == 0) then
        if self._animTarget == 1 then
            blurMul = math.Clamp((aMul - 0.6) / 0.4, 0, 1)
        else
            blurMul = math.Clamp(aMul / 0.3, 0, 1)
        end
    end

    if !self._disableBlur then
        RNDX.Rect(0, 0, w, h)
            :Rad(RADIUS)
            :Blur(blurMul)
        :Draw()
    end

    local bg = Mantle.color.background_panelpopup
    RNDX.Rect(0, 0, w, h)
        :Rad(RADIUS)
        :Color(Color(bg.r, bg.g, bg.b, math_floor((bg.a or 150) * aMul)))
    :Draw()

    RNDX.Rect(0, 0, w, h)
        :Rad(RADIUS)
        :Color(Mantle.color.window_shadow)
        :Outline(1)
    :Draw()
end

function PANEL:AddOption(text, func, icon, optData)
    surface.SetFont('Fated.16')
    self.MaxTextWidth = math_max(self.MaxTextWidth, surface.GetTextSize(text))

    local option = vgui.Create('Button', self)
    option:SetText('')
    option:Dock(TOP)
    option:DockMargin(0, 2, 0, 0)
    option:SetTall(ITEM_HEIGHT)
    option.sumTall = ITEM_HEIGHT + 2
    option.Icon = icon
    option.Text = text
    option._submenu = nil
    option._submenu_open = false
    option._iconMat = icon and (type(icon) == 'IMaterial' and icon or Material(icon)) or nil

    if optData then
        for k, v in pairs(optData) do
            option[k] = v
        end
    end

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

        local panel = option
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

    option.Paint = function(pnl, w, h)
        if pnl._submenu and !pnl._submenu_open and pnl:IsHovered() then
            pnl:OpenSubMenu()
        end

        local iconSize = 16
        local textX = 10
        if pnl._iconMat then
            RNDX.Rect(12, (h - iconSize) / 2, iconSize, iconSize)
                :Material(pnl._iconMat)
                :Color(Mantle.color.text)
            :Draw()
            textX = 36
        end

        local col = Mantle.color.text
        if pnl.selected then
            col = Mantle.color.theme
        end

        draw.SimpleText(pnl.Text, 'Fated.16', textX, h * 0.5 - 1, col, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)

        if pnl._submenu then
            local s = 4
            local cx = w - 14
            local cy = h * 0.5
            surface.SetDrawColor(Mantle.color.gray)
            draw.NoTexture()
            surface.DrawPoly({
                {x = cx - s, y = cy - s * 0.7},
                {x = cx + s, y = cy - s * 0.7},
                {x = cx, y = cy + s * 0.7}
            })
        end
    end

    function option:AddSubMenu()
        if IsValid(option._submenu) then option._submenu:Remove() end
        local submenu = vgui.Create('MantleDermaMenu')
        submenu:SetDrawOnTop(true)
        submenu:SetParent(self:GetParent())
        submenu:SetVisible(false)
        option._submenu = submenu
        option._submenu_open = false
        submenu._hoverParent = option

        option.OnRemove = function()
            if IsValid(submenu) then submenu:Remove() end
        end

        function option:OpenSubMenu()
            if !IsValid(submenu) then return end
            for _, sibling in ipairs(self:GetParent().Items or {}) do
                if sibling != self and sibling.CloseSubMenu then sibling:CloseSubMenu() end
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
            if !IsValid(opt) then return false end
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
                if !isAnySubmenuHovered(pnl) and IsValid(pnl) then pnl:CloseSubMenu() end
            end)
        end
        submenu.OnCursorExited = function(pnl)
            timer.Simple(0.15, function()
                if !isAnySubmenuHovered(option) and IsValid(pnl) then option:CloseSubMenu() end
            end)
        end

        return submenu
    end

    table.insert(self.Items, option)
    self:UpdateSize()
    return option
end

function PANEL:AddSpacer()
    local spacer = vgui.Create('Panel', self)
    spacer:Dock(TOP)
    spacer:DockMargin(6, 4, 6, 4)
    spacer:SetTall(1)
    spacer.sumTall = 9
    spacer.Paint = function(_, w, h)
        RNDX.Rect(0, 0, w, h)
            :Color(Mantle.color.window_shadow)
        :Draw()
    end
    table.insert(self.Items, spacer)
    self:UpdateSize()
    return spacer
end

function PANEL:UpdateSize()
    local height = PAD * 2
    for _, item in ipairs(self.Items) do
        if IsValid(item) then height = height + (item.sumTall or item:GetTall()) end
    end
    local maxWidth = math_max(MIN_WIDTH, self.MaxTextWidth + 56)
    self:SetSize(maxWidth, math.min(height, ScrH() * 0.8))

    if !self._targetX or !self._targetY then
        Mantle.func.ClampMenuPosition(self)
        self._targetX, self._targetY = self:GetPos()
        if !self._initPosSet then self:SetPos(self._targetX, self._targetY + 6) end
    else
        Mantle.func.ClampMenuPosition(self)
        self._targetX, self._targetY = self:GetPos()
    end
end

function PANEL:CloseMenu()
    if self._closing then return end
    self._closing = true
    self._disableBlur = true
    self._animTarget = 0
end

function PANEL:GetDeleteSelf()
    return true
end

vgui.Register('MantleDermaMenu', PANEL, 'Panel')

function Mantle.ui.derma_menu()
    if IsValid(Mantle.ui.menu_derma_menu) then Mantle.ui.menu_derma_menu:CloseMenu() end
    local mouseX, mouseY = input.GetCursorPos()
    local m = vgui.Create('MantleDermaMenu')
    m:SetPos(mouseX, mouseY)
    Mantle.func.ClampMenuPosition(m)
    m._targetX, m._targetY = m:GetPos()
    Mantle.ui.menu_derma_menu = m
    return m
end
