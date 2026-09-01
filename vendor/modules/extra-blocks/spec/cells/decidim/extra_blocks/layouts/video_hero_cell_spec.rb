# frozen_string_literal: true

require "spec_helper"

module Decidim::ExtraBlocks::Layouts
  describe VideoHeroCell, type: :cell do
    subject { cell_instance.call }

    let(:organization) { create(:organization) }
    let(:settings) do
      {
        "layout" => "video_hero",
        "eyebrow" => { "en" => "Live from the square" },
        "title" => { "en" => "Hero title" },
        "title_position" => "middle_center",
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
    let(:cell_instance) { cell("decidim/extra_blocks/layouts/video_hero", content_block) }

    controller Decidim::PagesController

    around do |example|
      I18n.with_locale(:en) { example.run }
    end

    before do
      allow(controller).to receive(:current_organization).and_return(organization)
    end

    it "falls back to background color when no video is attached" do
      html = subject.to_s
      expect(html).to include("--eb-bg: #112233")
      expect(html).to include("--eb-fg: #ffffff")
      expect(subject).to have_css("section.extra-blocks-video-hero.prose.prose-invert")
      expect(subject).to have_css("p.extra-blocks__eyebrow.extra-blocks-video-hero__eyebrow", text: "Live from the square")
      expect(subject).to have_css("div.extra-blocks-video-hero__content--middle_center")
      expect(html).not_to include("<video")
      expect(html).not_to include("<source")
      expect(subject).to have_no_css(".extra-blocks-video-hero__button")
    end

    context "with a call to action" do
      let(:settings) do
        super().merge(
          "button_label" => { "en" => "Take part" },
          "button_url" => "https://example.org/join"
        )
      end

      it "renders a transparent overlay button" do
        expect(subject).to have_css(
          "a.button.button__lg.button__transparent.extra-blocks-video-hero__button",
          text: "Take part"
        )
        expect(subject).to have_link("Take part", href: "https://example.org/join")
      end
    end

    context "with black text color" do
      let(:settings) do
        super().merge("text_color" => "black")
      end

      it "uses prose without invert" do
        expect(subject).to have_css("section.extra-blocks-video-hero.prose")
        expect(subject).to have_no_css("section.prose-invert")
        expect(subject.to_s).to include("--eb-fg: #020203")
      end
    end

    context "with mp4 only" do
      before do
        blob = ActiveStorage::Blob.create_and_upload!(
          io: StringIO.new("fake-mp4"),
          filename: "hero.mp4",
          content_type: "video/mp4"
        )
        content_block.images_container.background_video = blob
        content_block.save!
      end

      it "renders a single mp4 source" do
        expect(subject).to have_css("video.extra-blocks-video-hero__video")
        expect(subject).to have_css("source[type='video/mp4']")
        expect(subject).to have_no_css("source[type='video/webm']")
        expect(subject).to have_no_css("video[autoplay]")
      end
    end

    context "with webm and mp4" do
      before do
        webm = ActiveStorage::Blob.create_and_upload!(
          io: StringIO.new("fake-webm"),
          filename: "hero.webm",
          content_type: "video/webm"
        )
        mp4 = ActiveStorage::Blob.create_and_upload!(
          io: StringIO.new("fake-mp4"),
          filename: "hero.mp4",
          content_type: "video/mp4"
        )
        content_block.images_container.background_video_webm = webm
        content_block.images_container.background_video = mp4
        content_block.save!
      end

      it "renders webm before mp4" do
        sources = subject.to_s.scan(%r{type="(video/[^"]+)"}).flatten
        expect(sources).to eq(%w(video/webm video/mp4))
      end
    end
  end
end
