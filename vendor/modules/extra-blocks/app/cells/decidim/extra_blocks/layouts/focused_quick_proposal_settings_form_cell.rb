# frozen_string_literal: true

module Decidim
  module ExtraBlocks
    module Layouts
      class FocusedQuickProposalSettingsFormCell < BaseSettingsFormCell
        def proposal_components
          organization = content_block.organization
          return [] if organization.blank?

          organization.published_components.where(manifest_name: "proposals").map do |component|
            space_name = translated_attribute(component.participatory_space.try(:title) || component.participatory_space.try(:name))
            component_name = translated_attribute(component.name)
            ["#{space_name} — #{component_name}", component.id]
          end
        end

        def proposal_component
          return @proposal_component if defined?(@proposal_component)

          id = form.object.settings.try(:proposal_component_id).presence ||
               content_block.settings.try(:proposal_component_id).presence
          @proposal_component = resolve_proposal_component(id)
        end

        def gate_callout
          reasons = Decidim::ExtraBlocks::FastProposal::EphemeralGate.closed_reasons(proposal_component)
          return gate_open_callout if reasons.empty?

          {
            title: t("decidim.extra_blocks.layouts.fast_proposal_settings_form.gate_warning_title"),
            body: gate_reasons_list(reasons),
            callout_class: "warning"
          }
        end

        private

        def resolve_proposal_component(id)
          return if id.blank?

          component = Decidim::Component.published.find_by(id:, manifest_name: "proposals")
          return unless component
          return unless component.organization == content_block.organization

          component
        end

        def gate_open_callout
          {
            title: t("decidim.extra_blocks.layouts.fast_proposal_settings_form.gate_ok_title"),
            body: t("decidim.extra_blocks.layouts.fast_proposal_settings_form.gate_ok_body"),
            callout_class: "success"
          }
        end

        def gate_reasons_list(reasons)
          items = reasons.map do |reason|
            content_tag(:li, t("decidim.extra_blocks.layouts.fast_proposal_settings_form.gate_reasons.#{reason}"))
          end
          content_tag(:div, content_tag(:ul, safe_join(items)), class: "rich-text-display")
        end
      end
    end
  end
end
