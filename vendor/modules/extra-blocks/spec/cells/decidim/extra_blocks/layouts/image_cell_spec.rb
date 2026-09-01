# frozen_string_literal: true

require "spec_helper"

module Decidim::ExtraBlocks::Layouts
  describe ImageCell, type: :cell do
    subject { cell_instance.call }

    let(:organization) { create(:organization) }
    let(:settings) do
      {
        "layout" => "image",
        "background_color" => "#ffffff",
        "media_width" => "boxed"
      }
    end
    let(:content_block) do
      create(
        :content_block,
        organization:,
        manifest_name: :extra_block,
        scope_name: :homepage,
        settings:
      )
    end
    let(:cell_instance) { cell("decidim/extra_blocks/layouts/image", content_block) }

    controller Decidim::PagesController

    before do
      allow(controller).to receive(:current_organization).and_return(organization)
    end

    it "renders a boxed misc image section without an upload" do
      expect(subject).to have_css(
        "section.extra-blocks-image--boxed[data-extra-blocks-category='misc']"
      )
      expect(subject).to have_no_css("img.extra-blocks-image__img")
    end
  end
end
