Mantle.color = {
    header = Color(51, 51, 51), -- верхняя панель
    background = Color(34, 34, 34), -- фон
    background_alpha = Color(34, 34, 34, 210), -- фон с прозрачностью

    sp = Color(53, 53, 53), -- задний фон скролл панели

    button = Color(76, 76, 76), -- кнопка
    button_shadow = Color(57, 55, 69, 150), -- тень кнопки для градиента

    panel = { -- варианты цветов для панели
        Color(106, 106, 114),
        Color(60, 60, 64),
        Color(193, 193, 193)
    },

    gray = Color(190, 190, 190, 220)
}

Mantle.color.panel_alpha = { -- прозрачные панели
    ColorAlpha(Mantle.color.panel[1], 150),
    ColorAlpha(Mantle.color.panel[2], 150),
    ColorAlpha(Mantle.color.panel[3], 150)
}
