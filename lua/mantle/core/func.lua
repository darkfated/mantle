Mantle.func = {
    sw = ScrW(),
    sh = ScrH(),
    ents_scales = {},
    w_save = {},
    h_save = {},
}

local mat_blur = Material('pp/blurscreen')
local mat_gradients = {
    Material('vgui/gradient_up'),
    Material('vgui/gradient_down'),
    Material('vgui/gradient-l'),
    Material('vgui/gradient-r')
}

-- Создание шрифтов Fated.* на лету
local function setupFonts()
    local function createFont(name, family, size)
        surface.CreateFont(name, { font = family, size = size, extended = true })
    end

    local original = surface.SetFont
    local created = { ['Fated.16'] = true }
    createFont('Fated.16', 'Montserrat Medium', 16)

    function surface.SetFont(font)
        if type(font) ~= 'string' then
            if font == nil then
                ErrorNoHalt('surface.SetFont called with nil! Using fallback font')
                original('DermaDefault')
                return
            end
            original(font)
            return
        end

        if not created[font] and font:match('^Fated%.') then
            local size, isBold = font:match('^Fated%.(%d+)(b?)$')
            if size then
                createFont(font, isBold == 'b' and 'Montserrat Bold' or 'Montserrat Medium', tonumber(size))
                created[font] = true
            end
        end

        original(font)
    end

    function Mantle.func.cache_font( size, isBold )
        if not isnumber(size) then return "DermaDefault" end
        size = math.max(0, size)

        local font = string.format("Fated.%i%s", size, isBold and "b" or "")
        surface.SetFont(font)

        return font
    end
end

-- Размытие фона под панелью
function Mantle.func.blur(panel)
    local x, y = panel:LocalToScreen(0, 0)

    surface.SetDrawColor(color_white)
    surface.SetMaterial(mat_blur)

    for i = 1, 6 do
        mat_blur:SetFloat('$blur', i)
        mat_blur:Recompute()

        render.UpdateScreenEffectTexture()
        surface.DrawTexturedRect(-x, -y, Mantle.func.sw, Mantle.func.sh)
    end
end

-- Градиент в прямоугольнике
function Mantle.func.gradient(x, y, w, h, direction, color, radius, flags)
    local rect = RNDX.Rect(x, y, w, h)
        :Rad(radius or 0)
        :Material(mat_gradients[direction])
        :Color(color)
    if flags then rect:Flags(flags) end
    rect:Draw()
end

-- Проиграть звук
function Mantle.func.sound(path)
    surface.PlaySound(path or 'mantle/btn_click.ogg')
end

-- Относительная ширина (база 1920)
function Mantle.func.w(px)
    local cached = Mantle.func.w_save[px]
    if not cached then
        cached = px / 1920 * Mantle.func.sw
        Mantle.func.w_save[px] = cached
    end

    return cached
end

-- Относительная высота (база 1080)
function Mantle.func.h(px)
    local cached = Mantle.func.h_save[px]
    if not cached then
        cached = px / 1080 * Mantle.func.sh
        Mantle.func.h_save[px] = cached
    end

    return cached
end

local function drawEntText(text, y)
    surface.SetFont('Fated.40')
    local tw, th = surface.GetTextSize(text)
    local bx, by = -tw * 0.5 - 18, y - 12
    local bw, bh = tw + 36, th + 24

    RNDX.Rect(bx, by, bw, bh - 6)
        :Radii(16, 16, 0, 0)
        :Blur()
    :Draw()
    RNDX.Rect(bx, by, bw, bh - 6)
        :Radii(16, 16, 0, 0)
        :Color(Mantle.color.background_alpha)
    :Draw()
    RNDX.Rect(bx, by + bh - 6, bw, 6)
        :Radii(0, 0, 16, 16)
        :Color(Mantle.color.text)
    :Draw()

    draw.SimpleText(text, 'Fated.40', 0, y - 2, Mantle.color.text, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
end

-- Текст над энтити в 3D
function Mantle.func.draw_ent_text(ent, text, posY)
    local distSqr = EyePos():DistToSqr(ent:GetPos())
    local maxDist = 380
    if distSqr > maxDist * maxDist then return end

    local dist = math.sqrt(distSqr)
    local minDist = 20

    local idx = ent:EntIndex()
    local prev = Mantle.func.ents_scales[idx] or 0

    local normalized = math.Clamp((maxDist - dist) / math.max(1, (maxDist - minDist)), 0, 1)

    local appearThreshold = 0.8
    local disappearThreshold = 0.01

    local target
    if normalized <= disappearThreshold then
        target = 0
    elseif normalized >= appearThreshold then
        target = 1
    else
        target = (normalized - disappearThreshold) / (appearThreshold - disappearThreshold)
    end

    local dt = FrameTime() or 0.016
    local appearSpeed = 18
    local disappearSpeed = 12
    local speed = (target > prev) and appearSpeed or disappearSpeed

    local cur = Mantle.func.approachExp(prev, target, speed, dt)
    if math.abs(cur - target) < 0.0005 then cur = target end
    Mantle.func.ents_scales[idx] = cur

    local eased = Mantle.func.easeInOutCubic(cur)
    local alpha = eased
    local baseScale = 0.13
    local camScale = baseScale * math.max(1e-4, eased)

    if eased < 0.01 then
        surface.SetAlphaMultiplier(1)
        return
    end

    local _, max = ent:GetRotatedAABB(ent:OBBMins(), ent:OBBMaxs())
    local rot = (ent:GetPos() - EyePos()):Angle().yaw - 90
    local bob = math.sin(CurTime() + idx) / 3 + 0.5
    local center = ent:LocalToWorld(ent:OBBCenter())

    surface.SetAlphaMultiplier(alpha)
    cam.Start3D2D(center + Vector(0, 0, math.abs(max.z / 2) + 12 + bob), Angle(0, rot, 90), camScale)
        drawEntText(text, posY)
    cam.End3D2D()
    surface.SetAlphaMultiplier(1)
end

-- Анимация появления панели
function Mantle.func.animate_appearance(panel, target_w, target_h, duration, alpha_dur, callback, scale_factor)
    if not IsValid(panel) then return end
    duration = (duration and duration > 0) and duration or 0.18
    alpha_dur = (alpha_dur and alpha_dur > 0) and alpha_dur or duration

    local targetX, targetY = panel:GetPos()

    local initialScale = scale_factor or 0.8
    local initialW = target_w * initialScale
    local initialH = target_h * initialScale
    local initialX = targetX + (target_w - initialW) / 2
    local initialY = targetY + (target_h - initialH) / 2

    panel:SetSize(initialW, initialH)
    panel:SetPos(initialX, initialY)
    panel:SetAlpha(0)

    local curW, curH = initialW, initialH
    local curX, curY = initialX, initialY
    local curA = 0

    local eps = 0.5
    local alpha_eps = 1

    local speedSize = 3 / math.max(0.0001, duration)
    local speedAlpha = 3 / math.max(0.0001, alpha_dur)

    panel.Think = function()
        if not IsValid(panel) then return end

        local dt = FrameTime()

        curW = Mantle.func.approachExp(curW, target_w, speedSize, dt)
        curH = Mantle.func.approachExp(curH, target_h, speedSize, dt)
        curX = Mantle.func.approachExp(curX, targetX, speedSize, dt)
        curY = Mantle.func.approachExp(curY, targetY, speedSize, dt)
        curA = Mantle.func.approachExp(curA, 255, speedAlpha, dt)

        panel:SetSize(curW, curH)
        panel:SetPos(curX, curY)
        panel:SetAlpha(math.floor(curA + 0.5))

        local doneSize = math.abs(curW - target_w) <= eps and math.abs(curH - target_h) <= eps
        local donePos = math.abs(curX - targetX) <= eps and math.abs(curY - targetY) <= eps
        local doneAlpha = math.abs(curA - 255) <= alpha_eps

        if doneSize and donePos and doneAlpha then
            panel:SetSize(target_w, target_h)
            panel:SetPos(targetX, targetY)
            panel:SetAlpha(255)
            panel.Think = nil
            if callback then callback(panel) end
        end
    end
end

-- Плавный переход цвета
function Mantle.func.LerpColor(frac, col1, col2)
    local ft = FrameTime() * frac

    return Color(
        Lerp(ft, col1.r, col2.r),
        Lerp(ft, col1.g, col2.g),
        Lerp(ft, col1.b, col2.b),
        Lerp(ft, col1.a, col2.a)
    )
end

-- Экспоненциальное приближение значения
function Mantle.func.approachExp(current, target, speed, dt)
    local t = 1 - math.exp(-speed * dt)
    return current + (target - current) * t
end

-- Easing: быстрый старт, плавное окончание
function Mantle.func.easeOutCubic(t)
    return 1 - (1 - t) * (1 - t) * (1 - t)
end

-- Easing: плавные старт и окончание
function Mantle.func.easeInOutCubic(t)
    if t < 0.5 then
        return 4 * t * t * t
    else
        return 1 - math.pow(-2 * t + 2, 3) / 2
    end
end

-- Не дать панели выйти за границы экрана
function Mantle.func.ClampMenuPosition(panel)
    if not IsValid(panel) then return end
    local x, y = panel:GetPos()
    local w, h = panel:GetSize()
    local sw, sh = Mantle.func.sw, Mantle.func.sh
    if x < 5 then x = 5 elseif x + w > sw - 5 then x = sw - 5 - w end
    if y < 5 then y = 5 elseif y + h > sh - 5 then y = sh - 5 - h end
    panel:SetPos(x, y)
end

-- Конвертация integer в boolean
function Mantle.func.int2bool( val, rev )
    if not isnumber(val) then return false end
    return rev and val < 1 or val > 0
end

    -- Конвертация boolean в integer
    function Mantle.func.bool2int( bool, rev )
        if not isbool(bool) and bool ~= nil then return 0 end
        return rev and (bool and 0 or 1) or (bool and 1 or 0)
    end

    -- Проверка на пустоту в string-
    function Mantle.func.nil_str( str )
        if isstring(str) and #str > 0 then return str end
        return nil
    end

setupFonts()

hook.Add('OnScreenSizeChanged', 'Mantle', function()
    local newW, newH = ScrW(), ScrH()
    if newW == Mantle.func.sw and newH == Mantle.func.sh then return end

    Mantle.func.sw, Mantle.func.sh = newW, newH
    Mantle.func.w_save = {}
    Mantle.func.h_save = {}
end)
