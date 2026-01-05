function CreateMantleSettingsTab()
    local panel = vgui.Create('MantleScrollPanel')

    local categoryTheme = vgui.Create('MantleCategory', panel)
    categoryTheme:Dock(TOP)
    categoryTheme:DockMargin(0, 6, 0, 0)
    categoryTheme:SetText('Изменение цветовой темы')
    categoryTheme:SetActive(true)

    local themes = vgui.Create('MantleComboBox')
    themes:Dock(TOP)
    themes:SetPlaceholder('Выберите тему интерфейса')
    themes:AddChoice('Тёмная (dark)', 'dark')
    themes.OnSelect = function(_, _, data)
        RunConsoleCommand('mantle_theme', data)
    end
    categoryTheme:AddItem(themes)

    local listThemeColors = vgui.Create('DIconLayout')
    listThemeColors:Dock(TOP)
    listThemeColors:DockMargin(6, 8, 6, 0)
    listThemeColors:SetTall(164)
    listThemeColors:SetSpaceX(8)
    listThemeColors:SetSpaceY(8)
    categoryTheme:AddItem(listThemeColors)

    for colId, _ in pairs(Mantle.color) do
        local panCol = vgui.Create('Panel', listThemeColors)
        panCol:SetSize(80, 80)
        panCol.Paint = function(_, w, h)
            RNDX().Rect(0, 0, w, h)
                :Rad(16)
                :Color(Mantle.color[colId])
                :Shape(RNDX.SHAPE_IOS)
            :Draw()
            draw.SimpleText(colId, 'Fated.Small', w * 0.5, h * 0.5, color_black, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end
    end

    return panel
end
