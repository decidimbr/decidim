# frozen_string_literal: true

module Decidim
  module ExtraBlocks
    class FastProposalsController < Decidim::ApplicationController
      include Decidim::FormFactory

      skip_before_action :store_current_location

      def create
        form = form(Decidim::ExtraBlocks::FastProposalForm).from_params(params)

        Decidim::ExtraBlocks::CreateFastProposal.call(form, request) do
          on(:ok) do |_proposal, redirect_url|
            render json: { ok: true, redirect_url: }
          end

          on(:invalid) do |payload|
            render json: error_payload(payload), status: :unprocessable_entity
          end
        end
      end

      private

      def error_payload(payload)
        errors = normalize_errors(payload)
        {
          ok: false,
          error: base_message(errors),
          errors:
        }
      end

      def normalize_errors(payload)
        return payload.except(:reason).transform_values { |v| Array(v) } if payload.is_a?(Hash)

        { base: [reason_message(payload)] }
      end

      def base_message(errors)
        Array(errors[:base]).presence&.first ||
          Array(errors["base"]).presence&.first ||
          I18n.t("decidim.extra_blocks.fast_proposals.create.error")
      end

      def reason_message(reason)
        case reason
        when :ephemeral_authorization_missing
          I18n.t("decidim.extra_blocks.fast_proposals.create.ephemeral_authorization_missing")
        when :creation_disabled
          I18n.t("decidim.extra_blocks.fast_proposals.create.creation_disabled")
        else
          I18n.t("decidim.extra_blocks.fast_proposals.create.error")
        end
      end
    end
  end
end
