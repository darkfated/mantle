
CreateClientConVar('mantle_depth_ui', 1, true, false)
CreateClientConVar('mantle_theme', 'dark', true, false) -- dark, light, blue, red

Mantle.ui = {
    convar = {
        depth_ui = GetConVar('mantle_depth_ui'):GetBool(),
        theme = GetConVar('mantle_theme'):GetString()
    }
}

local themeMap = {
    dark = Mantle.color_dark,
    dark_mono = Mantle.color_dark_mono,
    light = Mantle.color_light,
    blue = Mantle.color_blue,
    red = Mantle.color_red,
    green = Mantle.color_green
}

local function UpdateTheme()
    local theme = Mantle.ui.convar.theme
    Mantle.color = themeMap[theme] or Mantle.color_dark
end

UpdateTheme()

cvars.AddChangeCallback('mantle_depth_ui', function(_, _, newValue)
    Mantle.ui.convar.depth_ui = newValue == '1'
end)

cvars.AddChangeCallback('mantle_theme', function(_, _, newValue)
    Mantle.ui.convar.theme = newValue
    UpdateTheme()
end)
