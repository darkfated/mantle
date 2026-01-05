function CreateMantlePopupTab()
    local sp = vgui.Create('MantleScrollPanel')

    local listMenus = {
        {'Выбор цвета через палитру', function()
            Mantle.ui.color_picker(function(col)
                chat.AddText('Вы выбрали цвет: ', col, tostring(col))
            end, Color(25, 59, 102))
        end},
        {'Опциональное меню (Derma Menu)', function()
            local DM = Mantle.ui.derma_menu()
            for i = 1, 5 do
                DM:AddOption('Опция ' .. i, function()
                    chat.AddText('Привет всем! ' .. i)
                end)
            end
            DM:AddSpacer()
            DM:AddOption('Узнать свою привилегию', function()
                chat.AddText(LocalPlayer():GetUserGroup())
            end, 'icon16/status_online.png')
        end},
        {'Опциональное с подменю (Derma Menu)', function()
            local DM = Mantle.ui.derma_menu()

            local clothes = DM:AddOption('Одежда')
            local subClothes = clothes:AddSubMenu()
            subClothes:AddOption('Шапка', function()
                chat.AddText('Вы выбрали: Шапка')
            end)
            subClothes:AddOption('Свитер', function()
                chat.AddText('Вы выбрали: Свитер')
            end)

            local food = DM:AddOption('Еда')
            local subFood = food:AddSubMenu()
            subFood:AddOption('Морковь', function()
                chat.AddText('Вы выбрали: Морковь')
            end)
            subFood:AddOption('Яблоко', function()
                chat.AddText('Вы выбрали: Яблоко')
            end)
        end},
        {'Выбор игрока', function()
            Mantle.ui.player_selector(function(pl)
                chat.AddText('Вы выбрали игрока: ', color_white, pl:Name())
            end)
        end},
        {'Круговое меню', function()
            --[[
            Имеется возможность настроить радиальное меню

            local configRadial = {
                disable_background = true, -- отключает фон
                hover_sound = 'buttons/button14.wav', -- звук при наведении
                scale_animation = false, -- отключает анимацию масштабирования
                radius = 300, -- радиус меню
                inner_radius = 100 -- радиус внутреннего круга
            }

            local rm = Mantle.ui.radial_menu(configRadial)
            --]]

            local rm = Mantle.ui.radial_menu()
            rm:SetCenterText('Действия', 'Выберите действие')

            local weaponsMenu = rm:CreateSubMenu('Оружие', 'Выберите оружие')
            weaponsMenu:AddOption('Пистолет', function()
                chat.AddText(Mantle.color.theme, 'Выбран пистолет')
            end, 'icon16/gun.png', 'Обычный пистолет')
            weaponsMenu:AddOption('Винтовка', function()
                chat.AddText(Mantle.color.theme, 'Выбрана винтовка')
            end, 'icon16/gun.png', 'Мощная винтовка')
            rm:AddSubMenuOption('Оружие', weaponsMenu, 'icon16/gun.png', 'Выберите оружие')

            -- Обычные опции
            rm:AddOption('Выбросить', function()
                chat.AddText('Выбросить оружие')
            end, 'icon16/gun.png', 'Выбросить оружие')
            rm:AddOption('Кинуть кубик', function()
                chat.AddText('Действие выполнено')
            end, 'icon16/controller.png', 'Рандом кубика')
            rm:AddOption('Погибнуть', function()
                chat.AddText('Действие выполнено')
            end, 'icon16/world.png', 'Попрощаться с миром')
            rm:AddOption('Хакнуть', function()
                chat.AddText('Действие выполнено')
            end, 'icon16/server.png', 'Взломать сервер')
            rm:AddOption('Посмотреть баланс', function()
                chat.AddText('Действие выполнено')
            end, 'icon16/money.png', 'Сколько у вас денег')
            rm:AddOption('Нет иконки', function()
                chat.AddText('Действие выполнено')
            end, nil, 'Где иконка?')
        end},
        {'Написание текста', function()
            Mantle.ui.text_box('Заголовок', 'Описание того, что вводиться', function(s)
                chat.AddText('Вы ввели: ', color_white, s)
            end)
        end},
        {'Вызов сообщения в Окне', function()
            MantleMenu:Notify('Тестовое сообщение!')
        end}
    }

    for _, elem in ipairs(listMenus) do
        local btn = vgui.Create('MantleBtn', sp)
        btn:Dock(TOP)
        btn:DockMargin(0, 0, 0, 6)
        btn:SetTxt(elem[1])
        btn.DoClick = function()
            elem[2]()
            Mantle.func.sound()
        end
    end

    return sp
end
