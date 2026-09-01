---
sidebar_position: 2
title: Configure layouts
description: Field reference for Extra Blocks layouts
---

# Configure layouts

Who reads this: host-app **implementors** filling layout forms after freeze. Contributors registering layouts: [Add a layout](../contribute/add-a-layout.md).

After a layout is frozen, only that layout's form is available.

## Verbose CTA

Full-width section. Stacked on small screens; two columns from the `md` breakpoint (text | button).

| Field | Notes |
|-------|--------|
| Background color | Color picker |
| Text color | Radio: white / black |
| Title | Translated |
| Text | Translated WYSIWYG |
| Button label | Translated |
| Button URL | Single URL (not translated) |

## Dual Path CTA

Two equal action cards (e.g. take part vs see results).

| Field | Notes |
|-------|--------|
| Background color | Color picker |
| Text color | Radio: white / black |
| Section title | Translated, optional |
| First / second path title | Translated |
| First / second path text | Translated WYSIWYG |
| First / second button label | Translated |
| First / second button URL | Single URL (not translated) |
| Background image | Optional image upload |
| Background fit | Radio after the image upload. CSS object-fit: cover (default), contain, fill, none, scale-down. SVG backgrounds (seed `pattern_*.svg`) typically use contain. |

## Join Steps CTA

Three numbered onboarding steps ending in one primary button.

| Field | Notes |
|-------|--------|
| Background color | Color picker |
| Text color | Radio: white / black |
| Title | Translated |
| Step 1–3 title | Translated |
| Step 1–3 text | Translated plain text |
| Button label | Translated |
| Button URL | Single URL (not translated) |
| Background image | Optional image upload |
| Background fit | Radio after the image upload. CSS object-fit: cover (default), contain, fill, none, scale-down. SVG backgrounds (seed `pattern_*.svg`) typically use contain. |

## Trust Quote CTA

Participant or institutional quote with optional portrait and invitation button.

| Field | Notes |
|-------|--------|
| Background color | Color picker |
| Text color | Radio: white / black |
| Quote | Translated |
| Name | Translated |
| Role or organization | Translated |
| Button label | Translated |
| Button URL | Single URL (not translated) |
| Portrait | Optional image upload |

## Video Hero

Full-width section with `min-height: 60vh`. Optional video plays muted, looping, behind the title.

| Field | Notes |
|-------|--------|
| Background color | Fallback under / before video |
| Text color | Radio: white / black |
| Title | Translated |
| Title position | Nine positions (`top_left` … `bottom_right`) |
| Background video (WebM) | Optional |
| Background video (MP4) | Optional fallback |

## Photo Mission Hero

Full-bleed static photo with mission headline and tagline.

| Field | Notes |
|-------|--------|
| Background color | Fallback under / before image |
| Text color | Radio: white / black |
| Overlay strength | Light / medium / dark |
| Size | Small / medium / large |
| Eyebrow | Translated, optional |
| Title | Translated |
| Tagline | Translated |
| Button label | Translated |
| Button URL | Single URL (not translated) |
| Background image | Optional image upload |
| Background fit | Radio after the image upload. CSS object-fit: cover (default), contain, fill, none, scale-down. SVG backgrounds (seed `pattern_*.svg`) typically use contain. |

## Split Story Hero

Two columns: civic image beside title and narrative. Image side is configurable.

| Field | Notes |
|-------|--------|
| Background color | Color picker |
| Text color | Radio: white / black |
| Image side | Left / right |
| Eyebrow | Translated, optional |
| Title | Translated |
| Text | Translated WYSIWYG |
| Side image | Optional image upload |

## Outcome Stats Hero

Compact hero with headline and up to three admin-entered impact figures.

| Field | Notes |
|-------|--------|
| Background color | Color picker |
| Text color | Radio: white / black |
| Title | Translated |
| Intro | Translated |
| Statistic 1–3 value | Translated |
| Statistic 1–3 label | Translated |
| Button label | Translated |
| Button URL | Single URL (not translated) |

## Editorial Prose

Centered readable column for mid-page explainers. Optional lead image above or below the text.

| Field | Notes |
|-------|--------|
| Background color | Color picker |
| Text color | Radio: white / black |
| Image position | Above / below |
| Title | Translated |
| Text | Translated WYSIWYG |
| Button label | Translated |
| Button URL | Single URL (not translated) |
| Lead image | Optional image upload |

## Media Aside

Two columns: three-image fade slideshow beside title and narrative. Mid-page spacing (not a hero). Image side is configurable. Autoplay uses vanilla JS fade transitions (paused when `prefers-reduced-motion` is set).

| Field | Notes |
|-------|--------|
| Background color | Color picker |
| Text color | Radio: white / black |
| Image side | Left / right |
| Title | Translated |
| Text | Translated WYSIWYG |
| Button label | Translated |
| Button URL | Single URL (not translated) |
| Aside image 1–3 | Optional image uploads (slideshow when 2+ are set) |

## Topic Trio

Section intro plus three topic cards (image, title, short text) and one primary button. SVG card images need the host ActiveStorage opt-in; see [SVG display](./index.md#svg-display).

| Field | Notes |
|-------|--------|
| Background color | Color picker |
| Text color | Radio: white / black |
| Title | Translated |
| Text | Translated WYSIWYG (section intro) |
| Topic 1–3 title | Translated |
| Topic 1–3 text | Translated plain text |
| Topic 1–3 image | Optional image upload |
| Button label | Translated |
| Button URL | Single URL (not translated) |

## Brand Story (Timelines)

Vertical journey timeline with a center spine and alternating milestone cards (stacked on small screens). Blank events are omitted.

| Field | Notes |
|-------|--------|
| Background color | Color picker |
| Text color | Radio: white / black |
| Title | Translated section heading |
| Event 1–5 date | Translated freeform label (`2019`, `Q3`, `March 2024`) |
| Event 1–5 title | Translated |
| Event 1–5 text | Translated plain text |
| Event 1–5 image | Optional image upload |

## Roadmap (Timelines)

Horizontal phase cards with a connector line (scrolls sideways on small screens). Optional per-phase CTA. Blank events are omitted.

| Field | Notes |
|-------|--------|
| Background color | Color picker |
| Text color | Radio: white / black |
| Title | Translated section heading |
| Event 1–5 date | Translated phase label |
| Event 1–5 title | Translated |
| Event 1–5 text | Translated plain text |
| Event 1–5 button label | Translated (optional) |
| Event 1–5 button URL | Single URL (not translated) |

## Impact Milestones (Timelines)

Compact centered achievement rail for key wins and social proof. Blank events are omitted.

| Field | Notes |
|-------|--------|
| Background color | Color picker |
| Text color | Radio: white / black |
| Title | Translated section heading |
| Event 1–5 date | Translated prominent label (year, figure, or short date) |
| Event 1–5 title | Translated |
| Event 1–5 text | Translated plain text |

## Shared Fast Proposal fields

All Fast Proposal layouts publish into a selected proposals component. Guest submissions use Decidim ephemeral participation (managed user + required authorization). See the [Fast Proposal runbook](./index.md#fast-proposal-runbook).

| Field | Notes |
|-------|--------|
| Proposal component | Required. Published proposals components in the organization |
| Title | Optional translated heading above the form |
| Description | Optional translated WYSIWYG under the title |
| Background color | Color picker |
| Text color | Radio: white / black |
| Custom terms and conditions | Optional translated WYSIWYG. When set, participants must accept |
| Proposal Title when anonymous | Template with `{{id}}` / `{{random}}` (guest / ephemeral) |
| Proposal Title when connected | Template with `{{id}}` / `{{random}}` (logged-in account). If under 15 chars after placeholders, `{{random}}` is appended. Avoid `#words` (Decidim hashtags). |
| Success page message | Translated; use `{{seconds}}` for the redirect delay |
| Success page button | Translated |
| Time before redirect on success page | Default `15` |

The public section stays hidden until creation is enabled, ephemeral participation is on, and org + create-permission authorization match (`EphemeralGate`). Admins may still prepare settings beforehand.

## Focused Quick Proposal (`focused_quick_proposal`)

Centered form. Shared Fast Proposal fields plus:

| Field | Notes |
|-------|--------|
| Background image | Optional. Full-width image over the background color (srcset via Extra Blocks picture helper) |
| Background fit | Radio after the image upload. CSS object-fit: cover (default), contain, fill, none, scale-down. SVG backgrounds (seed `pattern_*.svg`) typically use contain. |

## Split Fast Proposal (`split_fast_proposal`)

Two-column layout: form beside supporting copy. Shared Fast Proposal fields plus:

| Field | Notes |
|-------|--------|
| Eyebrow | Translated, optional |
| Form side | Left / right |
| Background image | Optional |
| Background fit | Radio after the image upload. CSS object-fit: cover (default), contain, fill, none, scale-down. SVG backgrounds (seed `pattern_*.svg`) typically use contain. |

## Video Fast Proposal (`video_fast_proposal`)

Form over a looping muted background video. Shared Fast Proposal fields plus:

| Field | Notes |
|-------|--------|
| Background video (WebM) | Optional |
| Background video (MP4) | Optional fallback |

## Proposals Aside Fast Proposal (`proposals_aside_fast_proposal`)

Form with a proposals aside strip. Shared Fast Proposal fields plus:

| Field | Notes |
|-------|--------|
| Eyebrow | Translated, optional |
| Background image | Optional |
| Background fit | Radio after the image upload. CSS object-fit: cover (default), contain, fill, none, scale-down. SVG backgrounds (seed `pattern_*.svg`) typically use contain. |

## Spacer (Misc)

Empty vertical gap. No text.

| Field | Notes |
|-------|--------|
| Background color | Color picker |
| Height | `1rem` / `3rem` / `5rem` |

## Image (Misc)

One image, full-width or boxed.

| Field | Notes |
|-------|--------|
| Background color | Color picker |
| Width | Full width / boxed |
| Image | Optional image upload |

## Video (Misc)

One video with browser controls, full-width or boxed. Upload WebM and/or MP4 (same slots as Video Hero).

| Field | Notes |
|-------|--------|
| Background color | Fallback when no video is set |
| Width | Full width / boxed |
| Video (WebM) | Optional |
| Video (MP4) | Optional fallback |

## Logo showcase (Misc)

Partner logo grid (up to 12). Admin add/remove UI stores order and alt text in `logos_json`; images use fixed slots `logo_1`…`logo_12`. Public logos are greyscale and fade to color on hover. Frames are padded 16:9 (`object-fit: contain`). Logo images may be SVG (or jpeg/png/webp); SVG renders as `<img>`, not `<picture>`.

| Field | Notes |
|-------|--------|
| Background color | Color picker |
| Logos | Dynamic list: alt text (per locale) + image upload; “+” / remove |

## Changing layout

Delete the content block and create a new Extra Block. Layout freeze is one-way on purpose.
