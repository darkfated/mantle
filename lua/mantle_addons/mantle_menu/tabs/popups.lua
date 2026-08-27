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

local function build(tab)
    local panel = Mantle.menu.createBanner(tab)
    local cat

    cat = vgui.Create('MantleCategory', panel)
    cat:Dock(TOP)
    cat:SetText('Выбор цвета')
    cat:SetActive(true)
    local btnColor = createDemoButton('Открыть выбор цвета', function()
        Mantle.ui.color_picker(function(col)
            chat.AddText('Вы выбрали цвет: ', col, col)
        end, Color(25, 59, 102))
    end)
    btnColor:DockMargin(8, 8, 8, 8)
    cat:AddItem(btnColor)

    cat = vgui.Create('MantleCategory', panel)
    cat:Dock(TOP)
    cat:SetText('Контекстное меню')
    cat:SetActive(true)
    local btnCtx = createDemoButton('Открыть контекстное меню', function()
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
    btnCtx:DockMargin(8, 8, 8, 8)
    cat:AddItem(btnCtx)

    cat = vgui.Create('MantleCategory', panel)
    cat:Dock(TOP)
    cat:SetText('Выбор игрока')
    cat:SetActive(true)
    local btnPlayer = createDemoButton('Открыть выбор игрока', function()
        Mantle.ui.player_selector(function(pl)
            chat.AddText('Вы выбрали игрока: ', color_white, pl:Name())
        end)
    end)
    btnPlayer:DockMargin(8, 8, 8, 8)
    cat:AddItem(btnPlayer)

    cat = vgui.Create('MantleCategory', panel)
    cat:Dock(TOP)
    cat:SetText('Радиальное меню')
    cat:SetActive(true)
    local btnRadial = createDemoButton('Открыть радиальное меню', function()
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
    btnRadial:DockMargin(8, 8, 8, 8)
    cat:AddItem(btnRadial)

    cat = vgui.Create('MantleCategory', panel)
    cat:Dock(TOP)
    cat:SetText('Текстовое окно')
    cat:SetActive(true)
    local btnTextBox = createDemoButton('Открыть текстовое окно', function()
        Mantle.ui.text_box('Заголовок', 'Описание того, что вводиться', function(text)
            chat.AddText('Вы ввели: ', color_white, text)
        end)
    end)
    btnTextBox:DockMargin(8, 8, 8, 8)
    cat:AddItem(btnTextBox)

    cat = vgui.Create('MantleCategory', panel)
    cat:Dock(TOP)
    cat:SetText('Уведомления')
    cat:SetActive(true)
    local btnNotify = createDemoButton('Показать уведомление', function()
        if IsValid(mantleMenu) then
            mantleMenu:Notify('Тестовое сообщение!')
        end
    end)
    btnNotify:DockMargin(8, 8, 8, 8)
    cat:AddItem(btnNotify)

    return panel
end

Mantle.menu.registerTab('popups', {
    order = 3,
    title = 'Всплывающие окна',
    description = 'Список всплывающих элементов.',
    icon = Material('icon16/application_double.png'),
    build = build
})
