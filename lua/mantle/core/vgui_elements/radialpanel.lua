local PANEL = {}

local pi = math.pi
local tau = pi * 2
local deg2rad = pi / 180

local math_abs = math.abs
local math_atan2 = math.atan2
local math_cos = math.cos
local math_floor = math.floor
local math_max = math.max
local math_min = math.min
local math_sqrt = math.sqrt
local math_rad = math.rad
local math_exp = math.exp
local math_clamp = math.Clamp

local FrameTime = FrameTime
local CurTime = CurTime
local SysTime = SysTime

local EPS = 1e-6
local EPS_ANGLE = 1e-4

local DEFAULT_SETTINGS = {
    title = 'Меню',
    desc = 'Выберите опцию',
    radius = 320,
    inner_radius = 110,
    title_font = 'Fated.28',
    font = 'Fated.20',
    desc_font = 'Fated.14',
    fade_in_time = 0.18,
    fade_out_time = 0.12,
    scale_animation = true,
    disable_background = false,
    hover_sound = 'mantle/ratio_btn.ogg'
}

local function getSectorIndexFromAngle(angle, count)
    if not angle or count <= 0 then return nil end

    local sector = tau / count
    local index = math_floor(angle / sector + EPS) % count + 1

    return index
end

local function shortestAngle(from, to)
    return (to - from + pi) % tau - pi
end

local function setColor(target, source, alpha)
    target.r = source.r
    target.g = source.g
    target.b = source.b
    target.a = math_floor((source.a or 255) * alpha + 0.5)

    return target
end

local function addSubmenuOption(submenu, text, func, icon, desc, childSubmenu, disabled)
    local options = submenu.options

    options[#options + 1] = {
        text = text,
        func = func,
        icon = icon,
        desc = desc,
        submenu = childSubmenu,
        disabled = disabled
    }

    return #options
end

local function createPaintColors()
    return {
        dim = Color(255, 255, 255, 0),
        outer = Color(255, 255, 255, 0),
        outerBorder = Color(255, 255, 255, 0),
        sector = Color(255, 255, 255, 0),
        hover = Color(255, 255, 255, 0),
        hoverBorder = Color(255, 255, 255, 0),
        inner = Color(255, 255, 255, 0),
        innerGlow = Color(255, 255, 255, 0),
        innerBorder = Color(255, 255, 255, 0),
        text = Color(255, 255, 255, 0),
        desc = Color(255, 255, 255, 0),
        icon = Color(255, 255, 255, 0),
        number = Color(255, 255, 255, 0)
    }
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
    self._closeCb = nil

    self._matCache = {}
    self._sectorData = {}
    self._sectorCount = -1
    self.optionHover = {}

    self._paint = createPaintColors()

    self.openTime = SysTime()
    self.currentAlpha = 0
    self.scaleAnim = 0.96

    self:SetSize(Mantle.func.sw, Mantle.func.sh)
    self:SetPos(0, 0)
    self:MakePopup()
    self:SetKeyboardInputEnabled(true)
    self:SetDrawOnTop(true)
    self:SetMouseInputEnabled(true)

    self:ApplySettings()
end

function PANEL:ApplySettings(settings)
    settings = settings or {}

    self.settings = settings

    self.rootMenu = {
        title = settings.title or DEFAULT_SETTINGS.title,
        desc = settings.desc or DEFAULT_SETTINGS.desc,
        options = self.options
    }

    self.currentMenu = self.rootMenu
    self.menuStack = {}

    local baseRadius = settings.radius or DEFAULT_SETTINGS.radius
    local baseInnerRadius = settings.inner_radius or DEFAULT_SETTINGS.inner_radius

    local scale = 1
    if Mantle.func.sw > 1366 and Mantle.func.sh > 768 then
        scale = math_min(
            math_min(Mantle.func.sw / 1920, Mantle.func.sh / 1080),
            1.15
        )
    end

    self.radius = Mantle.func.w(baseRadius) * scale
    self.innerRadius = Mantle.func.w(baseInnerRadius) * scale
    self.scale = scale

    self.titleFont = settings.title_font or DEFAULT_SETTINGS.title_font
    self.font = settings.font or DEFAULT_SETTINGS.font
    self.descFont = settings.desc_font or DEFAULT_SETTINGS.desc_font

    self.fadeInTime = math_max(0, settings.fade_in_time or DEFAULT_SETTINGS.fade_in_time)
    self.fadeOutTime = math_max(0, settings.fade_out_time or DEFAULT_SETTINGS.fade_out_time)

    self.scaleAnimation = settings.scale_animation != false
    self.disableBackground = settings.disable_background
    self.hoverSound = settings.hover_sound or DEFAULT_SETTINGS.hover_sound

    self._sectorCount = -1
    self._sectorData = {}
    self.optionHover = {}
    self.hoverOption = nil
    self.hoverAngle = nil
    self.hoverWidth = 0

    self:UpdateCenterText()
end

function PANEL:GetCenter()
    return self:GetWide() * 0.5, self:GetTall() * 0.5
end

function PANEL:GetIconMaterial(icon)
    if icon == nil or icon == false then return nil end

    local mat = self._matCache[icon]
    if mat then
        return mat:IsError() and nil or mat
    end

    mat = Material(icon)
    self._matCache[icon] = mat

    if mat:IsError() then
        return nil
    end

    return mat
end

function PANEL:_SyncScreenSize()
    local sw = Mantle.func.sw
    local sh = Mantle.func.sh

    if self:GetWide() != sw or self:GetTall() != sh then
        self:SetSize(sw, sh)
        self:SetPos(0, 0)
    end
end

function PANEL:_UpdateAppearance()
    if self._closing then
        local duration = self.fadeOutTime
        local t = duration <= 0 and 1 or math_clamp((SysTime() - self._closeTime) / duration, 0, 1)
        local eased = Mantle.func.easeOutCubic(t)

        self.currentAlpha = math_floor(255 * (1 - eased) + 0.5)

        if t >= 1 then
            self:Remove()
        end

        return true
    end

    if self.currentAlpha < 255 then
        local duration = self.fadeInTime
        local t = duration <= 0 and 1 or math_clamp((SysTime() - self.openTime) / duration, 0, 1)

        self.currentAlpha = math_floor(255 * t + 0.5)

        if self.scaleAnimation then
            local eased = Mantle.func.easeOutCubic(t)
            self.scaleAnim = 0.96 + eased * 0.04
        else
            self.scaleAnim = 1
        end
    else
        self.scaleAnim = 1
    end

    return false
end

function PANEL:_RebuildSectorData(count)
    if self._sectorCount == count then return end

    self._sectorCount = count
    self._sectorData = {}
    self.optionHover = {}

    if count <= 0 then
        self.hoverOption = nil
        self.hoverAngle = nil
        self.hoverWidth = 0
        return
    end

    local sectorRad = tau / count
    local sectorDeg = 360 / count
    local gapDeg = math_min(2.4, sectorDeg * 0.12)
    local halfGapDeg = gapDeg * 0.5

    for i = 1, count do
        local startDeg = (i - 1) * sectorDeg
        local endDeg = i * sectorDeg
        local midRad = (i - 0.5) * sectorRad

        local drawStart = startDeg + halfGapDeg
        local drawEnd = endDeg - halfGapDeg

        if drawStart < 360 - EPS_ANGLE and drawEnd > drawStart then
            self._sectorData[i] = {
                startDeg = drawStart,
                endDeg = drawEnd,
                midRad = midRad,
                cos = math_cos(midRad),
                sin = math_sin(midRad)
            }
        else
            self._sectorData[i] = {
                startDeg = 0,
                endDeg = 0,
                midRad = midRad,
                cos = math_cos(midRad),
                sin = math_sin(midRad)
            }
        end
    end
end

function PANEL:_GetPointerState()
    local cx, cy = self:GetCenter()
    local mx, my = self:CursorPos()

    local dx = mx - cx
    local dy = my - cy
    local distSqr = dx * dx + dy * dy

    local outer = self.radius * self.scaleAnim
    local inner = self.innerRadius * self.scaleAnim

    if distSqr > inner * inner and distSqr < outer * outer then
        local angle = math_atan2(dy, dx)

        if angle < 0 then
            angle = angle + tau
        end

        local options = self:GetCurrentOptions()
        local count = #options

        if count > 0 then
            return getSectorIndexFromAngle(angle, count), distSqr, angle, cx, cy
        end
    end

    return nil, distSqr, nil, cx, cy
end

function PANEL:_UpdateHover(ft)
    local options = self:GetCurrentOptions()
    local count = #options

    self:_RebuildSectorData(count)

    local hovered = self:_GetPointerState()
    local previous = self.hoverOption

    if hovered != previous and hovered then
        local option = options[hovered]
        if option and !option.disabled and self.hoverSound then
            surface.PlaySound(self.hoverSound)
        end
    end

    self.hoverOption = hovered

    local hoverTarget = hovered and 1 or 0
    self.hoverAnim = Mantle.func.approachExp(self.hoverAnim, hoverTarget, hovered and 14 or 20, ft)

    local sectorRad = count > 0 and tau / count or 0
    local hoveredOption = hovered and options[hovered] or nil

    if hovered and hoveredOption and !hoveredOption.disabled then
        local data = self._sectorData[hovered]
        local targetAngle = data and data.midRad or nil
        local targetWidth = sectorRad * 0.84

        if targetAngle then
            local currentAngle = self.hoverAngle or targetAngle
            local delta = shortestAngle(currentAngle, targetAngle)

            self.hoverAngle = currentAngle + delta * (1 - math_exp(-16 * ft))
            self.hoverWidth = Mantle.func.approachExp(self.hoverWidth, targetWidth, 20, ft)
        end
    else
        self.hoverAngle = nil
        self.hoverWidth = Mantle.func.approachExp(self.hoverWidth, 0, 20, ft)
    end

    for i = 1, count do
        local option = options[i]
        local target = (i == hovered and option and !option.disabled) and 1 or 0

        self.optionHover[i] = Mantle.func.approachExp(
            self.optionHover[i] or 0,
            target,
            18,
            ft
        )
    end

    for i = 1, math_min(9, count) do
        local key = KEY_1 + (i - 1)

        if input.IsKeyDown(key) then
            local now = CurTime()
            local last = self._hotkeyCooldown[key] or 0

            if now - last > 0.18 then
                self._hotkeyCooldown[key] = now
                self:SelectOption(i)
            end
        end
    end
end

function PANEL:Think()
    self:_SyncScreenSize()

    if self:_UpdateAppearance() then
        return
    end

    local now = CurTime()
    if input.IsKeyDown(KEY_ESCAPE) and now - self._keyCooldown > 0.2 then
        self._keyCooldown = now
        self:CloseMenu()
        return
    end

    local options = self:GetCurrentOptions()
    local count = #options

    self:_RebuildSectorData(count)

    local pointer, distSqr, _, cx, cy = self:_GetPointerState()

    local outer = self.radius * self.scaleAnim
    local inner = self.innerRadius * self.scaleAnim

    local mouseDown = input.IsMouseDown(MOUSE_LEFT)

    if mouseDown and !self._mouseWasDown then
        if pointer then
            self:SelectOption(pointer)
        elseif distSqr <= inner * inner then
            if #self.menuStack > 0 then
                self:GoBack()
            else
                self:CloseMenu()
            end
        elseif distSqr >= outer * outer then
            self:CloseMenu()
        end
    end

    self:_UpdateHover(FrameTime())

    self._mouseWasDown = mouseDown
end

function PANEL:OnMousePressed(k)
    local mx, my = self:CursorPos()
    local cx, cy = self:GetCenter()

    local outer = self.radius * self.scaleAnim
    local dx = mx - cx
    local dy = my - cy

    if dx * dx + dy * dy <= outer * outer then
        self:MouseCapture(true)
        return true
    end

    self:CloseMenu()
    return true
end

function PANEL:OnMouseReleased(k)
    self:MouseCapture(false)
end

function PANEL:CreateSubMenu(title, desc)
    local submenu = {
        title = title or 'Подменю',
        desc = desc or '',
        options = {}
    }

    submenu.AddOption = addSubmenuOption

    return submenu
end

function PANEL:AddSubMenuOption(text, submenu, icon, desc)
    return self:AddOption(text, nil, icon, desc, submenu)
end

function PANEL:AddOption(text, func, icon, desc, submenu, disabled)
    local options = self.options

    options[#options + 1] = {
        text = text,
        func = func,
        icon = icon,
        desc = desc,
        submenu = submenu,
        disabled = disabled
    }

    self:_RebuildSectorData(-1)

    return #options
end

function PANEL:GetCurrentOptions()
    if self.currentMenu and self.currentMenu.options then
        return self.currentMenu.options
    end

    return self.options
end

function PANEL:SelectOption(index)
    if self._closing then return end

    local options = self:GetCurrentOptions()
    if not options then return end

    local option = options[index]
    if not option or option.disabled then return end

    if option.submenu then
        self.menuStack[#self.menuStack + 1] = self.currentMenu
        self.currentMenu = option.submenu

        self.hoverOption = nil
        self.hoverAnim = 0
        self.hoverAngle = nil
        self.hoverWidth = 0

        self:UpdateCenterText()

        if self.hoverSound then
            surface.PlaySound(self.hoverSound)
        end

        return
    end

    if option.func then
        option.func()
    end

    self:CloseMenu()
end

function PANEL:GoBack()
    if #self.menuStack <= 0 then return end

    self.currentMenu = table.remove(self.menuStack)

    self.hoverOption = nil
    self.hoverAnim = 0
    self.hoverAngle = nil
    self.hoverWidth = 0

    self:UpdateCenterText()

    if self.hoverSound then
        surface.PlaySound(self.hoverSound)
    end
end

function PANEL:SetCenterText(title, desc)
    if not self.rootMenu then return end

    self.rootMenu.title = title or self.rootMenu.title
    self.rootMenu.desc = desc or self.rootMenu.desc

    self:UpdateCenterText()
end

function PANEL:UpdateCenterText()
    local root = self.rootMenu
    if not root then return end

    local menu = self.currentMenu or root

    self.centerText = menu.title or root.title
    self.centerDesc = menu.desc or root.desc
end

function PANEL:IsMouseOver()
    local mx, my = self:CursorPos()
    local cx, cy = self:GetCenter()

    local dx = mx - cx
    local dy = my - cy
    local outer = self.radius * self.scaleAnim

    return dx * dx + dy * dy <= outer * outer
end

function PANEL:OnCursorMoved(x, y)
    if !self:IsMouseOver() then
        self.hoverOption = nil
    end
end

function PANEL:CloseMenu(callback)
    if self._closing then return end

    self._closing = true
    self._closeTime = SysTime()
    self._closeCb = callback
end

function PANEL:OnRemove()
    if self._closeCb then
        local callback = self._closeCb
        self._closeCb = nil

        if isfunction(callback) then
            callback()
        end
    end

    if Mantle.ui.menu_radial == self then
        Mantle.ui.menu_radial = nil
    end
end

function PANEL:_DrawSector(cx, cy, radius, data, color)
    if data.startDeg >= data.endDeg then return end

    RNDX.Circle(cx, cy, radius)
        :Angles(data.startDeg, data.endDeg)
        :Color(color)
    :Draw()
end

function PANEL:_DrawText(text, font, x, y, color, alignX, alignY)
    draw.SimpleText(text or '', font, x, y, color, alignX, alignY)
end

function PANEL:_DrawOptions(cx, cy, innerRadius, outerRadius, alpha, options)
    local count = #options
    if count <= 0 then return end

    local textColor = Mantle.color.text
    local headerColor = Mantle.color.header_text

    local ring = outerRadius - innerRadius

    for i, option in ipairs(options) do
        local data = self._sectorData[i]
        if not data then continue end

        local hover = math_clamp(self.optionHover[i] or 0, 0, 1)
        local eased = Mantle.func.easeOutCubic(hover)

        local labelRadius = innerRadius + ring * (0.50 + 0.06 * eased)
        local numberRadius = innerRadius + (labelRadius - innerRadius) * 0.35

        local lx = cx + labelRadius * data.cos
        local ly = cy + labelRadius * data.sin
        local nx = cx + numberRadius * data.cos
        local ny = cy + numberRadius * data.sin

        local hovered = self.hoverOption == i and !option.disabled
        local disabled = option.disabled

        local textAlpha = (hovered and 255) or (disabled and 110 or 215)
        local optionTextColor = setColor(self._paint.text, textColor, alpha * textAlpha / 255)

        local material = self:GetIconMaterial(option.icon)

        if material then
            local iconScale = 1 + 0.06 * eased
            local iconSize = Mantle.func.w(28) * self.scale * iconScale
            local iconX = lx - iconSize * 0.5
            local iconY = ly - iconSize * 0.5 - Mantle.func.h(6) * self.scale

            local iconColor = setColor(
                self._paint.icon,
                Mantle.color.icon,
                alpha * (disabled and 0.65 or 0.9)
            )

            RNDX.Rect(iconX, iconY, iconSize, iconSize)
                :Rad(6)
                :Material(material)
                :Color(iconColor)
            :Draw()

            self:_DrawText(
                option.text,
                self.font,
                lx,
                ly + iconSize * 0.5 - Mantle.func.h(4) * self.scale,
                optionTextColor,
                TEXT_ALIGN_CENTER,
                TEXT_ALIGN_TOP
            )

            if option.desc and hovered then
                local descColor = setColor(self._paint.desc, headerColor, alpha * 0.72)

                self:_DrawText(
                    option.desc,
                    self.descFont,
                    lx,
                    ly + iconSize * 0.5 + Mantle.func.h(16) * self.scale,
                    descColor,
                    TEXT_ALIGN_CENTER,
                    TEXT_ALIGN_TOP
                )
            end
        else
            self:_DrawText(
                option.text,
                self.font,
                lx,
                ly,
                optionTextColor,
                TEXT_ALIGN_CENTER,
                TEXT_ALIGN_CENTER
            )

            if option.desc and hovered then
                local descColor = setColor(self._paint.desc, headerColor, alpha * 0.72)

                self:_DrawText(
                    option.desc,
                    self.descFont,
                    lx,
                    ly + Mantle.func.h(18) * self.scale,
                    descColor,
                    TEXT_ALIGN_CENTER,
                    TEXT_ALIGN_TOP
                )
            end
        end

        if i <= 9 and !disabled then
            local numberColor = setColor(
                self._paint.number,
                Mantle.color.theme,
                alpha * 0.78
            )

            self:_DrawText(
                tostring(i),
                'Fated.14',
                nx,
                ny,
                numberColor,
                TEXT_ALIGN_CENTER,
                TEXT_ALIGN_CENTER
            )
        end
    end
end

function PANEL:Paint(w, h)
    local alpha = math_clamp(self.currentAlpha / 255, 0, 1)

    if alpha <= 0 then return end

    local cx, cy = self:GetCenter()
    local outerRadius = self.radius * self.scaleAnim
    local innerRadius = self.innerRadius * self.scaleAnim

    local options = self:GetCurrentOptions()
    local count = #options

    local paint = self._paint

    if !self.disableBackground then
        RNDX.Rect(0, 0, w, h)
            :Color(setColor(paint.dim, Mantle.color.dim_overlay, alpha))
        :Draw()
    end

    RNDX.Circle(cx, cy, outerRadius)
        :Color(setColor(paint.outer, Mantle.color.background, alpha * 0.94))
    :Draw()

    if count > 0 then
        local sectorColor = setColor(
            paint.sector,
            Mantle.color.background_panelpopup,
            alpha
        )

        for i = 1, count do
            local data = self._sectorData[i]
            if data then
                self:_DrawSector(cx, cy, outerRadius, data, sectorColor)
            end
        end
    end

    RNDX.Circle(cx, cy, outerRadius)
        :Outline(1)
        :Color(setColor(paint.outerBorder, Mantle.color.theme, alpha * 0.34))
    :Draw()

    if count > 0 and self.hoverAngle and self.hoverWidth > 0.01 and self.hoverOption then
        local option = options[self.hoverOption]

        if option and !option.disabled then
            local hoverAlpha = alpha * self.hoverAnim
            local halfWidth = self.hoverWidth * 0.5

            local startDeg = (self.hoverAngle - halfWidth) / deg2rad
            local endDeg = (self.hoverAngle + halfWidth) / deg2rad

            local hoverFill = setColor(
                paint.hover,
                Mantle.color.theme,
                0.12 * hoverAlpha
            )

            local hoverBorder = setColor(
                paint.hoverBorder,
                Mantle.color.theme,
                0.82 * hoverAlpha
            )

            RNDX.Circle(cx, cy, outerRadius)
                :Angles(startDeg, endDeg)
                :Color(hoverFill)
            :Draw()

            RNDX.Circle(cx, cy, outerRadius)
                :Angles(startDeg, endDeg)
                :Outline(2)
                :Color(hoverBorder)
            :Draw()
        end
    end

    RNDX.Circle(cx, cy, innerRadius)
        :Color(setColor(paint.inner, Mantle.color.background_panelpopup, alpha))
    :Draw()

    local innerGlowRadius = math_max(0, innerRadius - Mantle.func.w(8) * self.scale)
    if innerGlowRadius > 0 then
        RNDX.Circle(cx, cy, innerGlowRadius)
            :Color(setColor(paint.innerGlow, Mantle.color.theme, alpha * 0.05))
        :Draw()
    end

    RNDX.Circle(cx, cy, innerRadius)
        :Outline(1)
        :Color(setColor(paint.innerBorder, Mantle.color.theme, alpha * 0.4))
    :Draw()

    self:_DrawOptions(cx, cy, innerRadius, outerRadius, alpha, options)

    self:_DrawText(
        self.centerText or self.rootMenu.title,
        self.titleFont,
        cx,
        cy - Mantle.func.h(8) * self.scale,
        setColor(paint.text, Mantle.color.text, alpha),
        TEXT_ALIGN_CENTER,
        TEXT_ALIGN_CENTER
    )

    self:_DrawText(
        self.centerDesc or self.rootMenu.desc,
        self.descFont,
        cx,
        cy + Mantle.func.h(18) * self.scale,
        setColor(paint.desc, Mantle.color.header_text, alpha * 0.68),
        TEXT_ALIGN_CENTER,
        TEXT_ALIGN_CENTER
    )
end

vgui.Register('MantleRadialPanel', PANEL, 'Panel')

function Mantle.ui.radial_menu(options)
    if IsValid(Mantle.ui.menu_radial) then
        Mantle.ui.menu_radial:Remove()
    end

    local menu = vgui.Create('MantleRadialPanel')
    menu.settings = options or {}
    menu:ApplySettings(menu.settings)

    Mantle.ui.menu_radial = menu

    return menu
end
