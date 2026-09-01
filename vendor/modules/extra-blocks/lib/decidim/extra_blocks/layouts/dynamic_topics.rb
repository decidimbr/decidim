# frozen_string_literal: true

module Decidim
  module ExtraBlocks
    module Layouts
      # Topic list contract: fixed topic_N_* settings/images + topics_json order.
      #
      # ponytail: SLOT_COUNT=6 ceiling — raise with RegisterDefaults later.
      module DynamicTopics
        extend DynamicOrderedSlots::API

        SLOT_COUNT = 6
        JSON_ATTRIBUTE = :topics_json
        UPLOADER = "Decidim::ExtraBlocks::LayoutImageUploader"

        class << self
          def declare!(layout)
            layout.images = Array(layout.images) + image_definitions
            declare_json!(layout)
          end

          def image_name(slot)
            :"topic_#{slot}_image"
          end

          def image_definitions
            (1..SLOT_COUNT).map do |slot|
              { name: image_name(slot), uploader: UPLOADER }
            end
          end

          def form_json_for_settings(content_block, settings_object)
            form_json(content_block) do |slot|
              title = settings_object.try(:"topic_#{slot}_title")
              body = settings_object.try(:"topic_#{slot}_body")
              image = image_attached?(content_block, slot)
              translated_present?(title) || translated_present?(body) || image
            end
          end

          def image_attached?(content_block, slot)
            name = image_name(slot)
            container = content_block.images_container
            container.respond_to?(name) && container.public_send(name).attached?
          end
        end
      end
    end
  end
end
