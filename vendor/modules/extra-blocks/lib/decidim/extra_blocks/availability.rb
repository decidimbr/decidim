# frozen_string_literal: true

module Decidim
  module ExtraBlocks
    # Org-scoped enablement for the Extra Blocks module and layout categories.
    # Missing JSON keys default to enabled (backward compatible).
    module Availability
      module_function

      def module_enabled?(organization)
        return true if organization.blank?

        flag_enabled?(organization, :enabled)
      end

      def category_enabled?(organization, category)
        return false unless module_enabled?(organization)

        flag_enabled?(organization, category_key(category))
      end

      def effective_categories(organization)
        Layouts::LayoutRegistry.categories.select do |category|
          category_enabled?(organization, category)
        end
      end

      def category_key(category)
        :"#{category}_enabled"
      end

      def flag_enabled?(organization, key)
        raw = raw_config(organization)
        key_s = key.to_s
        return true unless raw.key?(key_s)

        ActiveModel::Type::Boolean.new.cast(raw[key_s])
      end

      def raw_config(organization)
        return {} if organization.blank?

        Decidim::Toggle::OrganizationModuleConfig.find_by(
          decidim_organization_id: organization.id,
          module_name: MODULE_NAME
        )&.config || {}
      end
    end
  end
end
