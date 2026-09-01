# frozen_string_literal: true

module Decidim
  module ExtraBlocks
    class CreateFastProposal < Decidim::Command
      include ::Devise::Controllers::Helpers

      def initialize(form, request)
        @form = form
        @request = request
        @errors = Hash.new { |hash, key| hash[key] = [] }
      end

      def call
        return broadcast_form_invalid if form.invalid?
        return broadcast_reason(:creation_disabled) unless gate_open?
        return broadcast_reason(:ephemeral_authorization_missing) if authorization_name.blank?

        perform!
      rescue StandardError => e
        handle_unexpected_error(e)
      end

      private

      attr_reader :form, :request, :errors

      def perform!
        @user = resolve_user!
        return broadcast_handler_invalid unless authorize_user!

        create_and_publish_proposal!
        broadcast(:ok, @proposal, redirect_url)
      end

      def handle_unexpected_error(error)
        log_error(error)
        cleanup_ephemeral_user!
        return broadcast(:invalid, errors) if errors_present?

        broadcast_reason(:error)
      end

      def errors_present?
        errors.values.any?(&:present?)
      end

      def broadcast_form_invalid
        merge_model_errors(form)
        broadcast(:invalid, errors)
      end

      def broadcast_handler_invalid
        cleanup_ephemeral_user!
        broadcast(:invalid, errors)
      end

      def broadcast_reason(reason)
        errors[:base] << reason_message(reason) if errors[:base].empty?
        broadcast(:invalid, errors.merge(reason:))
      end

      def reason_message(reason)
        I18n.t(
          reason,
          scope: "decidim.extra_blocks.fast_proposals.create",
          default: I18n.t("decidim.extra_blocks.fast_proposals.create.error")
        )
      end

      def gate_open?
        Decidim::ExtraBlocks::FastProposal::EphemeralGate.open?(component)
      end

      def organization
        form.current_organization
      end

      def component
        form.proposal_component
      end

      def content_block
        form.content_block
      end

      def authorization_name
        form.authorization_name
      end

      def resolve_user!
        return form.current_user if form.logged_in?

        create_ephemeral_user!
      end

      def create_ephemeral_user!
        inject_ephemeral_params!
        raise StandardError, "CreateEphemeralParticipant failed" unless create_ephemeral_ok?

        user = session_user
        raise StandardError, "Ephemeral user missing after sign_in" if user.blank?

        @created_ephemeral_user = user
        user
      end

      def create_ephemeral_ok?
        created = false
        Decidim::EphemeralParticipation::CreateEphemeralParticipant.call(request, nil) do
          on(:ok) { created = true }
          on(:invalid) { created = false }
        end
        created
      end

      def inject_ephemeral_params!
        request.params[:component_id] = component.id
        request.params[:ephemeral_participation_path] = redirect_url
      end

      def session_user
        warden.user(:user) || warden.user
      end

      def authorize_user!
        return true unless form.authorization_needed?
        return true if authorization_granted?(@user)

        handler = form.build_authorization_handler(@user)
        return add_authorization_missing_error if handler.blank?

        run_authorize_user(handler)
      end

      def add_authorization_missing_error
        errors[:base] << reason_message(:ephemeral_authorization_missing)
        false
      end

      def authorization_granted?(user)
        Decidim::Authorization.find_by(user:, name: authorization_name)&.granted?
      end

      def run_authorize_user(handler)
        if authorize_outcome(handler) == :ok && authorization_granted?(@user)
          return true
        end

        merge_model_errors(handler)
        errors[:base] << reason_message(:error) if errors[:base].empty?
        false
      end

      def authorize_outcome(handler)
        outcome = :invalid
        Decidim::Verifications::AuthorizeUser.call(handler, organization) do
          on(:ok) { outcome = :ok }
          on(:transferred) { outcome = :ok }
          on(:transfer_user) do |transferred_user|
            adopt_transferred_user!(transferred_user)
            outcome = :ok
          end
          on(:invalid) { outcome = :invalid }
        end
        outcome
      end

      def adopt_transferred_user!(transferred_user)
        orphan = @created_ephemeral_user
        @user = transferred_user
        @created_ephemeral_user = nil
        sign_in(transferred_user) if respond_to?(:sign_in, true)
        return if orphan.blank? || orphan.id == transferred_user.id

        orphan.destroy!
      rescue StandardError => e
        log_error(e)
      end

      def create_and_publish_proposal!
        @random = format("%09d", SecureRandom.random_number(10**9))
        title = interpolate_title(@user.id, @random)
        @proposal = create_proposal!(build_proposal_form(title))
        publish_proposal!
      end

      def build_proposal_form(title)
        Decidim::Proposals::ProposalForm.from_params(
          title:,
          body: form.body.to_s
        ).with_context(proposal_form_context)
      end

      def proposal_form_context
        {
          current_user: @user,
          current_organization: organization,
          current_participatory_space: component.participatory_space,
          current_component: component
        }
      end

      def create_proposal!(proposal_form)
        created_proposal = nil
        Decidim::Proposals::CreateProposal.call(proposal_form, @user) do
          on(:ok) { |proposal| created_proposal = proposal }
          on(:invalid) { raise_proposal_invalid(proposal_form) }
        end
        raise StandardError, "CreateProposal returned no proposal" if created_proposal.blank?

        created_proposal
      end

      def raise_proposal_invalid(proposal_form)
        merge_model_errors(proposal_form)
        raise StandardError, "CreateProposal invalid"
      end

      def publish_proposal!
        Decidim::Proposals::PublishProposal.call(@proposal, @user) do
          on(:ok) { nil }
          on(:invalid) { raise StandardError, "PublishProposal invalid" }
        end
      end

      def interpolate_title(user_id, random)
        title = normalized_title(title_template, user_id, random)
        return title if interpolator.valid_proposal_title?(title)

        normalized_title(fallback_title_template, user_id, random)
      end

      def normalized_title(template, user_id, random)
        interpolator.normalize_proposal_title(template, id: user_id, random:)
      end

      def interpolator
        Decidim::ExtraBlocks::FastProposal::TemplateInterpolator
      end

      def title_template
        if form.logged_in?
          content_block.settings.default_title_connected.presence || fallback_title_template
        else
          content_block.settings.default_title.presence || fallback_title_template
        end
      end

      def fallback_title_template
        form.logged_in? ? "Proposal from {{id}}" : "Anonymous Proposal {{id}}"
      end

      def merge_model_errors(model)
        model.errors.each do |error|
          errors[error.attribute] << error.message
        end
      end

      def cleanup_ephemeral_user!
        return unless @created_ephemeral_user

        destroy_ephemeral_user!
      rescue StandardError => e
        log_error(e)
      end

      def destroy_ephemeral_user!
        sign_out(@created_ephemeral_user) if respond_to?(:sign_out, true)
        @created_ephemeral_user.destroy!
        @created_ephemeral_user = nil
      end

      def redirect_url
        Decidim::EngineRouter.main_proxy(component).root_path
      end

      def log_error(error)
        Rails.logger.error(
          "[ExtraBlocks::CreateFastProposal] #{error.class}: #{error.message}\n#{error.backtrace&.first(10)&.join("\n")}"
        )
      end

      def session
        request.session
      end

      def warden
        request.env["warden"]
      end
    end
  end
end
