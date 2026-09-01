# frozen_string_literal: true

require "spec_helper"

module Decidim::ExtraBlocks::Layouts
  describe VideoFastProposalCell, type: :cell do
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
        "layout" => "video_fast_proposal",
        "proposal_component_id" => proposal_component.id.to_s,
        "eyebrow" => { "en" => "From the street" },
        "title" => { "en" => "Submit your idea" },
        "description" => { "en" => "<p>Complete verification to participate.</p>" },
        "background_color" => "#112233",
        "text_color" => "white",
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
    let(:cell_instance) { cell("decidim/extra_blocks/layouts/video_fast_proposal", content_block) }

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

    it "renders centered form without video when none attached" do
      html = subject.to_s
      expect(html).to include("--eb-bg: #112233")
      expect(html).to include("--eb-fg: #ffffff")
      expect(subject).to have_css("section.extra-blocks-video-fast-proposal.prose.prose-invert[data-extra-blocks-category='fast_proposal']")
      expect(html).not_to include("<video")
      expect(subject).to have_css("form.extra-blocks-fast-proposal-form")
      expect(subject).to have_css("p.extra-blocks__eyebrow.extra-blocks-video-fast-proposal__eyebrow", text: "From the street")
      expect(subject).to have_css("h2.extra-blocks__title.extra-blocks-video-fast-proposal__title", text: "Submit your idea")
      expect(subject).to have_field("body")
    end

    context "with webm and mp4" do
      before do
        webm = ActiveStorage::Blob.create_and_upload!(
          io: StringIO.new("fake-webm"),
          filename: "bg.webm",
          content_type: "video/webm"
        )
        mp4 = ActiveStorage::Blob.create_and_upload!(
          io: StringIO.new("fake-mp4"),
          filename: "bg.mp4",
          content_type: "video/mp4"
        )
        content_block.images_container.background_video_webm = webm
        content_block.images_container.background_video = mp4
        content_block.save!
      end

      it "renders webm before mp4" do
        expect(subject).to have_css("video.extra-blocks__media.extra-blocks-video-fast-proposal__video")
        expect(subject).to have_no_css("video[autoplay]")
        sources = subject.to_s.scan(%r{type="(video/[^"]+)"}).flatten
        expect(sources).to eq(%w(video/webm video/mp4))
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
        expect(subject).to have_no_css("section.extra-blocks-video-fast-proposal")
      end
    end
  end
end
