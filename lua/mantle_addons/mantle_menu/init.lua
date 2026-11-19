-- Menu for testing the functionality

Mantle.menu = {
    tabs = {}
}

function Mantle.menu.registerTab(id, data)
    data.id = id
    Mantle.menu.tabs[id] = data
end

Mantle.run_cl('mantle_addons/mantle_menu/tabs/settings.lua')
Mantle.run_cl('mantle_addons/mantle_menu/tabs/ui.lua')
Mantle.run_cl('mantle_addons/mantle_menu/tabs/popups.lua')
Mantle.run_cl('mantle_addons/mantle_menu/tabs/legacy.lua')
Mantle.run_cl('mantle_addons/mantle_menu/menu.lua')
