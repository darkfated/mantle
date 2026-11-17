---
title: Popups
description: List of popups
---

# Popups

## Contents

| Window                                | Function                                         | Description                    |
| ------------------------------------- | ------------------------------------------------ | ------------------------------ |
| [Color picker](color-picker.md)       | `Mantle.ui.color_picker(callback, defaultColor)` | Pick a color                   |
| [Context menu](derma-menu.md)         | `Mantle.ui.derma_menu()`                         | Select options                 |
| [Player selector](player-selector.md) | `Mantle.ui.player_selector(onSelect, filterFn)`  | Player list                    |
| [Model selector](model-selector.md)   | `Mantle.ui.model_selector(models, callback)`     | Model list                     |
| [Radial menu](radial-menu.md)         | `Mantle.ui.radial_menu(options)`                 | Ring menu with keys 1-9        |
| [Text box](text-box.md)               | `Mantle.ui.text_box(title, desc, callback)`      | Text input window              |

## How they work

Popups are opened by calling a function, and once a condition is met they run a callback with the result you asked for.

```js
Mantle.ui.player_selector(function(pl)
    print('Selected:', pl:Name())
end)
```
