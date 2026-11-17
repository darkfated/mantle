---
title: Drawing
description: Blur and gradient
sidebar_position: 1
---

# Drawing

Drawing functions. Call them inside `:Paint()`.

## Background blur

Blurs everything behind the panel.

```js
function Panel:Paint(w, h)
    Mantle.func.blur(self)
end
```

## Gradient

```js
function Panel:Paint(w, h)
    Mantle.func.gradient(0, 0, w, h, 2, Mantle.color.panel[1], 16)
end
```

| Argument           | Type    | Description                                     |
| ------------------ | ------- | ----------------------------------------------- |
| `x`, `y`, `w`, `h` | `int`   | Gradient area                                   |
| `dir`              | `int`   | Direction: 1 up, 2 down, 3 left, 4 right        |
| `col`              | `color` | Gradient color                                  |
| `radius`           | `int`   | Corner radius                                   |
| `flags`            | `int`   | RNDX flags (for example, the shape). Optional   |
