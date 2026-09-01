# frozen_string_literal: true

require "spec_helper"

describe Decidim::ExtraBlocks::Admin::UpdateConfigCommand do
  let(:organization) { create(:organization) }
  let(:attributes) { { enabled: true, cta_enabled: true, hero_enabled: true, fast_proposal_enabled: true } }
  let(:form) do
    Decidim::ExtraBlocks::Admin::ConfigForm.from_params(
      organization: attributes
    ).with_context(current_organization: organization)
  end

  before do
    Decidim::Toggle.save_config!(
      organization,
      Decidim::ExtraBlocks::MODULE_NAME,
      { "enabled" => true, "cta_enabled" => true, "hero_enabled" => true, "fast_proposal_enabled" => true },
      merge: false
    )
  end

  def call_command
    outcomes = []
    command = described_class.new(organization, form)
    command.on(:ok) { outcomes << :ok }
    command.on(:invalid) { outcomes << :invalid }
    command.call
    outcomes
  end

  it "preserves category flags when disabling the module" do
    attributes.replace("enabled" => false, "cta_enabled" => false, "hero_enabled" => false, "fast_proposal_enabled" => false)

    expect(call_command).to eq([:ok])
    raw = Decidim::ExtraBlocks::Availability.raw_config(organization)
    expect(raw["enabled"]).to be(false)
    expect(raw["cta_enabled"]).to be(true)
    expect(raw["hero_enabled"]).to be(true)
    expect(raw["fast_proposal_enabled"]).to be(true)
  end

  it "updates category flags when the module stays enabled" do
    attributes.replace("enabled" => true, "cta_enabled" => false, "hero_enabled" => true, "fast_proposal_enabled" => false)

    expect(call_command).to eq([:ok])
    raw = Decidim::ExtraBlocks::Availability.raw_config(organization)
    expect(raw["enabled"]).to be(true)
    expect(raw["cta_enabled"]).to be(false)
    expect(raw["hero_enabled"]).to be(true)
    expect(raw["fast_proposal_enabled"]).to be(false)
  end
end
