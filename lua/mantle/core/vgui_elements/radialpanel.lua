local PANEL = {}

local pi = math.pi
local math_cos = math.cos
local math_sin = math.sin
local math_atan2 = math.atan2
local math_sqrt = math.sqrt
local math_floor = math.floor
local math_min = math.min
local math_clamp = math.Clamp
local FrameTime = FrameTime
local SysTime = SysTime
local CurTime = CurTime

local EPS = 1e-6
local EPS_ANGLE = 1e-4

local function getSectorIndexFromAngle(angle, cnt)
    if !angle or cnt <= 0 then return nil end
    local sector = (2 * pi) / cnt
    local raw = angle / sector
    local idx = (math.floor(raw + EPS) % cnt) + 1
    return idx
end

local function clampEndAngle(a)
    if a >= 360 then
        return 360 - EPS_ANGLE
    end
    return a
end

function PANEL:Init()
    self.options = {}
    self.menuStack = {}
    self.hoverOption = nil
    self.hoverAnim = 0
    self.hoverAngle = nil
    self.hoverWidth = 0

    self._hotkeyCooldown = {}
    self._keyCooldown = 0
    self._mouseWasDown = false
    self._closing = false
    self._closeTime = nil
    self._matCache = {}

    self.optionHover = {}

    self.openTime = SysTime()
    self.currentAlpha = 0
    self.scaleAnim = 0.96

    self:ApplySettings(self.settings)

    self:SetSize(Mantle.func.sw, Mantle.func.sh)
    self:SetPos(0, 0)
    self:MakePopup()
    self:SetKeyboardInputEnabled(true)
    self:SetDrawOnTop(true)
    self:SetMouseInputEnabled(true)
end

function PANEL:ApplySettings(settings)
    settings = settings or {}

    self.rootMenu = { title = settings.title or 'Меню', desc = settings.desc or 'Выберите опцию', options = self.options }
    self.currentMenu = self.rootMenu

    local baseRadius = settings.radius or 320
    local baseInner = settings.inner_radius or 110

    local scale = 1
    if Mantle.func.sw > 1366 and Mantle.func.sh > 768 then
        scale = math_min(math_min(Mantle.func.sw / 1920, Mantle.func.sh / 1080), 1.15)
    end

    self.radius = Mantle.func.w(baseRadius) * scale
    self.innerRadius = Mantle.func.w(baseInner) * scale
    self.scale = scale

    self.titleFont = settings.title_font or 'Fated.28'
    self.font = settings.font or 'Fated.20'
    self.descFont = settings.desc_font or 'Fated.14'

    self.fadeInTime = settings.fade_in_time or 0.18
    self.fadeOutTime = settings.fade_out_time or 0.12
    self.scale_animation = settings.scale_animation != false

    self.disable_background = settings.disable_background or false
    self.hover_sound = settings.hover_sound or 'mantle/ratio_btn.ogg'
end

function PANEL:GetCenter()
    return Mantle.func.sw * 0.5, Mantle.func.sh * 0.5
end

function PANEL:GetIconMaterial(icon)
    if icon == nil or icon == false then return nil end
    local mat = self._matCache[icon]
    if !mat then
        mat = Material(icon)
        self._matCache[icon] = mat
    end
    if mat:IsError() then return nil end
    return mat
end

function PANEL:Think()
    local ft = FrameTime()

    if self._closing then
        local t = math_clamp((SysTime() - self._closeTime) / self.fadeOutTime, 0, 1)
        self.currentAlpha = math_floor(255 * (1 - t))
        if t >= 1 then
            self:Remove()
        end
        return
    end

    if self.currentAlpha < 255 then
        local t = math_clamp((SysTime() - self.openTime) / self.fadeInTime, 0, 1)
        self.currentAlpha = math_floor(255 * t)

        if self.scale_animation then
            self.scaleAnim = 0.96 + (1 - (1 - t) * (1 - t)) * 0.04
        else
            self.scaleAnim = 1
        end
    end

    if input.IsKeyDown(KEY_ESCAPE) and CurTime() - self._keyCooldown > 0.2 then
        self._keyCooldown = CurTime()
        self:CloseMenu()
        return
    end

    local cx, cy = self:GetCenter()
    local curOuter = self.radius * self.scaleAnim
    local curInner = self.innerRadius * self.scaleAnim

    local opts = self:GetCurrentOptions()
    local cnt = #opts

    local mouseDown = input.IsMouseDown(MOUSE_LEFT)
    if mouseDown and !self._mouseWasDown then
        local mx, my = self:CursorPos()
        local dx, dy = mx - cx, my - cy
        local dist = math_sqrt(dx * dx + dy * dy)

        if dist > curInner and dist < curOuter then
            local ang = math_atan2(dy, dx)
            if ang < 0 then ang = ang + 2 * pi end
            if cnt > 0 then
                local idx = getSectorIndexFromAngle(ang, cnt)
                if idx and opts[idx] then
                    self:SelectOption(idx)
                end
            end
        elseif dist <= curInner then
            if #self.menuStack > 0 then
                self:GoBack()
            else
                self:CloseMenu()
            end
        else
            self:CloseMenu()
        end
    end

    local mx, my = self:CursorPos()
    local dx, dy = mx - cx, my - cy
    local dist = math_sqrt(dx * dx + dy * dy)
    local hovered = nil
    if dist > curInner and dist < curOuter then
        local ang = math_atan2(dy, dx)
        if ang < 0 then ang = ang + 2 * pi end
        if cnt > 0 then
            hovered = getSectorIndexFromAngle(ang, cnt)
        end
    end

    if hovered and self.hoverOption != hovered and self.hover_sound then
        surface.PlaySound(self.hover_sound)
    end

    self.hoverOption = hovered
    self.hoverAnim = math_clamp(self.hoverAnim + (self.hoverOption and 10 or -20) * ft, 0, 1)
    self._mouseWasDown = mouseDown

    local sectorRad = cnt > 0 and (2 * pi) / cnt or 0

    local targetAngle = nil
    local targetWidth = 0
    if self.hoverOption and opts[self.hoverOption] and !opts[self.hoverOption].disabled then
        targetAngle = (self.hoverOption - 1) * sectorRad + sectorRad * 0.5
        targetWidth = sectorRad * 0.92
    end

    if targetAngle then
        local cur = self.hoverAngle or targetAngle
        local diff = ((targetAngle - cur) % (2 * pi) + 3 * pi) % (2 * pi) - pi
        self.hoverAngle = cur + diff * (1 - math.exp(-16 * ft))
        self.hoverWidth = Mantle.func.approachExp(self.hoverWidth or 0, targetWidth, 20, ft)
    else
        self.hoverAngle = nil
        self.hoverWidth = Mantle.func.approachExp(self.hoverWidth or 0, 0, 20, ft)
    end

    for i = 1, cnt do
        local target = (self.hoverOption == i and !opts[i].disabled) and 1 or 0
        self.optionHover[i] = Mantle.func.approachExp(self.optionHover[i] or 0, target, 18, ft)
    end

    for i = 1, math_min(9, cnt) do
        local k = KEY_1 + (i - 1)
        if input.IsKeyDown(k) then
            local last = self._hotkeyCooldown[k] or 0
            if CurTime() - last > 0.18 then
                self._hotkeyCooldown[k] = CurTime()
                self:SelectOption(i)
            end
        end
    end
end

function PANEL:OnMousePressed(k)
    local mx, my = self:CursorPos()
    local cx, cy = self:GetCenter()
    local curOuter = self.radius * self.scaleAnim
    local dist = math_sqrt((mx - cx) * (mx - cx) + (my - cy) * (my - cy))
    if dist <= curOuter then
        return self:MouseCapture(true)
    end
    self:CloseMenu()
    return true
end

function PANEL:OnMouseReleased(k)
    self:MouseCapture(false)
end

function PANEL:CreateSubMenu(title, desc)
    local submenu = { title = title or 'Подменю', desc = desc or '', options = {} }
    function submenu:AddOption(text, func, icon, desc, submenu)
        table.insert(self.options, { text = text, func = func, icon = icon, desc = desc, submenu = submenu })
        return #self.options
    end
    return submenu
end

function PANEL:AddSubMenuOption(text, submenu, icon, desc)
    return self:AddOption(text, nil, icon, desc, submenu)
end

function PANEL:AddOption(text, func, icon, desc, submenu, disabled)
    table.insert(self.options, {
        text = text,
        func = func,
        icon = icon,
        desc = desc,
        submenu = submenu,
        disabled = disabled
    })
    return #self.options
end

function PANEL:GetCurrentOptions()
    if self.currentMenu and self.currentMenu.options then
        return self.currentMenu.options
    end
    return self.options
end

function PANEL:SelectOption(index)
    if self._closing then return end

    local opts = self:GetCurrentOptions()
    if !opts or !opts[index] then return end
    local opt = opts[index]
    if opt.disabled then return end

    if opt.submenu then
        table.insert(self.menuStack, self.currentMenu)
        self.currentMenu = opt.submenu
        self:UpdateCenterText()
        if self.hover_sound then surface.PlaySound(self.hover_sound) end
        return
    end

    if opt.func then
        opt.func()
    end
    self:CloseMenu()
end

function PANEL:GoBack()
    if #self.menuStack > 0 then
        self.currentMenu = table.remove(self.menuStack)
        self.hoverOption = nil
        self:UpdateCenterText()
        if self.hover_sound then surface.PlaySound(self.hover_sound) end
    end
end

function PANEL:SetCenterText(title, desc)
    self.rootMenu.title = title or self.rootMenu.title
    self.rootMenu.desc = desc or self.rootMenu.desc
    self:UpdateCenterText()
end

function PANEL:UpdateCenterText()
    local menu = self.currentMenu or self.rootMenu
    self.centerText = menu.title or self.rootMenu.title
    self.centerDesc = menu.desc or self.rootMenu.desc
end

function PANEL:IsMouseOver()
    local mx, my = self:CursorPos()
    local cx, cy = self:GetCenter()
    local curOuter = self.radius * self.scaleAnim
    return math_sqrt((mx - cx) * (mx - cx) + (my - cy) * (my - cy)) <= curOuter
end

function PANEL:OnCursorMoved(x, y)
    if !self:IsMouseOver() then self.hoverOption = nil end
end

function PANEL:CloseMenu(callback)
    if self._closing then return end
    self._closing = true
    self._closeTime = SysTime()
    self._closeCb = callback
end

function PANEL:OnRemove()
    if self._closeCb then
        local cb = self._closeCb
        self._closeCb = nil
        cb()
    end

    if Mantle.ui.menu_radial == self then
        Mantle.ui.menu_radial = nil
    end
end

function PANEL:Paint(w, h)
    local cx, cy = self:GetCenter()
    local alpha = math_clamp(self.currentAlpha / 255, 0, 1)
    local opts = self:GetCurrentOptions()
    local cnt = #opts

    if !self.disable_background then
        local dim = Mantle.color.dim_overlay
        RNDX.Rect(0, 0, w, h)
            :Radii(0, 0, 0, 0)
            :Color(Color(dim.r, dim.g, dim.b, math_floor(dim.a * alpha)))
        :Draw()
    end

    local outerR = self.radius * self.scaleAnim
    local innerR = self.innerRadius * self.scaleAnim

    RNDX.Circle(cx, cy, outerR)
        :Color(Color(Mantle.color.background.r, Mantle.color.background.g, Mantle.color.background.b, math_floor(240 * alpha)))
    :Draw()

    RNDX.Circle(cx, cy, outerR)
        :Outline(2)
        :Color(Color(Mantle.color.theme.r, Mantle.color.theme.g, Mantle.color.theme.b, math_floor(160 * alpha)))
    :Draw()

    if cnt > 0 then
        local sectorDeg = 360 / cnt
        local baseCol = Mantle.color.background_panelpopup
        local baseSectorCol = Color(baseCol.r, baseCol.g, baseCol.b, math_floor(255 * alpha))
        local panelCol = Mantle.color.panel[1]

        for i = 1, cnt do
            local startDeg = (i - 1) * sectorDeg
            local endDeg = clampEndAngle(i * sectorDeg)
            if endDeg > startDeg then
                RNDX.Circle(cx, cy, outerR)
                    :Angles(startDeg, endDeg)
                    :Color(baseSectorCol)
                :Draw()

                RNDX.Circle(cx, cy, outerR)
                    :Angles(startDeg, endDeg)
                    :Outline(2)
                    :Color(Color(panelCol.r, panelCol.g, panelCol.b, math_floor(160 * alpha)))
                :Draw()
            end
        end

        local hoveredOpt = self.hoverOption and opts[self.hoverOption]
        if hoveredOpt and !hoveredOpt.disabled and self.hoverAngle and self.hoverWidth > 0.01 then
            local th = Mantle.color.theme
            local hoverAlpha = math_floor(200 * self.hoverAnim * alpha)
            local startDeg = (self.hoverAngle - self.hoverWidth * 0.5) * (180 / pi)
            local endDeg = (self.hoverAngle + self.hoverWidth * 0.5) * (180 / pi)

            RNDX.Circle(cx, cy, outerR)
                :Angles(startDeg, endDeg)
                :Color(Color(th.r, th.g, th.b, math_floor(26 * self.hoverAnim * alpha)))
            :Draw()

            RNDX.Circle(cx, cy, outerR)
                :Angles(startDeg, endDeg)
                :Outline(3)
                :Color(Color(th.r, th.g, th.b, hoverAlpha))
            :Draw()
        end

        RNDX.Circle(cx, cy, innerR)
            :Color(Color(Mantle.color.background_panelpopup.r, Mantle.color.background_panelpopup.g, Mantle.color.background_panelpopup.b, math_floor(255 * alpha)))
        :Draw()

        RNDX.Circle(cx, cy, innerR - 4)
            :Color(Color(Mantle.color.theme.r, Mantle.color.theme.g, Mantle.color.theme.b, math_floor(36 * alpha)))
        :Draw()

        RNDX.Circle(cx, cy, innerR)
            :Outline(2)
            :Color(Color(Mantle.color.theme.r, Mantle.color.theme.g, Mantle.color.theme.b, math_floor(80 * alpha)))
        :Draw()

        local sectorRad = (2 * pi) / cnt
        local textCol = Mantle.color.text
        local headerCol = Mantle.color.header_text

        for i, option in ipairs(opts) do
            local startA = (i - 1) * sectorRad
            local midA = startA + sectorRad * 0.5

            local hv = self.optionHover[i] or 0
            local eased = Mantle.func.easeOutCubic(math_clamp(hv, 0, 1))
            local isHovered = (self.hoverOption == i and !option.disabled)
            local iconScale = 1 + 0.06 * eased

            local labelR = innerR + (outerR - innerR) * (0.5 + 0.06 * eased)
            local numberR = innerR + (labelR - innerR) * 0.35
            local lx = cx + labelR * math_cos(midA)
            local ly = cy + labelR * math_sin(midA)
            local nx = cx + numberR * math_cos(midA)
            local ny = cy + numberR * math_sin(midA)

            local isDisabled = option.disabled
            local txtAlpha = math_floor((isHovered and 255 or (isDisabled and 120 or 220)) * alpha)
            local txtCol = Color(textCol.r, textCol.g, textCol.b, txtAlpha)

            local mat = self:GetIconMaterial(option.icon)
            if mat then
                local iconSize = Mantle.func.w(28) * self.scale * iconScale
                local iconX = lx - iconSize * 0.5
                local iconY = ly - iconSize * 0.5 - Mantle.func.h(6) * self.scale
                local ic = Mantle.color.icon
                surface.SetDrawColor(ic.r, ic.g, ic.b, math_floor(230 * alpha))
                surface.SetMaterial(mat)
                surface.DrawTexturedRect(iconX, iconY, iconSize, iconSize)

                draw.SimpleText(option.text or '', self.font, lx, ly + iconSize * 0.5 - Mantle.func.h(4) * self.scale, txtCol, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)

                if option.desc and isHovered then
                    draw.SimpleText(option.desc, self.descFont, lx, ly + iconSize * 0.5 + Mantle.func.h(16) * self.scale, Color(headerCol.r, headerCol.g, headerCol.b, math_floor(180 * alpha)), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
                end

                if i <= 9 and !isDisabled then
                    draw.SimpleText(tostring(i), 'Fated.14', nx, ny, Color(Mantle.color.theme.r, Mantle.color.theme.g, Mantle.color.theme.b, math_floor(200 * alpha)), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                end
            else
                draw.SimpleText(option.text or '', self.font, lx, ly - Mantle.func.h(4) * self.scale, txtCol, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

                if option.desc and isHovered then
                    draw.SimpleText(option.desc, self.descFont, lx, ly + Mantle.func.h(18) * self.scale, Color(headerCol.r, headerCol.g, headerCol.b, math_floor(180 * alpha)), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
                end

                if i <= 9 and !isDisabled then
                    draw.SimpleText(tostring(i), 'Fated.14', nx, ny, Color(Mantle.color.theme.r, Mantle.color.theme.g, Mantle.color.theme.b, math_floor(200 * alpha)), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                end
            end
        end
    else
        RNDX.Circle(cx, cy, outerR)
            :Color(Color(Mantle.color.background.r, Mantle.color.background.g, Mantle.color.background.b, math_floor(240 * alpha)))
        :Draw()
        RNDX.Circle(cx, cy, innerR)
            :Color(Color(Mantle.color.background_panelpopup.r, Mantle.color.background_panelpopup.g, Mantle.color.background_panelpopup.b, math_floor(255 * alpha)))
        :Draw()
    end

    draw.SimpleText(self.centerText or self.rootMenu.title, self.titleFont, cx, cy - Mantle.func.h(8) * self.scale, Color(Mantle.color.text.r, Mantle.color.text.g, Mantle.color.text.b, math_floor(255 * alpha)), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    draw.SimpleText(self.centerDesc or self.rootMenu.desc, self.descFont, cx, cy + Mantle.func.h(18) * self.scale, Color(Mantle.color.header_text.r, Mantle.color.header_text.g, Mantle.color.header_text.b, math_floor(160 * alpha)), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
end

vgui.Register('MantleRadialPanel', PANEL, 'Panel')

function Mantle.ui.radial_menu(options)
    if IsValid(Mantle.ui.menu_radial) then
        Mantle.ui.menu_radial:Remove()
    end

    local m = vgui.Create('MantleRadialPanel')
    m.settings = options or {}
    m:ApplySettings(m.settings)
    Mantle.ui.menu_radial = m
    return m
end
