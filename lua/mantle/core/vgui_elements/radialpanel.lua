local PANEL = {}

local pi = math.pi
local tau = pi * 2
local deg2rad = pi / 180

local math_abs = math.abs
local math_atan2 = math.atan2
local math_cos = math.cos
local math_sin = math.sin
local math_floor = math.floor
local math_max = math.max
local math_min = math.min
local math_clamp = math.Clamp
local math_exp = math.exp
local math_deg = math.deg

local FrameTime = FrameTime
local SysTime = SysTime
local CurTime = CurTime

local EPS = 1e-6
local BORDER_WIDTH = 3
local SEGMENT_GAP = 3

local function getSectorIndexFromAngle(angle, cnt)
    if !angle or cnt <= 0 then return nil end

    local sector = tau / cnt
    local idx = (math_floor(angle / sector + EPS) % cnt) + 1

    return idx
end

local function shortestAngle(from, to, direction)
    local diff = (to - from + pi) % tau - pi

    if math_abs(math_abs(diff) - pi) < 0.0001 and direction and direction != 0 then
        return direction > 0 and pi or -pi
    end

    return diff
end

local function setColor(target, source, alpha)
    target.r = source.r
    target.g = source.g
    target.b = source.b
    target.a = math_floor((source.a or 255) * alpha + 0.5)

    return target
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
        center = Color(255, 255, 255, 0),
        centerHover = Color(255, 255, 255, 0),
        centerBorder = Color(255, 255, 255, 0),
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
    self.centerHover = 0
    self.pointerRegion = 'outside'

    self._hoverVisualActive = false
    self._hoverTargetAngle = nil
    self._hoverTargetWidth = 0
    self._hoverTargetAlpha = 0
    self._hoverDirection = 0

    self._lastPointerAngle = nil
    self._pointerDirection = 0
    self._previousPointerRegion = 'outside'
    self._lastHoverSoundOption = nil

    self._hotkeyCooldown = {}
    self._keyCooldown = 0
    self._mouseWasDown = false
    self._closing = false
    self._closeTime = nil
    self._closeCb = nil
    self._matCache = {}

    self._sectorData = {}
    self._sectorCount = -1
    self._sectorRadius = -1
    self._sectorHalfGapRad = 0

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
    self:SetCursor('arrow')
end

function PANEL:ApplySettings(settings)
    settings = settings or {}

    self.rootMenu = {
        title = settings.title or 'Меню',
        desc = settings.desc or 'Выберите опцию',
        options = self.options
    }
    self.currentMenu = self.rootMenu
    self.menuStack = {}

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

    self.fadeInTime = math_max(0, settings.fade_in_time or 0.18)
    self.fadeOutTime = math_max(0, settings.fade_out_time or 0.12)
    self.scaleAnimation = settings.scale_animation != false

    self.disableBackground = settings.disable_background
    self.hoverSound = settings.hover_sound or 'mantle/ratio_btn.ogg'

    self._sectorCount = -1
    self._sectorRadius = -1
    self._sectorData = {}
    self._sectorHalfGapRad = 0
    self.optionHover = {}

    self.hoverOption = nil
    self.hoverAnim = 0
    self.hoverAngle = nil
    self.hoverWidth = 0
    self.centerHover = 0

    self._hoverVisualActive = false
    self._hoverTargetAngle = nil
    self._hoverTargetWidth = 0
    self._hoverTargetAlpha = 0
    self._hoverDirection = 0

    self._lastPointerAngle = nil
    self._pointerDirection = 0
    self._previousPointerRegion = 'outside'
    self._lastHoverSoundOption = nil

    self.pointerRegion = 'outside'

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

    if mat:IsError() then return nil end

    return mat
end

function PANEL:Think()
    if self:GetWide() != Mantle.func.sw or self:GetTall() != Mantle.func.sh then
        self:SetSize(Mantle.func.sw, Mantle.func.sh)
        self:SetPos(0, 0)
    end

    if self._closing then
        local t = self.fadeOutTime <= 0 and 1 or math_clamp((SysTime() - self._closeTime) / self.fadeOutTime, 0, 1)
        local eased = Mantle.func.easeOutCubic(t)

        self.currentAlpha = math_floor(255 * (1 - eased) + 0.5)

        if t >= 1 then
            self:Remove()
        end

        return
    end

    if self.currentAlpha < 255 then
        local t = self.fadeInTime <= 0 and 1 or math_clamp((SysTime() - self.openTime) / self.fadeInTime, 0, 1)
        self.currentAlpha = math_floor(255 * t + 0.5)

        if self.scaleAnimation then
            self.scaleAnim = 0.96 + Mantle.func.easeOutCubic(t) * 0.04
        else
            self.scaleAnim = 1
        end
    else
        self.scaleAnim = 1
    end

    local now = CurTime()

    if input.IsKeyDown(KEY_ESCAPE) and now - self._keyCooldown > 0.2 then
        self._keyCooldown = now
        self:CloseMenu()
        return
    end

    local opts = self:GetCurrentOptions()
    local cnt = #opts

    self:_buildSectorData(cnt)

    local hovered, region, _, pointerAngle = self:_getPointerState()

    if pointerAngle and (region == 'segment' or region == 'gap') then
        if self._lastPointerAngle then
            local movement = shortestAngle(
                self._lastPointerAngle,
                pointerAngle,
                self._pointerDirection
            )

            if math_abs(movement) > 0.0005 then
                self._pointerDirection = movement > 0 and 1 or -1
            end
        end

        self._lastPointerAngle = pointerAngle
    elseif region == 'outside' then
        self._lastPointerAngle = nil
    end

    self.pointerRegion = region

    if region == 'center' then
        self:SetCursor('hand')
    elseif region == 'segment' then
        local option = opts[hovered]

        if option and !option.disabled then
            self:SetCursor('hand')
        else
            self:SetCursor('arrow')
        end
    else
        self:SetCursor('arrow')
    end

    local mouseDown = input.IsMouseDown(MOUSE_LEFT)

    if mouseDown and !self._mouseWasDown then
        if region == 'segment' and hovered then
            self:SelectOption(hovered)
        elseif region == 'center' then
            if #self.menuStack > 0 then
                self:GoBack()
            else
                self:CloseMenu()
            end
        elseif region == 'outside' then
            self:CloseMenu()
        end
    end

    self:_updateHover(FrameTime(), region, hovered, pointerAngle)
    self:_handleHotkeys()

    self._previousPointerRegion = region
    self._mouseWasDown = mouseDown
end

function PANEL:_buildSectorData(cnt)
    local radius = self.radius

    if self._sectorCount == cnt and self._sectorRadius == radius then return end

    self._sectorCount = cnt
    self._sectorRadius = radius
    self._sectorData = {}
    self.optionHover = {}

    self._sectorHalfGapRad = 0

    if cnt <= 0 then
        self.hoverOption = nil
        self.hoverAngle = nil
        self.hoverWidth = 0
        self._hoverVisualActive = false
        return
    end

    local sectorRad = tau / cnt
    local gapRad = SEGMENT_GAP / math_max(radius, 1)

    gapRad = math_min(gapRad, sectorRad * 0.2)

    local halfGapRad = gapRad * 0.5

    self._sectorHalfGapRad = halfGapRad

    for i = 1, cnt do
        local startRad = (i - 1) * sectorRad + halfGapRad
        local endRad = i * sectorRad - halfGapRad
        local midRad = (i - 0.5) * sectorRad

        self._sectorData[i] = {
            startDeg = math_deg(startRad),
            endDeg = math_deg(endRad),
            midRad = midRad,
            widthRad = endRad - startRad,
            cos = math_cos(midRad),
            sin = math_sin(midRad)
        }
    end
end

function PANEL:_getPointerState()
    local cx, cy = self:GetCenter()
    local mx, my = self:CursorPos()

    local dx = mx - cx
    local dy = my - cy
    local distSqr = dx * dx + dy * dy

    local angle = nil

    if distSqr > EPS then
        angle = math_atan2(dy, dx)

        if angle < 0 then
            angle = angle + tau
        end
    end

    local outer = self.radius * self.scaleAnim
    local inner = self.innerRadius * self.scaleAnim

    if distSqr <= inner * inner then
        return nil, 'center', distSqr, angle
    end

    if distSqr >= outer * outer then
        return nil, 'outside', distSqr, angle
    end

    local opts = self:GetCurrentOptions()
    local cnt = #opts

    if cnt <= 0 then
        return nil, 'center', distSqr, angle
    end

    local sectorRad = tau / cnt
    local angleInSector = angle % sectorRad

    if angleInSector < self._sectorHalfGapRad
        or angleInSector > sectorRad - self._sectorHalfGapRad then
        return nil, 'gap', distSqr, angle
    end

    local idx = getSectorIndexFromAngle(angle, cnt)

    return idx, 'segment', distSqr, angle
end

function PANEL:_updateHover(ft, region, hovered, pointerAngle)
    local opts = self:GetCurrentOptions()
    local cnt = #opts
    local fromCenter = self._previousPointerRegion == 'center'

    if region == 'segment' and hovered then
        local option = opts[hovered]

        if option and !option.disabled then
            if self._lastHoverSoundOption != hovered and self.hoverSound then
                surface.PlaySound(self.hoverSound)
            end

            self._lastHoverSoundOption = hovered
            self.hoverOption = hovered

            local data = self._sectorData[hovered]

            if data then
                if fromCenter or !self._hoverVisualActive then
                    self._hoverVisualActive = true
                    self.hoverAngle = data.midRad
                    self.hoverWidth = 0
                    self.hoverAnim = 0
                    self._hoverDirection = self._pointerDirection

                    if fromCenter then
                        self.centerHover = 1
                    end
                end

                self._hoverTargetAngle = data.midRad
                self._hoverTargetWidth = data.widthRad
                self._hoverTargetAlpha = 1

                local currentAngle = self.hoverAngle or data.midRad
                local direction = 0

                if pointerAngle then
                    local pointerDiff = shortestAngle(currentAngle, pointerAngle)

                    if math_abs(math_abs(pointerDiff) - pi) > 0.001 then
                        direction = pointerDiff > 0 and 1 or -1
                    end
                end

                if direction == 0 then
                    direction = self._pointerDirection
                end

                if direction != 0 then
                    self._hoverDirection = direction
                end
            end
        else
            self.hoverOption = nil
            self._hoverTargetAlpha = 0
            self._hoverTargetWidth = 0
        end
    elseif region == 'center' then
        self.hoverOption = nil

        if self._hoverVisualActive then
            self._hoverTargetAlpha = 1
        end
    else
        self.hoverOption = nil
        self._hoverTargetAlpha = 0
        self._hoverTargetWidth = 0

        if region == 'outside' then
            self._lastHoverSoundOption = nil
        end
    end

    self.hoverAnim = Mantle.func.approachExp(
        self.hoverAnim,
        self._hoverTargetAlpha,
        self._hoverTargetAlpha > 0 and 14 or 18,
        ft
    )

    if self._hoverVisualActive then
        if self._hoverTargetAngle then
            local currentAngle = self.hoverAngle or self._hoverTargetAngle

            local diff = shortestAngle(
                currentAngle,
                self._hoverTargetAngle,
                self._hoverDirection or self._pointerDirection
            )

            self.hoverAngle = currentAngle + diff * (1 - math_exp(-16 * ft))
        end

        self.hoverWidth = Mantle.func.approachExp(
            self.hoverWidth,
            self._hoverTargetWidth,
            20,
            ft
        )

        if self._hoverTargetAlpha <= 0
            and self.hoverAnim <= 0.005
            and self.hoverWidth <= 0.01 then

            self._hoverVisualActive = false
            self.hoverAngle = nil
            self.hoverWidth = 0
            self._hoverTargetAngle = nil
            self._hoverTargetWidth = 0
            self._hoverDirection = 0
        end
    end

    self.centerHover = Mantle.func.approachExp(
        self.centerHover,
        region == 'center' and 1 or 0,
        region == 'center' and 16 or 18,
        ft
    )

    if region == 'center' and self.centerHover >= 0.995 then
        self._hoverVisualActive = false
        self.hoverAngle = nil
        self.hoverWidth = 0
        self.hoverAnim = 0

        self._hoverTargetAngle = nil
        self._hoverTargetWidth = 0
        self._hoverTargetAlpha = 0
        self._hoverDirection = 0
    end

    for i = 1, cnt do
        local option = opts[i]
        local target = (i == self.hoverOption and option and !option.disabled) and 1 or 0

        self.optionHover[i] = Mantle.func.approachExp(
            self.optionHover[i] or 0,
            target,
            18,
            ft
        )
    end
end

function PANEL:_handleHotkeys()
    local opts = self:GetCurrentOptions()
    local cnt = #opts

    for i = 1, math_min(9, cnt) do
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

function PANEL:OnMousePressed(k)
    local mx, my = self:CursorPos()
    local cx, cy = self:GetCenter()

    local outer = self.radius * self.scaleAnim
    local dx = mx - cx
    local dy = my - cy

    if dx * dx + dy * dy <= outer * outer then
        return self:MouseCapture(true)
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

    function submenu:AddOption(text, func, icon, desc, submenu)
        table.insert(self.options, {
            text = text,
            func = func,
            icon = icon,
            desc = desc,
            submenu = submenu
        })

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

    self:_buildSectorData(-1)

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
        self.hoverOption = nil
        self.hoverAnim = 0
        self.hoverAngle = nil
        self.hoverWidth = 0
        self.centerHover = 0

        self._hoverVisualActive = false
        self._hoverTargetAngle = nil
        self._hoverTargetWidth = 0
        self._hoverTargetAlpha = 0
        self._hoverDirection = 0

        self._lastPointerAngle = nil
        self._pointerDirection = 0
        self._previousPointerRegion = 'outside'
        self._lastHoverSoundOption = nil

        self:UpdateCenterText()

        if self.hoverSound then
            surface.PlaySound(self.hoverSound)
        end

        return
    end

    if opt.func then
        opt.func()
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
    self.centerHover = 0

    self._hoverVisualActive = false
    self._hoverTargetAngle = nil
    self._hoverTargetWidth = 0
    self._hoverTargetAlpha = 0
    self._hoverDirection = 0

    self._lastPointerAngle = nil
    self._pointerDirection = 0
    self._previousPointerRegion = 'outside'
    self._lastHoverSoundOption = nil

    self:UpdateCenterText()

    if self.hoverSound then
        surface.PlaySound(self.hoverSound)
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

    local dx = mx - cx
    local dy = my - cy
    local outer = self.radius * self.scaleAnim

    return dx * dx + dy * dy <= outer * outer
end

function PANEL:OnCursorMoved(x, y)
    if !self:IsMouseOver() then
        self.pointerRegion = 'outside'
        self:SetCursor('arrow')
    end
end

function PANEL:CloseMenu(callback)
    if self._closing then return end

    self._closing = true
    self._closeTime = SysTime()
    self._closeCb = callback

    self:SetCursor('arrow')
end

function PANEL:OnRemove()
    if self._closeCb then
        local cb = self._closeCb
        self._closeCb = nil

        if isfunction(cb) then
            cb()
        end
    end

    if Mantle.ui.menu_radial == self then
        Mantle.ui.menu_radial = nil
    end
end

function PANEL:_drawSector(cx, cy, radius, data, color)
    if !data or data.startDeg >= data.endDeg then return end

    RNDX.Circle(cx, cy, radius)
        :Angles(data.startDeg, data.endDeg)
        :Color(color)
    :Draw()
end

function PANEL:_drawText(text, font, x, y, color, alignX, alignY)
    draw.SimpleText(
        text or '',
        font,
        x,
        y,
        color,
        alignX,
        alignY
    )
end

function PANEL:_drawHover(cx, cy, innerRadius, outerRadius, alpha)
    if !self._hoverVisualActive or !self.hoverAngle or self.hoverWidth <= 0.01 then
        return
    end

    local centerProgress = math_clamp(self.centerHover, 0, 1)
    local radiusProgress = Mantle.func.easeInOutCubic(centerProgress)
    local radius = outerRadius + (innerRadius - outerRadius) * radiusProgress
    local centerFade = 1 - radiusProgress
    local strength = self.hoverAnim * centerFade

    if strength <= 0.001 then return end

    local halfWidth = self.hoverWidth * 0.5
    local startDeg = (self.hoverAngle - halfWidth) / deg2rad
    local endDeg = (self.hoverAngle + halfWidth) / deg2rad

    local fillColor = setColor(
        self._paint.hover,
        Mantle.color.theme,
        alpha * 0.12 * strength
    )

    local borderColor = setColor(
        self._paint.hoverBorder,
        Mantle.color.theme,
        alpha * 0.86 * strength
    )

    RNDX.Circle(cx, cy, radius)
        :Angles(startDeg, endDeg)
        :Color(fillColor)
    :Draw()

    RNDX.Circle(cx, cy, radius)
        :Angles(startDeg, endDeg)
        :Outline(2)
        :Color(borderColor)
    :Draw()
end

function PANEL:_drawCenterButton(cx, cy, innerRadius, alpha)
    if #self.menuStack <= 0 then return end

    local hover = Mantle.func.easeOutCubic(
        math_clamp(self.centerHover, 0, 1)
    )

    local width = Mantle.func.w(84) * self.scale
    local height = Mantle.func.h(30) * self.scale

    local x = cx - width * 0.5
    local y = cy + innerRadius * 0.24

    local maxY = cy + innerRadius - height - Mantle.func.h(8) * self.scale
    local minY = cy - innerRadius + Mantle.func.h(8) * self.scale

    y = math_max(minY, math_min(y, maxY))

    local baseColor = setColor(
        self._paint.center,
        Mantle.color.focus_panel,
        alpha
    )

    local hoverColor = setColor(
        self._paint.centerHover,
        Mantle.color.theme,
        alpha * (0.08 + hover * 0.18)
    )

    local borderColor = setColor(
        self._paint.centerBorder,
        Mantle.color.theme,
        alpha * (0.35 + hover * 0.4)
    )

    RNDX.Rect(x, y, width, height)
        :Rad(height * 0.5)
        :Color(baseColor)
    :Draw()

    if hover > 0.01 then
        RNDX.Rect(x, y, width, height)
            :Rad(height * 0.5)
            :Color(hoverColor)
        :Draw()
    end

    RNDX.Rect(x, y, width, height)
        :Rad(height * 0.5)
        :Outline(2)
        :Color(borderColor)
    :Draw()

    local textColor = setColor(
        self._paint.text,
        Mantle.color.text,
        alpha
    )

    local arrowX = x + Mantle.func.w(15) * self.scale
    local arrowSize = Mantle.func.w(6) * self.scale
    local arrowY = y + height * 0.5

    surface.SetDrawColor(
        textColor.r,
        textColor.g,
        textColor.b,
        textColor.a
    )

    surface.DrawLine(
        arrowX + arrowSize,
        arrowY - arrowSize,
        arrowX,
        arrowY
    )

    surface.DrawLine(
        arrowX,
        arrowY,
        arrowX + arrowSize,
        arrowY + arrowSize
    )

    self:_drawText(
        'Назад',
        'Fated.14',
        x + width * 0.5 + Mantle.func.w(6) * self.scale,
        arrowY,
        textColor,
        TEXT_ALIGN_CENTER,
        TEXT_ALIGN_CENTER
    )
end

function PANEL:_drawOptions(cx, cy, innerRadius, outerRadius, alpha, opts)
    local cnt = #opts
    if cnt <= 0 then return end

    local textCol = Mantle.color.text
    local headerCol = Mantle.color.header_text
    local ring = outerRadius - innerRadius

    for i, option in ipairs(opts) do
        local data = self._sectorData[i]

        if data then
            local hv = math_clamp(self.optionHover[i] or 0, 0, 1)
            local eased = Mantle.func.easeOutCubic(hv)

            local labelR = innerRadius + ring * (0.5 + 0.06 * eased)
            local numberR = innerRadius + (labelR - innerRadius) * 0.35

            local lx = cx + labelR * data.cos
            local ly = cy + labelR * data.sin

            local nx = cx + numberR * data.cos
            local ny = cy + numberR * data.sin

            local isHovered = self.hoverOption == i and !option.disabled
            local isDisabled = option.disabled

            local txtAlpha = math_floor(
                (isHovered and 255 or (isDisabled and 110 or 220)) * alpha
            )

            local txtCol = setColor(
                self._paint.text,
                textCol,
                txtAlpha / 255
            )

            local mat = self:GetIconMaterial(option.icon)

            if mat then
                local iconScale = 1 + 0.06 * eased
                local iconSize = Mantle.func.w(28) * self.scale * iconScale

                local iconX = lx - iconSize * 0.5
                local iconY = ly - iconSize * 0.5 - Mantle.func.h(6) * self.scale

                local iconCol = setColor(
                    self._paint.icon,
                    Mantle.color.icon,
                    alpha * (isDisabled and 0.58 or 0.9)
                )

                RNDX.Rect(iconX, iconY, iconSize, iconSize)
                    :Rad(6)
                    :Material(mat)
                    :Color(iconCol)
                :Draw()

                self:_drawText(
                    option.text,
                    self.font,
                    lx,
                    ly + iconSize * 0.5 - Mantle.func.h(4) * self.scale,
                    txtCol,
                    TEXT_ALIGN_CENTER,
                    TEXT_ALIGN_TOP
                )

                if option.desc and isHovered then
                    self:_drawText(
                        option.desc,
                        self.descFont,
                        lx,
                        ly + iconSize * 0.5 + Mantle.func.h(16) * self.scale,
                        setColor(self._paint.desc, headerCol, alpha * 0.72),
                        TEXT_ALIGN_CENTER,
                        TEXT_ALIGN_TOP
                    )
                end
            else
                self:_drawText(
                    option.text,
                    self.font,
                    lx,
                    ly,
                    txtCol,
                    TEXT_ALIGN_CENTER,
                    TEXT_ALIGN_CENTER
                )

                if option.desc and isHovered then
                    self:_drawText(
                        option.desc,
                        self.descFont,
                        lx,
                        ly + Mantle.func.h(18) * self.scale,
                        setColor(self._paint.desc, headerCol, alpha * 0.72),
                        TEXT_ALIGN_CENTER,
                        TEXT_ALIGN_TOP
                    )
                end
            end

            if i <= 9 and !isDisabled then
                self:_drawText(
                    tostring(i),
                    'Fated.14',
                    nx,
                    ny,
                    setColor(self._paint.number, Mantle.color.theme, alpha * 0.78),
                    TEXT_ALIGN_CENTER,
                    TEXT_ALIGN_CENTER
                )
            end
        end
    end
end

function PANEL:Paint(w, h)
    local alpha = math_clamp(self.currentAlpha / 255, 0, 1)

    if alpha <= 0 then return end

    local cx, cy = self:GetCenter()

    local outerR = self.radius * self.scaleAnim
    local innerR = self.innerRadius * self.scaleAnim

    local opts = self:GetCurrentOptions()
    local cnt = #opts

    if !self.disableBackground then
        RNDX.Rect(0, 0, w, h)
            :Color(setColor(self._paint.dim, Mantle.color.dim_overlay, alpha))
        :Draw()
    end

    RNDX.Circle(cx, cy, outerR)
        :Color(setColor(self._paint.outer, Mantle.color.background, alpha * 0.94))
    :Draw()

    if cnt > 0 then
        local sectorColor = setColor(
            self._paint.sector,
            Mantle.color.background_panelpopup,
            alpha
        )

        for i = 1, cnt do
            self:_drawSector(
                cx,
                cy,
                outerR,
                self._sectorData[i],
                sectorColor
            )
        end
    end

    self:_drawHover(
        cx,
        cy,
        innerR,
        outerR,
        alpha
    )

    RNDX.Circle(cx, cy, outerR)
        :Outline(BORDER_WIDTH)
        :Color(setColor(self._paint.outerBorder, Mantle.color.theme, alpha * 0.5))
    :Draw()

    RNDX.Circle(cx, cy, innerR)
        :Color(setColor(self._paint.inner, Mantle.color.background_panelpopup, alpha))
    :Draw()

    local innerGlowR = math_max(
        0,
        innerR - Mantle.func.w(8) * self.scale
    )

    if innerGlowR > 0 then
        RNDX.Circle(cx, cy, innerGlowR)
            :Color(setColor(
                self._paint.innerGlow,
                Mantle.color.theme,
                alpha * (
                    0.035
                    + self.centerHover * 0.055
                )
            ))
        :Draw()
    end

    RNDX.Circle(cx, cy, innerR)
        :Outline(2)
        :Color(setColor(
            self._paint.innerBorder,
            Mantle.color.panel[1],
            alpha * 0.5
        ))
    :Draw()

    self:_drawOptions(
        cx,
        cy,
        innerR,
        outerR,
        alpha,
        opts
    )

    local titleY
    local descY

    if #self.menuStack > 0 then
        titleY = cy - innerR * 0.48
        descY = cy - innerR * 0.17
    else
        titleY = cy - Mantle.func.h(8) * self.scale
        descY = cy + Mantle.func.h(18) * self.scale
    end

    self:_drawText(
        self.centerText or self.rootMenu.title,
        self.titleFont,
        cx,
        titleY,
        setColor(self._paint.text, Mantle.color.text, alpha),
        TEXT_ALIGN_CENTER,
        TEXT_ALIGN_CENTER
    )

    self:_drawText(
        self.centerDesc or self.rootMenu.desc,
        self.descFont,
        cx,
        descY,
        setColor(self._paint.desc, Mantle.color.header_text, alpha * 0.68),
        TEXT_ALIGN_CENTER,
        TEXT_ALIGN_CENTER
    )

    self:_drawCenterButton(
        cx,
        cy,
        innerR,
        alpha
    )
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
