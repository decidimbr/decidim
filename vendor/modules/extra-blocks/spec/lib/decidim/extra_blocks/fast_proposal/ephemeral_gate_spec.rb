# frozen_string_literal: true

require "spec_helper"

describe Decidim::ExtraBlocks::FastProposal::EphemeralGate do
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

  before do
    allow_any_instance_of(Decidim::Organization)
      .to receive(:ephemeral_participation_authorization)
      .and_return("dummy_authorization_handler")
  end

  it "opens when creation and ephemeral create permission are enabled" do
    expect(described_class.open?(component)).to be(true)
    expect(described_class.closed_reasons(component)).to eq([])
  end

  it "closes when ephemeral participation is disabled" do
    component.update!(settings: component.settings.to_h.merge("ephemeral_participation_enabled" => false))
    expect(described_class.open?(component)).to be(false)
    expect(described_class.closed_reasons(component)).to include(:ephemeral_creation_disabled)
  end

  it "closes when creation is disabled" do
    component.update!(
      step_settings: {
        participatory_process.active_step.id => { creation_enabled: false }
      }
    )
    expect(described_class.open?(component)).to be(false)
    expect(described_class.closed_reasons(component)).to include(:creation_disabled)
  end

  it "closes when create permission lacks ephemeral authorization" do
    component.update!(permissions: {})
    expect(described_class.open?(component)).to be(false)
    expect(described_class.closed_reasons(component)).to include(:missing_ephemeral_authorization_in_permissions)
  end

  it "returns missing_component when component is blank" do
    expect(described_class.closed_reasons(nil)).to eq([:missing_component])
  end
end
