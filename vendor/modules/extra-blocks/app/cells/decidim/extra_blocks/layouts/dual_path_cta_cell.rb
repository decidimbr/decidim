# frozen_string_literal: true

module Decidim
  module ExtraBlocks
    module Layouts
      class DualPathCtaCell < BaseCell
        def title
          translated_attribute(model.settings.title)
        end

        def background_color
          model.settings.background_color.presence || "#FAFBFC"
        end

        def background_image?
          model.images_container.respond_to?(:background_image) &&
            model.images_container.background_image.attached?
        end

        def background_image_uploader
          return unless background_image?

          model.images_container.attached_uploader(:background_image)
        end

        def prose_classes
          model.settings.text_color.to_s == "white" ? "prose prose-invert" : "prose"
        end

        def alignment
          value = model.settings.alignment.to_s
          %w(left center).include?(value) ? value : "left"
        end

        def alignment_class
          "extra-blocks-dual-path-cta--align-#{alignment}"
        end

        def primary_background_color
          model.settings.primary_background_color.presence || "#ffffff"
        end

        def primary_prose_classes
          model.settings.primary_text_color.to_s == "white" ? "prose prose-invert" : "prose"
        end

        def primary_text_color_value
          model.settings.primary_text_color.to_s == "white" ? "#ffffff" : "#020203"
        end

        def primary_title
          translated_attribute(model.settings.primary_title)
        end

        def primary_body
          translated_attribute(model.settings.primary_body)
        end

        def primary_button_label
          translated_attribute(model.settings.primary_button_label)
        end

        def primary_button_url
          model.settings.primary_button_url.to_s
        end

        def primary_path_linked?
          primary_button_url.present?
        end

        def show_primary_button?
          primary_button_label.present? && primary_path_linked?
        end

        def secondary_background_color
          model.settings.secondary_background_color.presence || "#020203"
        end

        def secondary_prose_classes
          model.settings.secondary_text_color.to_s == "white" ? "prose prose-invert" : "prose"
        end

        def secondary_text_color_value
          model.settings.secondary_text_color.to_s == "white" ? "#ffffff" : "#020203"
        end

        def secondary_title
          translated_attribute(model.settings.secondary_title)
        end

        def secondary_body
          translated_attribute(model.settings.secondary_body)
        end

        def secondary_button_label
          translated_attribute(model.settings.secondary_button_label)
        end

        def secondary_button_url
          model.settings.secondary_button_url.to_s
        end

        def secondary_path_linked?
          secondary_button_url.present?
        end

        def show_secondary_button?
          secondary_button_label.present? && secondary_path_linked?
        end

        def path_tag(side)
          public_send(:"#{side}_path_linked?") ? :a : :div
        end

        def path_html_options(side)
          options = {
            class: "extra-blocks__card extra-blocks-dual-path-cta__path extra-blocks-dual-path-cta__path--#{side} #{public_send(:"#{side}_prose_classes")}",
            style: "--eb-path-bg: #{public_send(:"#{side}_background_color")}; --eb-path-fg: #{public_send(:"#{side}_text_color_value")};"
          }
          options[:href] = public_send(:"#{side}_button_url") if public_send(:"#{side}_path_linked?")
          options
        end
      end
    end
  end
end
