# frozen_string_literal: true

module Decidim
  module ExtraBlocks
    class BackgroundMp4Uploader < BackgroundVideoUploader
      CONTENT_TYPES = %w(video/mp4 application/mp4).freeze
      EXTENSIONS = %w(mp4).freeze
    end
  end
end
