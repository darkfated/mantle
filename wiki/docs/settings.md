---
title: Настройки
description: Конфигурационные настройки библиотеки
sidebar_position: 4
---

# Настройки

## ConVars

Библиотека предоставляет клиентские ConVars, которые можно менять из консоли.

| ConVar            | Описание                 | Значение по умолчанию |
| ----------------- | ------------------------ | --------------------- |
| `mantle_depth_ui` | Тени для UI элементов    | `1`                   |
| `mantle_smooth`   | Эффект плавности         | `1`                   |
| `mantle_theme`    | Активная тема интерфейса | `dark`                |

Получить текущее состояние:

```js
local depth = Mantle.ui.convar.depth_ui
local smooth = Mantle.ui.convar.smooth
local theme = Mantle.ui.convar.theme
```

## config/theme.lua

Файл лежит в `lua/mantle/config/theme.lua`. Управляет доступными темами.

```js
Mantle.config.theme = {
    forced = '',
    enabled = {
        dark = true,
        dark_mono = true,
        light = true,
        blue = true,
        red = true,
        green = true,
        orange = true,
        purple = true,
        coffee = true,
        ice = true,
        wine = true,
        violet = true,
        moss = true,
        coral = true
    }
}
```

- `forced` - принудительная тема для всех игроков. Если пусто, каждый выбирает тему сам.
- `enabled` - какие темы доступны игрокам при выборе.

## config/colors.lua

Здесь создаются цветовые темы через `Mantle.ui.registerTheme(id, title, colors)`.
