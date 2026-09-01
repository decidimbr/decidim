# frozen_string_literal: true

# Intentionally empty: Extra Blocks seeds run after Decidim.seed! via
# Decidim::ExtraBlocks::SeedHook (see engine). Mid-flight load_seed would run
# before participatory space manifests and could abort the rest of Decidim seeds.
