# frozen_string_literal: true

require "spec_helper"

describe Decidim::ExtraBlocks::Availability do
  let(:organization) { create(:organization) }
  let(:other_organization) { create(:organization) }

  describe ".module_enabled?" do
    it "defaults to true when no config row exists" do
      expect(described_class.module_enabled?(organization)).to be(true)
    end

    it "returns false when enabled is persisted as false" do
      Decidim::Toggle.save_config!(
        organization,
        Decidim::ExtraBlocks::MODULE_NAME,
        { "enabled" => false },
        merge: false
      )

      expect(described_class.module_enabled?(organization)).to be(false)
    end

    it "isolates tenants" do
      Decidim::Toggle.save_config!(
        organization,
        Decidim::ExtraBlocks::MODULE_NAME,
        { "enabled" => false },
        merge: false
      )

      expect(described_class.module_enabled?(other_organization)).to be(true)
    end
  end

  describe ".category_enabled?" do
    it "defaults to true when module is on and category key is missing" do
      expect(described_class.category_enabled?(organization, :cta)).to be(true)
      expect(described_class.category_enabled?(organization, :hero)).to be(true)
      expect(described_class.category_enabled?(organization, :text)).to be(true)
      expect(described_class.category_enabled?(organization, :fast_proposal)).to be(true)
      expect(described_class.category_enabled?(organization, :misc)).to be(true)
      expect(described_class.category_enabled?(organization, :timelines)).to be(true)
    end

    it "returns false for every category when the module is off" do
      Decidim::Toggle.save_config!(
        organization,
        Decidim::ExtraBlocks::MODULE_NAME,
        {
          "enabled" => false,
          "cta_enabled" => true,
          "hero_enabled" => true,
          "text_enabled" => true,
          "fast_proposal_enabled" => true,
          "misc_enabled" => true,
          "timelines_enabled" => true
        },
        merge: false
      )

      expect(described_class.category_enabled?(organization, :cta)).to be(false)
      expect(described_class.category_enabled?(organization, :hero)).to be(false)
      expect(described_class.category_enabled?(organization, :text)).to be(false)
      expect(described_class.category_enabled?(organization, :fast_proposal)).to be(false)
      expect(described_class.category_enabled?(organization, :misc)).to be(false)
      expect(described_class.category_enabled?(organization, :timelines)).to be(false)
    end

    it "respects per-category flags when the module is on" do
      Decidim::Toggle.save_config!(
        organization,
        Decidim::ExtraBlocks::MODULE_NAME,
        {
          "enabled" => true,
          "cta_enabled" => false,
          "hero_enabled" => true,
          "text_enabled" => true,
          "fast_proposal_enabled" => false,
          "misc_enabled" => false,
          "timelines_enabled" => false
        },
        merge: false
      )

      expect(described_class.category_enabled?(organization, :cta)).to be(false)
      expect(described_class.category_enabled?(organization, :hero)).to be(true)
      expect(described_class.category_enabled?(organization, :text)).to be(true)
      expect(described_class.category_enabled?(organization, :fast_proposal)).to be(false)
      expect(described_class.category_enabled?(organization, :misc)).to be(false)
      expect(described_class.category_enabled?(organization, :timelines)).to be(false)
    end
  end

  describe ".effective_categories" do
    it "returns only enabled categories" do
      Decidim::Toggle.save_config!(
        organization,
        Decidim::ExtraBlocks::MODULE_NAME,
        {
          "enabled" => true,
          "cta_enabled" => true,
          "hero_enabled" => false,
          "text_enabled" => false,
          "fast_proposal_enabled" => false,
          "misc_enabled" => false,
          "timelines_enabled" => false
        },
        merge: false
      )

      expect(described_class.effective_categories(organization)).to eq([:cta])
    end
  end
end
