# frozen_string_literal: true

require "open3"

module Decidim
  module ExtraBlocks
    # Runtime checks for optional image tooling (libvips WebP, pngquant, ImageMagick flags).
    module ImageCapabilities
      WEBP_SAVER_BASE = {
        strip: true,
        interlace: true,
        quality: 100
      }.freeze

      class << self
        def vips_webp?
          return @vips_webp if defined?(@vips_webp)

          @vips_webp = variant_processor_vips? && libvips_webp?
        end

        def pngquant?
          return @pngquant if defined?(@pngquant)

          @pngquant = system("which", "pngquant", out: File::NULL, err: File::NULL)
        end

        # MiniMagick maps saver keys to convert/magick CLI flags. ImageMagick 6
        # (convert-im6) has no -subsample-mode; only add it when the active CLI lists it.
        def imagemagick_subsample_mode?
          return @imagemagick_subsample_mode if defined?(@imagemagick_subsample_mode)

          @imagemagick_subsample_mode = detect_imagemagick_subsample_mode
        end

        def webp_saver
          saver = WEBP_SAVER_BASE.dup
          saver[:subsample_mode] = "on" if imagemagick_subsample_mode?
          saver
        end

        # Test hooks
        def reset!
          remove_instance_variable(:@vips_webp) if defined?(@vips_webp)
          remove_instance_variable(:@pngquant) if defined?(@pngquant)
          remove_instance_variable(:@imagemagick_subsample_mode) if defined?(@imagemagick_subsample_mode)
        end

        private

        def variant_processor_vips?
          ActiveStorage.variant_processor == :vips
        rescue NameError
          false
        end

        def libvips_webp?
          require "vips"
          Vips.get_suffixes.include?(".webp") && webp_encode_ok?
        rescue LoadError, StandardError
          false
        end

        # ponytail: memoized once per process; restart Puma after installing libwebp.
        def webp_encode_ok?
          Vips::Image.black(1, 1).write_to_buffer(".webp")
          true
        rescue StandardError
          false
        end

        def detect_imagemagick_subsample_mode
          # Vips saver ignores ImageMagick CLI flags; never inject subsample_mode there.
          return false if variant_processor_vips?

          binary = mini_magick_binary
          return false unless binary

          out, status = Open3.capture2e(binary, "-help")
          status.success? && out.include?("-subsample-mode")
        rescue StandardError
          false
        end

        # Match the CLI MiniMagick actually invokes (:imagemagick → convert, :imagemagick7 → magick).
        def mini_magick_binary
          require "mini_magick"

          case MiniMagick.cli
          when :imagemagick7
            "magick"
          when :imagemagick
            "convert"
          end
        rescue LoadError, StandardError
          nil
        end
      end
    end
  end
end
