function Mantle.ui.text_box(title, desc, callback)
    if IsValid(Mantle.ui.menu_text_box) then
        Mantle.ui.menu_text_box:Remove()
    end

    local window = vgui.Create('MantleFrame')
    Mantle.ui.menu_text_box = window
    window:SetSize(320, 134)
    window:Center()
    window:MakePopup()
    window:SetTitle(title)
    Mantle.func.animate_appearance(window, window:GetWide(), window:GetTall(), 0.3, 0.2, nil, 0.9)
    window:DockPadding(12, 30, 12, 12)

    local entry = vgui.Create('MantleEntry', window)
    entry:Dock(TOP)
    entry:SetTitle(desc)

    local function applyFunction()
        callback(entry:GetValue())
        window:Close()
    end

    entry.textEntry.OnEnter = function()
        applyFunction()
    end

    local btnAccept = vgui.Create('MantleBtn', window)
    btnAccept:Dock(BOTTOM)
    btnAccept:SetTall(30)
    btnAccept:SetTxt(Mantle.lang.get('mantle', 'apply'))
    btnAccept.DoClick = function()
        applyFunction()
        Mantle.func.sound()
    end
end
