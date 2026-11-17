---
title: Utilities
description: Helper functions for panels and animations
sidebar_position: 11
---

# Utilities

Small helper functions from `Mantle.util`.

## Checking panel ancestry

`Mantle.util.isDescendantOf(panel, target)` returns `true` if `panel` is `target` or its child panel at any depth.

```js
hook.Add('GUIMousePressed', 'Test', function()
    if Mantle.util.isDescendantOf(vgui.GetHoveredPanel(), somePanel) then
        print('Clicked inside the panel')
    end
end)
```

| Argument | Type    | Description              |
| -------- | ------- | ------------------------ |
| `panel`  | `panel` | Panel to check           |
| `target` | `panel` | Presumed ancestor        |

## Smooth alpha transitions

`Mantle.util.stepAlpha(current, target, maxSpeed, ft)` moves `current` toward `target` exponentially but limits the step to `maxSpeed * ft`.

```js
function Panel:Think()
    self.alpha = Mantle.util.stepAlpha(self.alpha or 0, self:IsHovered() and 255 or 0, 600, FrameTime())
end
```

| Argument   | Type     | Description                              |
| ---------- | -------- | ---------------------------------------- |
| `current`  | `number` | Current value                            |
| `target`   | `number` | Target value                             |
| `maxSpeed` | `number` | Maximum change rate per second           |
| `ft`       | `number` | `FrameTime()`                            |

Returns the new value.
