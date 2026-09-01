# frozen_string_literal: true

require "spec_helper"

module Decidim::ExtraBlocks
  describe ContentBlocks::ExtraBlockCell, type: :cell do
    subject { cell_instance.call }

    let(:organization) { create(:organization) }
    let(:settings) do
      {
        "layout" => "verbose_cta",
        "title" => { "en" => "Join us" },
        "body" => { "en" => "<p>Welcome</p>" },
        "button_label" => { "en" => "Participate" },
        "button_url" => "https://example.org/join",
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
    let(:cell_instance) { cell(content_block.cell, content_block) }

    controller Decidim::PagesController

    before do
      I18n.locale = :en
      allow(controller).to receive(:current_organization).and_return(organization)
    end

    it "renders the verbose CTA layout" do
      expect(subject).to have_css("section.extra-blocks-verbose-cta.prose.prose-invert")
      expect(subject.to_s).to include("--eb-bg: #112233")
      expect(subject.to_s).to include("--eb-fg: #ffffff")
      expect(subject).to have_content("Join us")
      expect(subject).to have_content("Welcome")
      expect(subject).to have_link("Participate", href: "https://example.org/join")
    end

    it "builds a cache hash including layout and locale" do
      hash = cell_instance.send(:cache_hash)
      expect(hash).to include("verbose_cta")
      expect(hash).to include("en")
      expect(hash).to include(organization.cache_key_with_version)
    end

    it "uses EXTRA_BLOCK_MAX_CACHE for fragment expiry" do
      allow(Decidim::ExtraBlocks).to receive(:max_cache).and_return(42.minutes)
      expect(cell_instance.send(:cache_expiry_time)).to eq(42.minutes)
    end

    context "when layout is blank" do
      let(:settings) { { "layout" => nil } }

      it "renders nothing meaningful" do
        html = cell_instance.call.to_s
        expect(html).not_to include("extra-blocks-verbose-cta")
        expect(html).not_to include("extra-blocks-video-hero")
      end
    end

    context "with photo mission hero layout" do
      let(:settings) do
        {
          "layout" => "photo_mission_hero",
          "title" => { "en" => "Mission" },
          "tagline" => { "en" => "Local democracy" },
          "background_color" => "#112233",
          "text_color" => "white",
          "overlay_strength" => "medium"
        }
      end

      it "renders the photo mission hero layout" do
        expect(subject).to have_css("section.extra-blocks-photo-mission-hero.prose.prose-invert")
        expect(subject).to have_content("Mission")
      end

      it "includes background image checksum in the cache hash when attached" do
        blob = ActiveStorage::Blob.create_and_upload!(
          io: StringIO.new("fake-png"),
          filename: "mission.png",
          content_type: "image/png"
        )
        content_block.images_container.background_image = blob
        content_block.save!

        hash = cell_instance.send(:cache_hash)
        expect(hash).to include(blob.checksum)
      end
    end
  end
end
