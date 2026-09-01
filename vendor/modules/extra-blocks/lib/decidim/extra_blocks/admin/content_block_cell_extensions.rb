# frozen_string_literal: true

module Decidim
  module ExtraBlocks
    module Admin
      # Shows frozen layout in the ContentBlock DnD list label.
      module ContentBlockCellExtensions
        def name
          return Decidim::ExtraBlocks::AdminDisplayName.for(model) if extra_block?

          super
        end

        private

        def extra_block?
          model.respond_to?(:manifest_name) && model.manifest_name.to_s == "extra_block"
        end
      end
    end
  end
end
