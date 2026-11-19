<div align="center">

# 🎈 Mantle

**A UI and renderer library for Garry's Mod**

Ready-made VGUI components, popups, a theme system, fast rendering and much more. Connect it to your project and use its features to the fullest.

[![Workshop](https://img.shields.io/badge/Steam_Workshop-Subscribe-1b2838?style=for-the-badge&logo=steam&logoColor=white)](https://steamcommunity.com/sharedfiles/filedetails/?id=3126986993)
[![Documentation](https://img.shields.io/badge/Documentation-Open-6C5CE7?style=for-the-badge&logo=readthedocs&logoColor=white)](https://darkfated.github.io/mantle/)
[![Releases](https://img.shields.io/badge/Releases-Latest_release-2ea44f?style=for-the-badge&logo=github&logoColor=white)](https://github.com/darkfated/mantle/releases/latest)
[![License](https://img.shields.io/badge/License-MIT-blue?style=for-the-badge&logo=opensourceinitiative&logoColor=white)](LICENSE)

<img width="1018" height="764" alt="Mantle" src="https://github.com/user-attachments/assets/7209d923-ae93-4230-9bb4-ad4b96b7ac05" />

</div>

---

## ✨ About the library

Mantle - a tool for your server. The library provides capabilities from UI components to functions for sending messages to players.

> [!NOTE]
> To view some things in the game, there is a console command `mantle_menu`.

---

## 🧩 Features

| Section | What's inside |
| --- | --- |
| **🎨 UI elements** | `MantleBtn`, `MantleFrame`, `MantlePanel`, `MantleEntry`, `MantleCheckBox`, `MantleComboBox`, `MantleSlideBox`, `MantleTabs`, `MantleTable`, `MantleScrollPanel`, `MantleCategory`, `MantleText` and others |
| **🎉 Popups** | Player and model selector, color picker, context menu, radial menu, text boxes |
| **⚙️ Rendering** | Fast graphical primitives via [modified RNDX](https://github.com/darkfated/mantle/tree/master/rndx) |
| **🌫️ Effects** | Kawase Blur, acrylic material, shadows, blur and glow |
| **🎨 Themes** | 11 built-in color schemes, smooth animations and server settings |
| **🌐 Localization** | Built-in translation system: English, Russian and French |
| **🧱 Architecture** | Modular structure: the core, configs and elements can be changed to suit your needs |

---

## 📚 Documentation

All components and code examples are collected in the [Documentation](https://darkfated.github.io/mantle/). It is recommended to check it out for convenience.

<img width="1592" height="953" alt="Documentation screenshot" src="https://github.com/user-attachments/assets/f4884be6-4505-40dc-8b1f-f60361c0532d" />

---

## 🚀 Quick start

An example of a window with a button:

```lua
local frame = vgui.Create('MantleFrame')
frame:SetSize(520, 320)
frame:Center()
frame:MakePopup()

local btn = vgui.Create('MantleBtn', frame)
btn:Dock(BOTTOM)
btn:DockMargin(16, 0, 16, 16)
btn:SetTall(44)
btn:SetTxt('Hello, Mantle!')

btn.DoClick = function()
    chat.AddText('Hello World')
end
```

More examples: [Button](https://darkfated.github.io/mantle/docs/ui/button), [Frame](https://darkfated.github.io/mantle/docs/ui/frame), [Tabs](https://darkfated.github.io/mantle/docs/ui/tabs).

---

## 🌫️ Modified RNDX

RNDX draws primitives faster than the standard `draw`. It supports rounded corners, outlines, shadows, blur and materials. This is a fork of the original library with optimizations and additional effects.

```lua
hook.Add('HUDPaint', 'OutlineTest', function()
    local w, h = 320, 140
    local x, y = (ScrW() - w) / 2, (ScrH() - h) / 2

    RNDX.Rect(x, y, w, h)
        :Rad(20)
        :Color(Mantle.color.background_alpha)
        :Outline(1)
    :Draw()
end)
```

### Acrylic material

This is a ready-made frosted glass effect in the spirit of **Windows 11**. Instead of a flat translucent rectangle, the library combines five layers at once:

| Layer | What it does |
| --- | --- |
| **blur** | background blur |
| **burn** | dimming of bright areas |
| **tint** | color tint |
| **noise** | light grain |
| **fresnel** | soft glow at the edges |

<div align="center">
<img width="528" height="355" alt="Acrylic" src="https://github.com/user-attachments/assets/495981db-b115-4607-8f05-14650fb26e75" />
</div>

<details>
<summary><b>Code</b></summary>

```lua
local acrylic = {
    blur = { enabled = true, iterations = 4, radius = 4 },
    burn = { enabled = true, color = Color(120, 120, 120), amount = 0.4 },
    tint = { enabled = true, color = Color(25, 25, 25), amount = 0.4 },
    noise = { enabled = true, intensity = 0.02, scale = 8 },
    fresnel = { enabled = true, color = Color(70, 140, 230), amount = 0.3, width = 1.4 }
}

hook.Add('HUDPaint', 'MantleAcrylic', function()
    RNDX.Rect(100, 100, 400, 200)
        :Rad(16)
        :Acrylic(acrylic)
    :Draw()
end)
```

</details>

Learn more: [modified RNDX](https://darkfated.github.io/mantle/docs/rndx).

---

## 🎨 Themes

The library comes with ready-made themes: `dark`, `dark_mono`, `blue`, `red`, `green`, `purple`, `coffee`, `wine`, `violet`, `moss`, `coral`.

The player selects a theme in the settings. The server can limit the list or set a forced theme via `lua/mantle/config/theme.lua`.

```lua
-- Theme selected by the player
local preferred = Mantle.ui.convar.theme

-- Active server theme (if forcing is enabled)
local active = Mantle.ui.activeTheme

-- List of available themes: { {id, title, colors}, ... }
for _, theme in ipairs(Mantle.ui.getAvailableThemes()) do
    print(theme.id, theme.title)
end
```

Custom themes are created via `Mantle.ui.registerTheme(id, title, colors)` in `config/colors.lua`.

Learn more: [Themes](https://darkfated.github.io/mantle/docs/functions/themes), [Settings](https://darkfated.github.io/mantle/docs/settings).

---

## 🌐 Localization

Mantle contains its own translation layer. Strings are stored in `lang.lua` next to the addon and read via `Mantle.lang.get`.

```lua
local text = Mantle.lang.get('mantle', 'theme_dark')
```

---

## 📩 Installation

### 🟦 Steam Workshop

Recommended way: subscribe to the [Workshop](https://steamcommunity.com/sharedfiles/filedetails/?id=3126986993) and add the addon to the server collection. This way the library updates automatically, without manual downloading.

### 📦 Manual

Download the latest release from the [Releases](https://github.com/darkfated/mantle/releases/latest) page and extract it into the `garrysmod/addons/` folder.

### 🔤 Font

The [Montserrat](https://steamcommunity.com/sharedfiles/filedetails/?id=2924839375) font is used for correct text display. It is connected automatically via `resource.AddWorkshop`, but it is better to add it to the server collection as well, in case the addon has not loaded yet.

---

## 🧬 Project structure

```
lua/
├── mantle/
│   ├── core/ # core: VGUI, rendering, utilities
│   │   ├── functions/ # drawing, fonts, animations
│   │   └── vgui_elements/ # ready-made UI components
│   ├── config/ # themes, colors, settings
│   └── ...
└── mantle_addons/ # addons built on Mantle
```

---

## 🤝 Contributing

Found a bug or want to suggest an improvement? Create an [Issue](https://github.com/darkfated/mantle/issues) or send a Pull Request.

The experimental macOS-style interface is located in the [`new-design`](https://github.com/darkfated/mantle/tree/new-design) branch - for anyone interested.

---

## 🔐 License

The project is distributed under the [**MIT Terms**](LICENSE).

---

<div align="center">

### ⭐ Like Mantle?

Star the repository. This helps the project grow.

[![Star Mantle](https://img.shields.io/github/stars/darkfated/mantle?style=for-the-badge&logo=github&label=Star%20Mantle)](https://github.com/darkfated/mantle)

</div>
