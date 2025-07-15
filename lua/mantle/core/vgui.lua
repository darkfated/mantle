
CreateClientConVar('mantle_depth_ui', 1, true, false)
CreateClientConVar('mantle_light_theme', 0, true, false)


Mantle.ui = {
    convar = {
        depth_ui = GetConVar('mantle_depth_ui'):GetBool(),
        light_theme = GetConVar('mantle_light_theme'):GetBool()
    }
}

local function UpdateTheme()
    if Mantle.ui.convar.light_theme then
        Mantle.color = Mantle.color_light
    else
        Mantle.color = Mantle.color_dark
    end
end

UpdateTheme()


cvars.AddChangeCallback('mantle_depth_ui', function(_, _, newValue)
    Mantle.ui.convar.depth_ui = newValue == '1'
end)

cvars.AddChangeCallback('mantle_light_theme', function(_, _, newValue)
    Mantle.ui.convar.light_theme = newValue == '1'
    UpdateTheme()
end)
