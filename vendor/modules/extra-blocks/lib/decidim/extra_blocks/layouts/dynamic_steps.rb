# frozen_string_literal: true

module Decidim
  module ExtraBlocks
    module Layouts
      # Join-steps list contract: fixed step_N_* settings + steps_json order.
      #
      # ponytail: SLOT_COUNT=6 ceiling — raise with RegisterDefaults later.
      module DynamicSteps
        extend DynamicOrderedSlots::API

        SLOT_COUNT = 6
        JSON_ATTRIBUTE = :steps_json

        class << self
          def declare!(layout)
            declare_json!(layout)
          end

          def form_json_for_settings(content_block, settings_object)
            form_json(content_block) do |slot|
              title = settings_object.try(:"step_#{slot}_title")
              body = settings_object.try(:"step_#{slot}_body")
              translated_present?(title) || translated_present?(body)
            end
          end
        end
      end
    end
  end
end
