# frozen_string_literal: true

module Decidim
  module ExtraBlocks
    module Layouts
      class SplitStoryHeroCell < BaseCell
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

        def image_side
          model.settings.image_side.presence || "right"
        end

        def side_image?
          model.images_container.respond_to?(:side_image) &&
            model.images_container.side_image.attached?
        end

        def side_image_uploader
          return unless side_image?

          model.images_container.attached_uploader(:side_image)
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
      end
    end
  end
end
