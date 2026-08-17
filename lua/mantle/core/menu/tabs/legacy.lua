local menu = Mantle.menu

local function build()
    local panel = menu.createTabPanel()

    local btnFrame = vgui.Create('MantleBtn')
    btnFrame:SetTxt('Посмотреть пример')
    btnFrame:SetTall(32)
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
        btn1:DockMargin(8, 8, 8, 8)
        btn1:SetText('Обычная кнопка')
        Mantle.ui.btn(btn1)

        local btn2 = vgui.Create('DButton', scroll)
        btn2:Dock(TOP)
        btn2:DockMargin(8, 8, 8, 8)
        btn2:SetText('Кнопка с иконкой')
        Mantle.ui.btn(btn2, Material('icon16/accept.png'), 16)

        local btn3 = vgui.Create('DButton', scroll)
        btn3:Dock(TOP)
        btn3:DockMargin(8, 8, 8, 8)
        btn3:SetText('Кнопка без градиента')
        Mantle.ui.btn(btn3, nil, nil, nil, nil, true)

        local btn4 = vgui.Create('DButton', scroll)
        btn4:Dock(TOP)
        btn4:DockMargin(8, 8, 8, 8)
        btn4:SetText('Кнопка без ховера')
        Mantle.ui.btn(btn4, nil, nil, nil, nil, nil, nil, true)

        --[[
            Слайдер
        ]]--
        local slider1 = Mantle.ui.slidebox(scroll, 'Слайдер (0-5)', 0, 5, 'r_skybox', 0)
        slider1:DockMargin(8, 8, 8, 8)

        local slider2 = Mantle.ui.slidebox(scroll, 'Слайдер (0-1)', 0, 1, 'cl_drawhud', 2)
        slider2:DockMargin(8, 8, 8, 8)

        --[[
            Поле ввода
        ]]--
        local entry1, entry_bg1 = Mantle.ui.desc_entry(scroll, 'Поле с заголовком', 'Введите текст...')
        entry_bg1:DockMargin(8, 8, 8, 8)

        local entry2, entry_bg2 = Mantle.ui.desc_entry(scroll, nil, 'Поле без заголовка')
        entry_bg2:DockMargin(8, 8, 8, 8)

        --[[
            Тумблер
        ]]--
        local checkbox1, checkbox_btn1 = Mantle.ui.checkbox(scroll, 'Тумблер с ConVar', 'cl_drawhud')
        checkbox1:DockMargin(8, 8, 8, 8)

        local checkbox2, checkbox_btn2 = Mantle.ui.checkbox(scroll, 'Тумблер без ConVar')
        checkbox2:DockMargin(8, 8, 8, 8)

        --[[
            Вкладки
        ]]--
        local panelTabs = vgui.Create('Panel', scroll)
        panelTabs:Dock(TOP)
        panelTabs:DockMargin(8, 8, 8, 8)
        panelTabs:SetTall(250)
        panelTabs.Paint = nil

        local tabs = Mantle.ui.panel_tabs(panelTabs)

        local tab1 = vgui.Create('Panel')
        tab1.Paint = function(_, w, h)
            draw.SimpleText('Вкладка 1', 'Fated.20', w / 2, h / 2, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end
        tabs:AddTab('Вкладка 1', tab1, 'icon16/page_white.png')

        local tab2 = vgui.Create('Panel')
        tab2.Paint = function(_, w, h)
            draw.SimpleText('Вкладка 2', 'Fated.20', w / 2, h / 2, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end
        tabs:AddTab('Вкладка 2', tab2, 'icon16/page_white_edit.png', Color(100, 200, 100))

        local tab3 = vgui.Create('Panel')
        tab3.Paint = function(_, w, h)
            draw.SimpleText('Вкладка 3', 'Fated.20', w / 2, h / 2, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end
        tabs:AddTab('Вкладка 3', tab3, 'icon16/page_white_gear.png', nil, Color(200, 100, 100))

        tabs:ActiveTab('Вкладка 1')
    end

    menu.createCategory(panel, {
        title = 'Элементы',
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
