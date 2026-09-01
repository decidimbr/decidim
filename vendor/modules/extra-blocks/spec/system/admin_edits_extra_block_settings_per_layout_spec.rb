# frozen_string_literal: true

require "spec_helper"

# Full HTML render for every layout settings form (no Chrome).
# Catches Cell::TemplateMissingError / erbse parse failures.
describe "Admin edits Extra Block settings for each layout", type: :system, driver: :rack_test do
  let(:organization) { create(:organization) }
  let(:user) { create(:user, :admin, :confirmed, organization:) }

  before do
    switch_to_host(organization.host)
    login_as user, scope: :user
  end

  Decidim::ExtraBlocks::Layouts::LayoutRegistry.names.each do |layout_name|
    it "opens the homepage content-block edit screen for #{layout_name}" do
      content_block = create(
        :content_block,
        organization:,
        manifest_name: :extra_block,
        scope_name: :homepage,
        published_at: Time.current,
        settings: { "layout" => layout_name.to_s }
      )

      visit decidim_admin.edit_organization_homepage_content_block_path(content_block)

      expect(page).to have_current_path(
        decidim_admin.edit_organization_homepage_content_block_path(content_block),
        ignore_query: true
      )
      expect(page).to have_field(
        "content_block[settings][layout]",
        type: :hidden,
        with: layout_name.to_s
      )
      expect(page).not_to have_css(".extra-blocks-gallery")
      expect(page).not_to have_content("Template missing")
      expect(page).not_to have_content("undefined method")
    end
  end
end
