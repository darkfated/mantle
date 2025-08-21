
CreateClientConVar('mantle_depth_ui', 1, true, false)
CreateClientConVar('mantle_theme', 'dark', true, false) -- dark, light, blue, red
CreateClientConVar('mantle_blur', 1, true, false)

Mantle.ui = {
    convar = {
        depth_ui = GetConVar('mantle_depth_ui'):GetBool(),
        theme = GetConVar('mantle_theme'):GetString(),
        blur = GetConVar('mantle_blur'):GetBool()
    }
}

local themeMap = {
    dark = Mantle.color_dark,
    dark_mono = Mantle.color_dark_mono,
    graphite = Mantle.color_graphite,
    light = Mantle.color_light,
    blue = Mantle.color_blue,
    red = Mantle.color_red,
    green = Mantle.color_green,
    orange = Mantle.color_orange,
    purple = Mantle.color_purple,
    coffee = Mantle.color_coffee,
    ice = Mantle.color_ice,
    wine = Mantle.color_wine,
    violet = Mantle.color_violet,
    moss = Mantle.color_moss,
    coral = Mantle.color_coral
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

cvars.AddChangeCallback('mantle_blur', function(_, _, newValue)
    Mantle.ui.convar.blur = newValue == '1'
end)
