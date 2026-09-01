# frozen_string_literal: true

module Decidim
  module ExtraBlocks
    module Layouts
      # Shared proposal-component resolution + EphemeralGate visibility for Fast Proposal layouts.
      module FastProposalVisibility
        extend ActiveSupport::Concern

        included do
          include Decidim::ComponentPathHelper
        end

        def proposal_component
          @proposal_component ||= resolve_proposal_component
        end

        def visible?
          Decidim::ExtraBlocks::FastProposal::EphemeralGate.open?(proposal_component)
        end

        private

        def resolve_proposal_component
          id = model.settings.proposal_component_id.to_s
          return if id.blank?

          component = Decidim::Component.published.find_by(id:, manifest_name: "proposals")
          return unless component&.organization == model.organization

          component
        end
      end
    end
  end
end
