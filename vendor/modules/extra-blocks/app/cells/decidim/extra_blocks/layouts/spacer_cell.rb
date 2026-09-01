# frozen_string_literal: true

module Decidim
  module ExtraBlocks
    module Layouts
      class SpacerCell < BaseCell
        def background_color
          model.settings.background_color.presence || "#ffffff"
        end

        def spacer_height
          height = model.settings.spacer_height.to_s
          return height if RegisterDefaults::SPACER_HEIGHTS.include?(height)

          "3rem"
        end
      end
    end
  end
end
