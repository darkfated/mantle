local function L(key)
    return Mantle.lang.get('mantle_menu', key)
end

local function createDemoButton(text, callback)
    local button = vgui.Create('MantleBtn')
    button:Dock(TOP)
    button:SetTxt(text)
    button.DoClick = function()
        callback()
        Mantle.func.sound()
    end
    return button
end

local function buildPanel(tab)
    local panel = vgui.Create('MantleScrollPanel')

    local cat = vgui.Create('MantleCategory', panel)
    cat:Dock(TOP)
    cat:SetText(L('popups_color'))
    cat:SetActive(true)
    local btnColor = createDemoButton(L('popups_color_open'), function()
        Mantle.ui.color_picker(function(col)
            chat.AddText('You picked a color: ', col, col)
        end, Color(25, 59, 102))
    end)
    btnColor:DockMargin(8, 8, 8, 8)
    cat:AddItem(btnColor)

    cat = vgui.Create('MantleCategory', panel)
    cat:Dock(TOP)
    cat:SetText(L('popups_context'))
    cat:SetActive(true)
    local btnCtx = createDemoButton(L('popups_context_open'), function()
        local dermaMenu = Mantle.ui.derma_menu()
        for i = 1, 5 do
            dermaMenu:AddOption(string.format(L('popups_context_option'), i), function()
                chat.AddText('Hello everyone! ' .. i)
            end)
        end
        dermaMenu:AddSpacer()
        dermaMenu:AddOption(L('popups_context_privilege'), function()
            chat.AddText(LocalPlayer():GetUserGroup())
        end, 'icon16/status_online.png')

        local clothes = dermaMenu:AddOption(L('popups_context_clothes'))
        local subClothes = clothes:AddSubMenu()
        subClothes:AddOption(L('popups_context_hat'), function()
            chat.AddText('You picked: Hat')
        end)
        subClothes:AddOption(L('popups_context_sweater'), function()
            chat.AddText('You picked: Sweater')
        end)
    end)
    btnCtx:DockMargin(8, 8, 8, 8)
    cat:AddItem(btnCtx)

    cat = vgui.Create('MantleCategory', panel)
    cat:Dock(TOP)
    cat:SetText(L('popups_player'))
    cat:SetActive(true)
    local btnPlayer = createDemoButton(L('popups_player_open'), function()
        Mantle.ui.player_selector(function(pl)
            chat.AddText('You picked a player: ', color_white, pl:Name())
        end)
    end)
    btnPlayer:DockMargin(8, 8, 8, 8)
    cat:AddItem(btnPlayer)

    cat = vgui.Create('MantleCategory', panel)
    cat:Dock(TOP)
    cat:SetText(L('popups_radial'))
    cat:SetActive(true)
    local btnRadial = createDemoButton(L('popups_radial_open'), function()
        local radialMenu = Mantle.ui.radial_menu()
        radialMenu:SetCenterText(L('popups_radial_title'), L('popups_radial_desc'))

        local weaponsMenu = radialMenu:CreateSubMenu(L('popups_radial_weapons'), L('popups_radial_weapons_desc'))
        weaponsMenu:AddOption(L('popups_radial_pistol'), function()
            chat.AddText(Mantle.color.theme, 'Pistol selected')
        end, 'icon16/gun.png', L('popups_radial_pistol_desc'))
        weaponsMenu:AddOption(L('popups_radial_rifle'), function()
            chat.AddText(Mantle.color.theme, 'Rifle selected')
        end, 'icon16/gun.png', L('popups_radial_rifle_desc'))
        radialMenu:AddSubMenuOption(L('popups_radial_weapons'), weaponsMenu, 'icon16/gun.png', L('popups_radial_weapons_desc'))

        radialMenu:AddOption(L('popups_radial_drop'), function()
            chat.AddText('You dropped the weapon')
        end, 'icon16/gun.png', L('popups_radial_drop_desc'))
        radialMenu:AddOption(L('popups_radial_throw'), function()
            chat.AddText('Action completed')
        end, 'icon16/controller.png', L('popups_radial_throw_desc'))
        radialMenu:AddOption(L('popups_radial_die'), function()
            chat.AddText('Action completed')
        end, 'icon16/world.png', L('popups_radial_die_desc'))
        radialMenu:AddOption(L('popups_radial_hack'), function()
            chat.AddText('Action completed')
        end, 'icon16/server.png', L('popups_radial_hack_desc'))
        radialMenu:AddOption(L('popups_radial_balance'), function()
            chat.AddText('Action completed')
        end, 'icon16/money.png', L('popups_radial_balance_desc'))
        radialMenu:AddOption(L('popups_radial_no_icon'), function()
            chat.AddText('Action completed')
        end, nil, L('popups_radial_no_icon_desc'))
    end)
    btnRadial:DockMargin(8, 8, 8, 8)
    cat:AddItem(btnRadial)

    cat = vgui.Create('MantleCategory', panel)
    cat:Dock(TOP)
    cat:SetText(L('popups_textbox'))
    cat:SetActive(true)
    local btnTextBox = createDemoButton(L('popups_textbox_open'), function()
        Mantle.ui.text_box(L('popups_textbox_title'), L('popups_textbox_desc'), function(text)
            chat.AddText('You entered: ', color_white, text)
        end)
    end)
    btnTextBox:DockMargin(8, 8, 8, 8)
    cat:AddItem(btnTextBox)

    cat = vgui.Create('MantleCategory', panel)
    cat:Dock(TOP)
    cat:SetText(L('popups_notify'))
    cat:SetActive(true)
    local btnNotify = createDemoButton(L('popups_notify_show'), function()
        mantleMenu:Notify(L('popups_notify_text'))
    end)
    btnNotify:DockMargin(8, 8, 8, 8)
    cat:AddItem(btnNotify)

    cat = vgui.Create('MantleCategory', panel)
    cat:Dock(TOP)
    cat:SetText(L('popups_model'))
    cat:SetActive(true)

    local btnModel = createDemoButton(L('popups_model_open'), function()
        Mantle.ui.model_selector({
            'models/player/group01/male_01.mdl',
            'models/player/group01/female_01.mdl',
            {
                model = 'models/player/combine_soldier.mdl',
                name = 'Combine Soldier',
                description = 'Combine faction'
            },
            {
                model = 'models/player/alyx.mdl',
                name = 'Alyx',
                description = 'Resistance'
            },
            {
                model = 'models/player/monk.mdl',
                name = 'Monk',
                description = 'Civilian character'
            }
        }, function(model, data, index)
            local name = istable(data) and data.name or model

            chat.AddText('Selected model: ', Mantle.color.theme, name, color_white, ' (' .. model .. ')')
        end)
    end)

    btnModel:DockMargin(8, 8, 8, 8)
    cat:AddItem(btnModel)

    return panel
end

Mantle.menu.registerTab('popups', {
    order = 3,
    title = L('tab_popups'),
    description = L('tab_popups_desc'),
    icon = Material('icon16/application_double.png'),
    build = buildPanel
})
