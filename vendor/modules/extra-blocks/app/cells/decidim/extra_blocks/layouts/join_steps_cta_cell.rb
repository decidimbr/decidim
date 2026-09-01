# frozen_string_literal: true

module Decidim
  module ExtraBlocks
    module Layouts
      class JoinStepsCtaCell < BaseCell
        def title
          translated_attribute(model.settings.title)
        end

        def background_color
          model.settings.background_color.presence || "#ffffff"
        end

        def background_image?
          model.images_container.respond_to?(:background_image) &&
            model.images_container.background_image.attached?
        end

        def background_image_uploader
          return unless background_image?

          model.images_container.attached_uploader(:background_image)
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

        def steps
          DynamicSteps.entries_for(model) { |slot| step_filled?(slot) }.filter_map.with_index do |entry, position|
            index = entry[:slot]
            step_title = translated_attribute(model.settings.public_send(:"step_#{index}_title"))
            step_body = translated_attribute(model.settings.public_send(:"step_#{index}_body"))
            next if step_title.blank? && step_body.blank?

            { number: position + 1, title: step_title, body: step_body }
          end
        end

        private

        def step_filled?(slot)
          title = model.settings.public_send(:"step_#{slot}_title")
          body = model.settings.public_send(:"step_#{slot}_body")
          DynamicSteps.translated_present?(title) || DynamicSteps.translated_present?(body)
        end
      end
    end
  end
end
