# frozen_string_literal: true

module Decidim
  module ExtraBlocks
    module ContentBlocks
      class LayoutGalleryCell < Decidim::ViewModel
        alias form model

        def content_block
          options[:content_block]
        end

        def categories
          Decidim::ExtraBlocks::Availability.effective_categories(current_organization)
        end

        def layouts_for(category)
          Layouts::LayoutRegistry.for_category(category)
        end

        def category_label(category)
          I18n.t("decidim.extra_blocks.categories.#{category}")
        end

        def preview_path(layout)
          safe_pack_path(layout.preview_image)
        end

        def screenshot_path(path)
          safe_pack_path(path)
        end

        def safe_pack_path(path)
          asset_pack_path(path)
        rescue StandardError
          ""
        end
      end
    end
  end
end
