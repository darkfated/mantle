Mantle.color = {
    header = Color(51, 51, 51), -- верхняя панель
    background = Color(34, 34, 34), -- фон
    background_alpha = Color(34, 34, 34, 210), -- фон с прозрачностью
    background_panelpopup = Color(29, 29, 29), -- фон для DermaMenu

    button = Color(56, 56, 56), -- кнопка
    button_shadow = Color(0, 0, 0, 30), -- тень кнопки для градиента
    button_hovered = Color(52, 70, 109), -- кнопка при наведении

    category = Color(54, 54, 56), -- категория
    category_opened = Color(54, 54, 56, 0), -- категория открыта

    theme = Color(106, 108, 197), -- тема интерфейса

    panel = { -- варианты цветов для панели
        Color(71, 71, 75),
        Color(60, 60, 64),
        Color(193, 193, 193)
    },

    focus_panel = Color(46, 46, 46), -- универсальный цвет для элементов
    hover = Color(60, 65, 80), -- универсальное выделение

    window_shadow = Color(0, 0, 0, 150), -- тень окна

    gray = Color(190, 190, 190, 220)
}

Mantle.color.panel_alpha = { -- прозрачные панели
    ColorAlpha(Mantle.color.panel[1], 150),
    ColorAlpha(Mantle.color.panel[2], 150),
    ColorAlpha(Mantle.color.panel[3], 150)
}
