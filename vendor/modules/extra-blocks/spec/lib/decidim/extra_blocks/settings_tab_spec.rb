# frozen_string_literal: true

require "spec_helper"

describe Decidim::ExtraBlocks::SettingsTab do
  it "registers the Extra Blocks organization settings tab" do
    tabs = double("tabs")
    allow(Decidim::Toggle).to receive(:settings_tabs).with(:organization_settings).and_yield(tabs)
    expect(tabs).to receive(:add_tab).with(
      :decidim_extra_blocks,
      kind_of(String),
      hash_including(
        form: Decidim::ExtraBlocks::Admin::ConfigForm,
        command: Decidim::ExtraBlocks::Admin::UpdateConfigCommand,
        module_name: Decidim::ExtraBlocks::MODULE_NAME
      )
    )

    described_class.register!
  end
end
