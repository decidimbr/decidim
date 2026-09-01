---
sidebar_position: 1
title: Add a layout
description: Register a new Extra Blocks layout with LayoutRegistry
---

# Add a layout

Who reads this: contributors to `decidim-extra-blocks`. You do **not** register a new Decidim ContentBlock — one `:extra_block` already covers all layouts.

Categories (`:cta`, `:hero`, `:text`, `:fast_proposal`, `:misc`, `:timelines`, …) group layouts in the gallery and drive System → Extra Blocks Toggle checkboxes. New categories also need an `availability.scss` hide rule and Toggle/category locales.

See also: [Architecture](./architecture.md), [Local development](./local-development.md), root [CONTRIBUTING.md](https://git.octree.ch/decidim/decidim-modules/decidim-extra-blocks/-/blob/main/CONTRIBUTING.md).

## File tree to create

For a layout named `my_layout` (snake_case registry key; kebab-case in CSS):

```text
lib/decidim/extra_blocks/layouts/register_defaults.rb   # or a dedicated register_*.rb required from engine
app/cells/decidim/extra_blocks/layouts/
  my_layout_cell.rb
  my_layout/show.erb
  my_layout_settings_form_cell.rb
  my_layout_settings_form/show.erb
app/packs/stylesheets/decidim/extra_blocks/my_layout.scss
app/packs/images/decidim/extra_blocks/
  my_layout.png
  my_layout_1.png
  my_layout_2.png
  my_layout_3.png
config/locales/en.yml                                    # name + description (+ settings labels)
spec/…                                                   # registry, cell, admin path
website/docs/integrate/configure.md                      # implementor field reference
```

Import the SCSS (and any JS) from `app/packs/entrypoints/decidim_extra_blocks.js`.

## BEM dual-class contract

Shared elements use **both** a global Extra Blocks class and a layout-scoped class:

```erb
<h2 class="extra-blocks__title extra-blocks-my-layout__title"><%= title %></h2>
<div class="extra-blocks__description extra-blocks-my-layout__description"><%= body %></div>
```

- `extra-blocks__*` — shared typography/spacing hooks (tokens + host overrides)
- `extra-blocks-<layout>__*` — layout-specific structure (kebab-case layout name)

Section root: `extra-blocks-my-layout` plus `data-extra-blocks-category="…"`.

## Design tokens

Shared CSS variables live in `app/packs/stylesheets/decidim/extra_blocks/_tokens.scss`. Prefer tokens over hard-coded sizes. When adding a font-size token, add the matching **line-height** token (e.g. `--eb-font-size-md` with `--eb-line-height-md`).

## Dynamic ordered slots

Reusable add/remove lists (topics, events, logos, asides, …) use fixed settings/image slots plus a JSON order attribute via `DynamicOrderedSlots`:

1. Family module (`DynamicTopics`, `DynamicEvents`, …) sets `SLOT_COUNT` + `JSON_ATTRIBUTE` and calls `declare!` from registration.
2. Admin partials render the shared dynamic list UI.
3. Public cell uses `entries_for` so blank slots are omitted and JSON order wins when set.

Example: `DynamicTopics.declare!(layout)` + `dynamic_topics_fields` partial. For logos: `DynamicLogos.declare!(layout)` + `dynamic_logos_fields`.

## Checklist

1. Register the layout in `lib/decidim/extra_blocks/layouts/` (new file or `register_defaults.rb`).
2. Set `category`, i18n keys, preview PNG, **exactly three** screenshots, `cell`, `settings_form_cell`.
3. Declare `settings` (reuse shared names like `background_color`, `text_color`, `title` when meanings match).
4. Optional: `images` for uploads (see `background_video`). For ordered slot lists, call the matching `Dynamic*.declare!(layout)`.
5. Add public cell + ERB + mobile-first SCSS partial imported from `decidim_extra_blocks.js`.
6. Add settings_form cell inheriting `BaseSettingsFormCell` (layout fields only + hidden `layout`; explicit `render :show` avoids Decidim’s intermittent `block.erb` lookup). Shared cell partials must not use ActionView-only APIs (`local_assigns`) or multiline `<% … do … end %>` (erbse treats any `end` as `<% end %>`).
7. Add locale strings under `decidim.extra_blocks`.
8. Specs: registry presence, cell render, admin path select → freeze → save.
9. Document the layout in `website/docs/integrate/configure.md`.

## Example

```ruby
Decidim::ExtraBlocks::Layouts::LayoutRegistry.register(:my_layout) do |layout|
  layout.category = :cta
  layout.public_name_key = "decidim.extra_blocks.layouts.my_layout.name"
  layout.description_key = "decidim.extra_blocks.layouts.my_layout.description"
  layout.preview_image = "media/images/my_layout.png"
  layout.screenshots = [
    "media/images/my_layout_1.png",
    "media/images/my_layout_2.png",
    "media/images/my_layout_3.png"
  ]
  layout.cell = "decidim/extra_blocks/layouts/my_layout"
  layout.settings_form_cell = "decidim/extra_blocks/layouts/my_layout_settings_form"

  layout.settings do |settings|
    settings.attribute :title, type: :text, translated: true
  end
end
```

Union settings are merged onto the single ContentBlock manifest at boot — no migration.

## Local verification

```bash
docker compose exec extra-blocks bundle exec rspec \
  spec/lib/decidim/extra_blocks/layouts/layout_registry_spec.rb
```

Full suite (0.29 default):

```bash
docker compose exec extra-blocks bash -lc 'unset DATABASE_URL && bundle exec rspec'
```
