# frozen_string_literal: true

require "spec_helper"

describe Decidim::ExtraBlocks::Admin::ContentBlockCellExtensions do
  let(:organization) { create(:organization) }
  let(:host) do
    Class.new do
      def initialize(model)
        @model = model
      end

      attr_reader :model

      def name
        I18n.t(model.public_name_key)
      end
    end.prepend(described_class)
  end

  it "uses AdminDisplayName for Extra Blocks" do
    content_block = create(
      :content_block,
      organization:,
      manifest_name: :extra_block,
      scope_name: :homepage,
      settings: { "layout" => "video_hero" }
    )

    expect(host.new(content_block).name).to eq("Video Hero (Extra Block)")
  end

  it "defers to the original name for other content blocks" do
    content_block = create(
      :content_block,
      organization:,
      manifest_name: :hero,
      scope_name: :homepage
    )

    expect(host.new(content_block).name).to eq(I18n.t(content_block.public_name_key))
  end
end
