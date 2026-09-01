# frozen_string_literal: true

module Decidim
  module ExtraBlocks
    module Layouts
      # Shared base for layout settings-form cells.
      # Bare `render` + Decidim instrumented `#call` can resolve to `block.erb`.
      class BaseSettingsFormCell < Decidim::ViewModel
        include ::Cell::ViewModel::Partial

        alias form model

        def show
          render :show
        end

        def content_block
          options[:content_block]
        end
      end
    end
  end
end
