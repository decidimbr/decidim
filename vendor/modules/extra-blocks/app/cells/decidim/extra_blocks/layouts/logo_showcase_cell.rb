# frozen_string_literal: true

module Decidim
  module ExtraBlocks
    module Layouts
      class LogoShowcaseCell < BaseCell
        def background_color
          model.settings.background_color.presence || "#ffffff"
        end

        def logos
          @logos ||= DynamicLogos.items_for(model)
        end
      end
    end
  end
end
