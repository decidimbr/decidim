# frozen_string_literal: true

require "spec_helper"

describe "Extra Blocks toggle availability", type: :system do
  let(:organization) { create(:organization) }
  let(:user) { create(:user, :admin, :confirmed, organization:) }
  let!(:content_block) do
    create(
      :content_block,
      organization:,
      manifest_name: :extra_block,
      scope_name: :homepage,
      published_at: Time.current,
      settings: {
        "layout" => "verbose_cta",
        "title" => { "en" => "Join the process" },
        "button_label" => { "en" => "Participate" },
        "button_url" => "https://example.org/join"
      }
    )
  end

  before do
    switch_to_host(organization.host)
  end

  context "when the module is disabled" do
    before do
      Decidim::Toggle.save_config!(
        organization,
        Decidim::ExtraBlocks::MODULE_NAME,
        { "enabled" => false, "cta_enabled" => true, "hero_enabled" => true },
        merge: false
      )
    end

    it "hides Extra Block from the add dropdown and hides published cells" do
      login_as user, scope: :user
      visit decidim_admin.edit_organization_homepage_path

      expect(page).to have_css("body[data-extra-blocks-enabled=\"false\"]")
      expect(page).to have_css("#add-content-block-dropdown a[href*='manifest_name=extra_block']", visible: :hidden)

      visit decidim.root_path
      expect(page).to have_css(".layout-container[data-extra-blocks-enabled=\"false\"]")
      expect(page).to have_css("section.extra-blocks-verbose-cta", visible: :hidden)
    end
  end

  context "when a category is disabled" do
    before do
      Decidim::Toggle.save_config!(
        organization,
        Decidim::ExtraBlocks::MODULE_NAME,
        { "enabled" => true, "cta_enabled" => false, "hero_enabled" => true },
        merge: false
      )
    end

    it "hides CTA cells and omits CTA from the layout gallery" do
      login_as user, scope: :user

      visit decidim.root_path
      expect(page).to have_css(".layout-container[data-extra-blocks-cta-enabled=\"false\"]")
      expect(page).to have_css("section.extra-blocks-verbose-cta", visible: :hidden)

      gallery_block = create(
        :content_block,
        organization:,
        manifest_name: :extra_block,
        scope_name: :homepage,
        settings: { "layout" => nil }
      )
      visit decidim_admin.edit_organization_homepage_content_block_path(gallery_block)

      expect(page).to have_css(".extra-blocks-gallery")
      expect(page).not_to have_content("Verbose CTA")
      expect(page).to have_content("Video Hero")
    end
  end
end
