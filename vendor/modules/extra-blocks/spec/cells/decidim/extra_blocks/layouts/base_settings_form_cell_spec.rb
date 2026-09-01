# frozen_string_literal: true

require "spec_helper"

module Decidim::ExtraBlocks::Layouts
  describe BaseSettingsFormCell, type: :cell do
    # Decidim::ViewModel#call instruments with a block; bare `render` can resolve to
    # `block.erb`. BaseSettingsFormCell must always render `show.erb` via `.call`.
    subject { cell_instance.call }

    let(:organization) { create(:organization) }
    let(:content_block) do
      create(
        :content_block,
        organization:,
        manifest_name: :extra_block,
        scope_name: :homepage,
        settings: { "layout" => "verbose_cta" }
      )
    end
    let(:content_block_form) do
      Decidim::Admin::ContentBlockForm.from_model(content_block).with_context(
        current_organization: organization,
        content_block:
      )
    end
    let(:cell_instance) do
      cell(
        "decidim/extra_blocks/layouts/verbose_cta_settings_form",
        Decidim::FormBuilder.new(:content_block, content_block_form, controller.view_context, {}),
        content_block:
      )
    end

    controller Decidim::Admin::ApplicationController

    around do |example|
      I18n.with_locale(:en) { example.run }
    end

    before do
      allow(controller).to receive(:current_organization).and_return(organization)
    end

    it "is the superclass for layout settings-form cells" do
      expect(VerboseCtaSettingsFormCell.superclass).to eq(BaseSettingsFormCell)
      expect(ImpactMilestonesSettingsFormCell.superclass).to eq(BaseSettingsFormCell)
      expect(cell_instance).to be_a(BaseSettingsFormCell)
    end

    it "renders show.erb through Decidim instrumented #call" do
      expect { subject }.not_to raise_error
      expect(subject).to have_field("content_block[settings][layout]", type: :hidden, with: "verbose_cta")
      expect(subject.to_s).to include("background_color")
      expect(subject).to have_css("input[type=color][name*='background_color']")
      expect(subject).to have_css("fieldset legend", text: "Text color")
    end
  end
end
