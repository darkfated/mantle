---
title: Themes
description: Interface color themes
sidebar_position: 9
---

# Themes

The library ships with many themes in different colors.

## Available colors

| Key                                  | Description                     |
| ------------------------------------ | ------------------------------- |
| `Mantle.color.header`                | Window header                   |
| `Mantle.color.header_text`           | Header text                     |
| `Mantle.color.background`            | Window background               |
| `Mantle.color.background_alpha`      | Window background with opacity  |
| `Mantle.color.background_panelpopup` | Popup panel background          |
| `Mantle.color.button`                | Button                          |
| `Mantle.color.button_shadow`         | Button shadow                   |
| `Mantle.color.button_hovered`        | Button on hover                 |
| `Mantle.color.category`              | Category                        |
| `Mantle.color.category_opened`       | Expanded category               |
| `Mantle.color.theme`                 | Primary accent color            |
| `Mantle.color.panel[1]`              | Panel color #1                  |
| `Mantle.color.panel[2]`              | Panel color #2                  |
| `Mantle.color.panel[3]`              | Panel color #3                  |
| `Mantle.color.panel_alpha[1]`        | Panel color #1 with opacity     |
| `Mantle.color.panel_alpha[2]`        | Panel color #2 with opacity     |
| `Mantle.color.panel_alpha[3]`        | Panel color #3 with opacity     |
| `Mantle.color.toggle`                | Toggle                          |
| `Mantle.color.focus_panel`           | Focused panel                   |
| `Mantle.color.hover`                 | Hover highlight                 |
| `Mantle.color.window_shadow`         | Window shadow                   |
| `Mantle.color.hover_overlay`         | Hover dim overlay               |
| `Mantle.color.hover_overlay_strong`  | Strong hover dim overlay        |
| `Mantle.color.notify_outline`        | Notification outline            |
| `Mantle.color.dim_overlay`           | Background dim                  |
| `Mantle.color.circle_shadow`         | Circle shadow (radial menu)     |
| `Mantle.color.ripple`                | Ripple effect                   |
| `Mantle.color.blur_shadow`           | Blur shadow                     |
| `Mantle.color.tab_hover`             | Tab on hover                    |
| `Mantle.color.icon`                  | Icons                           |
| `Mantle.color.status_disconnect`     | "Offline" status                |
| `Mantle.color.status_bot`            | "Bot" status                    |
| `Mantle.color.status_online`         | "Online" status                 |
| `Mantle.color.gray`                  | Gray text                       |
| `Mantle.color.text_muted`            | Muted text                      |
| `Mantle.color.text`                  | Primary text                    |

Examples:

```js
-- Accent color
local accent = Mantle.color.theme

-- Text
local text = Mantle.color.text
```

## Active theme

```js
-- ID of the active theme: dark, red, blue, and so on
local name = Mantle.ui.activeTheme

-- ID of the theme selected with the server settings taken into account
local resolved = Mantle.ui.getActiveThemeName()

-- Whether the player can use a theme
local available = Mantle.ui.isThemeEnabled('red')

-- Forced theme from the server ('' if not set)
local forced = Mantle.ui.getForcedThemeName()

-- List of available themes: { {id, title, colors}, ... }
local themes = Mantle.ui.getAvailableThemes()
for _, theme in ipairs(themes) do
    print(theme.id, theme.title)
end
```

`getActiveThemeName()` returns the theme that should be active, while `Mantle.ui.activeTheme` is the theme the user currently sees. `getForcedThemeName()` returns the theme ID from `Mantle.config.theme.forced` (or an empty string if no theme is forced).

## Switching themes

```js
-- Preferred way
local ok = Mantle.ui.setTheme('red')
if !ok then
    print('Theme change is unavailable')
end

-- Console way
RunConsoleCommand('mantle_theme', 'red')
```

`setTheme(name)` returns `false` if the theme does not exist, is disabled in `config/theme.lua`, or the server forces a theme.

When `mantle_smooth` is enabled, colors transition smoothly. With `mantle_smooth 0` the theme is applied instantly.

Built-in themes: `dark`, `dark_mono`, `blue`, `red`, `green`, `purple`, `coffee`, `wine`, `violet`, `moss`, `coral`.

## Custom themes

Themes are created in `config/colors.lua` via `Mantle.ui.registerTheme(id, title, colors)`.

You do not have to specify every key: missing colors fall back to the `dark` theme.

```js
Mantle.ui.registerTheme('mytheme', 'My theme', {
    theme = Color(120, 80, 200),
    background = Color(20, 16, 28),
    text = Color(230, 230, 240)
})
```
