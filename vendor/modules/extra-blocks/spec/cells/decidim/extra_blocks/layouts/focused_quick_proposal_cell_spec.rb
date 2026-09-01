# frozen_string_literal: true

require "spec_helper"

module Decidim::ExtraBlocks::Layouts
  describe FocusedQuickProposalCell, type: :cell do
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
        "layout" => "focused_quick_proposal",
        "proposal_component_id" => proposal_component.id.to_s,
        "eyebrow" => { "en" => "Quick share" },
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
    let(:cell_instance) { cell("decidim/extra_blocks/layouts/focused_quick_proposal", content_block) }

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

    it "renders the centered form for guests with authorization fields" do
      expect(subject).to have_css("section.extra-blocks-focused-quick-proposal[data-extra-blocks-category='fast_proposal']")
      expect(subject).to have_css("form.extra-blocks-fast-proposal-form[data-turbo='false']")
      expect(subject).to have_no_css("form.extra-blocks-fast-proposal-form[data-remote='true']")
      expect(subject).to have_css("p.extra-blocks__eyebrow.extra-blocks-focused-quick-proposal__eyebrow", text: "Quick share")
      expect(subject).to have_css("h2.extra-blocks__title.extra-blocks-focused-quick-proposal__title", text: "Submit your idea")
      expect(subject).to have_css("div.extra-blocks__description.extra-blocks-focused-quick-proposal__description", text: "Complete verification to participate.")
      expect(subject).to have_no_content("Complete this verification to submit as a participant.")
      expect(subject).to have_no_field("full_name")
      expect(subject).to have_no_field("identifier")
      expect(subject).to have_field("authorization_handler[document_number]")
      expect(subject).to have_field("body")
      expect(subject).to have_css("label[for='fast_proposal_body'] .label-required", text: "*")
      expect(subject).to have_css("textarea#fast_proposal_body[rows='3']")
      expect(subject).to have_field("accept_terms")
      expect(subject).to have_content("an anonymous account will be created")
      expect(subject).to have_link("log in")
      expect(subject).to have_button("Submit proposal")
    end

    context "with custom terms" do
      let(:settings) do
        super().merge("terms" => { "en" => "<p>Custom terms body</p>" })
      end

      it "renders terms body with prose" do
        expect(subject).to have_css(
          "div.extra-blocks-fast-proposal-form__terms-body.prose",
          text: "Custom terms body"
        )
      end
    end

    context "with background image" do
      before do
        blob = ActiveStorage::Blob.create_and_upload!(
          io: StringIO.new("fake-png"),
          filename: "focused_quick_proposal.png",
          content_type: "image/png"
        )
        content_block.images_container.background_image = blob
        content_block.save!
      end

      it "renders a full-width picture with proxy srcset" do
        html = subject.to_s
        expect(html).to include("<picture")
        expect(html).to include("extra-blocks__media")
        expect(html).to include("extra-blocks-focused-quick-proposal__image")
        expect(html).to include("/rails/active_storage/")
        expect(html).to include("proxy")
        expect(html).not_to include("/blobs/redirect/")
        expect(html).to match(/1x|2x|3x/)
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
        expect(subject).to have_no_css("section.extra-blocks-focused-quick-proposal")
        expect(subject).to have_no_css("form.extra-blocks-fast-proposal-form")
      end
    end

    context "when the user is logged in without authorization" do
      let(:user) { create(:user, :confirmed, organization:) }

      before do
        allow(controller).to receive(:current_user).and_return(user)
      end

      it "shows authorization fields and body" do
        expect(subject).to have_field("authorization_handler[document_number]")
        expect(subject).to have_field("body")
        expect(subject).to have_no_field("accept_terms")
        expect(subject).to have_no_css("div.extra-blocks-fast-proposal-form__terms")
      end
    end

    context "when the user is logged in with authorization" do
      let(:user) { create(:user, :confirmed, organization:) }

      before do
        create(
          :authorization,
          :granted,
          user:,
          name: "dummy_authorization_handler",
          unique_id: "123456789X"
        )
        allow(controller).to receive(:current_user).and_return(user)
      end

      it "hides authorization fields" do
        expect(subject).to have_no_field("authorization_handler[document_number]")
        expect(subject).to have_field("body")
        expect(subject).to have_no_field("accept_terms")
      end
    end
  end
end
