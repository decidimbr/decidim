# frozen_string_literal: true

module Decidim
  module ExtraBlocks
    # Demo ephemeral authorization: phone number only (for Fast Proposal demos).
    class DummyEphemeralAuthorizationHandler < Decidim::AuthorizationHandler
      attribute :phone_number, String

      validates :phone_number, presence: true
      validate :valid_phone_number

      def unique_id
        normalized_phone
      end

      def metadata
        super.merge(phone_number: normalized_phone)
      end

      def form_attributes
        [:phone_number]
      end

      private

      def normalized_phone
        phone_number.to_s.gsub(/\D/, "")
      end

      def valid_phone_number
        return if normalized_phone.match?(/\A\d{8,15}\z/)

        errors.add(:phone_number, :invalid)
      end
    end
  end
end
