Mantle.color = {
    header = Color(51, 51, 51), -- верхняя панель
    background = Color(34, 34, 34), -- фон
    background_alpha = Color(34, 34, 34, 210), -- фон с прозрачностью
    background_dermapanel = Color(29, 29, 29), -- фон для DermaMenu

    sp = Color(53, 53, 53), -- задний фон скролл панели

    button = Color(76, 76, 76), -- кнопка
    button_shadow = Color(57, 55, 69, 150), -- тень кнопки для градиента
    button_hovered = Color(52, 70, 109), -- кнопка при наведении

    theme = Color(106, 108, 197), -- тема интерфейса

    panel = { -- варианты цветов для панели
        Color(106, 106, 114),
        Color(60, 60, 64),
        Color(193, 193, 193)
    },

    hover = Color(60, 65, 80),

    gray = Color(190, 190, 190, 220)
}

Mantle.color.panel_alpha = { -- прозрачные панели
    ColorAlpha(Mantle.color.panel[1], 150),
    ColorAlpha(Mantle.color.panel[2], 150),
    ColorAlpha(Mantle.color.panel[3], 150)
}
