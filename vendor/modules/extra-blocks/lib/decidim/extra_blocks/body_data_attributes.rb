# frozen_string_literal: true

module Decidim
  module ExtraBlocks
    # Deface data-* attributes for CSS hide rules (admin <body>, public .layout-container).
    module BodyDataAttributes
      module_function

      def deface_attributes
        attrs = {
          "data-extra-blocks-enabled" =>
            "<%= Decidim::ExtraBlocks::Availability.module_enabled?(current_organization).to_s %>"
        }

        Layouts::LayoutRegistry.categories.each do |category|
          attrs["data-extra-blocks-#{category.to_s.dasherize}-enabled"] =
            "<%= Decidim::ExtraBlocks::Availability.category_enabled?(current_organization, :#{category}).to_s %>"
        end

        attrs
      end
    end
  end
end
