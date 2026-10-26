local convar_depth_ui = CreateClientConVar('mantle_depth_ui', 1, true, false)
local convar_theme = CreateClientConVar('mantle_theme', 'dark', true, false)
local convar_blur = CreateClientConVar('mantle_blur', 1, true, false)
local convar_smooth = CreateClientConVar('mantle_smooth', 1, true, false)

Mantle.ui.convar = {
    depth_ui = convar_depth_ui:GetBool(),
    theme = convar_theme:GetString(),
    blur = convar_blur:GetBool(),
    smooth = convar_smooth:GetBool()
}

local math_abs = math.abs
local math_exp = math.exp
local math_max = math.max

local THEME_TRANSITION_HOOK = 'MantleThemeTransition'
local THEME_TRANSITION_SPEED = 10

local themes = {}
local theme_index = {}

local transition = {
    active = false,
    target = nil
}

local function mergeColors(base, overrides)
    local out = {}

    if istable(base) and !IsColor(base) then
        for key, value in pairs(base) do
            if IsColor(value) then
                out[key] = value:Copy()
            elseif istable(value) then
                out[key] = mergeColors(value)
            else
                out[key] = value
            end
        end
    end

    if istable(overrides) and !IsColor(overrides) then
        for key, value in pairs(overrides) do
            if IsColor(value) then
                out[key] = value:Copy()
            elseif istable(value) then
                out[key] = mergeColors(out[key], value)
            else
                out[key] = value
            end
        end
    end

    return out
end

local function normalizeColors(colors)
    local base = theme_index.dark
    return mergeColors(base and base.colors, colors)
end

local function syncColors(dst, src, t)
    if !istable(dst) or !istable(src) then return 0 end

    local maxDiff = 0

    for key, value in pairs(src) do
        local current = dst[key]

        if IsColor(value) then
            if IsColor(current) then
                current.r = current.r + (value.r - current.r) * t
                current.g = current.g + (value.g - current.g) * t
                current.b = current.b + (value.b - current.b) * t
                current.a = current.a + (value.a - current.a) * t

                maxDiff = math_max(
                    maxDiff,
                    math_abs(value.r - current.r),
                    math_abs(value.g - current.g),
                    math_abs(value.b - current.b),
                    math_abs(value.a - current.a)
                )
            else
                dst[key] = value:Copy()
            end
        elseif istable(value) then
            if !istable(current) or IsColor(current) then
                current = {}
                dst[key] = current
            end

            maxDiff = math_max(maxDiff, syncColors(current, value, t))
        else
            dst[key] = value
        end
    end

    for key in pairs(dst) do
        if src[key] == nil then
            dst[key] = nil
        end
    end

    return maxDiff
end

local function getFallbackThemeName()
    for _, theme in ipairs(themes) do
        if Mantle.ui.isThemeEnabled(theme.id) then
            return theme.id
        end
    end

    return themes[1] and themes[1].id
end

local function resolveThemeName(name)
    if isstring(name) and theme_index[name] then
        return name
    end

    return getFallbackThemeName()
end

local warnedForcedTheme = false

function Mantle.ui.getForcedThemeName()
    local config = Mantle.config.theme
    local themeId = config and config.forced

    if !isstring(themeId) or themeId == '' then
        return ''
    end

    if theme_index[themeId] then
        return themeId
    end

    if !warnedForcedTheme then
        warnedForcedTheme = true
        print(('[Mantle] Unknown forced theme: %s'):format(themeId))
    end

    return ''
end

function Mantle.ui.isThemeEnabled(themeId)
    local forced = Mantle.ui.getForcedThemeName()
    if forced != '' then
        return themeId == forced
    end

    local config = Mantle.config.theme
    local enabled = config and config.enabled

    if !enabled then
        return true
    end

    return enabled[themeId] != false
end

function Mantle.ui.getActiveThemeName()
    local forced = Mantle.ui.getForcedThemeName()
    if forced != '' then
        return forced
    end

    local saved = Mantle.ui.convar.theme

    if theme_index[saved] and Mantle.ui.isThemeEnabled(saved) then
        return saved
    end

    return getFallbackThemeName()
end

function Mantle.ui.getAvailableThemes()
    local available = {}

    for _, theme in ipairs(themes) do
        if Mantle.ui.isThemeEnabled(theme.id) then
            available[#available + 1] = {
                id = theme.id,
                title = theme.title,
                colors = theme.colors
            }
        end
    end

    if #available == 0 then
        local entry = theme_index[getFallbackThemeName()]

        if entry then
            available[1] = {
                id = entry.id,
                title = entry.title,
                colors = entry.colors
            }
        end
    end

    return available
end

function Mantle.ui.registerTheme(id, title, colors)
    if !isstring(id) or id == '' or !istable(colors) then return end

    local normalized = normalizeColors(colors)
    local entry = theme_index[id]

    if entry then
        entry.title = title or entry.title
        entry.colors = normalized

        if Mantle.ui.activeTheme == id and Mantle.color then
            syncColors(Mantle.color, normalized, 1)
        end

        return entry
    end

    entry = {
        id = id,
        title = title or id,
        colors = normalized
    }

    theme_index[id] = entry
    themes[#themes + 1] = entry

    return entry
end

function Mantle.ui.applyTheme(name)
    local resolved = resolveThemeName(name)
    local entry = resolved and theme_index[resolved]

    if !entry then
        return false
    end

    transition.active = false
    transition.target = nil
    hook.Remove('Think', THEME_TRANSITION_HOOK)

    if Mantle.color then
        syncColors(Mantle.color, entry.colors, 1)
    else
        Mantle.color = mergeColors(entry.colors)
    end

    Mantle.ui.activeTheme = resolved

    return resolved
end

function Mantle.ui.setTheme(name)
    if !isstring(name) or !theme_index[name] then return false end
    if Mantle.ui.getForcedThemeName() != '' then return false end
    if !Mantle.ui.isThemeEnabled(name) then return false end

    RunConsoleCommand('mantle_theme', name)

    return true
end

local function updateTransition()
    local tr = transition

    if !tr.active then
        hook.Remove('Think', THEME_TRANSITION_HOOK)
        return
    end

    local entry = tr.target and theme_index[tr.target]

    if !entry or !Mantle.color then
        tr.active = false
        hook.Remove('Think', THEME_TRANSITION_HOOK)
        return
    end

    local t = 1 - math_exp(-THEME_TRANSITION_SPEED * FrameTime())
    local maxDiff = syncColors(Mantle.color, entry.colors, t)

    if maxDiff <= 0.5 then
        syncColors(Mantle.color, entry.colors, 1)
        Mantle.ui.activeTheme = tr.target
        tr.active = false
        hook.Remove('Think', THEME_TRANSITION_HOOK)
    end
end

local function startThemeTransition(name)
    local resolved = resolveThemeName(name)
    local entry = resolved and theme_index[resolved]

    if !entry then
        return
    end

    if !Mantle.color or !Mantle.ui.convar.smooth then
        Mantle.ui.applyTheme(resolved)
        return
    end

    if transition.active and transition.target == resolved then
        return
    end

    if !transition.active and Mantle.ui.activeTheme == resolved then
        return
    end

    transition.target = resolved
    transition.active = true

    hook.Add('Think', THEME_TRANSITION_HOOK, updateTransition)
end

cvars.AddChangeCallback('mantle_theme', function(_, _, newValue)
    Mantle.ui.convar.theme = newValue
    startThemeTransition(Mantle.ui.getActiveThemeName())
end)

cvars.AddChangeCallback('mantle_depth_ui', function(_, _, newValue)
    Mantle.ui.convar.depth_ui = newValue == '1'
end)

cvars.AddChangeCallback('mantle_blur', function(_, _, newValue)
    Mantle.ui.convar.blur = newValue == '1'
end)

cvars.AddChangeCallback('mantle_smooth', function(_, _, newValue)
    Mantle.ui.convar.smooth = newValue == '1'

    if !Mantle.ui.convar.smooth and transition.active then
        Mantle.ui.applyTheme(transition.target)
    end
end)
