# frozen_string_literal: true

# Org Toggle flags on admin <body> for Extra Blocks CSS hide rules.

Deface::Override.new(
  virtual_path: "layouts/decidim/admin/_application",
  name: "decidim_extra_blocks_admin_body_data_attributes",
  set_attributes: "body",
  attributes: Decidim::ExtraBlocks::BodyDataAttributes.deface_attributes
)
