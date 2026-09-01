# frozen_string_literal: true

# Org Toggle flags on public .layout-container for Extra Blocks CSS hide rules.
# Do not target layouts/decidim/_application: Deface cannot parse an open <body>.

Deface::Override.new(
  virtual_path: "layouts/decidim/_wrapper",
  name: "decidim_extra_blocks_public_layout_container_data_attributes",
  set_attributes: "div.layout-container",
  original: %(<div class="layout-container">),
  attributes: Decidim::ExtraBlocks::BodyDataAttributes.deface_attributes
)
