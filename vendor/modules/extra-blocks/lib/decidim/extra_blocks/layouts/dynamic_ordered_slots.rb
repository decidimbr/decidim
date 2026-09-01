# frozen_string_literal: true

module Decidim
  module ExtraBlocks
    module Layouts
      # Shared pool+JSON slot-order contract for fixed settings/image slots.
      # Family modules set SLOT_COUNT + JSON_ATTRIBUTE and extend this API.
      #
      # ponytail: not a DynamicSlots framework — only shared parse/order/legacy helpers.
      module DynamicOrderedSlots
        module API
          def declare_json!(layout)
            attribute = self::JSON_ATTRIBUTE
            layout.settings do |settings|
              settings.attribute attribute, type: :text, default: ""
            end
          end

          def parse_items(raw_json)
            data = JSON.parse(raw_json.to_s.presence || "[]")
            return [] unless data.is_a?(Array)

            data.filter_map do |entry|
              next unless entry.is_a?(Hash)

              slot = entry["slot"].to_i
              next unless slot.between?(1, self::SLOT_COUNT)

              { "slot" => slot }
            end
          rescue JSON::ParserError
            []
          end

          # When JSON is blank (legacy blocks), yield each slot and keep filled ones.
          # When JSON is set (including "[]"), use JSON order only.
          def entries_for(content_block)
            raw = content_block.settings.public_send(self::JSON_ATTRIBUTE).to_s
            return parse_items(raw).map { |entry| { slot: entry["slot"] } } if raw.strip.present?

            (1..self::SLOT_COUNT).filter_map do |slot|
              next unless block_given? && yield(slot)

              { slot: }
            end
          end

          def form_json(content_block)
            raw = content_block.settings.public_send(self::JSON_ATTRIBUTE).to_s
            return raw if raw.strip.present?

            entries_for(content_block) { |slot| yield(slot) }.map do |entry|
              { "slot" => entry[:slot] }
            end.to_json
          end

          def translated_present?(value)
            case value
            when Hash
              value.values.any? { |text| text.to_s.strip.present? }
            else
              value.to_s.strip.present?
            end
          end
        end
      end
    end
  end
end
