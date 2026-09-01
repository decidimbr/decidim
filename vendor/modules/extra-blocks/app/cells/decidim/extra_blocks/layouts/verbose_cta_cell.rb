# frozen_string_literal: true

module Decidim
  module ExtraBlocks
    module Layouts
      class VerboseCtaCell < BaseCell
        def title
          translated_attribute(model.settings.title)
        end

        def body
          translated_attribute(model.settings.body)
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
      end
    end
  end
end
