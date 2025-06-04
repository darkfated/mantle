--[[
    * Mantle *
    GitHub: https://github.com/darkfated/mantle
    Author's telegram: @darkfated
]]--

local function RunScripts()
    Mantle.run_cl('config/colors.lua')
    
    Mantle.run_cl('core/func.lua')
    Mantle.run_cl('core/vgui.lua')
    Mantle.run_cl('core/legacy_vgui.lua')
    Mantle.run_cl('core/menu.lua')
    
    Mantle.run_cl('core/vgui_elements/button.lua')
    Mantle.run_cl('core/vgui_elements/checkbox.lua')
    Mantle.run_cl('core/vgui_elements/color_picker.lua')
    Mantle.run_cl('core/vgui_elements/derma_menu.lua')
    Mantle.run_cl('core/vgui_elements/entry.lua')
    Mantle.run_cl('core/vgui_elements/frame.lua')
    Mantle.run_cl('core/vgui_elements/player_selector.lua')
    Mantle.run_cl('core/vgui_elements/radialpanel.lua')
    Mantle.run_cl('core/vgui_elements/scrollpanel.lua')
    Mantle.run_cl('core/vgui_elements/slidebox.lua')
    Mantle.run_cl('core/vgui_elements/tabs.lua')
    Mantle.run_cl('core/vgui_elements/textbox.lua')
    Mantle.run_cl('core/vgui_elements/category.lua')
    Mantle.run_cl('core/vgui_elements/combobox.lua')

    Mantle.run_cl('modules/shadows.lua')
    Mantle.run_cl('modules/material_url.lua')
    Mantle.run_sh('modules/notify.lua')
end

local function RunAddons()
    local function LoadAddon(addonName)
        local addonPath = 'mantle_addons/' .. addonName
        local initPath = addonPath .. '/init.lua'

        Mantle.run_sh(initPath)
    end

    local _, addonsName = file.Find('mantle_addons/*', 'LUA')
    
    for _, addon in ipairs(addonsName) do
        LoadAddon(addon)
    end
end

local function InitLib()
    if SERVER then
        resource.AddWorkshop('2924839375') -- DarkFated font
        resource.AddWorkshop('3126986993') -- Mantle
    end

    local color_div = Color(168, 109, 236)

    MsgC(color_white, '------------------\n')
    MsgC(Color(0, 255, 0), '| Mantle LIBRARY |\n')
    MsgC(color_white, '------------------\n')

    Mantle = Mantle or {}
    Mantle.run_cl = SERVER and AddCSLuaFile or include
    Mantle.run_sv = SERVER and include or function() end
    Mantle.run_sh = function(f)
        Mantle.run_cl(f)
        Mantle.run_sv(f)
    end

    RunScripts()
    RunAddons()
end

InitLib()
