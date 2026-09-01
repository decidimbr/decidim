# frozen_string_literal: true

base_path = File.expand_path("..", __dir__)

# Decidim::Webpacker was renamed to Decidim::Shakapacker in Decidim 0.32
packer = defined?(Decidim::Shakapacker) ? Decidim::Shakapacker : Decidim::Webpacker

packer.register_path("#{base_path}/app/packs")
packer.register_entrypoints(
  decidim_extra_blocks: "#{base_path}/app/packs/entrypoints/decidim_extra_blocks.js"
)
