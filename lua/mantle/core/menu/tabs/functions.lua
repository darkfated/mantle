local menu = Mantle.menu

local icon = Material('icon16/error.png')

local function createFunctionsTab()
    local panel = menu.createTabPanel('Функции', 'Полный список утилитарных функций Mantle.func и других вспомогательных функций', icon)

    menu.createCategory('Отрисовка и звук', {
        {'Mantle.func.blur(object panel)', 'Отрисовка размытия панели в Paint'},
        {'Mantle.func.gradient(int x, int y, int w, int h, int dir, color color_shadow, int radius, flags)', 'Отрисовка градиента (dir: 1 - вверх, 2 - вниз, 3 - влево, 4 - вправо)'},
        {'Mantle.func.sound(string path)', 'Проигрывает звук (дефолт - mantle/btn_click.ogg)'}
    }, panel)

    menu.createCategory('Адаптив, позиционирование и анимации', {
        {'Mantle.func.w(int px)', 'Относительная ширина (от 1920)'},
        {'Mantle.func.h(int px)', 'Относительная высота (от 1080)'},
        {'Mantle.func.animate_appearance(object panel, int w, int h, int duration, int alpha_dur, func callback, int scale_factor)', 'Плавное изменение панели до нужного размера'},
        {'Mantle.func.LerpColor(int frac, color col1, color col2)', 'Плавный переход цвета от col1 до col2'},
        {'Mantle.func.approachExp(number current, number target, number speed, number dt)', 'Экспоненциальное приближение значения к target'},
        {'Mantle.func.easeOutCubic(number t)', 'Cubic easing для анимаций с быстрым стартом и плавным окончанием'},
        {'Mantle.func.easeInOutCubic(number t)', 'Cubic easing для анимаций с плавным стартом и окончанием'},
        {'Mantle.func.ClampMenuPosition(object panel)', 'Ограничивает позицию окна/меню границами экрана'}
    }, panel)

    menu.createCategory('Entity и сетевые утилиты', {
        {'Mantle.func.draw_ent_text(object ent, string text, int posY)', 'Рисует текст над энтити с плавным появлением (3D2D)'},
        {'http.DownloadMaterial(string url, string path, func callback, int retryCount)', 'Скачивает материал по URL, сохраняет в data/, кэширует и объединяет одинаковые параллельные запросы'},
        {'Mantle.notify(object pl, color header_color, string header, string text)', 'Отправка сообщений в чат игроку или всем (вместо pl указать true - тогда всем)'}
    }, panel)

    menu.createCategory('Локализация и UTF-8', {
        {'Mantle.lang.get(string addon, string key)', 'Возвращает локализованную строку аддона по ключу'},
        {'utf8.lower(string text)', 'Преобразует строку в нижний регистр с поддержкой русских букв'},
        {'utf8.upper(string text)', 'Преобразует строку в верхний регистр с поддержкой русских букв'}
    }, panel)

    menu.createCategory('Legacy-тени', {
        {'BShadows.BeginShadow()', 'Начинает отрисовку тени в render target'},
        {'BShadows.EndShadow(number intensity, number spread, number blur, number opacity, number direction, number distance, bool shadow_only)', 'Завершает построение тени и выводит результат на экран'},
        {'BShadows.DrawShadowTexture(ITexture texture, number intensity, number spread, number blur, number opacity, number direction, number distance, bool shadow_only)', 'Рисует тень для уже готовой текстуры'}
    }, panel)

    return panel
end

menu.registerTab('functions', {
    order = 3,
    title = 'Функции',
    description = 'Справочник по встроенным функциям Mantle',
    icon = icon,
    create = createFunctionsTab
})
