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

    local header = vgui.Create('MantlePanel', panel)
    header:Dock(TOP)
    header:SetTall(58)
    header:SetColorAlpha(2)
    header:SetRadius(12)

    header.PaintOver = function(_, w, h)
        RNDX.Rect(0, 0, 4, h)
            :Rad(32)
            :Color(Mantle.color.theme)
        :Draw()

        local iconX = 18
        if data.icon then
            RNDX.Rect(iconX, h * 0.5 - 11, 22, 22)
                :Color(255, 255, 255)
                :Material(data.icon)
            :Draw()
        end

        local textX = data.icon and (iconX + 32) or 24
        draw.SimpleText(title, 'Fated.20', textX, 8, Mantle.color.text)
        draw.SimpleText(description, 'Fated.14', textX, h - 8, Mantle.color.gray, TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM)
    end

    return panel
end

function menu.createColorRow(parent, name, color)
    local panel = vgui.Create('MantlePanel')
    panel:Dock(TOP)
    panel:SetTall(44)
    panel:SetColorAlpha(2)
    panel:SetRadius(6)

    panel.PaintOver = function(_, w, h)
        draw.SimpleText(name, 'Fated.16', 16, h * 0.5, Mantle.color.text, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)

        local s = 24
        local sx = w - s - 16
        local sy = (h - s) * 0.5

        RNDX.Rect(sx, sy, s, s)
            :Rad(6)
            :Color(color)
        :Draw()
        RNDX.Rect(sx, sy, s, s)
            :Rad(6)
            :Color(Mantle.color.window_shadow)
            :Outline(1)
        :Draw()
    end

    parent:AddItem(panel)
    return panel
end

function menu.createCategory(parent, opts)
    local category = vgui.Create('MantleCategory', parent)
    category:Dock(TOP)
    category:SetText(opts.title)
    category:SetActive(true)

    if opts.demo then
        local demo = isfunction(opts.demo) and opts.demo(category) or opts.demo
        if IsValid(demo) then
            demo:DockMargin(8, 8, 8, 8)
            category:AddItem(demo)
        end
    end

    return category
end
