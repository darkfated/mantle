function Mantle.menu.open()
    if IsValid(mantleMenu) then mantleMenu:Remove() end

    mantleMenu = vgui.Create('MantleFrame')
    mantleMenu:SetSize(920, 640)
    mantleMenu:Center()
    mantleMenu:MakePopup()
    mantleMenu:SetTitle('Mantle')
    mantleMenu:SetCenterTitle('Основное меню библиотеки')
    mantleMenu:ShowAnimation()
    mantleMenu.OnRemove = function()
        mantleMenu = nil
    end

    local tabs = vgui.Create('MantleTabs', mantleMenu)
    tabs:Dock(FILL)

    local sorted = {}
    for _, tab in pairs(Mantle.menu.tabs) do
        sorted[#sorted + 1] = tab
    end
    table.sort(sorted, function(a, b) return (a.order or 0) < (b.order or 0) end)

    for _, tab in ipairs(sorted) do
        local content = tab.build(tab)
        tabs:AddTab({
            title = tab.title,
            description = tab.description,
            icon = tab.icon
        }, content)
    end
end

concommand.Add('mantle_menu', Mantle.menu.open)
