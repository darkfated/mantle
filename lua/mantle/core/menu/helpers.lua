local menu = Mantle.menu

local function hasTabId(tabId)
    for _, currentId in ipairs(menu.order) do
        if currentId == tabId then
            return true
        end
    end

    return false
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

function menu.createTabPanel()
    local data = menu._activeTab or {}
    local title = data.title or ''
    local description = data.description or ''

    local panel = vgui.Create('MantleScrollPanel')

    local header = vgui.Create('Panel', panel)
    header:Dock(TOP)
    header:DockMargin(0, 0, 0, 8)
    header:SetTall(56)

    header.Paint = function(_, w, h)
        RNDX.Rect(0, 0, w, h)
            :Rad(8)
            :Color(Mantle.color.panel_alpha[2])
        :Draw()

        if data.icon then
            RNDX.Rect(12, h * 0.5 - 12, 24, 24)
                :Color(255, 255, 255)
                :Material(data.icon)
            :Draw()
        end

        draw.SimpleText(title, 'Fated.20', 48, 10, Mantle.color.text)
        draw.SimpleText(description, 'Fated.16', 48, h - 10, Mantle.color.gray, TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM)
    end

    return panel
end

function menu.createCopyButton(parent, snippet)
    local button = vgui.Create('MantleBtn', parent)
    button:SetTxt('Скопировать')
    button:SetWide(110)
    button:SetRadius(8)
    button.DoClick = function()
        SetClipboardText(snippet)
        menu.notify(snippet)
        Mantle.func.sound()
    end

    return button
end

function menu.createDoc(parent, name, desc)
    local panel = vgui.Create('Panel')
    panel:Dock(TOP)
    panel:DockMargin(0, 0, 0, 8)
    panel:SetTall(50)

    panel.Paint = function(_, w, h)
        RNDX.Rect(0, 0, w, h)
            :Rad(6)
            :Color(Mantle.color.panel_alpha[2])
        :Draw()

        RNDX.Rect(0, 0, 4, h)
            :Rad(32)
            :Color(Mantle.color.theme)
        :Draw()

        draw.SimpleText(name, 'Fated.20', 16, 7, Mantle.color.text)
        draw.SimpleText(desc, 'Fated.16', 16, h - 7, Mantle.color.gray, TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM)
    end

    local copyButton = menu.createCopyButton(panel, name)
    copyButton:Dock(RIGHT)
    copyButton:DockMargin(0, 10, 10, 10)

    parent:AddItem(panel)
    return panel
end

function menu.createCategory(parent, opts)
    local category = vgui.Create('MantleCategory', parent)
    category:Dock(TOP)
    category:DockMargin(0, 0, 0, 8)
    category:SetText(opts.title)

    if opts.open then
        category:SetActive(true)
    end

    if opts.rows then
        for _, row in ipairs(opts.rows) do
            menu.createDoc(category, row.name, row.desc)
        end
    end

    if opts.demo then
        local demo = type(opts.demo) == 'function' and opts.demo(category) or opts.demo
        if IsValid(demo) then
            category:AddItem(demo)
        end
    end

    return category
end
