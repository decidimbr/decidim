# frozen_string_literal: true

module Decidim
  module ExtraBlocks
    # Admin instance label for Extra Blocks (DnD list + edit header).
    # Catalog type name stays on the content-block manifest; layouts own their names.
    module AdminDisplayName
      TYPE_NAME_KEY = "decidim.extra_blocks.content_blocks.extra_block.name"

      module_function

      def for(content_block)
        return if content_block.blank?
        return I18n.t(content_block.public_name_key) unless extra_block?(content_block)

        base = I18n.t(TYPE_NAME_KEY)
        layout = layout_for(content_block)
        return base if layout.blank?

        "#{I18n.t(layout.public_name_key)} (#{base})"
      end

      def extra_block?(content_block)
        content_block.present? &&
          content_block.respond_to?(:manifest_name) &&
          content_block.manifest_name.to_s == "extra_block"
      end
      module_function :extra_block?

      def layout_for(content_block)
        return unless content_block.respond_to?(:settings)

        Layouts::LayoutRegistry.find(content_block.settings.try(:layout))
      end
      module_function :layout_for
    end
  end
end
