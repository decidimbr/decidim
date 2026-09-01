# frozen_string_literal: true

require "spec_helper"

describe Decidim::ExtraBlocks::FastProposalForm, type: :form do
  subject do
    described_class.from_params(params).with_context(
      current_organization: organization,
      current_user: nil
    )
  end

  let(:organization) { create(:organization, available_authorizations: %w(dummy_authorization_handler)) }
  let(:participatory_process) { create(:participatory_process, :with_steps, organization:) }
  let(:component) do
    create(
      :proposal_component,
      :published,
      :with_creation_enabled,
      participatory_space: participatory_process,
      settings: { ephemeral_participation_enabled: true },
      permissions: {
        "create" => {
          "authorization_handlers" => {
            "dummy_authorization_handler" => {}
          }
        }
      }
    )
  end
  let(:content_block) do
    create(
      :content_block,
      organization:,
      manifest_name: :extra_block,
      scope_name: :homepage,
      settings: {
        "layout" => "focused_quick_proposal",
        "proposal_component_id" => component.id.to_s
      }
    )
  end
  let(:params) do
    {
      content_block_id: content_block.id,
      body: "A valid proposal body for the form.",
      accept_terms: true,
      authorization_handler: {
        handler_name: "dummy_authorization_handler",
        document_number: "123456789X"
      }
    }
  end

  before do
    allow_any_instance_of(Decidim::Organization)
      .to receive(:ephemeral_participation_authorization)
      .and_return("dummy_authorization_handler")
  end

  it { is_expected.to be_valid }

  context "when terms are not accepted" do
    let(:params) { super().merge(accept_terms: false) }

    it { is_expected.not_to be_valid }
  end

  context "when authorization_handler is invalid" do
    let(:params) do
      super().merge(
        authorization_handler: {
          handler_name: "dummy_authorization_handler",
          document_number: "123456789"
        }
      )
    end

    it "is invalid and exposes document_number errors" do
      expect(subject).not_to be_valid
      expect(subject.errors[:document_number]).to be_present
    end
  end
end
