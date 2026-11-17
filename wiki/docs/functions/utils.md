---
title: Утилиты
description: Вспомогательные функции для панелей и анимаций
sidebar_position: 11
---

# Утилиты

Небольшие вспомогательные функции из `Mantle.util`.

## Проверка родства панелей

`Mantle.util.isDescendantOf(panel, target)` возвращает `true`, если `panel` является `target` или его дочерней панелью на любой глубине.

```js
hook.Add('GUIMousePressed', 'Test', function()
    if Mantle.util.isDescendantOf(vgui.GetHoveredPanel(), somePanel) then
        print('Клик внутри панели')
    end
end)
```

| Аргумент | Тип       | Описание                  |
| -------- | --------- | ------------------------- |
| `panel`  | `panel`   | Проверяемая панель        |
| `target` | `panel`   | Предполагаемый предок     |

## Плавное изменение прозрачности

`Mantle.util.stepAlpha(current, target, maxSpeed, ft)` экспоненциально приближает `current` к `target`, но ограничивает шаг значением `maxSpeed * ft`.

```js
function Panel:Think()
    self.alpha = Mantle.util.stepAlpha(self.alpha or 0, self:IsHovered() and 255 or 0, 600, FrameTime())
end
```

| Аргумент   | Тип      | Описание                                   |
| ---------- | -------- | ------------------------------------------ |
| `current`  | `number` | Текущее значение                           |
| `target`   | `number` | Целевое значение                           |
| `maxSpeed` | `number` | Максимальная скорость изменения в секунду  |
| `ft`       | `number` | `FrameTime()`                              |

Возвращает новое значение.
