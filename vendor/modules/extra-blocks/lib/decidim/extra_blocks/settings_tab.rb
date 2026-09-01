# frozen_string_literal: true

module Decidim
  module ExtraBlocks
    class SettingsTab
      def self.register!
        Decidim::Toggle.settings_tabs :organization_settings do |tabs|
          tabs.add_tab :decidim_extra_blocks,
                       I18n.t("decidim_toggle.system.#{MODULE_NAME}.tab"),
                       form: Decidim::ExtraBlocks::Admin::ConfigForm,
                       command: Decidim::ExtraBlocks::Admin::UpdateConfigCommand,
                       module_name: MODULE_NAME,
                       position: 25
        end
      end
    end
  end
end
