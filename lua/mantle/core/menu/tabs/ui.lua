local menu = Mantle.menu

local icon = Material('icon16/chart_pie.png')

local function createUITab()
    local panel = menu.createTabPanel('UI Элементы', 'Демонстрация всех компонентов Mantle. Клик по элементу открывает пример.', icon)
    local menuWide = menu.getMenuWide()

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

    menu.createCategory('Кнопка (MantleBtn)', {
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

    local checkbox = vgui.Create('MantleCheckBox')
    checkbox:DockMargin(menuWide * 0.3, 6, menuWide * 0.3, 0)
    checkbox:Dock(TOP)
    checkbox:SetTxt('Отображение HUD')
    checkbox:SetConvar('cl_drawhud')
    menu.createCategory('Тумблер (MantleCheckBox)', {
        {':SetTxt(string text)', 'Установить текст'},
        {':SetValue(bool value)', 'Установить bool-значение тумблера'},
        {':GetBool()', 'Получить bool-значение тумблера'},
        {':SetConvar(string convar)', 'Установить ConVar'},
        {':OnChange(bool new_value)', 'Вызывается при изменении значения тумблера'}
    }, panel, checkbox)

    local entry = vgui.Create('MantleEntry')
    entry:Dock(TOP)
    entry:DockMargin(menuWide * 0.35, 6, menuWide * 0.35, 0)
    entry:SetTitle('Никнейм')
    entry:SetPlaceholder('darkf')
    menu.createCategory('Ввод текста (MantleEntry)', {
        {':SetTitle(string text)', 'Установить заголовок'},
        {':SetPlaceholder(string text)', 'Установить фоновый текст (появляется при пустом поле)'},
        {':GetValue()', 'Получить string-значение поля'},
        {':SetValue(string value)', 'Установить значение полю'}
    }, panel, entry)

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

    menu.createCategory('Окно (MantleFrame)', {
        {':SetAlphaBackground(bool is_alpha)', 'Включить/выключить прозрачность окна (дефолт - false)'},
        {':SetTitle(string title)', 'Установить заголовок'},
        {':SetCenterTitle(string title)', 'Установить центральный заголовок'},
        {':ShowAnimation()', 'Активировать анимацию при появлении меню'},
        {':Close()', 'Плавно закрывает окно'},
        {':DisableCloseBtn()', 'Скрыть кнопку закрытия'},
        {':SetDraggable(bool is_draggable)', 'Включить/выключить перемещение окна'},
        {':LiteMode()', 'Активировать режим Lite (без верхней панели)'},
        {':Notify(string text, number duration, color col)', 'Показать уведомление внизу окна (дефолт времени - 2 сек., цвета - Mantle.color.theme)'}
    }, panel, panelFrames)

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
    menu.createCategory('Панель прокрутки (MantleScrollPanel)', {
        {':SetScroll(number offset)', 'Установить смещение прокрутки'},
        {':GetScroll()', 'Получить текущее смещение прокрутки'},
        {':AddItem(object panel)', 'Добавить элемент в панель'},
        {':GetCanvas()', 'Получить внутренний контейнер содержимого'},
        {':GetVBar()', 'Получить вертикальный скроллбар'},
        {':Clear()', 'Очистить панель от всего'},
        {':DisableVBarPadding()', 'Отключить отступ справа для скроллбара (по умолчанию имеется)'},
        {':SetVBarPaddingRight(bool enabled)', 'Переключает дополнительный отступ под скроллбар'}
    }, panel, sp)

    local panelTabs = vgui.Create('Panel')
    panelTabs:Dock(TOP)
    panelTabs:SetTall(280)

    local testTabs = vgui.Create('MantleTabs', panelTabs)
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

    local testTabs2 = vgui.Create('MantleTabs', panelTabs)
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

    menu.createCategory('Вкладки (MantleTabs)', {
        {':SetTabStyle(string style)', 'Установить стиль вкладок (modern или classic)'},
        {':SetTabHeight(int height)', 'Установить высоту вкладок'},
        {':SetIndicatorHeight(int height)', 'Установить высоту индикатора вкладок'},
        {':AddTab(string name, object panel, string icon)', 'Добавить вкладку старым сигнатурным API'},
        {':AddTab(table data, object panel)', 'Добавить вкладку descriptor-форматом {title, description, icon}'},
        {':SetActiveTab(number|string tab_id)', 'Активировать вкладку по индексу или названию'}
    }, panel, panelTabs)

    local hscroll = vgui.Create('MantleHScroll')
    hscroll:Dock(TOP)
    hscroll:DockMargin(menuWide * 0.3, 6, menuWide * 0.3, 0)
    hscroll:SetTall(80)

    for i = 1, 8 do
        local btn = vgui.Create('MantleBtn')
        btn:SetSize(120, 60)
        btn:SetTxt('Элемент ' .. i)
        btn:Dock(LEFT)
        btn:DockMargin(0, 0, 5, 0)
        hscroll:AddItem(btn)
    end

    menu.createCategory('Горизонтальная прокрутка (MantleHScroll)', {
        {':AddItem(pnl) / :Add(pnl)', 'Добавить элемент в контейнер прокрутки'},
        {':GetCanvas()', 'Получить внутренний контейнер содержимого'},
        {':DockPadding(number l, number t, number r, number b)', 'Задать внутренние отступы контейнера'},
        {':Clear()', 'Очистить все элементы из контейнера'},
        {':SetScroll(x)', 'Установить текущее смещение прокрутки'},
        {':GetScroll()', 'Получить текущее смещение прокрутки'}
    }, panel, hscroll)

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
    menu.createCategory('Выпадающий список (MantleComboBox)', {
        {':AddChoice(string text, any data)', 'Добавить вариант в список (data - любое значение, связанное с пунктом)'},
        {':SetValue(string text)', 'Установить выбранное значение по тексту'},
        {':GetValue()', 'Получить выбранное значение (текст)'},
        {':SetPlaceholder(string text)', 'Установить текст-заполнитель (placeholder)'},
        {':OpenMenu()', 'Открыть выпадающее меню программно'},
        {':CloseMenu()', 'Закрыть выпадающее меню программно'},
        {':OnSelect(idx, text, data)', 'Вызывается при выборе варианта: idx - индекс, text - текст, data - значение'}
    }, panel, combo)

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

    menu.createCategory('Таблица (MantleTable)', {
        {':AddColumn(string name, number width, number align, bool sortable)', 'Добавить колонку'},
        {':AddItem(...)', 'Добавить строку. Количество аргументов должно соответствовать количеству колонок'},
        {':SortByColumn(number index)', 'Отсортировать таблицу по колонке'},
        {':SetAction(function(table row_data))', 'Установить функцию, вызываемую при клике на строку. row_data - массив значений строки'},
        {':SetRightClickAction(function(table row_data))', 'Установить функцию, вызываемую при правом клике на строку'},
        {':Clear()', 'Очистить таблицу от всех строк'},
        {':GetSelectedRow()', 'Получить данные выбранной строки (массив значений)'},
        {':GetRowCount()', 'Получить количество строк в таблице'},
        {':RemoveRow(number index)', 'Удалить строку по индексу (начиная с 1)'}
    }, panel, tableExample)

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
    menu.createCategory('Категория (MantleCategory)', {
        {':SetText(string name)', 'Установить название'},
        {':AddItem(object panel)', 'Добавить в категорию элемент'},
        {':SetColor(color col)', 'Установить кастомный цвет категории'},
        {':SetCenterText(bool is_centered)', 'Установить центрирование названия'},
        {':SetActive(bool is_active)', 'Установить активность категории (дефолт - false)'}
    }, panel, panelCat)

    local slider = vgui.Create('MantleSlideBox')
    slider:Dock(TOP)
    slider:DockMargin(menuWide * 0.3, 6, menuWide * 0.3, 0)
    slider:SetRange(0, 4)
    slider:SetConvar('net_graph')
    slider:SetText('График')
    menu.createCategory('Слайдер (MantleSlideBox)', {
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
    text1:SetText('MantleText - компонент для аккуратного вывода многострочного текста. Текст автоматически переносится по ширине и сокращается троеточием')

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
        Это длинный пример текста, который занимает несколько строк. Если блок небольшой по высоте - последняя видимая строка будет усечена с троеточием, чтобы не порвать верстку и не выходить за пределы панели нашего меню.
    ]]

    local text4 = vgui.Create('MantleText', panelText4)
    text4:Dock(FILL)
    text4:SetPadding(8)
    text4:SetFont('Fated.16')
    text4:SetText(longText)

    menu.createCategory('Текст (MantleText)', {
        {':SetText(string text)', 'Установить текст для отображения'},
        {':GetText()', 'Получить исходный текст компонента'},
        {':SetFont(string font)', 'Установить шрифт'},
        {':SetColor(color col)', 'Установить цвет текста'},
        {':SetAlign(number align)', 'Горизонтальное выравнивание (TEXT_ALIGN_*)'},
        {':SetVAlign(string valign)', 'Вертикальное выравнивание: top, center, bottom'},
        {':SetPadding(number px)', 'Внутренний отступ от краёв'}
    }, panel, panelTexts)

    return panel
end

menu.registerTab('ui', {
    order = 1,
    title = 'UI Элементы',
    description = 'Демонстрация компонентов и элементов библиотеки Mantle',
    icon = icon,
    create = createUITab
})
