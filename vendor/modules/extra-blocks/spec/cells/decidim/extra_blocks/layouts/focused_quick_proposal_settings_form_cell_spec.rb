# frozen_string_literal: true

require "spec_helper"

module Decidim::ExtraBlocks::Layouts
  describe FocusedQuickProposalSettingsFormCell, type: :cell do
    let(:organization) { create(:organization, available_authorizations: %w(dummy_authorization_handler)) }
    let(:participatory_process) { create(:participatory_process, :with_steps, organization:) }
    let(:proposal_component) do
      create(
        :proposal_component,
        :published,
        :with_creation_enabled,
        participatory_space: participatory_process,
        settings: { ephemeral_participation_enabled: true },
        permissions: {
          "create" => {
            "authorization_handlers" => {
              "dummy_authorization_handler" => {}
            }
          }
        }
      )
    end
    let(:content_block) do
      create(
        :content_block,
        organization:,
        manifest_name: :extra_block,
        scope_name: :homepage,
        settings: {
          "layout" => "focused_quick_proposal",
          "proposal_component_id" => proposal_component.id.to_s
        }
      )
    end
    let(:content_block_form) do
      Decidim::Admin::ContentBlockForm.from_model(content_block).with_context(
        current_organization: organization,
        content_block:
      )
    end

    controller Decidim::Admin::ApplicationController

    around do |example|
      I18n.with_locale(:en) { example.run }
    end

    before do
      allow(controller).to receive(:current_organization).and_return(organization)
      allow_any_instance_of(Decidim::Organization)
        .to receive(:ephemeral_participation_authorization)
        .and_return("dummy_authorization_handler")

      @cell_with_form = cell(
        "decidim/extra_blocks/layouts/focused_quick_proposal_settings_form",
        Decidim::FormBuilder.new(:content_block, content_block_form, controller.view_context, {}),
        content_block:
      )
    end

    subject { @cell_with_form.call }

    it "shows a success callout when the gate is open" do
      expect(subject).to have_content("Fast Proposal is ready to display")
      expect(subject).to have_css("select[name*='proposal_component_id']")
      expect(subject).to have_field(name: /\[title_/)
      expect(subject).to have_css(".editor input[name*='description']", visible: :all)
      expect(subject).to have_content("Background image")
      expect(subject).to have_css("fieldset legend", text: "Background fit")
    end

    context "when creation is disabled" do
      let(:proposal_component) do
        create(
          :proposal_component,
          :published,
          participatory_space: participatory_process,
          settings: { ephemeral_participation_enabled: true },
          permissions: {
            "create" => {
              "authorization_handlers" => {
                "dummy_authorization_handler" => {}
              }
            }
          },
          step_settings: {
            participatory_process.active_step.id => { creation_enabled: false }
          }
        )
      end

      it "warns that the block will not be displayed" do
        expect(subject).to have_content("Warn: this content block won't be displayed because:")
        expect(subject).to have_content("component is not open to proposal creation")
      end
    end
  end
end
