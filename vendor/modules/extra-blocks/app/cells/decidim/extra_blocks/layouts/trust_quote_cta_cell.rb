# frozen_string_literal: true

module Decidim
  module ExtraBlocks
    module Layouts
      class TrustQuoteCtaCell < BaseCell
        def quote
          translated_attribute(model.settings.quote)
        end

        def attribution_name
          translated_attribute(model.settings.attribution_name)
        end

        def attribution_role
          translated_attribute(model.settings.attribution_role)
        end

        def background_color
          model.settings.background_color.presence || "#020203"
        end

        def prose_classes
          model.settings.text_color.to_s == "white" ? "prose prose-invert" : "prose"
        end

        def button_label
          translated_attribute(model.settings.button_label)
        end

        def button_url
          model.settings.button_url.to_s
        end

        def show_button?
          button_label.present? && button_url.present?
        end

        def portrait?
          model.images_container.respond_to?(:portrait) &&
            model.images_container.portrait.attached?
        end

        def portrait_uploader
          return unless portrait?

          model.images_container.attached_uploader(:portrait)
        end
      end
    end
  end
end
