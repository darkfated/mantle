local menu = Mantle.menu

local function createDemoButton(text, callback)
    local button = vgui.Create('MantleBtn')
    button:Dock(TOP)
    button:SetTall(30)
    button:SetTxt(text)
    button.DoClick = function()
        callback()
        Mantle.func.sound()
    end

    return button
end

local function build()
    local panel = menu.createTabPanel()

    menu.createCategory(panel, {
        title = 'Выбор цвета',
        demo = createDemoButton('Открыть выбор цвета', function()
            Mantle.ui.color_picker(function(col)
                chat.AddText('Вы выбрали цвет: ', col, col)
            end, Color(25, 59, 102))
        end)
    })

    menu.createCategory(panel, {
        title = 'Контекстное меню',
        demo = createDemoButton('Открыть контекстное меню', function()
            local dermaMenu = Mantle.ui.derma_menu()
            for i = 1, 5 do
                dermaMenu:AddOption('Опция ' .. i, function()
                    chat.AddText('Привет всем! ' .. i)
                end)
            end
            dermaMenu:AddSpacer()
            dermaMenu:AddOption('Узнать свою привилегию', function()
                chat.AddText(LocalPlayer():GetUserGroup())
            end, 'icon16/status_online.png')

            local clothes = dermaMenu:AddOption('Одежда')
            local subClothes = clothes:AddSubMenu()
            subClothes:AddOption('Шапка', function()
                chat.AddText('Вы выбрали: Шапка')
            end)
            subClothes:AddOption('Свитер', function()
                chat.AddText('Вы выбрали: Свитер')
            end)
        end)
    })

    menu.createCategory(panel, {
        title = 'Выбор игрока',
        demo = createDemoButton('Открыть выбор игрока', function()
            Mantle.ui.player_selector(function(pl)
                chat.AddText('Вы выбрали игрока: ', color_white, pl:Name())
            end)
        end)
    })

    menu.createCategory(panel, {
        title = 'Радиальное меню',
        demo = createDemoButton('Открыть радиальное меню', function()
            local radialMenu = Mantle.ui.radial_menu()
            radialMenu:SetCenterText('Действия', 'Выберите действие')

            local weaponsMenu = radialMenu:CreateSubMenu('Оружие', 'Выберите оружие')
            weaponsMenu:AddOption('Пистолет', function()
                chat.AddText(Mantle.color.theme, 'Выбран пистолет')
            end, 'icon16/gun.png', 'Обычный пистолет')
            weaponsMenu:AddOption('Винтовка', function()
                chat.AddText(Mantle.color.theme, 'Выбрана винтовка')
            end, 'icon16/gun.png', 'Мощная винтовка')
            radialMenu:AddSubMenuOption('Оружие', weaponsMenu, 'icon16/gun.png', 'Выберите оружие')

            radialMenu:AddOption('Выбросить', function()
                chat.AddText('Выбросить оружие')
            end, 'icon16/gun.png', 'Выбросить оружие')
            radialMenu:AddOption('Кинуть кубик', function()
                chat.AddText('Действие выполнено')
            end, 'icon16/controller.png', 'Рандом кубика')
            radialMenu:AddOption('Погибнуть', function()
                chat.AddText('Действие выполнено')
            end, 'icon16/world.png', 'Попрощаться с миром')
            radialMenu:AddOption('Хакнуть', function()
                chat.AddText('Действие выполнено')
            end, 'icon16/server.png', 'Взломать сервер')
            radialMenu:AddOption('Посмотреть баланс', function()
                chat.AddText('Действие выполнено')
            end, 'icon16/money.png', 'Сколько у вас денег')
            radialMenu:AddOption('Нет иконки', function()
                chat.AddText('Действие выполнено')
            end, nil, 'Где иконка?')
        end)
    })

    menu.createCategory(panel, {
        title = 'Текстовое окно',
        demo = createDemoButton('Открыть текстовое окно', function()
            Mantle.ui.text_box('Заголовок', 'Описание того, что вводиться', function(text)
                chat.AddText('Вы ввели: ', color_white, text)
            end)
        end)
    })

    menu.createCategory(panel, {
        title = 'Уведомления',
        demo = createDemoButton('Показать уведомление', function()
            menu.notify('Тестовое сообщение!')
        end)
    })

    return panel
end

menu.registerTab('popups', {
    order = 3,
    title = 'Всплывающие окна',
    description = 'Список всплывающих элементов.',
    icon = Material('icon16/application_double.png'),
    build = build
})
