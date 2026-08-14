local menu = Mantle.menu

local function build()
    local panel = menu.createTabPanel()
    local menuWide = menu.getMenuWide()

    local btnFrame = vgui.Create('MantleBtn')
    btnFrame:SetTxt('Посмотреть пример')
    btnFrame:SetTall(32)
    btnFrame:DockMargin(menuWide * 0.3, 6, menuWide * 0.3, 0)
    btnFrame:Dock(TOP)
    btnFrame.DoClick = function()
        --[[
            Окно
        ]]--
        local frame = vgui.Create('DFrame')
        frame:SetSize(400, 300)
        frame:Center()
        frame:MakePopup()
        Mantle.ui.frame(frame, 'Окно', 400, 300, true, true)

        --[[
            Панель прокрутки
        ]]--
        local scroll = vgui.Create('DScrollPanel', frame)
        scroll:Dock(FILL)
        Mantle.ui.sp(scroll)

        --[[
            Кнопка
        ]]--
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

        --[[
            Слайдер
        ]]--
        local slider1 = Mantle.ui.slidebox(scroll, 'Слайдер (0-5)', 0, 5, 'r_skybox', 0)
        slider1:DockMargin(10, 20, 10, 0)

        local slider2 = Mantle.ui.slidebox(scroll, 'Слайдер (0-1)', 0, 1, 'cl_drawhud', 2)
        slider2:DockMargin(10, 20, 10, 0)

        --[[
            Поле ввода
        ]]--
        local entry1, entry_bg1 = Mantle.ui.desc_entry(scroll, 'Поле с заголовком', 'Введите текст...')
        entry_bg1:DockMargin(10, 20, 10, 0)

        local entry2, entry_bg2 = Mantle.ui.desc_entry(scroll, nil, 'Поле без заголовка')
        entry_bg2:DockMargin(10, 20, 10, 0)

        --[[
            Тумблер
        ]]--
        local checkbox1, checkbox_btn1 = Mantle.ui.checkbox(scroll, 'Тумблер с ConVar', 'cl_drawhud')
        checkbox1:DockMargin(10, 20, 10, 0)

        local checkbox2, checkbox_btn2 = Mantle.ui.checkbox(scroll, 'Тумблер без ConVar')
        checkbox2:DockMargin(10, 20, 10, 0)

        --[[
            Вкладки
        ]]--
        local panelTabs = vgui.Create('DPanel', scroll)
        panelTabs:Dock(TOP)
        panelTabs:SetTall(250)
        panelTabs.Paint = nil

        local tabs = Mantle.ui.panel_tabs(panelTabs)
        tabs:DockMargin(10, 20, 10, 0)

        local tab1 = vgui.Create('DPanel')
        tab1.Paint = function(_, w, h)
            draw.SimpleText('Вкладка 1', 'Fated.20', w / 2, h / 2, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end
        tabs:AddTab('Вкладка 1', tab1, 'icon16/page_white.png')

        local tab2 = vgui.Create('DPanel')
        tab2.Paint = function(_, w, h)
            draw.SimpleText('Вкладка 2', 'Fated.20', w / 2, h / 2, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end
        tabs:AddTab('Вкладка 2', tab2, 'icon16/page_white_edit.png', Color(100, 200, 100))

        local tab3 = vgui.Create('DPanel')
        tab3.Paint = function(_, w, h)
            draw.SimpleText('Вкладка 3', 'Fated.20', w / 2, h / 2, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end
        tabs:AddTab('Вкладка 3', tab3, 'icon16/page_white_gear.png', nil, Color(200, 100, 100))

        tabs:ActiveTab('Вкладка 1')
    end

    menu.createCategory(panel, {
        title = 'Элементы',
        open = true,
        rows = {
            { name = 'Mantle.ui.frame(object frame, string title, int w, int h, bool cls_btn, bool open_anim)', desc = 'Оформление для DFrame' },
            { name = 'Mantle.ui.sp(object scroll)', desc = 'Оформление для DScrollPanel' },
            { name = 'Mantle.ui.btn(object btn, mat icon, int icon_size, color col, int rad, bool off_grad, color hov, bool off_hov)', desc = 'Оформление для DButton' },
            { name = 'Mantle.ui.slidebox(object parent, string label, int min_value, int max_value, string convar, int decimals)', desc = 'Слайдер с подписью и текущим значением, привязанный к ConVar' },
            { name = 'Mantle.ui.desc_entry(object parent, string title, string placeholder, bool off_title)', desc = 'Поле ввода с заголовком. Возвращает entry и его фон' },
            { name = 'Mantle.ui.checkbox(object parent, string text, string convar)', desc = 'Тумблер. Возвращает панель и кнопку' },
            { name = 'Mantle.ui.panel_tabs(object parent)', desc = 'Панель вкладок. Настройка через :AddTab(title, panel, icon, col, col_hov) и :ActiveTab(title)' }
        },
        demo = btnFrame
    })

    return panel
end

menu.registerTab('legacy', {
    order = 4,
    title = 'Legacy UI',
    description = 'Старые функции для поддержания древних скриптов.',
    icon = Material('icon16/exclamation.png'),
    build = build
})
