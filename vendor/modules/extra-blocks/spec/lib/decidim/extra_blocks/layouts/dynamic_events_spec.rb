# frozen_string_literal: true

require "spec_helper"

module Decidim::ExtraBlocks::Layouts
  describe DynamicEvents do
    describe ".parse_items" do
      it "returns an empty array for blank or invalid JSON" do
        expect(described_class.parse_items(nil)).to eq([])
        expect(described_class.parse_items("")).to eq([])
        expect(described_class.parse_items("{")).to eq([])
        expect(described_class.parse_items('"nope"')).to eq([])
      end

      it "keeps valid slots and casts highlighted" do
        raw = [
          { "slot" => 1, "highlighted" => true },
          { "slot" => 99, "highlighted" => true },
          { "slot" => 2, "highlighted" => "0" }
        ].to_json

        expect(described_class.parse_items(raw)).to eq(
          [
            { "slot" => 1, "highlighted" => true },
            { "slot" => 2, "highlighted" => false }
          ]
        )
      end
    end

    describe ".entries_for" do
      let(:organization) { create(:organization) }
      let(:events_json) { "" }
      let(:settings) do
        {
          "layout" => "impact_milestones",
          "event_1_title" => { "en" => "One" },
          "event_2_title" => { "en" => "Two" },
          "event_3_title" => { "en" => "" },
          "events_json" => events_json
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

      it "falls back to filled slots when events_json is blank" do
        entries = described_class.entries_for(content_block) do |slot|
          title = content_block.settings.public_send(:"event_#{slot}_title")
          described_class.translated_present?(title)
        end

        expect(entries).to eq(
          [
            { slot: 1, highlighted: false },
            { slot: 2, highlighted: false }
          ]
        )
      end

      context "when events_json is set" do
        let(:events_json) do
          [
            { "slot" => 2, "highlighted" => true },
            { "slot" => 1, "highlighted" => false }
          ].to_json
        end

        it "uses JSON order and highlighted" do
          entries = described_class.entries_for(content_block)

          expect(entries).to eq(
            [
              { slot: 2, highlighted: true },
              { slot: 1, highlighted: false }
            ]
          )
        end
      end
    end

    describe ".form_json_for_settings" do
      let(:organization) { create(:organization) }
      let(:content_block) do
        create(
          :content_block,
          organization:,
          manifest_name: :extra_block,
          scope_name: :homepage,
          settings: {
            "layout" => "impact_milestones",
            "event_1_title" => { "en" => "One" },
            "event_2_title" => { "en" => "" },
            "events_json" => ""
          }
        )
      end

      it "builds JSON from filled settings slots without an ERB block" do
        json = described_class.form_json_for_settings(content_block, content_block.settings)

        expect(JSON.parse(json)).to eq([{ "slot" => 1, "highlighted" => false }])
      end
    end
  end
end
