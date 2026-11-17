---
title: Настройки
description: Конфигурационные настройки библиотеки
sidebar_position: 4
---

# Настройки

## ConVars

Библиотека предоставляет клиентские ConVars, которые можно менять из консоли.

| ConVar            | Описание                          | Значение по умолчанию |
| ----------------- | --------------------------------- | --------------------- |
| `mantle_depth_ui` | Тени для UI элементов             | `1`                   |
| `mantle_blur`     | Размытие фона                     | `1`                   |
| `mantle_smooth`   | Плавные переходы и анимации       | `1`                   |
| `mantle_theme`    | Выбранная игроком тема интерфейса | `dark`                |

Получить текущее состояние:

```js
local depth = Mantle.ui.convar.depth_ui
local blur = Mantle.ui.convar.blur
local smooth = Mantle.ui.convar.smooth

-- Выбор игрока
local preferred = Mantle.ui.convar.theme

-- Тема, которая отрисована сейчас
local active = Mantle.ui.activeTheme
```

## config/theme.lua

Файл лежит в `lua/mantle/config/theme.lua`. Управляет доступными темами.

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

- `forced` - принудительная тема для всех игроков. Если пусто, каждый выбирает тему сам.
- `enabled` - какие темы доступны игрокам при выборе. Если тема не указана в таблице, она считается доступной.

## config/colors.lua

Здесь создаются цветовые темы через `Mantle.ui.registerTheme(id, title, colors)`.
