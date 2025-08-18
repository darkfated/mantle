Mantle.func = {
    sw = ScrW(),
    sh = ScrH(),
    ents_scales = {},
}

local function CreateFonts()
    local function CreateFont(name, font_name, size)
        surface.CreateFont(name, {
            font = font_name,
            size = size,
            extended = true
        })
    end

    local old_surface_SetFont = surface.SetFont
    local createdFonts = {
        ['Fated.16'] = true
    }
    CreateFont('Fated.16', 'Montserrat Medium', 16)

    function surface.SetFont(font)
        if type(font) != 'string' then
            if font == nil then
                ErrorNoHalt('surface.SetFont called with nil! Using fallback font')
                old_surface_SetFont('DermaDefault')
                return
            end
            old_surface_SetFont(font)
            return
        end

        if !createdFonts[font] and font:match('^Fated%.') then
            local size, isBold = font:match('^Fated%.(%d+)(b?)$')
            if size then
                size = tonumber(size)
                local fontFamily = isBold == 'b' and 'Montserrat Bold' or 'Montserrat Medium'
                CreateFont(font, fontFamily, size)
                createdFonts[font] = true
            end
        end

        old_surface_SetFont(font)
    end
end

local math_sin = math.sin
local math_clamp = math.Clamp
local math_abs = math.abs

local function CreateFunc()
    local mat_blur = Material('pp/blurscreen')

    --[[
        Отрисовка размытия у панели.
        Применяется в функциях отрисовки (например Paint)
    ]]--
    function Mantle.func.blur(panel)
        local x, y = panel:LocalToScreen(0, 0)

        surface.SetDrawColor(color_white)
        surface.SetMaterial(mat_blur)

        for i = 1, 6 do
            if !mat_blur:GetFloat('$blur') then
                mat_blur:SetFloat('$blur', i)
                mat_blur:Recompute()
            end

            render.UpdateScreenEffectTexture()

            surface.DrawTexturedRect(-x, -y, Mantle.func.sw, Mantle.func.sh)
        end
    end

    local listGradients = {
        Material('vgui/gradient_up'),
        Material('vgui/gradient_down'),
        Material('vgui/gradient-l'),
        Material('vgui/gradient-r')
    }

    --[[
        Отрисовка градиента
    ]]--
    function Mantle.func.gradient(_x, _y, _w, _h, direction, color_shadow, radius, flags)
        radius = radius and radius or 0
        RNDX.DrawMaterial(radius, _x, _y, _w, _h, color_shadow, listGradients[direction], flags)
    end

    function Mantle.func.sound(path)
        surface.PlaySound(path or 'mantle/btn_click.ogg')
    end

    Mantle.func.w_save = {}
    Mantle.func.h_save = {}

    --[[
        Получение относительной ширины (на основе 1920)
        При указании Mantle.func.w(20), 20 будет менять в меньшую сторону или большую в зависимости от ширины экрана
    ]]--
    function Mantle.func.w(px)
        if !Mantle.func.w_save[px] then
            Mantle.func.w_save[px] = px / 1920 * Mantle.func.sw
        end

        return Mantle.func.w_save[px]
    end

    --[[
        Получение относительной высоты (на основе 1080)
    ]]--
    function Mantle.func.h(px)
        if !Mantle.func.h_save[px] then
            Mantle.func.h_save[px] = px / 1080 * Mantle.func.sh
        end

        return Mantle.func.h_save[px]
    end

    local function EntText(text, y)
        surface.SetFont('Fated.40')
        local tw, th = surface.GetTextSize(text)
        local bx, by = -tw * 0.5 - 18, y - 12
        local bw, bh = tw + 36, th + 24

        RNDX().Rect(bx, by, bw, bh - 6)
            :Radii(16, 16, 0, 0)
            :Blur()
            :Shape(RNDX.SHAPE_IOS)
        :Draw()
        RNDX().Rect(bx, by, bw, bh - 6)
            :Radii(16, 16, 0, 0)
            :Color(Mantle.color.header)
            :Shape(RNDX.SHAPE_IOS)
        :Draw()
        RNDX().Rect(bx, by + bh - 6, bw, 6)
            :Radii(0, 0, 16, 16)
            :Color(Mantle.color.text)
        :Draw()

        draw.SimpleText(text, 'Fated.40', 0, y - 2, Mantle.color.text, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
    end

    --[[
        Отрисовка текста на Entity.
        Применяется в функциях отрисовки (например ENT:Draw)
    ]]--
    function Mantle.func.draw_ent_text(ent, text, posY)
        local dist = EyePos():DistToSqr(ent:GetPos())
        if dist > 60000 then return end

        local idx = ent:EntIndex()
        local prev = Mantle.func.ents_scales[idx] or 0
        local target = math_clamp(3 - (dist / 20000), 0, 1)

        local dt = FrameTime() or 0.016
        local appearSpeed = 6 -- скорость появления (меньше -> мягче)
        local disappearSpeed = 12 -- скорость исчезания (больше -> быстрее)
        local speed = target > prev and appearSpeed or disappearSpeed
        local t = 1 - math.exp(-speed * dt)
        local cur = Lerp(t, prev, target)
        Mantle.func.ents_scales[idx] = cur

        local alpha = cur

        local baseScale = 0.13
        local camScale = baseScale * cur

        if cur < 0.01 then
            surface.SetAlphaMultiplier(1)
            return
        end

        local _, max = ent:GetRotatedAABB(ent:OBBMins(), ent:OBBMaxs())
        local rot = (ent:GetPos() - EyePos()):Angle().yaw - 90
        local sin = math_sin(CurTime() + ent:EntIndex()) / 3 + 0.5
        local center = ent:LocalToWorld(ent:OBBCenter())

        surface.SetAlphaMultiplier(alpha)
        cam.Start3D2D(center + Vector(0, 0, math_abs(max.z / 2) + 12 + sin), Angle(0, rot, 90), camScale)
            EntText(text, posY)
        cam.End3D2D()
        surface.SetAlphaMultiplier(1)
    end

    local scaleFactor = 0.9

    function Mantle.func.animate_appearance(panel, target_w, target_h, duration, alpha_dur, callback)
        local startTime = SysTime()
        local initialW = target_w * scaleFactor
        local initialH = target_h * scaleFactor

        local targetX, targetY = panel:GetPos()
        local initialX = targetX + (target_w - initialW) / 2
        local initialY = targetY + (target_h - initialH) / 2

        panel:SetSize(initialW, initialH)
        panel:SetPos(initialX, initialY)
        panel:SetAlpha(0)

        panel.Think = function()
            local elapsed = SysTime() - startTime
            local sizeProgress = math_clamp(elapsed / duration, 0, 1)
            local alphaProgress = math_clamp(elapsed / alpha_dur, 0, 1)

            local currentW = Lerp(sizeProgress, initialW, target_w)
            local currentH = Lerp(sizeProgress, initialH, target_h)
            local currentX = Lerp(sizeProgress, initialX, targetX)
            local currentY = Lerp(sizeProgress, initialY, targetY)

            panel:SetSize(currentW, currentH)
            panel:SetPos(currentX, currentY)

            local alpha = Lerp(alphaProgress, 0, 255)
            panel:SetAlpha(alpha)

            if sizeProgress == 1 and alphaProgress == 1 then
                panel.Think = nil

                if callback then
                    callback(panel)
                end
            end
        end
    end

    --[[
        Плавное изменение цвета с одного на другой
    ]]--
    function Mantle.func.LerpColor(frac, col1, col2)
        local ft = FrameTime() * frac

        return Color(
            Lerp(ft, col1.r, col2.r),
            Lerp(ft, col1.g, col2.g),
            Lerp(ft, col1.b, col2.b),
            Lerp(ft, col1.a, col2.a)
        )
    end
end

CreateFunc()
CreateFonts()

hook.Add('OnScreenSizeChanged', 'Mantle', function()
    local newW, newH = ScrW(), ScrH()

    if newW != Mantle.func.sw and newH != Mantle.func.sh then
        Mantle.func.sw, Mantle.func.sh = newW, newH

        Mantle.func.w_save = {}
        Mantle.func.h_save = {}

        CreateFunc()
        -- CreateFonts()
    end
end)
