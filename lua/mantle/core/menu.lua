local function CreateMenu()
    if IsValid(menuMantle) then
        menuMantle:Remove()
    end

    menuMantle = vgui.Create('MantleFrame')
    menuMantle:SetSize(700, 500)
    menuMantle:Center()
    menuMantle:MakePopup()
    menuMantle:SetTitle('Mantle')
    menuMantle:SetCenterTitle('Основное меню библиотеки')
    menuMantle:ShowAnimation()

    local tabs = vgui.Create('MantleTabs', menuMantle)
    tabs:Dock(FILL)

    local function CreateInfo(info, pan)
        local panelInfo = vgui.Create('Panel')
        panelInfo:Dock(TOP)
        panelInfo:SetTall(56)

        surface.SetFont('Fated.20')
        local infoWide = surface.GetTextSize(info[1]) + 16
        panelInfo.Paint = function(_, w, h)
            RNDX.Draw(0, 4, 0, w - 4, h, Mantle.color.panel_alpha[2])
            RNDX.Draw(16, 0, 0, infoWide, 30, Mantle.color.panel[1], RNDX.SHAPE_IOS)
            draw.SimpleText(info[1], 'Fated.20', 8, 4, color_white)
            draw.SimpleText(info[2], 'Fated.16', 12, 34, color_white)
        end

        pan:AddItem(panelInfo)
    end

    local function CreateCategory(name, info_table, pan, ui_element, is_active)
        local panel = vgui.Create('MantleCategory', pan)
        panel:Dock(TOP)
        panel:DockMargin(0, 0, 0, 6)
        panel:SetText(name)

        if is_active then
            panel:SetActive(true)
        end

        for _, info in ipairs(info_table) do
            CreateInfo(info, panel)
        end

        panel:AddItem(ui_element)
    end

    local function CreateTabElements()
        local panel = vgui.Create('MantleScrollPanel')
        local menuWide = menuMantle:GetWide()

        -- Кнопка
        local btn = vgui.Create('MantleBtn')
        btn:SetTxt('Click')
        btn:SetTall(40)
        btn:DockMargin(menuWide * 0.2, 6, menuWide * 0.2, 0)
        btn:Dock(TOP)
        btn:SetRipple(true)
        CreateCategory('Кнопка (MantleBtn)', {
            {':SetHover(bool is_hover)', 'Включить/выключить цвет наведения (дефолт - true)'},
            {':SetFont(string font)', 'Установить шрифт'},
            {':SetRadius(int rad)', 'Установить размер закругления'},
            {':SetIcon(string icon, int icon_size)', 'Установить иконку'},
            {':SetTxt(string text)', 'Установить текст'},
            {':SetColor(color col)', 'Установить цвет кнопки'},
            {':SetColorHover(color col)', 'Установить цвет наведения'},
            {':SetGradient(bool is_grad)', 'Включить/выключить градиент (дефолт - true)'},
            {':SetRipple(bool is_ripple)', 'Включить/выключить эффект волн (дефолт - false)'}
        }, panel, btn)

        -- Чекбокс
        local checkbox = vgui.Create('MantleCheckBox')
        checkbox:SetTxt('Отображение HUD')
        checkbox:SetConvar('cl_drawhud')
        checkbox:SetDescription('Показать информационный интерфейс')
        checkbox:DockMargin(menuWide * 0.1, 6, menuWide * 0.1, 0)
        checkbox:Dock(TOP)
        CreateCategory('Тумблер (MantleCheckBox)', {
            {':SetTxt(string text)', 'Установить текст'},
            {':SetValue(bool value)', 'Установить bool-значение тумблера'},
            {':GetBool()', 'Получить bool-значение тумблера'},
            {':SetConvar(string convar)', 'Установить ConVar'},
            {':SetDescription(string desc)', 'Установить описание для тумблера'}
        }, panel, checkbox)

        -- Ввод текста
        local entry = vgui.Create('MantleEntry')
        entry:SetTitle('Никнейм')
        entry:SetPlaceholder('darkf')
        entry:DockMargin(menuWide * 0.15, 6, menuWide * 0.15, 0)
        entry:Dock(TOP)
        CreateCategory('Ввод текста (MantleEntry)', {
            {':SetTitle(string text)', 'Установить заголовок'},
            {':SetPlaceholder(string text)', 'Установить фоновый текст (появляется при пустом поле)'},
            {':GetValue()', 'Получить string-значение поля'}
        }, panel, entry)

        -- Окно
        local btnFrame = vgui.Create('MantleBtn')
        btnFrame:SetTxt('Открыть окно')
        btnFrame:SetTall(40)
        btnFrame:DockMargin(menuWide * 0.2, 6, menuWide * 0.2, 0)
        btnFrame:Dock(TOP)
        btnFrame.DoClick = function()
            local frame = vgui.Create('MantleFrame')
            frame:SetSize(400, 300)
            frame:Center()
            frame:MakePopup()
            frame:SetCenterTitle('Центр')
        end
        CreateCategory('Окно (MantleFrame)', {
            {':SetAlphaBackground(bool is_alpha)', 'Включить/выключить прозрачность окна (дефолт - false)'},
            {':SetTitle(string title)', 'Установить заголовок'},
            {':SetCenterTitle(string title)', 'Установить центральный заголовок'},
            {':ShowAnimation()', 'Активировать анимацию при появлении меню'},
            {':DisableCloseBtn()', 'Скрыть кнопку закрытия'},
            {':SetDraggable(bool is_draggable)', 'Включить/выключить перемещение окна'}
        }, panel, btnFrame)

        -- ScrollPanel
        local sp = vgui.Create('MantleScrollPanel')
        sp:SetTall(120)
        for spK = 1, 5 do
            local spPanel = vgui.Create('DPanel', sp)
            spPanel:Dock(TOP)
            spPanel:DockMargin(0, 0, 6, 6)
            spPanel:SetTall(24)
            spPanel.Paint = function(_, w, h)
                RNDX.Draw(16, 0, 0, w - 12, h, Mantle.color.panel_alpha[1], RNDX.SHAPE_IOS)
            end
        end
        sp:DockMargin(menuWide * 0.11, 6, menuWide * 0.11, 0)
        sp:Dock(TOP)
        CreateCategory('Панель прокрутки (MantleScrollPanel)', {}, panel, sp)

        -- Вкладки
        local panelTabs = vgui.Create('DPanel')
        panelTabs:Dock(TOP)
        panelTabs:SetTall(200)
        panelTabs.Paint = nil

        local testTabs = vgui.Create('MantleTabs', panelTabs) -- modern стиль
        testTabs:SetTall(90)
        testTabs:DockMargin(menuWide * 0.05, 6, menuWide * 0.05, 0)
        testTabs:Dock(TOP)
        local testTab1 = vgui.Create('DPanel')
        testTab1.Paint = function(_, w, h)
            RNDX.Draw(16, 0, 0, w - 12, h, Color(53, 98, 40), RNDX.SHAPE_IOS)
        end
        testTabs:AddTab('Test1', testTab1)
        local testTab2 = vgui.Create('DPanel')
        testTab2.Paint = function(_, w, h)
            RNDX.Draw(16, 0, 0, w - 12, h, Color(108, 41, 45), RNDX.SHAPE_IOS)
        end
        testTabs:AddTab('Test2', testTab2)

        local testTabs2 = vgui.Create('MantleTabs', panelTabs) -- classic стиль
        testTabs2:SetTall(90)
        testTabs2:DockMargin(menuWide * 0.05, 10, menuWide * 0.05, 0)
        testTabs2:Dock(TOP)
        testTabs2:SetTabStyle('classic')
        local testTab3 = vgui.Create('DPanel')
        testTab3.Paint = function(_, w, h)
            RNDX.Draw(16, 0, 0, w - 12, h, Color(51, 61, 116), RNDX.SHAPE_IOS)
        end
        testTabs2:AddTab('Test3', testTab3)
        local testTab4 = vgui.Create('DPanel')
        testTab4.Paint = function(_, w, h)
            RNDX.Draw(16, 0, 0, w - 12, h, Color(138, 89, 43), RNDX.SHAPE_IOS)
        end
        testTabs2:AddTab('Test4', testTab4)

        CreateCategory('Вкладки (MantleTabs)', {
            {':SetTabStyle(string style)', 'Установить стиль вкладок (modern или classic)'},
            {':SetTabHeight(int height)', 'Установить высоту вкладок'},
            {':SetIndicatorHeight(int height)', 'Установить высоту индикатора вкладок'},
            {':AddTab(string name, object panel, string icon)', 'Добавить вкладку'}
        }, panel, panelTabs)

        -- Категория
        local panelCat = vgui.Create('Panel')
        panelCat:Dock(TOP)
        panelCat:DockMargin(0, 6, 0, 0)
        panelCat:SetTall(142)
        panelCat.Paint = nil

        local cat = vgui.Create('MantleCategory', panelCat)
        cat:Dock(TOP)
        cat:SetCenterText(true)
        cat:SetActive(true)
        local panGreen = vgui.Create('DPanel')
        panGreen:Dock(TOP)
        panGreen:SetTall(50)
        panGreen.Paint = function(_, w, h)
            RNDX.Draw(16, 0, 0, w - 12, h, Color(93, 179, 101), RNDX.SHAPE_IOS)
        end
        cat:AddItem(panGreen)
        local panRed = vgui.Create('DPanel')
        panRed:Dock(TOP)
        panRed:DockMargin(0, 6, 0, 0)
        panRed:SetTall(50)
        panRed.Paint = function(_, w, h)
            RNDX.Draw(16, 0, 0, w - 12, h, Color(179, 110, 93), RNDX.SHAPE_IOS)
        end
        cat:AddItem(panRed)
        CreateCategory('Категория (MantleCategory)', {
            {':SetText(string name)', 'Установить название'},
            {':AddItem(object panel)', 'Добавить в категорию элемент'},
            {':SetColor(color col)', 'Установить кастомный цвет категории'},
            {':SetCenterText(bool is_centered)', 'Установить центрирование названия'},
            {':SetActive(bool is_active)', 'Установить активность категории (дефолт - false)'}
        }, panel, panelCat)

        -- Слайдер
        local slider = vgui.Create('MantleSlideBox')
        slider:SetRange(0, 4)
        slider:SetConvar('net_graph')
        slider:SetText('График')
        slider:DockMargin(menuWide * 0.2, 6, menuWide * 0.2, 0)
        slider:Dock(TOP)
        CreateCategory('Слайдер (MantleSlideBox)', {
            {':SetRange(int min_value, int max_value, int decimals)', 'Сделать диапазон слайдера с точностью (дефолт точность - 0)'},
            {':SetConvar(string convar)', 'Установить ConVar'},
            {':SetText(string text)', 'Установить текстовое обозначение'},
            {':SetValue(string val)', 'Установить значение'},
            {':GetValue()', 'Получить выбранное значение (число)'},
        }, panel, slider)

        -- Выбор варианта
        local combo = vgui.Create('MantleComboBox')
        combo:SetPlaceholder('Выберите вариант')
        combo:AddChoice('Вариант 1', 'value1')
        combo:AddChoice('Вариант 2', 'value2')
        combo:AddChoice('Вариант 3', 'value3')
        combo:AddChoice('Вариант 4', 'value4')
        combo:AddChoice('Вариант 5', 'value5')
        combo:AddChoice('Вариант 6', 'value6')
        combo:AddChoice('Вариант 7', 'value7')
        combo:AddChoice('Вариант 8', 'value8')
        combo.OnSelect = function(idx, text, data)
            chat.AddText(color_white, 'Вы выбрали: ', Mantle.color.theme, text, color_white, ' (', tostring(data), ')')
        end
        combo:DockMargin(menuWide * 0.2, 6, menuWide * 0.2, 0)
        combo:Dock(TOP)
        CreateCategory('Выпадающий список (MantleComboBox)', {
            {':AddChoice(string text, any data)', 'Добавить вариант в список (data — любое значение, связанное с пунктом)'},
            {':SetValue(string text)', 'Установить выбранное значение по тексту'},
            {':GetValue()', 'Получить выбранное значение (текст)'},
            {':SetPlaceholder(string text)', 'Установить текст-заполнитель (placeholder)'},
            {':OnSelect(idx, text, data)', 'Вызывается при выборе варианта: idx — индекс, text — текст, data — значение'}
        }, panel, combo)

        -- Таблица
        local tableExample = vgui.Create('MantleTable')
        tableExample:Dock(TOP)
        tableExample:DockMargin(menuWide * 0.1, 6, menuWide * 0.1, 0)
        tableExample:SetTall(250)

        tableExample:AddColumn('Название', 200, TEXT_ALIGN_LEFT, true)
        tableExample:AddColumn('Тип', 120, TEXT_ALIGN_CENTER, true)
        tableExample:AddColumn('Качество', 100, TEXT_ALIGN_CENTER, true)
        tableExample:AddColumn('Цена', 110, TEXT_ALIGN_RIGHT, true)

        local products = {
            {'Молоко "Домик в деревне"', 'Молочка', 'Высшее', 89},
            {'Хлеб "Бородинский"', 'Выпечка', 'Стандарт', 45},
            {'Сок "Добрый"', 'Напитки', 'Премиум', 120},
            {'Шоколад "Аленка"', 'Конфеты', 'Высшее', 95},
            {'Йогурт "Активиа"', 'Молочка', 'Премиум', 65},
            {'Пельмени "Сибирские"', 'Заморозка', 'Стандарт', 350},
            {'Колбаса "Докторская"', 'Мясо', 'Высшее', 450},
            {'Сыр "Российский"', 'Молочка', 'Стандарт', 380},
            {'Пицца "Пепперони"', 'Заморозка', 'Премиум', 450},
            {'Чай "Липтон"', 'Напитки', 'Стандарт', 180},
            {'Печенье "Юбилейное"', 'Выпечка', 'Стандарт', 85},
            {'Масло "Крестьянское"', 'Молочка', 'Высшее', 120},
            {'Сметана "Простоквашино"', 'Молочка', 'Стандарт', 65},
            {'Курица "Бройлер"', 'Мясо', 'Стандарт', 280},
            {'Рыба "Минтай"', 'Морепродукты', 'Стандарт', 320},
            {'Яблоки "Голден"', 'Фрукты', 'Высшее', 180},
            {'Картофель', 'Овощи', 'Стандарт', 45},
            {'Морковь', 'Овощи', 'Стандарт', 35},
            {'Бананы', 'Фрукты', 'Стандарт', 120},
            {'Апельсины', 'Фрукты', 'Премиум', 180}
        }

        for _, product in ipairs(products) do
            tableExample:AddItem(unpack(product))
        end
        
        tableExample:SetAction(function(row_data)
            chat.AddText(color_white, 'Выбран продукт: ', Mantle.color.theme, row_data[1], color_white, ' (', row_data[2], ')')
        end)

        CreateCategory('Таблица (MantleTable)', {
            {':AddColumn(string name, number width, number align, bool sortable)', 'Добавить колонку'},
            {':AddItem(...)', 'Добавить строку. Количество аргументов должно соответствовать количеству колонок'},
            {':SetAction(function(table row_data))', 'Установить функцию, вызываемую при клике на строку. row_data — массив значений строки'},
            {':SetRightClickAction(function(table row_data))', 'Установить функцию, вызываемую при правом клике на строку'},
            {':Clear()', 'Очистить таблицу от всех строк'},
            {':GetSelectedRow()', 'Получить данные выбранной строки (массив значений)'},
            {':GetRowCount()', 'Получить количество строк в таблице'},
            {':RemoveRow(number index)', 'Удалить строку по индексу (начиная с 1)'}
        }, panel, tableExample)

        return panel
    end

    tabs:AddTab('UI Элементы', CreateTabElements(), Material('icon16/chart_pie.png'))

    local function CreateShowMenus()
        local panel = vgui.Create('MantleScrollPanel')
        
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
            end}
        }

        for _, elem in ipairs(listMenus) do
            local btn = vgui.Create('MantleBtn', panel)
            btn:Dock(TOP)
            btn:DockMargin(0, 0, 0, 6)
            btn:SetTall(30)
            btn:SetTxt(elem[1])
            btn.DoClick = function()
                elem[2]()

                Mantle.func.sound()
            end
        end

        return panel
    end

    tabs:AddTab('Всплывающие', CreateShowMenus(), Material('icon16/application_double.png'))

    local function CreateLegacyTest()
        local panel = vgui.Create('MantleScrollPanel')
        local menuWide = menuMantle:GetWide()

        local btnFrame = vgui.Create('MantleBtn')
        btnFrame:SetTxt('Открыть Legacy Frame')
        btnFrame:SetTall(40)
        btnFrame:DockMargin(menuWide * 0.2, 6, menuWide * 0.2, 0)
        btnFrame:Dock(TOP)
        btnFrame.DoClick = function()
            local frame = vgui.Create('DFrame')
            frame:SetSize(400, 300)
            frame:Center()
            frame:MakePopup()
            Mantle.ui.frame(frame, 'Legacy Frame', 400, 300, true, true)
            
            local scroll = vgui.Create('DScrollPanel', frame)
            scroll:Dock(FILL)
            Mantle.ui.sp(scroll)
            
            -- Тест кнопок с разными параметрами
            local btn1 = vgui.Create('DButton', scroll)
            btn1:Dock(TOP)
            btn1:DockMargin(10, 10, 10, 0)
            btn1:SetText('Обычная кнопка')
            Mantle.ui.btn(btn1)
            
            local btn2 = vgui.Create('DButton', scroll)
            btn2:Dock(TOP)
            btn2:DockMargin(10, 10, 10, 0)
            btn2:SetText('Кнопка с иконкой')
            Mantle.ui.btn(btn2, Material('icon16/accept.png'), 16)
            
            local btn3 = vgui.Create('DButton', scroll)
            btn3:Dock(TOP)
            btn3:DockMargin(10, 10, 10, 0)
            btn3:SetText('Кнопка без градиента')
            Mantle.ui.btn(btn3, nil, nil, nil, nil, true)
            
            local btn4 = vgui.Create('DButton', scroll)
            btn4:Dock(TOP)
            btn4:DockMargin(10, 10, 10, 0)
            btn4:SetText('Кнопка без ховера')
            Mantle.ui.btn(btn4, nil, nil, nil, nil, nil, nil, true)
            
            -- Тест слайдеров
            local slider1 = Mantle.ui.slidebox(scroll, 'Слайдер (0-100)', 0, 100, 'net_graph', 0)
            slider1:DockMargin(10, 20, 10, 0)
            
            local slider2 = Mantle.ui.slidebox(scroll, 'Слайдер (0-1)', 0, 1, 'cl_drawhud', 2)
            slider2:DockMargin(10, 20, 10, 0)
            
            -- Тест полей ввода
            local entry1, entry_bg1 = Mantle.ui.desc_entry(scroll, 'Поле с заголовком', 'Введите текст...')
            entry_bg1:DockMargin(10, 20, 10, 0)
            
            local entry2, entry_bg2 = Mantle.ui.desc_entry(scroll, nil, 'Поле без заголовка')
            entry_bg2:DockMargin(10, 20, 10, 0)
            
            -- Тест чекбоксов
            local checkbox1, checkbox_btn1 = Mantle.ui.checkbox(scroll, 'Чекбокс с ConVar', 'cl_drawhud')
            checkbox1:DockMargin(10, 20, 10, 0)
            
            local checkbox2, checkbox_btn2 = Mantle.ui.checkbox(scroll, 'Чекбокс без ConVar')
            checkbox2:DockMargin(10, 20, 10, 0)
            
            -- Тест вкладок
            local panelTabs = vgui.Create('DPanel', scroll)
            panelTabs:Dock(TOP)
            panelTabs:SetTall(250)
            panelTabs.Paint = nil

            local tabs = Mantle.ui.panel_tabs(panelTabs)
            tabs:DockMargin(10, 20, 10, 0)
            
            -- Добавляем вкладки с разными стилями
            local tab1 = vgui.Create('DPanel')
            tab1.Paint = function(_, w, h)
                draw.SimpleText('Вкладка 1', 'Fated.20', w/2, h/2, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            end
            tabs:AddTab('Вкладка 1', tab1, 'icon16/page_white.png')
            
            local tab2 = vgui.Create('DPanel')
            tab2.Paint = function(_, w, h)
                draw.SimpleText('Вкладка 2', 'Fated.20', w/2, h/2, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            end
            tabs:AddTab('Вкладка 2', tab2, 'icon16/page_white_edit.png', Color(100, 200, 100))
            
            local tab3 = vgui.Create('DPanel')
            tab3.Paint = function(_, w, h)
                draw.SimpleText('Вкладка 3', 'Fated.20', w/2, h/2, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            end
            tabs:AddTab('Вкладка 3', tab3, 'icon16/page_white_gear.png', nil, Color(200, 100, 100))
            
            tabs:ActiveTab('Вкладка 1')
        end
        CreateCategory('Legacy Frame (не стоит использовать)', {
            {'Mantle.ui.frame(frame, title, width, height, close_bool, anim_bool)', 'Создание окна с кастомным стилем'},
            {'Mantle.ui.sp(scroll)', 'Стилизация скролл панели'},
            {'Mantle.ui.btn(btn, icon, icon_size, btn_color, btn_radius, off_grad_bool, btn_color_hov, off_hov_bool)', 'Стилизация кнопки'},
            {'Mantle.ui.slidebox(parent, label, min_value, max_value, slide_convar, decimals)', 'Создание слайдера'},
            {'Mantle.ui.desc_entry(parent, title, placeholder, bool_title_off)', 'Создание поля ввода'},
            {'Mantle.ui.checkbox(parent, text, convar)', 'Создание чекбокса'},
            {'Mantle.ui.panel_tabs(parent)', 'Создание панели с вкладками'}
        }, panel, btnFrame, true)

        return panel
    end

    tabs:AddTab('Legacy UI', CreateLegacyTest(), Material('icon16/exclamation.png'))

    local function CreateSettings()
        local panel = vgui.Create('MantleScrollPanel')
        local menuWide = menuMantle:GetWide()

        local checkboxDepth = vgui.Create('MantleCheckBox', panel)
        checkboxDepth:Dock(TOP)
        checkboxDepth:SetTxt('Глубины элементов')
        checkboxDepth:SetConvar('mantle_depth_ui')

        return panel
    end

    tabs:AddTab('Настройки', CreateSettings(), Material('icon16/cog.png'))
end

concommand.Add('mantle_menu', CreateMenu)
