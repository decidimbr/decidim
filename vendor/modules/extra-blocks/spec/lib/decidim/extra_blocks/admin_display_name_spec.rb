# frozen_string_literal: true

require "spec_helper"

describe Decidim::ExtraBlocks::AdminDisplayName do
  let(:organization) { create(:organization) }

  describe ".for" do
    it "returns Extra Block with layout when frozen" do
      content_block = create(
        :content_block,
        organization:,
        manifest_name: :extra_block,
        scope_name: :homepage,
        settings: { "layout" => "verbose_cta" }
      )

      expect(described_class.for(content_block)).to eq("Verbose CTA (Extra Block)")
    end

    it "resolves the product_roadmap alias to Roadmap" do
      content_block = create(
        :content_block,
        organization:,
        manifest_name: :extra_block,
        scope_name: :homepage,
        settings: { "layout" => "product_roadmap" }
      )

      expect(described_class.for(content_block)).to eq("Roadmap (Extra Block)")
    end

    it "returns Extra Block when layout is blank" do
      content_block = create(
        :content_block,
        organization:,
        manifest_name: :extra_block,
        scope_name: :homepage,
        settings: { "layout" => nil }
      )

      expect(described_class.for(content_block)).to eq("Extra Block")
    end

    it "returns the manifest name for other content blocks" do
      content_block = create(
        :content_block,
        organization:,
        manifest_name: :hero,
        scope_name: :homepage
      )

      expect(described_class.for(content_block)).to eq(I18n.t(content_block.public_name_key))
    end
  end
end
