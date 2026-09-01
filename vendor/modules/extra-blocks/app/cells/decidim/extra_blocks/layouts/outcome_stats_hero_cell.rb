# frozen_string_literal: true

module Decidim
  module ExtraBlocks
    module Layouts
      class OutcomeStatsHeroCell < BaseCell
        def title
          translated_attribute(model.settings.title)
        end

        def intro
          translated_attribute(model.settings.intro)
        end

        def background_color
          model.settings.background_color.presence || "#020203"
        end

        def prose_classes
          model.settings.text_color.to_s == "white" ? "prose prose-invert" : "prose"
        end

        def stats
          DynamicStats.entries_for(model) { |slot| stat_filled?(slot) }.filter_map do |entry|
            index = entry[:slot]
            value = translated_attribute(model.settings.public_send(:"stat_#{index}_value"))
            label = translated_attribute(model.settings.public_send(:"stat_#{index}_label"))
            next if value.blank? && label.blank?

            { value:, label: }
          end
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

        private

        def stat_filled?(slot)
          value = model.settings.public_send(:"stat_#{slot}_value")
          label = model.settings.public_send(:"stat_#{slot}_label")
          DynamicStats.translated_present?(value) || DynamicStats.translated_present?(label)
        end
      end
    end
  end
end
