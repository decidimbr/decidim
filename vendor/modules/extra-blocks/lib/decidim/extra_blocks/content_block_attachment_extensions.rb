# frozen_string_literal: true

module Decidim
  module ExtraBlocks
    module ContentBlockAttachmentExtensions
      def self.prepended(base)
        base.class_eval do
          after_commit :eager_process_extra_blocks_variants, on: [:create, :update]
        end
      end

      def maximum_upload_size
        return BackgroundVideoUploader::MAX_FILE_SIZE if background_video_uploader?

        super
      end

      private

      def background_video_uploader?
        uploader.is_a?(Class) && uploader <= BackgroundVideoUploader
      end

      def eager_process_extra_blocks_variants
        VariantProcessor.process_attachment!(self)
      end
    end
  end
end
