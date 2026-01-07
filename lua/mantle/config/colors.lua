Mantle.color_dark = {
    background = Color(32, 32, 32, 220), -- фон
    background_alpha = Color(32, 32, 32, 220), -- фон прозрачный (тот же, просто для совместимости)
    outline = Color(255, 255, 255, 40), -- обводка

    btn_close = Color(255, 93, 98), -- кнопка закрытия
    btn_middle = Color(248, 201, 0), -- средняя кнопка
    btn_right = Color(52, 200, 91), -- правая кнопка

    tab_panel = Color(40, 40, 40, 200), -- фон для вкладок
    tab_text = Color(129, 129, 129), -- текст вкладок
    tab_active = Color(255, 255, 255), -- активная вкладка
    tab_top_panel = Color(25, 25, 25, 200), -- фон для верхней панели вкладок с информацией

    text = Color(255, 255, 255),
    text_muted = Color(170, 170, 170),

    p = Color(102, 102, 102, 130), -- основной цвет для панели (или кнопки)
    p_hovered = Color(102, 102, 102), -- при наведении для кнопки
    p_outline = Color(255, 255, 255, 10), -- обводка панели или кнопки

    theme = Color(61, 113, 255), -- основная цветовая тема

    // Cтарое, будет удалено
    background_panelpopup = Color(20, 20, 20, 150), -- фон для DermaMenu

    button = Color(54, 54, 54), -- кнопка
    button_shadow = Color(0, 0, 0, 25), -- тень кнопки для градиента
    button_hovered = Color(60, 60, 62), -- кнопка при наведении

    panel = { -- варианты цветов для панели
        Color(60, 60, 60),
        Color(50, 50, 50),
        Color(80, 80, 80)
    },

    toggle = Color(56, 56, 56), -- тумблер

    focus_panel = Color(46, 46, 46, 200), -- универсальный цвет для элементов
    hover = Color(60, 65, 80), -- универсальное выделение

    window_shadow = Color(0, 0, 0, 100), -- тень окна

    gray = Color(150, 150, 150, 220),
}
Mantle.color_dark.panel_alpha = { -- прозрачные панели
    ColorAlpha(Mantle.color_dark.panel[1], 150),
    ColorAlpha(Mantle.color_dark.panel[2], 150),
    ColorAlpha(Mantle.color_dark.panel[3], 150)
}

Mantle.color = Mantle.color_dark
