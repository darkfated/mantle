local menu = Mantle.menu

local icon = Material('icon16/error.png')

local function createFunctionsTab()
    local panel = menu.createTabPanel('Функции', 'Функционал, который предоставляет библиотека.', icon)

    menu.createCategory('Отрисовка и звук', {
        {'Mantle.func.blur(object panel)', 'Размывает фон под панелью. Вызывается в :Paint()'},
        {'Mantle.func.gradient(int x, int y, int w, int h, int dir, color col, int radius, int flags)', 'Градиент в области (dir: 1 - вверх, 2 - вниз, 3 - влево, 4 - вправо)'},
        {'Mantle.func.sound(string path)', 'Проиграть звук (по умолчанию - mantle/btn_click.ogg)'}
    }, panel)

    menu.createCategory('Вёрстка и анимация', {
        {'Mantle.func.w(int px)', 'Относительная ширина на основе 1920 - подгонит размер под любой монитор'},
        {'Mantle.func.h(int px)', 'Относительная высота на основе 1080'},
        {'Mantle.func.animate_appearance(object panel, int w, int h, int duration, int alpha_dur, func callback, int scale_factor)', 'Анимация появления: панель вырастает из малого размера с нулевой прозрачностью до целевого'},
        {'Mantle.func.LerpColor(int frac, color col1, color col2)', 'Плавный переход цвета от col1 к col2 (frac - скорость за кадр)'},
        {'Mantle.func.approachExp(number current, number target, number speed, number dt)', 'Экспоненциальное приближение current к target'},
        {'Mantle.func.easeOutCubic(number t)', 'Cubic easing: быстрый старт, плавное окончание'},
        {'Mantle.func.easeInOutCubic(number t)', 'Cubic easing: плавные старт и окончание'},
        {'Mantle.func.ClampMenuPosition(object panel)', 'Не даёт панели выйти за границы экрана'}
    }, panel)

    menu.createCategory('3D и сетевое', {
        {'Mantle.func.draw_ent_text(object ent, string text, int posY)', 'Рисует текст над сущностью в 3D. Вызывается в ENT:Draw'},
        {'http.DownloadMaterial(string url, string path, func callback, int retry_count)', 'Скачивает картинку по URL в data/ и отдаёт материал в callback. Кэшируется - повторные вызовы не качают заново'},
        {'Mantle.notify(object pl, color header_color, string header, string text)', 'Отправляет сообщение из сервера в чат. Если вместо pl передать true - уведомление придёт всем'}
    }, panel)

    menu.createCategory('Текст и локализация', {
        {'Mantle.lang.get(string addon, string key)', 'Переведённая строка по ключу. Язык подхватывается из gmod_language'},
        {'utf8.upper(string text)', 'Верхний регистр с поддержкой русских букв'},
        {'utf8.lower(string text)', 'Нижний регистр с поддержкой русских букв'}
    }, panel)

    menu.createCategory('Шрифты Fated.*', {
        {'Fated.NN (например Fated.20)', 'Шрифт Montserrat Medium нужного размера. Можно использовать в интерфейсе'},
        {'Fated.NNb (например Fated.20b)', 'Жирная версия того же шрифта'}
    }, panel)

    menu.createCategory('Отрисовка (RNDX)', {
        {'RNDX.Rect(int x, int y, int w, int h)', 'Начать построение прямоугольника. Дальше - цепочка модификаторов'},
        {':Rad(int rad) / :Radii(int tl, int tr, int bl, int br)', 'Скругление углов: всех сразу или каждого отдельно'},
        {':Color(color col или int r, int g, int b, int a)', 'Цвет заливки'},
        {':Outline(int thickness)', 'Обводка (по умолчанию - 1)'},
        {':Texture(ITexture) / :Material(IMaterial)', 'Картинка внутри фигуры'},
        {':Blur(int intensity)', 'Размытие фона внутри фигуры'},
        {':Shadow(int blur, int spread, int offset_x, int offset_y)', 'Тень под фигурой'},
        {':Rotation(int deg)', 'Поворот фигуры'},
        {':Angles(int start, int end)', 'Сектор круга (для RNDX.Circle)'},
        {':Clip(object panel)', 'Обрезать отрисовку по границам панели'},
        {':Flags(int flags)', 'Быстрые флаги: RNDX.NO_TL/TR/BL/BR (убрать углы), RNDX.BLUR, RNDX.MANUAL_COLOR'},
        {':Draw()', 'Завершить и вывести фигуру на экран'},
        {'RNDX.Circle(int x, int y, int radius)', 'Круг по центру. Работают те же модификаторы (кроме скругления)'}
    }, panel)

    menu.createCategory('Темы интерфейса', {
        {'Mantle.ui.getActiveThemeName()', 'ID активной темы (dark, red, blue и т.д.)'},
        {'Mantle.ui.getAvailableThemes()', 'Список доступных тем - { {id, title, colors}, ... }'},
        {'Mantle.color', 'Цвета активной темы: theme, background, text, panel, button и другие'}
    }, panel)

    menu.createCategory('Тени (Legacy)', {
        {'BShadows.BeginShadow()', 'Начинает отрисовку тени в Render Target'},
        {'BShadows.EndShadow(number intensity, number spread, number blur, number opacity, number direction, number distance, bool shadow_only)', 'Завершает построение тени и выводит результат на экран'},
        {'BShadows.DrawShadowTexture(ITexture texture, ...)', 'Рисует тень для уже готовой текстуры'}
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
