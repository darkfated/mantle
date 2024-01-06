--[[
    * mantle *
    GitHub: https://github.com/darkfated/mantle
    Author's discord: darkfated
]]--

local function run_scripts()
    local cl = SERVER and AddCSLuaFile or include
    local sv = SERVER and include or function() end

    cl('colors.lua')
    cl('func_ui.lua')
    cl('vgui.lua')

    cl('modules/shadows.lua')
    cl('modules/material_url.lua')
    cl('modules/test_menu.lua')
end

local function init()
    if SERVER then
        resource.AddWorkshop('2924839375') -- DarkFated font
        resource.AddWorkshop('3126986993') -- Mantle
    end

    Mantle = Mantle or {}

    run_scripts()
end

init()
