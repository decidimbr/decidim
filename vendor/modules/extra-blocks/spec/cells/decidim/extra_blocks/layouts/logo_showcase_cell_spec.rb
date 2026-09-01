# frozen_string_literal: true

require "spec_helper"

module Decidim::ExtraBlocks::Layouts
  describe LogoShowcaseCell, type: :cell do
    subject { cell_instance.call }

    let(:organization) { create(:organization) }
    let(:settings) do
      {
        "layout" => "logo_showcase",
        "background_color" => "#fafafa",
        "logos_json" => [
          { "slot" => 1, "alt" => { "en" => "Partner One" } }
        ].to_json
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
    let(:cell_instance) { cell("decidim/extra_blocks/layouts/logo_showcase", content_block) }

    controller Decidim::PagesController

    before do
      allow(controller).to receive(:current_organization).and_return(organization)
    end

    it "renders an empty misc section without logos" do
      expect(subject).to have_css(
        "section.extra-blocks-logo-showcase[data-extra-blocks-category='misc']"
      )
      expect(subject).to have_no_css(".extra-blocks-logo-showcase__img")
    end

    context "with an attached logo" do
      before do
        blob = ActiveStorage::Blob.create_and_upload!(
          io: File.open(Decidim::Dev.asset("city.jpeg")),
          filename: "partner.jpeg",
          content_type: "image/jpeg"
        )
        content_block.images_container.logo_1 = blob
        content_block.save!
      end

      it "renders the logo grid with greyscale image class" do
        I18n.with_locale(:en) do
          expect(subject).to have_css(".extra-blocks-logo-showcase__grid")
          expect(subject).to have_css("img.extra-blocks-logo-showcase__img[alt='Partner One']")
        end
      end
    end
  end
end
