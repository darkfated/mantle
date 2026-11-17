---
title: Text
description: Working with text
sidebar_position: 7
---

# Text

Text handling in the library.

## Case conversion with Cyrillic

The stock `string.lower/upper` do not convert Cyrillic letters. The library adds UTF-8 aware support.

```js
local txt = 'ПриВЕТ МИР Hello World'

print(string.lower(txt)) -- leaves Cyrillic letters untouched
print(utf8.lower(txt))   -- "привет мир hello world"
print(utf8.upper(txt))   -- "ПРИВЕТ МИР HELLO WORLD"
```

## Localization

Strings are loaded from a `mantle_addons/myaddon/lang.lua` file. Each table holds language sections (en, ru, and so on) with keys.

```js
local tabl = {}

tabl['en'] = {
    apply = 'Apply',
    cancel = 'Cancel',
}

tabl['ru'] = {
    apply = 'Применить',
    cancel = 'Отмена',
}

return tabl
```

The language is picked automatically from the `gmod_language` ConVar. If a translation is missing, the default language is used.

## Getting a translated string

```js
local apply = Mantle.lang.get('myaddon', 'apply')
```

| Argument | Type     | Description                                 |
| -------- | -------- | ------------------------------------------- |
| `addon`  | `string` | Addon name (the folder in `mantle_addons/`) |
| `key`    | `string` | String key                                  |
