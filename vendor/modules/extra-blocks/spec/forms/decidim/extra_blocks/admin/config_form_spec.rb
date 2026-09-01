# frozen_string_literal: true

require "spec_helper"

describe Decidim::ExtraBlocks::Admin::ConfigForm do
  subject(:form) { described_class.from_params(params).with_context(current_organization: organization) }

  let(:organization) { create(:organization) }
  let(:params) do
    {
      organization: {
        enabled: true,
        cta_enabled: true,
        hero_enabled: true,
        fast_proposal_enabled: true
      }
    }
  end

  it "disables category attributes when the module is off" do
    form = described_class.from_params(
      organization: { enabled: false, cta_enabled: true, hero_enabled: true, fast_proposal_enabled: true }
    ).with_context(current_organization: organization)

    expect(form.attribute_disabled?(:enabled)).to be(false)
    expect(form.attribute_disabled?(:cta_enabled)).to be(true)
    expect(form.attribute_disabled?(:hero_enabled)).to be(true)
    expect(form.attribute_disabled?(:fast_proposal_enabled)).to be(true)
  end

  it "enables category attributes when the module is on" do
    expect(form.attribute_disabled?(:cta_enabled)).to be(false)
    expect(form.attribute_disabled?(:hero_enabled)).to be(false)
    expect(form.attribute_disabled?(:fast_proposal_enabled)).to be(false)
  end

  describe ".from_model" do
    before do
      Decidim::Toggle.save_config!(
        organization,
        Decidim::ExtraBlocks::MODULE_NAME,
        { "enabled" => false, "cta_enabled" => true, "hero_enabled" => true, "fast_proposal_enabled" => true },
        merge: false
      )
    end

    it "presents category checkboxes as unchecked when the module is off" do
      loaded = described_class.from_model(organization)

      expect(loaded.enabled).to be(false)
      expect(loaded.cta_enabled).to be(false)
      expect(loaded.hero_enabled).to be(false)
      expect(loaded.fast_proposal_enabled).to be(false)
    end
  end

  describe "#persistable_attributes" do
    context "when the module is enabled" do
      it "includes category flags" do
        expect(form.persistable_attributes).to include(
          "enabled" => true,
          "cta_enabled" => true,
          "hero_enabled" => true,
          "fast_proposal_enabled" => true
        )
      end
    end

    context "when the module is disabled" do
      let(:params) do
        {
          organization: {
            enabled: false,
            cta_enabled: false,
            hero_enabled: false,
            fast_proposal_enabled: false
          }
        }
      end

      it "only persists enabled false so category flags are not wiped" do
        expect(form.persistable_attributes).to eq("enabled" => false)
      end
    end
  end
end
