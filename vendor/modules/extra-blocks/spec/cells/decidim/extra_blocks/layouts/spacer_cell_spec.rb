# frozen_string_literal: true

require "spec_helper"

module Decidim::ExtraBlocks::Layouts
  describe SpacerCell, type: :cell do
    subject { cell_instance.call }

    let(:organization) { create(:organization) }
    let(:settings) do
      {
        "layout" => "spacer",
        "background_color" => "#eeeeee",
        "spacer_height" => "5rem"
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
    let(:cell_instance) { cell("decidim/extra_blocks/layouts/spacer", content_block) }

    controller Decidim::PagesController

    before do
      allow(controller).to receive(:current_organization).and_return(organization)
    end

    it "renders an empty misc spacer section" do
      expect(subject).to have_css(
        "section.extra-blocks-spacer[data-extra-blocks-category='misc'][aria-hidden='true']"
      )
      expect(subject.to_s).to include("--eb-spacer-height: 5rem")
      expect(subject.to_s).to include("--eb-bg: #eeeeee")
      expect(subject).to have_no_css("h2, p, img, video")
    end
  end
end
