local menu = Mantle.menu

local icon = Material('icon16/cog.png')

local function build()
    local panel = menu.createTabPanel()
    local forcedTheme = Mantle.ui.getForcedThemeName()

    local checkboxDepth = vgui.Create('MantleCheckBox', panel)
    checkboxDepth:Dock(TOP)
    checkboxDepth:SetTxt('Выделение элементов (Тени)')
    checkboxDepth:SetConvar('mantle_depth_ui')

    local checkboxBlur = vgui.Create('MantleCheckBox', panel)
    checkboxBlur:Dock(TOP)
    checkboxBlur:DockMargin(0, 6, 0, 0)
    checkboxBlur:SetTxt('Размытие фона')
    checkboxBlur:SetConvar('mantle_blur')

    local checkboxSmooth = vgui.Create('MantleCheckBox', panel)
    checkboxSmooth:Dock(TOP)
    checkboxSmooth:DockMargin(0, 6, 0, 0)
    checkboxSmooth:SetTxt('Эффект плавности')
    checkboxSmooth:SetConvar('mantle_smooth')

    local categoryTheme = vgui.Create('MantleCategory', panel)
    categoryTheme:Dock(TOP)
    categoryTheme:DockMargin(0, 6, 0, 0)
    categoryTheme:SetText('Изменение цветовой темы')
    categoryTheme:SetActive(true)

    menu.createDoc(categoryTheme, 'Файл config/theme.lua', 'forced = "тема" - принудительная тема для всех игроков, enabled = { red = true } - какие темы разрешены.')

    menu.createDoc(categoryTheme, 'Файл config/colors.lua', 'Здесь создаются и редактируются цветовые пресеты для тем.')

    local comboboxTheme = vgui.Create('MantleComboBox')
    comboboxTheme:Dock(TOP)
    comboboxTheme:SetPlaceholder('Выберите тему интерфейса')

    for _, theme in ipairs(Mantle.ui.getAvailableThemes()) do
        comboboxTheme:AddChoice(theme.title, theme.id)

        if theme.id == Mantle.ui.getActiveThemeName() then
            comboboxTheme:SetValue(theme.title)
        end
    end

    comboboxTheme.OnSelect = function(_, _, data)
        LocalPlayer():ConCommand('mantle_theme ' .. data)
    end

    if forcedTheme == '' then
        categoryTheme:AddItem(comboboxTheme)
    else
        menu.createDoc(categoryTheme, 'Серверная тема - "' .. forcedTheme .. '"', 'Владелец сервера принудительно выбрал её для всех, сменить на другую нельзя.')
    end

    local listThemeColors = vgui.Create('DIconLayout')
    listThemeColors:Dock(TOP)
    listThemeColors:DockMargin(6, 8, 6, 0)
    listThemeColors:SetTall(164)
    listThemeColors:SetSpaceX(8)
    listThemeColors:SetSpaceY(8)
    categoryTheme:AddItem(listThemeColors)

    for colId, value in pairs(Mantle.color) do
        if IsColor(value) then
            local panCol = vgui.Create('DPanel', listThemeColors)
            panCol:SetSize(78, 78)
            panCol.Paint = function(_, w, h)
                RNDX.Rect(0, 0, w, h)
                    :Rad(16)
                    :Color(Mantle.color[colId])
                :Draw()
                draw.SimpleText(colId, 'Fated.12', w * 0.5, h * 0.5, color_black, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            end
        end
    end

    return panel
end

menu.registerTab('settings', {
    order = 5,
    title = 'Настройки',
    description = 'Конфигурационные настройки библиотеки.',
    icon = icon,
    build = build
})
