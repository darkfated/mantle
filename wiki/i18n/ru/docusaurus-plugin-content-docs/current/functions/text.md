---
title: Текст
description: Работа с текстом
sidebar_position: 7
---

# Текст

Работа с текстом в библиотеке.

## Регистр с кириллицей

Стандартные `string.lower/upper` не преобразуют русские буквы. Библиотека добавляет поддержку с UTF-8.

```js
local txt = 'ПриВЕТ МИР Hello World'

print(string.lower(txt)) -- не изменит русские буквы
print(utf8.lower(txt))   -- "привет мир hello world"
print(utf8.upper(txt))   -- "ПРИВЕТ МИР HELLO WORLD"
```

## Локализация

Строки подключаются через файл `mantle_addons/myaddon/lang.lua`. Каждая таблица содержит секции языков (en, ru и т.д.) с ключами.

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

Язык выбирается автоматически по ConVar `gmod_language`. Если перевода нет, используется язык по умолчанию.

## Получение переведённой строки

```js
local apply = Mantle.lang.get('myaddon', 'apply')
```

| Аргумент | Тип      | Описание                                  |
| -------- | -------- | ----------------------------------------- |
| `addon`  | `string` | Имя дополнения (папка в `mantle_addons/`) |
| `key`    | `string` | Ключ строки                               |
