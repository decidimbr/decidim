# frozen_string_literal: true

require "spec_helper"

describe "Admin configures Extra Block", type: :system do
  let(:organization) { create(:organization) }
  let(:user) { create(:user, :admin, :confirmed, organization:) }
  let!(:content_block) do
    create(
      :content_block,
      organization:,
      manifest_name: :extra_block,
      scope_name: :homepage,
      published_at: Time.current,
      settings: { "layout" => nil }
    )
  end

  before do
    switch_to_host(organization.host)
    login_as user, scope: :user
  end

  it "freezes verbose_cta, configures it, and shows it on the homepage" do
    visit decidim_admin.edit_organization_homepage_content_block_path(content_block)

    expect(page).to have_css(".extra-blocks-gallery")
    expect(page).to have_content("Verbose CTA")

    within "#extra-blocks-layout-verbose_cta" do
      click_on "Use"
    end

    within "#extra-blocks-confirm-verbose_cta" do
      click_on "Use this layout"
    end

    expect(page).to have_current_path(decidim_admin.edit_organization_homepage_content_block_path(content_block))
    expect(content_block.reload.settings.layout).to eq("verbose_cta")
    expect(page).to have_css("h1.item_show__header-title", text: "Verbose CTA (Extra Block)")
    expect(page).to have_css(
      "a.button.button__transparent-secondary.button__sm[href='#{decidim_admin.edit_organization_homepage_path}']",
      text: I18n.t("decidim.extra_blocks.admin.edit.back")
    )
    expect(page).to have_field("content_block[settings][layout]", type: :hidden, with: "verbose_cta")

    fill_in "content_block_settings_title_en", with: "Join the process"
    fill_in "content_block[settings][button_url]", with: "https://example.org/join"
    fill_in "content_block_settings_button_label_en", with: "Participate"

    click_on "Update"
    expect(page).to have_current_path(decidim_admin.edit_organization_homepage_content_block_path(content_block))
    expect(page).to have_link(
      I18n.t("decidim.extra_blocks.admin.edit.back"),
      href: decidim_admin.edit_organization_homepage_path
    )

    click_on I18n.t("decidim.extra_blocks.admin.edit.back")
    expect(page).to have_current_path(decidim_admin.edit_organization_homepage_path)
    expect(page).to have_content("Verbose CTA (Extra Block)")

    visit decidim.root_path
    expect(page).to have_css("section.extra-blocks-verbose-cta")
    expect(page).to have_content("Join the process")
  end

  it "freezes photo_mission_hero and shows it on the homepage" do
    visit decidim_admin.edit_organization_homepage_content_block_path(content_block)

    expect(page).to have_content("Photo Mission Hero")

    within "#extra-blocks-layout-photo_mission_hero" do
      click_on "Use"
    end

    expect(page).to have_css("#extra-blocks-confirm-photo_mission_hero[open]")

    within "#extra-blocks-confirm-photo_mission_hero" do
      click_on "Use this layout"
    end

    expect(page).to have_current_path(decidim_admin.edit_organization_homepage_content_block_path(content_block))
    expect(page).to have_field("content_block[settings][layout]", type: :hidden, with: "photo_mission_hero")
    expect(content_block.reload.settings.layout).to eq("photo_mission_hero")

    fill_in "content_block_settings_title_en", with: "Your voice shapes the city"
    fill_in "content_block_settings_tagline_en", with: "Participate locally"

    click_on "Update"
    expect(page).to have_current_path(decidim_admin.edit_organization_homepage_content_block_path(content_block))

    visit decidim.root_path
    expect(page).to have_css("section.extra-blocks-photo-mission-hero")
    expect(page).to have_content("Your voice shapes the city")
    expect(page).to have_content("Participate locally")
  end

  it "does not show the gallery after the layout is frozen" do
    content_block.update!(settings: { "layout" => "verbose_cta" })

    visit decidim_admin.edit_organization_homepage_content_block_path(content_block)

    expect(page).not_to have_css(".extra-blocks-gallery")
    expect(page).to have_field("content_block[settings][layout]", type: :hidden, with: "verbose_cta")
  end
end
