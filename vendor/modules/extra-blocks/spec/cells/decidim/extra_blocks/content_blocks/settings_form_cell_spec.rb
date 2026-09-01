# frozen_string_literal: true

require "spec_helper"

module Decidim::ExtraBlocks
  describe ContentBlocks::SettingsFormCell, type: :cell do
    subject { cell_instance.call }

    let(:organization) { create(:organization) }
    let(:layout) { nil }
    let(:content_block) do
      create(
        :content_block,
        organization:,
        manifest_name: :extra_block,
        scope_name: :homepage,
        settings: { "layout" => layout }
      )
    end
    let(:content_block_form) do
      Decidim::Admin::ContentBlockForm.from_model(content_block).with_context(
        current_organization: organization,
        content_block:
      )
    end
    let(:form) do
      Decidim::FormBuilder.new(:content_block, content_block_form, vc, {})
    end
    let(:vc) { cell_instance.send(:view_context) }
    let(:cell_instance) do
      cell("decidim/extra_blocks/content_blocks/settings_form", content_block_form, content_block:)
    end

    controller Decidim::Admin::ApplicationController

    before do
      allow(controller).to receive(:current_organization).and_return(organization)
      allow_any_instance_of(described_class).to receive(:asset_pack_path) { |path| "/packs/#{path}" }

      # Rebuild cell with FormBuilder once view_context is available
      @cell_with_form = cell(
        "decidim/extra_blocks/content_blocks/settings_form",
        Decidim::FormBuilder.new(:content_block, content_block_form, controller.view_context, {}),
        content_block:
      )
      allow(@cell_with_form).to receive(:asset_pack_path) { |path| "/packs/#{path}" }
    end

    subject { @cell_with_form.call }

    context "when layout is blank" do
      it "renders the layout gallery" do
        expect(subject).to have_css(".extra-blocks-gallery")
        expect(subject).to have_content("Verbose CTA")
        expect(subject).to have_content("Video Hero")
        expect(subject).to have_button("Use")
        expect(subject).to have_button("Details")
        expect(subject).to have_css("button.button.button__sm.button__secondary[data-open-confirm]")
        expect(subject).to have_no_css(".extra-blocks-gallery button.button__primary")
      end
    end

    context "when layout is frozen" do
      let(:layout) { "verbose_cta" }

      it "renders the layout settings form" do
        expect(subject).to have_field("content_block[settings][layout]", type: :hidden, with: "verbose_cta")
        expect(subject.to_s).to include("background_color")
        expect(subject).not_to have_css(".extra-blocks-gallery")
      end

      it "uses a color field and a text-color fieldset" do
        expect(subject).to have_css("input[type=color][name*='background_color']")
        expect(subject).to have_css("fieldset legend", text: "Text color")
      end
    end

    context "when layout is dual_path_cta" do
      let(:layout) { "dual_path_cta" }

      it "shows background fit radios" do
        expect(subject).to have_css("fieldset legend", text: "Background fit")
        expect(subject).to have_field("content_block[settings][background_fit]", type: :radio, with: "cover")
        expect(subject).to have_field("content_block[settings][background_fit]", type: :radio, with: "contain")
        expect(subject).to have_content("How the background image fills the block.")
      end
    end

    context "when layout is topic_trio" do
      let(:layout) { "topic_trio" }

      it "uses Decidim admin add button classes" do
        expect(subject).to have_css("button.button.button__sm.button__secondary[data-dynamic-slot-list-add]")
        expect(subject.to_s).not_to include("alert hollow")
      end

      it "shows topic image crop help" do
        expect(subject).to have_content("331px per card from 768px")
      end
    end

    context "when layout is media_aside" do
      let(:layout) { "media_aside" }

      it "shows aside image crop help" do
        expect(subject).to have_content("504px beside text from 768px")
      end
    end

    context "when layout is editorial_prose" do
      let(:layout) { "editorial_prose" }

      it "shows lead image crop help" do
        expect(subject).to have_content("Max display width 640px")
      end
    end
  end
end
