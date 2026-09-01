# frozen_string_literal: true

module Decidim
  module ExtraBlocks
    module Layouts
      class MediaAsideSettingsFormCell < BaseSettingsFormCell
        def image_sides
          Decidim::ExtraBlocks::Layouts::RegisterDefaults::IMAGE_SIDES
        end
      end
    end
  end
end
