# frozen_string_literal: true

require "spec_helper"

describe Decidim::ExtraBlocks::ApplicationMailerOverride do
  let(:mailer_class) do
    Class.new(Decidim::ApplicationMailer) do
      def test_mail(address)
        mail(to: address, subject: "Hello", body: "Body")
      end
    end
  end

  before do
    mailer_class.include(described_class) unless mailer_class.included_modules.include?(described_class)
  end

  it "disables delivery for example.org recipients" do
    message = mailer_class.new.test_mail("someone@example.org")
    expect(message.perform_deliveries).to be(false)
  end

  it "keeps delivery for other recipients" do
    message = mailer_class.new.test_mail("someone@example.com")
    expect(message.perform_deliveries).not_to be(false)
  end
end
