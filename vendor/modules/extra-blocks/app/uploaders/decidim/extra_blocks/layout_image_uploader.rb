# frozen_string_literal: true

module Decidim
  module ExtraBlocks
    # Still-image uploads for Extra Blocks layouts with responsive variants.
    class LayoutImageUploader < Decidim::RecordImageUploader
      FIXED_VARIANTS = {
        w600: { resize_to_limit: [600, nil] },
        w900: { resize_to_limit: [900, nil] },
        w1200: { resize_to_limit: [1200, nil] }
      }.freeze

      FULL_WIDTH_VARIANTS = {
        d1x: { resize_to_limit: [1280, nil] },
        d2x: { resize_to_limit: [2560, nil] },
        d3x: { resize_to_limit: [3840, nil] }
      }.freeze

      set_variants do
        base = FIXED_VARIANTS.merge(FULL_WIDTH_VARIANTS)
        webp = base.transform_keys { |key| :"#{key}_webp" }.transform_values do |opts|
          opts.merge(convert: :webp, format: :webp, saver: ImageCapabilities.webp_saver)
        end
        base.merge(webp)
      end

      def extension_allowlist
        super + %w(svg)
      end

      def content_type_allowlist
        super + %w(image/svg+xml)
      end

      def validable_dimensions
        !svg?
      end

      def svg?
        self.class.svg?(model.public_send(mounted_as)&.blob)
      end

      def self.svg?(file)
        return false if file.blank?

        file.try(:content_type).to_s == "image/svg+xml" ||
          File.extname(file.try(:filename).to_s).downcase == ".svg"
      end
    end
  end
end
