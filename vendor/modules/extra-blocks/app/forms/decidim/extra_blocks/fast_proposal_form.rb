# frozen_string_literal: true

module Decidim
  module ExtraBlocks
    class FastProposalForm < Decidim::Form
      include Decidim::TranslatableAttributes

      attribute :content_block_id, Integer
      attribute :body, String
      attribute :accept_terms, Boolean
      attribute :authorization_handler, Hash, default: {}

      validates :content_block_id, presence: true
      validates :body, presence: true
      validates :accept_terms, acceptance: true
      validate :content_block_and_component_usable
      validate :authorization_handler_valid

      def content_block
        @content_block ||= Decidim::ContentBlock.find_by(
          id: content_block_id,
          organization: current_organization,
          manifest_name: "extra_block"
        )
      end

      def proposal_component
        return @proposal_component if defined?(@proposal_component)

        @proposal_component = resolve_proposal_component
      end

      def logged_in?
        current_user.present?
      end

      def authorization_name
        current_organization.try(:ephemeral_participation_authorization)
      end

      def authorization_needed?
        return false if authorization_name.blank?
        return true unless logged_in?

        !authorization_granted?
      end

      def authorization_granted?
        return false unless logged_in?
        return false if authorization_name.blank?

        Decidim::Authorization.find_by(user: current_user, name: authorization_name)&.granted?
      end

      def build_authorization_handler(user = current_user)
        return if authorization_name.blank?

        Decidim::AuthorizationHandler.handler_for(
          authorization_name,
          authorization_handler_params.merge(user:)
        )
      end

      private

      def resolve_proposal_component
        return if content_block.blank?

        component = Decidim::Component.published.find_by(
          id: content_block.settings.proposal_component_id,
          manifest_name: "proposals"
        )
        return unless component
        return unless component.organization == current_organization

        component
      end

      def authorization_handler_params
        raw = authorization_handler
        raw = raw.to_unsafe_h if raw.respond_to?(:to_unsafe_h)
        raw.to_h.with_indifferent_access
      end

      def content_block_and_component_usable
        if content_block.blank?
          errors.add(:content_block_id, :invalid)
          return
        end

        if proposal_component.blank?
          errors.add(:base, :invalid)
          return
        end

        return if Decidim::ExtraBlocks::FastProposal::EphemeralGate.open?(proposal_component)

        errors.add(:base, :invalid)
      end

      def authorization_handler_valid
        return unless authorization_needed?

        handler = build_authorization_handler
        if handler.blank?
          errors.add(:base, :invalid)
          return
        end

        return if handler.valid?

        handler.errors.each do |error|
          errors.add(error.attribute, error.message)
        end
      end
    end
  end
end
