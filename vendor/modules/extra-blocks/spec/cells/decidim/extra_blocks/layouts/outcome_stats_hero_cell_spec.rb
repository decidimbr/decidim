# frozen_string_literal: true

require "spec_helper"

module Decidim::ExtraBlocks::Layouts
  describe OutcomeStatsHeroCell, type: :cell do
    subject { cell_instance.call }

    let(:organization) { create(:organization) }
    let(:settings) do
      {
        "layout" => "outcome_stats_hero",
        "title" => { "en" => "Participation in numbers" },
        "intro" => { "en" => "Results from this mandate." },
        "stat_1_value" => { "en" => "12 000" },
        "stat_1_label" => { "en" => "Participants" },
        "stat_2_value" => { "en" => "480" },
        "stat_2_label" => { "en" => "Proposals" },
        "stat_3_value" => { "en" => "" },
        "stat_3_label" => { "en" => "" },
        "stats_json" => "",
        "button_label" => { "en" => "Learn more" },
        "button_url" => "https://example.org/more",
        "background_color" => "#0f3460",
        "text_color" => "white"
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
    let(:cell_instance) { cell("decidim/extra_blocks/layouts/outcome_stats_hero", content_block) }

    controller Decidim::PagesController

    around do |example|
      I18n.with_locale(:en) { example.run }
    end

    before do
      allow(controller).to receive(:current_organization).and_return(organization)
    end

    it "renders title and filled stats only" do
      expect(subject.to_s).to include("--eb-fg: #ffffff")
      expect(subject).to have_content("Participation in numbers")
      expect(subject).to have_content("Results from this mandate.")
      expect(subject).to have_css("li.extra-blocks-outcome-stats-hero__stat", count: 2)
      expect(subject).to have_content("12 000")
      expect(subject).to have_content("Participants")
      expect(subject).to have_link("Learn more", href: "https://example.org/more")
      expect(subject).to have_css("a.button.button__lg.button__primary", text: "Learn more")
    end
  end
end
