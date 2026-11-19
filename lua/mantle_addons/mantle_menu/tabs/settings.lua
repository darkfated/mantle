local function L(key)
    return Mantle.lang.get('mantle_menu', key)
end

local function buildPanel(tab)
    local panel = vgui.Create('MantleScrollPanel')

    local forcedTheme = Mantle.ui.getForcedThemeName()

    local checkboxBlur = vgui.Create('MantleCheckBox', panel)
    checkboxBlur:Dock(TOP)
    checkboxBlur:SetTxt(L('settings_blur'))
    checkboxBlur:SetConvar('mantle_blur')

    local checkboxSmooth = vgui.Create('MantleCheckBox', panel)
    checkboxSmooth:Dock(TOP)
    checkboxSmooth:SetTxt(L('settings_smooth'))
    checkboxSmooth:SetConvar('mantle_smooth')

    local cat = vgui.Create('MantleCategory', panel)
    cat:Dock(TOP)
    cat:SetText(L('settings_theme'))
    cat:SetActive(true)

    if forcedTheme == '' then
        local comboboxTheme = vgui.Create('MantleComboBox')
        comboboxTheme:Dock(TOP)
        comboboxTheme:SetPlaceholder(L('settings_theme_placeholder'))

        for _, theme in ipairs(Mantle.ui.getAvailableThemes()) do
            comboboxTheme:AddChoice(theme.title, theme.id)
            if theme.id == Mantle.ui.getActiveThemeName() then
                comboboxTheme:SetValue(theme.title)
            end
        end

        comboboxTheme.OnSelect = function(_, _, data)
            Mantle.ui.setTheme(data)
        end

        cat:AddItem(comboboxTheme)
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

        local row = vgui.Create('MantlePanel')
        row:Dock(TOP)
        row:SetTall(44)
        row:SetColorAlpha(2)
        row:SetRadius(6)

        row.PaintOver = function(_, w, h)
            draw.SimpleText(colId, 'Fated.16', 16, h * 0.5, Mantle.color.text, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)

            local s = 24
            local sx = w - s - 16
            local sy = (h - s) * 0.5

            RNDX.Rect(sx, sy, s, s)
                :Rad(6)
                :Color(value)
            :Draw()
            RNDX.Rect(sx, sy, s, s)
                :Rad(6)
                :Color(Mantle.color.window_shadow)
                :Outline(1)
            :Draw()
        end

        cat:AddItem(row)
    end

    return panel
end

Mantle.menu.registerTab('settings', {
    order = 1,
    title = L('tab_settings'),
    description = L('tab_settings_desc'),
    icon = Material('icon16/cog.png'),
    build = buildPanel
})
