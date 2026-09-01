# frozen_string_literal: true

require "spec_helper"

module Decidim::ExtraBlocks::Layouts
  describe ImpactMilestonesCell, type: :cell do
    subject { cell_instance.call }

    let(:organization) { create(:organization) }
    let(:settings) do
      {
        "layout" => "impact_milestones",
        "title" => { "en" => "Impact so far" },
        "event_1_date" => { "en" => "12k" },
        "event_1_title" => { "en" => "Participants" },
        "event_1_body" => { "en" => "Across the city." },
        "event_2_date" => { "en" => "48" },
        "event_2_title" => { "en" => "Projects funded" },
        "event_2_body" => { "en" => "" },
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
    let(:cell_instance) { cell("decidim/extra_blocks/layouts/impact_milestones", content_block) }

    controller Decidim::PagesController

    around do |example|
      I18n.with_locale(:en) { example.run }
    end

    before do
      allow(controller).to receive(:current_organization).and_return(organization)
    end

    it "renders the section and filled milestones only" do
      expect(subject).to have_css("section.extra-blocks-impact-milestones[data-extra-blocks-category='timelines']")
      expect(subject).to have_content("Impact so far")
      expect(subject).to have_css("li.extra-blocks-impact-milestones__event", count: 2)
      expect(subject).to have_content("12k")
      expect(subject).to have_content("Participants")
      expect(subject).to have_content("48")
      expect(subject).to have_content("Projects funded")
    end
  end
end
