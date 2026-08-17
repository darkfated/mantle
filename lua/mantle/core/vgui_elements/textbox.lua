function Mantle.ui.text_box(title, desc, callback)
    if IsValid(Mantle.ui.menu_text_box) then
        Mantle.ui.menu_text_box:Remove()
    end

    local window = vgui.Create('MantleFrame')
    Mantle.ui.menu_text_box = window
    window:SetSize(340, 140)
    window:Center()
    window:MakePopup()
    window:SetTitle(title)
    window:ShowAnimation()
    window:SetPopupPad(12)

    local entry = vgui.Create('MantleEntry', window)
    entry:Dock(TOP)
    entry:DockMargin(0, 0, 0, 8)
    entry:SetTitle(desc)

    local function applyFunction()
        callback(entry:GetValue())
        window:Close()
    end

    entry.textEntry.OnEnter = function()
        applyFunction()
    end

    timer.Simple(0.1, function()
        if IsValid(entry) then
            entry.textEntry:RequestFocus()
        end
    end)

    local btnAccept = vgui.Create('MantleBtn', window)
    btnAccept:Dock(BOTTOM)
    btnAccept:SetTall(32)
    btnAccept:SetRadius(10)
    btnAccept:SetTxt(Mantle.lang.get('mantle', 'apply'))
    btnAccept.DoClick = function()
        applyFunction()
        Mantle.func.sound()
    end
end
