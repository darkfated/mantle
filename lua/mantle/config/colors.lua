Mantle.color_dark = {
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

    gray = Color(190, 190, 190, 220),
    text = Color(255, 255, 255)
}

Mantle.color_dark.panel_alpha = { -- прозрачные панели
    ColorAlpha(Mantle.color_dark.panel[1], 150),
    ColorAlpha(Mantle.color_dark.panel[2], 150),
    ColorAlpha(Mantle.color_dark.panel[3], 150)
}

Mantle.color = Mantle.color_dark

-- Светлая палитра
Mantle.color_light = {
    header = Color(240, 240, 240),
    background = Color(255, 255, 255),
    background_alpha = Color(255, 255, 255, 170),
    background_panelpopup = Color(245, 245, 245),

    button = Color(235, 235, 235),
    button_shadow = Color(0, 0, 0, 15),
    button_hovered = Color(215, 220, 255),

    category = Color(240, 240, 245),
    category_opened = Color(240, 240, 245, 0),

    theme = Color(106, 108, 197),

    panel = {
        Color(250, 250, 255),
        Color(240, 240, 245),
        Color(230, 230, 235)
    },

    focus_panel = Color(245, 245, 255),
    hover = Color(235, 240, 255),

    window_shadow = Color(0, 0, 0, 50),

    gray = Color(130, 130, 130, 220),
    text = Color(20, 20, 20)
}

Mantle.color_light.panel_alpha = {
    ColorAlpha(Mantle.color_light.panel[1], 120),
    ColorAlpha(Mantle.color_light.panel[2], 120),
    ColorAlpha(Mantle.color_light.panel[3], 120)
}
