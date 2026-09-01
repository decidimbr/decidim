# frozen_string_literal: true

module Decidim
  module ExtraBlocks
    module Layouts
      class ImageCell < BaseCell
        def background_color
          model.settings.background_color.presence || "#ffffff"
        end

        def media_width
          width = model.settings.media_width.to_s
          return width if RegisterDefaults::MEDIA_WIDTHS.include?(width)

          "full"
        end

        def block_image?
          model.images_container.respond_to?(:block_image) &&
            model.images_container.block_image.attached?
        end

        def block_image_uploader
          return unless block_image?

          model.images_container.attached_uploader(:block_image)
        end

        def picture_mode
          media_width == "full" ? :full_width : :fixed
        end
      end
    end
  end
end
