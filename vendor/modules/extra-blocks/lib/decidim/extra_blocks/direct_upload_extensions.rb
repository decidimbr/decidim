# frozen_string_literal: true

module Decidim
  module ExtraBlocks
    # DirectUpload validates against organization allowlists/size and never
    # consults the mounted uploader. Allow Extra Blocks blobs (mp4/webm, svg).
    #
    # ponytail: org settings are global, not uploader-scoped; upgrade = this prepend
    # + BackgroundVideoUploader::MAX_FILE_SIZE wired into validates_upload / JS.
    module DirectUploadExtensions
      def validate_direct_upload
        return super unless extra_blocks_direct_upload?
        return if current_admin.present?

        head :unprocessable_entity unless extra_blocks_direct_upload_allowed?
      rescue NoMethodError
        head :unprocessable_entity
      end

      private

      def extra_blocks_direct_upload?
        background_video_direct_upload? || layout_svg_direct_upload?
      end

      def extra_blocks_direct_upload_allowed?
        return background_video_direct_upload_allowed? if background_video_direct_upload?

        layout_svg_direct_upload_allowed?
      end

      def background_video_direct_upload?
        BackgroundVideoUploader::EXTENSIONS.include?(extension) &&
          BackgroundVideoUploader::CONTENT_TYPES.include?(blob_args[:content_type].to_s)
      end

      def background_video_direct_upload_allowed?
        mime = MiniMime.lookup_by_extension(extension)&.content_type
        return false unless BackgroundVideoUploader::CONTENT_TYPES.include?(mime)

        blob_args[:byte_size].to_i <= BackgroundVideoUploader::MAX_FILE_SIZE
      end

      def layout_svg_direct_upload?
        extension == "svg" && blob_args[:content_type].to_s == "image/svg+xml"
      end

      def layout_svg_direct_upload_allowed?
        mime = MiniMime.lookup_by_extension(extension)&.content_type
        mime == "image/svg+xml" && blob_args[:byte_size].to_i <= maximum_allowed_size.to_i
      end
    end
  end
end
