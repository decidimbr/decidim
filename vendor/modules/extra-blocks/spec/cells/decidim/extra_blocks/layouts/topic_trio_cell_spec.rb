# frozen_string_literal: true

require "spec_helper"

module Decidim::ExtraBlocks::Layouts
  describe TopicTrioCell, type: :cell do
    subject { cell_instance.call }

    let(:organization) { create(:organization) }
    let(:settings) do
      {
        "layout" => "topic_trio",
        "eyebrow" => { "en" => "Guiding themes" },
        "title" => { "en" => "What you will find" },
        "body" => { "en" => "<p>Three themes to explore.</p>" },
        "topic_1_title" => { "en" => "Debate" },
        "topic_1_body" => { "en" => "Share ideas." },
        "topic_2_title" => { "en" => "Decide" },
        "topic_2_body" => { "en" => "Vote together." },
        "topic_3_title" => { "en" => "Follow" },
        "topic_3_body" => { "en" => "Track outcomes." },
        "topics_json" => "",
        "button_label" => { "en" => "Get started" },
        "button_url" => "https://example.org/start",
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
    let(:cell_instance) { cell("decidim/extra_blocks/layouts/topic_trio", content_block) }

    controller Decidim::PagesController

    around do |example|
      I18n.with_locale(:en) { example.run }
    end

    before do
      allow(controller).to receive(:current_organization).and_return(organization)
    end

    it "renders the section, topics, and button" do
      expect(subject).to have_css("section.extra-blocks-topic-trio[data-extra-blocks-category='text']")
      expect(subject).to have_css("p.extra-blocks__eyebrow.extra-blocks-topic-trio__eyebrow", text: "Guiding themes")
      expect(subject).to have_content("What you will find")
      expect(subject).to have_content("Three themes to explore.")
      expect(subject).to have_content("Debate")
      expect(subject).to have_content("Decide")
      expect(subject).to have_content("Follow")
      expect(subject).to have_link("Get started", href: "https://example.org/start")
    end
  end
end
