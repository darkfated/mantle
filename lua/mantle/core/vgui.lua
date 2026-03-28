CreateClientConVar('mantle_depth_ui', 1, true, false)
CreateClientConVar('mantle_theme', 'dark', true, false)
CreateClientConVar('mantle_blur', 1, true, false)

Mantle.ui.convar = {
    depth_ui = GetConVar('mantle_depth_ui'):GetBool(),
    theme = GetConVar('mantle_theme'):GetString(),
    blur = GetConVar('mantle_blur'):GetBool()
}

Mantle.ui.themes = {
    { id = 'dark', title = 'Тёмная (dark)', colors = Mantle.color_dark },
    { id = 'dark_mono', title = 'Тёмная монотонная (dark_mono)', colors = Mantle.color_dark_mono },
    { id = 'light', title = 'Светлая (light)', colors = Mantle.color_light },
    { id = 'blue', title = 'Синяя (blue)', colors = Mantle.color_blue },
    { id = 'red', title = 'Красная (red)', colors = Mantle.color_red },
    { id = 'green', title = 'Зелёная (green)', colors = Mantle.color_green },
    { id = 'orange', title = 'Оранжевая (orange)', colors = Mantle.color_orange },
    { id = 'purple', title = 'Фиолетовая (purple)', colors = Mantle.color_purple },
    { id = 'coffee', title = 'Кофейная (coffee)', colors = Mantle.color_coffee },
    { id = 'ice', title = 'Ледяная (ice)', colors = Mantle.color_ice },
    { id = 'wine', title = 'Винная (wine)', colors = Mantle.color_wine },
    { id = 'violet', title = 'Фиалковая (violet)', colors = Mantle.color_violet },
    { id = 'moss', title = 'Моховая (moss)', colors = Mantle.color_moss },
    { id = 'coral', title = 'Коралловая (coral)', colors = Mantle.color_coral }
}

Mantle.ui.theme_map = {}
for _, theme in ipairs(Mantle.ui.themes) do
    Mantle.ui.theme_map[theme.id] = theme.colors
end

local function getForcedThemeName()
    local themeId = Mantle.config.theme.forced or ''

    if themeId != '' and Mantle.ui.theme_map[themeId] then
        return themeId
    end

    return ''
end

local function isThemeEnabled(themeId)
    local forced = getForcedThemeName()
    if forced != '' then
        return themeId == forced
    end

    local enabledThemes = Mantle.config.theme.enabled
    if enabledThemes == nil then
        return true
    end

    local isEnabled = enabledThemes[themeId]
    return isEnabled == nil or isEnabled
end

local function getFallbackThemeName()
    for _, theme in ipairs(Mantle.ui.themes) do
        if isThemeEnabled(theme.id) then
            return theme.id
        end
    end

    return 'dark'
end

local function getActiveThemeName()
    local forced = getForcedThemeName()
    if forced != '' then
        return forced
    end

    local saved = Mantle.ui.convar.theme
    if Mantle.ui.theme_map[saved] and isThemeEnabled(saved) then
        return saved
    end

    return getFallbackThemeName()
end

function Mantle.ui.getForcedThemeName()
    return getForcedThemeName()
end

function Mantle.ui.isThemeEnabled(themeId)
    return isThemeEnabled(themeId)
end

function Mantle.ui.getAvailableThemes()
    local themes = {}

    for _, theme in ipairs(Mantle.ui.themes) do
        if isThemeEnabled(theme.id) then
            themes[#themes + 1] = theme
        end
    end

    if #themes == 0 then
        local fallbackTheme = getFallbackThemeName()
        local fallbackTitle = fallbackTheme

        for _, theme in ipairs(Mantle.ui.themes) do
            if theme.id == fallbackTheme then
                fallbackTitle = theme.title
                break
            end
        end

        themes[1] = {
            id = fallbackTheme,
            title = fallbackTitle,
            colors = Mantle.ui.theme_map[fallbackTheme]
        }
    end

    return themes
end

function Mantle.ui.getActiveThemeName()
    return getActiveThemeName()
end

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
    transition.to = table.Copy(Mantle.ui.theme_map[name] or Mantle.color_dark)
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

local function applyInitialTheme()
    local theme = getActiveThemeName()
    Mantle.ui.convar.theme = theme
    Mantle.color = table.Copy(Mantle.ui.theme_map[theme] or Mantle.color_dark)
end

applyInitialTheme()

cvars.AddChangeCallback('mantle_depth_ui', function(_, _, newValue)
    Mantle.ui.convar.depth_ui = newValue == '1'
end)

cvars.AddChangeCallback('mantle_theme', function(_, _, newValue)
    Mantle.ui.convar.theme = newValue
    local theme = getActiveThemeName()
    Mantle.ui.convar.theme = theme
    startThemeTransition(theme)
end)

cvars.AddChangeCallback('mantle_blur', function(_, _, newValue)
    Mantle.ui.convar.blur = newValue == '1'
end)
