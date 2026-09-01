# frozen_string_literal: true

module Decidim
  module ExtraBlocks
    module Layouts
      class LogoShowcaseSettingsFormCell < BaseSettingsFormCell
        include Decidim::DecidimFormHelper
        include Decidim::TranslatableAttributes

        def available_locales
          organization = content_block&.organization
          return Array(I18n.available_locales).map(&:to_s) if organization.blank?

          Array(organization.available_locales).map(&:to_s)
        end
      end
    end
  end
end
