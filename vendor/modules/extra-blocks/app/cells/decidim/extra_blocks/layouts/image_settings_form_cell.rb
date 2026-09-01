# frozen_string_literal: true

module Decidim
  module ExtraBlocks
    module Layouts
      class ImageSettingsFormCell < BaseSettingsFormCell
        def media_widths
          Decidim::ExtraBlocks::Layouts::RegisterDefaults::MEDIA_WIDTHS
        end
      end
    end
  end
end
