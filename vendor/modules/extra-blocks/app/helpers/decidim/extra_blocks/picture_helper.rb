# frozen_string_literal: true

module Decidim
  module ExtraBlocks
    # Renders a <picture> with permanent proxy srcset URLs, or a plain <img> for SVG.
    module PictureHelper
      FIXED_SRCSET = {
        w600: "600w",
        w900: "900w",
        w1200: "1200w"
      }.freeze

      FULL_WIDTH_SRCSET = {
        d1x: "1x",
        d2x: "2x",
        d3x: "3x"
      }.freeze

      def extra_blocks_picture_tag(uploader, mode:, picture: {}, **image_options)
        return "".html_safe if uploader.blank? || !uploader.attached?
        return svg_img_tag(uploader, image_options) if uploader.svg?

        raster_picture_tag(uploader, mode, picture, image_options)
      end

      def extra_blocks_media_path(blob_or_attachment)
        PermanentMediaUrl.path(blob_or_attachment)
      end

      private

      def svg_img_tag(uploader, image_options)
        src = extra_blocks_media_path(uploader.model.public_send(uploader.mounted_as))
        return "".html_safe if src.blank?

        tag.img(**image_options.merge(src:, class: img_class(image_options[:class])))
      end

      def raster_picture_tag(uploader, mode, picture, image_options)
        descriptors = mode.to_sym == :full_width ? FULL_WIDTH_SRCSET : FIXED_SRCSET
        fallback_src = permanent_variant_path(uploader, descriptors.keys.last)
        return "".html_safe if fallback_src.blank?

        content_tag(:picture, picture.merge(class: img_class(picture[:class]))) do
          safe_join(picture_children(uploader, descriptors, fallback_src, image_options))
        end
      end

      def picture_children(uploader, descriptors, fallback_src, image_options)
        [
          webp_source_tag(uploader, descriptors),
          source_tag_for(uploader, descriptors, type: original_mime_type(uploader)),
          tag.img(**image_options.merge(
            src: fallback_src,
            srcset: srcset_for(uploader, descriptors),
            class: img_class(image_options[:class])
          ))
        ].compact
      end

      def img_class(css_class)
        [css_class, "not-prose"].compact.join(" ")
      end

      def webp_source_tag(uploader, descriptors)
        return unless ImageCapabilities.vips_webp?

        webp_descriptors = descriptors.transform_keys { |key| :"#{key}_webp" }
        srcset = srcset_for(uploader, webp_descriptors)
        return if srcset.blank?

        tag.source(srcset:, type: "image/webp")
      rescue StandardError
        nil
      end

      def source_tag_for(uploader, descriptors, type:)
        srcset = srcset_for(uploader, descriptors)
        return if srcset.blank?

        options = { srcset: }
        options[:type] = type if type.present?
        tag.source(**options)
      end

      def srcset_for(uploader, descriptors)
        descriptors.filter_map do |variant_key, descriptor|
          url = permanent_variant_path(uploader, variant_key)
          next if url.blank?

          "#{url} #{descriptor}"
        end.join(", ").presence
      end

      def permanent_variant_path(uploader, variant_key)
        transformations = uploader.variants[variant_key]
        return PermanentMediaUrl.path(uploader.model.public_send(uploader.mounted_as)) if transformations.blank?

        representable = uploader.variant(variant_key)
        PermanentMediaUrl.path(representable)
      rescue ActiveStorage::InvariableError
        PermanentMediaUrl.path(uploader.model.public_send(uploader.mounted_as))
      end

      def original_mime_type(uploader)
        blob = uploader.model.public_send(uploader.mounted_as)&.blob
        blob&.content_type
      end
    end
  end
end
