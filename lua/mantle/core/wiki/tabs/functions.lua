function CreateMantleFunctionsTab()
    local panel = vgui.Create('MantleScrollPanel')

    MantleCreateCategory('Размытие панели', {
        {'Mantle.func.blur(object panel)', 'Отрисовка размытия панели в Paint'}
    }, panel)

    MantleCreateCategory('Градиент', {
        {'Mantle.func.gradient(int x, int y, int w, int h, int dir, color color_shadow, int radius, flags)', 'Отрисовка градиента (dir: 1 - вверх, 2 - вниз, 3 - влево, 4 - вправо)'}
    }, panel)

    MantleCreateCategory('Создание звука', {
        {'Mantle.func.sound(string path)', 'Проигрывает звук (дефолт - mantle/btn_click.ogg)'}
    }, panel)

    MantleCreateCategory('Относительные единицы для адаптивного интерфейса', {
        {'Mantle.func.w(int px)', 'Относительная ширина (от 1920)'},
        {'Mantle.func.h(int px)', 'Относительная высота (от 1080)'}
    }, panel)

    MantleCreateCategory('Отрисовка текста над энтити', {
        {'Mantle.func.draw_ent_text(object ent, string text, int posY)', 'Рисует текст над энтити с плавным появлением (3D2D)'}
    }, panel)

    MantleCreateCategory('Анимация размера панели', {
        {'Mantle.func.animate_appearance(object panel, int w, int h, int duration, int alpha_dur, func callback, int scale_factor)', 'Плавное изменение панели до нужного размера'}
    }, panel)

    MantleCreateCategory('Плавное изменение цвета', {
        {'Mantle.func.LerpColor(int frac, color col1, color col2)', 'Плавный переход цвета от col1 → col2'}
    }, panel)

    MantleCreateCategory('Загрузка картинки', {
        {'http.DownloadMaterial(string url, string path, func callback, int retry_count)', 'Скачивает материал по URL и кэширует его. Повторяет попытку при ошибке, возвращает через callback материал'}
    }, panel)

    MantleCreateCategory('Серверное уведомление', {
        {'Mantle.notify(object pl, color header_color, string header, string text)', 'Отправка сообщений в чат игроку или всем (вместо pl указать true - тогда всем)'}
    }, panel)

    MantleCreateCategory('Изменение регистра букв', {
        {'utf8.lower(string text)', 'Преобразует строку в нижний регистр с поддержкой русских букв'},
        {'utf8.upper(string text)', 'Преобразует строку в верхний регистр с поддержкой русских букв'}
    }, panel)

    return panel
end
