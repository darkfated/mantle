---
title: Legacy Shadows
description: Отрисовка теней через Render Targets
sidebar_position: 10
---

# Legacy Shadows

Отрисовка теней через Render Targets. Это устаревшая система, для новых проектов используйте встроенную тень RNDX через `:Shadow()`.

## Пример

![](./assets/shadows-1.png)

```js
local w, h = 300, 120
local x, y = (ScrW() - w) / 2, (ScrH() - h) / 2

hook.Add('HUDPaint', 'Test', function()
    BShadows.BeginShadow()
        RNDX.Rect(x, y, w, h)
            :Color(Mantle.color.panel[1])
        :Draw()
    BShadows.EndShadow(1, 2, 2, 255, 0, 0)
end)
```

## Параметры EndShadow

| Аргумент      | Тип      | Описание                          |
| ------------- | -------- | --------------------------------- |
| `intensity`   | `number` | Интенсивность тени                |
| `spread`      | `number` | Размер распространения            |
| `blur`        | `number` | Размытие                          |
| `opacity`     | `number` | Прозрачность                      |
| `direction`   | `number` | Направление                       |
| `distance`    | `number` | Дистанция от объекта              |
| `shadow_only` | `bool`   | Рисовать только тень. Опционально |

## Тень готовой текстуры

Рисует тень вокруг уже отрисованной текстуры (например, рендер-таргета панели), без `BeginShadow`/`EndShadow`.

```js
BShadows.DrawShadowTexture(texture, 2, 4, 6, 200, 0, 3)
```

| Аргумент       | Тип        | Описание                          |
| -------------- | ---------- | --------------------------------- |
| `texture`      | `texture`  | Исходная текстура                 |
| `intensity`    | `number`   | Интенсивность тени                |
| `spread`       | `number`   | Размер распространения            |
| `blur`         | `number`   | Размытие                          |
| `opacity`      | `number`   | Прозрачность. По умолчанию `255`  |
| `direction`    | `number`   | Направление. По умолчанию `0`     |
| `distance`     | `number`   | Дистанция от объекта. По умолчанию `0` |
| `shadow_only`  | `bool`     | Не рисовать исходную текстуру     |
