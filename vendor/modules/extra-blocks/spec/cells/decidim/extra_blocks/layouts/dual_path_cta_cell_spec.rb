# frozen_string_literal: true

require "spec_helper"

module Decidim::ExtraBlocks::Layouts
  describe DualPathCtaCell, type: :cell do
    subject { cell_instance.call }

    let(:organization) { create(:organization) }
    let(:settings) do
      {
        "layout" => "dual_path_cta",
        "title" => { "en" => "How will you take part?" },
        "primary_title" => { "en" => "Take part" },
        "primary_body" => { "en" => "<p>Submit a proposal.</p>" },
        "primary_button_label" => { "en" => "Propose" },
        "primary_button_url" => "https://example.org/propose",
        "secondary_title" => { "en" => "See results" },
        "secondary_body" => { "en" => "<p>Follow decisions.</p>" },
        "secondary_button_label" => { "en" => "Browse" },
        "secondary_button_url" => "https://example.org/results",
        "background_color" => "#f5f5f5",
        "text_color" => "black",
        "alignment" => "left",
        "primary_background_color" => "#ffffff",
        "primary_text_color" => "black",
        "secondary_background_color" => "#0f3460",
        "secondary_text_color" => "white"
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
    let(:cell_instance) { cell("decidim/extra_blocks/layouts/dual_path_cta", content_block) }

    controller Decidim::PagesController

    around do |example|
      I18n.with_locale(:en) { example.run }
    end

    before do
      allow(controller).to receive(:current_organization).and_return(organization)
    end

    it "renders both paths as linked cards with nested button spans" do
      expect(subject).to have_content("How will you take part?")
      expect(subject).to have_content("Take part")
      expect(subject).to have_content("See results")
      expect(subject).to have_link(class: "extra-blocks-dual-path-cta__path--primary", href: "https://example.org/propose")
      expect(subject).to have_link(class: "extra-blocks-dual-path-cta__path--secondary", href: "https://example.org/results")
      expect(subject).to have_css("a.extra-blocks-dual-path-cta__path span.button.button__lg.button__primary", text: "Propose")
      expect(subject).to have_css("a.extra-blocks-dual-path-cta__path span.button.button__lg.button__primary", text: "Browse")
      expect(subject).to have_no_css("a.extra-blocks-dual-path-cta__path a")
      expect(subject).to have_css("a.extra-blocks-dual-path-cta__path--primary.prose:not(.prose-invert)")
      expect(subject).to have_css("a.extra-blocks-dual-path-cta__path--secondary.prose-invert")
      expect(subject).to have_css("h2.extra-blocks__title.extra-blocks-dual-path-cta__title.prose")
      expect(subject).to have_no_css("h2.extra-blocks-dual-path-cta__title.prose-invert")
      expect(subject).to have_no_css("section.extra-blocks-dual-path-cta.prose-invert")
      expect(subject.to_s).to include("--eb-fg: #020203")
      expect(subject.to_s).to include("--eb-path-bg: #ffffff")
      expect(subject.to_s).to include("--eb-path-fg: #020203")
      expect(subject.to_s).to include("--eb-path-bg: #0f3460")
      expect(subject.to_s).to include("--eb-path-fg: #ffffff")
      expect(subject.to_s).to include("extra-blocks-dual-path-cta--align-left")
    end

    context "with center alignment" do
      let(:settings) { super().merge("alignment" => "center") }

      it "applies the center alignment class" do
        expect(subject.to_s).to include("extra-blocks-dual-path-cta--align-center")
      end
    end

    context "without path URLs" do
      let(:settings) do
        super().merge(
          "primary_button_url" => "",
          "secondary_button_url" => ""
        )
      end

      it "renders paths as unlinked cards" do
        expect(subject).to have_css("div.extra-blocks-dual-path-cta__path--primary")
        expect(subject).to have_css("div.extra-blocks-dual-path-cta__path--secondary")
        expect(subject).to have_no_css("a.extra-blocks-dual-path-cta__path")
      end
    end

    context "with background image" do
      before do
        blob = ActiveStorage::Blob.create_and_upload!(
          io: File.open(Decidim::Dev.asset("city.jpeg")),
          filename: "dual-path.jpeg",
          content_type: "image/jpeg"
        )
        content_block.images_container.background_image = blob
        content_block.images_container.save
        content_block.save!
      end

      it "renders a full-width picture with proxy srcset" do
        expect(subject).to have_css("img.extra-blocks-dual-path-cta__image")
        html = subject.native.to_html
        expect(html).to include("/rails/active_storage/")
        expect(html).to include("proxy")
        expect(html).to match(/1x|2x|3x/)
      end
    end
  end
end
