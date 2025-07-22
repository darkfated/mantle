# Mantle
🎈 Универсальная GLua библиотека для написания кода в Garry's Mod: создание интерфейсов и использование удобных утилит.

Все блоки кода имеют комментарии, поэтому исследуйте код. В нём вы найдёте пояснения и примеры

## Возможности
- Использование кастомного VGUI
- Оптимизация засчёт быстрого рендеринга RNDX
- Использование материала через ссылку
- Тёмная и светлая тема
- Создание уведомлений
- Модульная система
- И многое другое!

## UI составляющая
У библиотеки есть меню: документация, настройка – всё в одном месте. Воспользуйтесь консольной командой `mantle_menu`

*Ниже можете увидеть некоторые возможности*

### Документация
<img width="813" height="608" alt="VGUI элементы" src="https://github.com/user-attachments/assets/a95430cb-75a1-4ea8-acf7-bd8228e3914e" />

### Lite-режим окна
<img width="775" height="576" alt="{ED43C1DB-8110-4695-97D3-ED9918502C21}" src="https://github.com/user-attachments/assets/628b5870-8229-408e-9794-7ab119681eba" />

### ComboBox
<img width="837" height="610" alt="ComboBox" src="https://github.com/user-attachments/assets/35033dc4-6fbb-4154-8905-01b80d8158ad" />

### SlideBox
<img width="808" height="605" alt="SlideBox" src="https://github.com/user-attachments/assets/df4bf805-5a1c-4c60-a38f-7b81d996d5b4" />

### Таблицы
<img width="802" height="602" alt="Таблицы" src="https://github.com/user-attachments/assets/3629a261-37dd-4cbd-8d75-765c91e6b8c9" />

### Поле ввода
<img width="809" height="601" alt="Поле ввода" src="https://github.com/user-attachments/assets/b37cbaed-b3b2-474a-9e70-91ff08f5ec99" />

### Множественные всплывающие меню
<img width="815" height="614" alt="Множественные всплывающие меню" src="https://github.com/user-attachments/assets/3bfe5206-9813-421c-93f2-597ca6746983" />

### Круговое меню
<img width="943" height="760" alt="Круговое меню" src="https://github.com/user-attachments/assets/d4472c3b-03ca-4140-a0a5-d1e9c0161e63" />

### Опциональное меню
<img width="830" height="612" alt="Опциональное меню" src="https://github.com/user-attachments/assets/f1977385-7de9-4bae-b8cd-408efe21d816" />

### Светлая тема
<img width="830" height="613" alt="Светлая тема документация" src="https://github.com/user-attachments/assets/db6dc9f4-d6cd-4918-ba2e-203d0ad071f7" />
<img width="864" height="732" alt="Светлая тема круговое меню" src="https://github.com/user-attachments/assets/17fbb74e-1ca4-4be3-93ae-df88134a2469" />

## Примеры использования
### Отправка серверных уведомлений
```lua
hook.Add('PlayerSpawn', 'Test', function(pl)
    Mantle.notify(pl, Color(75, 0, 0), 'Заголовок', 'Привет, ' .. pl:Name() .. '!')
    -- первым аргументом true, в случае отправки всем игрокам
end)
```

### Картинка через ссылку
```lua
http.DownloadMaterial('https://i.imgur.com/eEnGbcp.jpeg', 'dog.png', function(your_mat)
    hook.Add('HUDPaint', 'Test', function()
        surface.SetDrawColor(255, 255, 255)
        surface.SetMaterial(your_mat)
        surface.DrawTexturedRect(5, 5, 250, 330)
    end)
end)
```

### Преобразование символов кириллицы
```lua
hook.Add('HUDPaint', 'test', function()
    local txt = 'ПриВЕТ МИР Hello World'
    -- default
    draw.SimpleText(string.lower(txt), 'Fated.20', 15, 15, color_black)
    -- mantle
    draw.SimpleText(utf8.lower(txt), 'Fated.20', 15, 35, color_black)
end)
```
<img width="247" height="75" alt="Сравнение default и mantle функции" src="https://github.com/user-attachments/assets/77e0b791-e970-45da-90b3-1b4960b945fd" />


## Steam Workshop
Для автообновления – [подпишитесь и добавьте аддон в серверную коллекцию](https://steamcommunity.com/sharedfiles/filedetails/?id=3126986993). Таким образом сможете всегда получать актуальную версию библиотеки ✅
