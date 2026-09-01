# frozen_string_literal: true

module Decidim
  module ExtraBlocks
    module Layouts
      class EditorialProseSettingsFormCell < BaseSettingsFormCell
        def image_positions
          Decidim::ExtraBlocks::Layouts::RegisterDefaults::IMAGE_POSITIONS
        end
      end
    end
  end
end
