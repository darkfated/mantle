Mantle.func = {}
Mantle.ui = {}

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
        surface.GetTextureID('gui/gradient_down')
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
            Mantle.func.h_save[h] = h / 1920 * scrh
        end
    
        return Mantle.func.h_save[h]
    end
end

local function create_vgui()
    local color_white = Color(255, 255, 255)
    local color_gray = Color(200, 200, 200)
    local color_red = Color(255, 50, 50)
    local mat_close = Material('mantle/close_btn.png')

    function Mantle.ui.frame(s, title, width, height, close_bool)
        s:SetSize(width, height)
        s:SetTitle('')
        s:ShowCloseButton(false)
        s:DockPadding(6, 30, 6, 6)
        s.f_title = title
        s.Paint = function(self, w, h)
            local x, y = self:LocalToScreen()

            BSHADOWS.BeginShadow()
                draw.RoundedBoxEx(6, x, y, w, 24, Mantle.color.header, true, true)
                draw.RoundedBoxEx(6, x, y + 24, w, h - 24, Mantle.color.background, false, false, true, true)
                draw.SimpleText(self.f_title, 'Fated.16', x + 6, y + 4, color_white)
            BSHADOWS.EndShadow(1, 2, 2, 255, 0, 0)
        end

        if close_bool then
            s.cls = vgui.Create('DButton', s)
            s.cls:SetSize(20, 20)
            s.cls:SetPos(width - 22, 2)
            s.cls:SetText('')
            s.cls.Paint = function(_, w, h)
                surface.SetDrawColor(color_white)
                surface.SetMaterial(mat_close)
                surface.DrawTexturedRect(0, 0, w, h)
            end
            s.cls.DoClick = function()
                s:Remove()
            end
            s.cls.DoRightClick = function()
                local DM = DermaMenu()
                DM:AddOption('Закрыть окно', function()
                    s:Remove()
                end)
                DM:Open()
            end
        end
    end

    function Mantle.ui.sp(s)
        local vbar = s:GetVBar()
        vbar:SetWide(12)
        vbar.Paint = nil
        vbar.btnDown.Paint = nil
        vbar.btnUp.Paint = nil
        vbar.btnGrip.Paint = function(_, w, h)
            draw.RoundedBox(6, 6, 0, w - 6, h, Mantle.color.vbar)
        end
    end

    function Mantle.ui.btn(s, icon, icon_size, btn_color, btn_radius, off_grad_bool, btn_color_hov)
        s:SetTall(32)
        s.hoverStatus = 0
        s.Paint = function(self, w, h)
            if !self.btn_text then
                self.btn_text = self:GetText()
                self:SetText('')
            end
            
            if self:IsHovered() then
                self.hoverStatus = math.Clamp(self.hoverStatus + 4 * FrameTime(), 0, 255)
            else
                self.hoverStatus = math.Clamp(self.hoverStatus - 8 * FrameTime(), 0, 255)
            end

            draw.RoundedBox(btn_radius and btn_radius or 6, 0, 0, w, h, btn_color and btn_color or Mantle.color.button)

            local color_hover = btn_color_hov and btn_color_hov or Mantle.color.button_hovered 
            color_hover = Color(color_hover.r, color_hover.g, color_hover.b, 255 * self.hoverStatus)

            draw.RoundedBox(btn_radius and btn_radius or 6, 0, 0, w, h, color_hover)

            if !off_grad_bool then
                Mantle.func.gradient(0, 0, w, h, 1, Mantle.color.button_shadow)
            end

            draw.SimpleText(self.btn_text, 'Fated.18', w * 0.5 + (icon and icon_size * 0.5 - 2 or 0), h * 0.5 - 1, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

            if icon then
                surface.SetDrawColor(color_white)
                surface.SetMaterial(icon)
                surface.DrawTexturedRect(2, (h - icon_size) * 0.5, icon_size, icon_size)
            end
        end
    end

    function Mantle.ui.desc_entry(parent, title, placeholder)
        local label = vgui.Create('DLabel', parent)
        label:Dock(TOP)
        label:SetText(title)
        label:SetFont('Fated.16')
    
        local entry = vgui.Create('DTextEntry', parent)
        entry:Dock(TOP)
        entry:DockMargin(0, 4, 0, 0)
        entry:SetTall(24)
        entry:SetPlaceholderText(placeholder)
        entry:SetFont('Fated.16')
        entry:SetDrawLanguageID(false)

        return entry
    end

    function Mantle.ui.player_selector(doclick, func_check)
        if IsValid(Mantle.ui.menu_player_selector) then
            Mantle.ui.menu_player_selector:Remove()
        end

        Mantle.ui.menu_player_selector = vgui.Create('DFrame')
        Mantle.ui.frame(Mantle.ui.menu_player_selector, 'Выбор игрока', 250, 400, false)
        Mantle.ui.menu_player_selector:Center()
        Mantle.ui.menu_player_selector:MakePopup()

        Mantle.ui.menu_player_selector.sp = vgui.Create('DScrollPanel', Mantle.ui.menu_player_selector)
        Mantle.ui.sp(Mantle.ui.menu_player_selector.sp)
        Mantle.ui.menu_player_selector.sp:Dock(FILL)
        Mantle.ui.menu_player_selector.sp:DockMargin(6, 6, 6, 6)

        for i, pl in pairs(player.GetAll()) do
            if func_check(pl) then
                continue 
            end

            local panel_ply = vgui.Create('DButton', Mantle.ui.menu_player_selector.sp)
            panel_ply:Dock(TOP)
            panel_ply:DockMargin(0, 0, 0, 6)
            panel_ply:SetTall(40)
            panel_ply:SetText('')
            panel_ply.Paint = function(self, w, h)
                draw.RoundedBox(6, 0, 0, w, h, Mantle.color.panel[1])
                Mantle.func.gradient(0, 0, w, h, 1, Mantle.color.button_shadow)

                if IsValid(pl) then
                    draw.SimpleText(pl:Name(), 'Fated.18', w * 0.5, h * 0.5, self:IsHovered() and color_gray or color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                else
                    draw.SimpleText('Вышел', 'Fated.18', w * 0.5, h * 0.5, color_red, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                end
            end
            panel_ply.DoClick = function()
                if IsValid(pl) then
                    doclick(pl)
                end

                Mantle.ui.menu_player_selector:Remove()
            end

            panel_ply.avatar = vgui.Create('AvatarImage', panel_ply)
            panel_ply.avatar:SetSize(32, 32)
            panel_ply.avatar:SetPos(4, 4)
            panel_ply.avatar:SetPlayer(pl)
        end

        Mantle.ui.menu_player_selector.btn_close = vgui.Create('DButton', Mantle.ui.menu_player_selector)
        Mantle.ui.btn(Mantle.ui.menu_player_selector.btn_close)
        Mantle.ui.menu_player_selector.btn_close:Dock(BOTTOM)
        Mantle.ui.menu_player_selector.btn_close:DockMargin(0, 6, 0, 0)
        Mantle.ui.menu_player_selector.btn_close:SetText('Закрыть')
        Mantle.ui.menu_player_selector.btn_close.DoClick = function()
            Mantle.ui.menu_player_selector:Remove()
        end
    end

    function Mantle.ui.color_picker(func, color_standart)
        if IsValid(Mantle.ui.menu_color_picker) then
            Mantle.ui.menu_color_picker:Remove()
        end

        Mantle.ui.menu_color_picker = vgui.Create('DFrame')
        Mantle.ui.frame(Mantle.ui.menu_color_picker, 'Выбор цвета', 250, 400, false)
        Mantle.ui.menu_color_picker:Center()
        Mantle.ui.menu_color_picker:MakePopup()

        Mantle.ui.menu_color_picker.picker = vgui.Create('DColorMixer', Mantle.ui.menu_color_picker)
        Mantle.ui.menu_color_picker.picker:Dock(FILL)
        Mantle.ui.menu_color_picker.picker:SetAlphaBar(false)

        if color_standart then
            Mantle.ui.menu_color_picker.picker:SetColor(color_standart)
        end

        Mantle.ui.menu_color_picker.btn_close = vgui.Create('DButton', Mantle.ui.menu_color_picker)
        Mantle.ui.btn(Mantle.ui.menu_color_picker.btn_close, nil, nil, Color(210, 65, 65))
        Mantle.ui.menu_color_picker.btn_close:Dock(BOTTOM)
        Mantle.ui.menu_color_picker.btn_close:DockMargin(0, 6, 0, 0)
        Mantle.ui.menu_color_picker.btn_close:SetText('Закрыть')
        Mantle.ui.menu_color_picker.btn_close.DoClick = function()
            Mantle.ui.menu_color_picker:Remove()
        end

        Mantle.ui.menu_color_picker.btn_select = vgui.Create('DButton', Mantle.ui.menu_color_picker)
        Mantle.ui.btn(Mantle.ui.menu_color_picker.btn_select)
        Mantle.ui.menu_color_picker.btn_select:Dock(BOTTOM)
        Mantle.ui.menu_color_picker.btn_select:DockMargin(0, 6, 0, 0)
        Mantle.ui.menu_color_picker.btn_select:SetText('Выбрать')
        Mantle.ui.menu_color_picker.btn_select.DoClick = function()
            local col = Mantle.ui.menu_color_picker.picker:GetColor()

            func(Color(col.r, col.g, col.b))

            Mantle.ui.menu_color_picker:Remove()
        end
    end
end

create_ui_func()
create_fonts()
create_vgui()

concommand.Add('mantle_ui_test', function()
    local frame = vgui.Create('DFrame')
    Mantle.ui.frame(frame, 'Test', 600, 400, true)
    frame:Center()
    frame:MakePopup()

    local main_sp = vgui.Create('DScrollPanel', frame)
    Mantle.ui.sp(main_sp)
    main_sp:Dock(FILL)
    
    for i = 1, 22 do
        local btn = vgui.Create('DButton', main_sp)
        Mantle.ui.btn(btn)
        btn:Dock(TOP)
        btn:DockMargin(0, 0, 0, 6)
        btn:SetText('Button ' .. i)
    end
end)
