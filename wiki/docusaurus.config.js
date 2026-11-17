import { themes as prismThemes } from "prism-react-renderer";

const config = {
  title: "Mantle Wiki",
  tagline: "Documentation for the Mantle library for Garry's Mod",

  future: {
    v4: true,
  },

  url: "https://darkfated.github.io",
  baseUrl: "/mantle/",

  organizationName: "darkfated",
  projectName: "mantle",
  deploymentBranch: "gh-pages",

  onBrokenLinks: "throw",

  i18n: {
    defaultLocale: "en",
    locales: ["en", "ru"],
    localeConfigs: {
      en: {
        label: "English",
        direction: "ltr",
        htmlLang: "en-US",
      },
      ru: {
        label: "Русский",
        direction: "ltr",
        htmlLang: "ru-RU",
      },
    },
  },

  trailingSlash: false,

  presets: [
    [
      "classic",
      {
        docs: {
          sidebarPath: "./sidebars.js",
          editUrl: "https://github.com/darkfated/mantle/edit/master/wiki/docs/",
        },
        blog: false,
        theme: {
          customCss: "./src/css/custom.css",
        },
      },
    ],
  ],

  themeConfig: {
    colorMode: {
      respectPrefersColorScheme: true,
    },
    navbar: {
      title: "Mantle Wiki",
      items: [
        {
          type: "docSidebar",
          sidebarId: "docs",
          position: "left",
          label: "Documentation",
        },
        {
          href: "https://github.com/darkfated/mantle",
          label: "GitHub",
          position: "right",
        },
        {
          type: "localeDropdown",
          position: "right",
        },
      ],
    },
    footer: {
      style: "dark",
      links: [
        {
          title: "Project",
          items: [
            {
              label: "GitHub",
              href: "https://github.com/darkfated/mantle",
            },
            {
              label: "Workshop",
              href: "https://steamcommunity.com/sharedfiles/filedetails/?id=3126986993",
            },
          ],
        },
      ],
    },
    prism: {
      theme: prismThemes.github,
      darkTheme: prismThemes.dracula,
    },
  },
};

export default config;
