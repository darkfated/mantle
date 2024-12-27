local function ClampPanelPosition(panel)
    local x, y = panel:GetPos()
    local w, h = panel:GetSize()

    if x < 0 then
        x = 0
    elseif x + w > Mantle.func.sw then
        x = Mantle.func.sw - w
    end

    if y < 0 then
        y = 0
    elseif y + h > Mantle.func.sh then
        y = Mantle.func.sh - h
    end

    panel:SetPos(x, y)
end

function Mantle.ui.derma_menu()
    if IsValid(Mantle.ui.menu_derma_menu) then
        Mantle.ui.menu_derma_menu:Remove()
    end

    local mousePosX, mousePosY = input.GetCursorPos()

    Mantle.ui.menu_derma_menu = vgui.Create('DPanel')
    Mantle.ui.menu_derma_menu:SetSize(200, 100)
    Mantle.ui.menu_derma_menu:SetPos(mousePosX - Mantle.ui.menu_derma_menu:GetWide() * 0.5, mousePosY)
    Mantle.ui.menu_derma_menu:MakePopup()
    Mantle.ui.menu_derma_menu:SetIsMenu(true)
    Mantle.ui.menu_derma_menu:SetKeyBoardInputEnabled(false)
    Mantle.ui.menu_derma_menu.Paint = function(self, w, h)
        local x, y = self:LocalToScreen()

        BShadows.BeginShadow()
            draw.RoundedBox(6, x, y, w, h, Mantle.color.background)
        BShadows.EndShadow(1, 2, 2, 255, 0, 0)
    end
    Mantle.ui.menu_derma_menu.tall = 6
    Mantle.ui.menu_derma_menu.max_width = 0

    Mantle.ui.menu_derma_menu.sp = vgui.Create('MantleScrollPanel', Mantle.ui.menu_derma_menu)
    Mantle.ui.menu_derma_menu.sp:Dock(FILL)
    Mantle.ui.menu_derma_menu.sp:DockMargin(2, 4, 2, 2)

    RegisterDermaMenuForClose(Mantle.ui.menu_derma_menu)

    function Mantle.ui.menu_derma_menu:AddOption(name, func, icon)
        local option = vgui.Create('MantleBtn', Mantle.ui.menu_derma_menu.sp)
        option:Dock(TOP)
        option:DockMargin(2, Mantle.ui.menu_derma_menu.tall == 0 and 2 or 0, 2, 2)
        option:SetTall(20)
        option:SetTxt(name)
        option.DoClick = function()
            func()
            Mantle.ui.menu_derma_menu:Remove()

            Mantle.func.sound()
        end

        surface.SetFont('Fated.18')

        Mantle.ui.menu_derma_menu.max_width = math.max(Mantle.ui.menu_derma_menu.max_width, surface.GetTextSize(name))

        if icon then
            local iconPanel = vgui.Create('DPanel', option)
            iconPanel:SetSize(16, 16)
            iconPanel:SetPos(2, 2)

            local mat_icon = Material(icon)

            iconPanel.Paint = function(_, w, h)
                surface.SetDrawColor(color_white)
                surface.SetMaterial(mat_icon)
                surface.DrawTexturedRect(0, 0, w, h)
            end
        end

        Mantle.ui.menu_derma_menu.tall = Mantle.ui.menu_derma_menu.tall + 22 + (Mantle.ui.menu_derma_menu.tall == 0 and 2 or 0)
        Mantle.ui.menu_derma_menu:SetTall(math.Clamp(Mantle.ui.menu_derma_menu.tall, 0, Mantle.func.sh * 0.5))
        Mantle.ui.menu_derma_menu:SetWide(Mantle.ui.menu_derma_menu.max_width + 72)

        ClampPanelPosition(Mantle.ui.menu_derma_menu)
    end

    function Mantle.ui.menu_derma_menu:AddSpacer()
        local panelSpacer = vgui.Create('DPanel', Mantle.ui.menu_derma_menu.sp)
        panelSpacer:Dock(TOP)
        panelSpacer:DockMargin(0, 2, 0, 4)
        panelSpacer:SetTall(4)
        panelSpacer.Paint = function(_, w, h)
            draw.RoundedBox(2, 6, 0, w - 12, h, Mantle.color.panel[2])
        end

        Mantle.ui.menu_derma_menu.tall = Mantle.ui.menu_derma_menu.tall + 10
        Mantle.ui.menu_derma_menu:SetTall(Mantle.ui.menu_derma_menu.tall)
    end

    function Mantle.ui.menu_derma_menu:GetDeleteSelf()
        return true
    end

    return Mantle.ui.menu_derma_menu
end
