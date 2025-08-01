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

-- Графитная палитра
Mantle.color_graphite = {
    header = Color(40, 40, 40),
    header_text = Color(100, 100, 100),
    background = Color(25, 25, 25),
    background_alpha = Color(25, 25, 25, 210),
    background_panelpopup = Color(20, 20, 20),

    button = Color(45, 45, 45),
    button_shadow = Color(0, 0, 0, 25),
    button_hovered = Color(60, 60, 60),

    category = Color(50, 50, 50),
    category_opened = Color(50, 50, 50, 0),

    theme = Color(130, 130, 130),

    panel = {
        Color(60, 60, 60),
        Color(50, 50, 50),
        Color(80, 80, 80)
    },

    focus_panel = Color(55, 55, 55),
    hover = Color(70, 70, 70),

    window_shadow = Color(0, 0, 0, 120),

    gray = Color(150, 150, 150, 220),
    text = Color(220, 220, 220)
}
Mantle.color_graphite.panel_alpha = {
    ColorAlpha(Mantle.color_graphite.panel[1], 130),
    ColorAlpha(Mantle.color_graphite.panel[2], 130),
    ColorAlpha(Mantle.color_graphite.panel[3], 130)
}

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

-- Оранжевая палитра
Mantle.color_orange = {
    header = Color(255, 200, 100),
    header_text = Color(200, 120, 30),
    background = Color(255, 245, 220),
    background_alpha = Color(255, 245, 220, 210),
    background_panelpopup = Color(255, 230, 180),

    button = Color(255, 210, 140),
    button_shadow = Color(255, 200, 100, 30),
    button_hovered = Color(255, 170, 60),

    category = Color(255, 230, 180),
    category_opened = Color(255, 230, 180, 0),

    theme = Color(255, 170, 60),

    panel = {
        Color(255, 230, 180),
        Color(255, 210, 140),
        Color(255, 170, 60)
    },

    focus_panel = Color(255, 210, 140),
    hover = Color(255, 200, 100, 90),

    window_shadow = Color(255, 200, 100, 90),

    gray = Color(180, 150, 120, 200),
    text = Color(120, 70, 0)
}
Mantle.color_orange.panel_alpha = {
    ColorAlpha(Mantle.color_orange.panel[1], 110),
    ColorAlpha(Mantle.color_orange.panel[2], 110),
    ColorAlpha(Mantle.color_orange.panel[3], 110)
}

-- Фиолетовая палитра
Mantle.color_purple = {
    header = Color(120, 81, 169),
    header_text = Color(180, 140, 220),
    background = Color(60, 40, 90),
    background_alpha = Color(60, 40, 90, 210),
    background_panelpopup = Color(80, 60, 120),

    button = Color(140, 100, 200),
    button_shadow = Color(120, 81, 169, 30),
    button_hovered = Color(180, 140, 220),

    category = Color(100, 70, 150),
    category_opened = Color(100, 70, 150, 0),

    theme = Color(180, 140, 220),

    panel = {
        Color(100, 70, 150),
        Color(140, 100, 200),
        Color(180, 140, 220)
    },

    focus_panel = Color(140, 100, 200),
    hover = Color(180, 140, 220, 90),

    window_shadow = Color(120, 81, 169, 90),

    gray = Color(180, 170, 200, 200),
    text = Color(230, 220, 255)
}
Mantle.color_purple.panel_alpha = {
    ColorAlpha(Mantle.color_purple.panel[1], 110),
    ColorAlpha(Mantle.color_purple.panel[2], 110),
    ColorAlpha(Mantle.color_purple.panel[3], 110)
}

-- Кофейная палитра
Mantle.color_coffee = {
    header = Color(44, 28, 17),
    header_text = Color(236, 220, 200),
    background = Color(54, 34, 20),
    background_alpha = Color(54, 34, 20, 220),
    background_panelpopup = Color(48, 30, 18),

    button = Color(193, 142, 80),
    button_shadow = Color(30, 20, 10, 80),
    button_hovered = Color(213, 162, 100),

    category = Color(120, 75, 40),
    category_opened = Color(120, 75, 40, 0),

    theme = Color(210, 160, 100),

    panel = {
        Color(85, 50, 30),
        Color(120, 75, 40),
        Color(160, 100, 55)
    },

    focus_panel = Color(102, 65, 35),
    hover = Color(210, 160, 100, 90),

    window_shadow = Color(20, 15, 10, 120),

    gray = Color(180, 150, 130, 200),
    text = Color(35, 20, 10)
}
Mantle.color_coffee.panel_alpha = {
    ColorAlpha(Mantle.color_coffee.panel[1], 120),
    ColorAlpha(Mantle.color_coffee.panel[2], 120),
    ColorAlpha(Mantle.color_coffee.panel[3], 120)
}

-- Ледяная палитра
Mantle.color_ice = {
    header = Color(190, 225, 250),
    header_text = Color(25, 45, 65),
    background = Color(235, 245, 255),
    background_alpha = Color(235, 245, 255, 200),
    background_panelpopup = Color(220, 235, 245),

    button = Color(145, 185, 225),
    button_shadow = Color(80, 110, 140, 40),
    button_hovered = Color(170, 210, 255),

    category = Color(200, 225, 245),
    category_opened = Color(200, 225, 245, 0),

    theme = Color(100, 170, 230),

    panel = {
        Color(210, 235, 250),
        Color(190, 220, 240),
        Color(100, 170, 230)
    },

    focus_panel = Color(205, 230, 245),
    hover = Color(100, 170, 230, 80),

    window_shadow = Color(60, 100, 140, 80),

    gray = Color(160, 180, 200, 200),
    text = Color(20, 35, 50)
}
Mantle.color_ice.panel_alpha = {
    ColorAlpha(Mantle.color_ice.panel[1], 120),
    ColorAlpha(Mantle.color_ice.panel[2], 120),
    ColorAlpha(Mantle.color_ice.panel[3], 120)
}
