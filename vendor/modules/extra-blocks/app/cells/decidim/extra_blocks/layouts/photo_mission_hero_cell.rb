# frozen_string_literal: true

module Decidim
  module ExtraBlocks
    module Layouts
      class PhotoMissionHeroCell < BaseCell
        def eyebrow
          translated_attribute(model.settings.eyebrow)
        end

        def title
          translated_attribute(model.settings.title)
        end

        def tagline
          translated_attribute(model.settings.tagline)
        end

        def background_color
          model.settings.background_color.presence || "#020203"
        end

        def prose_classes
          model.settings.text_color.to_s == "white" ? "prose prose-invert" : "prose"
        end

        def overlay_strength
          model.settings.overlay_strength.presence || "medium"
        end

        def size
          model.settings.size.presence || "medium"
        end

        def background_image?
          model.images_container.respond_to?(:background_image) &&
            model.images_container.background_image.attached?
        end

        def background_image_uploader
          return unless background_image?

          model.images_container.attached_uploader(:background_image)
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
