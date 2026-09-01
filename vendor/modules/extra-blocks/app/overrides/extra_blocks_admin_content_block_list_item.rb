# frozen_string_literal: true

# Mark admin landing-page content-block list items so CSS can hide Extra Blocks
# by module / category when Toggle disables them.

Deface::Override.new(
  virtual_path: "decidim/admin/content_block/show",
  name: "decidim_extra_blocks_admin_content_block_list_item_data",
  set_attributes: "li",
  attributes: {
    "data-extra-blocks-manifest" => "<%= model.manifest_name %>",
    "data-extra-blocks-category" =>
      "<%= Decidim::ExtraBlocks::AdminListItemData.category_for(model) %>"
  }
)
