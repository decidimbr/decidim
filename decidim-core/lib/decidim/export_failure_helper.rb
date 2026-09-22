# frozen_string_literal: true

module Decidim
  module ExportFailureHelper
    def notify_export_failure(user, name, error)
      ExportMailer.export_failed(user, name, error.message).deliver_later if user&.email.present?
    end
  end
end
