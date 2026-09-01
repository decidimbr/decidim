# frozen_string_literal: true

module Decidim
  module ExtraBlocks
    module Admin
      class ConfigForm < Decidim::Form
        include Decidim::Toggle::TabForm
        include Decidim::Toggle::ModuleConfigForm

        self.module_config_name = Decidim::ExtraBlocks::MODULE_NAME

        mimic :organization

        attribute :enabled, :boolean, default: true

        Decidim::ExtraBlocks::Layouts::RegisterDefaults.call
        Decidim::ExtraBlocks::Layouts::LayoutRegistry.categories.each do |category|
          attribute :"#{category}_enabled", :boolean, default: true
        end

        def self.from_model(organization)
          form = super
          return form if ActiveModel::Type::Boolean.new.cast(form.enabled)

          Decidim::ExtraBlocks::Layouts::LayoutRegistry.categories.each do |category|
            form.public_send(:"#{category}_enabled=", false)
          end
          form
        end

        # Used by Decidim::Toggle::SettingsFormBuilder (published gem API).
        def attribute_disabled?(attribute)
          attribute = attribute.to_sym
          return false if attribute == :enabled

          category_keys = Decidim::ExtraBlocks::Layouts::LayoutRegistry.categories.map do |category|
            :"#{category}_enabled"
          end
          return false unless category_keys.include?(attribute)

          !ActiveModel::Type::Boolean.new.cast(enabled)
        end

        # Attributes to persist. When the module is off, only write +enabled+ so
        # category flags are preserved (disabled checkboxes must not wipe them).
        def persistable_attributes
          return { "enabled" => false } unless ActiveModel::Type::Boolean.new.cast(enabled)

          to_h.except("id").stringify_keys
        end
      end
    end
  end
end
