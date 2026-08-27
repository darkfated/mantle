local function build(tab)
    local panel = Mantle.menu.createBanner(tab)

    local panelBtns = vgui.Create('Panel')
    panelBtns:Dock(TOP)
    panelBtns:SetTall(168)

    local btn1 = vgui.Create('MantleBtn', panelBtns)
    btn1:Dock(TOP)
    btn1:SetTall(40)
    btn1:SetTxt('Стандартная кнопка')

    local btn2 = vgui.Create('MantleBtn', panelBtns)
    btn2:Dock(TOP)
    btn2:SetTall(40)
    btn2:SetTxt('Эффект волны')
    btn2:SetRipple(true)

    local btn3 = vgui.Create('MantleBtn', panelBtns)
    btn3:Dock(TOP)
    btn3:SetTall(40)
    btn3:SetTxt('Свой цвет')
    btn3:SetColor(Color(182, 65, 65))
    btn3:SetColorHover(Color(143, 57, 57))
    btn3:SetIcon(Material('icon16/delete.png'), 16)

    local cat = vgui.Create('MantleCategory', panel)
    cat:Dock(TOP)
    cat:SetText('Кнопка')
    cat:SetActive(true)
    panelBtns:DockMargin(8, 8, 8, 8)
    cat:AddItem(panelBtns)

    local checkbox = vgui.Create('MantleCheckBox')
    checkbox:Dock(TOP)
    checkbox:SetTxt('Отображение HUD')
    checkbox:SetConvar('cl_drawhud')

    cat = vgui.Create('MantleCategory', panel)
    cat:Dock(TOP)
    cat:SetText('Тумблер')
    cat:SetActive(true)
    checkbox:DockMargin(8, 8, 8, 8)
    cat:AddItem(checkbox)

    local entry = vgui.Create('MantleEntry')
    entry:Dock(TOP)
    entry:SetTitle('Никнейм')
    entry:SetPlaceholder('darkf')

    cat = vgui.Create('MantleCategory', panel)
    cat:Dock(TOP)
    cat:SetText('Поле ввода')
    cat:SetActive(true)
    entry:DockMargin(8, 8, 8, 8)
    cat:AddItem(entry)

    local panelFrames = vgui.Create('Panel')
    panelFrames:Dock(TOP)
    panelFrames:SetTall(112)

    local btnFrame1 = vgui.Create('MantleBtn', panelFrames)
    btnFrame1:Dock(TOP)
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
    btnFrame2:SetTxt('Режим без верхней панели')
    btnFrame2:SetTall(40)
    btnFrame2.DoClick = function()
        local frame = vgui.Create('MantleFrame')
        frame:SetSize(400, 300)
        frame:Center()
        frame:MakePopup()
        frame:LiteMode()
    end

    cat = vgui.Create('MantleCategory', panel)
    cat:Dock(TOP)
    cat:SetText('Окно')
    cat:SetActive(true)
    panelFrames:DockMargin(8, 8, 8, 8)
    cat:AddItem(panelFrames)

    local sp = vgui.Create('MantleScrollPanel')
    sp:Dock(TOP)
    sp:SetTall(150)

    for k = 1, 10 do
        local spPanel = vgui.Create('MantlePanel', sp)
        spPanel:Dock(TOP)
        spPanel:SetTall(24)
        spPanel:SetColorAlpha(1)
        spPanel:SetRadius(16)
    end

    cat = vgui.Create('MantleCategory', panel)
    cat:Dock(TOP)
    cat:SetText('Панель прокрутки')
    cat:SetActive(true)
    sp:DockMargin(8, 8, 8, 8)
    cat:AddItem(sp)

    local panelTabs = vgui.Create('Panel')
    panelTabs:Dock(TOP)
    panelTabs:SetTall(320)

    local testTabs = vgui.Create('MantleTabs', panelTabs)
    testTabs:Dock(TOP)
    testTabs:SetTall(150)
    local testTab1 = vgui.Create('Panel')
    testTab1.Paint = function(_, w, h)
        RNDX.Rect(0, 0, w - 12, h):Rad(16):Color(53, 98, 40):Draw()
    end
    testTabs:AddTab('Test1', testTab1)

    local testTab2 = vgui.Create('Panel')
    testTab2.Paint = function(_, w, h)
        RNDX.Rect(0, 0, w - 12, h):Rad(16):Color(108, 41, 45):Draw()
    end
    testTabs:AddTab('Test2', testTab2)

    local testTabs2 = vgui.Create('MantleTabs', panelTabs)
    testTabs2:Dock(FILL)
    testTabs2:SetTabStyle('classic')
    local testTab3 = vgui.Create('Panel')
    testTab3.Paint = function(_, w, h)
        RNDX.Rect(0, 0, w - 12, h):Rad(16):Color(51, 61, 116):Draw()
    end
    testTabs2:AddTab('Test3', testTab3)

    local testTab4 = vgui.Create('Panel')
    testTab4.Paint = function(_, w, h)
        RNDX.Rect(0, 0, w - 12, h):Rad(16):Color(138, 89, 43):Draw()
    end
    testTabs2:AddTab('Test4', testTab4)

    local testTab5 = vgui.Create('Panel')
    testTab5.Paint = function(_, w, h)
        RNDX.Rect(0, 0, w - 12, h):Rad(16):Color(43, 138, 133):Draw()
    end
    testTabs2:AddTab('С иконкой', testTab5, Material('icon16/folder.png'))

    cat = vgui.Create('MantleCategory', panel)
    cat:Dock(TOP)
    cat:SetText('Вкладки')
    cat:SetActive(true)
    panelTabs:DockMargin(8, 8, 8, 8)
    cat:AddItem(panelTabs)

    local hscroll = vgui.Create('MantleHScroll')
    hscroll:Dock(TOP)
    hscroll:SetTall(80)

    for i = 1, 8 do
        local btn = vgui.Create('MantleBtn')
        btn:SetSize(120, 60)
        btn:SetTxt('Элемент ' .. i)
        btn:Dock(LEFT)
        hscroll:AddItem(btn)
    end

    cat = vgui.Create('MantleCategory', panel)
    cat:Dock(TOP)
    cat:SetText('Горизонтальная прокрутка')
    cat:SetActive(true)
    hscroll:DockMargin(8, 8, 8, 8)
    cat:AddItem(hscroll)

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
    combo:Dock(TOP)

    cat = vgui.Create('MantleCategory', panel)
    cat:Dock(TOP)
    cat:SetText('Выпадающий список')
    cat:SetActive(true)
    combo:DockMargin(8, 8, 8, 8)
    cat:AddItem(combo)

    local tableExample = vgui.Create('MantleTable')
    tableExample:Dock(TOP)
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

    cat = vgui.Create('MantleCategory', panel)
    cat:Dock(TOP)
    cat:SetText('Таблица')
    cat:SetActive(true)
    tableExample:DockMargin(8, 8, 8, 8)
    cat:AddItem(tableExample)

    local panelCat = vgui.Create('Panel')
    panelCat:Dock(TOP)
    panelCat:SetTall(170)
    panelCat.Paint = nil

    local catDemo = vgui.Create('MantleCategory', panelCat)
    catDemo:Dock(TOP)
    catDemo:SetCenterText(true)
    catDemo:SetActive(true)

    local panGreen = vgui.Create('MantlePanel')
    panGreen:Dock(TOP)
    panGreen:SetTall(50)
    panGreen:SetCustomColor(Color(93, 179, 101))
    catDemo:AddItem(panGreen)

    local panRed = vgui.Create('MantlePanel')
    panRed:Dock(TOP)
    panRed:SetTall(50)
    panRed:SetCustomColor(Color(179, 110, 93))
    catDemo:AddItem(panRed)

    cat = vgui.Create('MantleCategory', panel)
    cat:Dock(TOP)
    cat:SetText('Категория')
    cat:SetActive(true)
    panelCat:DockMargin(8, 8, 8, 8)
    cat:AddItem(panelCat)

    local slider = vgui.Create('MantleSlideBox')
    slider:Dock(TOP)
    slider:SetRange(0, 5)
    slider:SetText('Тестовый ползунок')

    cat = vgui.Create('MantleCategory', panel)
    cat:Dock(TOP)
    cat:SetText('Слайдер')
    cat:SetActive(true)
    slider:DockMargin(8, 8, 8, 8)
    cat:AddItem(slider)

    local panelTexts = vgui.Create('MantlePanel')
    panelTexts:Dock(TOP)
    panelTexts:DockPadding(8, 8, 8, 8)
    panelTexts:SetTall(418)
    panelTexts:SetColorAlpha(2)
    panelTexts:SetRadius(32)

    local panelText1 = vgui.Create('MantlePanel', panelTexts)
    panelText1:Dock(TOP)
    panelText1:SetTall(70)
    panelText1:SetColorAlpha(1)
    panelText1:SetRadius(32)

    local text1 = vgui.Create('MantleText', panelText1)
    text1:Dock(FILL)
    text1:SetPadding(10)
    text1:SetText('MantleText - компонент для аккуратного вывода многострочного текста. Текст автоматически переносится по ширине и сокращается троеточием')

    local panelText2 = vgui.Create('MantlePanel', panelTexts)
    panelText2:Dock(TOP)
    panelText2:SetTall(130)
    panelText2:SetColorAlpha(1)
    panelText2:SetRadius(32)

    local text2 = vgui.Create('MantleText', panelText2)
    text2:Dock(FILL)
    text2:SetPadding(12)
    text2:SetFont('Fated.20')
    text2:SetText('Центрирование: горизонталь + вертикаль. Текст выровнен по центру блока.')
    text2:SetAlign(TEXT_ALIGN_CENTER)
    text2:SetVAlign('center')

    local panelText3 = vgui.Create('MantlePanel', panelTexts)
    panelText3:Dock(TOP)
    panelText3:SetTall(60)
    panelText3:SetColorAlpha(1)
    panelText3:SetRadius(32)

    local text3 = vgui.Create('MantleText', panelText3)
    text3:Dock(FILL)
    text3:SetPadding(8)
    text3:SetText('ОченьДлинноеСловоБезПробеловКотороеНужноОтделитьЧтобыНеПорвалосьОформление')

    local panelText4 = vgui.Create('MantlePanel', panelTexts)
    panelText4:Dock(TOP)
    panelText4:SetTall(80)
    panelText4:SetColorAlpha(1)
    panelText4:SetRadius(32)

    local text4 = vgui.Create('MantleText', panelText4)
    text4:Dock(FILL)
    text4:SetPadding(8)
    text4:SetFont('Fated.16')
    text4:SetText([[
        Это длинный пример текста, который занимает несколько строк. Если блок небольшой по высоте - последняя видимая строка будет усечена с троеточием, чтобы не порвать верстку и не выходить за пределы панели нашего меню.
    ]])

    cat = vgui.Create('MantleCategory', panel)
    cat:Dock(TOP)
    cat:SetText('Текст')
    cat:SetActive(true)
    panelTexts:DockMargin(8, 8, 8, 8)
    cat:AddItem(panelTexts)

    return panel
end

Mantle.menu.registerTab('ui', {
    order = 2,
    title = 'UI Элементы',
    description = 'Демонстрация всех графических компонентов.',
    icon = Material('icon16/chart_pie.png'),
    build = build
})
