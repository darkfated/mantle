Mantle.color_dark = {
    header = Color(51, 51, 51), -- верхняя панель
    header_text = Color(109, 109, 109), -- цвет элементов в заголовке
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

-- Тёмная палитра (монотонная)

Mantle.color_dark_mono = table.Copy(Mantle.color_dark)
Mantle.color_dark_mono.theme = Color(121, 121, 121)

-- Светлая палитра
Mantle.color_light = {
    header = Color(240, 240, 240),
    header_text = Color(150, 150, 150),
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

-- Синяя палитра
Mantle.color_blue = {
    header = Color(36, 48, 66),
    header_text = Color(109, 129, 159),
    background = Color(24, 28, 38),
    background_alpha = Color(24, 28, 38, 210),
    background_panelpopup = Color(20, 24, 32),

    button = Color(38, 54, 82),
    button_shadow = Color(18, 22, 32, 35),
    button_hovered = Color(70, 120, 180),

    category = Color(34, 48, 72),
    category_opened = Color(34, 48, 72, 0),

    theme = Color(80, 160, 220),

    panel = {
        Color(34, 48, 72),
        Color(38, 54, 82),
        Color(70, 120, 180)
    },

    focus_panel = Color(48, 72, 90),
    hover = Color(80, 160, 220, 90),

    window_shadow = Color(18, 22, 32, 90),

    gray = Color(150, 170, 190, 200),
    text = Color(210, 220, 235)
}
Mantle.color_blue.panel_alpha = {
    ColorAlpha(Mantle.color_blue.panel[1], 110),
    ColorAlpha(Mantle.color_blue.panel[2], 110),
    ColorAlpha(Mantle.color_blue.panel[3], 110)
}

-- Красная палитра
Mantle.color_red = {
    header = Color(54, 36, 36),
    header_text = Color(159, 109, 109),
    background = Color(32, 24, 24),
    background_alpha = Color(32, 24, 24, 210),
    background_panelpopup = Color(28, 20, 20),

    button = Color(66, 38, 38),
    button_shadow = Color(32, 18, 18, 35),
    button_hovered = Color(140, 70, 70),

    category = Color(62, 34, 34),
    category_opened = Color(62, 34, 34, 0),

    theme = Color(180, 80, 80),

    panel = {
        Color(62, 34, 34),
        Color(66, 38, 38),
        Color(140, 70, 70)
    },

    focus_panel = Color(72, 48, 48),
    hover = Color(180, 80, 80, 90),

    window_shadow = Color(32, 18, 18, 90),

    gray = Color(180, 150, 150, 200),
    text = Color(235, 210, 210)
}
Mantle.color_red.panel_alpha = {
    ColorAlpha(Mantle.color_red.panel[1], 110),
    ColorAlpha(Mantle.color_red.panel[2], 110),
    ColorAlpha(Mantle.color_red.panel[3], 110)
}

-- Зелёная палитра
Mantle.color_green = {
    header = Color(36, 54, 40),
    header_text = Color(109, 159, 109),
    background = Color(24, 32, 26),
    background_alpha = Color(24, 32, 26, 210),
    background_panelpopup = Color(20, 28, 22),

    button = Color(38, 66, 48),
    button_shadow = Color(18, 32, 22, 35),
    button_hovered = Color(70, 140, 90),

    category = Color(34, 62, 44),
    category_opened = Color(34, 62, 44, 0),

    theme = Color(80, 180, 120),

    panel = {
        Color(34, 62, 44),
        Color(38, 66, 48),
        Color(70, 140, 90)
    },

    focus_panel = Color(48, 72, 58),
    hover = Color(80, 180, 120, 90),

    window_shadow = Color(18, 32, 22, 90),

    gray = Color(150, 180, 150, 200),
    text = Color(210, 235, 210)
}
Mantle.color_green.panel_alpha = {
    ColorAlpha(Mantle.color_green.panel[1], 110),
    ColorAlpha(Mantle.color_green.panel[2], 110),
    ColorAlpha(Mantle.color_green.panel[3], 110)
}
