# frozen_string_literal: true

require "spec_helper"

module Decidim::ExtraBlocks::Layouts
  describe VideoCell, type: :cell do
    subject { cell_instance.call }

    let(:organization) { create(:organization) }
    let(:settings) do
      {
        "layout" => "video",
        "background_color" => "#000000",
        "media_width" => "full"
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
    let(:cell_instance) { cell("decidim/extra_blocks/layouts/video", content_block) }

    controller Decidim::PagesController

    before do
      allow(controller).to receive(:current_organization).and_return(organization)
    end

    it "renders a full-width misc video section without sources" do
      expect(subject).to have_css(
        "section.extra-blocks-video--full[data-extra-blocks-category='misc']"
      )
      expect(subject).to have_no_css("video.extra-blocks-video__player")
    end
  end
end
