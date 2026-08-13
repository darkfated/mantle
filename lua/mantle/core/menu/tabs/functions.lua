local menu = Mantle.menu

local icon = Material('icon16/error.png')

local function createFunctionsTab()
    local panel = menu.createTabPanel('Функции', 'Функционал, который предоставляет библиотека.', icon)

    menu.createCategory('Отрисовка и звук', {
        {'Mantle.func.blur(object panel)', 'Размыть область панели, вызывается в :Paint()'},
        {'Mantle.func.gradient(int x, int y, int w, int h, int dir, color color_shadow, int radius, flags)', 'Отрисовка градиента (dir: 1 - вверх, 2 - вниз, 3 - влево, 4 - вправо)'},
        {'Mantle.func.sound(string path)', 'Проиграть звук (стандарт - mantle/btn_click.ogg)'}
    }, panel)

    menu.createCategory('Вёрстка', {
        {'Mantle.func.w(int px)', 'На основе 1920 получить относительную ширину под ваш монитор'},
        {'Mantle.func.h(int px)', 'На основе 1080 получить относительную высоту под ваш монитор'},
        {'Mantle.func.animate_appearance(object panel, int w, int h, int duration, int alpha_dur, func callback, int scale_factor)', 'Измение панели до определённого значение с анимацией'},
        {'Mantle.func.LerpColor(int frac, color col1, color col2)', 'Плавный переход цвета от col1 до col2'},
        {'Mantle.func.approachExp(number current, number target, number speed, number dt)', 'Экспоненциальное приближение значения к Target'},
        {'Mantle.func.easeOutCubic(number t)', 'Cubic easing для анимаций с быстрым стартом и плавным окончанием'},
        {'Mantle.func.easeInOutCubic(number t)', 'Cubic easing для анимаций с плавным стартом и окончанием'},
        {'Mantle.func.ClampMenuPosition(object panel)', 'Не позволяет панели выйти за границы экрана'}
    }, panel)

    menu.createCategory('Сетевое', {
        {'Mantle.func.draw_ent_text(object ent, string text, int posY)', 'Вызывается в :Draw(). Рисует над сущностью текст'},
        {'http.DownloadMaterial(string url, string path, func callback, int retryCount)', 'Скачивает материал по URL и сохраняет в data/. Позволяет использовать картинки из интернета'},
        {'Mantle.notify(object pl, color header_color, string header, string text)', 'Отправка сообщения из сервера (если вместо pl указать true, уведомление прийдёт всем)'}
    }, panel)

    menu.createCategory('Текст', {
        { 'Mantle.lang.get(string addon, string key)', 'Возвращает переведённую строчку на основе языкового ключа' },
        {'utf8.upper(string text)', 'Преобразует строку в верхний регистр (поддержка русских букв)'},
        {'utf8.lower(string text)', 'Преобразует строку в нижний регистр (поддержка русских букв)'}
    }, panel)

    menu.createCategory('Тени (Legacy)', {
        {'BShadows.BeginShadow()', 'Начинает отрисовку тени в Render Target'},
        {'BShadows.EndShadow(number intensity, number spread, number blur, number opacity, number direction, number distance, bool shadow_only)', 'Завершает построение тени и выводит результат на экран'},
        {'BShadows.DrawShadowTexture(ITexture texture, number intensity, number spread, number blur, number opacity, number direction, number distance, bool shadow_only)', 'Рисует тень для уже готовой текстуры'}
    }, panel)

    return panel
end

menu.registerTab('functions', {
    order = 3,
    title = 'Функции',
    description = 'Функционал, который предоставляет библиотека.',
    icon = icon,
    create = createFunctionsTab
})
