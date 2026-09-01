# frozen_string_literal: true

module Decidim
  module ExtraBlocks
    module ContentBlocks
      class SettingsFormCell < Decidim::ViewModel
        alias form model

        def show
          if layout_frozen?
            render :layout_form
          else
            render :gallery
          end
        end

        def content_block
          options[:content_block]
        end

        def layout_manifest
          @layout_manifest ||= Layouts::LayoutRegistry.find(content_block.settings.layout)
        end

        def layout_frozen?
          layout_manifest.present?
        end
      end
    end
  end
end
