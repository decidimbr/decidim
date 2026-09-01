# frozen_string_literal: true

require "spec_helper"

module Decidim::ExtraBlocks::Layouts
  describe SplitStoryHeroCell, type: :cell do
    subject { cell_instance.call }

    let(:organization) { create(:organization) }
    let(:settings) do
      {
        "layout" => "split_story_hero",
        "eyebrow" => { "en" => "Our platform" },
        "title" => { "en" => "Why we opened this space" },
        "body" => { "en" => "<p>Citizens decide together.</p>" },
        "button_label" => { "en" => "Learn more" },
        "button_url" => "https://example.org/more",
        "image_side" => "left",
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
    let(:cell_instance) { cell("decidim/extra_blocks/layouts/split_story_hero", content_block) }

    controller Decidim::PagesController

    around do |example|
      I18n.with_locale(:en) { example.run }
    end

    before do
      allow(controller).to receive(:current_organization).and_return(organization)
    end

    it "renders the story without an image" do
      expect(subject.to_s).to include("--eb-fg: #020203")
      expect(subject).to have_css("section.extra-blocks-split-story-hero--image-left")
      expect(subject).to have_content("Our platform")
      expect(subject).to have_content("Why we opened this space")
      expect(subject).to have_content("Citizens decide together.")
      expect(subject).to have_link("Learn more", href: "https://example.org/more")
      expect(subject).to have_css("a.button.button__lg.button__primary", text: "Learn more")
      expect(subject).to have_no_css("img.extra-blocks-split-story-hero__image")
    end
  end
end
