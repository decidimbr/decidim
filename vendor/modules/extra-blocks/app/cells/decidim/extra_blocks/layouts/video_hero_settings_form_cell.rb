# frozen_string_literal: true

module Decidim
  module ExtraBlocks
    module Layouts
      class VideoHeroSettingsFormCell < BaseSettingsFormCell
        def title_positions
          Decidim::ExtraBlocks::Layouts::RegisterDefaults::TITLE_POSITIONS
        end
      end
    end
  end
end
