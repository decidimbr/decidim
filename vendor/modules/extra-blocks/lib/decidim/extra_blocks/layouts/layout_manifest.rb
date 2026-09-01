# frozen_string_literal: true

module Decidim
  module ExtraBlocks
    module Layouts
      class LayoutManifest
        include ActiveModel::Model

        attr_accessor :name, :category, :public_name_key, :description_key,
                      :preview_image, :cell, :settings_form_cell, :images, :screenshots

        validates :name, :category, :public_name_key, :description_key,
                  :preview_image, :cell, :settings_form_cell, presence: true
        validate :screenshots_count

        def settings(&)
          @settings ||= Decidim::SettingsManifest.new
          yield(@settings) if block_given?
          @settings
        end

        private

        def screenshots_count
          list = Array(screenshots)
          return if list.size == 3

          errors.add(:screenshots, "must contain exactly 3 paths")
        end
      end
    end
  end
end
