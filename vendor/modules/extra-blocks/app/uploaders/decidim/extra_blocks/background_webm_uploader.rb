# frozen_string_literal: true

module Decidim
  module ExtraBlocks
    class BackgroundWebmUploader < BackgroundVideoUploader
      CONTENT_TYPES = %w(video/webm audio/webm).freeze
      EXTENSIONS = %w(webm).freeze
    end
  end
end
