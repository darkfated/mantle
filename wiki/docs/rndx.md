---
title: Модифицированный RNDX
description: Быстрый рендеринг фигур
---

# Модифицированный RNDX

Быстрая отрисовка графических элементов (замена `draw`).

## Прямоугольник

```js
hook.Add('HUDPaint', 'Test', function()
    local w, h = 300, 120
    local x, y = (ScrW() - w) / 2, (ScrH() - h) / 2

    RNDX.Rect(x, y, w, h)
        :Rad(16)
        :Color(Mantle.color.panel[1])
    :Draw()
end)
```

## Скругление

```js
hook.Add('HUDPaint', 'Test', function()
    local w, h = 300, 120
    local x, y = (ScrW() - w) / 2, (ScrH() - h) / 2

    RNDX.Rect(x, y, w, h)
        :Radii(16, 16, 0, 0) -- сверху закругление, снизу нет
        :Color(Mantle.color.panel[1])
    :Draw()
end)
```

## Обводка

```js
hook.Add('HUDPaint', 'Test', function()
    local w, h = 300, 120
    local x, y = (ScrW() - w) / 2, (ScrH() - h) / 2

    RNDX.Rect(x, y, w, h)
        :Rad(16)
        :Outline(2)
        :Color(Mantle.color.panel[1])
    :Draw()
end)
```

## Круг

```js
hook.Add('HUDPaint', 'Test', function()
    local cx, cy = ScrW() / 2, ScrH() / 2

    RNDX.Circle(cx, cy, 30)
        :Color(Color(182, 65, 65))
    :Draw()
end)
```

## Тень под фигурой

```js
hook.Add('HUDPaint', 'Test', function()
    local w, h = 300, 120
    local x, y = (ScrW() - w) / 2, (ScrH() - h) / 2

    RNDX.Rect(x, y, w, h)
        :Rad(16)
        :Shadow(20, 4, 0, 2)
    :Draw()

    RNDX.Rect(x, y, w, h)
        :Rad(16)
        :Color(Mantle.color.panel[1])
    :Draw()
end)
```

## Размытие фона

```js
hook.Add('HUDPaint', 'Test', function()
    local w, h = 300, 120
    local x, y = (ScrW() - w) / 2, (ScrH() - h) / 2

    RNDX.Rect(x, y, w, h)
        :Rad(16)
        :Blur(2)
    :Draw()
end)
```

## Сектор круга

```js
hook.Add('HUDPaint', 'Test', function()
    local cx, cy = ScrW() / 2, ScrH() / 2

    -- Угол в градусах: от 0 до 180 (полукруг снизу)
    RNDX.Circle(cx, cy, 40)
        :Angles(0, 180)
        :Color(Mantle.color.theme)
    :Draw()
end)
```

## Отрисовка материала

```js
hook.Add('HUDPaint', 'Test', function()
    local w, h = 300, 120
    local x, y = (ScrW() - w) / 2, (ScrH() - h) / 2

    RNDX.Rect(x, y, w, h)
        :Rad(12)
        :Material(Material('icon16/user.png'))
    :Draw()
end)
```

## Конструкторы

| Конструктор                             | Описание       |
| --------------------------------------- | -------------- |
| `RNDX.Rect(int x, int y, int w, int h)` | Прямоугольник  |
| `RNDX.Circle(int x, int y, int radius)` | Круг по центру |

## Модификаторы

| Модификатор                                                 | Описание                                                               |
| ----------------------------------------------------------- | ---------------------------------------------------------------------- |
| `:Rad(int rad)` / `:Radii(int tl, int tr, int bl, int br)`  | Скругление углов                                                       |
| `:Color(color col)`                                         | Цвет заливки                                                           |
| `:Outline(int thickness)`                                   | Обводка вместо заливки. По умолчанию 1                                 |
| `:Texture(ITexture)` / `:Material(IMaterial)`               | Отрисовка текстуры / материала                                         |
| `:Blur(int intensity)`                                      | Размытие фона внутри фигуры                                            |
| `:Fade(int top, int bottom)`                                | Вертикальное затухание. Например `:Fade(1, 0)` прозрачно снизу         |
| `:Shadow(int blur, int spread, int offset_x, int offset_y)` | Тень под фигурой                                                       |
| `:Rotation(int deg)`                                        | Поворот фигуры                                                         |
| `:Angles(int start, int end)`                               | Сектор круга                                                           |
| `:Clip(object panel)`                                       | Обрезать отрисовку по границам панели                                  |
| `:Flags(int flags)`                                         | Быстрые флаги: `RNDX.NO_TL/TR/BL/BR`, `RNDX.BLUR`, `RNDX.MANUAL_COLOR` |
| `:Draw()`                                                   | Завершить и нарисовать фигуру                                          |
