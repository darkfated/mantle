Mantle.color_dark = {
    header = Color(40, 40, 40), -- верхняя панель
    header_text = Color(100, 100, 100), -- цвет элементов в заголовке
    background = Color(25, 25, 25), -- фон
    background_alpha = Color(25, 25, 25, 210), -- фон с прозрачностью
    background_panelpopup = Color(20, 20, 20, 150), -- фон для DermaMenu

    button = Color(54, 54, 54), -- кнопка
    button_shadow = Color(0, 0, 0, 25), -- тень кнопки для градиента
    button_hovered = Color(60, 60, 62), -- кнопка при наведении

    category = Color(50, 50, 50), -- категория
    category_opened = Color(50, 50, 50, 0), -- категория открыта

    theme = Color(106, 108, 197), -- тема интерфейса

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
    text = Color(255, 255, 255)
}
Mantle.color_dark.panel_alpha = { -- прозрачные панели
    ColorAlpha(Mantle.color_dark.panel[1], 150),
    ColorAlpha(Mantle.color_dark.panel[2], 150),
    ColorAlpha(Mantle.color_dark.panel[3], 150)
}

-- Тёмная палитра (монотонная)

Mantle.color_dark_mono = table.Copy(Mantle.color_dark)
Mantle.color_dark_mono.theme = Color(121, 121, 121)

-- Светлая палитра
Mantle.color_light = {
    header = Color(240, 240, 240),
    header_text = Color(150, 150, 150),
    background = Color(255, 255, 255),
    background_alpha = Color(255, 255, 255, 170),
    background_panelpopup = Color(245, 245, 245, 150),

    button = Color(235, 235, 235),
    button_shadow = Color(0, 0, 0, 15),
    button_hovered = Color(196, 199, 218),

    category = Color(240, 240, 245),
    category_opened = Color(240, 240, 245, 0),

    theme = Color(106, 108, 197),

    panel = {
        Color(250, 250, 255),
        Color(240, 240, 245),
        Color(230, 230, 235)
    },

    toggle = Color(220, 220, 230),

    focus_panel = Color(245, 245, 255, 200),
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
    background_panelpopup = Color(20, 24, 32, 150),

    button = Color(38, 54, 82),
    button_shadow = Color(18, 22, 32, 35),
    button_hovered = Color(47, 69, 110),

    category = Color(34, 48, 72),
    category_opened = Color(34, 48, 72, 0),

    theme = Color(80, 160, 220),

    panel = {
        Color(34, 48, 72),
        Color(38, 54, 82),
        Color(70, 120, 180)
    },

    toggle = Color(34, 44, 66),

    focus_panel = Color(48, 72, 90, 200),
    hover = Color(80, 160, 220, 90),

    window_shadow = Color(18, 22, 32, 100),

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
    background_panelpopup = Color(28, 20, 20, 150),

    button = Color(66, 38, 38),
    button_shadow = Color(32, 18, 18, 35),
    button_hovered = Color(97, 50, 50),

    category = Color(62, 34, 34),
    category_opened = Color(62, 34, 34, 0),

    theme = Color(180, 80, 80),

    panel = {
        Color(62, 34, 34),
        Color(66, 38, 38),
        Color(140, 70, 70)
    },

    toggle = Color(60, 34, 34),

    focus_panel = Color(72, 48, 48, 200),
    hover = Color(180, 80, 80, 90),

    window_shadow = Color(32, 18, 18, 100),

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
    background_panelpopup = Color(20, 28, 22, 150),

    button = Color(38, 66, 48),
    button_shadow = Color(18, 32, 22, 35),
    button_hovered = Color(48, 88, 62),

    category = Color(34, 62, 44),
    category_opened = Color(34, 62, 44, 0),

    theme = Color(80, 180, 120),

    panel = {
        Color(34, 62, 44),
        Color(38, 66, 48),
        Color(70, 140, 90)
    },

    toggle = Color(34, 60, 44),

    focus_panel = Color(48, 72, 58, 200),
    hover = Color(80, 180, 120, 90),

    window_shadow = Color(18, 32, 22, 100),

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
    header = Color(70, 35, 10),
    header_text = Color(250, 230, 210),
    background = Color(255, 250, 240),
    background_alpha = Color(255, 250, 240, 220),
    background_panelpopup = Color(255, 245, 235, 160),

    button = Color(184, 122, 64),
    button_shadow = Color(20, 10, 0, 30),
    button_hovered = Color(197, 129, 65),

    category = Color(255, 245, 235),
    category_opened = Color(255, 245, 235, 0),

    theme = Color(245, 130, 50),

    panel = {
        Color(255, 250, 240),
        Color(250, 220, 180),
        Color(235, 150, 90)
    },

    toggle = Color(143, 121, 104),

    focus_panel = Color(255, 240, 225, 200),
    hover = Color(255, 165, 80, 90),

    window_shadow = Color(20, 8, 0, 100),
    gray = Color(180, 161, 150, 200),
    text = Color(45, 20, 10)
}

Mantle.color_orange.panel_alpha = {
    ColorAlpha(Mantle.color_orange.panel[1], 120),
    ColorAlpha(Mantle.color_orange.panel[2], 120),
    ColorAlpha(Mantle.color_orange.panel[3], 120)
}

-- Фиолетовая палитра
Mantle.color_purple = {
    header = Color(40, 36, 56),
    header_text = Color(150, 140, 180),
    background = Color(25, 22, 30),
    background_alpha = Color(25, 22, 30, 210),
    background_panelpopup = Color(28, 24, 40, 150),

    button = Color(58, 52, 76),
    button_shadow = Color(8, 6, 20, 30),
    button_hovered = Color(74, 64, 105),

    category = Color(46, 40, 60),
    category_opened = Color(46, 40, 60, 0),

    theme = Color(138, 114, 219),

    panel = {
        Color(56, 48, 76),
        Color(44, 36, 64),
        Color(120, 90, 200)
    },

    toggle = Color(43, 39, 53),

    focus_panel = Color(48, 42, 62, 200),
    hover = Color(138, 114, 219, 90),

    window_shadow = Color(8, 6, 20, 100),

    gray = Color(140, 128, 148, 220),
    text = Color(245, 240, 255)
}
Mantle.color_purple.panel_alpha = {
    ColorAlpha(Mantle.color_purple.panel[1], 150),
    ColorAlpha(Mantle.color_purple.panel[2], 150),
    ColorAlpha(Mantle.color_purple.panel[3], 150)
}

-- Кофейная палитра
Mantle.color_coffee = {
    header = Color(67, 48, 36),
    header_text = Color(210, 190, 170),

    background = Color(45, 32, 25),
    background_alpha = Color(45, 32, 25, 215),
    background_panelpopup = Color(38, 28, 22, 150),

    button = Color(84, 60, 45),
    button_shadow = Color(20, 10, 5, 40),
    button_hovered = Color(100, 75, 55),

    category = Color(72, 54, 42),
    category_opened = Color(72, 54, 42, 0),

    theme = Color(150, 110, 75),

    panel = {
        Color(68, 50, 40),
        Color(90, 65, 50),
        Color(150, 110, 75)
    },

    toggle = Color(53, 40, 31),

    focus_panel = Color(70, 55, 40, 200),
    hover = Color(150, 110, 75, 90),

    window_shadow = Color(15, 10, 5, 100),

    gray = Color(180, 150, 130, 200),
    text = Color(235, 225, 210)
}
Mantle.color_coffee.panel_alpha = {
    ColorAlpha(Mantle.color_coffee.panel[1], 110),
    ColorAlpha(Mantle.color_coffee.panel[2], 110),
    ColorAlpha(Mantle.color_coffee.panel[3], 110)
}

-- Ледяная палитра
Mantle.color_ice = {
    header = Color(190, 225, 250),
    header_text = Color(68, 104, 139),
    background = Color(235, 245, 255),
    background_alpha = Color(235, 245, 255, 200),
    background_panelpopup = Color(220, 235, 245, 150),

    button = Color(145, 185, 225),
    button_shadow = Color(80, 110, 140, 40),
    button_hovered = Color(170, 210, 255),

    category = Color(200, 225, 245),
    category_opened = Color(200, 225, 245, 0),

    theme = Color(100, 170, 230),

    panel = {
        Color(146, 186, 211),
        Color(107, 157, 190),
        Color(74, 132, 184)
    },

    toggle = Color(168, 194, 219),

    focus_panel = Color(205, 230, 245, 200),
    hover = Color(100, 170, 230, 80),

    window_shadow = Color(60, 100, 140, 100),

    gray = Color(92, 112, 133, 200),
    text = Color(20, 35, 50)
}
Mantle.color_ice.panel_alpha = {
    ColorAlpha(Mantle.color_ice.panel[1], 120),
    ColorAlpha(Mantle.color_ice.panel[2], 120),
    ColorAlpha(Mantle.color_ice.panel[3], 120)
}

-- Винная палитра
Mantle.color_wine = {
    header = Color(59, 42, 53),
    header_text = Color(246, 242, 246),
    background = Color(31, 23, 22),
    background_alpha = Color(31, 23, 22, 210),
    background_panelpopup = Color(36, 28, 28, 150),

    button = Color(79, 50, 60),
    button_shadow = Color(10, 6, 18, 30),
    button_hovered = Color(90, 52, 65),

    category = Color(79, 50, 60),
    category_opened = Color(79, 50, 60, 0),

    theme = Color(148, 61, 91),

    panel = {
        Color(79, 50, 60),
        Color(63, 44, 48),
        Color(160, 85, 143)
    },

    toggle = Color(63, 40, 47),

    focus_panel = Color(70, 48, 58, 200),
    hover = Color(192, 122, 217, 90),

    window_shadow = Color(10, 6, 20, 100),

    gray = Color(170, 150, 160, 200),
    text = Color(246, 242, 246)
}
Mantle.color_wine.panel_alpha = {
    ColorAlpha(Mantle.color_wine.panel[1], 150),
    ColorAlpha(Mantle.color_wine.panel[2], 150),
    ColorAlpha(Mantle.color_wine.panel[3], 150)
}

-- Фиалковая палитра
Mantle.color_violet = {
    header = Color(49, 50, 68),
    header_text = Color(238, 244, 255),
    background = Color(22, 24, 35),
    background_alpha = Color(22, 24, 35, 210),
    background_panelpopup = Color(36, 40, 56, 150),

    button = Color(58, 64, 84),
    button_shadow = Color(8, 6, 18, 30),
    button_hovered = Color(64, 74, 104),

    category = Color(58, 64, 84),
    category_opened = Color(58, 64, 84, 0),

    theme = Color(159, 180, 255),

    panel = {
        Color(58, 64, 84),
        Color(48, 52, 72),
        Color(109, 136, 255)
    },

    toggle = Color(46, 51, 66),

    focus_panel = Color(56, 62, 86, 200),
    hover = Color(159, 180, 255, 90),

    window_shadow = Color(8, 6, 20, 100),

    gray = Color(147, 147, 184, 200),
    text = Color(238, 244, 255)
}
Mantle.color_violet.panel_alpha = {
    ColorAlpha(Mantle.color_violet.panel[1], 150),
    ColorAlpha(Mantle.color_violet.panel[2], 150),
    ColorAlpha(Mantle.color_violet.panel[3], 150)
}

-- Моховая палитра
Mantle.color_moss = {
    header = Color(42, 50, 36),
    header_text = Color(232, 244, 235),
    background = Color(14, 16, 12),
    background_alpha = Color(14, 16, 12, 210),
    background_panelpopup = Color(24, 28, 22, 150),

    button = Color(64, 82, 60),
    button_shadow = Color(6, 8, 6, 30),
    button_hovered = Color(74, 99, 68),

    category = Color(46, 64, 44),
    category_opened = Color(46, 64, 44, 0),

    theme = Color(110, 160, 90),

    panel = {
        Color(40, 56, 40),
        Color(66, 86, 66),
        Color(110, 160, 90)
    },

    toggle = Color(35, 44, 34),

    focus_panel = Color(46, 58, 44, 200),
    hover = Color(110, 160, 90, 90),

    window_shadow = Color(0, 0, 0, 100),

    gray = Color(148, 165, 140, 220),
    text = Color(232, 244, 235)
}
Mantle.color_moss.panel_alpha = {
    ColorAlpha(Mantle.color_moss.panel[1], 150),
    ColorAlpha(Mantle.color_moss.panel[2], 150),
    ColorAlpha(Mantle.color_moss.panel[3], 150)
}

-- Коралловая палитра
Mantle.color_coral = {
    header = Color(52, 32, 36),
    header_text = Color(255, 243, 242),
    background = Color(18, 14, 16),
    background_alpha = Color(18, 14, 16, 210),
    background_panelpopup = Color(30, 22, 24, 150),

    button = Color(116, 66, 61),
    button_shadow = Color(8, 4, 6, 30),
    button_hovered = Color(134, 73, 68),

    category = Color(74, 40, 42),
    category_opened = Color(74, 40, 42, 0),

    theme = Color(255, 120, 90),

    panel = {
        Color(66, 38, 40),
        Color(120, 60, 56),
        Color(240, 120, 90)
    },

    toggle = Color(58, 39, 37),

    focus_panel = Color(72, 42, 44, 200),
    hover = Color(255, 120, 90, 90),

    window_shadow = Color(0, 0, 0, 100),

    gray = Color(167, 136, 136, 220),
    text = Color(255, 243, 242)
}
Mantle.color_coral.panel_alpha = {
    ColorAlpha(Mantle.color_coral.panel[1], 150),
    ColorAlpha(Mantle.color_coral.panel[2], 150),
    ColorAlpha(Mantle.color_coral.panel[3], 150)
}
