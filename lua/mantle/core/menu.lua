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
        local panelInfo = vgui.Create('Panel', pan)
        panelInfo:Dock(TOP)
        panelInfo:SetTall(56)

        surface.SetFont('Fated.20')
        local infoWide = surface.GetTextSize(info[1]) + 16
        panelInfo.Paint = function(_, w, h)
            draw.RoundedBox(0, 0, 0, w, h, Mantle.color.panel_alpha[2])
            draw.RoundedBoxEx(6, 0, 0, infoWide, 30, Mantle.color.panel[1], false, true, false, true)
            draw.SimpleText(info[1], 'Fated.20', 9, 5, color_black)
            draw.SimpleText(info[1], 'Fated.20', 8, 4, color_white)
            draw.SimpleText(info[2], 'Fated.16', 8, 34, color_white)
        end
    end

    local isFirstTitle = true

    local function CreateTitle(title, info_table, pan)
        local panelTitle = vgui.Create('Panel', pan)
        panelTitle:Dock(TOP)
        panelTitle:DockMargin(0, isFirstTitle and 0 or 12, 0, 0)
        panelTitle:SetTall(24)
        panelTitle.Paint = function(_, w, h)
            draw.RoundedBoxEx(6, 0, 0, w, h, Mantle.color.panel_alpha[2], true, true, false, false)
            draw.SimpleText(title, 'Fated.20', w * 0.5, 12, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end

        if isFirstTitle then
            isFirstTitle = nil
        end

        for _, info in ipairs(info_table) do
            CreateInfo(info, pan)
        end
    end

    local function CreateTabElements()
        local panel = vgui.Create('MantleScrollPanel')
        local menuWide = menuMantle:GetWide()

        CreateTitle('Кнопка (MantleBtn)', {
            {':SetHover(bool is_hover)', 'Включить/выключить цвет наведения (дефолт - true)'},
            {':SetFont(string font)', 'Установить шрифт'},
            {':SetRadius(int rad)', 'Установить размер закругления'},
            {':SetIcon(string icon, int icon_size)', 'Установить иконку'},
            {':SetTxt(string text)', 'Установить текст'},
            {':SetColor(color col)', 'Установить цвет кнопки'},
            {':SetColorHover(color col)', 'Установить цвет наведения'},
            {':SetGradient(bool is_grad)', 'Включить/выключить градиент (дефолт - true)'},
            {':SetRipple(bool enable)', 'Включить/выключить ripple-эффект (волна при клике, дефолт - false)'}
        }, panel)

        local button = vgui.Create('MantleBtn', panel)
        button:Dock(TOP)
        button:DockMargin(menuWide * 0.2, 6, menuWide * 0.2, 0)
        button:SetTall(40)
        button:SetTxt('Click')
        button:SetRipple(true)

        CreateTitle('Тумблер (MantleCheckBox)', {
            {':SetTxt(string text)', 'Установить текст'},
            {':GetBool()', 'Получить bool-значение тумблера'},
            {':SetConvar(string convar)', 'Установить ConVar'},
            {':SetDescription(string desc)', 'Установить описание для тумблера'}
        }, panel)

        local checkbox = vgui.Create('MantleCheckBox', panel)
        checkbox:Dock(TOP)
        checkbox:DockMargin(menuWide * 0.1, 6, menuWide * 0.1, 0)
        checkbox:SetTxt('Отображение HUD')
        checkbox:SetConvar('cl_drawhud')
        checkbox:SetDescription('Показать информационный интерфейс')
        
        CreateTitle('Ввод текста (MantleEntry)', {
            {':SetTitle(string text)', 'Установить заголовок'},
            {':SetPlaceholder(string text)', 'Установить фоновый текст (появляется при пустом поле)'},
            {':GetValue()', 'Получить string-значение поля'}
        }, panel)

        local entry = vgui.Create('MantleEntry', panel)
        entry:Dock(TOP)
        entry:DockMargin(menuWide * 0.15, 6, menuWide * 0.15, 0)
        entry:SetTitle('Никнейм')
        entry:SetPlaceholder('darkf')

        CreateTitle('Окно (MantleFrame)', {
            {':SetAlphaBackground(bool is_alpha)', 'Включить/выключить прозрачность окна (дефолт - false)'},
            {':SetTitle(string title)', 'Установить заголовок'},
            {':SetCenterTitle(string title)', 'Установить центральный заголовок'},
            {':ShowAnimation()', 'Активировать анимацию при появлении меню'},
            {':DisableCloseBtn()', 'Скрыть кнопку закрытия'},
            {':SetDraggable(bool is_draggable)', 'Включить/выключить перемещение окна'}
        }, panel)

        local btnFrame = vgui.Create('MantleBtn', panel)
        btnFrame:Dock(TOP)
        btnFrame:DockMargin(menuWide * 0.2, 6, menuWide * 0.2, 0)
        btnFrame:SetTall(40)
        btnFrame:SetTxt('Открыть окно')
        btnFrame.DoClick = function()
            local frame = vgui.Create('MantleFrame')
            frame:SetSize(400, 300)
            frame:Center()
            frame:MakePopup()
            frame:SetCenterTitle('Центр')
        end

        CreateTitle('Панель прокрутки (MantleScrollPanel)', {}, panel)

        local sp = vgui.Create('MantleScrollPanel', panel)
        sp:Dock(TOP)
        sp:DockMargin(menuWide * 0.11, 6, menuWide * 0.11, 0)
        sp:SetTall(200)

        for spK = 1, 20 do
            local spPanel = vgui.Create('DPanel', sp)
            spPanel:Dock(TOP)
            spPanel:DockMargin(0, 0, 6, 6)
            spPanel.Paint = function(_, w, h)
                draw.RoundedBox(6, 0, 0, w, h, Mantle.color.panel_alpha[1])
            end
        end

        CreateTitle('Вкладки (MantleTabs)', {
            {':AddTab(string name, object panel, string icon)', 'Добавить вкладку'},
            {':SetTabStyle(string style)', 'Установить стиль вкладок: "modern" (сверху, по умолчанию) или "classic" (слева)'},
            {':SetTabHeight(int height)', 'Высота вкладки (modern)'},
            {':SetIndicatorHeight(int height)', 'Высота индикатора активной вкладки (modern)'}
        }, panel)

        local testTabs = vgui.Create('MantleTabs', panel)
        testTabs:Dock(TOP)
        testTabs:DockMargin(menuWide * 0.05, 6, menuWide * 0.05, 0)
        testTabs:SetTall(120)

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

        CreateTitle('Категория (MantleCategory)', {
            {':SetText(string name)', 'Установить название'},
            {':AddItem(object panel)', 'Добавить в категорию элемент'},
            {':SetColor(color col)', 'Установить кастомный цвет категории'}
        }, panel)

        local cat = vgui.Create('MantleCategory', panel)
        cat:Dock(TOP)
        cat:DockMargin(0, 6, 0, 0)

        local panGreen = vgui.Create('DPanel', cat)
        panGreen:Dock(TOP)
        panGreen:SetTall(50)
        panGreen.Paint = function(_, w, h) draw.RoundedBox(8, 0, 0, w, h, Color(93, 179, 101)) end
        cat:AddItem(panGreen)

        local panRed = vgui.Create('DPanel', cat)
        panRed:Dock(TOP)
        panRed:DockMargin(0, 6, 0, 0)
        panRed:SetTall(50)
        panRed.Paint = function(_, w, h) draw.RoundedBox(8, 0, 0, w, h, Color(179, 110, 93)) end
        cat:AddItem(panRed)

        CreateTitle('Слайдер (MantleSlideBox)', {
            {':SetRange(int min_value, int max_value, int decimals)', 'Сделать диапазон слайдера с точностью (дефолт точность - 0)'},
            {':SetConvar(string convar)', 'Установить ConVar'},
            {':SetText(string text)', 'Установить текстовое обозначение'},
        }, panel)

        local slider = vgui.Create('MantleSlideBox', panel)
        slider:Dock(TOP)
        slider:DockMargin(menuWide * 0.2, 6, menuWide * 0.2, 0)
        slider:SetRange(0, 4)
        slider:SetConvar('net_graph')
        slider:SetText('График')

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
                        chat.AddText('Привет всем!')
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

                Mantle.ui.ratial_panel(config)
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

    tabs:AddTab('Настройки', CreateTabSettings(), Material('icon16/bullet_wrench.png'))
end

concommand.Add('mantle_menu', CreateMenu)
