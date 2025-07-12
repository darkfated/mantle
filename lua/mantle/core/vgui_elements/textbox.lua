local color_accept = Color(35, 103, 51)

function Mantle.ui.text_box(title, desc, func)
    Mantle.ui.menu_text_box = vgui.Create('MantleFrame')
    Mantle.ui.menu_text_box:SetSize(300, 132)
    Mantle.ui.menu_text_box:Center()
    Mantle.ui.menu_text_box:MakePopup()
    Mantle.ui.menu_text_box:SetTitle(title)
    Mantle.ui.menu_text_box:ShowAnimation()
    Mantle.ui.menu_text_box:DockPadding(12, 30, 12, 12)

    local entry = vgui.Create('MantleEntry', Mantle.ui.menu_text_box)
    entry:Dock(TOP)
    entry:SetTitle(desc)

    local function apply_func()
        func(entry:GetValue())

        Mantle.ui.menu_text_box:Remove()
    end

    entry.OnEnter = function()
        apply_func()
    end

    local btn_accept = vgui.Create('MantleBtn', Mantle.ui.menu_text_box)
    btn_accept:Dock(BOTTOM)
    btn_accept:SetTall(30)
    btn_accept:SetTxt('Применить')
    btn_accept:SetColorHover(color_accept)
    btn_accept.DoClick = function()
        Mantle.func.sound()

        apply_func()
    end
end
