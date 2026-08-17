---
title: Панель
description: Базовая панель
sidebar_position: 13
---

# MantlePanel

Базовая панель, обычно используется для блоков.

## Пример

```js
local frame = vgui.Create('MantleFrame')
frame:SetSize(600, 500)
frame:Center()
frame:MakePopup()

local pan = vgui.Create('MantlePanel', frame)
pan:Dock(TOP)
pan:SetTall(80)
pan:SetColor(1)
```

## Цвет из темы

Цвет задаётся индексом из массива `Mantle.color.panel`. Имеется `1`, `2` и `3`.

```js
local pan = vgui.Create('MantlePanel', frame)
pan:Dock(TOP)
pan:SetColor(1) -- по умолчанию
```

## Полупрозрачный цвет

То же самое, но из массива `Mantle.color.panel_alpha`.

```js
local pan = vgui.Create('MantlePanel', frame)
pan:Dock(TOP)
pan:SetColorAlpha(2)
```

## Свой цвет

Произвольный цвет через `:SetCustomColor()`.

```js
local pan = vgui.Create('MantlePanel', frame)
pan:Dock(TOP)
pan:SetCustomColor(Color(86, 132, 235))
```

## Методы

| Метод                          | Описание                                                 |
| ------------------------------ | -------------------------------------------------------- |
| `:SetColor(number index)`      | Цвет из `Mantle.color.panel[index]`.                     |
| `:SetColorAlpha(number index)` | Полупрозрачный цвет из `Mantle.color.panel_alpha[index]` |
| `:SetCustomColor(color color)` | Свой цвет.                                               |
| `:SetRadius(number radius)`    | Радиус скругления. По умолчанию `12`                     |
