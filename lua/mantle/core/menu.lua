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
            draw.RoundedBox(0, 4, 0, w - 4, h, Mantle.color.panel_alpha[2])
            draw.RoundedBox(6, 0, 0, infoWide, 30, Mantle.color.panel[1])
            draw.SimpleText(info[1], 'Fated.20', 8, 4, color_white)
            draw.SimpleText(info[2], 'Fated.16', 8, 34, color_white)
        end

        pan:AddItem(panelInfo)
    end

    local function CreateCategory(name, info_table, pan, ui_element)
        local panel = vgui.Create('MantleCategory', pan)
        panel:Dock(TOP)
        panel:DockMargin(0, 0, 0, 6)
        panel:SetText(name)

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
                draw.RoundedBox(6, 0, 0, w, h, Mantle.color.panel_alpha[1])
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
            draw.RoundedBox(6, 0, 0, w, h, Color(53, 98, 40))
        end
        testTabs:AddTab('Test1', testTab1)
        local testTab2 = vgui.Create('DPanel')
        testTab2.Paint = function(_, w, h)
            draw.RoundedBox(6, 0, 0, w, h, Color(108, 41, 45))
        end
        testTabs:AddTab('Test2', testTab2)

        local testTabs2 = vgui.Create('MantleTabs', panelTabs) -- classic стиль
        testTabs2:SetTall(90)
        testTabs2:DockMargin(menuWide * 0.05, 10, menuWide * 0.05, 0)
        testTabs2:Dock(TOP)
        testTabs2:SetTabStyle('classic')
        local testTab3 = vgui.Create('DPanel')
        testTab3.Paint = function(_, w, h)
            draw.RoundedBox(6, 0, 0, w, h, Color(51, 61, 116))
        end
        testTabs2:AddTab('Test3', testTab3)
        local testTab4 = vgui.Create('DPanel')
        testTab4.Paint = function(_, w, h)
            draw.RoundedBox(6, 0, 0, w, h, Color(138, 89, 43))
        end
        testTabs2:AddTab('Test4', testTab4)

        CreateCategory('Вкладки (MantleTabs)', {
            {':SetTabStyle(string style)', 'Установить стиль вкладок (modern или classic)'},
            {':SetTabHeight(int height)', 'Установить высоту вкладок'},
            {':SetIndicatorHeight(int height)', 'Установить высоту индикатора вкладок'},
            {':AddTab(string name, object panel, string icon)', 'Добавить вкладку'}
        }, panel, panelTabs)

        -- Категория
        local cat = vgui.Create('MantleCategory')
        cat:SetTall(110)
        cat:Dock(TOP)
        cat:SetCenterText(true)
        local panGreen = vgui.Create('DPanel')
        panGreen:Dock(TOP)
        panGreen:SetTall(50)
        panGreen.Paint = function(_, w, h) draw.RoundedBox(8, 0, 0, w, h, Color(93, 179, 101)) end
        cat:AddItem(panGreen)
        local panRed = vgui.Create('DPanel')
        panRed:Dock(TOP)
        panRed:DockMargin(0, 6, 0, 0)
        panRed:SetTall(50)
        panRed.Paint = function(_, w, h) draw.RoundedBox(8, 0, 0, w, h, Color(179, 110, 93)) end
        cat:AddItem(panRed)
        CreateCategory('Категория (MantleCategory)', {
            {':SetText(string name)', 'Установить название'},
            {':AddItem(object panel)', 'Добавить в категорию элемент'},
            {':SetColor(color col)', 'Установить кастомный цвет категории'},
            {':SetCenterText(bool is_centered)', 'Установить центрирование названия'}
        }, panel, cat)

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
            {':SetText(string text)', 'Установить текстовое обозначение'}
        }, panel, slider)

        return panel
    end

    tabs:AddTab('UI Элементы', CreateTabElements(), Material('icon16/page_white.png'))

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
                local config = {
                    {name = 'Вывести 1', func = function() chat.AddText('1') end},
                    {name = 'Вывести 2', func = function() chat.AddText('2') end},
                    {name = 'Вывести 3', func = function() chat.AddText('3') end},
                    {name = 'Вывести 4', func = function() chat.AddText('4') end},
                    {name = 'Вывести 5', func = function() chat.AddText('5') end},
                    {name = 'Вывести 6', func = function() chat.AddText('6') end}
                }

                Mantle.ui.radial_panel(config)
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
    
    tabs:AddTab('Всплывающие', CreateShowMenus(), Material('icon16/database.png'))

    local function CreateTabSettings()
        local panel = vgui.Create('MantleScrollPanel')

        local buttonTheme = vgui.Create('Button', panel)
        buttonTheme:Dock(TOP)
        buttonTheme:SetTall(40)
        buttonTheme:SetText('')
        buttonTheme.Paint = function(_, w, h)
            draw.RoundedBox(8, 0, 0, w, h, Mantle.color.header)
            draw.RoundedBox(8, 1, 1, w - 2, h - 2, buttonTheme.col)
            draw.SimpleText('Изменить Цветовую тему', 'Fated.18', w * 0.5, h * 0.5, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end

        local function ChangeTheme()
            local tableTheme = util.JSONToTable(GetConVar('mantle_col_theme'):GetString())
            buttonTheme.col = Color(tableTheme[1], tableTheme[2], tableTheme[3])
        end

        ChangeTheme()

        buttonTheme.DoClick = function()
            Mantle.ui.color_picker(function(col)
                RunConsoleCommand('mantle_col_theme', util.TableToJSON({col.r, col.g, col.b}))

                timer.Simple(0, function()
                    ChangeTheme()
                    Mantle.func.SetCustomColors()
                end)
            end, buttonTheme.col)
        end

        local buttonThemeBtn = vgui.Create('Button', panel)
        buttonThemeBtn:Dock(TOP)
        buttonThemeBtn:DockMargin(0, 6, 0, 0)
        buttonThemeBtn:SetTall(40)
        buttonThemeBtn:SetText('')
        buttonThemeBtn.Paint = function(_, w, h)
            draw.RoundedBox(8, 0, 0, w, h, Mantle.color.header)
            draw.RoundedBox(8, 1, 1, w - 2, h - 2, buttonThemeBtn.col)
            draw.SimpleText('Изменить Цвет кнопок при наведении', 'Fated.18', w * 0.5, h * 0.5, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end

        local function ChangeHoverBtn()
            local tableHoverButton = util.JSONToTable(GetConVar('mantle_col_hoverbtn'):GetString())
            buttonThemeBtn.col = Color(tableHoverButton[1], tableHoverButton[2], tableHoverButton[3])
        end

        ChangeHoverBtn()

        buttonThemeBtn.DoClick = function()
            Mantle.ui.color_picker(function(col)
                RunConsoleCommand('mantle_col_hoverbtn', util.TableToJSON({col.r, col.g, col.b}))

                timer.Simple(0, function()
                    ChangeHoverBtn()
                    Mantle.func.SetCustomColors()
                end)
            end, buttonTheme.col)
        end

        local buttonResetCustomColors = vgui.Create('MantleBtn', panel)
        buttonResetCustomColors:Dock(TOP)
        buttonResetCustomColors:DockMargin(0, 6, 0, 0)
        buttonResetCustomColors:SetTall(30)
        buttonResetCustomColors:SetTxt('Сбросить пользовательские настройки')
        buttonResetCustomColors.DoClick = function()
            RunConsoleCommand('mantle_col_theme', GetConVar('mantle_col_theme'):GetDefault())
            RunConsoleCommand('mantle_col_hoverbtn', GetConVar('mantle_col_hoverbtn'):GetDefault())

            timer.Simple(0, function()
                Mantle.func.SetCustomColors()
            end)
        end

        return panel
    end

    tabs:AddTab('Настройки', CreateTabSettings())
end

concommand.Add('mantle_menu', CreateMenu)
