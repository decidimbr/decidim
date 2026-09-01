# frozen_string_literal: true

require "spec_helper"

module Decidim::ExtraBlocks::Layouts
  describe BrandStoryCell, type: :cell do
    subject { cell_instance.call }

    let(:organization) { create(:organization) }
    let(:settings) do
      {
        "layout" => "brand_story",
        "title" => { "en" => "Our journey" },
        "event_1_date" => { "en" => "2019" },
        "event_1_title" => { "en" => "Founded" },
        "event_1_body" => { "en" => "We started." },
        "event_2_date" => { "en" => "2022" },
        "event_2_title" => { "en" => "Grew" },
        "event_2_body" => { "en" => "More cities joined." },
        "event_3_date" => { "en" => "" },
        "event_3_title" => { "en" => "" },
        "event_3_body" => { "en" => "" },
        "background_color" => "#ffffff",
        "text_color" => "black"
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
    let(:cell_instance) { cell("decidim/extra_blocks/layouts/brand_story", content_block) }

    controller Decidim::PagesController

    around do |example|
      I18n.with_locale(:en) { example.run }
    end

    before do
      allow(controller).to receive(:current_organization).and_return(organization)
    end

    it "renders the section and filled events only" do
      expect(subject).to have_css("section.extra-blocks-brand-story[data-extra-blocks-category='timelines']")
      expect(subject).to have_content("Our journey")
      expect(subject).to have_css("li.extra-blocks-brand-story__event", count: 2)
      expect(subject).to have_content("2019")
      expect(subject).to have_content("Founded")
      expect(subject).to have_content("2022")
      expect(subject).to have_content("Grew")
    end

    context "with a highlighted event in events_json" do
      let(:settings) do
        super().merge(
          "events_json" => [
            { "slot" => 1, "highlighted" => true },
            { "slot" => 2, "highlighted" => false }
          ].to_json
        )
      end

      it "marks the highlighted event" do
        expect(subject).to have_css("li.extra-blocks-brand-story__event--highlighted", count: 1)
        expect(subject).to have_css("li.extra-blocks-brand-story__event--highlighted", text: "Founded")
      end
    end
  end
end
