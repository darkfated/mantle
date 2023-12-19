local function Create()
    local frame = vgui.Create('DFrame')
    Mantle.ui.frame(frame, 'Тест компонентов UI Mantle', 600, 400, true)
    frame:Center()
    frame:MakePopup()

    local panel_tabs = Mantle.ui.panel_tabs(frame)

    local sp_pops = vgui.Create('DPanel')
    sp_pops.Paint = nil

    local config_pop_actions = {
        {
            'Опциональное меню (Derma Menu)',
            function()
                local DM = Mantle.ui.derma_menu()

                for i = 1, 5 do
                    DM:AddOption('Тест ' .. i, function()
                        chat.AddText('Привет всем!')
                    end)
                end

                DM:AddSpacer()
                DM:AddOption('Узнать свою привилегию', function()
                    chat.AddText(LocalPlayer():GetUserGroup())
                end, 'icon16/status_online.png')
            end
        },
        {
            'Выбор игрока',
            function()
                Mantle.ui.player_selector(function(pl)
                    chat.AddText('Вы выбрали игрока: ' .. pl:Name())
                end)
            end
        },
        {
            'Выбор цвета через палитру',
            function()
                Mantle.ui.color_picker(function(col)
                    chat.AddText('Вы выбрали цвет: ' .. tostring(col))
                end, Color(25, 59, 102))
            end
        }
    }

    for i, action in ipairs(config_pop_actions) do
        local btn_action = vgui.Create('DButton', sp_pops)
        Mantle.ui.btn(btn_action)
        btn_action:Dock(TOP)
        btn_action:DockMargin(0, 0, 0, 4)
        btn_action:SetText(action[1])
        btn_action.DoClick = function()
            action[2]()
        end
    end

    panel_tabs:AddTab('Всплывающие меню', sp_pops)

    local panel_interactive = vgui.Create('DPanel')
    panel_interactive.Paint = function(_, w, h)
        draw.RoundedBox(6, 0, 0, w, h, Color(57, 74, 133, 50))
    end

    local sp_text = vgui.Create('DScrollPanel', panel_interactive)
    Mantle.ui.sp(sp_text)
    sp_text:Dock(TOP)
    sp_text:SetTall(160)

    for i = 1, 10 do
        local btn = vgui.Create('DButton', sp_text)
        Mantle.ui.btn(btn, Material('icon16/clock.png'), 16, Color(67, 92, 160), 6, false, Color(85, 95, 227), false)
        btn:Dock(TOP)
        btn:SetTall(40)
        btn:DockMargin(0, 0, 0, 6)
        btn:SetText('Кнопка ' .. i)
    end

    local text_entry_nickname = Mantle.ui.desc_entry(panel_interactive, 'Ник', 'Как вас зовут?')

    panel_tabs:AddTab('Интерактивные элементы', panel_interactive, Material('icon16/accept.png'))
    panel_tabs:ActiveTab('Всплывающие меню')
end

concommand.Add('mantle_ui_test', Create)
