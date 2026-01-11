function Mantle.ui.text_box(title, desc, func)
    if IsValid(Mantle.ui.menu_text_box) then
        Mantle.ui.menu_text_box:Remove()
    end

    Mantle.ui.menu_text_box = vgui.Create('MantleFrame')
    Mantle.ui.menu_text_box:SetSize(320, 134)
    Mantle.ui.menu_text_box:Center()
    Mantle.ui.menu_text_box:MakePopup()
    Mantle.ui.menu_text_box:SetTitle(title)
    Mantle.func.animate_appearance(Mantle.ui.menu_text_box, Mantle.ui.menu_text_box:GetWide(), Mantle.ui.menu_text_box:GetTall(), 0.3, 0.2, nil, 0.9)
    Mantle.ui.menu_text_box:DockPadding(12, 30, 12, 12)

    local entry = vgui.Create('MantleEntry', Mantle.ui.menu_text_box)
    entry:Dock(TOP)
    entry:SetTitle(desc)

    local function applyFunction()
        func(entry:GetValue())
        Mantle.ui.menu_text_box:Close()
    end

    entry.OnEnter = function()
        applyFunction()
    end

    local btn_accept = vgui.Create('MantleBtn', Mantle.ui.menu_text_box)
    btn_accept:Dock(BOTTOM)
    btn_accept:SetTall(30)
    btn_accept:SetTxt(Mantle.lang.get('mantle', 'apply'))
    btn_accept.DoClick = function()
        applyFunction()
        Mantle.func.sound()
    end
end
