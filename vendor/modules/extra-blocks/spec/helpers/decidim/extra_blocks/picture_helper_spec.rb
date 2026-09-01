# frozen_string_literal: true

require "spec_helper"

module Decidim
  module ExtraBlocks
    describe PictureHelper do
      include described_class

      let(:organization) { create(:organization) }
      let(:content_block) do
        create(
          :content_block,
          organization:,
          manifest_name: :extra_block,
          scope_name: :homepage,
          settings: { "layout" => "trust_quote_cta" }
        )
      end
      let(:blob) do
        ActiveStorage::Blob.create_and_upload!(
          io: StringIO.new("fake-png-bytes"),
          filename: "portrait.png",
          content_type: "image/png"
        )
      end
      let(:uploader) do
        content_block.images_container.portrait = blob
        content_block.save!
        content_block.images_container.attached_uploader(:portrait)
      end

      before do
        allow(ImageCapabilities).to receive(:vips_webp?).and_return(false)
      end

      it "renders a picture tag with fixed width srcset and proxy URLs" do
        html = extra_blocks_picture_tag(uploader, mode: :fixed, class: "portrait", alt: "Alex")

        expect(html).to include('<picture class="not-prose">')
        expect(html).to include('class="portrait not-prose"')
        expect(html).to include('alt="Alex"')
        expect(html).to include("600w")
        expect(html).to include("900w")
        expect(html).to include("1200w")
        expect(html).to include("/rails/active_storage/")
        expect(html).to include("proxy")
        expect(html).not_to include("/blobs/redirect/")
        expect(html).not_to include('type="image/webp"')
      end

      it "adds webp sources when vips webp is available" do
        allow(ImageCapabilities).to receive(:vips_webp?).and_return(true)
        html = extra_blocks_picture_tag(uploader, mode: :fixed, alt: "")

        expect(html).to include('type="image/webp"')
        expect(html).to include('<picture class="not-prose">')
        expect(html).to include('class="not-prose"')
      end

      it "renders a plain img for SVG without picture or srcset" do
        svg_blob = ActiveStorage::Blob.create_and_upload!(
          io: File.open(Decidim::ExtraBlocks::Engine.root.join("lib/seeds/logo_2.svg")),
          filename: "logo_2.svg",
          content_type: "image/svg+xml"
        )
        content_block.images_container.portrait = svg_blob
        content_block.save!
        svg_uploader = content_block.images_container.attached_uploader(:portrait)

        html = extra_blocks_picture_tag(svg_uploader, mode: :fixed, class: "logo", alt: "Mark")

        expect(html).to include("<img")
        expect(html).to include('class="logo not-prose"')
        expect(html).to include('alt="Mark"')
        expect(html).to include("/rails/active_storage/")
        expect(html).not_to include("<picture")
        expect(html).not_to include("srcset")
      end
    end
  end
end
