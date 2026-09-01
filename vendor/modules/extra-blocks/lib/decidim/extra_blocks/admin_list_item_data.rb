# frozen_string_literal: true

module Decidim
  module ExtraBlocks
    # Resolves layout category for admin content-block list item Deface attrs.
    module AdminListItemData
      module_function

      def category_for(model)
        return if model.blank?
        return unless model.respond_to?(:manifest_name)
        return unless model.manifest_name.to_s == "extra_block"
        return unless model.respond_to?(:settings)

        layout = model.settings.try(:layout)
        Layouts::LayoutRegistry.find(layout)&.category
      end
    end
  end
end
