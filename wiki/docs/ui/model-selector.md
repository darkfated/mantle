---
title: Model selector panel
description: Embeddable model catalog panel
sidebar_position: 14
---

# MantleModelSelector

An embeddable model selector panel with search and an interactive preview. It is used inside the [Model selector](../popups/model-selector.md) window, but you can create it separately and embed it in your own interface.

## Example

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
    print('Selected model:', model, 'index:', index)
end
```

## Model format

`SetModels` accepts a list of strings or tables:

```js
selector:SetModels({
    'models/player/group01/male_01.mdl', -- string
    {
        model = 'models/player/combine_soldier.mdl',
        name = 'Combine Soldier',
        description = 'Combine faction'
    } -- table
})
```

## Configuring the preview

```js
local selector = vgui.Create('MantleModelSelector', frame)
selector:Dock(FILL)

selector:SetSearchEnabled(false)  -- hide the search
selector:SetPreviewEnabled(false) -- hide the preview
selector:SetAutoRotate(true)      -- enable auto-rotation
selector:SetFOV(40)               -- field of view (20..70)
selector:ResetView()              -- reset the camera
```

## Fields and methods

| Field / method                                        | Description                                                   |
| ----------------------------------------------------- | ------------------------------------------------------------- |
| `OnSelect(self, index, model, data)`                  | Called on model selection. `data` is the normalized data      |
| `:SetModels(table models)`                            | Set the model list                                            |
| `:GetModels()`                                        | Current model list                                            |
| `:SetSelected(int index, bool silent, bool notify)`   | Select a model by index                                       |
| `:GetSelected()`                                      | Index of the selected model                                   |
| `:GetSelectedModel()`                                 | Path of the selected model, or `nil`                          |
| `:GetSelectedData()`                                  | Data table of the selected model                              |
| `:IsSelectedModelValid()`                             | `true` if the model exists and has loaded                     |
| `:SetSearchEnabled(bool enabled)`                     | Search. Default `true`                                        |
| `:SetPreviewEnabled(bool enabled)`                    | Preview panel. Default `true`                                 |
| `:SetAutoRotate(bool enabled)`                        | Automatic model rotation. Default `false`                     |
| `:GetAutoRotate()`                                    | Whether auto-rotation is enabled                              |
| `:SetFOV(number fov)`                                 | Camera field of view (`20..70`). Default `34`                 |
| `:ResetView()`                                        | Reset the camera rotation, zoom, and position                 |
