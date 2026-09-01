# frozen_string_literal: true

module Decidim
  module ExtraBlocks
    module Layouts
      class BrandStoryCell < BaseCell
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
            image_name = :"event_#{index}_image"
            has_image = model.images_container.respond_to?(image_name) &&
                        model.images_container.public_send(image_name).attached?
            next if date.blank? && event_title.blank? && event_body.blank? && !has_image

            {
              index:,
              date:,
              title: event_title,
              body: event_body,
              highlighted: entry[:highlighted],
              image_uploader: has_image ? model.images_container.attached_uploader(image_name) : nil
            }
          end
        end

        private

        def event_filled?(index)
          date = translated_attribute(model.settings.public_send(:"event_#{index}_date"))
          event_title = translated_attribute(model.settings.public_send(:"event_#{index}_title"))
          event_body = translated_attribute(model.settings.public_send(:"event_#{index}_body"))
          image_name = :"event_#{index}_image"
          has_image = model.images_container.respond_to?(image_name) &&
                      model.images_container.public_send(image_name).attached?
          date.present? || event_title.present? || event_body.present? || has_image
        end
      end
    end
  end
end
