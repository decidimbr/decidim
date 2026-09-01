# frozen_string_literal: true

require "spec_helper"

module Decidim
  module ExtraBlocks
    describe Seeds do
      describe "#logo_media" do
        subject { described_class.new.send(:logo_media) }

        it "globs seed logos as logo_*" do
          files = subject.transform_keys(&:to_s)
          expect(files).to include("logo_1" => "logo_1.svg")
          expect(files).to include("logo_2" => "logo_2.svg")
          expect(files.values).to all(match(/\Alogo_\d+\.[A-Za-z0-9]+\z/))
          expect(files.values.map { |name| File.extname(name).delete(".").downcase }).to include(
            "svg", "png", "jpeg", "jpg"
          )
        end
      end

      describe "MEDIA" do
        subject { described_class::MEDIA }

        it "uses renamed portraits and group photo" do
          expect(subject[:trust_quote_cta][:portrait]).to eq("portrait_1.jpg")
          expect(subject[:media_aside][:aside_3_image]).to eq("portrait_2.jpg")
          expect(subject[:split_story_hero][:side_image]).to eq("group_picture.jpg")
          expect(subject[:topic_trio][:topic_2_image]).to eq("group_picture.jpg")
          expect(subject[:brand_story][:event_2_image]).to eq("group_picture.jpg")
        end

        it "keeps remaining photos and videos" do
          expect(subject[:media_aside][:aside_1_image]).to eq("together-1.jpg")
          expect(subject[:editorial_prose][:lead_image]).to eq("benches.jpg")
          expect(subject[:media_aside][:aside_2_image]).to eq("benches-1.jpg")
          expect(subject[:video_hero][:background_video_webm]).to eq("video-1.webm")
          expect(subject[:video_hero][:background_video]).to eq("video-1.mp4")
        end

        it "mixes raster pictures and SVG patterns on background_image slots" do
          expect(subject[:dual_path_cta][:background_image]).to eq("bg_gradient.jpg")
          expect(subject[:join_steps_cta][:background_image]).to eq("bg_city.jpg")
          expect(subject[:focused_quick_proposal][:background_image]).to eq("bg_abstract.jpg")
          expect(subject[:photo_mission_hero][:background_image]).to eq("pattern_3.svg")
          expect(subject[:split_fast_proposal][:background_image]).to eq("pattern_5.svg")
          expect(subject[:proposals_aside_fast_proposal][:background_image]).to eq("pattern_6.svg")
        end
      end

      describe "#settings_for" do
        subject(:seeds) { described_class.new }

        let(:organization) { create(:organization) }
        let(:component) { instance_double(Decidim::Component, id: 1) }

        before { allow(seeds).to receive(:organization).and_return(organization) }

        it "uses cover on raster backgrounds and contain on SVG backgrounds" do
          [:dual_path_cta, :join_steps_cta, :focused_quick_proposal].each do |layout|
            expect(seeds.settings_for(layout, component)).to include("background_fit" => "cover")
          end
          [:photo_mission_hero, :split_fast_proposal, :proposals_aside_fast_proposal].each do |layout|
            expect(seeds.settings_for(layout, component)).to include("background_fit" => "contain")
          end
        end

        it "seeds dual_path cards with contrasting fill and text" do
          expect(seeds.settings_for(:dual_path_cta, component)).to include(
            "primary_background_color" => "#ffffff",
            "primary_text_color" => "black",
            "secondary_background_color" => "#155abf",
            "secondary_text_color" => "white"
          )
        end
      end
    end
  end
end
