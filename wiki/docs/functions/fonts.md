---
title: Fonts
description: Automatic Montserrat fonts
sidebar_position: 8
---

# Fonts

Montserrat fonts are created automatically on first use.

| Font        | Description                       |
| ----------- | --------------------------------- |
| `Fated.NN`  | Montserrat Medium at a given size |
| `Fated.NNb` | Bold version                      |

For example: `Fated.12`, `Fated.24`, `Fated.48b`.

## Using fonts when drawing

```js
draw.SimpleText("Text", "Fated.20", 15, 15, color_black);
draw.SimpleText("Text", "Fated.20b", 15, 35, color_black);
```

## Using fonts in elements

```js
local frame = vgui.Create('MantleFrame')
frame:SetSize(600, 500)
frame:Center()
frame:MakePopup()

local btn = vgui.Create('MantleBtn', frame)
btn:Dock(TOP)
btn:SetTall(40)
btn:SetTxt('Button')
btn:SetFont('Fated.22b')
```
