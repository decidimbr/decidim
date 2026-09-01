# frozen_string_literal: true

require "spec_helper"

module Decidim::ExtraBlocks::Layouts
  describe RoadmapCell, type: :cell do
    subject { cell_instance.call }

    let(:organization) { create(:organization) }
    let(:settings) do
      {
        "layout" => "roadmap",
        "title" => { "en" => "What is next" },
        "event_1_date" => { "en" => "Q1" },
        "event_1_title" => { "en" => "Listen" },
        "event_1_body" => { "en" => "Collect ideas." },
        "event_1_button_label" => { "en" => "Join" },
        "event_1_button_url" => "https://example.org/join",
        "event_2_date" => { "en" => "Q2" },
        "event_2_title" => { "en" => "Decide" },
        "event_2_body" => { "en" => "Vote on priorities." },
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
    let(:cell_instance) { cell("decidim/extra_blocks/layouts/roadmap", content_block) }

    controller Decidim::PagesController

    around do |example|
      I18n.with_locale(:en) { example.run }
    end

    before do
      allow(controller).to receive(:current_organization).and_return(organization)
    end

    it "renders the section, phases, and event button" do
      expect(subject).to have_css("section.extra-blocks-roadmap[data-extra-blocks-category='timelines']")
      expect(subject).to have_content("What is next")
      expect(subject).to have_css("ol.extra-blocks-roadmap__events.not-prose")
      expect(subject).to have_css("li.extra-blocks-roadmap__event", count: 2)
      expect(subject).to have_content("Q1")
      expect(subject).to have_content("Listen")
      expect(subject).to have_css("a.button.button__secondary", text: "Join")
      expect(subject).to have_link("Join", href: "https://example.org/join")
      expect(subject).to have_content("Decide")
    end
  end
end
