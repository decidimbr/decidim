# frozen_string_literal: true

require "spec_helper"

describe Decidim::ExtraBlocks::CreateFastProposal do
  let(:authorization_handler_name) { "dummy_authorization_handler" }
  let(:organization) do
    create(
      :organization,
      available_authorizations: {
        authorization_handler_name => { "allow_ephemeral_participation" => true }
      }
    )
  end
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
            authorization_handler_name => {}
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
        "proposal_component_id" => component.id.to_s,
        "default_title" => "Anonymous Proposal {{id}}",
        "default_title_connected" => "Proposal from {{id}}",
        "success_time" => "15"
      }
    )
  end
  let(:current_user) { nil }
  let(:document_number) { "123456789X" }
  let(:params) do
    {
      content_block_id: content_block.id,
      body: "This is a detailed proposal body for testing.",
      accept_terms: true,
      authorization_handler: {
        handler_name: authorization_handler_name,
        document_number:
      }
    }
  end
  let(:form) do
    Decidim::ExtraBlocks::FastProposalForm.from_params(params).with_context(
      current_organization: organization,
      current_user:
    )
  end
  let(:signed_in_user) { [] }
  let(:warden) do
    instance_double(Warden::Proxy).tap do |proxy|
      allow(proxy).to receive(:set_user) { |user, *_args| signed_in_user[0] = user }
      allow(proxy).to receive(:user) { signed_in_user[0] }
      allow(proxy).to receive(:authenticate)
      allow(proxy).to receive(:logout)
      allow(proxy).to receive(:clear_strategies_cache!)
    end
  end
  let(:request) do
    ActionDispatch::TestRequest.create.tap do |req|
      req.session = {}
      req.env["warden"] = warden
    end
  end

  def call_command
    outcomes = []
    command = described_class.new(form, request)
    command.on(:ok) { |_proposal, _redirect_url| outcomes << :ok }
    command.on(:invalid) { |payload| outcomes << payload }
    command.call
    outcomes
  end

  it "creates an ephemeral participant, authorizes, and publishes a proposal" do
    expect(call_command).to eq([:ok])

    user = signed_in_user[0]
    proposal = Decidim::Proposals::Proposal.order(:id).last

    expect(user).to be_present
    expect(user.name).to match(/\AParticipant \d+\z/)
    expect(user).to be_managed
    expect(user.extended_data["ephemeral_participation"]).to be_present
    expect(user.extended_data.dig("ephemeral_participation", "authorization_name")).to eq(authorization_handler_name)
    expect(Decidim::Authorization.find_by(user:, name: authorization_handler_name)).to be_granted
    expect(user).to be_verified_ephemeral_participant
    expect(proposal).to be_published
    expect(proposal.authors).to include(user)
    expect(translated(proposal.title)).to eq("Anonymous Proposal #{user.id}")
    expect(warden).to have_received(:set_user).at_least(:once)
  end

  context "when the anonymous title template starts in lowercase" do
    let(:content_block) do
      create(
        :content_block,
        organization:,
        manifest_name: :extra_block,
        scope_name: :homepage,
        settings: {
          "layout" => "focused_quick_proposal",
          "proposal_component_id" => component.id.to_s,
          "default_title" => "anonymous proposal {{id}}",
          "default_title_connected" => "Proposal from {{id}}",
          "success_time" => "15"
        }
      )
    end

    it "capitalizes the first letter and publishes" do
      expect(call_command).to eq([:ok])

      user = signed_in_user[0]
      title = translated(Decidim::Proposals::Proposal.order(:id).last.title)
      expect(title).to eq("Anonymous proposal #{user.id}")
    end
  end

  context "when the same unique authorization already belongs to an ephemeral participant" do
    let!(:existing_ephemeral_user) do
      create(
        :user,
        :confirmed,
        organization:,
        managed: true,
        extended_data: {
          "ephemeral_participation" => {
            "authorization_name" => authorization_handler_name,
            "component_id" => component.id,
            "permissions" => ["create"],
            "request_path" => "/"
          }
        }
      )
    end
    let!(:existing_authorization) do
      create(
        :authorization,
        :granted,
        user: existing_ephemeral_user,
        name: authorization_handler_name,
        unique_id: document_number
      )
    end

    it "reuses the existing ephemeral participant and publishes" do
      expect(call_command).to eq([:ok])

      user = signed_in_user[0]
      proposal = Decidim::Proposals::Proposal.order(:id).last

      expect(user).to eq(existing_ephemeral_user)
      expect(user).to be_verified_ephemeral_participant
      expect(proposal).to be_published
      expect(proposal.authors).to include(existing_ephemeral_user)
    end
  end

  context "when authorization data is invalid" do
    let(:document_number) { "123456789" }

    it "returns field errors and does not publish a proposal" do
      expect { expect(call_command.first).to include(:document_number) }
        .not_to change(Decidim::Proposals::Proposal, :count)
    end
  end

  context "when the body fails etiquette" do
    let(:params) do
      super().merge(body: "THIS IS A DETAILED PROPOSAL BODY WRITTEN ENTIRELY IN CAPITAL LETTERS.")
    end

    it "returns body field errors and does not publish a proposal" do
      expect { expect(call_command.first).to include(:body) }
        .not_to change(Decidim::Proposals::Proposal, :count)
    end
  end

  context "when the participant is logged in without authorization" do
    let!(:current_user) { create(:user, :confirmed, organization:) }

    it "authorizes the current user and publishes a proposal" do
      expect { expect(call_command).to eq([:ok]) }.not_to change(Decidim::User, :count)

      proposal = Decidim::Proposals::Proposal.order(:id).last
      expect(Decidim::Authorization.find_by(user: current_user, name: authorization_handler_name)).to be_granted
      expect(proposal.authors).to include(current_user)
      expect(translated(proposal.title)).to eq("Proposal from #{current_user.id}")
    end
  end

  context "when the participant is logged in with authorization" do
    let!(:current_user) { create(:user, :confirmed, organization:) }
    let!(:authorization) do
      create(
        :authorization,
        :granted,
        user: current_user,
        name: authorization_handler_name,
        unique_id: document_number
      )
    end
    let(:params) do
      {
        content_block_id: content_block.id,
        body: "This is a detailed proposal body for testing.",
        accept_terms: true
      }
    end

    it "authors the proposal without re-asking authorization fields" do
      expect { expect(call_command).to eq([:ok]) }.not_to change(Decidim::User, :count)

      proposal = Decidim::Proposals::Proposal.order(:id).last
      expect(proposal.authors).to include(current_user)
      expect(translated(proposal.title)).to eq("Proposal from #{current_user.id}")
    end

    context "with a short custom connected title template" do
      let(:content_block) do
        create(
          :content_block,
          organization:,
          manifest_name: :extra_block,
          scope_name: :homepage,
          settings: {
            "layout" => "focused_quick_proposal",
            "proposal_component_id" => component.id.to_s,
            "default_title" => "Anonymous Proposal {{id}}",
            "default_title_connected" => "Idea {{id}}",
            "success_time" => "15"
          }
        )
      end

      it "keeps the connected template and pads with random to meet the min length" do
        expect(call_command).to eq([:ok])

        title = translated(Decidim::Proposals::Proposal.order(:id).last.title)
        expect(title).to start_with("Idea #{current_user.id}")
        expect(title.length).to be >= 15
        expect(title).not_to eq("Proposal from #{current_user.id}")
      end
    end
  end

  context "when ephemeral participation is disabled on the component" do
    let(:component) do
      create(
        :proposal_component,
        :published,
        :with_creation_enabled,
        participatory_space: participatory_process,
        settings: { ephemeral_participation_enabled: false }
      )
    end

    it "rejects the form" do
      expect { expect(call_command.first).to be_a(Hash) }
        .not_to change(Decidim::Proposals::Proposal, :count)
    end
  end
end
