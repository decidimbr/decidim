---
sidebar_position: 1
title: Integrate
description: Install Extra Blocks and enable layouts on Decidim landing pages
---

# Integrate Extra Blocks

Who reads this: host-app **implementors** who install the gem and configure landing pages. Contributors adding layouts: see [Contribute](../contribute/add-a-layout.md).

Three steps to ship Extra Blocks on your Decidim instance.

## 1. Install the gem

**Default target: Decidim `0.29.x`.** Decidim `0.32` is optional (separate compose/appraisal in the gem repo — not required for host install).

Add to your host `Gemfile`:

```ruby
gem "decidim-extra_blocks", git: "https://git.octree.ch/decidim/decidim-modules/decidim-extra-blocks.git"
gem "decidim-toggle", git: "https://git.octree.ch/decidim/vocacity/decidim-modules/decidim-toggle.git", branch: "main"
```

Then:

```bash
bundle install
bin/rails decidim_toggle:install:migrations
bin/rails db:migrate
bin/rails decidim:webpacker:install
```

Restart the application. Configure Extra Blocks under **System → Organizations → Extra Blocks** (module + CTA / Hero / Fast Proposal / Text / Misc / Timelines categories).

WebP sources and pngquant PNG compression are optional. With basic libvips (resize only, no WebP) or without `pngquant` on `PATH`, Extra Blocks still serves PNG/JPEG resize variants and skips those enhancements. The Voca production image installs `libwebp-dev` and `pngquant` so both are available there. After installing those packages on a running host, restart the app process so memoized capability checks refresh.

Image slots also accept SVG. SVG skips picture/WebP/pngquant and renders as `<img>`. Upload already works. Display does not until the host opts ActiveStorage in to serve `image/svg+xml` inline.

### SVG display

Rails ActiveStorage otherwise serves SVG as `application/octet-stream` with `Content-Disposition: attachment`. Browsers will not paint that in `<img>`.

Organization `file_upload_settings` MIME types and extensions are not required for Extra Blocks slots (the gem already bypasses them). Organization CSP `img-src` is not required; the default `'self'` covers the blob proxy.

Add this initializer in the host app (not in the Extra Blocks Engine):

```ruby
# config/initializers/extra_blocks_svg.rb (host app)
Rails.application.config.active_storage.content_types_allowed_inline << "image/svg+xml"
Rails.application.config.active_storage.content_types_to_serve_as_binary -= ["image/svg+xml"]
```

If someone opens the blob URL as a document, SVG `<script>` can run. That is why this stays a host opt-in.

### Fast Proposal dependencies

Also add (if not already present):

```ruby
gem "decidim-ephemeral_participation",
    git: "https://git.octree.ch/decidim/vocacity/decidim-modules/decidim-ephemeral_participation",
    tag: "v0.0.9"
gem "decidim-proposals" # usually already present via decidim
```

## 2. Where the block appears

Admins can add **Extra Block** on:

- Organization homepage
- Participatory process homepage
- Participatory process group homepage
- Assembly homepage

Use the existing **Add content block** dropdown on each landing page.

## 3. Configure a block

1. Create an Extra Block — you are redirected to the layout gallery.
2. Open **Details** to preview screenshots, or **Use** to freeze a layout.
3. Confirm the freeze modal (layout cannot change later).
4. Fill the layout form and save.

### Shipped layouts

All layouts from `RegisterDefaults` (enable the matching Toggle category or the gallery hides them):

| Layout | Registry key | Category | Main settings |
|--------|--------------|----------|----------------|
| Verbose CTA | `verbose_cta` | CTA | Colors, title, WYSIWYG body, button |
| Dual Path CTA | `dual_path_cta` | CTA | Two path cards + optional section title / background image |
| Join Steps CTA | `join_steps_cta` | CTA | Title, step slots, button, optional background image |
| Trust Quote CTA | `trust_quote_cta` | CTA | Quote, attribution, button, optional portrait |
| Video Hero | `video_hero` | Hero | Title, 9-cell position, WebM/MP4 |
| Photo Mission Hero | `photo_mission_hero` | Hero | Overlay, size, eyebrow, title, tagline, button, image |
| Split Story Hero | `split_story_hero` | Hero | Image side, eyebrow, title, body, button, side image |
| Outcome Stats Hero | `outcome_stats_hero` | Hero | Title, intro, stat slots, button |
| Focused Quick Proposal | `focused_quick_proposal` | Fast Proposal | Proposal component + Fast Proposal fields, background image |
| Split Fast Proposal | `split_fast_proposal` | Fast Proposal | Shared Fast Proposal fields + eyebrow, form side |
| Video Fast Proposal | `video_fast_proposal` | Fast Proposal | Shared Fast Proposal fields + WebM/MP4 background |
| Proposals Aside Fast Proposal | `proposals_aside_fast_proposal` | Fast Proposal | Shared Fast Proposal fields + eyebrow, background image |
| Editorial Prose | `editorial_prose` | Text | Image position, title, body, button, lead image |
| Media Aside | `media_aside` | Text | Image side, title, body, button, aside image slots |
| Topic Trio | `topic_trio` | Text | Title, body, topic slots, button |
| Spacer | `spacer` | Misc | Background color, height |
| Image | `image` | Misc | Width, block image |
| Video | `video` | Misc | Width, WebM/MP4 |
| Logo Showcase | `logo_showcase` | Misc | Logo slots + `logos_json` |
| Brand Story | `brand_story` | Timelines | Event slots + images |
| Roadmap | `roadmap` | Timelines | Event slots + per-event buttons |
| Impact Milestones | `impact_milestones` | Timelines | Event slots |

Field-level detail: [Configure layouts](./configure.md).

## Fast Proposal runbook

Layouts in the **Fast Proposal** category publish into a proposals component. Guest flows use `decidim-ephemeral_participation`. The public section stays hidden until the gate opens (`FastProposal::EphemeralGate`).

1. Install `decidim-proposals` and `decidim-ephemeral_participation` (see above), migrate, restart.
2. Enable the **Fast Proposal** category under **System → Organizations → Extra Blocks**.
3. On the organization, set **ephemeral participation authorization** to a handler that exists in `available_authorizations`.
4. Create or pick a **proposals** component:
   - Allow proposal creation (`creation_enabled`).
   - Enable **ephemeral participation** on the component.
   - Put the same authorization handler on the component **create** permission.
5. On the landing page, add **Extra Block**, freeze a Fast Proposal layout, select that component, save.

If creation is disabled, ephemeral is off, org authorization is blank, or the handler is missing from create permissions, the block does not render for participants (admins can still prepare settings).

## See also

- [Quick configure](./configure.md)
- [Add a layout](../contribute/add-a-layout.md) — gem contributors only
