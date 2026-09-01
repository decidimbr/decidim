# frozen_string_literal: true

module Decidim
  module ExtraBlocks
    module Layouts
      class VideoHeroCell < BaseCell
        # webm before mp4 — browser picks the first supported source
        # (https://web.dev/learn/performance/video-performance).
        VIDEO_SOURCES = [
          { name: :background_video_webm, type: "video/webm" },
          { name: :background_video, type: "video/mp4" }
        ].freeze

        def eyebrow
          translated_attribute(model.settings.eyebrow)
        end

        def title
          translated_attribute(model.settings.title)
        end

        def background_color
          model.settings.background_color.presence || "#020203"
        end

        def prose_classes
          model.settings.text_color.to_s == "white" ? "prose prose-invert" : "prose"
        end

        def title_position
          model.settings.title_position.presence || "middle_center"
        end

        def video_sources
          VIDEO_SOURCES.filter_map do |source|
            next unless model.images_container.respond_to?(source[:name])
            next unless model.images_container.public_send(source[:name]).attached?

            attachment = model.images_container.public_send(source[:name])
            {
              src: PermanentMediaUrl.path(attachment),
              type: source[:type]
            }
          end
        end

        def video?
          video_sources.any?
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
