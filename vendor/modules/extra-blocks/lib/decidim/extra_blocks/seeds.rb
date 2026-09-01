# frozen_string_literal: true

require_relative "seeds/settings"

module Decidim
  module ExtraBlocks
    # QA homepage seeds: one filled Extra Block per layout + Fast Proposal prereqs.
    # ponytail: idempotent by settings.layout only; dummy phone auth + lib/seeds media are QA-only
    class Seeds
      include Settings

      HANDLER = "dummy_ephemeral_authorization_handler"
      PROCESS_SLUG = "extra-blocks-qa"
      COMPONENT_NAME = { "en" => "Fast Proposal QA" }.freeze
      SEED_LOCALES = ["pt-BR"].freeze

      def call
        return if organization.blank?

        print "Creating seeds for decidim-extra_blocks...\n" unless Rails.env.test? # rubocop:disable Rails/Output
        configure_organization!
        component = ensure_proposals_component!
        seed_layouts!(component)
      end

      private

      def organization
        @organization ||= Decidim::Organization.first
      end

      def configure_organization!
        ensure_seed_locales!
        organization.update!(
          available_authorizations: merged_authorizations,
          available_locales: merged_available_locales
        )
        enable_extra_blocks_categories!
      end

      def ensure_seed_locales!
        current = Array(Decidim.available_locales).map(&:to_s)
        missing = SEED_LOCALES - current
        return if missing.empty?

        Decidim.available_locales = current | SEED_LOCALES
      end

      def merged_available_locales
        Array(organization.available_locales).map(&:to_s) | SEED_LOCALES
      end

      def merged_authorizations
        auths = normalize_authorizations(organization.read_attribute(:available_authorizations))
        Decidim.authorization_workflows.each { |workflow| auths[workflow.name] ||= {} }
        auths.each_value { |value| value.delete("allow_ephemeral_participation") }
        auths[HANDLER] = { "allow_ephemeral_participation" => true }
        auths
      end

      def normalize_authorizations(raw)
        return raw.transform_values { |value| value.is_a?(Hash) ? value.dup : {} } if raw.is_a?(Hash)

        Array(raw).index_with { {} }
      end

      def enable_extra_blocks_categories!
        config = { "enabled" => true }
        Layouts::LayoutRegistry.categories.each { |category| config["#{category}_enabled"] = true }
        Decidim::Toggle.save_config!(organization, MODULE_NAME, config)
      end

      def ensure_proposals_component!
        existing = find_fast_proposal_component
        return configure_component!(existing) if existing

        create_proposals_component!
      end

      def find_fast_proposal_component
        Decidim::Component.where(manifest_name: :proposals, participatory_space:)
                          .order(:id)
                          .find { |component| component.settings.try(:ephemeral_participation_enabled) }
      end

      def participatory_space
        @participatory_space ||= Decidim::ParticipatoryProcess.find_by(organization:, slug: PROCESS_SLUG) ||
                                 create_participatory_space!
      end

      def create_participatory_space!
        process = Decidim::ParticipatoryProcess.create!(process_attrs)
        create_process_step!(process)
        process
      end

      def process_attrs
        {
          organization:,
          slug: PROCESS_SLUG,
          title: localized_hash("Extra Blocks QA"),
          subtitle: localized_hash("Layout gallery"),
          short_description: localized_hash("<p>QA process for Extra Blocks.</p>"),
          description: localized_hash("<p>Holds the Fast Proposal component used by seed layouts.</p>"),
          published_at: Time.current
        }
      end

      def create_process_step!(process)
        Decidim::ParticipatoryProcessStep.create!(
          participatory_process: process,
          title: localized_hash("Open"),
          active: true,
          position: 0
        )
      end

      def create_proposals_component!
        component = Decidim::Component.create!(new_proposals_component_attrs)
        seed_proposal_states!(component)
        configure_component!(component)
      end

      def new_proposals_component_attrs
        {
          name: COMPONENT_NAME.merge(localized_hash("Fast Proposal QA")),
          manifest_name: :proposals,
          participatory_space:,
          published_at: Time.current,
          settings: { ephemeral_participation_enabled: true },
          step_settings: proposal_step_settings,
          permissions: proposal_permissions
        }
      end

      def seed_proposal_states!(component)
        return if admin_user.blank?

        Decidim::Proposals.create_default_states!(component, admin_user)
      end

      def admin_user
        Decidim::User.find_by(organization:, email: "admin@example.org")
      end

      def configure_component!(component)
        component.update!(
          settings: { ephemeral_participation_enabled: true },
          step_settings: proposal_step_settings,
          permissions: proposal_permissions,
          published_at: component.published_at || Time.current
        )
        component
      end

      def proposal_step_settings
        step = participatory_space.try(:active_step) || participatory_space.steps.first
        return {} if step.blank?

        { step.id.to_s => { "creation_enabled" => true } }
      end

      def proposal_permissions
        { "create" => { "authorization_handlers" => { HANDLER => {} } } }
      end

      def seed_layouts!(component)
        categories = Layouts::LayoutRegistry.categories
        categories.each_with_index do |category, cat_index|
          Layouts::LayoutRegistry.for_category(category).each do |manifest|
            upsert_block!(manifest.name, component)
          end
          next if cat_index >= categories.size - 1

          upsert_category_separator!(category)
        end
      end

      def upsert_block!(layout, component)
        block = find_block(layout) || build_block(layout)
        block.weight = next_weight
        block.settings = settings_for(layout, component)
        block.published_at ||= Time.current
        block.save!
        attach_media!(block, layout)
        block.save!
      end

      def upsert_category_separator!(category)
        seed_key = "separator_after_#{category}"
        block = find_separator(seed_key) || build_block(:spacer, seed_key:)
        block.weight = next_weight
        block.settings = category_separator_settings(seed_key)
        block.published_at ||= Time.current
        block.save!
      end

      def category_separator_settings(seed_key)
        {
          "layout" => "spacer",
          "seed_key" => seed_key,
          "background_color" => "#e8e8e8",
          "spacer_height" => "5rem"
        }
      end

      def find_block(layout)
        homepage_extra_blocks
          .where("settings->>'layout' IN (?)", layout_lookup_keys(layout))
          .where("settings->>'seed_key' IS NULL")
          .first
      end

      def layout_lookup_keys(layout)
        keys = [layout.to_s]
        keys << "product_roadmap" if layout.to_sym == :roadmap
        keys
      end

      def find_separator(seed_key)
        homepage_extra_blocks.where("settings->>'seed_key' = ?", seed_key).first
      end

      def homepage_extra_blocks
        Decidim::ContentBlock.where(
          organization:,
          scope_name: :homepage,
          manifest_name: "extra_block"
        )
      end

      def build_block(layout, seed_key: nil)
        settings = { "layout" => layout.to_s }
        settings["seed_key"] = seed_key if seed_key.present?

        Decidim::ContentBlock.new(
          organization:,
          scope_name: :homepage,
          manifest_name: "extra_block",
          published_at: Time.current,
          settings:
        )
      end

      def next_weight
        @next_weight = (@next_weight || max_homepage_weight) + 10
      end

      def max_homepage_weight
        Decidim::ContentBlock.where(organization:, scope_name: :homepage).maximum(:weight).to_i
      end

      def attach_media!(block, layout)
        media_for(layout).each do |attribute, filename|
          block.images_container.public_send("#{attribute}=", blob_for(filename))
        end
      end

      def media_for(layout)
        layout.to_sym == :logo_showcase ? logo_media : MEDIA.fetch(layout.to_sym, {})
      end

      def logo_media
        seeds_root.glob("logo_*").each_with_object({}) do |path, memo|
          filename = path.basename.to_s
          slot = filename[/\Alogo_(\d+)\./, 1]
          next if slot.blank?

          memo[:"logo_#{slot}"] = filename
        end
      end

      def blob_for(filename)
        @blobs ||= {}
        @blobs[filename] ||= ActiveStorage::Blob.create_and_upload!(
          io: File.open(seeds_root.join(filename)),
          filename:,
          content_type: content_type_for(filename)
        )
      end

      def seeds_root
        @seeds_root ||= Pathname.new(Decidim::ExtraBlocks::Engine.root).join("lib/seeds")
      end

      def content_type_for(filename)
        {
          ".jpg" => "image/jpeg",
          ".jpeg" => "image/jpeg",
          ".png" => "image/png",
          ".svg" => "image/svg+xml",
          ".mp4" => "video/mp4",
          ".webm" => "video/webm"
        }.fetch(File.extname(filename).downcase, "application/octet-stream")
      end

      def localized_hash(text)
        organization.available_locales.index_with { |_locale| text }
      end

      def localized(key, text)
        organization.available_locales.each_with_object({}) do |locale, memo|
          memo["#{key}_#{locale}"] = text
        end
      end

      def html(text)
        "<p>#{text}</p>"
      end

      MEDIA = {
        dual_path_cta: { background_image: "bg_gradient.jpg" },
        join_steps_cta: { background_image: "bg_city.jpg" },
        trust_quote_cta: { portrait: "portrait_1.jpg" },
        video_hero: { background_video_webm: "video-1.webm", background_video: "video-1.mp4" },
        photo_mission_hero: { background_image: "pattern_3.svg" },
        split_story_hero: { side_image: "group_picture.jpg" },
        focused_quick_proposal: { background_image: "bg_abstract.jpg" },
        split_fast_proposal: { background_image: "pattern_5.svg" },
        video_fast_proposal: { background_video_webm: "big_bunny.webm", background_video: "video.mp4" },
        proposals_aside_fast_proposal: { background_image: "pattern_6.svg" },
        editorial_prose: { lead_image: "benches.jpg" },
        media_aside: {
          aside_1_image: "together-1.jpg",
          aside_2_image: "benches-1.jpg",
          aside_3_image: "portrait_2.jpg"
        },
        topic_trio: {
          topic_1_image: "bg_city.jpg",
          topic_2_image: "group_picture.jpg",
          topic_3_image: "benches.jpg"
        },
        image: { block_image: "bg_abstract.jpg" },
        video: { background_video_webm: "video-1.webm", background_video: "video.mp4" },
        brand_story: {
          event_1_image: "bg_city.jpg",
          event_2_image: "group_picture.jpg",
          event_3_image: "benches.jpg"
        }
      }.freeze
    end
  end
end
