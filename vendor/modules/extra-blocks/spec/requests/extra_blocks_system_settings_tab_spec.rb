# frozen_string_literal: true

require "spec_helper"

describe "Extra Blocks system settings tab" do
  let(:organization) { create(:organization) }
  let(:admin) { create(:admin) }
  let(:path) do
    "/decidim_toggle/system/organizations/#{organization.id}/settings_tab/decidim_extra_blocks"
  end
  let(:category_enabled_keys) do
    Decidim::ExtraBlocks::Layouts::LayoutRegistry.categories.map { |category| "#{category}_enabled" }
  end

  before do
    # Request specs do not submit authenticity tokens; Toggle settings_tab enforces CSRF.
    allow_any_instance_of(ActionController::Base).to receive(:protect_against_forgery?).and_return(false)

    login_as admin, scope: :admin
    seed = { "enabled" => true }
    category_enabled_keys.each { |key| seed[key] = true }
    Decidim::Toggle.save_config!(
      organization,
      Decidim::ExtraBlocks::MODULE_NAME,
      seed,
      merge: false
    )
  end

  it "saves module and category flags and reloads them" do
    disable_params = { "enabled" => "0" }
    category_enabled_keys.each { |key| disable_params[key] = "0" }

    patch path, params: {
      organization: disable_params,
      decidim_toggle_active_tab: "decidim_extra_blocks"
    }

    expect(response).to redirect_to(
      decidim_system.edit_organization_path(organization, anchor: "panel-toggle-decidim_extra_blocks")
    )

    config = Decidim::Toggle.config_for(organization, Decidim::ExtraBlocks::MODULE_NAME)
    expect(ActiveModel::Type::Boolean.new.cast(config["enabled"])).to be(false)
    # Category flags must not be wiped when the module is disabled.
    expect(ActiveModel::Type::Boolean.new.cast(config["cta_enabled"])).to be(true)
    expect(ActiveModel::Type::Boolean.new.cast(config["hero_enabled"])).to be(true)

    enable_params = { "enabled" => "1", "cta_enabled" => "0", "hero_enabled" => "1" }
    category_enabled_keys.each do |key|
      enable_params[key] ||= "1"
    end

    patch path, params: { organization: enable_params }

    expect(response).to redirect_to(decidim_system.edit_organization_path(organization))
    config = Decidim::Toggle.config_for(organization.reload, Decidim::ExtraBlocks::MODULE_NAME)
    expect(ActiveModel::Type::Boolean.new.cast(config["enabled"])).to be(true)
    expect(ActiveModel::Type::Boolean.new.cast(config["cta_enabled"])).to be(false)
    expect(ActiveModel::Type::Boolean.new.cast(config["hero_enabled"])).to be(true)

    get decidim_system.edit_organization_path(organization)
    expect(response.body).to include(I18n.t("decidim_toggle.system.decidim_extra_blocks.tab"))
    expect(response.body).to include("panel-toggle-decidim_extra_blocks")
  end
end
