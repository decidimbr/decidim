# frozen_string_literal: true

module Decidim
  module ExtraBlocks
    module Layouts
      # Shared logo-list contract for ContentBlock layouts: fixed ActiveStorage slots
      # plus a JSON order/meta setting. Admin UX can look dynamic; storage cannot invent
      # attachment names at runtime.
      #
      # ponytail: SLOT_COUNT=12 ceiling — raise the constant later (boot-time registry, no migration).
      module DynamicLogos
        SLOT_COUNT = 12
        JSON_ATTRIBUTE = :logos_json
        UPLOADER = "Decidim::ExtraBlocks::LayoutImageUploader"

        class << self
          include Decidim::TranslatableAttributes

          def declare!(layout)
            layout.images = Array(layout.images) + image_definitions
            layout.settings do |settings|
              settings.attribute JSON_ATTRIBUTE, type: :text, default: "[]"
            end
          end

          def image_name(slot)
            :"logo_#{slot}"
          end

          def image_definitions
            (1..SLOT_COUNT).map do |slot|
              { name: image_name(slot), uploader: UPLOADER }
            end
          end

          def parse_items(raw_json)
            data = JSON.parse(raw_json.to_s.presence || "[]")
            return [] unless data.is_a?(Array)

            data.filter_map do |entry|
              next unless entry.is_a?(Hash)

              slot = entry["slot"].to_i
              next unless slot.between?(1, SLOT_COUNT)

              {
                "slot" => slot,
                "alt" => normalize_alt(entry["alt"])
              }
            end
          rescue JSON::ParserError
            []
          end

          def items_for(content_block)
            raw = content_block.settings.public_send(JSON_ATTRIBUTE)
            parse_items(raw).filter_map do |entry|
              slot = entry["slot"]
              name = image_name(slot)
              container = content_block.images_container
              next unless container.respond_to?(name) && container.public_send(name).attached?

              {
                slot:,
                alt: translated_attribute(entry["alt"]),
                uploader: container.attached_uploader(name)
              }
            end
          end

          private

          def normalize_alt(alt)
            case alt
            when Hash
              alt.each_with_object({}) do |(locale, value), memo|
                text = value.to_s.strip
                memo[locale.to_s] = text if text.present?
              end
            when String
              text = alt.strip
              text.present? ? { I18n.locale.to_s => text } : {}
            else
              {}
            end
          end
        end
      end
    end
  end
end
