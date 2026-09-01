# frozen_string_literal: true

require "spec_helper"

module Decidim::ExtraBlocks::Layouts
  describe ProposalsAsideFastProposalCell, type: :cell do
    subject { cell_instance.call }

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
    let(:settings) do
      {
        "layout" => "proposals_aside_fast_proposal",
        "proposal_component_id" => proposal_component.id.to_s,
        "eyebrow" => { "en" => "From the community" },
        "title" => { "en" => "Submit your idea" },
        "description" => { "en" => "<p>Complete verification to participate.</p>" },
        "background_color" => "#ffffff",
        "text_color" => "black",
        "success_message" => { "en" => "Thanks {{seconds}}" },
        "success_button_label" => { "en" => "View proposals" },
        "success_time" => "15",
        "default_title" => "Anonymous Proposal {{id}}",
        "default_title_connected" => "Proposal from {{id}}"
      }
    end
    let(:content_block) do
      create(
        :content_block,
        organization:,
        manifest_name: :extra_block,
        scope_name: :homepage,
        settings:
      )
    end
    let(:cell_instance) { cell("decidim/extra_blocks/layouts/proposals_aside_fast_proposal", content_block) }

    controller Decidim::PagesController

    around do |example|
      I18n.with_locale(:en) { example.run }
    end

    before do
      allow(controller).to receive(:current_organization).and_return(organization)
      allow(controller).to receive(:current_user).and_return(nil)
      allow_any_instance_of(Decidim::Organization)
        .to receive(:ephemeral_participation_authorization)
        .and_return("dummy_authorization_handler")
    end

    it "renders form and intro without proposal cards when none exist" do
      expect(subject).to have_css("section.extra-blocks-proposals-aside-fast-proposal[data-extra-blocks-category='fast_proposal']")
      expect(subject).to have_css("form.extra-blocks-fast-proposal-form")
      expect(subject).to have_css("p.extra-blocks__eyebrow.extra-blocks-proposals-aside-fast-proposal__eyebrow", text: "From the community")
      expect(subject).to have_css("h2.extra-blocks__title.extra-blocks-proposals-aside-fast-proposal__title", text: "Submit your idea")
      expect(subject).to have_no_css("ul.extra-blocks-proposals-aside-fast-proposal__list")
    end

    context "with published proposals" do
      let!(:proposals) do
        create_list(
          :proposal,
          4,
          :published,
          component: proposal_component,
          body: { "en" => "A published proposal body for the aside card." }
        )
      end

      it "renders up to three proposal cards linking to comments" do
        expect(subject).to have_css("ul.extra-blocks-proposals-aside-fast-proposal__list")
        expect(subject).to have_css("a.extra-blocks__card.extra-blocks-proposals-aside-fast-proposal__card", count: 3)
        expect(subject).to have_css("p.extra-blocks-proposals-aside-fast-proposal__snippet", text: /published proposal body/i)
        href = subject.find("a.extra-blocks-proposals-aside-fast-proposal__card", match: :first)["href"]
        expect(href).to include("#comments")
      end
    end

    context "with fewer than three proposals" do
      let!(:proposals) do
        create_list(
          :proposal,
          2,
          :published,
          component: proposal_component,
          body: { "en" => "Only two proposals here." }
        )
      end

      it "renders the available proposals" do
        expect(subject).to have_css("a.extra-blocks-proposals-aside-fast-proposal__card", count: 2)
      end
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

      it "renders nothing" do
        expect(subject).to have_no_css("section.extra-blocks-proposals-aside-fast-proposal")
      end
    end
  end
end
