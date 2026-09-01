# frozen_string_literal: true

require "open3"
require "tempfile"
require "fileutils"

module Decidim
  module ExtraBlocks
    # Runs pngquant on processed PNG Active Storage variants when the binary exists.
    class PngquantOptimizer
      def self.call(variant)
        new(variant).call
      end

      def initialize(variant)
        @variant = variant
      end

      def call
        return variant if svg? || !ImageCapabilities.pngquant?

        processed = variant.processed
        return variant unless png?(processed)

        optimize!(processed)
        variant
      rescue StandardError
        variant
      end

      private

      attr_reader :variant

      def svg?
        LayoutImageUploader.svg?(variant) || LayoutImageUploader.svg?(variant.try(:blob))
      end

      def png?(processed)
        content_type = processed.try(:content_type) ||
                       processed.try(:blob)&.content_type ||
                       processed.try(:image)&.content_type
        content_type.to_s == "image/png" || File.extname(filename(processed)).downcase == ".png"
      end

      def filename(processed)
        processed.try(:filename).to_s.presence ||
          processed.try(:blob)&.filename.to_s ||
          processed.try(:image)&.filename.to_s ||
          ""
      end

      def key_for(processed)
        processed.try(:key).presence || processed.try(:image)&.key
      end

      def service_for(processed)
        processed.try(:service) ||
          processed.try(:blob)&.service ||
          processed.try(:image)&.service
      end

      def optimize!(processed)
        key = key_for(processed)
        service = service_for(processed)
        return if key.blank? || service.blank?

        input = Tempfile.new(["extra_blocks_pngquant", ".png"])
        output_path = nil
        begin
          input.binmode
          download(processed, input)
          input.flush

          output_path = "#{input.path}.out.png"
          _stdout, _stderr, status = Open3.capture3(
            "pngquant", "--force", "--skip-if-larger", "--output", output_path, input.path
          )
          return unless status.success? && File.exist?(output_path)

          File.open(output_path, "rb") do |file|
            checksum = Digest::MD5.file(file.path).base64digest
            file.rewind
            service.upload(key, file, checksum:)
          end
        ensure
          input.close!
          FileUtils.rm_f(output_path) if output_path
        end
      end

      def download(processed, io)
        if processed.respond_to?(:download)
          processed.download { |chunk| io.write(chunk) }
        elsif processed.respond_to?(:open)
          processed.open { |file| IO.copy_stream(file, io) }
        else
          service_for(processed).download(key_for(processed)) { |chunk| io.write(chunk) }
        end
      end
    end
  end
end
