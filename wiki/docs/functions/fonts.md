---
title: Шрифты
description: Автоматические шрифты Montserrat
sidebar_position: 8
---

# Шрифты

Шрифты Montserrat создаются автоматически при использовании.

| Шрифт       | Описание                          |
| ----------- | --------------------------------- |
| `Fated.NN`  | Montserrat Medium нужного размера |
| `Fated.NNb` | Жирная версия (Bold)              |

Например: `Fated.12`, `Fated.24`, `Fated.48b`.

## Использование в отрисовке

```js
draw.SimpleText("Текст", "Fated.20", 15, 15, color_black);
draw.SimpleText("Текст", "Fated.20b", 15, 35, color_black);
```

## Использование в элементах

```js
local frame = vgui.Create('MantleFrame')
frame:SetSize(600, 500)
frame:Center()
frame:MakePopup()

local btn = vgui.Create('MantleBtn', frame)
btn:Dock(TOP)
btn:SetTall(40)
btn:SetTxt('Кнопка')
btn:SetFont('Fated.22b')
```
