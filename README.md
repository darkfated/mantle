# Mantle
🎈 Универсальная GLua библиотека для написания кода в Garry's Mod: создание интерфейсов и использование удобных утилит.

Все блоки кода имеют комментарии, поэтому исследуйте код. В нём вы найдёте пояснения и примеры

## Возможности
- Использование кастомного VGUI
- Оптимизация засчёт кастомного рендеринга RNDX
- Создание теней благодаря модулю "shadows"
- Использование материала через ссылку
- Создание уведомлений
- И многое другое!

## Демонстрация UI составляющей
Для запуска меню библиотеки, воспользуйтесь консольной командой `mantle_menu`

### VGUI элементы
![VGUI элементы](https://github.com/user-attachments/assets/e57f0000-6ccd-41fe-926a-2f754ec62860)
### ComboBox
![ComboBox](https://github.com/user-attachments/assets/fc5f1279-2a9c-4334-b180-abbd68e59838)
### CheckBox
![CheckBox](https://github.com/user-attachments/assets/2b6c2e08-5f61-4fc1-a247-dccc1fc480be)
### Таблицы
![Таблицы](https://github.com/user-attachments/assets/347f2f69-481f-44f9-9c0c-5ec40364d4c3)
### Всплывающие меню
![Всплывающие меню](https://github.com/user-attachments/assets/ebb19369-f025-4b1d-bca9-de23daaa2231)
### Круговое меню
![Круговое меню](https://github.com/user-attachments/assets/02f04acc-0b7d-4585-8a81-768c49e8cab5)

## Примеры использования
### Отправка серверных уведомлений
```lua
hook.Add('PlayerSpawn', 'Test', function(pl)
    Mantle.notify(pl, Color(75, 0, 0), 'Заголовок', 'Привет, ' .. pl:Name() .. '!')
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

## Steam Workshop
Для автообновления библиотеки по мере выхода обновлений - [подпишитесь и добавьте аддон в серверную коллекцию](https://steamcommunity.com/sharedfiles/filedetails/?id=3126986993). Таким образом сможете всегда получать актуальную версию библиотеки ✅

