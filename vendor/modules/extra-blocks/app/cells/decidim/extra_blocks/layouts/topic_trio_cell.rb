# frozen_string_literal: true

module Decidim
  module ExtraBlocks
    module Layouts
      class TopicTrioCell < BaseCell
        def eyebrow
          translated_attribute(model.settings.eyebrow)
        end

        def title
          translated_attribute(model.settings.title)
        end

        def body
          translated_attribute(model.settings.body)
        end

        def background_color
          model.settings.background_color.presence || "#ffffff"
        end

        def prose_classes
          model.settings.text_color.to_s == "white" ? "prose prose-invert" : "prose"
        end

        def button_label
          translated_attribute(model.settings.button_label)
        end

        def button_url
          model.settings.button_url.to_s
        end

        def show_button?
          button_label.present? && button_url.present?
        end

        def topics
          DynamicTopics.entries_for(model) { |slot| topic_filled?(slot) }.filter_map do |entry|
            index = entry[:slot]
            topic_title = translated_attribute(model.settings.public_send(:"topic_#{index}_title"))
            topic_body = translated_attribute(model.settings.public_send(:"topic_#{index}_body"))
            image_name = DynamicTopics.image_name(index)
            has_image = DynamicTopics.image_attached?(model, index)
            next if topic_title.blank? && topic_body.blank? && !has_image

            {
              index:,
              title: topic_title,
              body: topic_body,
              image_uploader: has_image ? model.images_container.attached_uploader(image_name) : nil
            }
          end
        end

        private

        def topic_filled?(slot)
          title = model.settings.public_send(:"topic_#{slot}_title")
          body = model.settings.public_send(:"topic_#{slot}_body")
          DynamicTopics.translated_present?(title) ||
            DynamicTopics.translated_present?(body) ||
            DynamicTopics.image_attached?(model, slot)
        end
      end
    end
  end
end
