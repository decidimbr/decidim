# frozen_string_literal: true

module Decidim
  module ExtraBlocks
    class BackgroundVideoUploader < Decidim::ApplicationUploader
      # Video heroes are often larger than org attachment defaults; keep this
      # scoped to the video uploader (not organization upload settings).
      MAX_FILE_SIZE = 1.gigabyte

      # Browsers send video/*; MiniMime often maps .mp4 → application/mp4 and
      # .webm → audio/webm. Accept both sides so DirectUpload and model checks agree.
      CONTENT_TYPES = %w(
        video/mp4
        application/mp4
        video/webm
        audio/webm
      ).freeze
      EXTENSIONS = %w(mp4 webm).freeze

      def content_type_allowlist
        self.class::CONTENT_TYPES
      end

      def extension_allowlist
        self.class::EXTENSIONS
      end
    end
  end
end
