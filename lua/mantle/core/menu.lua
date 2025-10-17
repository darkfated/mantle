local function CreateMenu()
    if IsValid(menuMantle) then
        menuMantle:Remove()
    end

    menuMantle = vgui.Create('MantleFrame')
    menuMantle:SetSize(920, 640)
    menuMantle:Center()
    menuMantle:MakePopup()
    menuMantle:SetTitle('Mantle')
    menuMantle:SetCenterTitle('Основное меню библиотеки')
    menuMantle:ShowAnimation()

    local tabs = vgui.Create('MantleTabs', menuMantle)
    tabs:Dock(FILL)

    local function CreateTabHeader(title, subtitle, icon, pan)
        local header = vgui.Create('Panel', pan)
        header:Dock(TOP)
        header:DockMargin(0, 0, 0, 8)
        header:SetTall(56)

        header.Paint = function(_, w, h)
            RNDX().Rect(0, 0, w, h)
                :Rad(8)
                :Color(Mantle.color.panel_alpha[2])
            :Draw()

            RNDX().Rect(12, h * 0.5 - 12, 24, 24)
                :Color(255, 255, 255)
                :Material(icon)
            :Draw()

            draw.SimpleText(title, 'Fated.20', 48, 10, Mantle.color.text)
            draw.SimpleText(subtitle, 'Fated.16', 48, h - 10, Mantle.color.gray, TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM)
        end

        return header
    end

    local function CreateCopyButton(parent, snippet)
        local b = vgui.Create('DButton', parent)
        b:SetText('')
        b:SetWide(110)
        b.Paint = function(me, w, h)
            RNDX().Rect(0, 0, w, h)
                :Rad(6)
                :Color(Mantle.color.panel_alpha[1])
            :Draw()

            draw.SimpleText('Скопировать', 'Fated.16', w / 2, h / 2, Mantle.color.text, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end
        b.DoClick = function()
            SetClipboardText(snippet)
            menuMantle:Notify(snippet)
            Mantle.func.sound()
        end
        return b
    end

    local function CreateInfo(info, pan)
        local panelInfo = vgui.Create('Panel')
        panelInfo:Dock(TOP)
        panelInfo:DockMargin(0, 0, 0, 6)
        panelInfo:SetTall(50)

        panelInfo.Paint = function(_, w, h)
            RNDX().Rect(0, 0, w, h)
                :Rad(6)
                :Color(Mantle.color.panel_alpha[2])
            :Draw()

            Mantle.func.gradient(0, 0, 6, h, 3, Mantle.color.theme, 6)

            draw.SimpleText(info[1], 'Fated.20', 16, 7, Mantle.color.text)
            draw.SimpleText(info[2], 'Fated.16', 16, h - 7, Mantle.color.gray, TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM)
        end

        local copyBtn = CreateCopyButton(panelInfo, info[1])
        copyBtn:Dock(RIGHT)
        copyBtn:DockMargin(0, 10, 10, 10)

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

        if ui_element then
            panel:AddItem(ui_element)
        end
    end

    local function CreateTabElements()
        local panel = vgui.Create('MantleScrollPanel')
        CreateTabHeader('UI Элементы', 'Демонстрация всех компонентов Mantle. Клик по элементу открывает пример.', Material('icon16/chart_pie.png'), panel)

        local menuWide = menuMantle:GetWide()

        -- Кнопка
        local panelBtns = vgui.Create('Panel')
        panelBtns:Dock(TOP)
        panelBtns:DockMargin(menuWide * 0.3, 6, menuWide * 0.3, 0)
        panelBtns:SetTall(132)

        local btn1 = vgui.Create('MantleBtn', panelBtns)
        btn1:Dock(TOP)
        btn1:SetTall(40)
        btn1:SetTxt('Стандартная кнопка')

        local btn2 = vgui.Create('MantleBtn', panelBtns)
        btn2:Dock(TOP)
        btn2:DockMargin(0, 6, 0, 0)
        btn2:SetTall(40)
        btn2:SetTxt('Эффект волны')
        btn2:SetRipple(true)

        local btn3 = vgui.Create('MantleBtn', panelBtns)
        btn3:Dock(TOP)
        btn3:DockMargin(0, 6, 0, 0)
        btn3:SetTall(40)
        btn3:SetTxt('Кастомный цвет')
        btn3:SetColor(Color(182, 65, 65))
        btn3:SetColorHover(Color(143, 57, 57))
        btn3:SetIcon(Material('icon16/delete.png'), 16)

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
        }, panel, panelBtns)

        -- Чекбокс
        local checkbox = vgui.Create('MantleCheckBox')
        checkbox:DockMargin(menuWide * 0.3, 6, menuWide * 0.3, 0)
        checkbox:Dock(TOP)
        checkbox:SetTxt('Отображение HUD')
        checkbox:SetConvar('cl_drawhud')
        CreateCategory('Тумблер (MantleCheckBox)', {
            {':SetTxt(string text)', 'Установить текст'},
            {':SetValue(bool value)', 'Установить bool-значение тумблера'},
            {':GetBool()', 'Получить bool-значение тумблера'},
            {':SetConvar(string convar)', 'Установить ConVar'},
            {':SetDescription(string desc)', 'Установить описание для тумблера'},
            {':OnChange(bool new_value)', 'Вызывается при изменении значения тумблера'}
        }, panel, checkbox)

        -- Ввод текста
        local entry = vgui.Create('MantleEntry')
        entry:Dock(TOP)
        entry:DockMargin(menuWide * 0.35, 6, menuWide * 0.35, 0)
        entry:SetTitle('Никнейм')
        entry:SetPlaceholder('darkf')
        CreateCategory('Ввод текста (MantleEntry)', {
            {':SetTitle(string text)', 'Установить заголовок'},
            {':SetPlaceholder(string text)', 'Установить фоновый текст (появляется при пустом поле)'},
            {':GetValue()', 'Получить string-значение поля'},
            {':SetValue(string value)', 'Установить значение полю'}
        }, panel, entry)

        -- Окно
        local panelFrames = vgui.Create('Panel')
        panelFrames:Dock(TOP)
        panelFrames:SetTall(92)

        local btnFrame1 = vgui.Create('MantleBtn', panelFrames)
        btnFrame1:Dock(TOP)
        btnFrame1:DockMargin(menuWide * 0.3, 6, menuWide * 0.3, 0)
        btnFrame1:SetTxt('Обычное окно')
        btnFrame1:SetTall(40)
        btnFrame1.DoClick = function()
            local frame = vgui.Create('MantleFrame')
            frame:SetSize(400, 300)
            frame:Center()
            frame:MakePopup()
            frame:SetCenterTitle('Центр')
        end

        local btnFrame2 = vgui.Create('MantleBtn', panelFrames)
        btnFrame2:Dock(TOP)
        btnFrame2:DockMargin(menuWide * 0.3, 6, menuWide * 0.3, 0)
        btnFrame2:SetTxt('Lite-режим')
        btnFrame2:SetTall(40)
        btnFrame2.DoClick = function()
            local frame = vgui.Create('MantleFrame')
            frame:SetSize(400, 300)
            frame:Center()
            frame:MakePopup()
            frame:LiteMode()
        end

        CreateCategory('Окно (MantleFrame)', {
            {':SetAlphaBackground(bool is_alpha)', 'Включить/выключить прозрачность окна (дефолт - false)'},
            {':SetTitle(string title)', 'Установить заголовок'},
            {':SetCenterTitle(string title)', 'Установить центральный заголовок'},
            {':ShowAnimation()', 'Активировать анимацию при появлении меню'},
            {':DisableCloseBtn()', 'Скрыть кнопку закрытия'},
            {':SetDraggable(bool is_draggable)', 'Включить/выключить перемещение окна'},
            {':LiteMode()', 'Активировать режим Lite (без верхней панели)'},
            {':Notify(string text, number duration, color col)', 'Показать уведомление внизу окна (дефолт времени - 2 сек., цвета - Mantle.color.theme)'}
        }, panel, panelFrames)

        -- ScrollPanel
        local sp = vgui.Create('MantleScrollPanel')
        sp:Dock(TOP)
        sp:DockMargin(menuWide * 0.3, 6, menuWide * 0.3, 0)
        sp:SetTall(150)
        for spK = 1, 10 do
            local spPanel = vgui.Create('DPanel', sp)
            spPanel:Dock(TOP)
            spPanel:DockMargin(0, 0, 0, 6)
            spPanel:SetTall(24)
            spPanel.Paint = function(_, w, h)
                RNDX().Rect(0, 0, w, h)
                    :Rad(16)
                    :Color(Mantle.color.panel_alpha[1])
                    :Shape(RNDX.SHAPE_IOS)
                :Draw()
            end
        end
        CreateCategory('Панель прокрутки (MantleScrollPanel)', {
            {':SetScroll(number offset)', 'Установить смещение прокрутки'},
            {':GetScroll()', 'Получить текущее смещение прокрутки'},
            {':AddItem(object panel)', 'Добавить элемент в панель'},
            {':Clear()', 'Очистить панель от всего'},
            {':DisableVBarPadding()', 'Отключить отступ справа для скроллбара (по умолчанию имеется)'}
        }, panel, sp)

        -- Вкладки
        local panelTabs = vgui.Create('Panel')
        panelTabs:Dock(TOP)
        panelTabs:SetTall(280)

        local testTabs = vgui.Create('MantleTabs', panelTabs) -- modern стиль
        testTabs:Dock(TOP)
        testTabs:DockMargin(menuWide * 0.3, 6, menuWide * 0.3, 0)
        testTabs:SetTall(150)
        local testTab1 = vgui.Create('DPanel')
        testTab1.Paint = function(_, w, h)
            RNDX().Rect(0, 0, w - 12, h)
                :Rad(16)
                :Color(53, 98, 40)
                :Shape(RNDX.SHAPE_IOS)
            :Draw()
        end
        testTabs:AddTab('Test1', testTab1)
        local testTab2 = vgui.Create('DPanel')
        testTab2.Paint = function(_, w, h)
            RNDX().Rect(0, 0, w - 12, h)
                :Rad(16)
                :Color(108, 41, 45)
                :Shape(RNDX.SHAPE_IOS)
            :Draw()
        end
        testTabs:AddTab('Test2', testTab2)

        local testTabs2 = vgui.Create('MantleTabs', panelTabs) -- classic стиль
        testTabs2:Dock(FILL)
        testTabs2:DockMargin(menuWide * 0.3, 10, menuWide * 0.3, 0)
        testTabs2:SetTabStyle('classic')
        local testTab3 = vgui.Create('DPanel')
        testTab3.Paint = function(_, w, h)
            RNDX().Rect(0, 0, w - 12, h)
                :Rad(16)
                :Color(51, 61, 116)
                :Shape(RNDX.SHAPE_IOS)
            :Draw()
        end
        testTabs2:AddTab('Test3', testTab3)
        local testTab4 = vgui.Create('DPanel')
        testTab4.Paint = function(_, w, h)
            RNDX().Rect(0, 0, w - 12, h)
                :Rad(16)
                :Color(138, 89, 43)
                :Shape(RNDX.SHAPE_IOS)
            :Draw()
        end
        testTabs2:AddTab('Test4', testTab4)
        local testTab5 = vgui.Create('DPanel')
        testTab5.Paint = function(_, w, h)
            RNDX().Rect(0, 0, w - 12, h)
                :Rad(16)
                :Color(43, 138, 133)
                :Shape(RNDX.SHAPE_IOS)
            :Draw()
        end
        testTabs2:AddTab('С иконкой', testTab5, Material('icon16/folder.png'))

        CreateCategory('Вкладки (MantleTabs)', {
            {':SetTabStyle(string style)', 'Установить стиль вкладок (modern или classic)'},
            {':SetTabHeight(int height)', 'Установить высоту вкладок'},
            {':SetIndicatorHeight(int height)', 'Установить высоту индикатора вкладок'},
            {':AddTab(string name, object panel, string icon)', 'Добавить вкладку'}
        }, panel, panelTabs)

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
        combo:DockMargin(menuWide * 0.3, 6, menuWide * 0.3, 0)
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
        tableExample:DockMargin(menuWide * 0.2, 6, menuWide * 0.2, 0)
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
            RNDX().Rect(0, 0, w - 12, h)
                :Rad(16)
                :Color(93, 179, 101)
                :Shape(RNDX.SHAPE_IOS)
            :Draw()
        end
        cat:AddItem(panGreen)
        local panRed = vgui.Create('DPanel')
        panRed:Dock(TOP)
        panRed:DockMargin(0, 6, 0, 0)
        panRed:SetTall(50)
        panRed.Paint = function(_, w, h)
            RNDX().Rect(0, 0, w - 12, h)
                :Rad(16)
                :Color(179, 110, 93)
                :Shape(RNDX.SHAPE_IOS)
            :Draw()
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
        slider:Dock(TOP)
        slider:DockMargin(menuWide * 0.3, 6, menuWide * 0.3, 0)
        slider:SetRange(0, 4)
        slider:SetConvar('net_graph')
        slider:SetText('График')
        CreateCategory('Слайдер (MantleSlideBox)', {
            {':SetRange(int min_value, int max_value, int decimals)', 'Сделать диапазон слайдера с точностью (дефолт точность - 0)'},
            {':SetConvar(string convar)', 'Установить ConVar'},
            {':SetText(string text)', 'Установить текстовое обозначение'},
            {':SetValue(string val)', 'Установить значение'},
            {':GetValue()', 'Получить выбранное значение (число)'},
            {':OnValueChanged(string new_value)', 'Вызывается при изменении значения слайдера'}
        }, panel, slider)

        local panelTexts = vgui.Create('Panel')
        panelTexts:Dock(TOP)
        panelTexts:DockMargin(menuWide * 0.3, 6, menuWide * 0.3, 0)
        panelTexts:DockPadding(8, 8, 8, 8)
        panelTexts:SetTall(344)
        panelTexts.Paint = function(_, w, h)
            RNDX().Rect(0, 0, w, h)
                :Rad(32)
                :Color(Mantle.color.panel_alpha[2])
                :Shape(RNDX.SHAPE_IOS)
            :Draw()
        end

        local panelText1 = vgui.Create('DPanel', panelTexts)
        panelText1:Dock(TOP)
        panelText1:DockMargin(0, 0, 0, 6)
        panelText1:SetTall(74)
        panelText1.Paint = function(_, w, h)
            RNDX().Rect(0, 0, w, h)
                :Rad(32)
                :Color(Mantle.color.panel_alpha[1])
                :Shape(RNDX.SHAPE_IOS)
            :Draw()
        end

        local text1 = vgui.Create('MantleText', panelText1)
        text1:Dock(FILL)
        text1:SetPadding(10)
        text1:SetText('MantleText — компонент для аккуратного вывода многострочного текста. Текст автоматически переносится по ширине и сокращается троеточием')

        local panelText2 = vgui.Create('DPanel', panelTexts)
        panelText2:Dock(TOP)
        panelText2:DockMargin(0, 0, 0, 6)
        panelText2:SetTall(100)
        panelText2.Paint = function(_, w, h)
            RNDX().Rect(0, 0, w, h)
                :Rad(32)
                :Color(Mantle.color.panel_alpha[1])
                :Shape(RNDX.SHAPE_IOS)
            :Draw()
        end

        local text2 = vgui.Create('MantleText', panelText2)
        text2:Dock(FILL)
        text2:SetPadding(12)
        text2:SetFont('Fated.20')
        text2:SetText('Центрирование: горизонталь + вертикаль. Текст выровнен по центру блока.')
        text2:SetAlign(TEXT_ALIGN_CENTER)
        text2:SetVAlign('center')

        local panelText3 = vgui.Create('DPanel', panelTexts)
        panelText3:Dock(TOP)
        panelText3:DockMargin(0, 0, 0, 6)
        panelText3:SetTall(54)
        panelText3.Paint = function(_, w, h)
            RNDX().Rect(0, 0, w, h)
                :Rad(32)
                :Color(Mantle.color.panel_alpha[1])
                :Shape(RNDX.SHAPE_IOS)
            :Draw()
        end

        local text3 = vgui.Create('MantleText', panelText3)
        text3:Dock(FILL)
        text3:SetPadding(8)
        text3:SetText('ОченьДлинноеСловоБезПробеловКотороеНужноОтделитьЧтобыНеПорвалосьОформление')

        local panelText4 = vgui.Create('DPanel', panelTexts)
        panelText4:Dock(TOP)
        panelText4:SetTall(82)
        panelText4.Paint = function(_, w, h)
            RNDX().Rect(0, 0, w, h)
                :Rad(32)
                :Color(Mantle.color.panel_alpha[1])
                :Shape(RNDX.SHAPE_IOS)
            :Draw()
        end

        local longText = [[
        Это длинный пример текста, который занимает несколько строк. Если блок небольшой по высоте — последняя видимая строка будет усечена с троеточием, чтобы не порвать верстку и не выходить за пределы панели нашего меню.
        ]]

        local text4 = vgui.Create('MantleText', panelText4)
        text4:Dock(FILL)
        text4:SetPadding(8)
        text4:SetFont('Fated.16')
        text4:SetText(longText)

        CreateCategory('Текст (MantleText)', {
            {':SetText(string text)', 'Установить текст для отображения'},
            {':SetFont(string font)', 'Установить шрифт'},
            {':SetColor(color col)', 'Установить цвет текста'},
            {':SetAlign(number align)', 'Горизонтальное выравнивание (TEXT_ALIGN_*)'},
            {':SetVAlign(string valign)', 'Вертикальное выравнивание: top, center, bottom'},
            {':SetPadding(number px)', 'Внутренний отступ от краёв'}
        }, panel, panelTexts)

        return panel
    end

    tabs:AddTab('UI Элементы', CreateTabElements(), Material('icon16/chart_pie.png'))

    local function CreateShowMenus()
        local panel = vgui.Create('MantleScrollPanel')
        CreateTabHeader('Всплывающие', 'Палитра, derma-меню, radial и другие утилиты.', Material('icon16/application_double.png'), panel)

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
                menuMantle:Notify('Тестовое сообщение!')
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

    local function CreateTabFunctions()
        local panel = vgui.Create('MantleScrollPanel')
        CreateTabHeader('Функции', 'Полный список утилитарных функций Mantle.func и других вспомогательных функций', Material('icon16/cog.png'), panel)

        local menuWide = menuMantle:GetWide()

        CreateCategory('Размытие панели', {
            {'Mantle.func.blur(object panel)', 'Отрисовка размытия панели в Paint'}
        }, panel)

        CreateCategory('Градиент', {
            {'Mantle.func.gradient(int x, int y, int w, int h, int dir, color color_shadow, int radius, flags)', 'Отрисовка градиента (dir: 1 - вверх, 2 - вниз, 3 - влево, 4 - вправо)'}
        }, panel)

        CreateCategory('Создание звука', {
            {'Mantle.func.sound(string path)', 'Проигрывает звук (дефолт - mantle/btn_click.ogg)'}
        }, panel)

        CreateCategory('Относительные единицы для адаптивного интерфейса', {
            {'Mantle.func.w(int px)', 'Относительная ширина (от 1920)'},
            {'Mantle.func.h(int px)', 'Относительная высота (от 1080)'}
        }, panel)

        CreateCategory('Отрисовка текста над энтити', {
            {'Mantle.func.draw_ent_text(object ent, string text, int posY)', 'Рисует текст над энтити с плавным появлением (3D2D)'}
        }, panel)

        CreateCategory('Анимация размера панели', {
            {'Mantle.func.animate_appearance(object panel, int w, int h, int duration, int alpha_dur, func callback, int scale_factor)', 'Плавное изменение панели до нужного размера'}
        }, panel)

        CreateCategory('Плавное изменение цвета', {
            {'Mantle.func.LerpColor(int frac, color col1, color col2)', 'Плавный переход цвета от col1 → col2'}
        }, panel)

        CreateCategory('Загрузка картинки', {
            {'http.DownloadMaterial(string url, string path, func callback, int retry_count)', 'Скачивает материал по URL и кэширует его. Повторяет попытку при ошибке, возвращает через callback материал'}
        }, panel)

        CreateCategory('Серверное уведомление', {
            {'Mantle.notify(object pl, color header_color, string header, string text)', 'Отправка сообщений в чат игроку или всем (вместо pl указать true - тогда всем)'}
        }, panel)

        CreateCategory('Изменение регистра букв', {
            {'utf8.lower(string text)', 'Преобразует строку в нижний регистр с поддержкой русских букв'},
            {'utf8.upper(string text)', 'Преобразует строку в верхний регистр с поддержкой русских букв'}
        }, panel)

        return panel
    end

    tabs:AddTab('Функции', CreateTabFunctions(), Material('icon16/error.png'))

    local function CreateLegacyTest()
        local panel = vgui.Create('MantleScrollPanel')
        CreateTabHeader('Legacy UI', 'Набор legacy-утилит (Mantle.ui.*). Для совместимости и примеров.', Material('icon16/exclamation.png'), panel)

        local menuWide = menuMantle:GetWide()

        local btnFrame = vgui.Create('MantleBtn')
        btnFrame:SetTxt('Открыть Legacy Frame')
        btnFrame:SetTall(40)
        btnFrame:DockMargin(menuWide * 0.3, 6, menuWide * 0.3, 0)
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
            {'Mantle.ui.frame(object frame, string title, int w, int h, bool cls_btn, bool open_anim)', 'Оформление стандартное окна стилем Mantle'},
            {'Mantle.ui.sp(object scroll)', 'Оформление панели прокрутки элементов'},
            {'Mantle.ui.btn(object btn, mat icon, int icon_size, color col, int rad, bool off_grad, color hov, bool off_hov)', 'Оформление кнопки'},
            {'Mantle.ui.slidebox(object parent, string label, int min_value, int max_value, string convar, int decimals)', 'Создание слайдера на родительном элементе'},
            {'Mantle.ui.desc_entry(object parent, string title, string placeholder, bool off_title)', 'Создание поля ввода'},
            {'Mantle.ui.checkbox(object parent, string text, string convar)', 'Создание чекбокса'},
            {'Mantle.ui.panel_tabs(object parent)', 'Создание панели с вкладками. В дальнейшем использовать :AddTab() и :ActiveTab() для настройки'}
        }, panel, btnFrame, true)

        return panel
    end

    tabs:AddTab('Legacy UI', CreateLegacyTest(), Material('icon16/exclamation.png'))

    local function CreateSettings()
        local panel = vgui.Create('MantleScrollPanel')
        CreateTabHeader('Настройки', 'Глобальные настройки Mantle: темы, эффекты и глубины элементов.', Material('icon16/cog.png'), panel)

        local menuWide = menuMantle:GetWide()

        local checkboxDepth = vgui.Create('MantleCheckBox', panel)
        checkboxDepth:Dock(TOP)
        checkboxDepth:SetTxt('Глубины элементов')
        checkboxDepth:SetConvar('mantle_depth_ui')

        local checkboxBlur = vgui.Create('MantleCheckBox', panel)
        checkboxBlur:Dock(TOP)
        checkboxBlur:DockMargin(0, 6, 0, 0)
        checkboxBlur:SetTxt('Размытие фона')
        checkboxBlur:SetConvar('mantle_blur')

        local categoryTheme = vgui.Create('MantleCategory', panel)
        categoryTheme:Dock(TOP)
        categoryTheme:DockMargin(0, 6, 0, 0)
        categoryTheme:SetText('Изменение цветовой темы')
        categoryTheme:SetActive(true)

        local comboboxTheme = vgui.Create('MantleComboBox')
        comboboxTheme:Dock(TOP)
        comboboxTheme:SetPlaceholder('Выберите тему интерфейса')
        comboboxTheme:AddChoice('Тёмная (dark)', 'dark')
        comboboxTheme:AddChoice('Тёмная монотонная (dark_mono)', 'dark_mono')
        comboboxTheme:AddChoice('Светлая (light)', 'light')
        comboboxTheme:AddChoice('Синяя (blue)', 'blue')
        comboboxTheme:AddChoice('Красная (red)', 'red')
        comboboxTheme:AddChoice('Зелёная (green)', 'green')
        comboboxTheme:AddChoice('Оранжевая (orange)', 'orange')
        comboboxTheme:AddChoice('Фиолетовый (purple)', 'purple')
        comboboxTheme:AddChoice('Кофейная (coffee)', 'coffee')
        comboboxTheme:AddChoice('Ледяная (ice)', 'ice')
        comboboxTheme:AddChoice('Винная (wine)', 'wine')
        comboboxTheme:AddChoice('Фиалковая (violet)', 'violet')
        comboboxTheme:AddChoice('Моховая (moss)', 'moss')
        comboboxTheme:AddChoice('Коралловая (coral)', 'coral')
        comboboxTheme.OnSelect = function(_, _, data)
            RunConsoleCommand('mantle_theme', data)
        end
        categoryTheme:AddItem(comboboxTheme)

        local listThemeColors = vgui.Create('DIconLayout')
        listThemeColors:Dock(TOP)
        listThemeColors:DockMargin(6, 8, 6, 0)
        listThemeColors:SetTall(164)
        listThemeColors:SetSpaceX(8)
        listThemeColors:SetSpaceY(8)
        categoryTheme:AddItem(listThemeColors)

        for colId, _ in pairs(Mantle.color) do
            local panCol = vgui.Create('DPanel', listThemeColors)
            panCol:SetSize(80, 80)
            panCol.Paint = function(_, w, h)
                RNDX().Rect(0, 0, w, h)
                    :Rad(16)
                    :Color(Mantle.color[colId])
                    :Shape(RNDX.SHAPE_IOS)
                :Draw()
                draw.SimpleText(colId, 'Fated.12', w * 0.5, h * 0.5, color_black, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            end
        end

        return panel
    end

    tabs:AddTab('Настройки', CreateSettings(), Material('icon16/cog.png'))
end

concommand.Add('mantle_menu', CreateMenu)
