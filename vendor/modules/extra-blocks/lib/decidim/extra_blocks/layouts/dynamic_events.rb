# frozen_string_literal: true

module Decidim
  module ExtraBlocks
    module Layouts
      # Shared timeline-event list contract: fixed settings slots (event_1..) plus a JSON
      # order/meta setting. Admin UX can add/remove rows; storage cannot invent attributes.
      #
      # ponytail: SLOT_COUNT=5 ceiling — raise with RegisterDefaults::TIMELINE_EVENT_COUNT later;
      # translated settings stay on event_N_* (JSON only stores slot order + highlighted).
      module DynamicEvents
        SLOT_COUNT = 5
        JSON_ATTRIBUTE = :events_json

        class << self
          def declare!(layout)
            layout.settings do |settings|
              settings.attribute JSON_ATTRIBUTE, type: :text, default: ""
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
                "highlighted" => ActiveModel::Type::Boolean.new.cast(entry["highlighted"])
              }
            end
          rescue JSON::ParserError
            []
          end

          # When events_json is blank (legacy blocks), yield each slot and keep filled ones.
          # When events_json is set (including "[]"), use JSON order only.
          def entries_for(content_block)
            raw = content_block.settings.public_send(JSON_ATTRIBUTE).to_s
            if raw.strip.present?
              return parse_items(raw).map do |entry|
                { slot: entry["slot"], highlighted: entry["highlighted"] }
              end
            end

            (1..SLOT_COUNT).filter_map do |slot|
              next unless block_given? && yield(slot)

              { slot:, highlighted: false }
            end
          end

          def form_json(content_block)
            raw = content_block.settings.public_send(JSON_ATTRIBUTE).to_s
            return raw if raw.strip.present?

            entries_for(content_block) { |slot| yield(slot) }.map do |entry|
              { "slot" => entry[:slot], "highlighted" => entry[:highlighted] }
            end.to_json
          end

          # Settings-form helper: keep do/end out of cells-erb (erbse treats any `end` as <% end %>).
          def form_json_for_settings(content_block, settings_object)
            form_json(content_block) do |slot|
              date = settings_object.try(:"event_#{slot}_date")
              title = settings_object.try(:"event_#{slot}_title")
              body = settings_object.try(:"event_#{slot}_body")
              translated_present?(date) || translated_present?(title) || translated_present?(body)
            end
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
