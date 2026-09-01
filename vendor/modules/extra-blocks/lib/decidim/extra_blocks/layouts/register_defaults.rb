# frozen_string_literal: true

module Decidim
  module ExtraBlocks
    module Layouts
      module RegisterDefaults
        module_function

        TITLE_POSITIONS = %w(
          top_left top_center top_right
          middle_left middle_center middle_right
          bottom_left bottom_center bottom_right
        ).freeze

        OVERLAY_STRENGTHS = %w(light medium dark).freeze
        IMAGE_SIDES = %w(left right).freeze
        IMAGE_POSITIONS = %w(above below).freeze
        SIZES = %w(small medium large).freeze
        MEDIA_WIDTHS = %w(full boxed).freeze
        BACKGROUND_FITS = %w(cover contain fill none scale-down).freeze
        SPACER_HEIGHTS = %w(1rem 3rem 5rem).freeze
        TIMELINE_EVENT_COUNT = DynamicEvents::SLOT_COUNT
        TOPIC_COUNT = DynamicTopics::SLOT_COUNT
        STEP_COUNT = DynamicSteps::SLOT_COUNT
        STAT_COUNT = DynamicStats::SLOT_COUNT
        ASIDE_COUNT = DynamicAsides::SLOT_COUNT

        def call
          return if LayoutRegistry.names.any?

          register_verbose_cta!
          register_dual_path_cta!
          register_join_steps_cta!
          register_trust_quote_cta!
          register_video_hero!
          register_photo_mission_hero!
          register_split_story_hero!
          register_outcome_stats_hero!
          register_focused_quick_proposal!
          register_split_fast_proposal!
          register_video_fast_proposal!
          register_proposals_aside_fast_proposal!
          register_editorial_prose!
          register_media_aside!
          register_topic_trio!
          register_spacer!
          register_image!
          register_video!
          register_logo_showcase!
          register_brand_story!
          register_roadmap!
          register_impact_milestones!
        end

        def register_verbose_cta!
          LayoutRegistry.register(:verbose_cta) do |layout|
            layout.category = :cta
            layout.public_name_key = "decidim.extra_blocks.layouts.verbose_cta.name"
            layout.description_key = "decidim.extra_blocks.layouts.verbose_cta.description"
            layout.preview_image = "media/images/verbose_cta.png"
            layout.screenshots = [
              "media/images/verbose_cta_1.png",
              "media/images/verbose_cta_2.png",
              "media/images/verbose_cta_3.png"
            ]
            layout.cell = "decidim/extra_blocks/layouts/verbose_cta"
            layout.settings_form_cell = "decidim/extra_blocks/layouts/verbose_cta_settings_form"

            layout.settings do |settings|
              settings.attribute :background_color, type: :string, default: "#020203"
              settings.attribute :text_color, type: :enum, default: "white", choices: %w(white black)
              settings.attribute :title, type: :text, translated: true
              settings.attribute :body, type: :text, translated: true, editor: true
              settings.attribute :button_label, type: :string, translated: true
              settings.attribute :button_url, type: :string
            end
          end
        end

        def register_dual_path_cta!
          LayoutRegistry.register(:dual_path_cta) do |layout|
            layout.category = :cta
            layout.public_name_key = "decidim.extra_blocks.layouts.dual_path_cta.name"
            layout.description_key = "decidim.extra_blocks.layouts.dual_path_cta.description"
            layout.preview_image = "media/images/dual_path_cta.png"
            layout.screenshots = [
              "media/images/dual_path_cta_1.png",
              "media/images/dual_path_cta_2.png",
              "media/images/dual_path_cta_3.png"
            ]
            layout.cell = "decidim/extra_blocks/layouts/dual_path_cta"
            layout.settings_form_cell = "decidim/extra_blocks/layouts/dual_path_cta_settings_form"

            layout.images = [
              {
                name: :background_image,
                uploader: "Decidim::ExtraBlocks::LayoutImageUploader"
              }
            ]

            layout.settings do |settings|
              settings.attribute :background_color, type: :string, default: "#FAFBFC"
              settings.attribute :text_color, type: :enum, default: "black", choices: %w(white black)
              settings.attribute :background_fit, type: :enum, default: "cover", choices: BACKGROUND_FITS
              settings.attribute :alignment, type: :enum, default: "left", choices: %w(left center)
              settings.attribute :title, type: :text, translated: true
              settings.attribute :primary_background_color, type: :string, default: "#ffffff"
              settings.attribute :primary_text_color, type: :enum, default: "black", choices: %w(white black)
              settings.attribute :primary_title, type: :text, translated: true
              settings.attribute :primary_body, type: :text, translated: true, editor: true
              settings.attribute :primary_button_label, type: :string, translated: true
              settings.attribute :primary_button_url, type: :string
              settings.attribute :secondary_background_color, type: :string, default: "#020203"
              settings.attribute :secondary_text_color, type: :enum, default: "white", choices: %w(white black)
              settings.attribute :secondary_title, type: :text, translated: true
              settings.attribute :secondary_body, type: :text, translated: true, editor: true
              settings.attribute :secondary_button_label, type: :string, translated: true
              settings.attribute :secondary_button_url, type: :string
            end
          end
        end

        def register_join_steps_cta!
          LayoutRegistry.register(:join_steps_cta) do |layout|
            layout.category = :cta
            layout.public_name_key = "decidim.extra_blocks.layouts.join_steps_cta.name"
            layout.description_key = "decidim.extra_blocks.layouts.join_steps_cta.description"
            layout.preview_image = "media/images/join_steps_cta.png"
            layout.screenshots = [
              "media/images/join_steps_cta_1.png",
              "media/images/join_steps_cta_2.png",
              "media/images/join_steps_cta_3.png"
            ]
            layout.cell = "decidim/extra_blocks/layouts/join_steps_cta"
            layout.settings_form_cell = "decidim/extra_blocks/layouts/join_steps_cta_settings_form"
            layout.images = [
              {
                name: :background_image,
                uploader: "Decidim::ExtraBlocks::LayoutImageUploader"
              }
            ]
            DynamicSteps.declare!(layout)

            layout.settings do |settings|
              settings.attribute :background_color, type: :string, default: "#ffffff"
              settings.attribute :text_color, type: :enum, default: "black", choices: %w(white black)
              settings.attribute :background_fit, type: :enum, default: "cover", choices: BACKGROUND_FITS
              settings.attribute :title, type: :text, translated: true
              (1..STEP_COUNT).each do |index|
                settings.attribute :"step_#{index}_title", type: :text, translated: true
                settings.attribute :"step_#{index}_body", type: :text, translated: true
              end
              settings.attribute :button_label, type: :string, translated: true
              settings.attribute :button_url, type: :string
            end
          end
        end

        def register_trust_quote_cta!
          LayoutRegistry.register(:trust_quote_cta) do |layout|
            layout.category = :cta
            layout.public_name_key = "decidim.extra_blocks.layouts.trust_quote_cta.name"
            layout.description_key = "decidim.extra_blocks.layouts.trust_quote_cta.description"
            layout.preview_image = "media/images/trust_quote_cta.png"
            layout.screenshots = [
              "media/images/trust_quote_cta_1.png",
              "media/images/trust_quote_cta_2.png",
              "media/images/trust_quote_cta_3.png"
            ]
            layout.cell = "decidim/extra_blocks/layouts/trust_quote_cta"
            layout.settings_form_cell = "decidim/extra_blocks/layouts/trust_quote_cta_settings_form"
            layout.images = [
              {
                name: :portrait,
                uploader: "Decidim::ExtraBlocks::LayoutImageUploader"
              }
            ]

            layout.settings do |settings|
              settings.attribute :background_color, type: :string, default: "#020203"
              settings.attribute :text_color, type: :enum, default: "white", choices: %w(white black)
              settings.attribute :quote, type: :text, translated: true
              settings.attribute :attribution_name, type: :string, translated: true
              settings.attribute :attribution_role, type: :string, translated: true
              settings.attribute :button_label, type: :string, translated: true
              settings.attribute :button_url, type: :string
            end
          end
        end

        def register_video_hero!
          LayoutRegistry.register(:video_hero) do |layout|
            layout.category = :hero
            layout.public_name_key = "decidim.extra_blocks.layouts.video_hero.name"
            layout.description_key = "decidim.extra_blocks.layouts.video_hero.description"
            layout.preview_image = "media/images/video_hero.png"
            layout.screenshots = [
              "media/images/video_hero_1.png",
              "media/images/video_hero_2.png",
              "media/images/video_hero_3.png"
            ]
            layout.cell = "decidim/extra_blocks/layouts/video_hero"
            layout.settings_form_cell = "decidim/extra_blocks/layouts/video_hero_settings_form"
            layout.images = [
              {
                name: :background_video_webm,
                uploader: "Decidim::ExtraBlocks::BackgroundWebmUploader"
              },
              {
                name: :background_video,
                uploader: "Decidim::ExtraBlocks::BackgroundMp4Uploader"
              }
            ]

            layout.settings do |settings|
              settings.attribute :background_color, type: :string, default: "#020203"
              settings.attribute :text_color, type: :enum, default: "white", choices: %w(white black)
              settings.attribute :eyebrow, type: :string, translated: true
              settings.attribute :title, type: :text, translated: true
              settings.attribute :title_position, type: :enum, default: "middle_center",
                                                  choices: TITLE_POSITIONS
              settings.attribute :button_label, type: :string, translated: true
              settings.attribute :button_url, type: :string
            end
          end
        end

        def register_photo_mission_hero!
          LayoutRegistry.register(:photo_mission_hero) do |layout|
            layout.category = :hero
            layout.public_name_key = "decidim.extra_blocks.layouts.photo_mission_hero.name"
            layout.description_key = "decidim.extra_blocks.layouts.photo_mission_hero.description"
            layout.preview_image = "media/images/photo_mission_hero.png"
            layout.screenshots = [
              "media/images/photo_mission_hero_1.png",
              "media/images/photo_mission_hero_2.png",
              "media/images/photo_mission_hero_3.png"
            ]
            layout.cell = "decidim/extra_blocks/layouts/photo_mission_hero"
            layout.settings_form_cell = "decidim/extra_blocks/layouts/photo_mission_hero_settings_form"
            layout.images = [
              {
                name: :background_image,
                uploader: "Decidim::ExtraBlocks::LayoutImageUploader"
              }
            ]

            layout.settings do |settings|
              settings.attribute :background_color, type: :string, default: "#020203"
              settings.attribute :text_color, type: :enum, default: "white", choices: %w(white black)
              settings.attribute :background_fit, type: :enum, default: "cover", choices: BACKGROUND_FITS
              settings.attribute :overlay_strength, type: :enum, default: "medium",
                                                    choices: OVERLAY_STRENGTHS
              settings.attribute :size, type: :enum, default: "medium", choices: SIZES
              settings.attribute :eyebrow, type: :string, translated: true
              settings.attribute :title, type: :text, translated: true
              settings.attribute :tagline, type: :text, translated: true
              settings.attribute :button_label, type: :string, translated: true
              settings.attribute :button_url, type: :string
            end
          end
        end

        def register_split_story_hero!
          LayoutRegistry.register(:split_story_hero) do |layout|
            layout.category = :hero
            layout.public_name_key = "decidim.extra_blocks.layouts.split_story_hero.name"
            layout.description_key = "decidim.extra_blocks.layouts.split_story_hero.description"
            layout.preview_image = "media/images/split_story_hero.png"
            layout.screenshots = [
              "media/images/split_story_hero_1.png",
              "media/images/split_story_hero_2.png",
              "media/images/split_story_hero_3.png"
            ]
            layout.cell = "decidim/extra_blocks/layouts/split_story_hero"
            layout.settings_form_cell = "decidim/extra_blocks/layouts/split_story_hero_settings_form"
            layout.images = [
              {
                name: :side_image,
                uploader: "Decidim::ExtraBlocks::LayoutImageUploader"
              }
            ]

            layout.settings do |settings|
              settings.attribute :background_color, type: :string, default: "#ffffff"
              settings.attribute :text_color, type: :enum, default: "black", choices: %w(white black)
              settings.attribute :image_side, type: :enum, default: "right", choices: IMAGE_SIDES
              settings.attribute :eyebrow, type: :string, translated: true
              settings.attribute :title, type: :text, translated: true
              settings.attribute :body, type: :text, translated: true, editor: true
              settings.attribute :button_label, type: :string, translated: true
              settings.attribute :button_url, type: :string
            end
          end
        end

        def register_outcome_stats_hero!
          LayoutRegistry.register(:outcome_stats_hero) do |layout|
            layout.category = :hero
            layout.public_name_key = "decidim.extra_blocks.layouts.outcome_stats_hero.name"
            layout.description_key = "decidim.extra_blocks.layouts.outcome_stats_hero.description"
            layout.preview_image = "media/images/outcome_stats_hero.png"
            layout.screenshots = [
              "media/images/outcome_stats_hero_1.png",
              "media/images/outcome_stats_hero_2.png",
              "media/images/outcome_stats_hero_3.png"
            ]
            layout.cell = "decidim/extra_blocks/layouts/outcome_stats_hero"
            layout.settings_form_cell = "decidim/extra_blocks/layouts/outcome_stats_hero_settings_form"
            DynamicStats.declare!(layout)

            layout.settings do |settings|
              settings.attribute :background_color, type: :string, default: "#020203"
              settings.attribute :text_color, type: :enum, default: "white", choices: %w(white black)
              settings.attribute :title, type: :text, translated: true
              settings.attribute :intro, type: :text, translated: true
              (1..STAT_COUNT).each do |index|
                settings.attribute :"stat_#{index}_value", type: :string, translated: true
                settings.attribute :"stat_#{index}_label", type: :string, translated: true
              end
              settings.attribute :button_label, type: :string, translated: true
              settings.attribute :button_url, type: :string
            end
          end
        end

        def register_focused_quick_proposal!
          LayoutRegistry.register(:focused_quick_proposal) do |layout|
            layout.category = :fast_proposal
            layout.public_name_key = "decidim.extra_blocks.layouts.focused_quick_proposal.name"
            layout.description_key = "decidim.extra_blocks.layouts.focused_quick_proposal.description"
            layout.preview_image = "media/images/focused_quick_proposal.png"
            layout.screenshots = [
              "media/images/focused_quick_proposal_1.png",
              "media/images/focused_quick_proposal_2.png",
              "media/images/focused_quick_proposal_3.png"
            ]
            layout.cell = "decidim/extra_blocks/layouts/focused_quick_proposal"
            layout.settings_form_cell = "decidim/extra_blocks/layouts/focused_quick_proposal_settings_form"
            layout.images = [
              {
                name: :background_image,
                uploader: "Decidim::ExtraBlocks::LayoutImageUploader"
              }
            ]
            declare_fast_proposal_settings!(layout)
            layout.settings do |settings|
              settings.attribute :background_fit, type: :enum, default: "cover", choices: BACKGROUND_FITS
            end
          end
        end

        def register_split_fast_proposal!
          LayoutRegistry.register(:split_fast_proposal) do |layout|
            layout.category = :fast_proposal
            layout.public_name_key = "decidim.extra_blocks.layouts.split_fast_proposal.name"
            layout.description_key = "decidim.extra_blocks.layouts.split_fast_proposal.description"
            layout.preview_image = "media/images/split_fast_proposal.png"
            layout.screenshots = [
              "media/images/split_fast_proposal_1.png",
              "media/images/split_fast_proposal_2.png",
              "media/images/split_fast_proposal_3.png"
            ]
            layout.cell = "decidim/extra_blocks/layouts/split_fast_proposal"
            layout.settings_form_cell = "decidim/extra_blocks/layouts/split_fast_proposal_settings_form"
            layout.images = [
              {
                name: :background_image,
                uploader: "Decidim::ExtraBlocks::LayoutImageUploader"
              }
            ]
            declare_fast_proposal_settings!(layout)
            layout.settings do |settings|
              settings.attribute :form_side, type: :enum, default: "left", choices: IMAGE_SIDES
              settings.attribute :background_fit, type: :enum, default: "cover", choices: BACKGROUND_FITS
            end
          end
        end

        def register_video_fast_proposal!
          LayoutRegistry.register(:video_fast_proposal) do |layout|
            layout.category = :fast_proposal
            layout.public_name_key = "decidim.extra_blocks.layouts.video_fast_proposal.name"
            layout.description_key = "decidim.extra_blocks.layouts.video_fast_proposal.description"
            layout.preview_image = "media/images/video_fast_proposal.png"
            layout.screenshots = [
              "media/images/video_fast_proposal_1.png",
              "media/images/video_fast_proposal_2.png",
              "media/images/video_fast_proposal_3.png"
            ]
            layout.cell = "decidim/extra_blocks/layouts/video_fast_proposal"
            layout.settings_form_cell = "decidim/extra_blocks/layouts/video_fast_proposal_settings_form"
            layout.images = [
              {
                name: :background_video_webm,
                uploader: "Decidim::ExtraBlocks::BackgroundWebmUploader"
              },
              {
                name: :background_video,
                uploader: "Decidim::ExtraBlocks::BackgroundMp4Uploader"
              }
            ]
            declare_fast_proposal_settings!(layout)
          end
        end

        def register_proposals_aside_fast_proposal!
          LayoutRegistry.register(:proposals_aside_fast_proposal) do |layout|
            layout.category = :fast_proposal
            layout.public_name_key = "decidim.extra_blocks.layouts.proposals_aside_fast_proposal.name"
            layout.description_key = "decidim.extra_blocks.layouts.proposals_aside_fast_proposal.description"
            layout.preview_image = "media/images/proposals_aside_fast_proposal.png"
            layout.screenshots = [
              "media/images/proposals_aside_fast_proposal_1.png",
              "media/images/proposals_aside_fast_proposal_2.png",
              "media/images/proposals_aside_fast_proposal_3.png"
            ]
            layout.cell = "decidim/extra_blocks/layouts/proposals_aside_fast_proposal"
            layout.settings_form_cell = "decidim/extra_blocks/layouts/proposals_aside_fast_proposal_settings_form"
            layout.images = [
              {
                name: :background_image,
                uploader: "Decidim::ExtraBlocks::LayoutImageUploader"
              }
            ]
            declare_fast_proposal_settings!(layout)
            layout.settings do |settings|
              settings.attribute :background_fit, type: :enum, default: "cover", choices: BACKGROUND_FITS
            end
          end
        end

        def declare_fast_proposal_settings!(layout)
          layout.settings do |settings|
            settings.attribute :proposal_component_id, type: :string, default: ""
            settings.attribute :eyebrow, type: :string, translated: true
            settings.attribute :title, type: :text, translated: true
            settings.attribute :description, type: :text, translated: true, editor: true
            settings.attribute :terms, type: :text, translated: true, editor: true
            settings.attribute :background_color, type: :string, default: "#ffffff"
            settings.attribute :text_color, type: :enum, default: "black", choices: %w(white black)
            settings.attribute :success_message, type: :text, translated: true
            settings.attribute :success_button_label, type: :string, translated: true
            settings.attribute :success_time, type: :string, default: "15"
            settings.attribute :default_title, type: :string, default: "Anonymous Proposal {{id}}"
            settings.attribute :default_title_connected, type: :string, default: "Proposal from {{id}}"
          end
        end

        def register_editorial_prose!
          LayoutRegistry.register(:editorial_prose) do |layout|
            layout.category = :text
            layout.public_name_key = "decidim.extra_blocks.layouts.editorial_prose.name"
            layout.description_key = "decidim.extra_blocks.layouts.editorial_prose.description"
            layout.preview_image = "media/images/editorial_prose.png"
            layout.screenshots = [
              "media/images/editorial_prose_1.png",
              "media/images/editorial_prose_2.png",
              "media/images/editorial_prose_3.png"
            ]
            layout.cell = "decidim/extra_blocks/layouts/editorial_prose"
            layout.settings_form_cell = "decidim/extra_blocks/layouts/editorial_prose_settings_form"
            layout.images = [
              {
                name: :lead_image,
                uploader: "Decidim::ExtraBlocks::LayoutImageUploader"
              }
            ]

            layout.settings do |settings|
              settings.attribute :background_color, type: :string, default: "#ffffff"
              settings.attribute :text_color, type: :enum, default: "black", choices: %w(white black)
              settings.attribute :image_position, type: :enum, default: "above", choices: IMAGE_POSITIONS
              settings.attribute :eyebrow, type: :string, translated: true
              settings.attribute :title, type: :text, translated: true
              settings.attribute :body, type: :text, translated: true, editor: true
              settings.attribute :button_label, type: :string, translated: true
              settings.attribute :button_url, type: :string
            end
          end
        end

        def register_media_aside!
          LayoutRegistry.register(:media_aside) do |layout|
            layout.category = :text
            layout.public_name_key = "decidim.extra_blocks.layouts.media_aside.name"
            layout.description_key = "decidim.extra_blocks.layouts.media_aside.description"
            layout.preview_image = "media/images/media_aside.png"
            layout.screenshots = [
              "media/images/media_aside_1.png",
              "media/images/media_aside_2.png",
              "media/images/media_aside_3.png"
            ]
            layout.cell = "decidim/extra_blocks/layouts/media_aside"
            layout.settings_form_cell = "decidim/extra_blocks/layouts/media_aside_settings_form"
            DynamicAsides.declare!(layout)

            layout.settings do |settings|
              settings.attribute :background_color, type: :string, default: "#ffffff"
              settings.attribute :text_color, type: :enum, default: "black", choices: %w(white black)
              settings.attribute :image_side, type: :enum, default: "right", choices: IMAGE_SIDES
              settings.attribute :title, type: :text, translated: true
              settings.attribute :body, type: :text, translated: true, editor: true
              settings.attribute :button_label, type: :string, translated: true
              settings.attribute :button_url, type: :string
            end
          end
        end

        def register_topic_trio!
          LayoutRegistry.register(:topic_trio) do |layout|
            layout.category = :text
            layout.public_name_key = "decidim.extra_blocks.layouts.topic_trio.name"
            layout.description_key = "decidim.extra_blocks.layouts.topic_trio.description"
            layout.preview_image = "media/images/topic_trio.png"
            layout.screenshots = [
              "media/images/topic_trio_1.png",
              "media/images/topic_trio_2.png",
              "media/images/topic_trio_3.png"
            ]
            layout.cell = "decidim/extra_blocks/layouts/topic_trio"
            layout.settings_form_cell = "decidim/extra_blocks/layouts/topic_trio_settings_form"
            DynamicTopics.declare!(layout)

            layout.settings do |settings|
              settings.attribute :background_color, type: :string, default: "#ffffff"
              settings.attribute :text_color, type: :enum, default: "black", choices: %w(white black)
              settings.attribute :eyebrow, type: :string, translated: true
              settings.attribute :title, type: :text, translated: true
              settings.attribute :body, type: :text, translated: true, editor: true
              (1..TOPIC_COUNT).each do |index|
                settings.attribute :"topic_#{index}_title", type: :text, translated: true
                settings.attribute :"topic_#{index}_body", type: :text, translated: true
              end
              settings.attribute :button_label, type: :string, translated: true
              settings.attribute :button_url, type: :string
            end
          end
        end

        def register_spacer!
          LayoutRegistry.register(:spacer) do |layout|
            layout.category = :misc
            layout.public_name_key = "decidim.extra_blocks.layouts.spacer.name"
            layout.description_key = "decidim.extra_blocks.layouts.spacer.description"
            layout.preview_image = "media/images/spacer.png"
            layout.screenshots = [
              "media/images/spacer_1.png",
              "media/images/spacer_2.png",
              "media/images/spacer_3.png"
            ]
            layout.cell = "decidim/extra_blocks/layouts/spacer"
            layout.settings_form_cell = "decidim/extra_blocks/layouts/spacer_settings_form"

            layout.settings do |settings|
              settings.attribute :background_color, type: :string, default: "#ffffff"
              settings.attribute :spacer_height, type: :enum, default: "3rem", choices: SPACER_HEIGHTS
            end
          end
        end

        def register_image!
          LayoutRegistry.register(:image) do |layout|
            layout.category = :misc
            layout.public_name_key = "decidim.extra_blocks.layouts.image.name"
            layout.description_key = "decidim.extra_blocks.layouts.image.description"
            layout.preview_image = "media/images/image.png"
            layout.screenshots = [
              "media/images/image_1.png",
              "media/images/image_2.png",
              "media/images/image_3.png"
            ]
            layout.cell = "decidim/extra_blocks/layouts/image"
            layout.settings_form_cell = "decidim/extra_blocks/layouts/image_settings_form"
            layout.images = [
              {
                name: :block_image,
                uploader: "Decidim::ExtraBlocks::LayoutImageUploader"
              }
            ]

            layout.settings do |settings|
              settings.attribute :background_color, type: :string, default: "#ffffff"
              settings.attribute :media_width, type: :enum, default: "full", choices: MEDIA_WIDTHS
            end
          end
        end

        def register_video!
          LayoutRegistry.register(:video) do |layout|
            layout.category = :misc
            layout.public_name_key = "decidim.extra_blocks.layouts.video.name"
            layout.description_key = "decidim.extra_blocks.layouts.video.description"
            layout.preview_image = "media/images/video.png"
            layout.screenshots = [
              "media/images/video_1.png",
              "media/images/video_2.png",
              "media/images/video_3.png"
            ]
            layout.cell = "decidim/extra_blocks/layouts/video"
            layout.settings_form_cell = "decidim/extra_blocks/layouts/video_settings_form"
            layout.images = [
              {
                name: :background_video_webm,
                uploader: "Decidim::ExtraBlocks::BackgroundWebmUploader"
              },
              {
                name: :background_video,
                uploader: "Decidim::ExtraBlocks::BackgroundMp4Uploader"
              }
            ]

            layout.settings do |settings|
              settings.attribute :background_color, type: :string, default: "#020203"
              settings.attribute :media_width, type: :enum, default: "full", choices: MEDIA_WIDTHS
            end
          end
        end

        def register_logo_showcase!
          LayoutRegistry.register(:logo_showcase) do |layout|
            layout.category = :misc
            layout.public_name_key = "decidim.extra_blocks.layouts.logo_showcase.name"
            layout.description_key = "decidim.extra_blocks.layouts.logo_showcase.description"
            layout.preview_image = "media/images/logo_showcase.png"
            layout.screenshots = [
              "media/images/logo_showcase_1.png",
              "media/images/logo_showcase_2.png",
              "media/images/logo_showcase_3.png"
            ]
            layout.cell = "decidim/extra_blocks/layouts/logo_showcase"
            layout.settings_form_cell = "decidim/extra_blocks/layouts/logo_showcase_settings_form"
            DynamicLogos.declare!(layout)

            layout.settings do |settings|
              settings.attribute :background_color, type: :string, default: "#ffffff"
            end
          end
        end

        def register_brand_story!
          LayoutRegistry.register(:brand_story) do |layout|
            layout.category = :timelines
            layout.public_name_key = "decidim.extra_blocks.layouts.brand_story.name"
            layout.description_key = "decidim.extra_blocks.layouts.brand_story.description"
            layout.preview_image = "media/images/brand_story.png"
            layout.screenshots = [
              "media/images/brand_story_1.png",
              "media/images/brand_story_2.png",
              "media/images/brand_story_3.png"
            ]
            layout.cell = "decidim/extra_blocks/layouts/brand_story"
            layout.settings_form_cell = "decidim/extra_blocks/layouts/brand_story_settings_form"
            layout.images = (1..TIMELINE_EVENT_COUNT).map do |index|
              {
                name: :"event_#{index}_image",
                uploader: "Decidim::ExtraBlocks::LayoutImageUploader"
              }
            end
            DynamicEvents.declare!(layout)

            layout.settings do |settings|
              settings.attribute :background_color, type: :string, default: "#ffffff"
              settings.attribute :text_color, type: :enum, default: "black", choices: %w(white black)
              settings.attribute :title, type: :text, translated: true
              (1..TIMELINE_EVENT_COUNT).each do |index|
                settings.attribute :"event_#{index}_date", type: :string, translated: true
                settings.attribute :"event_#{index}_title", type: :text, translated: true
                settings.attribute :"event_#{index}_body", type: :text, translated: true
              end
            end
          end
        end

        def register_roadmap!
          LayoutRegistry.register(:roadmap) do |layout|
            layout.category = :timelines
            layout.public_name_key = "decidim.extra_blocks.layouts.roadmap.name"
            layout.description_key = "decidim.extra_blocks.layouts.roadmap.description"
            layout.preview_image = "media/images/roadmap.png"
            layout.screenshots = [
              "media/images/roadmap_1.png",
              "media/images/roadmap_2.png",
              "media/images/roadmap_3.png"
            ]
            layout.cell = "decidim/extra_blocks/layouts/roadmap"
            layout.settings_form_cell = "decidim/extra_blocks/layouts/roadmap_settings_form"
            DynamicEvents.declare!(layout)

            layout.settings do |settings|
              settings.attribute :background_color, type: :string, default: "#ffffff"
              settings.attribute :text_color, type: :enum, default: "black", choices: %w(white black)
              settings.attribute :title, type: :text, translated: true
              (1..TIMELINE_EVENT_COUNT).each do |index|
                settings.attribute :"event_#{index}_date", type: :string, translated: true
                settings.attribute :"event_#{index}_title", type: :text, translated: true
                settings.attribute :"event_#{index}_body", type: :text, translated: true
                settings.attribute :"event_#{index}_button_label", type: :string, translated: true
                settings.attribute :"event_#{index}_button_url", type: :string
              end
            end
          end
        end

        def register_impact_milestones!
          LayoutRegistry.register(:impact_milestones) do |layout|
            layout.category = :timelines
            layout.public_name_key = "decidim.extra_blocks.layouts.impact_milestones.name"
            layout.description_key = "decidim.extra_blocks.layouts.impact_milestones.description"
            layout.preview_image = "media/images/impact_milestones.png"
            layout.screenshots = [
              "media/images/impact_milestones_1.png",
              "media/images/impact_milestones_2.png",
              "media/images/impact_milestones_3.png"
            ]
            layout.cell = "decidim/extra_blocks/layouts/impact_milestones"
            layout.settings_form_cell = "decidim/extra_blocks/layouts/impact_milestones_settings_form"
            DynamicEvents.declare!(layout)

            layout.settings do |settings|
              settings.attribute :background_color, type: :string, default: "#ffffff"
              settings.attribute :text_color, type: :enum, default: "black", choices: %w(white black)
              settings.attribute :title, type: :text, translated: true
              (1..TIMELINE_EVENT_COUNT).each do |index|
                settings.attribute :"event_#{index}_date", type: :string, translated: true
                settings.attribute :"event_#{index}_title", type: :text, translated: true
                settings.attribute :"event_#{index}_body", type: :text, translated: true
              end
            end
          end
        end
      end
    end
  end
end
