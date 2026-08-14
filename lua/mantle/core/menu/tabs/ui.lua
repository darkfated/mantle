local menu = Mantle.menu

local icon = Material('icon16/chart_pie.png')

local function build()
    local panel = menu.createTabPanel()
    local menuWide = menu.getMenuWide()

    --[[
        Кнопка
    ]]--
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

    menu.createCategory(panel, {
        title = 'Кнопка (MantleBtn)',
        rows = {
            { name = ':SetHover(bool is_hover)', desc = 'Цвет выделения при наведении (по умолчанию - true)' },
            { name = ':SetFont(string font)', desc = 'Шрифт текста' },
            { name = ':SetRadius(int rad)', desc = 'Скругление углов (по умолчанию - 16)' },
            { name = ':SetIcon(string|material icon, int icon_size)', desc = 'Иконка: путь к материалу или IMaterial (размер по умолчанию - 16)' },
            { name = ':SetTxt(string text)', desc = 'Текст кнопки' },
            { name = ':SetColor(color col)', desc = 'Основной цвет кнопки' },
            { name = ':SetColorHover(color col)', desc = 'Цвет при наведении' },
            { name = ':SetGradient(bool is_grad)', desc = 'Градиент внизу кнопки (по умолчанию - true)' },
            { name = ':SetRipple(bool is_ripple)', desc = 'Эффект волны при клике (по умолчанию - false)' }
        },
        demo = panelBtns
    })

    --[[
        Ввод текста
    ]]--
    local checkbox = vgui.Create('MantleCheckBox')
    checkbox:DockMargin(menuWide * 0.3, 6, menuWide * 0.3, 0)
    checkbox:Dock(TOP)
    checkbox:SetTxt('Отображение HUD')
    checkbox:SetConvar('cl_drawhud')
    menu.createCategory(panel, {
        title = 'Тумблер (MantleCheckBox)',
        rows = {
            { name = ':SetTxt(string text)', desc = 'Текст рядом с тумблером' },
            { name = ':SetValue(bool value)', desc = 'Поставить значение (вкл/выкл)' },
            { name = ':GetBool()', desc = 'Текущее состояние тумблера' },
            { name = ':SetConvar(string convar)', desc = 'Привязать к ConVar' },
            { name = ':OnChange(bool new_value)', desc = 'Срабатывает при переключении' }
        },
        demo = checkbox
    })

    local entry = vgui.Create('MantleEntry')
    entry:Dock(TOP)
    entry:DockMargin(menuWide * 0.35, 6, menuWide * 0.35, 0)
    entry:SetTitle('Никнейм')
    entry:SetPlaceholder('darkf')
    menu.createCategory(panel, {
        title = 'Ввод текста (MantleEntry)',
        rows = {
            { name = ':SetTitle(string text)', desc = 'Заголовок над полем' },
            { name = ':SetPlaceholder(string text)', desc = 'Серая подсказка, пока поле пустое' },
            { name = ':GetValue()', desc = 'Текст из поля (string)' },
            { name = ':SetValue(string value)', desc = 'Вписать текст в поле' }
        },
        demo = entry
    })

    --[[
        Окно
    ]]--
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

    menu.createCategory(panel, {
        title = 'Окно (MantleFrame)',
        rows = {
            { name = ':SetAlphaBackground(bool is_alpha)', desc = 'Прозрачный фон окна (по умолчанию - true)' },
            { name = ':SetTitle(string title)', desc = 'Заголовок слева в шапке' },
            { name = ':SetCenterTitle(string title)', desc = 'Заголовок по центру шапки' },
            { name = ':ShowAnimation()', desc = 'Анимация появления окна' },
            { name = ':Close()', desc = 'Плавно закрыть окно' },
            { name = ':DisableCloseBtn()', desc = 'Убрать кнопку закрытия' },
            { name = ':SetDraggable(bool is_draggable)', desc = 'Перетаскивание окна (по умолчанию - true)' },
            { name = ':LiteMode()', desc = 'Режим без верхней панели' },
            { name = ':Notify(string text, number duration, color col)', desc = 'Уведомление внизу окна (длительность по умолчанию - 2 сек., цвет - Mantle.color.theme)' }
        },
        demo = panelFrames
    })

    --[[
        Панель прокрутки
    ]]--
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
            RNDX.Rect(0, 0, w, h)
                :Rad(16)
                :Color(Mantle.color.panel_alpha[1])
            :Draw()
        end
    end
    menu.createCategory(panel, {
        title = 'Панель прокрутки (MantleScrollPanel)',
        rows = {
            { name = ':SetScroll(number offset)', desc = 'Сместить прокрутку на offset' },
            { name = ':GetScroll()', desc = 'Текущее смещение прокрутки' },
            { name = ':AddItem(object panel)', desc = 'Добавить элемент внутрь' },
            { name = ':GetCanvas()', desc = 'Внутренний контейнер, куда падают элементы' },
            { name = ':GetVBar()', desc = 'Вертикальный скроллбар' },
            { name = ':Clear()', desc = 'Очистить панель от всего' },
            { name = ':DisableVBarPadding()', desc = 'Убрать отступ справа под скроллбар (есть по умолчанию)' },
            { name = ':SetVBarPaddingRight(bool enabled)', desc = 'Включить/выключить отступ под скроллбар' }
        },
        demo = sp
    })

    --[[
        Вкладки
    ]]--
    local panelTabs = vgui.Create('Panel')
    panelTabs:Dock(TOP)
    panelTabs:SetTall(280)

    local testTabs = vgui.Create('MantleTabs', panelTabs)
    testTabs:Dock(TOP)
    testTabs:DockMargin(menuWide * 0.3, 6, menuWide * 0.3, 0)
    testTabs:SetTall(150)
    local testTab1 = vgui.Create('DPanel')
    testTab1.Paint = function(_, w, h)
        RNDX.Rect(0, 0, w - 12, h)
            :Rad(16)
            :Color(53, 98, 40)
        :Draw()
    end
    testTabs:AddTab('Test1', testTab1)
    local testTab2 = vgui.Create('DPanel')
    testTab2.Paint = function(_, w, h)
        RNDX.Rect(0, 0, w - 12, h)
            :Rad(16)
            :Color(108, 41, 45)
        :Draw()
    end
    testTabs:AddTab('Test2', testTab2)

    local testTabs2 = vgui.Create('MantleTabs', panelTabs)
    testTabs2:Dock(FILL)
    testTabs2:DockMargin(menuWide * 0.3, 10, menuWide * 0.3, 0)
    testTabs2:SetTabStyle('classic')
    local testTab3 = vgui.Create('DPanel')
    testTab3.Paint = function(_, w, h)
        RNDX.Rect(0, 0, w - 12, h)
            :Rad(16)
            :Color(51, 61, 116)
        :Draw()
    end
    testTabs2:AddTab('Test3', testTab3)
    local testTab4 = vgui.Create('DPanel')
    testTab4.Paint = function(_, w, h)
        RNDX.Rect(0, 0, w - 12, h)
            :Rad(16)
            :Color(138, 89, 43)
        :Draw()
    end
    testTabs2:AddTab('Test4', testTab4)
    local testTab5 = vgui.Create('DPanel')
    testTab5.Paint = function(_, w, h)
        RNDX.Rect(0, 0, w - 12, h)
            :Rad(16)
            :Color(43, 138, 133)
        :Draw()
    end
    testTabs2:AddTab('С иконкой', testTab5, Material('icon16/folder.png'))

    menu.createCategory(panel, {
        title = 'Вкладки (MantleTabs)',
        rows = {
            { name = ':SetTabStyle(string style)', desc = 'Стиль вкладок: modern или classic' },
            { name = ':SetTabHeight(int height)', desc = 'Высота панели вкладок' },
            { name = ':SetIndicatorHeight(int height)', desc = 'Толщина индикатора активной вкладки' },
            { name = ':AddTab(string name, object panel, string icon)', desc = 'Добавить вкладку (старый формат)' },
            { name = ':AddTab(table data, object panel)', desc = 'Добавить вкладку через таблицу {title, description, icon}' },
            { name = ':SetActiveTab(number|string tab_id)', desc = 'Переключиться на вкладку по индексу или названию' }
        },
        demo = panelTabs
    })

    --[[
        Горизонтальная прокрутка
    ]]--
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

    menu.createCategory(panel, {
        title = 'Горизонтальная прокрутка (MantleHScroll)',
        rows = {
            { name = ':AddItem(pnl) / :Add(pnl)', desc = 'Добавить элемент в контейнер' },
            { name = ':GetCanvas()', desc = 'Внутренний контейнер, куда падают элементы' },
            { name = ':DockPadding(number l, number t, number r, number b)', desc = 'Внутренние отступы контейнера' },
            { name = ':Clear()', desc = 'Убрать все элементы' },
            { name = ':SetScroll(x)', desc = 'Сместить прокрутку на x' },
            { name = ':GetScroll()', desc = 'Текущее смещение прокрутки' }
        },
        demo = hscroll
    })

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
    menu.createCategory(panel, {
        title = 'Выпадающий список (MantleComboBox)',
        rows = {
            { name = ':AddChoice(string text, any data)', desc = 'Добавить вариант (data - любое значение, привязанное к пункту)' },
            { name = ':SetValue(string text)', desc = 'Выбрать пункт по тексту' },
            { name = ':GetValue()', desc = 'Текст выбранного пункта' },
            { name = ':SetPlaceholder(string text)', desc = 'Подсказка, пока ничего не выбрано' },
            { name = ':OpenMenu()', desc = 'Открыть список из кода' },
            { name = ':CloseMenu()', desc = 'Закрыть список из кода' },
            { name = ':OnSelect(idx, text, data)', desc = 'Срабатывает при выборе: idx - индекс, text - текст, data - значение' }
        },
        demo = combo
    })

    --[[
        Таблица
    ]]--
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

    menu.createCategory(panel, {
        title = 'Таблица (MantleTable)',
        rows = {
            { name = ':AddColumn(string name, number width, number align, bool sortable)', desc = 'Добавить колонку (sortable - сортировка по клику)' },
            { name = ':AddItem(...)', desc = 'Добавить строку. Аргументов столько же, сколько колонок' },
            { name = ':SortByColumn(number index)', desc = 'Отсортировать строки по колонке' },
            { name = ':SetAction(function(table row_data))', desc = 'Что делать при клике на строку (row_data - значения строки)' },
            { name = ':SetRightClickAction(function(table row_data))', desc = 'Что делать при правом клике на строку' },
            { name = ':Clear()', desc = 'Очистить таблицу от строк' },
            { name = ':GetSelectedRow()', desc = 'Значения выбранной строки' },
            { name = ':GetRowCount()', desc = 'Сколько строк в таблице' },
            { name = ':RemoveRow(number index)', desc = 'Удалить строку по индексу (счёт с 1)' }
        },
        demo = tableExample
    })

    --[[
        Категория
    ]]--
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
        RNDX.Rect(0, 0, w - 12, h)
            :Rad(16)
            :Color(93, 179, 101)
        :Draw()
    end
    cat:AddItem(panGreen)
    local panRed = vgui.Create('DPanel')
    panRed:Dock(TOP)
    panRed:DockMargin(0, 6, 0, 0)
    panRed:SetTall(50)
    panRed.Paint = function(_, w, h)
        RNDX.Rect(0, 0, w - 12, h)
            :Rad(16)
            :Color(179, 110, 93)
        :Draw()
    end
    cat:AddItem(panRed)
    menu.createCategory(panel, {
        title = 'Категория (MantleCategory)',
        rows = {
            { name = ':SetText(string name)', desc = 'Название категории' },
            { name = ':AddItem(object panel)', desc = 'Добавить элемент внутрь' },
            { name = ':SetColor(color col)', desc = 'Свой цвет шапки категории' },
            { name = ':SetCenterText(bool is_centered)', desc = 'Название по центру шапки' },
            { name = ':SetActive(bool is_active)', desc = 'Раскрыта ли категория (по умолчанию - false)' },
            { name = ':IsActive()', desc = 'Открыта ли категория сейчас' },
            { name = ':Clear()', desc = 'Убрать все элементы и свернуть категорию' }
        },
        demo = panelCat
    })

    --[[
        Слайдер
    ]]--
    local slider = vgui.Create('MantleSlideBox')
    slider:Dock(TOP)
    slider:DockMargin(menuWide * 0.3, 6, menuWide * 0.3, 0)
    slider:SetRange(0, 5)
    slider:SetConvar('r_skybox')
    slider:SetText('Отключение неба')
    menu.createCategory(panel, {
        title = 'Слайдер (MantleSlideBox)',
        rows = {
            { name = ':SetRange(int min_value, int max_value, int decimals)', desc = 'Диапазон значений (decimals - знаков после запятой, по умолчанию 0)' },
            { name = ':SetConvar(string convar)', desc = 'Привязать к ConVar' },
            { name = ':SetText(string text)', desc = 'Подпись слева от слайдера' },
            { name = ':SetValue(number val)', desc = 'Поставить значение' },
            { name = ':GetValue()', desc = 'Текущее значение (число)' },
            { name = ':OnValueChanged(number new_value)', desc = 'Срабатывает при изменении значения' }
        },
        demo = slider
    })

    --[[
        Текст
    ]]--
    local panelTexts = vgui.Create('Panel')
    panelTexts:Dock(TOP)
    panelTexts:DockMargin(menuWide * 0.3, 6, menuWide * 0.3, 0)
    panelTexts:DockPadding(8, 8, 8, 8)
    panelTexts:SetTall(344)
    panelTexts.Paint = function(_, w, h)
        RNDX.Rect(0, 0, w, h)
            :Rad(32)
            :Color(Mantle.color.panel_alpha[2])
        :Draw()
    end

    local panelText1 = vgui.Create('DPanel', panelTexts)
    panelText1:Dock(TOP)
    panelText1:DockMargin(0, 0, 0, 6)
    panelText1:SetTall(74)
    panelText1.Paint = function(_, w, h)
        RNDX.Rect(0, 0, w, h)
            :Rad(32)
            :Color(Mantle.color.panel_alpha[1])
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
        RNDX.Rect(0, 0, w, h)
            :Rad(32)
            :Color(Mantle.color.panel_alpha[1])
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
        RNDX.Rect(0, 0, w, h)
            :Rad(32)
            :Color(Mantle.color.panel_alpha[1])
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
        RNDX.Rect(0, 0, w, h)
            :Rad(32)
            :Color(Mantle.color.panel_alpha[1])
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

    menu.createCategory(panel, {
        title = 'Текст (MantleText)',
        rows = {
            { name = ':SetText(string text)', desc = 'Текст для отображения' },
            { name = ':GetText()', desc = 'Исходный текст компонента' },
            { name = ':SetFont(string font)', desc = 'Шрифт текста' },
            { name = ':SetColor(color col)', desc = 'Цвет текста' },
            { name = ':SetAlign(number align)', desc = 'Выравнивание по горизонтали (TEXT_ALIGN_*)' },
            { name = ':SetVAlign(string valign)', desc = 'Выравнивание по вертикали: top, center, bottom' },
            { name = ':SetPadding(number px)', desc = 'Отступ текста от краёв' }
        },
        demo = panelTexts
    })

    return panel
end

menu.registerTab('ui', {
    order = 1,
    title = 'UI Элементы',
    description = 'Демонстрация всех графических компонентов.',
    icon = icon,
    build = build
})
