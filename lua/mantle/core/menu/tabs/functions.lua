local menu = Mantle.menu

local function build()
    local panel = menu.createTabPanel()

    menu.createCategory(panel, {
        title = 'Отрисовка и звук',
        rows = {
            { name = 'Mantle.func.blur(object panel)', desc = 'Размывает фон под панелью. Вызывается в :Paint()' },
            { name = 'Mantle.func.gradient(int x, int y, int w, int h, int dir, color col, int radius, int flags)', desc = 'Градиент в области (dir: 1 - вверх, 2 - вниз, 3 - влево, 4 - вправо)' },
            { name = 'Mantle.func.sound(string path)', desc = 'Проиграть звук (по умолчанию - mantle/btn_click.ogg)' }
        }
    })

    menu.createCategory(panel, {
        title = 'Вёрстка и анимация',
        rows = {
            { name = 'Mantle.func.w(int px)', desc = 'Относительная ширина на основе 1920 - подгонит размер под любой монитор' },
            { name = 'Mantle.func.h(int px)', desc = 'Относительная высота на основе 1080' },
            { name = 'Mantle.func.animate_appearance(object panel, int w, int h, int duration, int alpha_dur, func callback, int scale_factor)', desc = 'Анимация появления: панель вырастает из малого размера с нулевой прозрачностью до целевого' },
            { name = 'Mantle.func.LerpColor(int frac, color col1, color col2)', desc = 'Плавный переход цвета от col1 к col2 (frac - скорость за кадр)' },
            { name = 'Mantle.func.approachExp(number current, number target, number speed, number dt)', desc = 'Экспоненциальное приближение current к target' },
            { name = 'Mantle.func.easeOutCubic(number t)', desc = 'Cubic easing: быстрый старт, плавное окончание' },
            { name = 'Mantle.func.easeInOutCubic(number t)', desc = 'Cubic easing: плавные старт и окончание' },
            { name = 'Mantle.func.ClampMenuPosition(object panel)', desc = 'Не даёт панели выйти за границы экрана' }
        }
    })

    menu.createCategory(panel, {
        title = '3D и сетевое',
        rows = {
            { name = 'Mantle.func.draw_ent_text(object ent, string text, int posY)', desc = 'Рисует текст над сущностью в 3D. Вызывается в ENT:Draw' },
            { name = 'http.DownloadMaterial(string url, string path, func callback, int retry_count)', desc = 'Скачивает картинку по URL в data/ и отдаёт материал в callback. Кэшируется - повторные вызовы не качают заново' },
            { name = 'Mantle.notify(object pl, color header_color, string header, string text)', desc = 'Отправляет сообщение из сервера в чат. Если вместо pl передать true - уведомление придёт всем' }
        }
    })

    menu.createCategory(panel, {
        title = 'Текст и локализация',
        rows = {
            { name = 'Mantle.lang.get(string addon, string key)', desc = 'Переведённая строка по ключу. Язык подхватывается из gmod_language' },
            { name = 'utf8.upper(string text)', desc = 'Верхний регистр с поддержкой русских букв' },
            { name = 'utf8.lower(string text)', desc = 'Нижний регистр с поддержкой русских букв' }
        }
    })

    menu.createCategory(panel, {
        title = 'Шрифты Fated.*',
        rows = {
            { name = 'Fated.NN (например Fated.20)', desc = 'Шрифт Montserrat Medium нужного размера. Можно использовать в интерфейсе' },
            { name = 'Fated.NNb (например Fated.20b)', desc = 'Жирная версия того же шрифта' }
        }
    })

    menu.createCategory(panel, {
        title = 'Отрисовка (RNDX)',
        rows = {
            { name = 'RNDX.Rect(int x, int y, int w, int h)', desc = 'Начать построение прямоугольника. Дальше - цепочка модификаторов' },
            { name = 'RNDX.Circle(int x, int y, int radius)', desc = 'Круг по центру. Работают те же модификаторы (кроме скругления)' },
            { name = ':Rad(int rad) / :Radii(int tl, int tr, int bl, int br)', desc = 'Скругление углов: всех сразу или каждого отдельно' },
            { name = ':Color(color col или int r, int g, int b, int a)', desc = 'Цвет заливки' },
            { name = ':Outline(int thickness)', desc = 'Обводка вместо заливки (по умолчанию - 1)' },
            { name = ':Texture(ITexture) / :Material(IMaterial)', desc = 'Картинка внутри фигуры' },
            { name = ':Blur(int intensity)', desc = 'Размытие фона внутри фигуры' },
            { name = ':Fade(int top, int bottom)', desc = 'Вертикальное затухание (1 - видно, 0 - прозрачно). Например :Fade(1, 0) - прозрачно снизу' },
            { name = ':Shadow(int blur, int spread, int offset_x, int offset_y)', desc = 'Тень под фигурой' },
            { name = ':Rotation(int deg)', desc = 'Поворот фигуры' },
            { name = ':Angles(int start, int end)', desc = 'Сектор круга (для RNDX.Circle)' },
            { name = ':Clip(object panel)', desc = 'Обрезать отрисовку по границам панели' },
            { name = ':Flags(int flags)', desc = 'Быстрые флаги: RNDX.NO_TL/TR/BL/BR (убрать углы), RNDX.BLUR, RNDX.MANUAL_COLOR' },
            { name = ':Draw()', desc = 'Завершить и вывести фигуру на экран' }
        }
    })

    menu.createCategory(panel, {
        title = 'Темы интерфейса',
        rows = {
            { name = 'Mantle.ui.getActiveThemeName()', desc = 'ID активной темы (dark, red, blue и т.д.)' },
            { name = 'Mantle.ui.getAvailableThemes()', desc = 'Список доступных тем - { {id, title, colors}, ... }' },
            { name = 'Mantle.color', desc = 'Цвета активной темы: theme, background, text, panel, button и другие' }
        }
    })

    menu.createCategory(panel, {
        title = 'Тени (Legacy)',
        rows = {
            { name = 'BShadows.BeginShadow()', desc = 'Начинает отрисовку тени в Render Target' },
            { name = 'BShadows.EndShadow(number intensity, number spread, number blur, number opacity, number direction, number distance, bool shadow_only)', desc = 'Завершает построение тени и выводит результат на экран' },
            { name = 'BShadows.DrawShadowTexture(ITexture texture, ...)', desc = 'Рисует тень для уже готовой текстуры' }
        }
    })

    return panel
end

menu.registerTab('functions', {
    order = 3,
    title = 'Функции',
    description = 'Функционал, который предоставляет библиотека.',
    icon = Material('icon16/error.png'),
    build = build
})
