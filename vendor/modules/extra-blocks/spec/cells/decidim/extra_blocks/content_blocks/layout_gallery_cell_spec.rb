# frozen_string_literal: true

require "spec_helper"

module Decidim::ExtraBlocks
  describe ContentBlocks::LayoutGalleryCell, type: :cell do
    let(:organization) { create(:organization) }
    let(:content_block) do
      create(
        :content_block,
        organization:,
        manifest_name: :extra_block,
        scope_name: :homepage,
        settings: { "layout" => nil }
      )
    end
    let(:content_block_form) do
      Decidim::Admin::ContentBlockForm.from_model(content_block).with_context(
        current_organization: organization,
        content_block:
      )
    end
    let(:cell_instance) do
      cell(
        "decidim/extra_blocks/content_blocks/layout_gallery",
        Decidim::FormBuilder.new(:content_block, content_block_form, controller.view_context, {}),
        content_block:
      )
    end

    controller Decidim::Admin::ApplicationController

    before do
      allow(controller).to receive(:current_organization).and_return(organization)
      allow(cell_instance).to receive(:asset_pack_path) { |path| "/packs/#{path}" }
    end

    it "omits disabled categories from the gallery" do
      Decidim::Toggle.save_config!(
        organization,
        Decidim::ExtraBlocks::MODULE_NAME,
        {
          "enabled" => true,
          "cta_enabled" => true,
          "hero_enabled" => false,
          "text_enabled" => true,
          "fast_proposal_enabled" => true
        },
        merge: false
      )

      html = cell_instance.call

      expect(html).to have_content("Verbose CTA")
      expect(html).not_to have_content("Video Hero")
      expect(html).to have_content("Editorial Prose")
      expect(html).to have_content("Focused")
      expect(html).to have_css('[data-extra-blocks-category="cta"]')
      expect(html).not_to have_css('[data-extra-blocks-category="hero"]')
      expect(html).to have_css('[data-extra-blocks-category="text"]')
      expect(html).to have_css('[data-extra-blocks-category="fast_proposal"]')
      expect(html).to have_css("button.button.button__sm.button__secondary[data-open-confirm]")
      expect(html).to have_no_css(".extra-blocks-gallery button.button__primary")
    end
  end
end
