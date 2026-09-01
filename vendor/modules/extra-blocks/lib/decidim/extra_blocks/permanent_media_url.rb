# frozen_string_literal: true

module Decidim
  module ExtraBlocks
    # Builds non-expiring Active Storage *proxy* paths (never redirect / disk service URLs).
    class PermanentMediaUrl
      def self.path(representable)
        new(representable).path
      end

      def initialize(representable)
        @representable = representable
      end

      def path
        target = unwrap
        return if target.blank?

        url = routes.rails_storage_proxy_path(target, only_path: true, expires_in: nil)
        apply_variation_extension(url, target)
      end

      private

      attr_reader :representable

      def unwrap
        return if representable.nil?

        if representable.is_a?(ActiveStorage::Attached::One)
          return unless representable.attached?

          return representable.blob
        end

        # Blob, Variant, VariantWithRecord, Preview
        representable
      end

      def routes
        Rails.application.routes.url_helpers
      end

      # Mirror Decidim::AssetRouter::Storage#rails_representation_url filename fix.
      def apply_variation_extension(url, target)
        variation = target.try(:variation)
        return url unless variation

        format = variation.try(:format)
        return url unless format

        blob = target.try(:blob) || target.try(:image)
        return url unless blob

        original_ext = File.extname(blob.filename.to_s)
        return url if original_ext == ".#{format}"

        basename = File.basename(blob.filename.to_s, original_ext)
        url.sub(/#{Regexp.escape(basename)}#{Regexp.escape(original_ext)}$/, "#{basename}.#{format}")
      end
    end
  end
end
