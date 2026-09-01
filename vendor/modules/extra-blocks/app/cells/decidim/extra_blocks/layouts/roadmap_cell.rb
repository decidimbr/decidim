# frozen_string_literal: true

module Decidim
  module ExtraBlocks
    module Layouts
      class RoadmapCell < BaseCell
        EVENT_COUNT = RegisterDefaults::TIMELINE_EVENT_COUNT

        def title
          translated_attribute(model.settings.title)
        end

        def background_color
          model.settings.background_color.presence || "#ffffff"
        end

        def prose_classes
          model.settings.text_color.to_s == "white" ? "prose prose-invert" : "prose"
        end

        def events
          DynamicEvents.entries_for(model) { |index| event_filled?(index) }.filter_map do |entry|
            index = entry[:slot]
            date = translated_attribute(model.settings.public_send(:"event_#{index}_date"))
            event_title = translated_attribute(model.settings.public_send(:"event_#{index}_title"))
            event_body = translated_attribute(model.settings.public_send(:"event_#{index}_body"))
            button_label = translated_attribute(model.settings.public_send(:"event_#{index}_button_label"))
            button_url = model.settings.public_send(:"event_#{index}_button_url").to_s
            next if date.blank? && event_title.blank? && event_body.blank?

            {
              index:,
              date:,
              title: event_title,
              body: event_body,
              highlighted: entry[:highlighted],
              button_label:,
              button_url:,
              show_button: button_label.present? && button_url.present?
            }
          end
        end

        private

        def event_filled?(index)
          date = translated_attribute(model.settings.public_send(:"event_#{index}_date"))
          event_title = translated_attribute(model.settings.public_send(:"event_#{index}_title"))
          event_body = translated_attribute(model.settings.public_send(:"event_#{index}_body"))
          date.present? || event_title.present? || event_body.present?
        end
      end
    end
  end
end
