# frozen_string_literal: true

require "spec_helper"

module Decidim
  module ExtraBlocks
    describe LayoutImageUploader do
      subject { described_class.new(double, :background_image) }

      it "allowlists common image formats" do
        expect(subject.extension_allowlist).to eq(%w(jpeg jpg png webp svg))
        expect(subject.content_type_allowlist).to include("image/jpeg", "image/png", "image/webp", "image/svg+xml")
      end

      it "detects SVG by content type or extension" do
        expect(described_class.svg?(double(content_type: "image/svg+xml", filename: "mark.png"))).to be(true)
        expect(described_class.svg?(double(content_type: "image/png", filename: "logo.svg"))).to be(true)
        expect(described_class.svg?(double(content_type: "image/png", filename: "logo.png"))).to be(false)
      end

      it "defines fixed and full-width variants plus webp mirrors" do
        expect(subject.variants.keys).to include(
          :w600, :w900, :w1200, :d1x, :d2x, :d3x,
          :w600_webp, :w900_webp, :w1200_webp, :d1x_webp, :d2x_webp, :d3x_webp
        )
        expect(subject.variants[:w600]).to eq(resize_to_limit: [600, nil])
        expect(subject.variants[:d2x]).to eq(resize_to_limit: [2560, nil])
        expect(subject.variants[:w600_webp]).to include(convert: :webp, format: :webp)
      end

      it "bakes ImageCapabilities.webp_saver into webp variants at load" do
        # set_variants yields once at class load; content must match current capability probe.
        expect(subject.variants[:w1200_webp][:saver]).to eq(ImageCapabilities.webp_saver)
      end

      it "treats an images_container SVG as svg without dimension validation" do
        organization = create(:organization)
        content_block = create(
          :content_block,
          organization:,
          manifest_name: :extra_block,
          scope_name: :homepage,
          settings: { "layout" => "trust_quote_cta" }
        )
        blob = ActiveStorage::Blob.create_and_upload!(
          io: File.open(Decidim::ExtraBlocks::Engine.root.join("lib/seeds/logo_2.svg")),
          filename: "logo_2.svg",
          content_type: "image/svg+xml"
        )
        content_block.images_container.portrait = blob
        content_block.save!
        uploader = content_block.images_container.attached_uploader(:portrait)

        expect(uploader.svg?).to be(true)
        expect(uploader.validable_dimensions).to be(false)
      end
    end
  end
end
