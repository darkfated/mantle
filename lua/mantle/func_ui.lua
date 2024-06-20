Mantle.func = {}

local function create_fonts()
    for s = 1, 50 do
        surface.CreateFont('Fated.' .. s, {
            font = 'Montserrat Medium',
            size = s,
            weight = 500,
            extended = true
        })
    end
end

local function create_ui_func()
    local color_white = Color(255, 255, 255)
    local mat_blur = Material('pp/blurscreen')
    local scrw, scrh = ScrW(), ScrH()

    function Mantle.func.blur(panel)
        local x, y = panel:LocalToScreen(0, 0)

        surface.SetDrawColor(color_white)
        surface.SetMaterial(mat_blur)

        for i = 1, 6 do
            mat_blur:SetFloat('$blur', i)
            mat_blur:Recompute()

            render.UpdateScreenEffectTexture()

            surface.DrawTexturedRect(-x, -y, scrw, scrh)
        end
    end

    local list_gradient = {
        surface.GetTextureID('gui/gradient_up'),
        surface.GetTextureID('gui/gradient_down'),
        surface.GetTextureID('vgui/gradient-l'),
        surface.GetTextureID('vgui/gradient-r')
    }

    function Mantle.func.gradient(_x, _y, _w, _h, direction, color_shadow)
        draw.TexturedQuad{
            texture = list_gradient[direction],
            color = color_shadow,
            x = _x,
            y = _y,
            w = _w,
            h = _h
        }
    end

    function Mantle.func.sound(snd)
        surface.PlaySound(snd or 'mantle/btn_click.ogg')
    end

    Mantle.func.w_save = {}
    Mantle.func.h_save = {}
    
    function Mantle.func.w(w)
        if !Mantle.func.w_save[w] then
            Mantle.func.w_save[w] = w / 1920 * scrw
        end
    
        return Mantle.func.w_save[w]
    end
    
    function Mantle.func.h(h)
        if !Mantle.func.h_save[h] then
            Mantle.func.h_save[h] = h / 1080 * scrh
        end
    
        return Mantle.func.h_save[h]
    end

    local function ent_text(text, y)
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

    function Mantle.func.draw_ent_text(ent, txt, posY)
        local dist = EyePos():DistToSqr(ent:GetPos())

        if dist > 60000 then
            return
        end
        
        surface.SetAlphaMultiplier(math.Clamp(3 - (dist / 20000), 0, 1))

        local _, max = ent:GetRotatedAABB(ent:OBBMins(), ent:OBBMaxs())
        local rot = (ent:GetPos() - EyePos()):Angle().yaw - 90
        local sin = math.sin(CurTime() + ent:EntIndex()) / 3 + 0.5
        local center = ent:LocalToWorld(ent:OBBCenter())

        cam.Start3D2D(center + Vector(0, 0, math.abs(max.z / 2) + 12 + sin), Angle(0, rot, 90), 0.13)
            ent_text(txt, posY)
        cam.End3D2D()

        surface.SetAlphaMultiplier(1)
    end

    function Mantle.func.animate_appearance(panel, target_w, target_h, duration, alpha_duration, func_callback)
        local startTime = SysTime()
        local scale_factor = 0.9
    
        local initial_w = target_w * scale_factor
        local initial_h = target_h * scale_factor
    
        panel:SetSize(initial_w, initial_h)
        panel:SetAlpha(0)
        panel:Center()
    
        panel.Think = function()
            local elapsed = SysTime() - startTime
            local size_progress = math.Clamp(elapsed / duration, 0, 1)
            local alpha_progress = math.Clamp(elapsed / alpha_duration, 0, 1)
    
            local current_w = Lerp(size_progress, initial_w, target_w)
            local current_h = Lerp(size_progress, initial_h, target_h)
            panel:SetSize(current_w, current_h)
            panel:Center()
    
            local alpha = Lerp(alpha_progress, 0, 255)
            panel:SetAlpha(alpha)
    
            if size_progress == 1 and alpha_progress == 1 then
                panel.Think = nil

                if func_callback then
                    func_callback(panel)
                end
            end
        end
    end
end

create_ui_func()
create_fonts()

hook.Add('OnScreenSizeChanged', 'Mantle', function()
    create_ui_func()
end)
