import {themes as prismThemes} from 'prism-react-renderer';
import type {Config} from '@docusaurus/types';
import type * as Preset from '@docusaurus/preset-classic';

const config: Config = {
  title: 'Decidim Extra Blocks',
  tagline: 'Layout-based content blocks for Decidim landing pages',
  favicon: 'img/logo.svg',

  url: 'https://octree.ch',
  baseUrl: '/',
  trailingSlash: false,

  organizationName: 'octree-gva',
  projectName: 'decidim-extra-blocks',

  onBrokenLinks: 'throw',
  onBrokenMarkdownLinks: 'warn',

  i18n: {
    defaultLocale: 'en',
    locales: ['en'],
  },

  presets: [
    [
      'classic',
      {
        docs: {
          sidebarPath: './sidebars.ts',
          routeBasePath: '/',
        },
        theme: {
          customCss: './src/css/custom.css',
        },
      } satisfies Preset.Options,
    ],
  ],

  themeConfig: {
    navbar: {
      title: 'Decidim Extra Blocks',
      items: [
        {
          type: 'docSidebar',
          sidebarId: 'tutorialSidebar',
          position: 'left',
          label: 'Documentation',
        },
        {
          href: 'https://git.octree.ch/decidim/decidim-modules/decidim-extra-blocks',
          label: 'GitLab',
          position: 'right',
        },
      ],
    },
    footer: {
      style: 'dark',
      links: [
        {
          title: 'Docs',
          items: [
            { label: 'Overview', to: '/' },
            { label: 'Integrate', to: '/integrate' },
            { label: 'Add a layout', to: '/contribute/add-a-layout' },
          ],
        },
      ],
      copyright: `Copyright © ${new Date().getFullYear()} Octree.`,
    },
    prism: {
      theme: prismThemes.github,
      darkTheme: prismThemes.dracula,
      additionalLanguages: ['ruby', 'bash'],
    },
  } satisfies Preset.ThemeConfig,
};

export default config;
