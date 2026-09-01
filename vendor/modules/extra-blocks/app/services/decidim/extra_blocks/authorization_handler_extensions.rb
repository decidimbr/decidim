# frozen_string_literal: true

module Decidim
  module ExtraBlocks
    # Completes the contract expected by decidim-ephemeral_participation's
    # AuthorizeUserOverride (calls handler.user_transferrable? but never defines it).
    module AuthorizationHandlerExtensions
      extend ActiveSupport::Concern

      # When unique_id already belongs to another ephemeral participant, AuthorizeUser
      # reuses that participant instead of failing uniqueness.
      def user_transferrable?
        return false unless user&.try(:ephemeral_participant?)
        return false if duplicate.blank?

        duplicate.user.try(:ephemeral_participant?)
      end
    end
  end
end
