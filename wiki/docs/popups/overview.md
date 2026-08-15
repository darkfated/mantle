---
title: Всплывающие элементы
description: Список всплывающих элементов
---

## Состав

| Окно                               | Функция                                          | Описание                       |
| ---------------------------------- | ------------------------------------------------ | ------------------------------ |
| [Выбор цвета](color-picker.md)     | `Mantle.ui.color_picker(callback, defaultColor)` | Выбор цвета                    |
| [Контекстное меню](derma-menu.md)  | `Mantle.ui.derma_menu()`                         | Выбор опций                    |
| [Выбор игрока](player-selector.md) | `Mantle.ui.player_selector(onSelect, filterFn)`  | Список игроков                 |
| [Радиальное меню](radial-menu.md)  | `Mantle.ui.radial_menu(options)`                 | Кольцевое меню с клавишами 1-9 |
| [Текстовое окно](text-box.md)      | `Mantle.ui.text_box(title, desc, callback)`      | Окно ввода текста              |

## Общий принцип

Всплывающие элементы вызываются через функцию, и после выполнение некоторого условия запускают callback-функцию с требуемыми вами действиями.

```js
Mantle.ui.player_selector(function(pl)
    print('Выбран:', pl:Name())
end)
```
