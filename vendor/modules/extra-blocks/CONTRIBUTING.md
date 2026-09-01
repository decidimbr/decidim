# Contributing

## Doc structure map

| Path | Audience | Purpose |
|------|----------|---------|
| `website/docs/index.md` | Both (split links) | Overview + persona entry points |
| `website/docs/integrate/` | Implementor | Install, Toggle, configure, Fast Proposal runbook |
| `website/docs/contribute/` | Contributor | Add layouts, architecture, local Docker |
| `README.md` | Implementor | Short entry + pointer to the site |
| `.cursor/plans/storage/extra-blocks-positioning.md` | Maintainer / wiki | Positioning canvas (not published on the site) |

Rules: kebab-case filenames, one primary persona per page, no structural one-offs without updating this map. Do not mix implementor and contributor audiences on one page.

## Adding a layout

Follow [Add a layout](website/docs/contribute/add-a-layout.md). Summary:

1. `LayoutRegistry.register(:my_layout)` with category, i18n keys, preview PNG, 3 screenshots, cells, settings.
2. Public + settings_form cells and mobile-first SCSS (BEM dual-class + tokens).
3. Specs for registry presence and render path.
4. No new ContentBlock manifest.

## Local checks

Default compose is **Decidim 0.29**. Run and gate on that stack:

```bash
docker compose up -d
docker compose exec extra-blocks bash -lc 'unset DATABASE_URL && bundle exec rspec'
```

Optional **0.32** stack (Ruby ~> 3.4, separate ports/volumes):

```bash
docker compose -f docker-compose.0.32.yml up -d
docker compose -f docker-compose.0.32.yml exec extra-blocks bash
```

### Appraisals (0.29 / 0.32)

Use an absolute `BUNDLE_GEMFILE` (or let `rake test_app` / `prepare_tests` expand a relative one) so dummy `chdir` cannot break the path.

```bash
bundle exec appraisal install
BUNDLE_GEMFILE=$PWD/gemfiles/decidim_0.29.gemfile bundle exec rake test_app
BUNDLE_GEMFILE=$PWD/gemfiles/decidim_0.29.gemfile bundle exec rspec
# Switch minor → regenerate dummy (migrations / secrets / Shakapacker differ)
BUNDLE_GEMFILE=$PWD/gemfiles/decidim_0.32.gemfile bundle exec rake test_app
BUNDLE_GEMFILE=$PWD/gemfiles/decidim_0.32.gemfile bundle exec rspec
```

One dummy app under `spec/decidim_dummy_app` — always regenerate when changing Decidim minor.
`docker-compose.0.32.yml` already sets `BUNDLE_GEMFILE=/home/module/gemfiles/decidim_0.32.gemfile`.

CI parity (fresh ruby:3.2.2 image + postgres:17 + redis, runs `bin/ci-setup` then RSpec):

```bash
docker compose -f docker-compose.ci.yml run --rm rspec
```
