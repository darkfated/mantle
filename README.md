# Mantle
🎈 GLua библиотека для написания кода в Garry's Mod: создание интерфейсов и использование удобных утилит.

## Возможности
- Использование кастомного VGUI
- Создание теней благодаря модулю "shadows"
- Использование материала через ссылку на картинку
- Создание уведомлений
- И многое другое в будущем!

## Демонстрация UI составляющей
Для запуска меню библиотеки, воспользуйтесь консольной командой `mantle_menu`

![VGUI элементы](https://github.com/user-attachments/assets/08d6358a-43a1-41f7-ae3d-3c45aaa66c48)
![Всплывающие меню](https://github.com/user-attachments/assets/4a0638d1-0d69-444d-93ce-6d6fa25c814b)

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

## Дополнительная информация
Все скрипты Mantle имеют комментарии, поэтому исследуйте код. В нём вы найдёте примеры, а также рекомендации.

**Подпишитесь и добавьте в коллекцию библиотеку, чтобы получать обновления автоматически** ✅ [Steam Workshop](https://steamcommunity.com/sharedfiles/filedetails/?id=3126986993)
