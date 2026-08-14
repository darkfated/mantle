local convar_depth_ui = CreateClientConVar('mantle_depth_ui', 1, true, false)
local convar_theme = CreateClientConVar('mantle_theme', 'dark', true, false)
local convar_blur = CreateClientConVar('mantle_blur', 1, true, false)

Mantle.ui.convar = {
    depth_ui = convar_depth_ui:GetBool(),
    theme = convar_theme:GetString(),
    blur = convar_blur:GetBool()
}

local themes = {}
local theme_map = {}

function Mantle.ui.registerTheme(id, title, colors)
    if !colors then return end

    table.insert(themes, { id = id, title = title, colors = colors })
    theme_map[id] = colors
end

function Mantle.ui.getForcedThemeName()
    local themeId = Mantle.config.theme.forced
    if themeId != '' and theme_map[themeId] then
        return themeId
    end

    return ''
end

local function isThemeEnabled(themeId)
    local forced = Mantle.ui.getForcedThemeName()
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
    for _, theme in ipairs(themes) do
        if isThemeEnabled(theme.id) then
            return theme.id
        end
    end

    return 'dark'
end

function Mantle.ui.getActiveThemeName()
    local forced = Mantle.ui.getForcedThemeName()
    if forced != '' then
        return forced
    end

    local saved = Mantle.ui.convar.theme
    if theme_map[saved] and isThemeEnabled(saved) then
        return saved
    end

    return getFallbackThemeName()
end

function Mantle.ui.getAvailableThemes()
    local available = {}

    for _, theme in ipairs(themes) do
        if isThemeEnabled(theme.id) then
            available[#available + 1] = theme
        end
    end

    if #available == 0 then
        local fallback = getFallbackThemeName()
        local title = fallback

        for _, theme in ipairs(themes) do
            if theme.id == fallback then
                title = theme.title
                break
            end
        end

        available[1] = {
            id = fallback,
            title = title,
            colors = theme_map[fallback]
        }
    end

    return available
end

local transition = {
    active = false,
    to = nil,
    progress = 0,
    speed = 6
}

local function updateTransition()
    local tr = transition
    if !tr.active then
        hook.Remove('Think', 'MantleThemeTransition')
        return
    end

    tr.progress = Mantle.func.approachExp(tr.progress, 1, tr.speed, FrameTime())

    local to = tr.to
    for k, v in pairs(to) do
        if IsColor(v) then
            local cur = Mantle.color[k]
            if IsColor(cur) then
                Mantle.color[k] = Mantle.func.LerpColor(tr.speed, cur, v)
            else
                Mantle.color[k] = v
            end
        elseif type(v) == 'table' then
            local cur = Mantle.color[k] or {}
            Mantle.color[k] = cur

            for i = 1, #v do
                local vi = v[i]
                if IsColor(vi) and IsColor(cur[i]) then
                    cur[i] = Mantle.func.LerpColor(tr.speed, cur[i], vi)
                else
                    cur[i] = vi
                end
            end
        end
    end

    if tr.progress >= 0.999 then
        Mantle.color = table.Copy(to)
        tr.active = false
    end
end

local function startThemeTransition(name)
    transition.to = theme_map[name] or theme_map['dark']
    transition.progress = 0
    transition.active = true

    if !hook.GetTable().MantleThemeTransition then
        hook.Add('Think', 'MantleThemeTransition', updateTransition)
    end
end

local function applyInitialTheme()
    local theme = Mantle.ui.getActiveThemeName()
    Mantle.ui.convar.theme = theme
    Mantle.color = table.Copy(theme_map[theme] or theme_map['dark'])
end

hook.Add('Think', 'MantleApplyInitialTheme', function()
    hook.Remove('Think', 'MantleApplyInitialTheme')
    applyInitialTheme()
end)

cvars.AddChangeCallback('mantle_depth_ui', function(_, _, newValue)
    Mantle.ui.convar.depth_ui = newValue == '1'
end)

cvars.AddChangeCallback('mantle_theme', function(_, _, newValue)
    Mantle.ui.convar.theme = newValue
    local theme = Mantle.ui.getActiveThemeName()
    Mantle.ui.convar.theme = theme
    startThemeTransition(theme)
end)

cvars.AddChangeCallback('mantle_blur', function(_, _, newValue)
    Mantle.ui.convar.blur = newValue == '1'
end)
