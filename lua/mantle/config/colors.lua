--[[
    Основная тема
]]
Mantle.color_dark = {
    header = Color(34, 35, 39), -- верхняя панель
    header_text = Color(165, 170, 180), -- цвет элементов в заголовке
    background = Color(18, 19, 22), -- фон
    background_alpha = Color(18, 19, 22, 245), -- фон с прозрачностью
    background_panelpopup = Color(23, 24, 28, 170), -- фон для DermaMenu

    button = Color(44, 46, 52), -- кнопка
    button_shadow = Color(0, 0, 0, 30), -- тень кнопки для градиента
    button_hovered = Color(60, 63, 72), -- кнопка при наведении

    category = Color(37, 39, 44), -- категория
    category_opened = Color(37, 39, 44, 0), -- категория открыта

    theme = Color(86, 132, 235), -- тема интерфейса

    panel = { -- варианты цветов для панели
        Color(46, 48, 54),
        Color(38, 40, 46),
        Color(72, 76, 86)
    },

    toggle = Color(44, 46, 52), -- тумблер

    focus_panel = Color(42, 44, 50, 200), -- универсальный цвет для элементов
    hover = Color(67, 76, 102), -- универсальное выделение

    window_shadow = Color(0, 0, 0, 60), -- тень окна

    hover_overlay = Color(255, 255, 255, 28), -- лёгкое выделение
    hover_overlay_strong = Color(255, 255, 255, 42), -- сильное выделение
    notify_outline = Color(255, 255, 255, 45), -- обводка уведомления
    dim_overlay = Color(0, 0, 0, 150), -- затемнение фона
    circle_shadow = Color(0, 0, 0, 20), -- тень кружка
    ripple = Color(255, 255, 255, 40), -- волна кнопки
    tab_shadow = Color(0, 0, 0, 150), -- тень вкладок
    tab_hover = Color(255, 255, 255, 14), -- выделение вкладки
    icon = Color(255, 255, 255), -- иконки
    status_disconnect = Color(230, 90, 90), -- офлайн
    status_bot = Color(90, 160, 230), -- бот
    status_online = Color(110, 200, 120), -- онлайн

    gray = Color(148, 153, 163, 220),
    text_muted = Color(148, 153, 163, 175),
    text = Color(236, 238, 244)
}
Mantle.color_dark.panel_alpha = { -- прозрачные панели
    ColorAlpha(Mantle.color_dark.panel[1], 160),
    ColorAlpha(Mantle.color_dark.panel[2], 160),
    ColorAlpha(Mantle.color_dark.panel[3], 160)
}

--[[
    Монохромная тема
]]
Mantle.color_dark_mono = table.Copy(Mantle.color_dark)
Mantle.color_dark_mono.theme = Color(148, 150, 156)
Mantle.color_dark_mono.text_muted = Color(150, 150, 150, 180)

--[[
    Светлая тема
]]
Mantle.color_light = {
    header = Color(234, 236, 244),
    header_text = Color(108, 114, 130),
    background = Color(252, 252, 255),
    background_alpha = Color(252, 252, 255, 245),
    background_panelpopup = Color(255, 255, 255, 190),

    button = Color(231, 233, 241),
    button_shadow = Color(95, 100, 115, 22),
    button_hovered = Color(205, 209, 224),

    category = Color(239, 241, 248),
    category_opened = Color(239, 241, 248, 0),

    theme = Color(88, 102, 192),

    panel = {
        Color(255, 255, 255),
        Color(245, 246, 252),
        Color(222, 225, 236)
    },

    toggle = Color(216, 218, 229),

    focus_panel = Color(241, 243, 249, 210),
    hover = Color(203, 208, 236),

    window_shadow = Color(105, 112, 128, 40),

    hover_overlay = Color(0, 0, 0, 28),
    hover_overlay_strong = Color(0, 0, 0, 42),
    notify_outline = Color(0, 0, 0, 45),
    dim_overlay = Color(0, 0, 0, 140),
    circle_shadow = Color(0, 0, 0, 20),
    ripple = Color(0, 0, 0, 40),
    tab_shadow = Color(105, 112, 128, 150),
    tab_hover = Color(0, 0, 0, 14),
    icon = Color(255, 255, 255),
    status_disconnect = Color(210, 65, 65),
    status_bot = Color(70, 150, 220),
    status_online = Color(120, 180, 70),

    gray = Color(120, 124, 136, 220),
    text_muted = Color(120, 124, 136, 180),
    text = Color(26, 28, 34)
}
Mantle.color_light.panel_alpha = {
    ColorAlpha(Mantle.color_light.panel[1], 120),
    ColorAlpha(Mantle.color_light.panel[2], 120),
    ColorAlpha(Mantle.color_light.panel[3], 120)
}

--[[
    Синяя тема
]]
Mantle.color_blue = {
    header = Color(30, 40, 54),
    header_text = Color(150, 170, 196),
    background = Color(14, 18, 26),
    background_alpha = Color(14, 18, 26, 245),
    background_panelpopup = Color(20, 26, 38, 170),

    button = Color(34, 44, 64),
    button_shadow = Color(0, 0, 0, 30),
    button_hovered = Color(46, 60, 88),

    category = Color(28, 36, 52),
    category_opened = Color(28, 36, 52, 0),

    theme = Color(84, 168, 236),

    panel = {
        Color(34, 44, 64),
        Color(26, 34, 50),
        Color(56, 104, 168)
    },

    toggle = Color(32, 42, 60),

    focus_panel = Color(36, 48, 70, 200),
    hover = Color(84, 168, 236),

    window_shadow = Color(0, 0, 0, 60),

    hover_overlay = Color(255, 255, 255, 28),
    hover_overlay_strong = Color(255, 255, 255, 42),
    notify_outline = Color(255, 255, 255, 45),
    dim_overlay = Color(0, 0, 0, 150),
    circle_shadow = Color(0, 0, 0, 20),
    ripple = Color(255, 255, 255, 40),
    tab_shadow = Color(0, 0, 0, 150),
    tab_hover = Color(255, 255, 255, 14),
    icon = Color(255, 255, 255),
    status_disconnect = Color(230, 90, 90),
    status_bot = Color(90, 160, 230),
    status_online = Color(110, 200, 120),

    gray = Color(140, 160, 186, 220),
    text_muted = Color(140, 160, 186, 180),
    text = Color(216, 228, 242)
}
Mantle.color_blue.panel_alpha = {
    ColorAlpha(Mantle.color_blue.panel[1], 160),
    ColorAlpha(Mantle.color_blue.panel[2], 160),
    ColorAlpha(Mantle.color_blue.panel[3], 160)
}

--[[
    Красная тема
]]
Mantle.color_red = {
    header = Color(46, 30, 32),
    header_text = Color(196, 168, 172),
    background = Color(20, 14, 16),
    background_alpha = Color(20, 14, 16, 245),
    background_panelpopup = Color(30, 20, 22, 170),

    button = Color(60, 36, 40),
    button_shadow = Color(0, 0, 0, 30),
    button_hovered = Color(82, 48, 54),

    category = Color(48, 30, 34),
    category_opened = Color(48, 30, 34, 0),

    theme = Color(232, 92, 92),

    panel = {
        Color(60, 36, 40),
        Color(48, 28, 32),
        Color(158, 66, 70)
    },

    toggle = Color(52, 32, 36),

    focus_panel = Color(62, 38, 44, 200),
    hover = Color(232, 92, 92),

    window_shadow = Color(0, 0, 0, 60),

    hover_overlay = Color(255, 255, 255, 28),
    hover_overlay_strong = Color(255, 255, 255, 42),
    notify_outline = Color(255, 255, 255, 45),
    dim_overlay = Color(0, 0, 0, 150),
    circle_shadow = Color(0, 0, 0, 20),
    ripple = Color(255, 255, 255, 40),
    tab_shadow = Color(0, 0, 0, 150),
    tab_hover = Color(255, 255, 255, 14),
    icon = Color(255, 255, 255),
    status_disconnect = Color(230, 90, 90),
    status_bot = Color(90, 160, 230),
    status_online = Color(110, 200, 120),

    gray = Color(190, 160, 164, 220),
    text_muted = Color(190, 160, 164, 180),
    text = Color(240, 226, 228)
}
Mantle.color_red.panel_alpha = {
    ColorAlpha(Mantle.color_red.panel[1], 160),
    ColorAlpha(Mantle.color_red.panel[2], 160),
    ColorAlpha(Mantle.color_red.panel[3], 160)
}

--[[
    Зелёная тема
]]
Mantle.color_green = {
    header = Color(28, 44, 34),
    header_text = Color(170, 196, 178),
    background = Color(12, 18, 14),
    background_alpha = Color(12, 18, 14, 245),
    background_panelpopup = Color(18, 28, 22, 170),

    button = Color(34, 58, 42),
    button_shadow = Color(0, 0, 0, 30),
    button_hovered = Color(46, 80, 58),

    category = Color(28, 46, 34),
    category_opened = Color(28, 46, 34, 0),

    theme = Color(96, 196, 136),

    panel = {
        Color(36, 60, 44),
        Color(28, 48, 36),
        Color(70, 150, 100)
    },

    toggle = Color(32, 54, 40),

    focus_panel = Color(38, 62, 48, 200),
    hover = Color(96, 196, 136),

    window_shadow = Color(0, 0, 0, 60),

    hover_overlay = Color(255, 255, 255, 28),
    hover_overlay_strong = Color(255, 255, 255, 42),
    notify_outline = Color(255, 255, 255, 45),
    dim_overlay = Color(0, 0, 0, 150),
    circle_shadow = Color(0, 0, 0, 20),
    ripple = Color(255, 255, 255, 40),
    tab_shadow = Color(0, 0, 0, 150),
    tab_hover = Color(255, 255, 255, 14),
    icon = Color(255, 255, 255),
    status_disconnect = Color(230, 90, 90),
    status_bot = Color(90, 160, 230),
    status_online = Color(110, 200, 120),

    gray = Color(156, 182, 166, 220),
    text_muted = Color(156, 182, 166, 180),
    text = Color(226, 240, 230)
}
Mantle.color_green.panel_alpha = {
    ColorAlpha(Mantle.color_green.panel[1], 160),
    ColorAlpha(Mantle.color_green.panel[2], 160),
    ColorAlpha(Mantle.color_green.panel[3], 160)
}

--[[
    Оранжевая тема
]]
Mantle.color_orange = {
    header = Color(78, 40, 18),
    header_text = Color(250, 236, 222),
    background = Color(250, 244, 235),
    background_alpha = Color(250, 244, 235, 245),
    background_panelpopup = Color(255, 250, 243, 180),

    button = Color(208, 142, 84),
    button_shadow = Color(130, 110, 90, 25),
    button_hovered = Color(218, 158, 102),

    category = Color(248, 238, 224),
    category_opened = Color(248, 238, 224, 0),

    theme = Color(246, 132, 54),

    panel = {
        Color(252, 246, 238),
        Color(244, 230, 208),
        Color(222, 160, 100)
    },

    toggle = Color(186, 150, 118),

    focus_panel = Color(250, 240, 228, 200),
    hover = Color(248, 190, 140),

    window_shadow = Color(130, 116, 102, 45),

    hover_overlay = Color(0, 0, 0, 28),
    hover_overlay_strong = Color(0, 0, 0, 42),
    notify_outline = Color(0, 0, 0, 45),
    dim_overlay = Color(0, 0, 0, 140),
    circle_shadow = Color(0, 0, 0, 20),
    ripple = Color(0, 0, 0, 40),
    tab_shadow = Color(130, 116, 102, 150),
    tab_hover = Color(0, 0, 0, 14),
    icon = Color(255, 255, 255),
    status_disconnect = Color(210, 65, 65),
    status_bot = Color(70, 150, 220),
    status_online = Color(120, 180, 70),

    gray = Color(255, 255, 255),
    text_muted = Color(172, 152, 140, 180),
    text = Color(52, 30, 16)
}
Mantle.color_orange.panel_alpha = {
    ColorAlpha(Mantle.color_orange.panel[1], 120),
    ColorAlpha(Mantle.color_orange.panel[2], 120),
    ColorAlpha(Mantle.color_orange.panel[3], 120)
}

--[[
    Пурпурная тема
]]
Mantle.color_purple = {
    header = Color(34, 28, 50),
    header_text = Color(186, 178, 216),
    background = Color(15, 13, 22),
    background_alpha = Color(15, 13, 22, 245),
    background_panelpopup = Color(24, 20, 36, 170),

    button = Color(48, 42, 68),
    button_shadow = Color(0, 0, 0, 30),
    button_hovered = Color(64, 56, 92),

    category = Color(38, 32, 56),
    category_opened = Color(38, 32, 56, 0),

    theme = Color(164, 128, 238),

    panel = {
        Color(48, 42, 68),
        Color(40, 34, 60),
        Color(118, 86, 210)
    },

    toggle = Color(42, 37, 60),

    focus_panel = Color(50, 44, 72, 200),
    hover = Color(164, 128, 238),

    window_shadow = Color(0, 0, 0, 60),

    hover_overlay = Color(255, 255, 255, 28),
    hover_overlay_strong = Color(255, 255, 255, 42),
    notify_outline = Color(255, 255, 255, 45),
    dim_overlay = Color(0, 0, 0, 150),
    circle_shadow = Color(0, 0, 0, 20),
    ripple = Color(255, 255, 255, 40),
    tab_shadow = Color(0, 0, 0, 150),
    tab_hover = Color(255, 255, 255, 14),
    icon = Color(255, 255, 255),
    status_disconnect = Color(230, 90, 90),
    status_bot = Color(90, 160, 230),
    status_online = Color(110, 200, 120),

    gray = Color(158, 148, 186, 220),
    text_muted = Color(158, 148, 186, 180),
    text = Color(238, 234, 252)
}
Mantle.color_purple.panel_alpha = {
    ColorAlpha(Mantle.color_purple.panel[1], 160),
    ColorAlpha(Mantle.color_purple.panel[2], 160),
    ColorAlpha(Mantle.color_purple.panel[3], 160)
}

--[[
    Кофейная тема
]]
Mantle.color_coffee = {
    header = Color(52, 36, 26),
    header_text = Color(200, 182, 164),
    background = Color(24, 16, 12),
    background_alpha = Color(24, 16, 12, 245),
    background_panelpopup = Color(34, 24, 18, 170),

    button = Color(60, 44, 32),
    button_shadow = Color(0, 0, 0, 30),
    button_hovered = Color(78, 58, 44),

    category = Color(50, 36, 26),
    category_opened = Color(50, 36, 26, 0),

    theme = Color(206, 146, 98),

    panel = {
        Color(62, 46, 34),
        Color(52, 38, 28),
        Color(130, 96, 66)
    },

    toggle = Color(52, 38, 28),

    focus_panel = Color(62, 48, 36, 200),
    hover = Color(206, 146, 98),

    window_shadow = Color(0, 0, 0, 60),

    hover_overlay = Color(255, 255, 255, 28),
    hover_overlay_strong = Color(255, 255, 255, 42),
    notify_outline = Color(255, 255, 255, 45),
    dim_overlay = Color(0, 0, 0, 150),
    circle_shadow = Color(0, 0, 0, 20),
    ripple = Color(255, 255, 255, 40),
    tab_shadow = Color(0, 0, 0, 150),
    tab_hover = Color(255, 255, 255, 14),
    icon = Color(255, 255, 255),
    status_disconnect = Color(230, 90, 90),
    status_bot = Color(90, 160, 230),
    status_online = Color(110, 200, 120),

    gray = Color(178, 156, 140, 220),
    text_muted = Color(178, 156, 140, 180),
    text = Color(240, 232, 222)
}
Mantle.color_coffee.panel_alpha = {
    ColorAlpha(Mantle.color_coffee.panel[1], 160),
    ColorAlpha(Mantle.color_coffee.panel[2], 160),
    ColorAlpha(Mantle.color_coffee.panel[3], 160)
}

--[[
    Ледяная тема
]]
Mantle.color_ice = {
    header = Color(218, 232, 246),
    header_text = Color(92, 120, 148),
    background = Color(240, 247, 254),
    background_alpha = Color(240, 247, 254, 245),
    background_panelpopup = Color(250, 253, 255, 180),

    button = Color(186, 210, 232),
    button_shadow = Color(100, 120, 140, 30),
    button_hovered = Color(158, 194, 228),

    category = Color(232, 240, 250),
    category_opened = Color(232, 240, 250, 0),

    theme = Color(74, 156, 224),

    panel = {
        Color(244, 249, 254),
        Color(236, 244, 252),
        Color(200, 222, 244)
    },

    toggle = Color(168, 196, 222),

    focus_panel = Color(232, 241, 250, 200),
    hover = Color(180, 214, 240),

    window_shadow = Color(105, 125, 145, 40),

    hover_overlay = Color(0, 0, 0, 28),
    hover_overlay_strong = Color(0, 0, 0, 42),
    notify_outline = Color(0, 0, 0, 45),
    dim_overlay = Color(0, 0, 0, 140),
    circle_shadow = Color(0, 0, 0, 20),
    ripple = Color(0, 0, 0, 40),
    tab_shadow = Color(105, 125, 145, 150),
    tab_hover = Color(0, 0, 0, 14),
    icon = Color(255, 255, 255),
    status_disconnect = Color(210, 65, 65),
    status_bot = Color(70, 150, 220),
    status_online = Color(120, 180, 70),

    gray = Color(255, 255, 255),
    text_muted = Color(110, 128, 148, 180),
    text = Color(22, 34, 48)
}
Mantle.color_ice.panel_alpha = {
    ColorAlpha(Mantle.color_ice.panel[1], 120),
    ColorAlpha(Mantle.color_ice.panel[2], 120),
    ColorAlpha(Mantle.color_ice.panel[3], 120)
}

--[[
    Винная тема
]]
Mantle.color_wine = {
    header = Color(44, 30, 40),
    header_text = Color(226, 210, 220),
    background = Color(18, 13, 16),
    background_alpha = Color(18, 13, 16, 245),
    background_panelpopup = Color(30, 22, 26, 170),

    button = Color(60, 40, 50),
    button_shadow = Color(0, 0, 0, 30),
    button_hovered = Color(78, 52, 66),

    category = Color(52, 36, 46),
    category_opened = Color(52, 36, 46, 0),

    theme = Color(214, 92, 134),

    panel = {
        Color(60, 40, 50),
        Color(50, 34, 44),
        Color(148, 78, 110)
    },

    toggle = Color(52, 36, 44),

    focus_panel = Color(62, 44, 54, 200),
    hover = Color(214, 92, 134),

    window_shadow = Color(0, 0, 0, 60),

    hover_overlay = Color(255, 255, 255, 28),
    hover_overlay_strong = Color(255, 255, 255, 42),
    notify_outline = Color(255, 255, 255, 45),
    dim_overlay = Color(0, 0, 0, 150),
    circle_shadow = Color(0, 0, 0, 20),
    ripple = Color(255, 255, 255, 40),
    tab_shadow = Color(0, 0, 0, 150),
    tab_hover = Color(255, 255, 255, 14),
    icon = Color(255, 255, 255),
    status_disconnect = Color(230, 90, 90),
    status_bot = Color(90, 160, 230),
    status_online = Color(110, 200, 120),

    gray = Color(186, 164, 176, 220),
    text_muted = Color(186, 164, 176, 180),
    text = Color(242, 232, 238)
}
Mantle.color_wine.panel_alpha = {
    ColorAlpha(Mantle.color_wine.panel[1], 160),
    ColorAlpha(Mantle.color_wine.panel[2], 160),
    ColorAlpha(Mantle.color_wine.panel[3], 160)
}

--[[
    Фиолетовая тема
]]
Mantle.color_violet = {
    header = Color(36, 38, 54),
    header_text = Color(208, 214, 240),
    background = Color(16, 18, 28),
    background_alpha = Color(16, 18, 28, 245),
    background_panelpopup = Color(28, 30, 44, 170),

    button = Color(50, 56, 78),
    button_shadow = Color(0, 0, 0, 30),
    button_hovered = Color(66, 74, 104),

    category = Color(44, 48, 68),
    category_opened = Color(44, 48, 68, 0),

    theme = Color(168, 186, 255),

    panel = {
        Color(50, 56, 78),
        Color(42, 46, 64),
        Color(120, 140, 240)
    },

    toggle = Color(46, 50, 68),

    focus_panel = Color(52, 58, 82, 200),
    hover = Color(168, 186, 255),

    window_shadow = Color(0, 0, 0, 60),

    hover_overlay = Color(255, 255, 255, 28),
    hover_overlay_strong = Color(255, 255, 255, 42),
    notify_outline = Color(255, 255, 255, 45),
    dim_overlay = Color(0, 0, 0, 150),
    circle_shadow = Color(0, 0, 0, 20),
    ripple = Color(255, 255, 255, 40),
    tab_shadow = Color(0, 0, 0, 150),
    tab_hover = Color(255, 255, 255, 14),
    icon = Color(255, 255, 255),
    status_disconnect = Color(230, 90, 90),
    status_bot = Color(90, 160, 230),
    status_online = Color(110, 200, 120),

    gray = Color(158, 162, 196, 220),
    text_muted = Color(158, 162, 196, 180),
    text = Color(236, 240, 252)
}
Mantle.color_violet.panel_alpha = {
    ColorAlpha(Mantle.color_violet.panel[1], 160),
    ColorAlpha(Mantle.color_violet.panel[2], 160),
    ColorAlpha(Mantle.color_violet.panel[3], 160)
}

--[[
    Моховая тема
]]
Mantle.color_moss = {
    header = Color(36, 44, 30),
    header_text = Color(196, 208, 190),
    background = Color(15, 18, 12),
    background_alpha = Color(15, 18, 12, 245),
    background_panelpopup = Color(24, 30, 20, 170),

    button = Color(50, 62, 46),
    button_shadow = Color(0, 0, 0, 30),
    button_hovered = Color(66, 84, 60),

    category = Color(40, 50, 34),
    category_opened = Color(40, 50, 34, 0),

    theme = Color(146, 196, 110),

    panel = {
        Color(48, 60, 44),
        Color(40, 50, 36),
        Color(112, 156, 88)
    },

    toggle = Color(44, 54, 38),

    focus_panel = Color(52, 64, 48, 200),
    hover = Color(146, 196, 110),

    window_shadow = Color(0, 0, 0, 60),

    hover_overlay = Color(255, 255, 255, 28),
    hover_overlay_strong = Color(255, 255, 255, 42),
    notify_outline = Color(255, 255, 255, 45),
    dim_overlay = Color(0, 0, 0, 150),
    circle_shadow = Color(0, 0, 0, 20),
    ripple = Color(255, 255, 255, 40),
    tab_shadow = Color(0, 0, 0, 150),
    tab_hover = Color(255, 255, 255, 14),
    icon = Color(255, 255, 255),
    status_disconnect = Color(230, 90, 90),
    status_bot = Color(90, 160, 230),
    status_online = Color(110, 200, 120),

    gray = Color(170, 184, 160, 220),
    text_muted = Color(170, 184, 160, 180),
    text = Color(234, 244, 230)
}
Mantle.color_moss.panel_alpha = {
    ColorAlpha(Mantle.color_moss.panel[1], 160),
    ColorAlpha(Mantle.color_moss.panel[2], 160),
    ColorAlpha(Mantle.color_moss.panel[3], 160)
}

--[[
    Коралловая тема
]]
Mantle.color_coral = {
    header = Color(44, 26, 30),
    header_text = Color(236, 212, 212),
    background = Color(17, 12, 14),
    background_alpha = Color(17, 12, 14, 245),
    background_panelpopup = Color(28, 20, 22, 170),

    button = Color(66, 38, 38),
    button_shadow = Color(0, 0, 0, 30),
    button_hovered = Color(88, 50, 50),

    category = Color(52, 30, 32),
    category_opened = Color(52, 30, 32, 0),

    theme = Color(255, 116, 88),

    panel = {
        Color(66, 38, 38),
        Color(54, 30, 32),
        Color(214, 100, 82)
    },

    toggle = Color(56, 34, 34),

    focus_panel = Color(68, 40, 42, 200),
    hover = Color(255, 116, 88),

    window_shadow = Color(0, 0, 0, 60),

    hover_overlay = Color(255, 255, 255, 28),
    hover_overlay_strong = Color(255, 255, 255, 42),
    notify_outline = Color(255, 255, 255, 45),
    dim_overlay = Color(0, 0, 0, 150),
    circle_shadow = Color(0, 0, 0, 20),
    ripple = Color(255, 255, 255, 40),
    tab_shadow = Color(0, 0, 0, 150),
    tab_hover = Color(255, 255, 255, 14),
    icon = Color(255, 255, 255),
    status_disconnect = Color(230, 90, 90),
    status_bot = Color(90, 160, 230),
    status_online = Color(110, 200, 120),

    gray = Color(190, 160, 160, 220),
    text_muted = Color(190, 160, 160, 180),
    text = Color(250, 238, 238)
}
Mantle.color_coral.panel_alpha = {
    ColorAlpha(Mantle.color_coral.panel[1], 160),
    ColorAlpha(Mantle.color_coral.panel[2], 160),
    ColorAlpha(Mantle.color_coral.panel[3], 160)
}
