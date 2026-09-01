# frozen_string_literal: true

require "spec_helper"

module Decidim::ExtraBlocks::Layouts
  describe JoinStepsCtaCell, type: :cell do
    subject { cell_instance.call }

    let(:organization) { create(:organization) }
    let(:settings) do
      {
        "layout" => "join_steps_cta",
        "title" => { "en" => "Start in three steps" },
        "step_1_title" => { "en" => "Create an account" },
        "step_1_body" => { "en" => "Register with your email." },
        "step_2_title" => { "en" => "Explore processes" },
        "step_2_body" => { "en" => "Pick an open consultation." },
        "step_3_title" => { "en" => "Contribute" },
        "step_3_body" => { "en" => "Support or propose ideas." },
        "steps_json" => "",
        "button_label" => { "en" => "Create account" },
        "button_url" => "https://example.org/users/sign_up",
        "background_color" => "#ffffff",
        "text_color" => "black"
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
    let(:cell_instance) { cell("decidim/extra_blocks/layouts/join_steps_cta", content_block) }

    controller Decidim::PagesController

    around do |example|
      I18n.with_locale(:en) { example.run }
    end

    before do
      allow(controller).to receive(:current_organization).and_return(organization)
    end

    it "renders steps and the primary button" do
      expect(subject).to have_content("Start in three steps")
      expect(subject).to have_css("li.extra-blocks-join-steps-cta__step", count: 3)
      expect(subject).to have_content("Create an account")
      expect(subject).to have_link("Create account", href: "https://example.org/users/sign_up")
    end

    context "with background image" do
      before do
        blob = ActiveStorage::Blob.create_and_upload!(
          io: File.open(Decidim::Dev.asset("city.jpeg")),
          filename: "join-steps.jpeg",
          content_type: "image/jpeg"
        )
        content_block.images_container.background_image = blob
        content_block.images_container.save
        content_block.save!
      end

      it "renders a picture inside inner with proxy srcset" do
        expect(subject).to have_css(".extra-blocks-join-steps-cta__inner picture")
        expect(subject).not_to have_css("section.extra-blocks-join-steps-cta > picture")
        expect(subject).to have_css("img.extra-blocks-join-steps-cta__image")
        html = subject.native.to_html
        expect(html).to include("/rails/active_storage/")
        expect(html).to include("proxy")
        expect(html).to match(/1x|2x|3x/)
      end
    end
  end
end
