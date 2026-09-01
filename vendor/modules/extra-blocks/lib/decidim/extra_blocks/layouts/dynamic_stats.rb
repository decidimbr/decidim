# frozen_string_literal: true

module Decidim
  module ExtraBlocks
    module Layouts
      # Outcome-stats list contract: fixed stat_N_* settings + stats_json order.
      #
      # ponytail: SLOT_COUNT=6 ceiling — raise with RegisterDefaults later.
      module DynamicStats
        extend DynamicOrderedSlots::API

        SLOT_COUNT = 6
        JSON_ATTRIBUTE = :stats_json

        class << self
          def declare!(layout)
            declare_json!(layout)
          end

          def form_json_for_settings(content_block, settings_object)
            form_json(content_block) do |slot|
              value = settings_object.try(:"stat_#{slot}_value")
              label = settings_object.try(:"stat_#{slot}_label")
              translated_present?(value) || translated_present?(label)
            end
          end
        end
      end
    end
  end
end
