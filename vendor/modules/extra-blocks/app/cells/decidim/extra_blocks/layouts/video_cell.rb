# frozen_string_literal: true

module Decidim
  module ExtraBlocks
    module Layouts
      class VideoCell < BaseCell
        # webm before mp4 — browser picks the first supported source
        VIDEO_SOURCES = [
          { name: :background_video_webm, type: "video/webm" },
          { name: :background_video, type: "video/mp4" }
        ].freeze

        def background_color
          model.settings.background_color.presence || "#020203"
        end

        def media_width
          width = model.settings.media_width.to_s
          return width if RegisterDefaults::MEDIA_WIDTHS.include?(width)

          "full"
        end

        def video_sources
          VIDEO_SOURCES.filter_map { |source| source_entry(source) }
        end

        def video?
          video_sources.any?
        end

        private

        def source_entry(source)
          return unless model.images_container.respond_to?(source[:name])
          return unless model.images_container.public_send(source[:name]).attached?

          attachment = model.images_container.public_send(source[:name])
          { src: PermanentMediaUrl.path(attachment), type: source[:type] }
        end
      end
    end
  end
end
