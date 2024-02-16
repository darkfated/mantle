--[[
    * Mantle *
    GitHub: https://github.com/darkfated/mantle
    Author's discord: darkfated
]]--

local function run_scripts()
    Mantle.run_cl('colors.lua')
    Mantle.run_cl('func_ui.lua')
    Mantle.run_cl('vgui.lua')

    Mantle.run_cl('modules/shadows.lua')
    Mantle.run_cl('modules/material_url.lua')
    Mantle.run_cl('modules/test_menu.lua')
    Mantle.run_cl('modules/notify.lua')
    Mantle.run_sv('modules/notify.lua')
end

local function run_addons()
    local function LoadAddon(addonName)
        local addonPath = 'mantle_addons/' .. addonName
        local initPath = addonPath .. '/init.lua'

        Mantle.run_cl(initPath)
        Mantle.run_sv(initPath)
    end

    local _, addons_name = file.Find('mantle_addons/*', 'LUA')
    
    for _, addon in ipairs(addons_name) do
        LoadAddon(addon)
    end
end

local function init()
    if SERVER then
        resource.AddWorkshop('2924839375') -- DarkFated font
        resource.AddWorkshop('3126986993') -- Mantle
    end

    Mantle = Mantle or {}
    Mantle.run_cl = SERVER and AddCSLuaFile or include
    Mantle.run_sv = SERVER and include or function() end

    run_scripts()
    run_addons()
end

init()
