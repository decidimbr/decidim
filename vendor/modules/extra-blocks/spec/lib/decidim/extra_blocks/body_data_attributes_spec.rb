# frozen_string_literal: true

require "spec_helper"

describe Decidim::ExtraBlocks::BodyDataAttributes do
  subject(:attributes) { described_class.deface_attributes }

  it "exposes module and category body data keys" do
    expect(attributes).to include("data-extra-blocks-enabled")
    expect(attributes).to include("data-extra-blocks-cta-enabled")
    expect(attributes).to include("data-extra-blocks-hero-enabled")
    expect(attributes).to include("data-extra-blocks-text-enabled")
    expect(attributes).to include("data-extra-blocks-fast-proposal-enabled")
    expect(attributes).to include("data-extra-blocks-misc-enabled")
    expect(attributes).to include("data-extra-blocks-timelines-enabled")
  end

  it "binds Availability in the ERB snippets" do
    expect(attributes["data-extra-blocks-enabled"]).to include("Availability.module_enabled?")
    expect(attributes["data-extra-blocks-enabled"]).to include(".to_s")
    expect(attributes["data-extra-blocks-cta-enabled"]).to include("Availability.category_enabled?")
  end
end
