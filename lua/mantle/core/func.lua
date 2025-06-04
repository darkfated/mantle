CreateClientConVar('mantle_col_theme', '[106,108,197]', true, false)
CreateClientConVar('mantle_col_hoverbtn', '[52,70,109]', true, false)

Mantle.func = {
    sw = ScrW(),
    sh = ScrH()
}

local function CreateFonts()
    local function CreateFont(name, font_name, size)
        surface.CreateFont(name, {
            font = font_name,
            size = size,
            extended = true
        })
    end

    CreateFont('Fated.12', 'Montserrat Medium', 12)
    CreateFont('Fated.17', 'Montserrat Medium', 17)
    CreateFont('Fated.19', 'Montserrat Medium', 19)

    for s = 14, 40, 2 do
        CreateFont('Fated.' .. s, 'Montserrat Medium', s)
        CreateFont('Fated.' .. s .. 'b', 'Montserrat Bold', s) -- жирный вариант
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

    function Mantle.func.sound(snd)
        surface.PlaySound(snd or 'mantle/btn_click.ogg')
    end

    Mantle.func.w_save = {}
    Mantle.func.h_save = {}
    
    --[[
        Получение относительной ширины (на основе 1920)
        При указании Mantle.func.w(20), 20 будет менять в меньшую сторону или большую в зависимости от ширины экрана
    ]]--
    function Mantle.func.w(w)
        if !Mantle.func.w_save[w] then
            Mantle.func.w_save[w] = w / 1920 * Mantle.func.sw
        end
    
        return Mantle.func.w_save[w]
    end
    
    --[[
        Получение относительной высоты (на основе 1080)
    ]]--
    function Mantle.func.h(h)
        if !Mantle.func.h_save[h] then
            Mantle.func.h_save[h] = h / 1080 * Mantle.func.sh
        end
    
        return Mantle.func.h_save[h]
    end

    local function EntText(text, y)
        surface.SetFont('Fated.40')
    
        local tw, th = surface.GetTextSize(text)
        local bx, by = -tw * 0.5 - 10, y - 5
        local bw, bh = tw + 20, th + 20

        draw.RoundedBoxEx(12, bx, by, bw, bh, Mantle.color.background_alpha, true, true, false, false)

        surface.SetDrawColor(color_white)
        surface.DrawRect(bx, by + bh - 4, bw, 4)

        surface.SetTextColor(color_white)
        surface.SetTextPos(-tw * 0.5, y)
        surface.DrawText(text)
    end

    --[[
        Отрисовка текста на Entity.
        Применяется в функциях отрисовки (например ENT:Draw)
    ]]--
    function Mantle.func.draw_ent_text(ent, txt, posY)
        local dist = EyePos():DistToSqr(ent:GetPos())

        if dist > 60000 then
            return
        end
        
        surface.SetAlphaMultiplier(math_clamp(3 - (dist / 20000), 0, 1))

        local _, max = ent:GetRotatedAABB(ent:OBBMins(), ent:OBBMaxs())
        local rot = (ent:GetPos() - EyePos()):Angle().yaw - 90
        local sin = math_sin(CurTime() + ent:EntIndex()) / 3 + 0.5
        local center = ent:LocalToWorld(ent:OBBCenter())

        cam.Start3D2D(center + Vector(0, 0, math_abs(max.z / 2) + 12 + sin), Angle(0, rot, 90), 0.13)
            EntText(txt, posY)
        cam.End3D2D()

        surface.SetAlphaMultiplier(1)
    end

    local scaleFactor = 0.9

    function Mantle.func.animate_appearance(panel, target_w, target_h, duration, alpha_duration, func_callback)
        local startTime = SysTime()
        local initialW = target_w * scaleFactor
        local initialH = target_h * scaleFactor

        panel:SetSize(initialW, initialH)
        panel:SetAlpha(0)
        panel:Center()
    
        panel.Think = function()
            local elapsed = SysTime() - startTime
            local sizeProgress = math_clamp(elapsed / duration, 0, 1)
            local alphaProgress = math_clamp(elapsed / alpha_duration, 0, 1)
    
            local currentW = Lerp(sizeProgress, initialW, target_w)
            local currentH = Lerp(sizeProgress, initialH, target_h)
            panel:SetSize(currentW, currentH)
            panel:Center()
    
            local alpha = Lerp(alphaProgress, 0, 255)
            panel:SetAlpha(alpha)
    
            if sizeProgress == 1 and alphaProgress == 1 then
                panel.Think = nil

                if func_callback then
                    func_callback(panel)
                end
            end
        end
    end

    --[[
        Плавное изменение цвета с одного на другой
    ]]--
    function Mantle.func.LerpColor(frac, from, to)
        local ft = FrameTime() * frac

        return Color(
            Lerp(ft, from.r, to.r),
            Lerp(ft, from.g, to.g),
            Lerp(ft, from.b, to.b),
            Lerp(ft, from.a, to.a)
        )
    end

    function Mantle.func.SetCustomColors()
        local tableTheme = util.JSONToTable(GetConVar('mantle_col_theme'):GetString())
        local tableHoverButton = util.JSONToTable(GetConVar('mantle_col_hoverbtn'):GetString())
        Mantle.color.theme = Color(tableTheme[1], tableTheme[2], tableTheme[3])
        Mantle.color.button_hovered = Color(tableHoverButton[1], tableHoverButton[2], tableHoverButton[3])
    end

    Mantle.func.SetCustomColors()
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
        CreateFonts()
    end
end)
