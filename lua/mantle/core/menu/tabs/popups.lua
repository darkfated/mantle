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
    local panel = menu.createTabPanel('Всплывающие', 'Показ панелей, открывающихся поверх меню.', icon)

    menu.createCategory('Палитра цвета', {
        {'Mantle.ui.color_picker(func callback, color default_color)', 'Окно выбора цвета: поле HSB, слайдер тона и ручной ввод RGB. Выбранный цвет приходит в callback(col)'}
    }, panel, createDemoButton('Открыть палитру', function()
        Mantle.ui.color_picker(function(col)
            chat.AddText('Вы выбрали цвет: ', col, col)
        end, Color(25, 59, 102))
    end), true)

    menu.createCategory('Контекстное меню (MantleDermaMenu)', {
        {'Mantle.ui.derma_menu()', 'Контекстное меню в позиции курсора'},
        {':AddOption(string text, func callback, string|material icon)', 'Добавить пункт. Возвращает объект пункта для дальнейших действий'},
        {':AddSpacer()', 'Визуальный разделитель между пунктами'},
        {'option:AddSubMenu()', 'Вложенное подменю для конкретного пункта'},
        {':CloseMenu()', 'Плавно закрыть меню'}
    }, panel, createDemoButton('Открыть контекстное меню', function()
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
        {'Mantle.ui.player_selector(func onSelect, func filter)', 'Окно со списком игроков и поиском. Выбранный игрок приходит в onSelect(ply)'},
        {'filter(player pl)', 'Фильтр показа: если вернуть false - игрок не появится в списке'}
    }, panel, createDemoButton('Открыть список игроков', function()
        Mantle.ui.player_selector(function(pl)
            chat.AddText('Вы выбрали игрока: ', color_white, pl:Name())
        end)
    end))

    menu.createCategory('Круговое меню', {
        {'Mantle.ui.radial_menu(table options)', 'Круговое меню в центре экрана. В options можно задать radius, inner_radius, title, desc, шрифты и длительность анимаций'},
        {':SetCenterText(string title, string desc)', 'Заголовок и описание в центре меню'},
        {':AddOption(string text, func callback, string icon, string desc)', 'Обычный пункт-кнопка'},
        {':CreateSubMenu(string title, string desc)', 'Создать подменю (таблица с методом :AddOption)'},
        {'submenu:AddOption(string text, func callback, string icon, string desc)', 'Пункт внутри подменю'},
        {':AddSubMenuOption(string text, table submenu, string icon, string desc)', 'Кнопка перехода в подменю'},
        {':GetCurrentOptions()', 'Текущий список опций (активное меню или подменю)'},
        {':GoBack()', 'Вернуться назад по стеку подменю'},
        {':CloseMenu(func callback)', 'Закрыть меню (callback вызовется после закрытия)'},
        {'Управление', '1-9 - выбор пункта, ESC - закрыть, клик в центр - назад, клик вне круга - закрыть'}
    }, panel, createDemoButton('Открыть круговое меню', function()
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
        {'Mantle.ui.text_box(string title, string desc, func callback)', 'Окно ввода: заголовок, описание и поле. Введённая строка приходит в callback(text)'}
    }, panel, createDemoButton('Открыть текстовый ввод', function()
        Mantle.ui.text_box('Заголовок', 'Описание того, что вводиться', function(text)
            chat.AddText('Вы ввели: ', color_white, text)
        end)
    end))

    menu.createCategory('Уведомление в MantleFrame', {
        {'frame:Notify(string text, number duration, color col)', 'Уведомление снизу окна. frame - ваша переменная от MantleFrame'}
    }, panel, createDemoButton('Показать уведомление', function()
        menu.notify('Тестовое сообщение!')
    end))

    return panel
end

menu.registerTab('popups', {
    order = 2,
    title = 'Всплывающие',
    description = 'Показ панелей, открывающихся поверх меню.',
    icon = icon,
    create = createPopupTab
})
