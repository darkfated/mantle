local menu = Mantle.menu

local icon = Material('icon16/application_double.png')

local function createDemoButton(text, callback)
    local button = vgui.Create('MantleBtn')
    button:Dock(TOP)
    button:DockMargin(0, 6, 0, 0)
    button:SetTall(30)
    button:SetTxt(text)
    button.DoClick = function()
        callback()
        Mantle.func.sound()
    end

    return button
end

local function createPopupTab()
    local panel = menu.createTabPanel('Всплывающие', 'Палитра, derma-меню, radial и другие утилиты.', icon)

    menu.createCategory('Палитра цвета', {
        {'Mantle.ui.color_picker(func callback, color default_color)', 'Открывает окно выбора цвета и возвращает Color в callback'}
    }, panel, createDemoButton('Открыть палитру', function()
        Mantle.ui.color_picker(function(col)
            chat.AddText('Вы выбрали цвет: ', col, tostring(col))
        end, Color(25, 59, 102))
    end), true)

    menu.createCategory('Контекстное меню (MantleDermaMenu)', {
        {'Mantle.ui.derma_menu()', 'Создаёт контекстное меню в позиции курсора'},
        {':AddOption(string text, func callback, string|IMaterial icon)', 'Добавляет обычную опцию в меню'},
        {':AddSpacer()', 'Добавляет визуальный разделитель'},
        {'option:AddSubMenu()', 'Создаёт вложенное подменю для конкретной опции'},
        {':CloseMenu()', 'Плавно закрывает меню'}
    }, panel, createDemoButton('Открыть derma-меню', function()
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
    end))

    menu.createCategory('Выбор игрока', {
        {'Mantle.ui.player_selector(func onSelect, func filter)', 'Открывает список игроков и передаёт выбранного игрока в callback'},
        {'filter(player pl)', 'Если функция вернёт false, игрок не попадёт в список'}
    }, panel, createDemoButton('Открыть список игроков', function()
        Mantle.ui.player_selector(function(pl)
            chat.AddText('Вы выбрали игрока: ', color_white, pl:Name())
        end)
    end))

    menu.createCategory('Радиальное меню', {
        {'Mantle.ui.radial_menu(table options)', 'Создаёт круговое меню действий в центре экрана'},
        {':SetCenterText(string title, string desc)', 'Меняет центральный заголовок и описание'},
        {':CreateSubMenu(string title, string desc)', 'Создаёт таблицу подменю'},
        {'submenu:AddOption(string text, func callback, string icon, string desc)', 'Добавляет опцию в подменю'},
        {':AddSubMenuOption(string text, table submenu, string icon, string desc)', 'Добавляет в радиальное меню кнопку перехода в подменю'},
        {':AddOption(string text, func callback, string icon, string desc)', 'Добавляет обычную опцию в текущее меню'},
        {':GetCurrentOptions()', 'Возвращает текущий активный список опций'},
        {':GoBack()', 'Возвращает назад по стеку подменю'}
    }, panel, createDemoButton('Открыть радиальное меню', function()
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
    end))

    menu.createCategory('Текстовый ввод', {
        {'Mantle.ui.text_box(string title, string desc, func callback)', 'Открывает окно ввода текста и возвращает строку в callback'}
    }, panel, createDemoButton('Открыть text-box', function()
        Mantle.ui.text_box('Заголовок', 'Описание того, что вводиться', function(text)
            chat.AddText('Вы ввели: ', color_white, text)
        end)
    end))

    menu.createCategory('Уведомление внутри окна', {
        {'MantleFrame:Notify(string text, number duration, color col)', 'Показывает уведомление внизу активного окна MantleFrame'}
    }, panel, createDemoButton('Показать уведомление', function()
        menu.notify('Тестовое сообщение!')
    end))

    return panel
end

menu.registerTab('popups', {
    order = 2,
    title = 'Всплывающие',
    description = 'Палитра, derma-меню, radial и другие утилиты',
    icon = icon,
    create = createPopupTab
})
