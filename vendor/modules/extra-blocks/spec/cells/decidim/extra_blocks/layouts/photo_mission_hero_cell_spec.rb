# frozen_string_literal: true

require "spec_helper"

module Decidim::ExtraBlocks::Layouts
  describe PhotoMissionHeroCell, type: :cell do
    subject { cell_instance.call }

    let(:organization) { create(:organization) }
    let(:settings) do
      {
        "layout" => "photo_mission_hero",
        "eyebrow" => { "en" => "City of Demo" },
        "title" => { "en" => "Your voice shapes the city" },
        "tagline" => { "en" => "Participate in open decisions." },
        "button_label" => { "en" => "Learn more" },
        "button_url" => "https://example.org/more",
        "overlay_strength" => "dark",
        "size" => "large",
        "background_color" => "#112233",
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
    let(:cell_instance) { cell("decidim/extra_blocks/layouts/photo_mission_hero", content_block) }

    controller Decidim::PagesController

    around do |example|
      I18n.with_locale(:en) { example.run }
    end

    before do
      allow(controller).to receive(:current_organization).and_return(organization)
    end

    it "renders mission content without an image" do
      html = subject.to_s
      expect(html).to include("--eb-bg: #112233")
      expect(html).to include("--eb-fg: #ffffff")
      expect(html).not_to include("--eb-bg-image")
      expect(subject).to have_css("section.extra-blocks-photo-mission-hero.prose.prose-invert")
      expect(subject).to have_css("section.extra-blocks-photo-mission-hero--overlay-dark")
      expect(subject).to have_css("section.extra-blocks-photo-mission-hero--size-large")
      expect(subject).to have_content("City of Demo")
      expect(subject).to have_content("Your voice shapes the city")
      expect(subject).to have_content("Participate in open decisions.")
      expect(subject).to have_link("Learn more", href: "https://example.org/more")
      expect(subject).to have_css("a.button.button__lg.button__transparent", text: "Learn more")
    end

    context "with background image" do
      before do
        blob = ActiveStorage::Blob.create_and_upload!(
          io: StringIO.new("fake-png"),
          filename: "mission.png",
          content_type: "image/png"
        )
        content_block.images_container.background_image = blob
        content_block.save!
      end

      it "renders a full-width picture with proxy srcset" do
        html = subject.to_s
        expect(html).not_to include("--eb-bg-image")
        expect(html).to include("<picture")
        expect(html).to include("extra-blocks__media")
        expect(html).to include("extra-blocks-photo-mission-hero__image")
        expect(html).to include("/rails/active_storage/")
        expect(html).to include("proxy")
        expect(html).not_to include("/blobs/redirect/")
        expect(html).to match(/1x|2x|3x/)
      end
    end

    context "with SVG background" do
      before do
        blob = ActiveStorage::Blob.create_and_upload!(
          io: File.open(Decidim::ExtraBlocks::Engine.root.join("lib/seeds/logo_2.svg")),
          filename: "logo_2.svg",
          content_type: "image/svg+xml"
        )
        content_block.images_container.background_image = blob
        content_block.save!
      end

      it "renders a section child img, not picture" do
        expect(subject).to have_css("section.extra-blocks-photo-mission-hero > img")
        expect(subject).not_to have_css("section.extra-blocks-photo-mission-hero > picture")
        expect(subject).to have_css("img.extra-blocks-photo-mission-hero__image")
      end
    end

    context "with background_fit contain" do
      let(:settings) { super().merge("background_fit" => "contain") }

      it "exposes the fit as a CSS custom property" do
        expect(subject.to_s).to include("--eb-bg-fit: contain")
      end
    end

    it "uses EXTRA_BLOCK_MAX_CACHE for fragment expiry" do
      allow(Decidim::ExtraBlocks).to receive(:max_cache).and_return(15.minutes)
      expect(cell_instance.send(:cache_expiry_time)).to eq(15.minutes)
      expect(cell_instance.send(:cache_hash)).to be_present
    end
  end
end
