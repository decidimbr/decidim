# frozen_string_literal: true

require "spec_helper"

describe Decidim::ExtraBlocks::AdminListItemData do
  let(:organization) { create(:organization) }

  it "returns the layout category for Extra Blocks" do
    content_block = create(
      :content_block,
      organization:,
      manifest_name: :extra_block,
      scope_name: :homepage,
      settings: { "layout" => "verbose_cta" }
    )

    expect(described_class.category_for(content_block)).to eq(:cta)
  end

  it "returns nil for other manifests" do
    content_block = create(
      :content_block,
      organization:,
      manifest_name: :hero,
      scope_name: :homepage
    )

    expect(described_class.category_for(content_block)).to be_nil
  end
end
