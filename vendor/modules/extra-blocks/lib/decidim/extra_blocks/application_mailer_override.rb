# frozen_string_literal: true

module Decidim
  module ExtraBlocks
    # Silence delivery for @example.org addresses (NCA / managed Fast Proposal users).
    module ApplicationMailerOverride
      extend ActiveSupport::Concern

      included do
        alias_method :decidim_extra_blocks_original_mail, :mail

        def mail(headers = {}, &)
          mail_object = decidim_extra_blocks_original_mail(headers, &)
          return mail_object unless headers[:to]

          recipients = Array(headers[:to]).map(&:to_s)
          if recipients.any? { |address| address.end_with?("example.org") }
            mail_object.perform_deliveries = false
          end

          mail_object
        end
      end
    end
  end
end
