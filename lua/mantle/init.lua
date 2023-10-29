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

    cl('modules/shadows.lua')
    cl('modules/material_url.lua')

end

local function init()
    if SERVER then
        resource.AddWorkshop('2924839375')
        resource.AddFile('materials/mantle/close_btn.png')
    end

    Mantle = Mantle or {}

    run_scripts()
end

init()

local menu = vgui.Create('DFrame')
menu:SetSize(120, 120)
menu:Center()
menu:MakePopup()

menu.btn = vgui.Create('DButton', menu)
Mantle.ui.btn(menu.btn, Material('icon16/accept.png'), 16, Color(25, 25, 25), 4, false, Color(237, 79, 79), false)
menu.btn:Dock(FILL)
