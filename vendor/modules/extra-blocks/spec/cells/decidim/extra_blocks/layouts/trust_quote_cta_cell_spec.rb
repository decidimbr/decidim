# frozen_string_literal: true

require "spec_helper"

module Decidim::ExtraBlocks::Layouts
  describe TrustQuoteCtaCell, type: :cell do
    subject { cell_instance.call }

    let(:organization) { create(:organization) }
    let(:settings) do
      {
        "layout" => "trust_quote_cta",
        "quote" => { "en" => "This platform helped our neighborhood be heard." },
        "attribution_name" => { "en" => "Alex Martin" },
        "attribution_role" => { "en" => "Resident" },
        "button_label" => { "en" => "Join them" },
        "button_url" => "https://example.org/join",
        "background_color" => "#1a1a2e",
        "text_color" => "white"
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
    let(:cell_instance) { cell("decidim/extra_blocks/layouts/trust_quote_cta", content_block) }

    controller Decidim::PagesController

    around do |example|
      I18n.with_locale(:en) { example.run }
    end

    before do
      allow(controller).to receive(:current_organization).and_return(organization)
    end

    it "renders quote, attribution, and button" do
      expect(subject).to have_content("This platform helped our neighborhood be heard.")
      expect(subject).to have_content("Alex Martin")
      expect(subject).to have_content("Resident")
      expect(subject).to have_link("Join them", href: "https://example.org/join")
      expect(subject).to have_css("blockquote.extra-blocks-trust-quote-cta__quote-block.not-prose")
      expect(subject).to have_css("cite.extra-blocks-trust-quote-cta__name", text: "Alex Martin")
      expect(subject).to have_no_css("img.extra-blocks-trust-quote-cta__portrait")
    end
  end
end
