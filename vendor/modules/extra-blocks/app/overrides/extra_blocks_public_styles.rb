# frozen_string_literal: true

# Shakapacker only stacks append_stylesheet_pack_tag calls that run *before*
# stylesheet_pack_tag "decidim_core" in the layout head (see shakapacker README).
# Calling append from a cell body is too late — packs never appear in the page.

Deface::Override.new(
  virtual_path: "layouts/decidim/_head",
  name: "decidim_extra_blocks_append_stylesheet",
  insert_before: "erb[loud]:contains('stylesheet_pack_tag \"decidim_core\"')",
  text: <<~ERB
    <%= append_stylesheet_pack_tag "decidim_extra_blocks", media: "all" %>
    <%= append_javascript_pack_tag "decidim_extra_blocks" %>
  ERB
)
