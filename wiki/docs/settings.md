---
title: Settings
description: Library configuration
sidebar_position: 4
---

# Settings

## ConVars

The library provides client ConVars that can be changed from the console.

| ConVar            | Description                          | Default value |
| ----------------- | ------------------------------------ | ------------- |
| `mantle_depth_ui` | Shadows for UI elements              | `1`           |
| `mantle_blur`     | Background blur                      | `1`           |
| `mantle_smooth`   | Smooth transitions and animations    | `1`           |
| `mantle_theme`    | The interface theme chosen by player | `dark`        |

Read the current state:

```js
local depth = Mantle.ui.convar.depth_ui
local blur = Mantle.ui.convar.blur
local smooth = Mantle.ui.convar.smooth

-- Player's choice
local preferred = Mantle.ui.convar.theme

-- The theme currently rendered
local active = Mantle.ui.activeTheme
```

## config/theme.lua

The file is located at `lua/mantle/config/theme.lua`. It controls which themes are available.

```js
Mantle.config.theme = {
    forced = '',
    enabled = {
        dark = true,
        dark_mono = true,
        blue = true,
        red = true,
        green = true,
        purple = true,
        coffee = true,
        wine = true,
        violet = true,
        moss = true,
        coral = true
    }
}
```

- `forced` - a forced theme for all players. If empty, each player chooses their own theme.
- `enabled` - which themes players can select. A theme that is not listed is considered available.

## config/colors.lua

Color themes are created here via `Mantle.ui.registerTheme(id, title, colors)`.
