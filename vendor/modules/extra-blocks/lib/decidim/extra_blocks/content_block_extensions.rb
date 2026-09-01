# frozen_string_literal: true

module Decidim
  module ExtraBlocks
    # Mirrors Decidim::ContentBlock#images_container with a video-only max_size
    # for BackgroundVideoUploader. Keep in sync with decidim-core when upgrading.
    module ContentBlockExtensions
      def images_container
        return @images_container if @images_container

        attachments = manifest_attachments

        @images_container = Class.new do
          include ActiveModel::Validations
          include Decidim::HasUploadValidations

          cattr_accessor :manifest_attachments
          attr_reader :content_block

          def self.name
            to_s.camelize
          end

          delegate :id, :organization, to: :content_block

          def initialize(content_block)
            @content_block = content_block
          end

          attachments.each do |name, attachment|
            uploader_class = attachment.uploader
            options = { uploader: uploader_class }
            if uploader_class.is_a?(Class) && uploader_class <= Decidim::ExtraBlocks::BackgroundVideoUploader
              options[:max_size] = Decidim::ExtraBlocks::BackgroundVideoUploader::MAX_FILE_SIZE
            end

            validates_upload name, **options

            define_method(name) do
              attachment.file
            end

            define_method("#{name}=") do |file|
              attachment.file = file
            end
          end

          def attached_uploader(name)
            return if manifest_attachments[name].blank?

            manifest_attachments[name].attached_uploader(:file)
          end

          def save
            return unless content_block.persisted?

            manifest_attachments.values.map(&:save).all?
          end
        end

        @images_container.manifest_attachments = manifest_attachments
        @images_container = @images_container.new(self)
      end
    end
  end
end
