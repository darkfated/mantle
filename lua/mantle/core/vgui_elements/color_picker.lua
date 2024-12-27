local color_close = Color(210, 65, 65)

function Mantle.ui.color_picker(func, color_standart)
    if IsValid(Mantle.ui.menu_color_picker) then
        Mantle.ui.menu_color_picker:Remove()
    end

    Mantle.ui.menu_color_picker = vgui.Create('MantleFrame')
    Mantle.ui.menu_color_picker:SetSize(250, 400)
    Mantle.ui.menu_color_picker:Center()
    Mantle.ui.menu_color_picker:MakePopup()
    Mantle.ui.menu_color_picker:SetTitle('')
    Mantle.ui.menu_color_picker:SetCenterTitle('Выбор цвета')

    Mantle.ui.menu_color_picker.picker = vgui.Create('DColorMixer', Mantle.ui.menu_color_picker)
    Mantle.ui.menu_color_picker.picker:Dock(FILL)
    Mantle.ui.menu_color_picker.picker:SetAlphaBar(false)

    if color_standart then
        Mantle.ui.menu_color_picker.picker:SetColor(color_standart)
    end

    Mantle.ui.menu_color_picker.btn_close = vgui.Create('MantleBtn', Mantle.ui.menu_color_picker)
    Mantle.ui.menu_color_picker.btn_close:Dock(BOTTOM)
    Mantle.ui.menu_color_picker.btn_close:DockMargin(0, 6, 0, 0)
    Mantle.ui.menu_color_picker.btn_close:SetTall(28)
    Mantle.ui.menu_color_picker.btn_close:SetTxt('Закрыть')
    Mantle.ui.menu_color_picker.btn_close:SetColor(color_close)
    Mantle.ui.menu_color_picker.btn_close:SetHover(false)
    Mantle.ui.menu_color_picker.btn_close.DoClick = function()
        Mantle.ui.menu_color_picker:Remove()
    end

    Mantle.ui.menu_color_picker.btn_select = vgui.Create('MantleBtn', Mantle.ui.menu_color_picker)
    Mantle.ui.menu_color_picker.btn_select:Dock(BOTTOM)
    Mantle.ui.menu_color_picker.btn_select:DockMargin(0, 6, 0, 0)
    Mantle.ui.menu_color_picker.btn_select:SetTall(28)
    Mantle.ui.menu_color_picker.btn_select:SetTxt('Выбрать')
    Mantle.ui.menu_color_picker.btn_select.DoClick = function()
        Mantle.func.sound()

        local col = Mantle.ui.menu_color_picker.picker:GetColor()

        func(Color(col.r, col.g, col.b))

        Mantle.ui.menu_color_picker:Remove()
    end
end
