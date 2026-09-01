# frozen_string_literal: true

module Decidim
  module ExtraBlocks
    # Eagerly processes LayoutImageUploader variants so homepage cache hits stay cheap.
    class VariantProcessor
      def self.process_attachment!(attachment)
        new(attachment).process!
      end

      def initialize(attachment)
        @attachment = attachment
      end

      def process!
        return unless processable?

        variant_definitions.each_key { |name| process_variant(name) }
      end

      private

      attr_reader :attachment

      def processable?
        attachment&.file&.attached? &&
          layout_image_uploader? &&
          blob.present? &&
          !LayoutImageUploader.svg?(blob) &&
          blob.variable?
      end

      def blob
        @blob ||= attachment.file.blob
      end

      def layout_image_uploader?
        attachment.uploader == LayoutImageUploader
      rescue NameError
        false
      end

      def variant_definitions
        LayoutImageUploader.variants
      end

      def process_variant(name)
        return if webp_variant?(name) && !ImageCapabilities.vips_webp?

        transformations = variant_definitions[name]
        return if transformations.blank?

        processed = attachment.file.variant(transformations).processed
        PngquantOptimizer.call(processed) if png_source?
      rescue StandardError
        nil
      end

      def webp_variant?(name)
        name.to_s.end_with?("_webp")
      end

      def png_source?
        blob.content_type.to_s == "image/png" || blob.filename.to_s.downcase.end_with?(".png")
      end
    end
  end
end
