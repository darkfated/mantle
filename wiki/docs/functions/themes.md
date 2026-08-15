---
title: Темы
description: Цветовые темы интерфейса
sidebar_position: 9
---

# Темы

Библиотека имеет множество тем с различными цветами.

## Доступные цвета

| Ключ                                 | Описание                         |
| ------------------------------------ | -------------------------------- |
| `Mantle.color.header`                | Шапка окна                       |
| `Mantle.color.header_text`           | Текст шапки                      |
| `Mantle.color.background`            | Фон окна                         |
| `Mantle.color.background_alpha`      | Фон окна с прозрачностью         |
| `Mantle.color.background_panelpopup` | Фон всплывающих панелей          |
| `Mantle.color.button`                | Кнопка                           |
| `Mantle.color.button_shadow`         | Тень кнопки                      |
| `Mantle.color.button_hovered`        | Кнопка при наведении             |
| `Mantle.color.category`              | Категория                        |
| `Mantle.color.category_opened`       | Категория в раскрытом состоянии  |
| `Mantle.color.theme`                 | Основной акцентный цвет          |
| `Mantle.color.panel[1]`              | Цвет панели #1                   |
| `Mantle.color.panel[2]`              | Цвет панели #2                   |
| `Mantle.color.panel[3]`              | Цвет панели #3                   |
| `Mantle.color.panel_alpha[1]`        | Цвет панели #1 с прозрачностью   |
| `Mantle.color.panel_alpha[2]`        | Цвет панели #2 с прозрачностью   |
| `Mantle.color.panel_alpha[3]`        | Цвет панели #3 с прозрачностью   |
| `Mantle.color.toggle`                | Тумблер                          |
| `Mantle.color.focus_panel`           | Панель в фокусе                  |
| `Mantle.color.hover`                 | Подсветка при наведении          |
| `Mantle.color.window_shadow`         | Тень окна                        |
| `Mantle.color.hover_overlay`         | Затемнение при наведении         |
| `Mantle.color.hover_overlay_strong`  | Сильное затемнение при наведении |
| `Mantle.color.notify_outline`        | Обводка уведомлений              |
| `Mantle.color.dim_overlay`           | Затемнение фона                  |
| `Mantle.color.circle_shadow`         | Тень круга (радиальное меню)     |
| `Mantle.color.ripple`                | Эффект волны                     |
| `Mantle.color.blur_shadow`           | Тень размытия                    |
| `Mantle.color.tab_hover`             | Вкладка при наведении            |
| `Mantle.color.icon`                  | Иконки                           |
| `Mantle.color.status_disconnect`     | Статус "не в сети"               |
| `Mantle.color.status_bot`            | Статус "бот"                     |
| `Mantle.color.status_online`         | Статус "в сети"                  |
| `Mantle.color.gray`                  | Серый текст                      |
| `Mantle.color.text_muted`            | Приглушённый текст               |
| `Mantle.color.text`                  | Основной текст                   |

Примеры обращения:

```js
-- Акцентный цвет
local accent = Mantle.color.theme

-- Текст
local text = Mantle.color.text
```

## Активная тема

```js
-- ID активной темы: dark, red, blue и т.д.
local name = Mantle.ui.getActiveThemeName()

-- Список доступных тем: { {id, title, colors}, ... }
local themes = Mantle.ui.getAvailableThemes()
for _, theme in ipairs(themes) do
    print(theme.id, theme.title)
end
```

## Переключение темы

```js
RunConsoleCommand("mantle_theme", "red");
```

Встроенные темы: `dark`, `dark_mono`, `light`, `blue`, `red`, `green`, `orange`, `purple`, `coffee`, `ice`, `wine`, `violet`, `moss`, `coral`.

## Дополнение

Создавать и редактировать темы нужно в файле `config/colors.lua`.

```js
Mantle.ui.registerTheme('mytheme', 'Моя тема', {
    theme = Color(120, 80, 200),
    background = Color(20, 16, 28),
    text = Color(230, 230, 240),
    -- и другие ключи
})
```
