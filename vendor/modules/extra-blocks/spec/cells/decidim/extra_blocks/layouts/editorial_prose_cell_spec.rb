# frozen_string_literal: true

require "spec_helper"

module Decidim::ExtraBlocks::Layouts
  describe EditorialProseCell, type: :cell do
    subject { cell_instance.call }

    let(:organization) { create(:organization) }
    let(:settings) do
      {
        "layout" => "editorial_prose",
        "eyebrow" => { "en" => "Method note" },
        "title" => { "en" => "How participation works" },
        "body" => { "en" => "<p>We publish agendas and open debate.</p>" },
        "button_label" => { "en" => "Learn more" },
        "button_url" => "https://example.org/more",
        "image_position" => "below",
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
    let(:cell_instance) { cell("decidim/extra_blocks/layouts/editorial_prose", content_block) }

    controller Decidim::PagesController

    around do |example|
      I18n.with_locale(:en) { example.run }
    end

    before do
      allow(controller).to receive(:current_organization).and_return(organization)
    end

    it "renders the editorial section without an image" do
      expect(subject).to have_css("section.extra-blocks-editorial-prose--image-below[data-extra-blocks-category='text']")
      expect(subject).to have_css("p.extra-blocks__eyebrow.extra-blocks-editorial-prose__eyebrow", text: "Method note")
      expect(subject).to have_content("How participation works")
      expect(subject).to have_content("We publish agendas and open debate.")
      expect(subject).to have_link("Learn more", href: "https://example.org/more")
      expect(subject).to have_no_css("img.extra-blocks-editorial-prose__image")
    end
  end
end
