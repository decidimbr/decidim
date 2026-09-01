# frozen_string_literal: true

module Decidim
  module ExtraBlocks
    module FastProposal
      # Fail-closed gate for Fast Proposal public UI and create command.
      module EphemeralGate
        module_function

        def open?(component)
          closed_reasons(component).empty?
        end

        # Returns i18n reason keys for admin callouts. Empty when the block may render.
        # ponytail: closed_reasons mirrors open? only; upgrade if admin needs rich remediation links per reason
        def closed_reasons(component)
          return [:missing_component] if component.blank?

          reasons = []
          reasons << :creation_disabled unless creation_enabled?(component)
          reasons << :ephemeral_creation_disabled unless ephemeral_creation_setting?(component)
          reasons << :missing_organization_ephemeral_authorization if organization_authorization(component).blank?
          reasons << :missing_ephemeral_authorization_in_permissions unless create_permission?(component)
          reasons
        end

        def creation_enabled?(component)
          component.current_settings.creation_enabled?
        end

        def ephemeral_creation_setting?(component)
          component.settings.try(:ephemeral_participation_enabled) == true
        end

        def organization_authorization(component)
          component.organization.try(:ephemeral_participation_authorization)
        end

        def create_permission?(component)
          auth = organization_authorization(component)
          return false if auth.blank?

          handlers = permissions_handlers(component)
          handlers.is_a?(Hash) && handlers.key?(auth)
        end

        def permissions_handlers(component)
          (component.permissions || {}).with_indifferent_access.dig("create", "authorization_handlers")
        end
      end
    end
  end
end
