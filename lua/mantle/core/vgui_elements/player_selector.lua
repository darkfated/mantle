local color_gray = Color(200, 200, 200)
local color_disconnect = Color(210, 65, 65)

function Mantle.ui.player_selector(do_click, func_check)
    if IsValid(Mantle.ui.menu_player_selector) then
        Mantle.ui.menu_player_selector:Remove()
    end

    Mantle.ui.menu_player_selector = vgui.Create('MantleFrame')
    Mantle.ui.menu_player_selector:SetSize(250, 400)
    Mantle.ui.menu_player_selector:Center()
    Mantle.ui.menu_player_selector:MakePopup()
    Mantle.ui.menu_player_selector:SetTitle('')
    Mantle.ui.menu_player_selector:SetCenterTitle('Выбор игрока')

    Mantle.ui.menu_player_selector.sp = vgui.Create('MantleScrollPanel', Mantle.ui.menu_player_selector)
    Mantle.ui.sp(Mantle.ui.menu_player_selector.sp)
    Mantle.ui.menu_player_selector.sp:Dock(FILL)

    for i, pl in pairs(player.GetAll()) do
        if isfunction(func_check) and func_check(pl) then
            continue
        end

        local plyPanel = vgui.Create('Button', Mantle.ui.menu_player_selector.sp)
        plyPanel:Dock(TOP)
        plyPanel:DockMargin(0, 0, 0, 6)
        plyPanel:SetTall(28)
        plyPanel:SetText('')
        plyPanel.Paint = function(self, w, h)
            draw.RoundedBox(6, 0, 0, w, h, Mantle.color.panel[1])
            Mantle.func.gradient(0, 0, w, h, 1, Mantle.color.button_shadow)

            if IsValid(pl) then
                draw.SimpleText(pl:Name(), 'Fated.18', w * 0.5, h * 0.5, self:IsHovered() and color_gray or color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            else
                draw.SimpleText('Вышел', 'Fated.18', w * 0.5, h * 0.5, color_disconnect, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            end
        end
        plyPanel.DoClick = function()
            if IsValid(pl) then
                Mantle.func.sound()
                
                do_click(pl)
            end

            Mantle.ui.menu_player_selector:Remove()
        end

        plyPanel.avatar = vgui.Create('AvatarImage', plyPanel)
        plyPanel.avatar:SetSize(20, 20)
        plyPanel.avatar:SetPos(4, 4)
        plyPanel.avatar:SetPlayer(pl, 24)
    end

    Mantle.ui.menu_player_selector.btn_close = vgui.Create('MantleBtn', Mantle.ui.menu_player_selector)
    Mantle.ui.menu_player_selector.btn_close:Dock(BOTTOM)
    Mantle.ui.menu_player_selector.btn_close:DockMargin(0, 6, 0, 0)
    Mantle.ui.menu_player_selector.btn_close:SetTall(30)
    Mantle.ui.menu_player_selector.btn_close:SetTxt('Закрыть')
    Mantle.ui.menu_player_selector.btn_close:SetColorHover(color_disconnect)
    Mantle.ui.menu_player_selector.btn_close.DoClick = function()
        Mantle.ui.menu_player_selector:AlphaTo(0, 0.1, 0, function()
            Mantle.ui.menu_player_selector:Remove()
        end)
    end
end
