---
sidebar_position: 2
title: Local development
description: Run Extra Blocks in Docker for gem development
---

# Local development

Who reads this: contributors working on the gem itself (not host-app install).

Default target is **Decidim 0.29**. Full commands live in the repo root [README](https://git.octree.ch/decidim/decidim-modules/decidim-extra-blocks/-/blob/main/README.md) and [CONTRIBUTING.md](https://git.octree.ch/decidim/decidim-modules/decidim-extra-blocks/-/blob/main/CONTRIBUTING.md).

## Quickstart (0.29)

```bash
docker compose up -d
docker compose exec extra-blocks bash
bundle install
bundle exec rake test_app
```

In the container, run Rails and Shakapacker (two shells):

```bash
cd /home/module/spec/decidim_dummy_app
bin/rails s -b 0.0.0.0 -p 3000
```

```bash
cd /home/module/spec/decidim_dummy_app
bin/shakapacker-dev-server
```

Open **http://localhost:3004** (Rails). Packs: **http://localhost:3035**. If `Bind for 0.0.0.0:3035 failed`, comment the `3035:3035` mapping in `docker-compose.yml` and compile once with `bin/shakapacker` in the dummy app instead of `shakapacker-dev-server`.

Specs:

```bash
cd /home/module
unset DATABASE_URL
bundle exec rspec
```

## Optional Decidim 0.32

```bash
docker compose -f docker-compose.0.32.yml up -d
docker compose -f docker-compose.0.32.yml exec extra-blocks bash
```

Regenerate the dummy app when switching minors. See README for ports (Rails **3014**, packs **3135**).

## Next

- [Add a layout](./add-a-layout.md)
- [Architecture](./architecture.md)
