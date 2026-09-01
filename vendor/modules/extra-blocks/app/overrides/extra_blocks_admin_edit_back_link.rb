# frozen_string_literal: true

# Extra Block edit header: back link + layout-aware title (and page title).

Deface::Override.new(
  virtual_path: "decidim/admin/shared/landing_page_content_blocks/edit",
  name: "decidim_extra_blocks_admin_edit_page_title",
  replace: "erb[silent]:contains('add_decidim_page_title')",
  text: <<~ERB
    <% add_decidim_page_title(Decidim::ExtraBlocks::AdminDisplayName.for(content_block)) %>
  ERB
)

Deface::Override.new(
  virtual_path: "decidim/admin/shared/landing_page_content_blocks/edit",
  name: "decidim_extra_blocks_admin_edit_header_title",
  replace: "h1.item_show__header-title",
  text: <<~ERB
    <% if content_block.manifest_name.to_s == "extra_block" %>
      <%= link_to controller.extra_blocks_edit_resource_landing_page_path, class: "button button__transparent-secondary button__sm" do %>
        <%= t("decidim.extra_blocks.admin.edit.back") %>
      <% end %>
    <% end %>
    <h1 class="item_show__header-title">
      <%= Decidim::ExtraBlocks::AdminDisplayName.for(content_block) %>
    </h1>
  ERB
)
