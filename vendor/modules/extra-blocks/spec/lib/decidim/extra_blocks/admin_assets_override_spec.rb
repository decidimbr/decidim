# frozen_string_literal: true

require "spec_helper"

describe "extra_blocks_admin_styles Deface override" do
  subject(:source) do
    Decidim::ExtraBlocks::Engine.root.join("app/overrides/extra_blocks_admin_styles.rb").read
  end

  it "appends stylesheet and javascript packs on the admin header" do
    expect(source).to include('append_stylesheet_pack_tag "decidim_extra_blocks"')
    expect(source).to include('append_javascript_pack_tag "decidim_extra_blocks"')
  end
end
