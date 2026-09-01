# frozen_string_literal: true

module Decidim
  module ExtraBlocks
    module Layouts
      class SpacerSettingsFormCell < BaseSettingsFormCell
        def spacer_heights
          Decidim::ExtraBlocks::Layouts::RegisterDefaults::SPACER_HEIGHTS
        end
      end
    end
  end
end
