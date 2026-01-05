--[[
    * Mantle *
    GitHub: https://github.com/darkfated/mantle
    Author's telegram: @darkfated
]]--

local function RunScripts()
    Mantle.run_cl('config/colors.lua')

    Mantle.run_cl('core/func.lua')
    Mantle.run_cl('core/vgui.lua')

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
    Mantle.run_cl('core/vgui_elements/table.lua')
    Mantle.run_cl('core/vgui_elements/text.lua')
    Mantle.run_cl('core/vgui_elements/hscroll.lua')
    Mantle.run_cl('core/vgui_elements/panel.lua')

    Mantle.run_cl('core/wiki/menu.lua')
    Mantle.run_cl('core/wiki/tabs/functions.lua')
    Mantle.run_cl('core/wiki/tabs/popup.lua')
    Mantle.run_cl('core/wiki/tabs/settings.lua')
    Mantle.run_cl('core/wiki/tabs/ui.lua')

    Mantle.run_cl('modules/shadows.lua')
    Mantle.run_cl('modules/material_url.lua')
    Mantle.run_sh('modules/notify.lua')
    Mantle.run_sh('modules/utf8.lua')
end

local function RunAddons()
    local _, addonsName = file.Find('mantle_addons/*', 'LUA')

    for _, addon in ipairs(addonsName) do
        if file.Exists('mantle_addons/' .. addon .. '/init.lua', 'LUA') then
            Mantle.run_sh('mantle_addons/' .. addon .. '/init.lua')
        end

        if file.Exists('mantle_addons/' .. addon .. '/lang.lua', 'LUA') then
            local lang = Mantle.run_sh('mantle_addons/' .. addon .. '/lang.lua')
            Mantle.lang.list[addon] = lang
        end
    end

    Mantle.run_sh('core/lang.lua')
end

local function InitLib()
    if SERVER then
        resource.AddWorkshop('2924839375') -- DarkFated font
        resource.AddWorkshop('3126986993') -- Mantle
        resource.AddWorkshop('3626277245') -- Steam Animated Avatars
        resource.AddFile('resource/fonts/sf-regular.ttf')
        resource.AddFile('resource/fonts/sf-medium.ttf')
    end

    local color_div = Color(168, 109, 236)

    MsgC(color_white, '------------------\n')
    MsgC(Color(0, 255, 0), '| Mantle LIBRARY |\n')
    MsgC(color_white, '------------------\n')

    Mantle = Mantle or {
        lang = { list = {}, default = 'en' },
    }
    Mantle.run_cl = SERVER and AddCSLuaFile or include
    Mantle.run_sv = SERVER and include or function() end
    Mantle.run_sh = function(f)
        local client = Mantle.run_cl(f)
        local server = Mantle.run_sv(f)
        return SERVER and server or client
    end

    RunScripts()
    RunAddons()
end

InitLib()
