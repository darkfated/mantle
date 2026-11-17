---
title: Panel
description: Base panel
sidebar_position: 13
---

# MantlePanel

The base panel, typically used for blocks.

## Example

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

## Theme color

The color is set by index into the `Mantle.color.panel` array. Available indices are `1`, `2`, and `3`.

```js
local pan = vgui.Create('MantlePanel', frame)
pan:Dock(TOP)
pan:SetColor(1) -- default
```

## Semi-transparent color

The same thing, but from the `Mantle.color.panel_alpha` array.

```js
local pan = vgui.Create('MantlePanel', frame)
pan:Dock(TOP)
pan:SetColorAlpha(2)
```

## Custom color

An arbitrary color via `:SetCustomColor()`.

```js
local pan = vgui.Create('MantlePanel', frame)
pan:Dock(TOP)
pan:SetCustomColor(Color(86, 132, 235))
```

## Methods

| Method                         | Description                                                   |
| ------------------------------ | ------------------------------------------------------------- |
| `:SetColor(number index)`      | Color from `Mantle.color.panel[index]`.                       |
| `:SetColorAlpha(number index)` | Semi-transparent color from `Mantle.color.panel_alpha[index]` |
| `:SetCustomColor(color color)` | Custom color.                                                 |
| `:SetRadius(number radius)`    | Corner radius. Default `12`                                   |
