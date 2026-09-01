# frozen_string_literal: true

module Decidim
  module ExtraBlocks
    module Admin
      # Persists Extra Blocks toggle config without wiping category flags when the
      # module is disabled (disabled checkboxes are omitted / false on submit).
      class UpdateConfigCommand < Decidim::Command
        def initialize(organization, form)
          @organization = organization
          @form = form
        end

        def call
          return broadcast(:invalid) if form.class.module_config_name.blank?
          return broadcast(:invalid) if form.invalid?

          Decidim::Toggle.save_config!(
            organization,
            form.class.module_config_name,
            form.persistable_attributes
          )
          broadcast(:ok)
        rescue ActiveRecord::RecordInvalid
          broadcast(:invalid)
        end

        private

        attr_reader :organization, :form
      end
    end
  end
end
