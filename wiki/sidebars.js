const sidebars = {
  docs: [
    "intro",
    "getting-started",
    {
      type: "category",
      label: "UI Элементы",
      items: [
        "ui/button",
        "ui/checkbox",
        "ui/entry",
        "ui/frame",
        "ui/scroll-panel",
        "ui/tabs",
        "ui/hscroll",
        "ui/combobox",
        "ui/table",
        "ui/category",
        "ui/slidebox",
        "ui/text",
      ],
    },
    {
      type: "category",
      label: "Всплывающие элементы",
      link: { type: "doc", id: "popups/overview" },
      items: [
        "popups/color-picker",
        "popups/derma-menu",
        "popups/player-selector",
        "popups/radial-menu",
        "popups/text-box",
      ],
    },
    {
      type: "category",
      label: "Функции",
      items: [
        "functions/drawing",
        "functions/sound",
        "functions/layout",
        "functions/3d",
        "functions/materials",
        "functions/notify",
        "functions/text",
        "functions/fonts",
        "functions/themes",
        "functions/shadows",
      ],
    },
    "rndx",
    "legacy-ui",
    "settings",
  ],
};

export default sidebars;
