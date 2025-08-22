CreateClientConVar('mantle_depth_ui', 1, true, false)
CreateClientConVar('mantle_theme', 'dark', true, false)
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

local function isColor(v)
    return type(v) == 'table' and type(v.r) == 'number'
end

local transition = {
    active = false,
    to = nil,
    progress = 0,
    speed = 3,
    colorBlend = 8
}

local function startThemeTransition(name)
    transition.to = table.Copy(themeMap[name] or Mantle.color_dark)
    transition.active = true
    transition.progress = 0

    if !hook.GetTable().MantleThemeTransition then
        hook.Add('Think', 'MantleThemeTransition', function()
            if !transition.active then return end

            local dt = FrameTime()
            transition.progress = Mantle.func.approachExp(transition.progress, 1, transition.speed, dt)
            local eased = Mantle.func.easeOutCubic(transition.progress)

            local to = transition.to
            if !to then
                transition.active = false
                hook.Remove('Think', 'MantleThemeTransition')
                return
            end

            for k, v in pairs(to) do
                if isColor(v) then
                    Mantle.color[k] = Mantle.func.LerpColor(transition.colorBlend, Mantle.color[k] or v, v)
                elseif type(v) == 'table' and #v > 0 then
                    Mantle.color[k] = Mantle.color[k] or {}
                    for i = 1, #v do
                        local vi = v[i]
                        if isColor(vi) then
                            Mantle.color[k][i] = Mantle.func.LerpColor(transition.colorBlend, (Mantle.color[k] and Mantle.color[k][i]) or vi, vi)
                        else
                            Mantle.color[k][i] = vi
                        end
                    end
                end
            end

            if transition.progress >= 0.999 then
                Mantle.color = table.Copy(transition.to)
                transition.active = false
                hook.Remove('Think', 'MantleThemeTransition')
            end
        end)
    end
end

local function ApplyInitialTheme()
    local theme = Mantle.ui.convar.theme
    Mantle.color = table.Copy(themeMap[theme] or Mantle.color_dark)
end

ApplyInitialTheme()

cvars.AddChangeCallback('mantle_depth_ui', function(_, _, newValue)
    Mantle.ui.convar.depth_ui = newValue == '1'
end)

cvars.AddChangeCallback('mantle_theme', function(_, _, newValue)
    Mantle.ui.convar.theme = newValue
    startThemeTransition(newValue)
end)

cvars.AddChangeCallback('mantle_blur', function(_, _, newValue)
    Mantle.ui.convar.blur = newValue == '1'
end)
