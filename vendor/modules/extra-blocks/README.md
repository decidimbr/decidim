# Decidim Extra Blocks

Layout-based content blocks for Decidim organization, participatory process, process group, and assembly homepages.

Pick a layout from a gallery (CTA, Hero, Fast Proposal, …), freeze it on the block, then edit layout-specific settings. Participants see a cached, mobile-first section.

## Gallery

Desktop and mobile captures of each layout on the organization homepage.

### CTA

_verbose cta_

| desktop | mobile |
| --- | --- |
| ![Verbose CTA desktop](docs/gallery/verbose_cta-desktop.png) | ![Verbose CTA mobile](docs/gallery/verbose_cta-mobile.png) |

_dual path cta_

| desktop | mobile |
| --- | --- |
| ![Dual Path CTA desktop](docs/gallery/dual_path_cta-desktop.png) | ![Dual Path CTA mobile](docs/gallery/dual_path_cta-mobile.png) |

_join steps cta_

| desktop | mobile |
| --- | --- |
| ![Join Steps CTA desktop](docs/gallery/join_steps_cta-desktop.png) | ![Join Steps CTA mobile](docs/gallery/join_steps_cta-mobile.png) |

_trust quote cta_

| desktop | mobile |
| --- | --- |
| ![Trust Quote CTA desktop](docs/gallery/trust_quote_cta-desktop.png) | ![Trust Quote CTA mobile](docs/gallery/trust_quote_cta-mobile.png) |

### Hero

_video hero_

| desktop | mobile |
| --- | --- |
| ![Video Hero desktop](docs/gallery/video_hero-desktop.png) | ![Video Hero mobile](docs/gallery/video_hero-mobile.png) |

_photo mission hero_

| desktop | mobile |
| --- | --- |
| ![Photo Mission Hero desktop](docs/gallery/photo_mission_hero-desktop.png) | ![Photo Mission Hero mobile](docs/gallery/photo_mission_hero-mobile.png) |

_split story hero_

| desktop | mobile |
| --- | --- |
| ![Split Story Hero desktop](docs/gallery/split_story_hero-desktop.png) | ![Split Story Hero mobile](docs/gallery/split_story_hero-mobile.png) |

_outcome stats hero_

| desktop | mobile |
| --- | --- |
| ![Outcome Stats Hero desktop](docs/gallery/outcome_stats_hero-desktop.png) | ![Outcome Stats Hero mobile](docs/gallery/outcome_stats_hero-mobile.png) |

### Fast proposal

_focused quick proposal_

| desktop | mobile |
| --- | --- |
| ![Focused Quick Proposal desktop](docs/gallery/focused_quick_proposal-desktop.png) | ![Focused Quick Proposal mobile](docs/gallery/focused_quick_proposal-mobile.png) |

_split fast proposal_

| desktop | mobile |
| --- | --- |
| ![Split Fast Proposal desktop](docs/gallery/split_fast_proposal-desktop.png) | ![Split Fast Proposal mobile](docs/gallery/split_fast_proposal-mobile.png) |

_video fast proposal_

| desktop | mobile |
| --- | --- |
| ![Video Fast Proposal desktop](docs/gallery/video_fast_proposal-desktop.png) | ![Video Fast Proposal mobile](docs/gallery/video_fast_proposal-mobile.png) |

_proposals aside fast proposal_

| desktop | mobile |
| --- | --- |
| ![Proposals Aside Fast Proposal desktop](docs/gallery/proposals_aside_fast_proposal-desktop.png) | ![Proposals Aside Fast Proposal mobile](docs/gallery/proposals_aside_fast_proposal-mobile.png) |

### Text

_editorial prose_

| desktop | mobile |
| --- | --- |
| ![Editorial Prose desktop](docs/gallery/editorial_prose-desktop.png) | ![Editorial Prose mobile](docs/gallery/editorial_prose-mobile.png) |

_media aside_

| desktop | mobile |
| --- | --- |
| ![Media Aside desktop](docs/gallery/media_aside-desktop.png) | ![Media Aside mobile](docs/gallery/media_aside-mobile.png) |

_topic trio_

| desktop | mobile |
| --- | --- |
| ![Topic Trio desktop](docs/gallery/topic_trio-desktop.png) | ![Topic Trio mobile](docs/gallery/topic_trio-mobile.png) |

### Misc

_spacer_

| desktop | mobile |
| --- | --- |
| ![Spacer desktop](docs/gallery/spacer-desktop.png) | ![Spacer mobile](docs/gallery/spacer-mobile.png) |

_image_

| desktop | mobile |
| --- | --- |
| ![Image desktop](docs/gallery/image-desktop.png) | ![Image mobile](docs/gallery/image-mobile.png) |

_video_

| desktop | mobile |
| --- | --- |
| ![Video desktop](docs/gallery/video-desktop.png) | ![Video mobile](docs/gallery/video-mobile.png) |

_logo showcase_

| desktop | mobile |
| --- | --- |
| ![Logo showcase desktop](docs/gallery/logo_showcase-desktop.png) | ![Logo showcase mobile](docs/gallery/logo_showcase-mobile.png) |

### Timelines

_brand story_

| desktop | mobile |
| --- | --- |
| ![Brand Story desktop](docs/gallery/brand_story-desktop.png) | ![Brand Story mobile](docs/gallery/brand_story-mobile.png) |

_roadmap_

| desktop | mobile |
| --- | --- |
| ![Roadmap desktop](docs/gallery/roadmap-desktop.png) | ![Roadmap mobile](docs/gallery/roadmap-mobile.png) |

_impact milestones_

| desktop | mobile |
| --- | --- |
| ![Impact Milestones desktop](docs/gallery/impact_milestones-desktop.png) | ![Impact Milestones mobile](docs/gallery/impact_milestones-mobile.png) |

## Documentation

Integrator and contributor guides live in the Docusaurus site under [`website/`](website/):

```bash
cd website && yarn && yarn start
```

Start with [Integrate](website/docs/integrate/index.md).

## Quick install

```ruby
gem "decidim-extra_blocks", git: "https://git.octree.ch/decidim/decidim-modules/decidim-extra-blocks.git"
gem "decidim-toggle", git: "https://git.octree.ch/decidim/vocacity/decidim-modules/decidim-toggle.git", branch: "main"
```

Bundle, install Toggle migrations, restart the app, then add **Extra Block** from the homepage / process / process group / assembly landing page content blocks UI.

```bash
bundle install
bin/rails decidim_toggle:install:migrations
bin/rails db:migrate
```

Enable or disable Extra Blocks (and layout categories) under **System → Organizations → Extra Blocks**.

## Development

**Default target is Decidim 0.29** (`octree/decidim-dev:0.29`).

```bash
docker compose up -d
docker compose exec extra-blocks bash
bundle install
bundle exec rake test_app
```

Run the dummy app **and** the webpack dev server (two shells inside the container):

```bash
cd /home/module/spec/decidim_dummy_app
bin/rails s -b 0.0.0.0 -p 3000
```

```bash
cd /home/module/spec/decidim_dummy_app
bin/shakapacker-dev-server
```

Open **http://localhost:3004** (Rails) — packs are on **http://localhost:3035** (published from the container). Restart `shakapacker-dev-server` after changing `config/shakapacker.yml`. If `Bind for 0.0.0.0:3035 failed`, comment the `3035:3035` mapping in `docker-compose.yml` and compile once with `bin/shakapacker` in the dummy app instead of `shakapacker-dev-server`.

Specs (must pass on **0.29**):

```bash
cd /home/module
unset DATABASE_URL
bundle exec rspec
```

### Decidim 0.32 (optional)

Separate stack — different ports, volumes, and gemfile. Regenerate the dummy app when switching (migrations differ).

```bash
docker compose -f docker-compose.0.32.yml up -d
docker compose -f docker-compose.0.32.yml exec extra-blocks bash
bundle install
bundle exec rake test_app
# Rails: http://localhost:3014 — packs: http://localhost:3135
```

CI-equivalent (0.29):

```bash
docker compose -f docker-compose.ci.yml run --rm rspec
```

## License

AGPL-3.0. See [LICENSE.md](LICENSE.md).
