function Mantle.menu.createBanner(tab)
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
        RNDX.Rect(iconX, h * 0.5 - 11, 22, 22)
            :Color(255, 255, 255)
            :Material(tab.icon)
        :Draw()

        draw.SimpleText(tab.title, 'Fated.20', iconX + 32, 10, Mantle.color.text)
        draw.SimpleText(tab.description, 'Fated.14', iconX + 32, h - 10, Mantle.color.gray, TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM)
    end

    return panel
end

function Mantle.menu.registerTab(id, data)
    data.id = id
    Mantle.menu.tabs[id] = data
end
