# frozen_string_literal: true

module Decidim
  module ExtraBlocks
    module Admin
      # ponytail: layout freeze is one-way; ceiling = recreate block; upgrade = admin unfreeze
      module ContentBlockFormExtensions
        extend ActiveSupport::Concern

        included do
          validate :extra_block_layout_immutable
          validate :extra_block_layout_known
          validate :extra_block_proposal_titles
        end

        private

        def extra_block_content_block
          context&.[](:content_block)
        end

        def extra_block?
          extra_block_content_block&.manifest_name.to_s == "extra_block"
        end

        def incoming_layout
          value = settings
          return value.layout.to_s if value.respond_to?(:layout)

          value.to_h.with_indifferent_access[:layout].to_s if value.respond_to?(:to_h)
        end

        def existing_layout
          extra_block_content_block.settings.layout.to_s
        end

        def extra_block_layout_immutable
          return unless extra_block?
          return if existing_layout.blank?
          return if incoming_layout.blank? || incoming_layout == existing_layout

          errors.add(:settings, I18n.t("decidim.extra_blocks.admin.errors.layout_frozen"))
        end

        def extra_block_layout_known
          return unless extra_block?
          return if incoming_layout.blank?
          return if Decidim::ExtraBlocks::Layouts::LayoutRegistry.find(incoming_layout)

          errors.add(:settings, I18n.t("decidim.extra_blocks.admin.errors.layout_unknown"))
        end

        def extra_block_proposal_titles
          return unless extra_block?
          return unless fast_proposal_layout?

          validate_proposal_title_setting(:default_title)
          validate_proposal_title_setting(:default_title_connected)
        end

        def fast_proposal_layout?
          layout = incoming_layout.presence || existing_layout
          Decidim::ExtraBlocks::Layouts::LayoutRegistry.find(layout)&.category.to_s == "fast_proposal"
        end

        def validate_proposal_title_setting(key)
          template = incoming_setting(key)
          return if template.blank?
          return if interpolator.valid_proposal_title_template?(template)

          errors.add(:settings, I18n.t("decidim.extra_blocks.admin.errors.invalid_proposal_title"))
        end

        def incoming_setting(key)
          value = settings
          return value.public_send(key).to_s if value.respond_to?(key)

          value.to_h.with_indifferent_access[key].to_s if value.respond_to?(:to_h)
        end

        def interpolator
          Decidim::ExtraBlocks::FastProposal::TemplateInterpolator
        end
      end
    end
  end
end
