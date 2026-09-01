# frozen_string_literal: true

require_relative "extra_blocks/version"
require_relative "extra_blocks/image_capabilities"
require_relative "extra_blocks/permanent_media_url"
require_relative "extra_blocks/pngquant_optimizer"
require_relative "extra_blocks/variant_processor"
require_relative "extra_blocks/layouts/layout_manifest"
require_relative "extra_blocks/layouts/layout_registry"
require_relative "extra_blocks/layouts/dynamic_logos"
require_relative "extra_blocks/layouts/dynamic_events"
require_relative "extra_blocks/layouts/dynamic_ordered_slots"
require_relative "extra_blocks/layouts/dynamic_topics"
require_relative "extra_blocks/layouts/dynamic_steps"
require_relative "extra_blocks/layouts/dynamic_stats"
require_relative "extra_blocks/layouts/dynamic_asides"
require_relative "extra_blocks/layouts/register_defaults"
require_relative "extra_blocks/layouts/cacheable"
require_relative "extra_blocks/content_blocks/registry_manager"
require_relative "extra_blocks/admin/content_block_form_extensions"
require_relative "extra_blocks/admin/landing_page_content_blocks_extensions"
require_relative "extra_blocks/direct_upload_extensions"
require_relative "extra_blocks/content_block_extensions"
require_relative "extra_blocks/content_block_attachment_extensions"
require_relative "extra_blocks/availability"
require_relative "extra_blocks/body_data_attributes"
require_relative "extra_blocks/admin_list_item_data"
require_relative "extra_blocks/admin_display_name"
require_relative "extra_blocks/admin/content_block_cell_extensions"
require_relative "extra_blocks/fast_proposal/template_interpolator"
require_relative "extra_blocks/fast_proposal/ephemeral_gate"
require_relative "extra_blocks/application_mailer_override"
require_relative "extra_blocks/settings_tab"
require_relative "extra_blocks/seeds"
require_relative "extra_blocks/seed_hook"
require_relative "extra_blocks/engine"

module Decidim
  module ExtraBlocks
    class Error < StandardError; end

    MODULE_NAME = "decidim_extra_blocks"

    class << self
      # Fragment cache TTL for Extra Blocks cells (minutes from EXTRA_BLOCK_MAX_CACHE).
      def max_cache
        Decidim::Env.new("EXTRA_BLOCK_MAX_CACHE", "60").to_i.minutes
      end

      def vips_webp?
        ImageCapabilities.vips_webp?
      end

      def pngquant?
        ImageCapabilities.pngquant?
      end
    end
  end
end
