---
title: Панель выбора модели
description: Встраиваемая панель каталога моделей
sidebar_position: 14
---

# MantleModelSelector

Встраиваемая панель выбора модели с поиском и интерактивным предпросмотром. Используется внутри окна [Выбор модели](../popups/model-selector.md), но её можно создать отдельно и встроить в свой интерфейс.

## Пример

```js
local frame = vgui.Create('MantleFrame')
frame:SetSize(800, 600)
frame:Center()
frame:MakePopup()

local selector = vgui.Create('MantleModelSelector', frame)
selector:Dock(FILL)

selector:SetModels({
    'models/player/group01/male_01.mdl',
    'models/player/group01/female_01.mdl',
    { model = 'models/player/alyx.mdl', name = 'Alyx', description = 'Resistance' }
})

selector.OnSelect = function(self, index, model, data)
    print('Выбрана модель:', model, 'индекс:', index)
end
```

## Формат моделей

`SetModels` принимает список строк или таблиц:

```js
selector:SetModels({
    'models/player/group01/male_01.mdl', -- строчка
    {
        model = 'models/player/combine_soldier.mdl',
        name = 'Combine Soldier',
        description = 'Combine faction'
    } -- таблица
})
```

## Настройка предпросмотра

```js
local selector = vgui.Create('MantleModelSelector', frame)
selector:Dock(FILL)

selector:SetSearchEnabled(false)  -- скрыть поиск
selector:SetPreviewEnabled(false) -- скрыть предпросмотр
selector:SetAutoRotate(true)      -- включить авто-вращение
selector:SetFOV(40)               -- угол обзора (20..70)
selector:ResetView()              -- сбросить камеру
```

## Поля и методы

| Поле / метод                                          | Описание                                                          |
| ----------------------------------------------------- | ----------------------------------------------------------------- |
| `OnSelect(self, index, model, data)`                  | Вызывается при выборе модели. `data` - нормализованные данные     |
| `:SetModels(table models)`                            | Задать список моделей                                             |
| `:GetModels()`                                        | Текущий список моделей                                            |
| `:SetSelected(int index, bool silent, bool notify)`   | Выбрать модель по индексу                                         |
| `:GetSelected()`                                      | Индекс выбранной модели                                           |
| `:GetSelectedModel()`                                 | Путь выбранной модели или `nil`                                   |
| `:GetSelectedData()`                                  | Таблица данных выбранной модели                                   |
| `:IsSelectedModelValid()`                             | `true`, если модель существует и прогрузилась                      |
| `:SetSearchEnabled(bool enabled)`                     | Поиск. По умолчанию `true`                                        |
| `:SetPreviewEnabled(bool enabled)`                    | Панель предпросмотра. По умолчанию `true`                         |
| `:SetAutoRotate(bool enabled)`                        | Автоматическое вращение модели. По умолчанию `false`              |
| `:GetAutoRotate()`                                    | Включено ли авто-вращение                                         |
| `:SetFOV(number fov)`                                 | Угол обзора камеры (`20..70`). По умолчанию `34`                  |
| `:ResetView()`                                        | Сбросить поворот, зум и положение камеры                          |
