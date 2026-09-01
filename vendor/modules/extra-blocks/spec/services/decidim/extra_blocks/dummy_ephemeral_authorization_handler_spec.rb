# frozen_string_literal: true

require "spec_helper"

describe Decidim::ExtraBlocks::DummyEphemeralAuthorizationHandler do
  subject { described_class.from_params(phone_number:) }

  let(:user) { create(:user, :confirmed) }
  let(:phone_number) { "+33 6 12 34 56 78" }

  before { subject.user = user }

  it "is valid with a phone number" do
    expect(subject).to be_valid
    expect(subject.unique_id).to eq("33612345678")
  end

  it "is registered as an ephemerable workflow" do
    workflow = Decidim.authorization_handlers.find { |item| item.name == "dummy_ephemeral_authorization_handler" }
    expect(workflow).to be_present
    expect(workflow.ephemerable).to be(true)
    expect(workflow.form).to eq("Decidim::ExtraBlocks::DummyEphemeralAuthorizationHandler")
  end

  it "exposes Phone number as the public name" do
    expect(I18n.t("decidim.authorization_handlers.dummy_ephemeral_authorization_handler.name")).to eq("Phone number")
    expect(described_class.human_attribute_name(:phone_number)).to eq("Phone number")
  end

  it "defines admin help" do
    expect(I18n.exists?("decidim.authorization_handlers.admin.dummy_ephemeral_authorization_handler.help")).to be(true)
  end

  it "translates the ephemeral participant display name" do
    expect(I18n.t("decidim.ephemeral_participation.ephemeral_participants.name", number: 12)).to eq("Participant 12")
  end

  context "when phone number is blank" do
    let(:phone_number) { "" }

    it { is_expected.to be_invalid }

    it "uses a translated blank error" do
      subject.valid?
      expect(subject.errors[:phone_number].join).not_to match(/translation missing/i)
    end
  end

  context "when phone number is too short" do
    let(:phone_number) { "123" }

    it { is_expected.to be_invalid }

    it "uses a translated invalid error" do
      subject.valid?
      expect(subject.errors[:phone_number].join).not_to match(/translation missing/i)
    end
  end

  describe "#user_transferrable?" do
    subject { Decidim::AuthorizationHandler.handler_for("dummy_ephemeral_authorization_handler", phone_number:).tap { |h| h.user = user } }

    let(:organization) { create(:organization) }
    let(:user) do
      create(
        :user,
        :confirmed,
        organization:,
        managed: true,
        extended_data: {
          "ephemeral_participation" => {
            "authorization_name" => "dummy_ephemeral_authorization_handler"
          }
        }
      )
    end
    let(:phone_number) { "+33 6 12 34 56 78" }

    it "is false without a duplicate" do
      expect(subject).not_to be_user_transferrable
    end

    context "when another ephemeral participant owns the same unique_id" do
      let!(:other_user) do
        create(
          :user,
          :confirmed,
          organization:,
          managed: true,
          extended_data: {
            "ephemeral_participation" => {
              "authorization_name" => "dummy_ephemeral_authorization_handler"
            }
          }
        )
      end
      let!(:authorization) do
        create(
          :authorization,
          :granted,
          user: other_user,
          name: "dummy_ephemeral_authorization_handler",
          unique_id: "33612345678"
        )
      end

      it { is_expected.to be_user_transferrable }
    end
  end
end
