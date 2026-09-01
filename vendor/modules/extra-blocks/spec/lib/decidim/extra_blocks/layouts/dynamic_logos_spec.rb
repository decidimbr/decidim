# frozen_string_literal: true

require "spec_helper"

module Decidim::ExtraBlocks::Layouts
  describe DynamicLogos do
    describe ".parse_items" do
      it "returns an empty array for blank or invalid JSON" do
        expect(described_class.parse_items(nil)).to eq([])
        expect(described_class.parse_items("")).to eq([])
        expect(described_class.parse_items("{")).to eq([])
        expect(described_class.parse_items('"nope"')).to eq([])
      end

      it "keeps valid slots and normalizes alt text" do
        raw = [
          { "slot" => 1, "alt" => { "en" => "Acme" } },
          { "slot" => 99, "alt" => { "en" => "Skip" } },
          { "slot" => 2, "alt" => " Beta " },
          { "slot" => 3, "alt" => "" }
        ].to_json

        expect(described_class.parse_items(raw)).to eq(
          [
            { "slot" => 1, "alt" => { "en" => "Acme" } },
            { "slot" => 2, "alt" => { "en" => "Beta" } },
            { "slot" => 3, "alt" => {} }
          ]
        )
      end
    end

    describe ".items_for" do
      let(:organization) { create(:organization) }
      let(:content_block) do
        create(
          :content_block,
          organization:,
          manifest_name: :extra_block,
          scope_name: :homepage,
          settings: {
            "layout" => "logo_showcase",
            "logos_json" => [
              { "slot" => 2, "alt" => { "en" => "Second" } },
              { "slot" => 1, "alt" => { "en" => "First" } }
            ].to_json
          }
        )
      end

      def attach_logo(slot, filename)
        blob = ActiveStorage::Blob.create_and_upload!(
          io: File.open(Decidim::Dev.asset("city.jpeg")),
          filename:,
          content_type: "image/jpeg"
        )
        content_block.images_container.public_send(:"logo_#{slot}=", blob)
        content_block.save!
      end

      it "returns only attached logos in JSON order" do
        attach_logo(1, "logo-one.jpeg")
        attach_logo(2, "logo-two.jpeg")

        items = described_class.items_for(content_block.reload)

        expect(items.map { |item| item[:slot] }).to eq([2, 1])
        expect(items.map { |item| item[:alt] }).to eq(%w(Second First))
        expect(items).to all(include(:uploader))
      end

      it "skips JSON entries without an attachment" do
        attach_logo(1, "logo-one.jpeg")

        items = described_class.items_for(content_block.reload)

        expect(items.map { |item| item[:slot] }).to eq([1])
      end
    end
  end
end
