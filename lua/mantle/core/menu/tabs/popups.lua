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

local function build()
    local panel = menu.createTabPanel()

    menu.createCategory(panel, {
        title = 'Палитра цвета',
        open = true,
        rows = {
            { name = 'Mantle.ui.color_picker(func callback, color default_color)', desc = 'Окно выбора цвета. Выбранный цвет приходит в callback(col)' }
        },
        demo = createDemoButton('Открыть палитру', function()
            Mantle.ui.color_picker(function(col)
                chat.AddText('Вы выбрали цвет: ', col, col)
            end, Color(25, 59, 102))
        end)
    })

    menu.createCategory(panel, {
        title = 'Контекстное меню (MantleDermaMenu)',
        rows = {
            { name = 'Mantle.ui.derma_menu()', desc = 'Контекстное меню в позиции курсора' },
            { name = ':AddOption(string text, func callback, string|material icon)', desc = 'Добавить пункт. Возвращает объект пункта для дальнейших действий' },
            { name = ':AddSpacer()', desc = 'Визуальный разделитель между пунктами' },
            { name = 'option:AddSubMenu()', desc = 'Вложенное подменю для конкретного пункта' },
            { name = ':CloseMenu()', desc = 'Плавно закрыть меню' }
        },
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
        rows = {
            { name = 'Mantle.ui.player_selector(func onSelect, func filter)', desc = 'Окно со списком игроков. Выбранный игрок приходит в onSelect(ply)' },
            { name = 'filter(player pl)', desc = 'Фильтр показа: если вернуть false - игрок не появится в списке' }
        },
        demo = createDemoButton('Открыть список игроков', function()
            Mantle.ui.player_selector(function(pl)
                chat.AddText('Вы выбрали игрока: ', color_white, pl:Name())
            end)
        end)
    })

    menu.createCategory(panel, {
        title = 'Круговое меню',
        rows = {
            { name = 'Mantle.ui.radial_menu(table options)', desc = 'Круговое меню в центре экрана. В options можно задать radius, inner_radius, title, desc, шрифты и длительность анимаций' },
            { name = ':SetCenterText(string title, string desc)', desc = 'Заголовок и описание в центре меню' },
            { name = ':AddOption(string text, func callback, string icon, string desc)', desc = 'Обычный пункт-кнопка' },
            { name = ':CreateSubMenu(string title, string desc)', desc = 'Создать подменю (таблица с методом :AddOption)' },
            { name = 'submenu:AddOption(string text, func callback, string icon, string desc)', desc = 'Пункт внутри подменю' },
            { name = ':AddSubMenuOption(string text, table submenu, string icon, string desc)', desc = 'Кнопка перехода в подменю' },
            { name = ':GetCurrentOptions()', desc = 'Текущий список опций (активное меню или подменю)' },
            { name = ':GoBack()', desc = 'Вернуться назад по стеку подменю' },
            { name = ':CloseMenu(func callback)', desc = 'Закрыть меню (callback вызовется после закрытия)' },
            { name = 'Управление', desc = '1-9 - выбор пункта, ESC - закрыть, клик в центр - назад, клик вне круга - закрыть' }
        },
        demo = createDemoButton('Открыть круговое меню', function()
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
        title = 'Текстовый ввод',
        rows = {
            { name = 'Mantle.ui.text_box(string title, string desc, func callback)', desc = 'Окно ввода. Введённая строка приходит в callback(text)' }
        },
        demo = createDemoButton('Открыть текстовый ввод', function()
            Mantle.ui.text_box('Заголовок', 'Описание того, что вводиться', function(text)
                chat.AddText('Вы ввели: ', color_white, text)
            end)
        end)
    })

    menu.createCategory(panel, {
        title = 'Уведомление в MantleFrame',
        rows = {
            { name = 'frame:Notify(string text, number duration, color col)', desc = 'Уведомление снизу окна. frame - ваша переменная от MantleFrame' }
        },
        demo = createDemoButton('Показать уведомление', function()
            menu.notify('Тестовое сообщение!')
        end)
    })

    return panel
end

menu.registerTab('popups', {
    order = 2,
    title = 'Всплывающие',
    description = 'Показ панелей, открывающихся поверх меню.',
    icon = icon,
    build = build
})
