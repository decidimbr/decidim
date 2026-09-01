# frozen_string_literal: true

module Decidim
  module ExtraBlocks
    module Layouts
      # Shared base for public Extra Blocks layout cells (caching + picture helper).
      class BaseCell < Decidim::ViewModel
        include Cacheable

        def show
          # Bare `render` + Decidim instrumented `#call` can resolve to `block.erb`.
          render :show
        end

        def text_color_value
          return "#ffffff" if text_color_white?

          "#020203"
        end

        def section_style
          [base_section_style, background_fit_style].compact.join(" ")
        end

        private

        def base_section_style
          "--eb-bg: #{background_color}; --eb-fg: #{text_color_value};"
        end

        def background_fit_style
          return unless background_fit_setting?

          "--eb-bg-fit: #{sanitized_background_fit};"
        end

        def background_fit_setting?
          model.settings.respond_to?(:background_fit)
        end

        def sanitized_background_fit
          value = model.settings.background_fit.to_s
          return value if RegisterDefaults::BACKGROUND_FITS.include?(value)

          "cover"
        end

        def text_color_white?
          model.settings.respond_to?(:text_color) && model.settings.text_color.to_s == "white"
        end
      end
    end
  end
end
