---
sidebar_position: 3
title: Architecture
description: How Extra Blocks maps ContentBlock to layouts, cells, packs, and Toggle
---

# Architecture

Who reads this: contributors extending the gem.

## Overview

One Decidim content block type — **`:extra_block`** — covers every layout. Layouts are registered in-process; admins freeze one layout per block instance.

## Context

```text
Decidim landing page (homepage / process / process group / assembly)
  └─ ContentBlock :extra_block
       ├─ settings.layout  (frozen string after gallery)
       ├─ union of all layout settings + images
       └─ public cell → layout cell
LayoutRegistry ← RegisterDefaults (boot)
Availability / Toggle ← org System tab (module + categories)
Packs ← decidim_extra_blocks.js (tokens, layout SCSS, admin JS)
```

## Pieces

| Piece | Role |
|-------|------|
| `ContentBlocks::RegistryManager` | Registers `:extra_block` on homepage scopes; merges registry settings/images |
| `Layouts::LayoutRegistry` | Name → category, cells, i18n, previews, settings |
| `Layouts::RegisterDefaults` | Ships built-in layouts |
| Layout public + settings_form cells | Render and admin form for one layout |
| `app/packs/…` | Tokens, layout SCSS, gallery/admin JS |
| `Availability` + Toggle settings tab | Gate module and categories per organization |
| `FastProposal::EphemeralGate` | Fail-closed checks for Fast Proposal public UI |

## Detail

- **Freeze**: after gallery **Use**, `layout` is set and cannot change; replace the content block to pick another layout.
- **Categories**: drive gallery grouping, Toggle checkboxes, and `data-extra-blocks-*-enabled` body attributes / `availability.scss`.
- **Dynamic slots**: fixed `slot_N_*` settings/images + JSON order (`DynamicOrderedSlots` families).

## See also

- [Add a layout](./add-a-layout.md)
- [Local development](./local-development.md)
- Implementor path: [Integrate](../integrate/index.md)
