local menu = Mantle.menu

local function hasTabId(tabId)
    for _, currentId in ipairs(menu.order) do
        if currentId == tabId then
            return true
        end
    end

    return false
end

function menu.isColor(value)
    return type(value) == 'table' and type(value.r) == 'number' and type(value.g) == 'number' and type(value.b) == 'number'
end

function menu.getFrame()
    if IsValid(menu.frame) then
        return menu.frame
    end

    return menuMantle
end

function menu.getMenuWide()
    local frame = menu.getFrame()
    return IsValid(frame) and frame:GetWide() or 920
end

function menu.notify(text, duration, col)
    local frame = menu.getFrame()
    if IsValid(frame) then
        frame:Notify(text, duration, col)
    end
end

function menu.createTabHeader(title, subtitle, icon, parent)
    local header = vgui.Create('Panel', parent)
    header:Dock(TOP)
    header:DockMargin(0, 0, 0, 8)
    header:SetTall(56)

    header.Paint = function(_, w, h)
        RNDX().Rect(0, 0, w, h)
            :Rad(8)
            :Color(Mantle.color.panel_alpha[2])
        :Draw()

        if icon then
            RNDX().Rect(12, h * 0.5 - 12, 24, 24)
                :Color(255, 255, 255)
                :Material(icon)
            :Draw()
        end

        draw.SimpleText(title, 'Fated.20', 48, 10, Mantle.color.text)
        draw.SimpleText(subtitle, 'Fated.16', 48, h - 10, Mantle.color.gray, TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM)
    end

    return header
end

function menu.createTabPanel(title, subtitle, icon)
    local panel = vgui.Create('MantleScrollPanel')
    menu.createTabHeader(title, subtitle, icon, panel)
    return panel
end

function menu.createCopyButton(parent, snippet)
    local button = vgui.Create('Button', parent)
    button:SetText('')
    button:SetWide(110)
    button.Paint = function(_, w, h)
        RNDX().Rect(0, 0, w, h)
            :Rad(6)
            :Color(Mantle.color.panel_alpha[1])
        :Draw()

        draw.SimpleText('Скопировать', 'Fated.16', w * 0.5, h * 0.5, Mantle.color.text, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
    button.DoClick = function()
        SetClipboardText(snippet)
        menu.notify(snippet)
        Mantle.func.sound()
    end

    return button
end

function menu.createInfo(info, parent)
    local panel = vgui.Create('Panel')
    panel:Dock(TOP)
    panel:DockMargin(0, 0, 0, 6)
    panel:SetTall(50)

    panel.Paint = function(_, w, h)
        RNDX().Rect(0, 0, w, h)
            :Rad(6)
            :Color(Mantle.color.panel_alpha[2])
        :Draw()

        Mantle.func.gradient(0, 0, 6, h, 3, Mantle.color.theme, 6)

        draw.SimpleText(info[1], 'Fated.20', 16, 7, Mantle.color.text)
        draw.SimpleText(info[2], 'Fated.16', 16, h - 7, Mantle.color.gray, TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM)
    end

    local copyButton = menu.createCopyButton(panel, info[1])
    copyButton:Dock(RIGHT)
    copyButton:DockMargin(0, 10, 10, 10)

    parent:AddItem(panel)
    return panel
end

function menu.createCategory(name, infoTable, parent, uiElement, isActive)
    local category = vgui.Create('MantleCategory', parent)
    category:Dock(TOP)
    category:DockMargin(0, 0, 0, 6)
    category:SetText(name)

    if isActive then
        category:SetActive(true)
    end

    for _, info in ipairs(infoTable) do
        menu.createInfo(info, category)
    end

    if uiElement then
        category:AddItem(uiElement)
    end

    return category
end

function menu.registerTab(tabId, data)
    data.id = tabId
    menu.tabs[tabId] = data

    if !hasTabId(tabId) then
        table.insert(menu.order, tabId)
    end

    table.sort(menu.order, function(a, b)
        local a_order = menu.tabs[a] and menu.tabs[a].order or math.huge
        local b_order = menu.tabs[b] and menu.tabs[b].order or math.huge

        if a_order == b_order then
            return a < b
        end

        return a_order < b_order
    end)
end

function menu.getTabs()
    local tabs = {}

    for _, tabId in ipairs(menu.order) do
        local data = menu.tabs[tabId]
        if data then
            tabs[#tabs + 1] = data
        end
    end

    return tabs
end
