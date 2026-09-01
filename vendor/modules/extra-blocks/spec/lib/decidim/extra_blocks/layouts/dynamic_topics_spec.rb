# frozen_string_literal: true

require "spec_helper"

module Decidim::ExtraBlocks::Layouts
  describe DynamicTopics do
    describe ".parse_items" do
      it "keeps valid slots only" do
        raw = [{ "slot" => 2 }, { "slot" => 99 }, { "slot" => 1 }].to_json
        expect(described_class.parse_items(raw)).to eq([{ "slot" => 2 }, { "slot" => 1 }])
      end
    end

    describe ".entries_for" do
      let(:organization) { create(:organization) }
      let(:topics_json) { "" }
      let(:content_block) do
        create(
          :content_block,
          organization:,
          manifest_name: :extra_block,
          scope_name: :homepage,
          settings: {
            "layout" => "topic_trio",
            "topic_1_title" => { "en" => "One" },
            "topic_2_title" => { "en" => "Two" },
            "topic_3_title" => { "en" => "" },
            "topics_json" => topics_json
          }
        )
      end

      it "falls back to filled slots when topics_json is blank" do
        entries = described_class.entries_for(content_block) do |slot|
          described_class.translated_present?(content_block.settings.public_send(:"topic_#{slot}_title"))
        end

        expect(entries).to eq([{ slot: 1 }, { slot: 2 }])
      end

      context "when topics_json is set" do
        let(:topics_json) { [{ "slot" => 2 }, { "slot" => 1 }].to_json }

        it "uses JSON order" do
          expect(described_class.entries_for(content_block)).to eq([{ slot: 2 }, { slot: 1 }])
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
            "layout" => "topic_trio",
            "topic_1_title" => { "en" => "One" },
            "topics_json" => ""
          }
        )
      end

      it "builds JSON from filled settings slots" do
        json = described_class.form_json_for_settings(content_block, content_block.settings)
        expect(JSON.parse(json)).to eq([{ "slot" => 1 }])
      end
    end
  end

  describe DynamicSteps do
    it "exposes a six-slot ceiling" do
      expect(described_class::SLOT_COUNT).to eq(6)
      expect(described_class::JSON_ATTRIBUTE).to eq(:steps_json)
    end
  end

  describe DynamicStats do
    it "exposes a six-slot ceiling" do
      expect(described_class::SLOT_COUNT).to eq(6)
      expect(described_class::JSON_ATTRIBUTE).to eq(:stats_json)
    end
  end

  describe DynamicAsides do
    it "exposes a six-slot ceiling" do
      expect(described_class::SLOT_COUNT).to eq(6)
      expect(described_class::JSON_ATTRIBUTE).to eq(:asides_json)
    end
  end
end
