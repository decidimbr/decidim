# frozen_string_literal: true

module Decidim
  module ExtraBlocks
    module Layouts
      class PhotoMissionHeroSettingsFormCell < BaseSettingsFormCell
        def overlay_strengths
          Decidim::ExtraBlocks::Layouts::RegisterDefaults::OVERLAY_STRENGTHS
        end

        def sizes
          Decidim::ExtraBlocks::Layouts::RegisterDefaults::SIZES
        end
      end
    end
  end
end
