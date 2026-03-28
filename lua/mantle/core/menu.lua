local menu = Mantle.menu

function menu.open()
    local frame = menu.getFrame()
    if IsValid(frame) then
        frame:Remove()
    end

    frame = vgui.Create('MantleFrame')
    frame:SetSize(920, 640)
    frame:Center()
    frame:MakePopup()
    frame:SetTitle('Mantle')
    frame:SetCenterTitle('Основное меню библиотеки')
    frame:ShowAnimation()
    frame.OnRemove = function()
        if menu.frame == frame then
            menu.frame = nil
        end

        if menuMantle == frame then
            menuMantle = nil
        end
    end

    menu.frame = frame
    menuMantle = frame

    local tabs = vgui.Create('MantleTabs', frame)
    tabs:Dock(FILL)

    for _, tab in ipairs(menu.getTabs()) do
        tabs:AddTab({
            title = tab.title,
            description = tab.description,
            icon = tab.icon
        }, tab.create())
    end

    return frame
end

concommand.Add('mantle_menu', menu.open)
