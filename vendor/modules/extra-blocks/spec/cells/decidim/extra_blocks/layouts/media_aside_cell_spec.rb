# frozen_string_literal: true

require "spec_helper"

module Decidim::ExtraBlocks::Layouts
  describe MediaAsideCell, type: :cell do
    subject { cell_instance.call }

    let(:organization) { create(:organization) }
    let(:settings) do
      {
        "layout" => "media_aside",
        "title" => { "en" => "A closer look" },
        "body" => { "en" => "<p>Context beside a photo.</p>" },
        "button_label" => { "en" => "Read the guide" },
        "button_url" => "https://example.org/guide",
        "image_side" => "left",
        "asides_json" => "",
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
    let(:cell_instance) { cell("decidim/extra_blocks/layouts/media_aside", content_block) }

    controller Decidim::PagesController

    around do |example|
      I18n.with_locale(:en) { example.run }
    end

    before do
      allow(controller).to receive(:current_organization).and_return(organization)
    end

    it "renders the media aside without an image" do
      expect(subject).to have_css("section.extra-blocks-media-aside--image-left[data-extra-blocks-category='text']")
      expect(subject).to have_css("h2.extra-blocks__title.not-prose", text: "A closer look")
      expect(subject).to have_content("Context beside a photo.")
      expect(subject).to have_link("Read the guide", href: "https://example.org/guide")
      expect(subject).to have_no_css("[data-extra-blocks-media-aside-slideshow]")
      expect(subject).to have_no_css("img.extra-blocks-media-aside__image")
    end
  end
end
