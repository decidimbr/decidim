# frozen_string_literal: true

# Admin gallery + settings forms need the same Extra Blocks pack as the public site.
# Must run before stylesheet_pack_tag in layouts/decidim/admin/_header.
# JS pack ensures head csrf-token for ActiveStorage DirectUpload (Video Hero).

Deface::Override.new(
  virtual_path: "layouts/decidim/admin/_header",
  name: "decidim_extra_blocks_append_stylesheet_admin",
  insert_before: "erb[loud]:contains('stylesheet_pack_tag \"decidim_core\"')",
  text: <<~ERB
    <%= append_stylesheet_pack_tag "decidim_extra_blocks", media: "all" %>
    <%= append_javascript_pack_tag "decidim_extra_blocks" %>
  ERB
)
