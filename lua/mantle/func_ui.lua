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
        surface.PlaySound(snd or 'UI/buttonclickrelease.wav')
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
end

create_ui_func()
create_fonts()
