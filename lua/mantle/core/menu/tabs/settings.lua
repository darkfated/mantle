local menu = Mantle.menu

local icon = Material('icon16/cog.png')

local function createSettingsTab()
    local panel = menu.createTabPanel('Настройки', 'Глобальные настройки Mantle: темы, эффекты и глубины элементов.', icon)
    local forcedTheme = Mantle.ui.getForcedThemeName()

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

    menu.createInfo({
        'lua/mantle/config/theme.lua',
        'forced фиксирует одну тему для всех, enabled включает и выключает темы из пользовательского выбора.'
    }, categoryTheme)

    menu.createInfo({
        "forced = '' / forced = 'red'",
        'Пустая строка оставляет выбор игроку. Конкретный id темы принудительно включает только её для всех.'
    }, categoryTheme)

    menu.createInfo({
        'enabled = { red = false, blue = true, ... }',
        'Позволяет скрыть отдельные темы из выбора. Если доступных тем не останется, библиотека откатится на fallback-палитру.'
    }, categoryTheme)

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
        RunConsoleCommand('mantle_theme', data)
    end

    if forcedTheme == '' then
        categoryTheme:AddItem(comboboxTheme)
    else
        menu.createInfo({
            'Mantle.config.theme.forced = "' .. forcedTheme .. '"',
            'Тема зафиксирована в config/theme.lua. Игрок не может переключить её на другую.'
        }, categoryTheme)
    end

    local listThemeColors = vgui.Create('DIconLayout')
    listThemeColors:Dock(TOP)
    listThemeColors:DockMargin(6, 8, 6, 0)
    listThemeColors:SetTall(164)
    listThemeColors:SetSpaceX(8)
    listThemeColors:SetSpaceY(8)
    categoryTheme:AddItem(listThemeColors)

    for colId, value in pairs(Mantle.color) do
        if menu.isColor(value) then
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
    end

    return panel
end

menu.registerTab('settings', {
    order = 5,
    title = 'Настройки',
    description = 'Глобальные настройки Mantle и цветовые темы',
    icon = icon,
    create = createSettingsTab
})
