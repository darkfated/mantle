local color_accept_1 = Color(44, 124, 62)
local color_accept_2 = Color(35, 103, 51)

function Mantle.ui.text_box(title, desc, func)
    Mantle.ui.menu_text_box = vgui.Create('MantleFrame')
    Mantle.ui.menu_text_box:SetSize(300, 120)
    Mantle.ui.menu_text_box:Center()
    Mantle.ui.menu_text_box:MakePopup()
    Mantle.ui.menu_text_box:SetTitle(title)
    Mantle.ui.menu_text_box.background_alpha = false

    local entry = vgui.Create('MantleEntry', Mantle.ui.menu_text_box)
    entry:Dock(FILL)
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
    btn_accept:DockMargin(0, 8, 0, 0)
    btn_accept:SetTall(30)
    btn_accept:SetTxt('Применить')
    btn_accept:SetColor(color_accept_1)
    btn_accept:SetColorHover(color_accept_2)
    btn_accept.DoClick = function()
        Mantle.func.sound()

        apply_func()
    end
end
