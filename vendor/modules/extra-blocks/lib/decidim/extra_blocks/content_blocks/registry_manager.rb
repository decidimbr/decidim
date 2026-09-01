# frozen_string_literal: true

module Decidim
  module ExtraBlocks
    module ContentBlocks
      class RegistryManager
        SCOPES = %i[
          homepage
          participatory_process_homepage
          participatory_process_group_homepage
          assembly_homepage
        ].freeze

        def self.register!
          Decidim::ExtraBlocks::Layouts::RegisterDefaults.call
          SCOPES.each { |scope| register_for(scope) }
        end

        def self.register_for(scope)
          Decidim.content_blocks.register(scope, :extra_block) do |content_block|
            content_block.cell = "decidim/extra_blocks/content_blocks/extra_block"
            content_block.settings_form_cell = "decidim/extra_blocks/content_blocks/settings_form"
            content_block.public_name_key = "decidim.extra_blocks.content_blocks.extra_block.name"
            content_block.images = Decidim::ExtraBlocks::Layouts::LayoutRegistry.all_images

            content_block.settings do |settings|
              # string (not enum): blank until the admin freezes a layout
              settings.attribute :layout, type: :string, default: nil
              Decidim::ExtraBlocks::Layouts::LayoutRegistry.merge_settings!(settings)
            end
          end
        end
      end
    end
  end
end
