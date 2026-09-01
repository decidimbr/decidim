# frozen_string_literal: true

module Decidim
  module ExtraBlocks
    module Layouts
      # Media-aside image list: fixed aside_N_image slots + asides_json order.
      #
      # ponytail: SLOT_COUNT=6 ceiling — raise with RegisterDefaults later.
      module DynamicAsides
        extend DynamicOrderedSlots::API

        SLOT_COUNT = 6
        JSON_ATTRIBUTE = :asides_json
        UPLOADER = "Decidim::ExtraBlocks::LayoutImageUploader"

        class << self
          def declare!(layout)
            layout.images = Array(layout.images) + image_definitions
            declare_json!(layout)
          end

          def image_name(slot)
            :"aside_#{slot}_image"
          end

          def image_definitions
            (1..SLOT_COUNT).map do |slot|
              { name: image_name(slot), uploader: UPLOADER }
            end
          end

          def form_json_for_settings(content_block, _settings_object = nil)
            form_json(content_block) { |slot| image_attached?(content_block, slot) }
          end

          def image_attached?(content_block, slot)
            name = image_name(slot)
            container = content_block.images_container
            container.respond_to?(name) && container.public_send(name).attached?
          end

          def items_for(content_block)
            entries_for(content_block) { |slot| image_attached?(content_block, slot) }.filter_map do |entry|
              slot = entry[:slot]
              next unless image_attached?(content_block, slot)

              {
                slot:,
                uploader: content_block.images_container.attached_uploader(image_name(slot))
              }
            end
          end
        end
      end
    end
  end
end
