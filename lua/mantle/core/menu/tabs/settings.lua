local menu = Mantle.menu

local function build()
    local panel = menu.createTabPanel()
    local forcedTheme = Mantle.ui.getForcedThemeName()

    local checkboxBlur = vgui.Create('MantleCheckBox', panel)
    checkboxBlur:Dock(TOP)
    checkboxBlur:SetTxt('Размытие фона')
    checkboxBlur:SetConvar('mantle_blur')

    local checkboxSmooth = vgui.Create('MantleCheckBox', panel)
    checkboxSmooth:Dock(TOP)
    checkboxSmooth:SetTxt('Эффект плавности')
    checkboxSmooth:SetConvar('mantle_smooth')

    local categoryTheme = vgui.Create('MantleCategory', panel)
    categoryTheme:Dock(TOP)
    categoryTheme:SetText('Изменение цветовой темы')
    categoryTheme:SetActive(true)

    if forcedTheme == '' then
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

        categoryTheme:AddItem(comboboxTheme)
    end

    local colorIds = {}
    for colId, value in pairs(Mantle.color) do
        if IsColor(value) then
            table.insert(colorIds, colId)
        end
    end
    table.sort(colorIds)

    for _, colId in ipairs(colorIds) do
        local value = Mantle.color[colId]
        menu.createColorRow(categoryTheme, colId, value)
    end

    return panel
end

menu.registerTab('settings', {
    order = 1,
    title = 'Настройки',
    description = 'Конфигурационные настройки библиотеки.',
    icon = Material('icon16/cog.png'),
    build = build
})
