# frozen_string_literal: true

require "spec_helper"

module Decidim::ExtraBlocks::Layouts
  describe LayoutRegistry do
    it "registers default layouts" do
      expect(described_class.find(:verbose_cta)).to be_present
      expect(described_class.find(:dual_path_cta)).to be_present
      expect(described_class.find(:join_steps_cta)).to be_present
      expect(described_class.find(:trust_quote_cta)).to be_present
      expect(described_class.find(:video_hero)).to be_present
      expect(described_class.find(:photo_mission_hero)).to be_present
      expect(described_class.find(:split_story_hero)).to be_present
      expect(described_class.find(:outcome_stats_hero)).to be_present
      expect(described_class.find(:focused_quick_proposal)).to be_present
      expect(described_class.find(:split_fast_proposal)).to be_present
      expect(described_class.find(:video_fast_proposal)).to be_present
      expect(described_class.find(:proposals_aside_fast_proposal)).to be_present
      expect(described_class.find(:editorial_prose)).to be_present
      expect(described_class.find(:media_aside)).to be_present
      expect(described_class.find(:topic_trio)).to be_present
      expect(described_class.find(:spacer)).to be_present
      expect(described_class.find(:image)).to be_present
      expect(described_class.find(:video)).to be_present
      expect(described_class.find(:logo_showcase)).to be_present
      expect(described_class.find(:brand_story)).to be_present
      expect(described_class.find(:roadmap)).to be_present
      expect(described_class.find(:product_roadmap)).to eq(described_class.find(:roadmap))
      expect(described_class.find(:impact_milestones)).to be_present
    end

    it "groups layouts by category" do
      expect(described_class.for_category(:cta).map(&:name)).to include(
        :verbose_cta, :dual_path_cta, :join_steps_cta, :trust_quote_cta
      )
      expect(described_class.for_category(:hero).map(&:name)).to include(
        :video_hero, :photo_mission_hero, :split_story_hero, :outcome_stats_hero
      )
      expect(described_class.for_category(:text).map(&:name)).to include(
        :editorial_prose, :media_aside, :topic_trio
      )
      expect(described_class.for_category(:fast_proposal).map(&:name)).to include(
        :focused_quick_proposal, :split_fast_proposal, :video_fast_proposal, :proposals_aside_fast_proposal
      )
      expect(described_class.for_category(:misc).map(&:name)).to include(
        :spacer, :image, :video, :logo_showcase
      )
      expect(described_class.for_category(:timelines).map(&:name)).to include(
        :brand_story, :roadmap, :impact_milestones
      )
    end

    it "exposes preview and three screenshots" do
      layout = described_class.find(:verbose_cta)
      expect(layout.preview_image).to be_present
      expect(layout.screenshots.size).to eq(3)
    end

    it "merges settings into a settings manifest without duplicates" do
      settings = Decidim::SettingsManifest.new
      settings.attribute :layout, type: :string
      described_class.merge_settings!(settings)

      expect(settings.attributes).to include(
        :background_color, :title, :body, :title_position, :button_url,
        :tagline, :quote, :primary_title, :step_1_title, :stat_1_value,
        :proposal_component_id, :default_title, :default_title_connected,
        :form_side, :eyebrow,
        :image_position, :topic_1_title, :spacer_height, :media_width,
        :event_1_date, :event_1_title, :event_1_body, :event_1_button_label, :event_1_button_url,
        :logos_json, :events_json, :topics_json, :steps_json, :stats_json, :asides_json,
        :background_fit
      )
      expect(settings.attributes[:background_color].type).to eq(:string)
    end

    it "collects unique images from layouts" do
      images = described_class.all_images
      expect(images.map { |image| image[:name] }).to include(
        :background_video_webm, :background_video, :background_image, :side_image, :portrait,
        :lead_image, :aside_1_image, :aside_2_image, :aside_3_image, :aside_6_image,
        :topic_1_image, :topic_2_image, :topic_3_image, :topic_6_image, :block_image,
        :event_1_image, :event_5_image, :logo_1, :logo_12
      )
    end

    it "declares background_fit on layouts with a background image" do
      [
        :dual_path_cta, :join_steps_cta, :photo_mission_hero,
        :focused_quick_proposal, :split_fast_proposal, :proposals_aside_fast_proposal
      ].each do |name|
        attribute = described_class.find(name).settings.attributes[:background_fit]
        expect(attribute.type).to eq(:enum)
        expect(attribute.default).to eq("cover")
        expect(attribute.build_choices).to eq(RegisterDefaults::BACKGROUND_FITS)
      end
    end
  end
end
