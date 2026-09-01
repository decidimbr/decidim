# frozen_string_literal: true

module Decidim
  module ExtraBlocks
    module Layouts
      # Fragment-cache Extra Blocks public layout cells with EXTRA_BLOCK_MAX_CACHE TTL.
      module Cacheable
        extend ActiveSupport::Concern

        included do
          include Decidim::ExtraBlocks::PictureHelper
        end

        private

        def cache_expiry_time
          Decidim::ExtraBlocks.max_cache
        end

        def cache_hash
          [
            self.class.name.underscore,
            Digest::SHA256.hexdigest(model.attributes.to_s),
            attachment_fingerprint,
            current_organization.cache_key_with_version,
            I18n.locale.to_s
          ].join(Decidim.cache_key_separator)
        end

        def attachment_fingerprint
          Layouts::LayoutRegistry.all_images.filter_map do |image|
            name = image[:name]
            next unless model.images_container.respond_to?(name)
            next unless model.images_container.public_send(name).attached?

            blob = model.images_container.public_send(name).blob
            blob&.checksum || blob&.id.to_s
          end.join("-")
        end
      end
    end
  end
end
