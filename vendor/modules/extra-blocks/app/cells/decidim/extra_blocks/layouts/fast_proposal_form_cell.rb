# frozen_string_literal: true

module Decidim
  module ExtraBlocks
    module Layouts
      # Shared participant form for all Fast Proposal layouts.
      class FastProposalFormCell < BaseCell
        include Decidim::ComponentPathHelper
        include Decidim::AuthorizationFormHelper
        include Decidim::DecidimFormHelper

        def proposal_component
          options[:proposal_component]
        end

        def guest?
          current_user.blank?
        end

        def authorization_needed?
          return false if authorization_name.blank?
          return true if guest?

          !authorization_granted?
        end

        def authorization_name
          current_organization.try(:ephemeral_participation_authorization)
        end

        def authorization_granted?
          return false if guest?
          return false if authorization_name.blank?

          Decidim::Authorization.find_by(user: current_user, name: authorization_name)&.granted?
        end

        def authorization_handler
          return if authorization_name.blank?

          @authorization_handler ||= Decidim::AuthorizationHandler.handler_for(
            authorization_name,
            handler_name: authorization_name,
            user: current_user
          )
        end

        def terms_html
          custom = translated_attribute(model.settings.terms)
          return custom if custom.present?

          platform_terms_html
        end

        def platform_terms_html
          page = Decidim::StaticPage.find_by(
            slug: "terms-of-service",
            organization: model.organization
          )
          return "" if page.blank?

          translated_attribute(page.content)
        end

        def success_message
          raw = translated_attribute(model.settings.success_message)
          raw = raw.presence || "Thanks for submitting your proposal, you will be redirected in {{seconds}}sec."
          Decidim::ExtraBlocks::FastProposal::TemplateInterpolator.interpolate(
            raw,
            id: "",
            random: "",
            seconds: success_time
          )
        end

        def success_button_label
          value = translated_attribute(model.settings.success_button_label)
          value.presence || I18n.t("decidim.extra_blocks.layouts.fast_proposal_settings_form.success_button_label")
        end

        def success_time
          value = model.settings.success_time.to_i
          value.positive? ? value : 15
        end

        def redirect_url
          main_component_path(proposal_component)
        end

        def create_path
          Decidim::ExtraBlocks::Engine.routes.url_helpers.fast_proposals_path
        end

        def platform_terms_path
          decidim.page_path("terms-of-service", locale: I18n.locale)
        end

        def login_path
          decidim.new_user_session_path(locale: I18n.locale)
        end

        def form_data
          {
            controller: "extra-blocks-fast-proposal-form",
            turbo: false,
            extra_blocks_fast_proposal_form_url_value: create_path,
            extra_blocks_fast_proposal_form_redirect_url_value: redirect_url,
            extra_blocks_fast_proposal_form_success_time_value: success_time,
            extra_blocks_fast_proposal_form_success_message_value: success_message,
            extra_blocks_fast_proposal_form_success_button_label_value: success_button_label,
            extra_blocks_fast_proposal_form_content_block_id_value: model.id
          }
        end
      end
    end
  end
end
