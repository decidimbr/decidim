# frozen_string_literal: true

module Decidim
  module ExtraBlocks
    module Layouts
      class VideoFastProposalCell < BaseCell
        include FastProposalVisibility

        # webm before mp4 — browser picks the first supported source
        # (https://web.dev/learn/performance/video-performance).
        VIDEO_SOURCES = [
          { name: :background_video_webm, type: "video/webm" },
          { name: :background_video, type: "video/mp4" }
        ].freeze

        def show
          return unless visible?

          render :show
        end

        def background_color
          model.settings.background_color.presence || "#ffffff"
        end

        def prose_classes
          model.settings.text_color.to_s == "white" ? "prose prose-invert" : "prose"
        end

        def eyebrow
          translated_attribute(model.settings.eyebrow)
        end

        def title
          translated_attribute(model.settings.title)
        end

        def description
          translated_attribute(model.settings.description)
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
      end
    end
  end
end
